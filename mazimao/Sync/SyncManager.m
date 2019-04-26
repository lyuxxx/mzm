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
		if (self.delegate && [self.delegate respondsToSelector:@selector(syncManager:syncChaptersWithResult:)]) {
			[self.delegate syncManager:[SyncManager shared] syncChaptersWithResult:YES];
		}
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
						//todo:获取章节状态
					} else {
						
					}
				} failure:^(YBNetworkResponse * _Nonnull response) {
					
				}];
				
				
				
			}
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
#warning todo:insert
			[self pullNewestChaptersWithMZMBookid:mzmBookid];
		} else {
			
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
	
	//根据求得的页数请求章节
	for (NSInteger i = 0; i < pageArr.count; i++) {
		NSInteger page = pageArr[i].integerValue;
		[self pullQGChaptersWithMZMBookid:mzmBookid page:page result:^(ChaptersResponseModel *chaptersResponseModel) {
			if (chaptersResponseModel) {
				NSArray<ChapterInfo *> *qgChapters = chaptersResponseModel.model.data;
				for (ChapterInfo *info in qgChapters) {
					[self pullChapterContentWithChapterInfo:info result:^(NSString *content) {
						info.content = content;
					}];
				}
#warning todo:insert
			} else {
				
			}
		}];
	}
	
}

///在青果上请求审核状态,本地已有该章节
- (void)pullNeedCheckChaptersWithMZMBookid:(NSString *)mzmBookid {
	NSArray *needCheckSNs = [MzmChapter getNeedCheckSNWithBookid:mzmBookid];
	
	NSMutableArray<NSNumber *> *pageArr = [NSMutableArray array];
	for (NSNumber *tmp in needCheckSNs) {
		NSInteger sn = tmp.integerValue;
		NSInteger page = (sn - 1) / 30 + 1;
		NSNumber *pageNum = [NSNumber numberWithInteger:page];
		if (![pageArr containsObject:pageNum]) {
			[pageArr addObject:pageNum];
		}
	}
	
	//根据求得的页数请求章节
	for (NSInteger i = 0; i < pageArr.count; i++) {
		NSInteger page = pageArr[i].integerValue;
		[self pullQGChaptersWithMZMBookid:mzmBookid page:page result:^(ChaptersResponseModel *chaptersResponseModel) {
			if (chaptersResponseModel) {
				NSArray<ChapterInfo *> *qgChapters = chaptersResponseModel.model.data;
#warning todo:update
			} else {
				
			}
		}];
	}
}

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
