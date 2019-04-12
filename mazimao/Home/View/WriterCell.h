//
//  WriterCell.h
//  mazimao
//
//  Created by wuhan006 on 2019/4/12.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WriterCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;

+ (NSString *)reuseIdentifier;

@end

NS_ASSUME_NONNULL_END
