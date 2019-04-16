//
//  DefaultServerRequest.m
//  mazimao
//
//  Created by wuhan006 on 2019/4/16.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "DefaultServerRequest.h"

@implementation DefaultServerRequest

- (instancetype)initWithType:(URIType)type paras:(NSDictionary *)paras {
    self = [self init];
    self.requestURI = [URIManager getURIWithType:type];
    self.requestMethod = [URIManager getRequestMethodWithType:type];
    self.requestParameter = paras;
    return self;
}

- (instancetype)initWithYype:(URIType)type paras:(NSDictionary *)paras delegate:(id<YBResponseDelegate>)delegate {
    self = [self initWithType:type paras:paras];
    self.delegate = delegate;
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.baseURI = @"https://www.qingoo.cn";
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.requestSerializer.timeoutInterval = 30;
        self.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return self;
}

#pragma mark - override -

- (NSDictionary *)yb_preprocessParameter:(NSDictionary *)parameter {
    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:parameter ?: @{}];
    tmp[@"source"] = @"mazimao";
    return tmp;
}

- (NSString *)yb_preprocessURLString:(NSString *)URLString {
    return URLString;
}

- (void)yb_preprocessSuccessInChildThreadWithResponse:(YBNetworkResponse *)response {
    
}

- (void)yb_preprocessFailureInChildThreadWithResponse:(YBNetworkResponse *)response {
    if (response.errorType == YBResponseErrorTypeCancelled) {
        NSLog(@"取消网络请求");
    }
}

@end
