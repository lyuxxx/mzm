//
//  LoginViewController.m
//  mazimao
//
//  Created by wuhan006 on 2019/4/11.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginResponseModel.h"
#import "BooksViewController.h"
#import "NavigationController.h"
#import "LoginRequest.h"
#import "UserInfoResponseModel.h"

@interface LoginViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *usernameField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UIButton *securityBtn;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, copy) LoginResult loginResult;
@end

@implementation LoginViewController

#pragma mark - life cycle -

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    
    //test
    self.usernameField.text = @"13581529298";
    self.passwordField.text = @"602274795";
    self.loginBtn.enabled = YES;
}

#pragma mark - private func -

- (void)setupUI {
    UIImageView *logoImgV = [[UIImageView alloc] init];
    logoImgV.image = [UIImage imageNamed:@"login_icon_logo"];
    [self.view addSubview:logoImgV];
    [logoImgV makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(50);
        make.centerX.equalTo(0);
        make.top.equalTo(kStatusBarHeight + 84);
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = NSLocalizedString(@"码字，就用码字猫", nil);
    label.textColor = [UIColor colorWithHexString:@"404040"];
    label.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:label];
    [label makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(logoImgV.bottom).offset(14);
        make.centerX.equalTo(0);
    }];
    
    [self.view addSubview:self.usernameField];
    [self.usernameField makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(315);
        make.height.equalTo(50);
        make.centerX.equalTo(0);
        make.top.equalTo(label.bottom).offset(48);
    }];
    
    [self.view addSubview:self.passwordField];
    [self.passwordField makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.centerX.equalTo(self.usernameField);
        make.top.equalTo(self.usernameField.bottom).offset(5);
    }];
    
    UIView *line0 = [[UIView alloc] init];
    line0.backgroundColor = [UIColor colorWithHexString:@"e9e9e9"];
    [self.view addSubview:line0];
    [line0 makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(0.5);
        make.left.right.bottom.equalTo(self.usernameField);
    }];
    
    UIView *line1 = [[UIView alloc] init];
    line1.backgroundColor = [UIColor colorWithHexString:@"e9e9e9"];
    [self.view addSubview:line1];
    [line1 makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(0.5);
        make.left.right.bottom.equalTo(self.passwordField);
    }];
    
    [self.view addSubview:self.tipLabel];
    [self.tipLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.passwordField);
        make.height.equalTo(20);
        make.top.equalTo(self.passwordField.bottom).offset(15);
    }];
    
    [self.view addSubview:self.loginBtn];
    [self.loginBtn makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(315);
        make.height.equalTo(40);
        make.centerX.equalTo(0);
        make.top.equalTo(self.tipLabel.bottom).offset(14);
    }];
    
    self.loginBtn.enabled = NO;
}

- (void)btnClick:(UIButton *)sender {
    if (sender == self.securityBtn) {
        sender.selected = !sender.selected;
        self.passwordField.secureTextEntry = ! self.passwordField.secureTextEntry;
    }
    if (sender == self.loginBtn) {
        [self login];
    }
}

- (void)login {
    LoginRequest *request = [LoginRequest new];
    request.requestURI = [URIManager getURIWithType:URITypeQgLogin];
    request.requestMethod = [URIManager getRequestMethodWithType:URITypeQgLogin];
    request.requestParameter = @{
                                 @"name": self.usernameField.text,
                                 @"password": self.passwordField.text
                                 };
    request.delegate = self;
    [request start];
}

- (void)autoLoginWithResult:(LoginResult)result {
	
	//没有记录过用户登录信息，无法自动登录
	if (![[NSUserDefaults standardUserDefaults] stringForKey:@"username"] || ![[NSUserDefaults standardUserDefaults] stringForKey:@"password"]) {
		result(NO);
		return;
	}
	
    self.loginResult = result;
    
    LoginRequest *request = [LoginRequest new];
    request.requestURI = [URIManager getURIWithType:URITypeQgLogin];
    request.requestMethod = [URIManager getRequestMethodWithType:URITypeQgLogin];
    request.requestParameter = @{
                                 @"name": [[NSUserDefaults standardUserDefaults] stringForKey:@"username"],
                                 @"password": [[NSUserDefaults standardUserDefaults] stringForKey:@"password"]
                                 };
    request.delegate = self;
    [request start];
}

- (BOOL)getButtonEnableByCurrentTF:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string tfArr:(NSArray *)tfArr;{
    if (string.length) {// 文本增加
        NSMutableArray *newTFs = [NSMutableArray arrayWithArray:tfArr];
        [newTFs removeObject:textField];
        for (UITextField *tempTF in newTFs) {
            if (tempTF.text.length==0) return NO;
        }
    }else{// 文本删除
        if (textField.text.length-range.length==0) {// 当前TF文本被删完
            return NO;
        }else{
            NSMutableArray *newTFs = [NSMutableArray arrayWithArray:tfArr];
            [newTFs removeObject:textField];
            for (UITextField *tempTF in newTFs) {
                if (tempTF.text.length==0) return NO;
            }
        }
    }
    return YES;
}

#pragma mark - YBResponseDelegate -

