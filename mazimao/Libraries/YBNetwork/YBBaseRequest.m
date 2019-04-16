//
//  YBBaseRequest.m
//  YBNetwork<https://github.com/indulgeIn/YBNetwork>
//
//  Created by 杨波 on 2019/4/3.
//  Copyright © 2019 杨波. All rights reserved.
//

#import "YBBaseRequest.h"
#import "YBBaseRequest+Internal.h"
#import "YBNetworkManager.h"
#import "YBNetworkCache+Internal.h"
#import <pthread/pthread.h>

#define YBN_IDECORD_LOCK(...) \
pthread_mutex_lock(&self->_lock); \
__VA_ARGS__ \
pthread_mutex_unlock(&self->_lock);

@interface YBBaseRequest ()
@property (nonatomic, copy, nullable) YBRequestProgressBlock uploadProgress;
@property (nonatomic, copy, nullable) YBRequestProgressBlock downloadProgress;
@property (nonatomic, copy, nullable) YBRequestCacheBlock cacheBlock;
@property (nonatomic, copy, nullable) YBRequestSuccessBlock successBlock;
@property (nonatomic, copy, nullable) YBRequestFailureBlock failureBlock;
@property (nonatomic, strong) YBNetworkCache *cacheHandler;
/// 记录网络任务标识容器
@property (nonatomic, strong) NSMutableSet<NSNumber *> *taskIDRecord;
@end

@implementation YBBaseRequest {
    pthread_mutex_t _lock;
}

#pragma mark - life cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        pthread_mutex_init(&_lock, NULL);
        self.releaseStrategy = YBNetworkReleaseStrategyHoldRequest;
        self.repeatStrategy = YBNetworkRepeatStrategyAllAllowed;
        self.taskIDRecord = [NSMutableSet set];
    }
    return self;
}

- (void)dealloc {
    pthread_mutex_destroy(&_lock);
    if (self.releaseStrategy == YBNetworkReleaseStrategyWhenRequestDealloc) {
        [self cancel];
    }
}

#pragma mark - public

- (void)startWithSuccess:(YBRequestSuccessBlock)success failure:(YBRequestFailureBlock)failure {
    [self startWithUploadProgress:nil downloadProgress:nil cache:nil success:success failure:failure];
}

- (void)startWithCache:(YBRequestCacheBlock)cache success:(YBRequestSuccessBlock)success failure:(YBRequestFailureBlock)failure {
    [self startWithUploadProgress:nil downloadProgress:nil cache:cache success:success failure:failure];
}

- (void)startWithUploadProgress:(YBRequestProgressBlock)uploadProgress downloadProgress:(YBRequestProgressBlock)downloadProgress cache:(YBRequestCacheBlock)cache success:(YBRequestSuccessBlock)success failure:(YBRequestFailureBlock)failure {
    self.uploadProgress = uploadProgress;
    self.downloadProgress = downloadProgress;
    self.cacheBlock = cache;
    self.successBlock = success;
    self.failureBlock = failure;
    [self start];
}

- (void)start {
    if (self.isExecuting) {
        switch (self.repeatStrategy) {
            case YBNetworkRepeatStrategyCancelNewest: return;
            case YBNetworkRepeatStrategyCancelOldest: {
                [self cancel];
            }
                break;
            default: break;
        }
    }
    
    NSString *cacheKey = [self requestCacheKey];

    if (self.cacheHandler.readMode == YBNetworkCacheReadModeNone) {
        [self startWithCacheKey:cacheKey];
        return;
    }
    
    [self.cacheHandler objectForKey:cacheKey withBlock:^(NSString * _Nonnull key, id<NSCoding>  _Nonnull object) {
        if (object) { //缓存命中
            YBNetworkResponse *response = [YBNetworkResponse responseWithSessionTask:nil responseObject:object error:nil];
            [self requestSuccessWithResponse:response cacheKey:cacheKey fromCache:YES];
        }
        
        BOOL needRequestNetwork = !object || self.cacheHandler.readMode == YBNetworkCacheReadModeAlsoNetwork;
        if (needRequestNetwork) {
            [self startWithCacheKey:cacheKey];
        } else {
            [self clearRequestBlocks];
        }
    }];
}

