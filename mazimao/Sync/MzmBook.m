//
//  MzmBook.m
//  mazimao
//
//  Created by wuhan006 on 2019/4/24.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "MzmBook.h"
#import "BSONIdGenerator.h"

@implementation MzmBook

+ (LKDBHelper *)getUsingLKDBHelper {
	static LKDBHelper *db;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSString *dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"MZMBook/MZMBook.db"];
		db = [[LKDBHelper alloc] initWithDBPath:dbPath];
		[db setKey:@"MZMBook"];
	});
	return db;
}

+ (NSString *)getPrimaryKey {
	return @"_id";
}

+ (NSString *)getTableName {
	return @"MzmBook";
}

+ (BOOL)isContainParent {
	return YES;
}

+ (BOOL)isContainSelf {
	return YES;
}

+ (BOOL)dbWillInsert:(NSObject *)entity {
	NSLog(@"will insert:%@",NSStringFromClass(self));
	return YES;
}

+ (void)dbDidInserted:(NSObject *)entity result:(BOOL)result {
	NSLog(@"did insert:%@",NSStringFromClass(self));
}

+ (NSString *)getNewestSupdatets {
	MzmBook *book = [self selectNewestSupdatetsBook];
	if (book) {
		return [NSString stringWithFormat:@"%.0f",book.supdatets];
	}
	return @"1";
}

+ (void)updateWithBooks:(NSArray<MzmBook *> *)books {
	for (MzmBook *book in books) {
		MzmBook *tmp = [MzmBook selectBookWithId:book._id];
		if (tmp) {//存在
			if ([tmp.status isEqualToString:@""]) {//更新
				[[self getUsingLKDBHelper] updateToDB:book where:nil];
			} else if ([tmp.status isEqualToString:@"del"] || [tmp.status isEqualToString:@"delforever"]) {//删除
				[[self getUsingLKDBHelper] deleteToDB:book];
			}
		} else {//不存在，添加
			[[self getUsingLKDBHelper] insertWhenNotExists:book];
		}
	}
}

+ (MzmBook *)selectBookWithId:(NSString *)bookid {
	return [[self getUsingLKDBHelper] searchSingle:[MzmBook class] where:[NSString stringWithFormat:@"_id = %@",bookid] orderBy:nil];
}

+ (MzmBook *)selectNewestSupdatetsBook {
	return [[self getUsingLKDBHelper] searchSingle:[MzmBook class] where:nil orderBy:@"supdatets desc"];
}

+ (NSString *)getNotSyncBookJsonString {
	
	NSArray *books = [[self getUsingLKDBHelper] search:[MzmBook class] where:[NSString stringWithFormat:@"async = 0"] orderBy:nil offset:0 count:0];
	if (!books) {
		return nil;
	}
	NSData *data = [books yy_modelToJSONData];
	
	return [[data zlibDeflate] base64EncodedString];
}

+ (void)updateTimestampWith:(MzmBookUpdateResult *)result {
	for (NSString *tmpId in result.update_ids) {
		MzmBook *book = [self selectBookWithId:tmpId];
		if (book) {
			book.supdatets = result.update_ts;
			book.async = 1;
			[[self getUsingLKDBHelper] updateToDB:book where:nil];
		}
	}
}

+ (NSArray<MzmBook *> *)selectAllBook {
	return [[self getUsingLKDBHelper] search:[MzmBook class] where:nil orderBy:nil offset:0 count:0];
}

+ (NSMutableArray<MzmBook *> *)selectBookWithWhere:(id)where orderBy:(NSString *)orderBy {
	NSMutableArray *arr = [[self getUsingLKDBHelper] search:[MzmBook class] where:where orderBy:orderBy offset:0 count:0];
	return arr;
}

+ (void)dropAllBook {
	[LKDBHelper clearTableData:[MzmBook class]];
}

@end

@implementation MzmChapter

- (instancetype)initWithQGChapter:(ChapterInfo *)qgchapter {
	self = [super init];
	if (self) {
		self._id = [BSONIdGenerator generate];
		self.qingguoid = qgchapter.chapterid;
		self.name = qgchapter.name;
		self.sn = qgchapter.sn;
		self.txt = qgchapter.content;
		self.shelfStatus = qgchapter.status;
		self.createts = qgchapter.create_time;
		self.updatets = qgchapter.update_time;
		self.wordscount = qgchapter.word_count;
		self.qingguostatus = qgchapter.checkStatus;
		self.checkMessage = qgchapter.checkMessage;
		self.authorTalk = qgchapter.authorTalk;
		self.async = 0;
	}
	return self;
}

