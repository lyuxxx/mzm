//
//  BooksResponseModel.m
//  mazimao
//
//  Created by wuhan006 on 2019/4/11.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "BooksResponseModel.h"


@implementation ChapterInfo
+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{
             @"chapterid": @"id"
             };
}

@end


@implementation Book

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{
             @"bookid": @"id",
             @"descrip": @"description"
             };
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    
    NSString *tmp = dic[@"image"];
    _image = [NSString stringWithFormat:@"https://www.qingoo.cn%@",tmp];
    
    return YES;
}

@end


@implementation BooksModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{
             @"data": [Book class]
             };
}

@end


@implementation BooksResponseModel
@end