- (void)cancel {
    [self clearRequestBlocks];
    [[YBNetworkManager sharedManager] cancelNetworkingWithSet:self.taskIDRecord];
    YBN_IDECORD_LOCK([self.taskIDRecord removeAllObjects];)
}

- (BOOL)isExecuting {
    YBN_IDECORD_LOCK(BOOL isExecuting = self.taskIDRecord.count > 0;)
    return isExecuting;
}

#pragma mark - request

- (void)startWithCacheKey:(NSString *)cacheKey {
    __block NSNumber *taskID = nil;
    if (self.releaseStrategy == YBNetworkReleaseStrategyHoldRequest) {
        taskID = [[YBNetworkManager sharedManager] startNetworkingWithRequest:self uploadProgress:^(NSProgress * _Nonnull progress) {
            [self requestUploadProgress:progress];
        } downloadProgress:^(NSProgress * _Nonnull progress) {
            [self requestDownloadProgress:progress];
        } completion:^(YBNetworkResponse * _Nonnull response) {
            YBN_IDECORD_LOCK([self.taskIDRecord removeObject:taskID];);
            [self requestCompletionWithResponse:response cacheKey:cacheKey fromCache:NO];
        }];
    } else {
        __weak typeof(self) weakSelf = self;
        taskID = [[YBNetworkManager sharedManager] startNetworkingWithRequest:weakSelf uploadProgress:^(NSProgress * _Nonnull progress) {
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            [self requestUploadProgress:progress];
        } downloadProgress:^(NSProgress * _Nonnull progress) {
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            [self requestDownloadProgress:progress];
        } completion:^(YBNetworkResponse * _Nonnull response) {
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            YBN_IDECORD_LOCK([self.taskIDRecord removeObject:taskID];);
            [self requestCompletionWithResponse:response cacheKey:cacheKey fromCache:NO];
        }];
    }
    if (taskID) {
        YBN_IDECORD_LOCK([self.taskIDRecord addObject:taskID];)
    }
}

#pragma mark - response

- (void)requestUploadProgress:(NSProgress *)progress {
    YBNETWORK_MAIN_QUEUE_ASYNC(^{
        if ([self.delegate respondsToSelector:@selector(request:uploadProgress:)]) {
            [self.delegate request:self uploadProgress:progress];
        }
        if (self.uploadProgress) {
            self.uploadProgress(progress);
        }
    })
}

- (void)requestDownloadProgress:(NSProgress *)progress {
    YBNETWORK_MAIN_QUEUE_ASYNC(^{
        if ([self.delegate respondsToSelector:@selector(request:downloadProgress:)]) {
            [self.delegate request:self downloadProgress:progress];
        }
        if (self.downloadProgress) {
            self.downloadProgress(progress);
        }
    })
}

- (void)requestCompletionWithResponse:(YBNetworkResponse *)response cacheKey:(NSString *)cacheKey fromCache:(BOOL)fromCache {
    if (response.error) {
        [self requestFailureWithResponse:response];
    } else {
        [self requestSuccessWithResponse:response cacheKey:cacheKey fromCache:NO];
    }
}

