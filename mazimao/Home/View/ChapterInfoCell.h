//
//  ChapterInfoCell.h
//  mazimao
//
//  Created by wuhan006 on 2019/4/11.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChaptersResponseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChapterInfoCell : UITableViewCell

+ (NSString *)reuseIdentifier;
- (void)configWithChapterInfo:(ChapterInfo *)chapterInfo;

@end

NS_ASSUME_NONNULL_END
