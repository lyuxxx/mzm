//
//  WriterViewController.m
//  mazimao
//
//  Created by wuhan006 on 2019/4/12.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "WriterViewController.h"
#import "WriterCell.h"

@interface WriterViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIButton *publishBtn;
@property (nonatomic, strong) UIButton *syncBtn;

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) UIView *inputAccessoryView;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIButton *createButton;
@property (nonatomic, strong) UIButton *keyboardBtn;

@property (nonatomic, strong) NSArray<NSString *> *editorIcons;
@property (nonatomic ,strong) NSArray<NSString *> *editorStrs;

@end

@implementation WriterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.textView];
    [self.textView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(53);
        make.left.equalTo(24);
        make.right.equalTo(-24);
        make.bottom.equalTo(-kBottomHeight);
    }];
    
    [self configBarButton];
    [self configInputAccessory];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)btnClick:(UIButton *)sender {
    if (sender == self.keyboardBtn) {
        [self.textView resignFirstResponder];
    }
}

- (void)configBarButton {
    
    self.publishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.publishBtn.adjustsImageWhenHighlighted = NO;
    [self.publishBtn setImage:[UIImage imageNamed:@"content_icon_release"] forState:UIControlStateNormal];
    [self.publishBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem0 = [[UIBarButtonItem alloc] initWithCustomView:self.publishBtn];
    
    self.syncBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.syncBtn.adjustsImageWhenHighlighted = NO;
    [self.syncBtn setImage:[UIImage imageNamed:@"bookshelf_icon_icloud"] forState:UIControlStateNormal];
    [self.syncBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem1 = [[UIBarButtonItem alloc] initWithCustomView:self.syncBtn];
    
    self.navigationItem.rightBarButtonItems = @[rightItem0, rightItem1];
}

- (void)configInputAccessory {
    [self.inputAccessoryView addSubview:self.createButton];
    [self.createButton makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(44);
        make.left.top.bottom.equalTo(self.inputAccessoryView);
    }];
    
    [self.inputAccessoryView addSubview:self.keyboardBtn];
    [self.keyboardBtn makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(44);
        make.right.top.bottom.equalTo(self.inputAccessoryView);
    }];
    
    [self.inputAccessoryView addSubview:self.collectionView];
    [self.collectionView makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.inputAccessoryView);
        make.left.equalTo(self.createButton.right);
        make.right.equalTo(self.keyboardBtn.left);
    }];
    
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:duration animations:^{
        if (keyboardFrame.origin.y < self.view.frame.size.height) {
            [self.textView updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(-keyboardFrame.size.height - 5);
            }];
        } else {
            [self.textView updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(-kBottomHeight);
            }];
        }
        
        [self.view setNeedsUpdateConstraints];
        [self.view updateConstraintsIfNeeded];
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - UICollectionViewDataSource -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.editorIcons.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WriterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[WriterCell reuseIdentifier] forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:self.editorIcons[indexPath.item]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(28,28);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *str = self.editorStrs[indexPath.item];
    self.textView.text = [NSString stringWithFormat:@"%@%@",self.textView.text,str];
}

#pragma mark - lazy load -

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.font = [UIFont systemFontOfSize:16];
        _textView.textColor = [UIColor colorWithHexString:@"404040"];
        _textView.inputAccessoryView = self.inputAccessoryView;
    }
    return _textView;
}

- (UIView *)inputAccessoryView {
    if (!_inputAccessoryView) {
        _inputAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 48)];
        _inputAccessoryView.backgroundColor = [UIColor whiteColor];
        _inputAccessoryView.layer.shadowOffset = CGSizeMake(0, -5);
        _inputAccessoryView.layer.shadowColor = [UIColor colorWithHexString:@"919191"].CGColor;
        _inputAccessoryView.layer.shadowRadius = 5;
        _inputAccessoryView.layer.shadowOpacity = 0.1;
        
    }
    return _inputAccessoryView;
}

- (UIButton *)createButton {
    if (!_createButton) {
        _createButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_createButton setImage:[UIImage imageNamed:@"editor_icon_new_section"] forState:UIControlStateNormal];
        [_createButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _createButton;
}

- (UIButton *)keyboardBtn {
    if (!_keyboardBtn) {
        _keyboardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_keyboardBtn setImage:[UIImage imageNamed:@"content_icon_retract"] forState:UIControlStateNormal];
        [_keyboardBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _keyboardBtn;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumInteritemSpacing = 10;
        flowLayout.minimumLineSpacing = 10;
        flowLayout.itemSize = CGSizeMake(28, 28);
        flowLayout.sectionInset = UIEdgeInsetsMake(10, 0, 10, 0);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        [_collectionView registerClass:[WriterCell class] forCellWithReuseIdentifier:[WriterCell reuseIdentifier]];
    }
    return _collectionView;
}

- (NSArray<NSString *> *)editorIcons {
    return @[
             @"editor_icon_douhao",
             @"editor_icon_juhao",
             @"editor_icon_maohao",
             @"editor_icon_yinhao",
             @"editor_icon_shengluehao",
             @"editor_icon_tanhao",
             @"editor_icon_wenhao",
             @"editor_icon_dunhao"
             ];
}

- (NSArray<NSString *> *)editorStrs {
    return @[
             @"，",
             @"。",
             @"：",
             @"“”",
             @"……",
             @"！",
             @"？",
             @"、"
             ];
}

@end
