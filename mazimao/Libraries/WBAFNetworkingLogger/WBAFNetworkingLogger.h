//
//  WBAFNetworkingLogger.h
//  WBAFNetworkingLogger
//
//  Created by brownfeng on 16/9/26.
//  Copyright © 2016年 brownfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WBLoggerLevel) {
    WBLoggerLevelOff,
    WBLoggerLevelDebug,
    WBLoggerLevelInfo,
    WBLoggerLevelWarn,
    WBLoggerLevelError,
    WBLoggerLevelFatal = WBLoggerLevelOff,
};

@interface WBAFNetworkingLogger : NSObject
/**
 The level of logging detail. See "Logging Levels" for possible values. `WBLoggerLevelInfo` by default.
 */
@property (nonatomic, assign) WBLoggerLevel level;
/**
 Returns the shared logger instance.
 */
+ (instancetype)sharedLogger;

/**
 Start logging requests and responses.
 */
- (void)startLogging;

/**
 Stop logging requests and responses.
 */
- (void)stopLogging;
@end
