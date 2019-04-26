//
//  WriterViewController.m
//  mazimao
//
//  Created by wuhan006 on 2019/4/12.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "WriterViewController.h"
#import "WriterCell.h"
#import <UITextView+Placeholder.h>

@interface CreateButton : UIButton

@end

@implementation CreateButton

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    return CGRectMake(14.0 / 44.0 * contentRect.size.width, 8.0 / 48.0 * contentRect.size.height, 16.0 / 44.0 * contentRect.size.width, 18.0 / 48.0 * contentRect.size.height);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    return CGRectMake(10.0 / 44.0 * contentRect.size.width, 26.0 / 48.0 * contentRect.size.height, 24.0 / 44.0 * contentRect.size.width, 18.0 / 48.0 * contentRect.size.height);
}

@end

@interface WriterViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UITextViewDelegate>

@property (nonatomic, strong) MzmChapter *chapter;

@property (nonatomic, strong) UIButton *publishBtn;
@property (nonatomic, strong) UIButton *syncBtn;

@property (nonatomic, strong) UITextField *nameField;

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) UIView *inputAccessoryView;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) CreateButton *createButton;
@property (nonatomic, strong) UIButton *keyboardBtn;

@property (nonatomic, strong) NSArray<NSString *> *editorIcons;
@property (nonatomic ,strong) NSArray<NSString *> *editorStrs;

@end

@implementation WriterViewController

- (instancetype)initWithChapter:(MzmChapter *)chapter {
    self = [super init];
    if (self) {
        self.chapter = chapter;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.nameField];
    [self.nameField makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(24);
		make.right.equalTo(-24);
        make.top.equalTo(16);
        make.height.equalTo(25);
    }];
    
    [self.view addSubview:self.textView];
    [self.textView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameField.bottom).offset(12);
        make.left.equalTo(24);
        make.right.equalTo(-24);
        make.bottom.equalTo(-kBottomHeight);
    }];
    
    [self configBarButton];
    [self configInputAccessory];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    self.nameField.text = self.chapter.name;
    self.textView.text = self.chapter.txt;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if ([self.nameField.text isNotBlank]) {
		[self.textView becomeFirstResponder];
	} else {
		[self.nameField becomeFirstResponder];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
		self.navigationController.interactivePopGestureRecognizer.enabled = NO;
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
		self.navigationController.interactivePopGestureRecognizer.enabled = YES;
	}
}

- (void)btnClick:(UIButton *)sender {
    if (sender == self.keyboardBtn) {
        [self.textView resignFirstResponder];
		[self.nameField resignFirstResponder];
    }
}

- (void)pop {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)configBarButton {
	
	//https://juejin.im/post/5a52d4316fb9a01c9657f93d 解决leftItem偏移
	CGFloat offset = 25;
	NavigationItemCustomView *backBtn = [NavigationItemCustomView buttonWithType:UIButtonTypeCustom];
	[backBtn setImage:[UIImage imageNamed:@"set_icon_back"] forState:UIControlStateNormal];
	[backBtn addTarget:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
	
	backBtn.alignmentRectInsetsOverride = UIEdgeInsetsMake(0, offset, 0, -offset);
	backBtn.translatesAutoresizingMaskIntoConstraints = NO;
	[backBtn.widthAnchor constraintEqualToConstant:44].active = YES;
	[backBtn.heightAnchor constraintEqualToConstant:44].active = YES;
	
	UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	spaceItem.width = -offset;
	
	self.navigationItem.leftBarButtonItems = @[spaceItem, backItem];
    
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
    
    [self.inputAccessoryView addSubview:self.collectionView];
    [self.collectionView makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.inputAccessoryView);
        make.left.equalTo(self.createButton.right);
        make.right.equalTo(-44);
    }];
    
    [self.inputAccessoryView addSubview:self.keyboardBtn];
    [self.keyboardBtn makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(44);
        make.right.top.bottom.equalTo(self.inputAccessoryView);
    }];
    
    UIView *verticalLine = [[UIView alloc] init];
    verticalLine.backgroundColor = [UIColor colorWithHexString:@"e9e9e9"];
    [self.inputAccessoryView addSubview:verticalLine];
    [verticalLine makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(0.5);
        make.height.equalTo(26);
        make.right.equalTo(self.createButton.right);
        make.centerY.equalTo(self.createButton);
    }];
    
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
	if ([self.nameField isFirstResponder]) {
		return;
	}
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
    if (indexPath.row == 3) {//双引号
        [self.textView setSelectedRange:NSMakeRange(self.textView.text.length - 1, 0)];
    }
}

#pragma mark - lazy load -

- (UITextField *)nameField {
	if (!_nameField) {
		_nameField = [[UITextField alloc] init];
		_nameField.textColor = [UIColor colorWithHexString:@"222222"];
		_nameField.font = [UIFont systemFontOfSize:18];
		_nameField.tintColor = [UIColor colorWithHexString:@"ffc627"];
		_nameField.inputAccessoryView = [UIView new];
	}
	return _nameField;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.font = [UIFont systemFontOfSize:16];
        _textView.textColor = [UIColor colorWithHexString:@"404040"];
        _textView.inputAccessoryView = self.inputAccessoryView;
        _textView.tintColor = [UIColor colorWithHexString:@"ffc627"];
        _textView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"请输入章节内容", nil) attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"919191"],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
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
        _createButton = [CreateButton buttonWithType:UIButtonTypeCustom];
        [_createButton setImage:[UIImage imageNamed:@"editor_icon_new_section"] forState:UIControlStateNormal];
        [_createButton setTitle:NSLocalizedString(@"新建", nil) forState:UIControlStateNormal];
        [_createButton setTitleColor:[UIColor colorWithHexString:@"222222"] forState:UIControlStateNormal];
        _createButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _createButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_createButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _createButton;
}

- (UIButton *)keyboardBtn {
    if (!_keyboardBtn) {
        _keyboardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _keyboardBtn.backgroundColor = [UIColor whiteColor];
        [_keyboardBtn setImage:[UIImage imageNamed:@"content_icon_retract"] forState:UIControlStateNormal];
        [_keyboardBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _keyboardBtn.layer.shadowOffset = CGSizeMake(-5, 0);
        _keyboardBtn.layer.shadowColor = [UIColor colorWithHexString:@"919191"].CGColor;
        _keyboardBtn.layer.shadowRadius = 3;
        _keyboardBtn.layer.shadowOpacity = 0.1;
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
        flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        
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
