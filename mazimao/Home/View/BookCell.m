//
//  BookCell.m
//  mazimao
//
//  Created by wuhan006 on 2019/4/11.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "BookCell.h"

@interface BookCell ()
@property (nonatomic, strong) UIImageView *coverImgV;
@property (nonatomic, strong) UILabel *nameLabel;
@end

@implementation BookCell

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.coverImgV = [[UIImageView alloc] init];
        [self.contentView addSubview:self.coverImgV];
        [self.coverImgV makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(158);
            make.height.equalTo(223);
            make.centerX.equalTo(0);
            make.top.equalTo(50);
        }];
        
        self.nameLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.nameLabel];
        [self.nameLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(0);
            make.top.equalTo(self.coverImgV.bottom).offset(36);
        }];
    }
    return self;
}

- (void)configWithBook:(Book *)book {
    [self.coverImgV sd_setImageWithURL:[NSURL URLWithString:book.image] placeholderImage:[UIImage imageNamed:@"default_cover"]];
    self.nameLabel.text = book.name;
}

@end
