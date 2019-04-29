//
//  SyncManager.m
//  mazimao
//
//  Created by wuhan006 on 2019/4/25.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "SyncManager.h"
#import "ChaptersResponseModel.h"

@interface SyncManager () <YBResponseDelegate>
@property (nonatomic, strong) MZMRequest *bookPullRequest;
@property (nonatomic, strong) MZMRequest *bookUpdateRequest;

@property (nonatomic, copy) NSString *bookid;
@property (nonatomic, copy) NSString *supdatets;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger allPage;
@property (nonatomic, strong) MZMRequest *chapterPullRequest;
@property (nonatomic, strong) MZMRequest *chapterUpdateRequest;

@property (nonatomic, assign) NSInteger qgCurrentPage;
@property (nonatomic, assign) NSInteger qgAllPage;

@end

@implementation SyncManager

+ (SyncManager *)shared {
	static SyncManager *manager;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		manager = [[self alloc] init];
	});
	return manager;
}

- (void)syncBooks {
	NSDictionary *paras = @{
							@"account_id": [[NSUserDefaults standardUserDefaults] stringForKey:@"account_id"],
							@"request_ts": [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] * 1000],
							@"supdatets": [MzmBook getNewestSupdatets]
							};
	
	self.bookPullRequest = [[MZMRequest alloc] initWithType:URITypeMzmBookList paras:paras delegate:self];
	[self.bookPullRequest start];
}

- (void)syncChaptersWithBookid:(NSString *)bookid {
	self.bookid = bookid;
	self.supdatets = [MzmChapter getNewestSupdatetsWithBookid:self.bookid];
	self.currentPage = 1;
	self.allPage = 1;
	self.qgCurrentPage = 1;
	self.qgAllPage = 1;
	
	[self pullChaptersWithCurrentPage];
}

- (void)pullChaptersWithCurrentPage {
	if (self.currentPage > self.allPage) {//拉取完成
		self.supdatets = @"1";
		self.currentPage = 1;
		self.allPage = 1;
		[self pullNewestChaptersWithMZMBookid:self.bookid];
		
		return;
	}
	NSDictionary *paras = @{
							@"account_id": [[NSUserDefaults standardUserDefaults] stringForKey:@"account_id"],
							@"request_ts": [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] * 1000],
							@"supdatets": self.supdatets,
							@"book_id": self.bookid,
							@"page": [NSString stringWithFormat:@"%ld",self.currentPage],
							@"page_size": @"50"
							};
	MZMRequest *request = [[MZMRequest alloc] initWithType:URITypeMzmChapterList paras:paras];
	[request startWithSuccess:^(YBNetworkResponse * _Nonnull response) {
		MzmChaptersResponse *res = [MzmChaptersResponse yy_modelWithJSON:response.responseObject];
		if ([res.code isEqualToString:@"20000"]) {
			[MzmChapter updateWithChapters:res.data.chapters];
			self.allPage = res.data.all_page_num;
			self.currentPage++;
			[self pullChaptersWithCurrentPage];
			
		} else {
			if (self.delegate && [self.delegate respondsToSelector:@selector(syncManager:syncChaptersWithResult:)]) {
				[self.delegate syncManager:[SyncManager shared] syncChaptersWithResult:NO];
			}
		}
	} failure:^(YBNetworkResponse * _Nonnull response) {
		if (self.delegate && [self.delegate respondsToSelector:@selector(syncManager:syncChaptersWithResult:)]) {
			[self.delegate syncManager:[SyncManager shared] syncChaptersWithResult:NO];
		}
	}];
}

///获取青果上最新的章节，因为本地没有这些章节，所以还需要获取章节content
- (void)pullNewestChaptersWithMZMBookid:(NSString *)mzmBookid {
	if (self.qgCurrentPage > self.qgAllPage) {
		self.qgCurrentPage = 1;
		self.qgAllPage = 1;
		
		[self pullDiscontinuousChaptersWithMZMBookid:mzmBookid];
		
		return;
	}
	self.qgCurrentPage = ([MzmChapter getBiggestSNWithBookid:mzmBookid]) / 30 + 1;
	self.qgAllPage = self.qgCurrentPage;
	
	[self pullQGChaptersWithMZMBookid:mzmBookid page:self.currentPage result:^(ChaptersResponseModel *chaptersResponseModel) {
		if (chaptersResponseModel) {
			self.qgAllPage = chaptersResponseModel.model.pages;
			self.qgCurrentPage++;
			
			NSArray<ChapterInfo *> *qgChapters = chaptersResponseModel.model.data;
			for (ChapterInfo *info in qgChapters) {
				[self pullChapterContentWithChapterInfo:info result:^(NSString *content) {
					info.content = content;
				}];
			}
			for (ChapterInfo *qgChapter in qgChapters) {
				MzmChapter *mzmChapter = [[MzmChapter alloc] initWithQGChapter:qgChapter];
				[MzmChapter updateWithChapters:@[mzmChapter]];
			}
			
			[self pullNewestChaptersWithMZMBookid:mzmBookid];
		} else {//失败，走下一步
			[self pullDiscontinuousChaptersWithMZMBookid:mzmBookid];
		}
	}];
}

