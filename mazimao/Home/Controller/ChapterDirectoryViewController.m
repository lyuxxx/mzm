//
//  ChapterDirectoryViewController.m
//  mazimao
//
//  Created by wuhan006 on 2019/4/11.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "ChapterDirectoryViewController.h"
#import <YBPopupMenu.h>

@interface ChapterDirectoryViewController () <UITableViewDelegate, UITableViewDataSource, YBPopupMenuDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UIButton *syncBtn;
@property (nonatomic, strong) UIButton *moreBtn;
@end

@implementation ChapterDirectoryViewController

#pragma mark - life cycle -

- (void)viewDidLoad {
    [self setupUI];
}

#pragma mark - private func -

- (void)setupUI {
    self.navigationItem.title = NSLocalizedString(@"章节目录", nil);
    [self setupBarButton];
    [self.view addSubview:self.tableView];
    [self.tableView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)setupBarButton {
    self.moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.moreBtn.adjustsImageWhenHighlighted = NO;
    [self.moreBtn setImage:[UIImage imageNamed:@"catalog_icon_more"] forState:UIControlStateNormal];
    [self.moreBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right0 = [[UIBarButtonItem alloc] initWithCustomView:self.moreBtn];
    
    self.syncBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.syncBtn.adjustsImageWhenHighlighted = NO;
    [self.syncBtn setImage:[UIImage imageNamed:@"bookshelf_icon_icloud"] forState:UIControlStateNormal];
    [self.syncBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right1 = [[UIBarButtonItem alloc] initWithCustomView:self.syncBtn];
    
    self.navigationItem.rightBarButtonItems = @[right0, right1];
    
    [self.moreBtn makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(28);
    }];
    [self.syncBtn makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(28);
    }];
}

- (void)btnClick:(UIButton *)sender {
    if (sender == self.moreBtn) {
        NSArray *titles = @[
                            NSLocalizedString(@"编辑章节", nil),
                            NSLocalizedString(@"章节正序", nil),
                            NSLocalizedString(@"回收站", nil)
                            ];
        NSArray *icons = @[
                           @"catalog_icon_editor",
                           @"catalog_icon_positive_sequence",
                           @"catalog_icon_recycle bin"
                           ];
        [YBPopupMenu showRelyOnView:self.moreBtn titles:titles icons:icons menuWidth:126 delegate:self];
    }
}

#pragma mark - YBPopupMenuDelegate -

- (void)ybPopupMenu:(YBPopupMenu *)ybPopupMenu didSelectedAtIndex:(NSInteger)index {
    
}

#pragma mark - UITableViewDataSource -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[UITableViewCell alloc] init];
}

#pragma mark - lazy load -

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

@end
