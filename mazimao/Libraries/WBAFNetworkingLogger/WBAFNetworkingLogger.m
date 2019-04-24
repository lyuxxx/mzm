//
//  WBAFNetworkingLogger.m
//  WBAFNetworkingLogger
//
//  Created by brownfeng on 16/9/26.
//  Copyright © 2016年 brownfeng. All rights reserved.
//

#import "WBAFNetworkingLogger.h"
#import "AFNetworking.h"
#import <objc/runtime.h>
static NSError * WBNetworkErrorFromNotification(NSNotification *notification) {
    NSError *error = nil;
    if ([[notification object] isKindOfClass:[NSURLSessionTask class]]) {
        error = [(NSURLSessionTask *)[notification object] error];
        if (!error) {
            error = notification.userInfo[AFNetworkingTaskDidCompleteErrorKey];
        }
    }
    return error;
}

@interface WBAFNetworkingLogger()

@end

@implementation WBAFNetworkingLogger
+ (instancetype)sharedLogger {
    static WBAFNetworkingLogger *_sharedLogger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedLogger = [[self alloc] init];
    });
    
    return _sharedLogger;
}

- (id)init {
    if (self = [super init]){
        self.level = WBLoggerLevelInfo;
    }
    return self;
}

- (void)dealloc {
    [self stopLogging];
}

- (void)startLogging {
    [self stopLogging];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRequestDidStart:) name:AFNetworkingTaskDidResumeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRequestDidFinish:) name:AFNetworkingTaskDidCompleteNotification object:nil];
}

- (void)stopLogging {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma -mark notification
static void * WBNetworkRequestStartDate = &WBNetworkRequestStartDate;
- (void)networkRequestDidStart:(NSNotification *)notification {
    NSURLSessionTask *task = notification.object;
    NSURLRequest *request = task.currentRequest;
    if (!request) {
        return;
    }
    
    objc_setAssociatedObject(notification.object, WBNetworkRequestStartDate, [NSDate date], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSString *body = nil;
    if ([request HTTPBody]) {
        body = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
    } else {
        if (task.originalRequest.HTTPBody) {
            body = [[NSString alloc] initWithData:task.originalRequest.HTTPBody encoding:NSUTF8StringEncoding];
        }
    }
    
    switch (self.level) {
        case WBLoggerLevelDebug:
            NSLog(@"%@ '%@': %@ %@", [request HTTPMethod], [[request URL] absoluteString], [request allHTTPHeaderFields], body);
            break;
        case WBLoggerLevelInfo:
            NSLog(@"%@ '%@'", [request HTTPMethod], [[request URL] absoluteString]);
            break;
        default:
            break;
    }
}

-(void)networkRequestDidFinish:(NSNotification *)notification{
    NSURLSessionTask *task = notification.object;
    NSURLRequest *request = task.currentRequest;
    NSURLResponse *response = task.response;
    NSError *error = WBNetworkErrorFromNotification(notification);
    if (!request && !response) {
        return;
    }
    
    NSUInteger responseStatusCode = 0;
    NSDictionary *responseHeaderFields = nil;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        responseStatusCode = (NSUInteger)[(NSHTTPURLResponse *)response statusCode];
        responseHeaderFields = [(NSHTTPURLResponse *)response allHeaderFields];
    }
    
    id responseObject = nil;
    if (notification.userInfo) {
        responseObject = notification.userInfo[AFNetworkingTaskDidCompleteSerializedResponseKey];
        if ([responseObject isKindOfClass:[NSData class]]) {
            responseObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            //data->dic
        }
    }
    
    NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:objc_getAssociatedObject(notification.object, WBNetworkRequestStartDate)];
    
    if (error) {
        switch (self.level) {
            case WBLoggerLevelDebug:
            case WBLoggerLevelInfo:
            case WBLoggerLevelWarn:
            case WBLoggerLevelError:
                NSLog(@"[Error] %@ '%@' (%ld) [%.04f s]: %@", [request HTTPMethod], [[response URL] absoluteString], (long)responseStatusCode, elapsedTime, error);
            default:
                break;
        }
    } else {
        switch (self.level) {
            case WBLoggerLevelDebug:
                NSLog(@"%ld '%@' [%.04f s]: %@ %@", (long)responseStatusCode, [[response URL] absoluteString], elapsedTime, responseHeaderFields, responseObject);                break;
            case WBLoggerLevelInfo:
                NSLog(@"%ld '%@' [%.04f s]", (long)responseStatusCode, [[response URL] absoluteString], elapsedTime);
                break;
            default:
                break;
        }
    }
}

@end
