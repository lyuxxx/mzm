//
//  LocalBook.h
//  mazimao
//
//  Created by wuhan006 on 2019/4/24.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LKDBHelper.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocalBook : NSObject
@property (nonatomic , copy) NSString              * _id;
@property (nonatomic , copy) NSString              * accountId;
@property (nonatomic , copy) NSString              * box;
@property (nonatomic , assign) NSInteger              createts;
@property (nonatomic , copy) NSString              * hRowKey;
@property (nonatomic , copy) NSString              * name;
@property (nonatomic , copy) NSString              * qingguoid;
@property (nonatomic , copy) NSString              * qingguostatus;
@property (nonatomic , assign) NSInteger              screatets;
@property (nonatomic , copy) NSString              * status;
@property (nonatomic , assign) NSInteger              supdatets;
@property (nonatomic , assign) NSInteger              updatets;
@end

@interface LocalChapter : NSObject
@property (nonatomic, copy) NSString *_id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *accountId;
@property (nonatomic, copy) NSString *phonenumber;
@property (nonatomic, assign) NSInteger updatets;
@property (nonatomic, assign) NSInteger createts;
@property (nonatomic, assign) NSInteger screatets;
@property (nonatomic, assign) NSInteger supdatets;
///"":正常 "del":回收站 "delforever":彻底删除
@property (nonatomic, copy) NSString *status;
@property (nonatomic, assign) NSInteger wordscount;
///发布成功后有此字段，创建时为空
@property (nonatomic, copy) NSString *qingguoid;
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

NS_ASSUME_NONNULL_END
