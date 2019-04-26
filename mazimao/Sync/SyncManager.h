//
//  SyncManager.h
//  mazimao
//
//  Created by wuhan006 on 2019/4/25.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MzmBook.h"
#import "MZMRequest.h"
#import "QGRequest.h"

NS_ASSUME_NONNULL_BEGIN

@class SyncManager;

@protocol SyncManagerDelegate <NSObject>

@optional
- (void)syncManager:(SyncManager *)manager syncBooksWithResult:(BOOL)result;
- (void)syncManager:(SyncManager *)manager syncChaptersWithResult:(BOOL)result;

@end

@interface SyncManager : NSObject

@property (nonatomic, weak) id<SyncManagerDelegate> delegate;

+ (SyncManager *)shared;

- (void)syncBooks;
- (void)syncChaptersWithBookid:(NSString *)bookid;

@end

NS_ASSUME_NONNULL_END
