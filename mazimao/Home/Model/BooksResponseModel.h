//
//  BooksResponseModel.h
//  mazimao
//
//  Created by wuhan006 on 2019/4/11.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginResponseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface Author :NSObject <YYModel>
@property (nonatomic , copy) NSString              * authorid;
@property (nonatomic , copy) NSString              * mobilenumber;
@property (nonatomic , copy) NSString              * penname;
@property (nonatomic , copy) NSString              * email;
@property (nonatomic , copy) NSString              * qq;
@property (nonatomic , strong) FullAddress              * fullAddress;
@property (nonatomic , strong) FullBankAddress              * fullBankAddress;

@end


@interface Chapter :NSObject
@property (nonatomic , assign) NSInteger              sn;
@property (nonatomic , assign) NSInteger              create_time;
@property (nonatomic , assign) NSInteger              update_time;
@property (nonatomic , assign) NSInteger              word_count;

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
@property (nonatomic , strong) Author              * author;
@property (nonatomic , strong) Chapter              * chapter;
@property (nonatomic , assign) NSInteger              pricePerKword;
@property (nonatomic , copy) NSString              * shareImageUrl;
@property (nonatomic , copy) NSString              * shareUrl;
@property (nonatomic , copy) NSString              * genre;
@property (nonatomic , copy) NSString              * subGenre;

@end


@interface BooksModel :NSObject <YYModel>
@property (nonatomic , strong) NSArray <Book *>              * data;

@end


@interface BooksResponseModel :NSObject
@property (nonatomic , assign) NSInteger              code;
@property (nonatomic , strong) BooksModel              * model;

@end

NS_ASSUME_NONNULL_END
