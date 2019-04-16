//
//  URIManager.m
//  mazimao
//
//  Created by wuhan006 on 2019/4/16.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "URIManager.h"

@implementation URIManager

+ (NSString *)getURIWithType:(URIType)type {
    
    NSString *uri = nil;
    
    switch (type) {
        case URITypeLogin:
            uri = @"/api/rl/logindo";
            break;
        case URITypeUserInfo:
            uri = @"/api/user/get";
            break;
        case URITypeBookList:
            uri = @"/api/book/list";
            break;
        case URITypeChapterList:
            uri = @"/api/book/chapterlist";
            break;
        case URITypeChapterContent:
            uri = @"/api/chapter/getchapter";
            break;
        default:
            break;
    }
    return uri;
}

+ (YBRequestMethod)getRequestMethodWithType:(URIType)type {
    YBRequestMethod method = YBRequestMethodGET;
    switch (type) {
        case URITypeLogin:
            method = YBRequestMethodPOST;
            break;
            
        default:
            break;
    }
    return method;
}

@end
