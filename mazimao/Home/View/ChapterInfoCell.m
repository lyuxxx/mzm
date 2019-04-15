//
//  ChapterInfoCell.m
//  mazimao
//
//  Created by wuhan006 on 2019/4/11.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "ChapterInfoCell.h"

@interface ChapterInfoCell ()
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *wordCountLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *infoBtn;
@end

@implementation ChapterInfoCell

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    //    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    self.multipleSelectionBackgroundView = [UIView new];
    
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(16);
        make.top.equalTo(12);
        make.height.equalTo(22);
    }];
    
    [self.contentView addSubview:self.timeLabel];
    [self.timeLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.bottom).offset(8);
        make.left.equalTo(16);
        make.bottom.equalTo(-12);
        make.height.equalTo(20);
    }];
    
    [self.contentView addSubview:self.wordCountLabel];
    [self.wordCountLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.timeLabel.right).offset(20);
        make.height.equalTo(20);
        make.centerY.equalTo(self.timeLabel);
    }];
    
    [self.contentView addSubview:self.infoBtn];
    [self.infoBtn makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(-16);
        make.width.height.equalTo(20);
        make.centerY.equalTo(0);
    }];
}

- (void)configWithChapterInfo:(ChapterInfo *)chapterInfo {
    self.nameLabel.text = chapterInfo.name;
    self.timeLabel.text = chapterInfo.update_time;
    self.wordCountLabel.text = [NSString stringWithFormat:@"%ld字",chapterInfo.word_count];
}

- (void)btnClick:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(chapterInfoCell:didClickInfoBtn:)]) {
        [self.delegate chapterInfoCell:self didClickInfoBtn:sender];
    }
}

- (void)resetColor {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self resetColor];
    if (!self.isEditing) {
        return;
    }
    if (selected) {
        [self changeCellSelectedImage];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self resetColor];
    if (!self.isEditing) {
        return;
    }
    if (highlighted) {
        [self changeCellSelectedImage];
    }
}

- (void)changeCellSelectedImage {
    for (UIControl *control in self.subviews) {
        if ([control isMemberOfClass:NSClassFromString(@"UITableViewCellEditControl")]) {
            for (UIView *v in control.subviews) {
                if ([v isKindOfClass:[UIImageView class]]) {
                    UIImageView *imgV = (UIImageView *)v;
                    [imgV setValue:[UIColor colorWithHexString:@"ffc627"] forKey:@"tintColor"];
                }
            }
        }
    }
}

#pragma mark - lazy load -

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textColor = [UIColor colorWithHexString:@"222222"];
    }
    return _nameLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:14];
        _timeLabel.textColor = [UIColor colorWithHexString:@"919191"];
    }
    return _timeLabel;
}

- (UILabel *)wordCountLabel {
    if (!_wordCountLabel) {
        _wordCountLabel = [[UILabel alloc] init];
        _wordCountLabel.font = [UIFont systemFontOfSize:14];
        _wordCountLabel.textColor = [UIColor colorWithHexString:@"919191"];
    }
    return _wordCountLabel;
}

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.font = [UIFont systemFontOfSize:14];
    }
    return _statusLabel;
}

- (UIButton *)infoBtn {
    if (!_infoBtn) {
        _infoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_infoBtn setImage:[UIImage imageNamed:@"catalog_icon_more_list"] forState:UIControlStateNormal];
        [_infoBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _infoBtn;
}

@end