///在青果上获取本地没有的不连续章节
- (void)pullDiscontinuousChaptersWithMZMBookid:(NSString *)mzmBookid {
	NSArray<NSNumber *> *discontinuousSN = [MzmChapter getDiscontinuousSNWithBookid:mzmBookid];
	
	NSMutableArray<NSNumber *> *pageArr = [NSMutableArray array];
	for (NSNumber *tmp in discontinuousSN) {
		NSInteger sn = tmp.integerValue;
		NSInteger page = (sn - 1) / 30 + 1;
		NSNumber *pageNum = [NSNumber numberWithInteger:page];
		if (![pageArr containsObject:pageNum]) {
			[pageArr addObject:pageNum];
		}
	}
	
	NSMutableArray<MzmChapter *> *mzmChapters = [NSMutableArray array];
	//根据求得的页数请求章节
	dispatch_group_t group = dispatch_group_create();
	for (NSInteger i = 0; i < pageArr.count; i++) {
		dispatch_group_enter(group);
		NSInteger page = pageArr[i].integerValue;
		[self pullQGChaptersWithMZMBookid:mzmBookid page:page result:^(ChaptersResponseModel *chaptersResponseModel) {
			if (chaptersResponseModel) {
				NSArray<ChapterInfo *> *qgChapters = chaptersResponseModel.model.data;
				for (NSInteger j = 0; j < qgChapters.count; j++) {
					ChapterInfo *qgChapter = qgChapters[j];
					[self pullChapterContentWithChapterInfo:qgChapter result:^(NSString *content) {
						qgChapter.content = content;
						
						for (NSInteger k = 0; k < discontinuousSN.count; k++) {
							NSNumber *snNum = discontinuousSN[k];
							NSInteger sn = snNum.integerValue;
							if (qgChapter.sn == sn) {
								MzmChapter *mzmChapter = [[MzmChapter alloc] initWithQGChapter:qgChapter];
								[mzmChapters addObject:mzmChapter];
							}
							if ((j == qgChapters.count - 1) && (k == discontinuousSN.count - 1)) {
								dispatch_group_leave(group);
							}
						}
					}];
				}
			} else {
				dispatch_group_leave(group);
			}
		}];
	}
	dispatch_group_notify(group, dispatch_get_main_queue(), ^{
		[MzmChapter updateWithChapters:mzmChapters];
		[self pullNeedCheckChaptersWithMZMBookid:mzmBookid];
	});
}

/// 在青果上请求审核状态,本地已有该章节,qingguostatus字段不为空
- (void)pullNeedCheckChaptersWithMZMBookid:(NSString *)mzmBookid {
	NSArray<NSNumber *> *needCheckSNs = [MzmChapter getNeedCheckSNWithBookid:mzmBookid];
	
	NSMutableArray<NSNumber *> *pageArr = [NSMutableArray array];
	for (NSNumber *tmp in needCheckSNs) {
		NSInteger sn = tmp.integerValue;
		NSInteger page = (sn - 1) / 30 + 1;
		NSNumber *pageNum = [NSNumber numberWithInteger:page];
		if (![pageArr containsObject:pageNum]) {
			[pageArr addObject:pageNum];
		}
	}
	
	NSMutableArray<MzmChapter *> *mzmChapters = [NSMutableArray array];
	//根据求得的页数请求章节
	dispatch_group_t group = dispatch_group_create();
	for (NSInteger i = 0; i < pageArr.count; i++) {
		dispatch_group_enter(group);
		NSInteger page = pageArr[i].integerValue;
		[self pullQGChaptersWithMZMBookid:mzmBookid page:page result:^(ChaptersResponseModel *chaptersResponseModel) {
			if (chaptersResponseModel) {
				NSArray<ChapterInfo *> *qgChapters = chaptersResponseModel.model.data;
				//根据sn找到对应的码字猫章节,更新审核状态
				for (NSInteger j = 0; j < needCheckSNs.count; j++) {
					NSNumber *snNum = needCheckSNs[j];
					NSInteger sn = snNum.integerValue;
					for (NSInteger k = 0; k < qgChapters.count; k++) {
						ChapterInfo *qgChapter = qgChapters[k];
						if (sn == qgChapter.sn) {
							NSArray<MzmChapter *> *tmp = [MzmChapter selectMZMChaptersWithBookid:mzmBookid sn:sn];
							for (MzmChapter *mzmChapter in tmp) {
								if ([mzmChapter updateWithQGChapter:qgChapter]) {
									[mzmChapters addObject:mzmChapter];
								}
							}
							break;
						}
					}
				}
			} else {
				
			}
			dispatch_group_leave(group);
		}];
	}
	dispatch_group_notify(group, dispatch_get_main_queue(), ^{
		[MzmChapter updateWithChapters:mzmChapters];
		[self uploadToSync];
		if (self.delegate && [self.delegate respondsToSelector:@selector(syncManager:syncChaptersWithResult:)]) {
			[self.delegate syncManager:[SyncManager shared] syncChaptersWithResult:YES];
		}
	});
}

