//
//  ChaptersResponseModel.h
//  mazimao
//
//  Created by wuhan006 on 2019/4/11.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BooksResponseModel.h"

NS_ASSUME_NONNULL_BEGIN




@interface Book_Id :NSObject
@property (nonatomic , assign) NSInteger              timestamp;
@property (nonatomic , assign) NSInteger              machineIdentifier;
@property (nonatomic , assign) NSInteger              processIdentifier;
@property (nonatomic , assign) NSInteger              counter;
@property (nonatomic , assign) NSInteger              timeSecond;
@property (nonatomic , assign) NSInteger              date;
@property (nonatomic , assign) NSInteger              time;

@end


@interface User_id :NSObject
@property (nonatomic , assign) NSInteger              timestamp;
@property (nonatomic , assign) NSInteger              machineIdentifier;
@property (nonatomic , assign) NSInteger              processIdentifier;
@property (nonatomic , assign) NSInteger              counter;
@property (nonatomic , assign) NSInteger              timeSecond;
@property (nonatomic , assign) NSInteger              date;
@property (nonatomic , assign) NSInteger              time;

@end


@interface Last_chapter_id :NSObject
@property (nonatomic , assign) NSInteger              timestamp;
@property (nonatomic , assign) NSInteger              machineIdentifier;
@property (nonatomic , assign) NSInteger              processIdentifier;
@property (nonatomic , assign) NSInteger              counter;
@property (nonatomic , assign) NSInteger              timeSecond;
@property (nonatomic , assign) NSInteger              date;
@property (nonatomic , assign) NSInteger              time;

@end


@interface Image_id :NSObject
@property (nonatomic , assign) NSInteger              timestamp;
@property (nonatomic , assign) NSInteger              machineIdentifier;
@property (nonatomic , assign) NSInteger              processIdentifier;
@property (nonatomic , assign) NSInteger              counter;
@property (nonatomic , assign) NSInteger              timeSecond;
@property (nonatomic , assign) NSInteger              date;
@property (nonatomic , assign) NSInteger              time;

@end