- (BOOL)updateWithQGChapter:(ChapterInfo *)qgchapter {
	if ([self.qingguoid isNotBlank]) {
		if ([self.qingguoid isEqualToString:qgchapter.chapterid]) {
			self.name = qgchapter.name;
			self.sn = qgchapter.sn;
			self.txt = qgchapter.content;
			self.shelfStatus = qgchapter.status;
			self.createts = qgchapter.create_time;
			self.updatets = qgchapter.update_time;
			self.wordscount = qgchapter.word_count;
			self.qingguostatus = qgchapter.checkStatus;
			self.checkMessage = qgchapter.checkMessage;
			self.authorTalk = qgchapter.authorTalk;
			self.async = 0;
			return YES;
		}
	} else if ([self.name isEqualToString:qgchapter.name]) {
		self.qingguoid = qgchapter.chapterid;
		self.sn = qgchapter.sn;
		self.txt = qgchapter.content;
		self.shelfStatus = qgchapter.status;
		self.createts = qgchapter.create_time;
		self.updatets = qgchapter.update_time;
		self.wordscount = qgchapter.word_count;
		self.qingguostatus = qgchapter.checkStatus;
		self.checkMessage = qgchapter.checkMessage;
		self.authorTalk = qgchapter.authorTalk;
		self.async = 0;
		return YES;
	}
	return NO;
}

+ (LKDBHelper *)getUsingLKDBHelper {
	static LKDBHelper *db;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSString *dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"MZMChapter/MZMChapter.db"];
		db = [[LKDBHelper alloc] initWithDBPath:dbPath];
		[db setKey:@"MZMChapter"];
	});
	return db;
}

+ (NSString *)getPrimaryKey {
	return @"_id";
}

+ (NSString *)getTableName {
	return @"MzmChapter";
}

+ (BOOL)isContainParent {
	return YES;
}

+ (BOOL)isContainSelf {
	return YES;
}

+ (BOOL)dbWillInsert:(NSObject *)entity {
	NSLog(@"will insert:%@",NSStringFromClass(self));
	return YES;
}

+ (void)dbDidInserted:(NSObject *)entity result:(BOOL)result {
	NSLog(@"did insert:%@",NSStringFromClass(self));
}

+ (NSString *)getNewestSupdatetsWithBookid:(NSString *)bookid {
	MzmChapter *chapter = [self selectNewestSupdatetsChapterWithBookid:bookid];
	if (chapter) {
		return [NSString stringWithFormat:@"%.0f",chapter.supdatets];
	}
	return @"1";
}

+ (void)updateWithChapters:(NSArray<MzmChapter *> *)chapters {
	if (!chapters || chapters.count == 0) {
		return;
	}
	for (MzmChapter *chapter in chapters) {
		MzmChapter *tmp = [MzmChapter selectChapterWithId:chapter._id];
		if (tmp) {//存在
			if ([tmp.status isEqualToString:@""]) {//更新
				[[self getUsingLKDBHelper] updateToDB:chapter where:nil];
			} else if ([tmp.status isEqualToString:@"del"] || [tmp.status isEqualToString:@"delforever"]) {//删除
				[[self getUsingLKDBHelper] deleteToDB:chapter];
			}
		} else {//不存在，添加
			[[self getUsingLKDBHelper] insertWhenNotExists:chapter];
		}
	}
}

+ (MzmChapter *)selectChapterWithId:(NSString *)chapterid {
	return [[self getUsingLKDBHelper] searchSingle:[MzmChapter class] where:@{@"_id":chapterid} orderBy:nil];
}

+ (MzmChapter *)selectNewestSupdatetsChapterWithBookid:(NSString *)bookid {
	return [[self getUsingLKDBHelper] searchSingle:[MzmChapter class] where:@{@"bookid":bookid} orderBy:@"supdatets desc"];
}

+ (NSString *)getNotSyncChapterJsonStringWithBookid:(NSString *)bookid {
	NSArray *chapters = [[self getUsingLKDBHelper] search:[MzmChapter class] where:@{@"bookid":bookid, @"async": @0} orderBy:nil offset:0 count:0];
	if (!chapters) {
		return nil;
	}
	NSData *data = [chapters yy_modelToJSONData];
	
	return [[data zlibDeflate] base64EncodedString];
}

+ (void)updateTimestampWith:(MzmChapterUpdateResult *)result {
	for (NSString *tmpId in result.update_ids) {
		MzmChapter *chapter = [self selectChapterWithId:tmpId];
		if (chapter) {
			chapter.supdatets = result.update_ts;
			chapter.async = 1;
			[[self getUsingLKDBHelper] updateToDB:chapter where:nil];
		}
	}
}

+ (NSArray<MzmChapter *> *)selectChaptersWithBookid:(NSString *)bookid status:(NSString *)status {
	NSArray *arr = [[self getUsingLKDBHelper] search:[MzmChapter class] withSQL:[self getSqlWithBookid:bookid status:status pageSize:0 pageIndex:0 keywords:nil],bookid];
	NSLog(@"select bookid:%@ count:%ld",bookid,arr.count);
	return [[arr reverseObjectEnumerator] allObjects];
}


+ (NSMutableArray *)selectChapterWithWhere:(id)where orderBy:(NSString *)orderBy {
	NSMutableArray *arr = [[self getUsingLKDBHelper] search:[MzmChapter class] where:where orderBy:orderBy offset:0 count:0];
	return arr;
}

