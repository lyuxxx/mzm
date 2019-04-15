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