@interface ChapterBook :NSObject <YYModel>
@property (nonatomic , strong) Book_Id              * book_id;
@property (nonatomic , copy) NSString              * name;
@property (nonatomic , copy) NSString              * descrip;
@property (nonatomic , assign) NSInteger              word_count;
@property (nonatomic , assign) NSInteger              click_count;
@property (nonatomic , assign) NSInteger              read_count;
@property (nonatomic , copy) NSString              * attribute;
@property (nonatomic , copy) NSString              * genre;
@property (nonatomic , copy) NSString              * subGenre;
@property (nonatomic , strong) NSArray <NSString *>              * tags;
@property (nonatomic , copy) NSString              * style;
@property (nonatomic , copy) NSString              *ending;
@property (nonatomic , copy) NSString              * fenpin;
@property (nonatomic , assign) NSInteger              chinese;
@property (nonatomic , assign) NSInteger              nonchinese;
@property (nonatomic , assign) NSInteger              qingqingtuijian;
@property (nonatomic , assign) NSInteger              qingguoshujiatuijian;
@property (nonatomic , assign) NSInteger              qudaoshujiatuijian;
@property (nonatomic , assign) NSInteger              qudaojingpintuijian;
@property (nonatomic , assign) NSInteger              qudaofengyunbangtuijian;
@property (nonatomic , assign) NSInteger              qudaofengyunbangliebiao;
@property (nonatomic , assign) NSInteger              nanpintuijian;
@property (nonatomic , assign) NSInteger              nvpintuijian;
@property (nonatomic , assign) NSInteger              zhendianzhibao;
@property (nonatomic , assign) NSInteger              shanzhai;
@property (nonatomic , copy) NSString               *host;
@property (nonatomic , copy) NSString               *lastChapter;
@property (nonatomic , strong) User_id              * user_id;
@property (nonatomic , strong) Last_chapter_id              * last_chapter_id;
@property (nonatomic , strong) Image_id              * image_id;
@property (nonatomic , copy) NSString              * status;
@property (nonatomic , copy) NSString              * update_time;
@property (nonatomic , copy) NSString              * create_time;
@property (nonatomic , copy) NSString              * sign_status;
@property (nonatomic , copy) NSString              * sign_type;
@property (nonatomic , copy) NSString              * sign_message;
@property (nonatomic , copy) NSString              * start_time;
@property (nonatomic , copy) NSString              * finish_time;
@property (nonatomic , assign) NSInteger              pricePerKword;
@property (nonatomic , assign) NSInteger              monthUpdateWord;
@property (nonatomic , assign) NSInteger              advertRate;
@property (nonatomic , copy) NSString              * publish_chapter_time;
@property (nonatomic , assign) NSInteger              comments_count;
@property (nonatomic , copy) NSString              * banner_id;
@property (nonatomic , copy) NSString              * rank_code;
@property (nonatomic , copy) NSString *up_count;
@property (nonatomic , copy) NSString *rank_time;
@property (nonatomic , copy) NSString *up_time;
@property (nonatomic , copy) NSString *week_click;
@property (nonatomic , copy) NSString *subscribe_count;
@property (nonatomic , assign) NSInteger              foreign_id;
@property (nonatomic , copy) NSString *manager_user_alias;
@property (nonatomic , copy) NSString *big_image_id;
@property (nonatomic , assign) NSInteger              flush_count;
@property (nonatomic , copy) NSString *reviewState;
@property (nonatomic , copy) NSString *reviewMessage;
@property (nonatomic , copy) NSString *rejectMessage;
@property (nonatomic , copy) NSString *outline;
@property (nonatomic , copy) NSString *signWordsCount;
@property (nonatomic , copy) NSString *createCycleStartTime;
@property (nonatomic , copy) NSString *createCycleEndTime;
@property (nonatomic , copy) NSString *contractNO;
@property (nonatomic , copy) NSString              * authorTalk;
@property (nonatomic , copy) NSString *retentionRate;
@property (nonatomic , assign) NSInteger              weekRead;
@property (nonatomic , assign) NSInteger              subscribeCountWeek;
@property (nonatomic , assign) NSInteger              updateWordNumberWeek;
@property (nonatomic , assign) NSInteger              retentionRateWeek;
@property (nonatomic , assign) NSInteger              retentionRateMonth;
@property (nonatomic , assign) NSInteger              todayCommentsCount;
@property (nonatomic , copy) NSString *buyoutPlusWordFinishTime;
@property (nonatomic , copy) NSString *mockCount;
@property (nonatomic , copy) NSString *signVersion;
@property (nonatomic , copy) NSString *applyConfirmTime;
@property (nonatomic , copy) NSString *outlineTime;
@property (nonatomic , copy) NSString *outlineConfirmTime;
@property (nonatomic , copy) NSString *profileConfirmTime;
@property (nonatomic , copy) NSString *realNameAuthTime;
@property (nonatomic , copy) NSString *signTime;
@property (nonatomic , copy) NSString *accountId;
@property (nonatomic , copy) NSString *signContractId;

@end


@interface ChaptersModel :NSObject <YYModel>
@property (nonatomic , assign) NSInteger              pages;
@property (nonatomic , strong) NSArray <ChapterInfo *>              * data;
@property (nonatomic , assign) NSInteger              size;
@property (nonatomic , assign) NSInteger              cpage;
@property (nonatomic , assign) NSInteger              draftsize;
@property (nonatomic , strong) ChapterBook              * book;
@property (nonatomic , copy) NSString              * bookid;
@property (nonatomic , assign) NSInteger              time_size;

@end


@interface ChaptersResponseModel :NSObject
@property (nonatomic , assign) NSInteger              code;
@property (nonatomic , strong) ChaptersModel              * model;
@property (nonatomic , copy) NSString             * message;

@end

NS_ASSUME_NONNULL_END