+ (void)dropAllChapterWithBookid:(NSString *)bookid {
	[[self getUsingLKDBHelper] deleteWithClass:[MzmChapter class] where:@{@"bookid":bookid}];
}

+ (NSString *)getSqlWithBookid:(NSString *)bookid status:(NSString *)status pageSize:(NSInteger)pageSize pageIndex:(NSInteger)pageIndex keywords:(NSString *)keywords {
//	NSMutableString *sql = [[NSMutableString alloc] initWithString:@"select _id, qingguoid, qingguostatus, name, wordscount, createts, updatets, status, sn, box, (CASE WHEN qingguoid is null or qingguoid=\"\" THEN 1 ELSE 0 END) as ispublish from @t where bookid = ? "];
	NSMutableString *sql = [[NSMutableString alloc] initWithString:@"select * , (CASE WHEN qingguoid is null or qingguoid=\"\" THEN 1 ELSE 0 END) as ispublish from @t where bookid = ? "];
	if ([status isEqualToString:@"del"]) {
		[sql appendString:@"and status = \"del\" "];
	} else {
		[sql appendString:@"and status = \"\" "];
	}
	if (keywords) {
		[sql appendString:[NSString stringWithFormat:@"and txt like \"%%%@%%\" ",keywords]];
	}
	[sql appendString:@"order by ispublish, sn, createts "];
	
	if (pageSize && pageIndex) {
		pageIndex = (pageIndex - 1) * pageSize;
		[sql appendString:[NSString stringWithFormat:@"limit %ld, %ld ",pageIndex,pageSize]];
	}
	NSLog(@"sqlString:%@",sql);
	return sql;
}

+ (NSInteger)getBiggestSNWithBookid:(NSString *)bookid {
	MzmChapter *chapter = [[self getUsingLKDBHelper] searchSingle:[MzmChapter class] where:@{@"bookid":bookid} orderBy:@"sn desc"];
	return chapter.sn;
}

+ (NSArray<NSNumber *> *)getDiscontinuousSNWithBookid:(NSString *)bookid {
	NSArray<MzmChapter *> *allChapters = [[self getUsingLKDBHelper] search:[MzmChapter class] where:@{@"bookid":bookid} orderBy:@"sn" offset:0 count:0];
	NSMutableArray *output = [NSMutableArray array];
	for (NSInteger i = 1; i <= [self getBiggestSNWithBookid:bookid]; i++) {
		BOOL exist = NO;
		for (NSInteger j = 0; j < allChapters.count; j++) {
			NSInteger existSN = allChapters[j].sn;
			if (i == existSN) {
				exist = YES;
				break;
			}
		}
		if (!exist) {
			[output addObject:[NSNumber numberWithInteger:i]];
		} else {
			continue;
		}
	}
	return output;
}

+ (NSArray<NSNumber *> *)getNeedCheckSNWithBookid:(NSString *)bookid {
	NSArray<MzmChapter *> *chapters = [[self getUsingLKDBHelper] search:[MzmChapter class] where:@{@"qingguostatus": @[@"notcheck",@"notpass",@"pass"],@"bookid":bookid} orderBy:@"sn" offset:0 count:0];
	NSMutableArray *output = [NSMutableArray array];
	for (MzmChapter *chapter in chapters) {
		[output addObject:[NSNumber numberWithInteger:chapter.sn]];
	}
	return output;
}

+ (NSArray<MzmChapter *> *)selectMZMChaptersWithBookid:(NSString *)bookid sn:(NSInteger)sn {
	NSArray *output = nil;
	output = [[self getUsingLKDBHelper] search:[self class] where:@{@"bookid": bookid, @"sn": [NSNumber numberWithInteger:sn]} orderBy:nil offset:0 count:0];
	return output;
}

@end

@implementation MzmBooksResponse

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
	if ([dic[@"code"] isEqualToString:@"20000"]) {
		NSData *data = [[NSData alloc] initWithBase64EncodedString:dic[@"data"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
		NSString *jsonString = [[NSString alloc] initWithData:[data zlibInflate] encoding:NSUTF8StringEncoding];
		_books = [NSArray yy_modelArrayWithClass:[MzmBook class] json:jsonString];
	}
	return YES;
}

@end

@implementation MzmBookUpdateResult

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
	return @{
			 @"update_ids": [NSString class]
			 };
}

@end

@implementation MzmBookUpdateResponse



@end

@implementation MzmChaptersPage

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
	NSData *data = [[NSData alloc] initWithBase64EncodedString:dic[@"chapterInfo"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
	NSString *jsonString = [[NSString alloc] initWithData:[data zlibInflate] encoding:NSUTF8StringEncoding];
	_chapters = [NSArray yy_modelArrayWithClass:[MzmChapter class] json:jsonString];
	return YES;
}

@end

@implementation MzmChaptersResponse


@end

@implementation MzmChapterUpdateResult

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
	return @{
			 @"update_ids": [NSString class]
			 };
}

@end

@implementation MzmChapterUpdateResponse



@end
