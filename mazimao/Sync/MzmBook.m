//
//  MzmBook.m
//  mazimao
//
//  Created by wuhan006 on 2019/4/24.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "MzmBook.h"

@implementation MzmBook

+ (LKDBHelper *)getUsingLKDBHelper {
	static LKDBHelper *db;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSString *dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"localBook/localBook.db"];
		db = [[LKDBHelper alloc] initWithDBPath:dbPath];
		[db setKey:@"localBook"];
	});
	return db;
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

+ (void)dropAllHistory {
	[LKDBHelper clearTableData:[self class]];
}

@end

@implementation MzmChapter


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