- (void)request:(__kindof YBBaseRequest *)request successWithResponse:(YBNetworkResponse *)response {
    LoginResponseModel *loginResponse = [LoginResponseModel yy_modelWithDictionary:response.responseObject];
    if (loginResponse.code == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:loginResponse.model.token forKey:@"token"];
        [[NSUserDefaults standardUserDefaults] setObject:self.usernameField.text forKey:@"username"];
        [[NSUserDefaults standardUserDefaults] setObject:self.passwordField.text forKey:@"password"];
        [[NSUserDefaults standardUserDefaults] synchronize];
		NSDictionary *paras = @{
								@"token": [[NSUserDefaults standardUserDefaults] stringForKey:@"token"]
								};
		
		QGRequest *request = [[QGRequest alloc] initWithType:URITypeQgUserInfo paras:paras];
		[request startWithSuccess:^(YBNetworkResponse * _Nonnull response) {
			UserInfoResponseModel *responseModel = [UserInfoResponseModel yy_modelWithDictionary:response.responseObject];
			BooksViewController *bookVC = [[BooksViewController alloc] init];
			bookVC.user = responseModel.model.data;
			[[NSUserDefaults standardUserDefaults] setObject:responseModel.model.data.userid forKey:@"account_id"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			NavigationController *navc = [[NavigationController alloc] initWithRootViewController:bookVC];
			
			if (self.loginResult) {
				self.loginResult(YES);
				self.loginResult = nil;
			}
			
			[UIApplication sharedApplication].delegate.window.rootViewController = navc;
		} failure:^(YBNetworkResponse * _Nonnull response) {
			if (self.loginResult) {
				self.loginResult(NO);
				self.loginResult = nil;
			}
		}];
		
        if (self.loginResult) {
            self.loginResult(YES);
            self.loginResult = nil;
        }
    } else {
        if (self.loginResult) {
            self.loginResult(NO);
            self.loginResult = nil;
        }
        self.tipLabel.text = loginResponse.message;
    }
}

- (void)request:(__kindof YBBaseRequest *)request failureWithResponse:(YBNetworkResponse *)response {
    if (self.loginResult) {
        self.loginResult(NO);
        self.loginResult = nil;
    }
}

#pragma mark - UITextFieldDelegate -

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSArray *tfs = @[self.usernameField,self.passwordField];
    
    if ([self getButtonEnableByCurrentTF:textField shouldChangeCharactersInRange:range replacementString:string tfArr:tfs]) {
        self.loginBtn.enabled = YES;
    } else {
        self.loginBtn.enabled = NO;
    }
    
    return YES;
}

#pragma mark - lazy load -

- (UITextField *)usernameField {
    if (!_usernameField) {
        _usernameField = [[UITextField alloc] init];
        _usernameField.textColor = [UIColor colorWithHexString:@"222222"];
        _usernameField.font = [UIFont systemFontOfSize:14];
        _usernameField.textContentType = UITextContentTypeUsername;
        _usernameField.delegate = self;
        _usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"输入手机号", nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"919191"]}];
        
        UIImageView *leftView = [[UIImageView alloc] init];
        leftView.contentMode = UIViewContentModeScaleAspectFit;
        leftView.image = [UIImage imageNamed:@"login_icon_cellphone"];
        leftView.frame = CGRectMake(0, 0, 50, 20);
        _usernameField.leftView = leftView;
        _usernameField.leftViewMode = UITextFieldViewModeAlways;
    }
    return _usernameField;
}

- (UITextField *)passwordField {
    if (!_passwordField) {
        _passwordField = [[UITextField alloc] init];
        _passwordField.textColor = [UIColor colorWithHexString:@"222222"];
        _passwordField.font = [UIFont systemFontOfSize:14];
        _passwordField.textContentType = UITextContentTypePassword;
        _passwordField.delegate = self;
        _passwordField.secureTextEntry = YES;
        _passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"输入密码", nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"919191"]}];
        
        UIImageView *leftView = [[UIImageView alloc] init];
        leftView.contentMode = UIViewContentModeScaleAspectFit;
        leftView.image = [UIImage imageNamed:@"login_icon_lock"];
        leftView.frame = CGRectMake(0, 0, 50, 20);
        _passwordField.leftView = leftView;
        _passwordField.leftViewMode = UITextFieldViewModeAlways;
        
        self.securityBtn.frame = CGRectMake(0, 0, 50, 20);
        _passwordField.rightView = self.securityBtn;
        _passwordField.rightViewMode = UITextFieldViewModeAlways;
    }
    return _passwordField;
}

- (UIButton *)securityBtn {
    if (!_securityBtn) {
        _securityBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_securityBtn setImage:[UIImage imageNamed:@"login_icon_eye"] forState:UIControlStateNormal];
        [_securityBtn setImage:[UIImage imageNamed:@"login_icon_eye"] forState:UIControlStateSelected];
        [_securityBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _securityBtn;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.textColor = [UIColor colorWithHexString:@"ed6558"];
        _tipLabel.font = [UIFont systemFontOfSize:14];
    }
    return _tipLabel;
}

- (UIButton *)loginBtn {
    if (!_loginBtn) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _loginBtn.layer.cornerRadius = 3;
        _loginBtn.layer.masksToBounds = YES;
        _loginBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _loginBtn.adjustsImageWhenHighlighted = NO;
        [_loginBtn setTitle:NSLocalizedString(@"登录", nil) forState:UIControlStateNormal];
        [_loginBtn setTitleColor:[UIColor colorWithHexString:@"222222"] forState:UIControlStateNormal];
        [_loginBtn setTitleColor:[UIColor colorWithHexString:@"919191"] forState:UIControlStateDisabled];
        [_loginBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = CGRectMake(0, 0, 315, 40);
        gradient.colors = @[(id)[UIColor colorWithHexString:@"ffd450"].CGColor,(id)[UIColor colorWithHexString:@"ffc627"].CGColor];
        gradient.startPoint = CGPointMake(0, 0.5);
        gradient.endPoint = CGPointMake(1, 0.5);
        
        [_loginBtn setBackgroundImage:[gradient snapshotImage] forState:UIControlStateNormal];
        
    }
    return _loginBtn;
}

@end
