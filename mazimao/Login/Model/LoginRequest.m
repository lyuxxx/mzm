//
//  LoginRequest.m
//  mazimao
//
//  Created by wuhan006 on 2019/4/16.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "LoginRequest.h"

@implementation LoginRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        [self.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    }
    return self;
}

@end
