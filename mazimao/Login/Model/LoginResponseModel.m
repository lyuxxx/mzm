//
//  LoginResponseModel.m
//  mazimao
//
//  Created by wuhan006 on 2019/4/11.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "LoginResponseModel.h"

@implementation FullAddress
@end


@implementation FullBankAddress
@end


@implementation User

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{
             @"userid": @"id"
             };
}

@end


@implementation LoginModel
@end


@implementation LoginResponseModel
@end
