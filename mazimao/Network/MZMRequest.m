//
//  MZMRequest.m
//  mazimao
//
//  Created by wuhan006 on 2019/4/22.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "MZMRequest.h"

@implementation MZMRequest

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
		self.baseURI = @"https://api.writingai.cn";
//		self.baseURI = @"http://10.80.122.208:8080";//测试地址
		self.requestSerializer = [AFHTTPRequestSerializer serializer];
//		[self.requestSerializer setValue:@"1529029300212" forHTTPHeaderField:@"test"];
		self.requestSerializer.timeoutInterval = 30;
		self.responseSerializer = [AFJSONResponseSerializer serializer];
	}
	return self;
}

- (NSString *)stringFromParameter:(NSDictionary *)parameter {
	NSMutableString *string = [NSMutableString string];
	NSArray *allKeys = [parameter.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
		return [[NSString stringWithFormat:@"%@", obj1] compare:[NSString stringWithFormat:@"%@", obj2] options:NSLiteralSearch];
	}];
	for (id key in allKeys) {
		[string appendString:[NSString stringWithFormat:@"%@%@=%@", string.length > 0 ? @"&" : @"", key, parameter[key]]];
	}
	return string;
}

#pragma mark - override -

- (NSDictionary *)yb_preprocessParameter:(NSDictionary *)parameter {
	if (parameter.allKeys.count) {
		NSString *token = [NSString stringWithFormat:@"%@%@",[self stringFromParameter:parameter],MZMMd5SaltKey];
		[self.requestSerializer setValue:[token md5String] forHTTPHeaderField:@"token"];
	}
	return parameter;
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
