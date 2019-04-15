//
//  ChapterInfoCell.h
//  mazimao
//
//  Created by wuhan006 on 2019/4/11.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChaptersResponseModel.h"

@class ChapterInfoCell;

@protocol ChapterInfoCellDelegate <NSObject>

- (void)chapterInfoCell:(ChapterInfoCell *)cell didClickInfoBtn:(UIButton *_Nonnull)sender;

@end

NS_ASSUME_NONNULL_BEGIN

@interface ChapterInfoCell : UITableViewCell

@property (nonatomic, weak) id<ChapterInfoCellDelegate> delegate;

+ (NSString *)reuseIdentifier;
- (void)configWithChapterInfo:(ChapterInfo *)chapterInfo;

@end

NS_ASSUME_NONNULL_END