- (void)uploadToSync {
	if ([[MzmChapter getNotSyncChapterJsonStringWithBookid:self.bookid] isNotBlank]) {//需同步
		
		NSDictionary *paras = @{
								@"account_id": [[NSUserDefaults standardUserDefaults] stringForKey:@"account_id"],
								@"request_ts": [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] * 1000],
								@"book_id": self.bookid,
								@"chapter_list": [MzmChapter getNotSyncChapterJsonStringWithBookid:self.bookid]
								};
		MZMRequest *chapterUpdateRequest = [[MZMRequest alloc] initWithType:URITypeMzmUpdateChapterList paras:paras];
		[chapterUpdateRequest.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
		[chapterUpdateRequest startWithSuccess:^(YBNetworkResponse * _Nonnull response) {
			MzmChapterUpdateResponse *res = [MzmChapterUpdateResponse yy_modelWithJSON:response.responseObject];
			if ([res.code isEqualToString:@"20000"]) {
				[MzmChapter updateTimestampWith:res.data];

			} else {

			}
		} failure:^(YBNetworkResponse * _Nonnull response) {

		}];
		
//		NSString *request_ts = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] * 1000];
//		NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.writingai.cn/v2/chapters/update_chapters_list?account_id=%@&book_id=%@&request_ts=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"account_id"],self.bookid,request_ts]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
//		[urlRequest setHTTPMethod:@"POST"];
//		[urlRequest setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
//
//		NSString *token = [NSString stringWithFormat:@"account_id=%@&book_id=%@&request_ts=%@%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"account_id"],self.bookid,request_ts,MZMMd5SaltKey];
//		[urlRequest setValue:[token md5String] forHTTPHeaderField:@"token"];
//
//		[urlRequest setValue:token forHTTPHeaderField:@"token"];
//		[urlRequest setHTTPBody:[[NSString stringWithFormat:@"chapter_list=%@",[MzmChapter getNotSyncChapterJsonStringWithBookid:self.bookid]] dataUsingEncoding:NSUTF8StringEncoding]];
//		NSURLSession *session = [NSURLSession sharedSession];
//		[[session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//			NSError *inerror;
//			NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&inerror];
//			NSLog(@"!!!%@",dic);
//		}] resume];
		
//		NSString *request_ts = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] * 1000];
//		AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//		NSDictionary *dict = @{
//							   @"account_id": [[NSUserDefaults standardUserDefaults] stringForKey:@"account_id"],
//							   @"request_ts": request_ts,
//							   @"book_id": self.bookid
//							   };
//
//		NSString *token = [NSString stringWithFormat:@"account_id=%@&book_id=%@&request_ts=%@%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"account_id"],self.bookid,request_ts,MZMMd5SaltKey];
//		[manager.requestSerializer setValue:[token md5String] forHTTPHeaderField:@"token"];
//
//		[manager POST:@"https://api.writingai.cn/v2/chapters/update_chapters_list" parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//			[formData appendPartWithFormData:[[MzmChapter getNotSyncChapterJsonStringWithBookid:self.bookid] dataUsingEncoding:NSUTF8StringEncoding] name:@"chapter_list"];
//		} progress:^(NSProgress * _Nonnull uploadProgress) {
//
//		} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
//		} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//
//		}];
	}
}

