//
//  MzmBook.h
//  mazimao
//
//  Created by wuhan006 on 2019/4/24.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LKDBHelper.h>

NS_ASSUME_NONNULL_BEGIN

@interface MzmBook : NSObject
@property (nonatomic , copy) NSString              * _id;
@property (nonatomic , copy) NSString              * accountId;
@property (nonatomic , copy) NSString              * box;
@property (nonatomic , assign) double              createts;
@property (nonatomic , copy) NSString              * hRowKey;
@property (nonatomic , copy) NSString              * name;
@property (nonatomic , copy) NSString              * qingguoid;
@property (nonatomic , copy) NSString              * qingguostatus;
@property (nonatomic , assign) double              screatets;
@property (nonatomic , copy) NSString              * status;
@property (nonatomic , assign) double              supdatets;
@property (nonatomic , assign) double              updatets;
@end

@interface MzmChapter : NSObject
@property (nonatomic, copy) NSString *_id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *accountId;
@property (nonatomic, copy) NSString *phonenumber;
@property (nonatomic, assign) double updatets;
@property (nonatomic, assign) double createts;
@property (nonatomic, assign) double screatets;
@property (nonatomic, assign) double supdatets;
///"":正常 "del":回收站 "delforever":彻底删除
@property (nonatomic, copy) NSString *status;
@property (nonatomic, assign) NSInteger wordscount;
///发布成功后有此字段，创建时为空
@property (nonatomic, copy) NSString *qingguoid;
///notcheck:审核中 notpass:未过审 pass:已过审
@property (nonatomic, copy) NSString *qingguostatus;
@property (nonatomic, copy) NSString *box;
@property (nonatomic, copy) NSString *bookid;
///使用<p></p>包裹每行
@property (nonatomic, copy) NSString *content;
///不带格式的内容，手机端默认使用这个
@property (nonatomic, copy) NSString *txt;
@property (nonatomic, copy) NSString *sn;
@property (nonatomic, assign) NSInteger publish_ts;
@end

@interface MzmBooksResponse : NSObject <YYModel>
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, assign) double time;
@property (nonatomic, copy) NSString *data;
@property (nonatomic, strong) NSArray<MzmBook *> *books;
@end

@interface MzmChaptersPage : NSObject <YYModel>
@property (nonatomic, copy) NSString *chapterInfo;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger all_page_num;
@property (nonatomic, assign) NSInteger page_size;
@property (nonatomic, strong) NSArray<MzmChapter *> *chapters;
@end

@interface MzmChaptersResponse : NSObject <YYModel>
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, assign) double time;
@property (nonatomic, strong) MzmChaptersPage *data;
@end

NS_ASSUME_NONNULL_END
