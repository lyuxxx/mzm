//
//  ProfileViewController.m
//  mazimao
//
//  Created by wuhan006 on 2019/4/11.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "ProfileViewController.h"
#import <UIViewController+CWLateralSlide.h>

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIImageView *avatarImgV;
@property (nonatomic, strong) UILabel *pennameLabel;
@property (nonatomic, strong) UILabel *idLabel;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation ProfileViewController

#pragma mark -life cycle -

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

#pragma mark - private func -

- (void)setupUI {
    [self.view addSubview:self.avatarImgV];
    self.avatarImgV.layer.cornerRadius = 25;
    self.avatarImgV.layer.masksToBounds = YES;
    [self.avatarImgV makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(50);
        make.top.equalTo(kStatusBarHeight + 44);
        make.left.equalTo(24);
    }];
    
    [self.view addSubview:self.pennameLabel];
    [self.pennameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarImgV);
        make.left.equalTo(self.avatarImgV.right).offset(16);
    }];
    
    [self.view addSubview:self.idLabel];
    [self.idLabel makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.avatarImgV);
        make.left.equalTo(self.pennameLabel);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithHexString:@"e9e9e9"];
    [self.view addSubview:line];
    [line makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(208);
        make.height.equalTo(0.5);
        make.left.equalTo(self.avatarImgV);
        make.top.equalTo(self.avatarImgV.bottom).offset(40);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(line.bottom).offset(25);
    }];
    
    [self configContent];
}

- (void)configContent {
    [self.avatarImgV sd_setImageWithURL:[NSURL URLWithString:self.user.image] placeholderImage:[UIImage imageNamed:@"bookshelf_icon_persal_big"]];
    self.pennameLabel.text = self.user.penname;
    self.idLabel.text = [NSString stringWithFormat:@"账号: %@",self.user.mobilenumber];
}

#pragma mark - UITableViewDataSource -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"porfileCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.imageView.image = [UIImage imageNamed:@"persal_icon_set"];
    cell.textLabel.text = NSLocalizedString(@"设置", nil);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        UIViewController *vc = [[NSClassFromString(@"SettingViewController") alloc] init];
        [self cw_pushViewController:vc];
    }
}

#pragma mark - lazy load -

- (UIImageView *)avatarImgV {
    if (!_avatarImgV) {
        _avatarImgV = [[UIImageView alloc] init];
    }
    return _avatarImgV;
}

- (UILabel *)pennameLabel {
    if (!_pennameLabel) {
        _pennameLabel = [[UILabel alloc] init];
        _pennameLabel.font = [UIFont systemFontOfSize:16];
        _pennameLabel.textColor = [UIColor colorWithHexString:@"222222"];
    }
    return _pennameLabel;
}

- (UILabel *)idLabel {
    if (!_idLabel) {
        _idLabel = [[UILabel alloc] init];
        _idLabel.font = [UIFont systemFontOfSize:14];
        _idLabel.textColor = [UIColor colorWithHexString:@"919191"];
    }
    return _idLabel;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
    }
    return _tableView;
}

@end
