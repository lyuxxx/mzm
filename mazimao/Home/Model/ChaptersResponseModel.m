//
//  ChaptersResponseModel.m
//  mazimao
//
//  Created by wuhan006 on 2019/4/11.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "ChaptersResponseModel.h"




@implementation Book_Id
@end


@implementation User_id
@end


@implementation Last_chapter_id
@end


@implementation Image_id
@end


@implementation ChapterBook
+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{
             @"book_id": @"id",
             @"descrip": @"description"
             };
}

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{
             @"tags": [NSString class]
             };
}
@end


@implementation ChaptersModel

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{
             @"bookid": @"id"
             };
}

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{
             @"data": [ChapterInfo class]
             };
}
@end


@implementation ChaptersResponseModel
@end
