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
        case URITypeQgLogin:
            uri = @"/api/rl/logindo";
            break;
        case URITypeQgUserInfo:
            uri = @"/api/user/get";
			break;
		case URITypeQgBookList:
			uri = @"/api/book/list";
			break;
		case URITypeQgChapterList:
			uri = @"/api/book/chapterlist";
			break;
		case URITypeQgChapterContent:
			uri = @"/api/chapter/getchapter";
			break;
		case URITypeQgCheckContext:
			uri = @"/api/chapter/checkContext";
			break;
		case URITypeQgPublishChapter:
			uri = @"/api/chapter/createdo";
			break;
		case URITypeQgUpdateChapter:
			uri = @"/api/chapter/update";
			break;
		
			
		case URITypeMzmBookList:
			uri = @"/v2/books/get_books_list";
			break;
		case URITypeMzmUpdateBookList:
			uri = @"/v2/books/update_books_list";
			break;
        case URITypeMzmChapterList:
            uri = @"/v2/chapters/get_chapters_list_app";
            break;
		case URITypeMzmUpdateChapterList:
			uri = @"/v2/chapters/update_chapters_list";
			break;
        default:
            break;
    }
    return uri;
}

+ (YBRequestMethod)getRequestMethodWithType:(URIType)type {
    YBRequestMethod method = YBRequestMethodGET;
    switch (type) {
		case URITypeQgLogin:
		case URITypeQgCheckContext:
		case URITypeQgPublishChapter:
		case URITypeQgUpdateChapter:
		case URITypeMzmUpdateBookList:
		case URITypeMzmUpdateChapterList:
			method = YBRequestMethodPOST;
			break;
            
        default:
            break;
    }
    return method;
}

@end