/// 获取青果章节的content字段
- (void)pullChapterContentWithChapterInfo:(ChapterInfo *)info result:(void(^)(NSString *content))result {

	NSDictionary *paras = @{
							@"token": [[NSUserDefaults standardUserDefaults] stringForKey:@"token"],
							@"id": info.chapterid
							};
	
	QGRequest *request = [[QGRequest alloc] initWithType:URITypeQgChapterContent paras:paras];
	[request startWithSuccess:^(YBNetworkResponse * _Nonnull response) {
		NSDictionary *dic = response.responseObject;
		if (((NSNumber *)dic[@"code"]).integerValue == 0) {
			ChapterInfo *output = [ChapterInfo yy_modelWithDictionary:[(NSDictionary *)response.responseObject objectForKey:@"model"]];
			result(output.content);
		} else {
			result(nil);
		}
	} failure:^(YBNetworkResponse * _Nonnull response) {
		result(nil);
	}];
}

/// 根据页数请求青果章节,一页30个sn，第一页index为1
- (void)pullQGChaptersWithMZMBookid:(NSString *)mzmBookid page:(NSInteger)page result:(void(^)(ChaptersResponseModel *chaptersResponseModel))result {
	
	NSString *qgBookid = [MzmBook selectBookWithWhere:@{@"_id": mzmBookid} orderBy:@"status"][0].qingguoid;
	NSDictionary *paras = @{
							@"token": [[NSUserDefaults standardUserDefaults] stringForKey:@"token"],
							@"id": qgBookid,
							@"cpage": [NSString stringWithFormat:@"%ld",page]
							};
	QGRequest *request = [[QGRequest alloc] initWithType:URITypeQgChapterList paras:paras];
	[request startWithSuccess:^(YBNetworkResponse * _Nonnull response) {
		ChaptersResponseModel *res = [ChaptersResponseModel yy_modelWithJSON:response.responseObject];
		if (res.code == 0) {
			result(res);
		} else {
			result(nil);
		}
	} failure:^(YBNetworkResponse * _Nonnull response) {
		result(nil);
	}];
}

#pragma mark - YBResponseDelegate -

- (void)request:(__kindof YBBaseRequest *)request successWithResponse:(YBNetworkResponse *)response {
	if (request == self.bookPullRequest) {
		MzmBooksResponse *res = [MzmBooksResponse yy_modelWithJSON:response.responseObject];
		if ([res.code isEqualToString:@"20000"]) {
			[MzmBook updateWithBooks:res.books];
			
			if ([[MzmBook getNotSyncBookJsonString] isNotBlank]) {//需同步
				NSDictionary *paras = @{
										@"account_id": [[NSUserDefaults standardUserDefaults] stringForKey:@"account_id"],
										@"request_ts": [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] * 1000],
										@"book_list": [MzmBook getNotSyncBookJsonString]
										};
				self.bookUpdateRequest = [[MZMRequest alloc] initWithType:URITypeMzmUpdateBookList paras:paras delegate:self];
				[self.bookUpdateRequest.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
				[self.bookUpdateRequest start];
			} else {
				if (self.delegate && [self.delegate respondsToSelector:@selector(syncManager:syncBooksWithResult:)]) {
					[self.delegate syncManager:[SyncManager shared] syncBooksWithResult:YES];
				}
			}
			
		} else {
			if (self.delegate && [self.delegate respondsToSelector:@selector(syncManager:syncBooksWithResult:)]) {
				[self.delegate syncManager:[SyncManager shared] syncBooksWithResult:NO];
			}
		}
	}
	if (request == self.bookUpdateRequest) {
		MzmBookUpdateResponse *res = [MzmBookUpdateResponse yy_modelWithJSON:response.responseObject];
		if ([res.code isEqualToString:@"20000"]) {
			[MzmBook updateTimestampWith:res.data];
			if (self.delegate && [self.delegate respondsToSelector:@selector(syncManager:syncBooksWithResult:)]) {
				[self.delegate syncManager:[SyncManager shared] syncBooksWithResult:YES];
			}
		} else {
			if (self.delegate && [self.delegate respondsToSelector:@selector(syncManager:syncBooksWithResult:)]) {
				[self.delegate syncManager:[SyncManager shared] syncBooksWithResult:NO];
			}
		}
	}
	
}

- (void)request:(__kindof YBBaseRequest *)request failureWithResponse:(YBNetworkResponse *)response {
	if (request == self.bookPullRequest) {
		if (self.delegate && [self.delegate respondsToSelector:@selector(syncManager:syncBooksWithResult:)]) {
			[self.delegate syncManager:[SyncManager shared] syncBooksWithResult:NO];
		}
	}
	if (request == self.bookUpdateRequest) {
		if (self.delegate && [self.delegate respondsToSelector:@selector(syncManager:syncBooksWithResult:)]) {
			[self.delegate syncManager:[SyncManager shared] syncBooksWithResult:NO];
		}
	}
}

@end
