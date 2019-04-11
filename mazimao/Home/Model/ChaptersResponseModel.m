//
//  ChaptersResponseModel.m
//  mazimao
//
//  Created by wuhan006 on 2019/4/11.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "ChaptersResponseModel.h"

@implementation ChapterInfo
+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{
             @"chapterid": @"id"
             };
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    formatter.timeZone = [NSTimeZone localTimeZone];
    
    NSTimeInterval createTS = ((NSNumber *)dic[@"create_time"]).floatValue / 1000.0;
    NSDate *createTime = [NSDate dateWithTimeIntervalSince1970:createTS];
    _create_time = [formatter stringFromDate:createTime];
    
    NSTimeInterval updateTS = ((NSNumber *)dic[@"update_time"]).floatValue / 1000.0;
    NSDate *updateTime = [NSDate dateWithTimeIntervalSince1970:updateTS];
    _update_time = [formatter stringFromDate:updateTime];
    
    return YES;
}


@end


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