- (void)requestSuccessWithResponse:(YBNetworkResponse *)response cacheKey:(NSString *)cacheKey fromCache:(BOOL)fromCache {
    
    BOOL shouldCache = !self.cacheHandler.shouldCacheBlock || self.cacheHandler.shouldCacheBlock(response);
    BOOL isSendFile = self.requestConstructingBody || self.downloadPath.length > 0;
    if (!fromCache && !isSendFile && shouldCache) {
        [self.cacheHandler setObject:response.responseObject forKey:cacheKey];
    }
    
    if ([self respondsToSelector:@selector(yb_preprocessSuccessInChildThreadWithResponse:)]) {
        [self yb_preprocessSuccessInChildThreadWithResponse:response];
    }
    
    YBNETWORK_MAIN_QUEUE_ASYNC(^{
        if ([self respondsToSelector:@selector(yb_preprocessSuccessInMainThreadWithResponse:)]) {
            [self yb_preprocessSuccessInMainThreadWithResponse:response];
        }
        
        if (fromCache) {
            if ([self.delegate respondsToSelector:@selector(request:cacheWithResponse:)]) {
                [self.delegate request:self cacheWithResponse:response];
            }
            if (self.cacheBlock) {
                self.cacheBlock(response);
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(request:successWithResponse:)]) {
                [self.delegate request:self successWithResponse:response];
            }
            if (self.successBlock) {
                self.successBlock(response);
            }
            [self clearRequestBlocks];
        }
    })
}

- (void)requestFailureWithResponse:(YBNetworkResponse *)response {
    if ([self respondsToSelector:@selector(yb_preprocessFailureInChildThreadWithResponse:)]) {
        [self yb_preprocessFailureInChildThreadWithResponse:response];
    }
    
    YBNETWORK_MAIN_QUEUE_ASYNC(^{
        if ([self respondsToSelector:@selector(yb_preprocessFailureInMainThreadWithResponse:)]) {
            [self yb_preprocessFailureInMainThreadWithResponse:response];
        }
        
        if ([self.delegate respondsToSelector:@selector(request:failureWithResponse:)]) {
            [self.delegate request:self failureWithResponse:response];
        }
        if (self.failureBlock) {
            self.failureBlock(response);
        }
        [self clearRequestBlocks];
    })
}

#pragma mark - private

- (void)clearRequestBlocks {
    self.uploadProgress = nil;
    self.downloadProgress = nil;
    self.cacheBlock = nil;
    self.successBlock = nil;
    self.failureBlock = nil;
}

- (NSString *)requestIdentifier {
    NSString *identifier = [NSString stringWithFormat:@"%@%@%@", [self requestMethodString], [self requestURLString], [self stringFromParameter:self.requestParameter]];
    return identifier;
}

- (NSString *)requestCacheKey {
    NSString *cacheKey = [NSString stringWithFormat:@"%@%@", self.cacheHandler.extraCacheKey, [self requestIdentifier]];
    if (self.cacheHandler.customCacheKeyBlock) {
        cacheKey = self.cacheHandler.customCacheKeyBlock(cacheKey);
    }
    return cacheKey;
}

- (NSString *)stringFromParameter:(NSDictionary *)parameter {
    NSMutableString *string = [NSMutableString string];
    NSArray *allKeys = [parameter.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [[NSString stringWithFormat:@"%@", obj1] compare:[NSString stringWithFormat:@"%@", obj2] options:NSLiteralSearch];
    }];
    for (id key in allKeys) {
        [string appendString:[NSString stringWithFormat:@"%@%@=%@", string.length > 0 ? @"&" : @"?", key, parameter[key]]];
    }
    return string;
}

- (NSString *)requestMethodString {
    switch (self.requestMethod) {
        case YBRequestMethodGET: return @"GET";
        case YBRequestMethodPOST: return @"POST";
        case YBRequestMethodPUT: return @"PUT";
        case YBRequestMethodDELETE: return @"DELETE";
        case YBRequestMethodHEAD: return @"HEAD";
        case YBRequestMethodPATCH: return @"PATCH";
    }
}

- (NSString *)requestURLString {
    NSURL *baseURL = [NSURL URLWithString:self.baseURI];
    NSString *URLString = [NSURL URLWithString:self.requestURI relativeToURL:baseURL].absoluteString;
    return URLString;
}

#pragma mark - getter

- (YBNetworkCache *)cacheHandler {
    if (!_cacheHandler) {
        _cacheHandler = [YBNetworkCache new];
    }
    return _cacheHandler;
}

@end
