//
//  SettingViewController.m
//  mazimao
//
//  Created by wuhan006 on 2019/4/11.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "SettingViewController.h"
#import "NavigationController.h"

@interface SettingViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSString *> *dataSource;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"设置", nil);
    [self.view addSubview:self.tableView];
    [self.tableView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - UITableViewDataSource -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"settingCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.dataSource[indexPath.row];
    if (indexPath.row == 0) {
        cell.detailTextLabel.text = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    }
    if (indexPath.row == 1) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"温馨提示", nil) attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"222222"],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
        [alertController setValue:title forKey:@"attributedTitle"];
        
        NSAttributedString *message = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"确定要退出账号吗?", nil) attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"919191"],NSFontAttributeName:[UIFont systemFontOfSize:14]}];
        [alertController setValue:message forKey:@"attributedMessage"];
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"退出", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UIViewController *loginVC = [[NSClassFromString(@"LoginViewController") alloc] init];
            NavigationController *navc = [[NavigationController alloc] initWithRootViewController:loginVC];
            navc.navigationBar.hidden = YES;
            
            [UIApplication sharedApplication].delegate.window.rootViewController = navc;
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [defaultAction setValue:[UIColor colorWithHexString:@"ffc627"] forKey:@"titleTextColor"];
        [cancelAction setValue:[UIColor colorWithHexString:@"222222"] forKey:@"titleTextColor"];
        [alertController addAction:cancelAction];
        [alertController addAction:defaultAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - lazy load -

- (NSArray<NSString *> *)dataSource {
    if (!_dataSource) {
        _dataSource = @[
                        NSLocalizedString(@"版本号", nil),
                        NSLocalizedString(@"用户协议", nil),
                        NSLocalizedString(@"退出登录", nil)
                        ];
    }
    return _dataSource;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

@end
