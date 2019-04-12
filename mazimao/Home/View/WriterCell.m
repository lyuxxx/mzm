//
//  WriterCell.m
//  mazimao
//
//  Created by wuhan006 on 2019/4/12.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "WriterCell.h"

@implementation WriterCell

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:self.imageView];
        [self.imageView makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(28);
            make.center.equalTo(self.contentView);
        }];
    }
    return self;
}

@end
