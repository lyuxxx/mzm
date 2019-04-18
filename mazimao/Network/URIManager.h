//
//  URIManager.h
//  mazimao
//
//  Created by wuhan006 on 2019/4/16.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YBBaseRequest.h"

typedef NS_ENUM(NSUInteger, URIType) {
    URITypeLogin,
    URITypeUserInfo,
    URITypeBookList,
    URITypeChapterList,
    URITypeChapterContent,
};

NS_ASSUME_NONNULL_BEGIN

@interface URIManager : NSObject

+ (NSString *)getURIWithType:(URIType)type;
+ (YBRequestMethod)getRequestMethodWithType:(URIType)type;

@end

NS_ASSUME_NONNULL_END
