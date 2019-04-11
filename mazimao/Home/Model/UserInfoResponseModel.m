//
//  UserInfoResponseModel.m
//  mazimao
//
//  Created by wuhan006 on 2019/4/11.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "UserInfoResponseModel.h"

@implementation FullAddress
+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{
             @"addressid": @"id"
             };
}
@end


@implementation FullBankAddress
@end


@implementation User
+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{
             @"userid": @"id"
             };
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSString *faceIDCardImgUrl = dic[@"faceIDCardImgUrl"];
    _faceIDCardImgUrl = [NSString stringWithFormat:@"https://www.qingoo.cn%@",faceIDCardImgUrl];
    
    NSString *rearIDCardImgUrl = dic[@"rearIDCardImgUrl"];
    _rearIDCardImgUrl = [NSString stringWithFormat:@"https://www.qingoo.cn%@",rearIDCardImgUrl];
    
    NSString *bankCardImgUrl = dic[@"bankCardImgUrl"];
    _bankCardImgUrl = [NSString stringWithFormat:@"https://www.qingoo.cn%@",bankCardImgUrl];
    
    NSString *image = dic[@"image"];
    _image = [NSString stringWithFormat:@"https://www.qingoo.cn%@",image];
    
    return YES;
}
@end


@implementation UserInfoModel
@end


@implementation UserInfoResponseModel
@end
