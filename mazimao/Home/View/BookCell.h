//
//  BookCell.h
//  mazimao
//
//  Created by wuhan006 on 2019/4/11.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MzmBook.h"

NS_ASSUME_NONNULL_BEGIN

@interface BookCell : UICollectionViewCell

- (void)configWithBook:(MzmBook *)book;
+ (NSString *)reuseIdentifier;

@end

NS_ASSUME_NONNULL_END
