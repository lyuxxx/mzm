//
//  LocalBook.m
//  mazimao
//
//  Created by wuhan006 on 2019/4/24.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "LocalBook.h"

@implementation LocalBook

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
	return @"LocalBook";
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

@implementation LocalChapter


@end
