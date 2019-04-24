//
//  BooksResponseModel.h
//  mazimao
//
//  Created by wuhan006 on 2019/4/11.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfoResponseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChapterInfo : NSObject <YYModel>
@property (nonatomic , copy) NSString              * chapterid;
@property (nonatomic , copy) NSString              * name;
@property (nonatomic , assign) NSInteger              sn;
@property (nonatomic , copy) NSString              * content;
///disable:已下架 enable:已上架
@property (nonatomic , copy) NSString              * status;
@property (nonatomic , copy) NSString              *create_time;
@property (nonatomic , copy) NSString              *update_time;
@property (nonatomic , assign) NSInteger              word_count;
///notcheck:审核中 notpass:未过审 pass:已过审
@property (nonatomic , copy) NSString              * checkStatus;
@property (nonatomic , copy) NSString              * checkMessage;
@property (nonatomic , copy) NSString              * authorTalk;

@end


@interface Book :NSObject <YYModel>
@property (nonatomic , copy) NSString              * bookid;
@property (nonatomic , copy) NSString              * name;
@property (nonatomic , copy) NSString              * descrip;
@property (nonatomic , copy) NSString              * attribute;
@property (nonatomic , assign) NSInteger              is_sign;
@property (nonatomic , assign) NSInteger              is_copyright;
@property (nonatomic , copy) NSString              * category;
@property (nonatomic , copy) NSString              * style;
@property (nonatomic , copy) NSString              * ending;
@property (nonatomic , copy) NSString              * image;
@property (nonatomic , copy) NSString              * status;
@property (nonatomic , copy) NSString              * channel;
@property (nonatomic , assign) NSInteger              word_count;
@property (nonatomic , assign) NSInteger              read_count;
@property (nonatomic , assign) NSInteger              click_count;
@property (nonatomic , assign) NSInteger              follow_count;
@property (nonatomic , assign) NSInteger              flush_count;
@property (nonatomic , assign) NSInteger              update_time;
@property (nonatomic, copy) NSString *authorTalk;
@property (nonatomic, copy) NSString *bigGodUser;
@property (nonatomic, copy) NSString *bannerImage;
@property (nonatomic, copy) NSString *reviewState;
@property (nonatomic, copy) NSString *reviewMessage;
@property (nonatomic, copy) NSString *signType;
@property (nonatomic, copy) NSString *outline;
@property (nonatomic, copy) NSString *signStatus;
@property (nonatomic , strong) User              * author;
@property (nonatomic , strong) ChapterInfo              * chapter;
@property (nonatomic , assign) NSInteger              pricePerKword;
@property (nonatomic , copy) NSString              * shareImageUrl;
@property (nonatomic , copy) NSString              * shareUrl;
@property (nonatomic , copy) NSString              * genre;
@property (nonatomic , copy) NSString              * subGenre;
@property (nonatomic, copy) NSString *leadIdentity;
@property (nonatomic, copy) NSString *leadImage;
@property (nonatomic, copy) NSString *storySchool;
@property (nonatomic, copy) NSString *storyElement;
@property (nonatomic, copy) NSString *defTag;
@property (nonatomic, copy) NSString *signVersion;

@end


@interface BooksModel :NSObject <YYModel>
@property (nonatomic , strong) NSArray <Book *>              * data;

@end


@interface BooksResponseModel :NSObject
@property (nonatomic , assign) NSInteger              code;
@property (nonatomic , strong) BooksModel              * model;
@property (nonatomic, copy) NSString *message;
@end

NS_ASSUME_NONNULL_END
