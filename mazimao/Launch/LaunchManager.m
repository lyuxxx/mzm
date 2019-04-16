//
//  LaunchManager.m
//  mazimao
//
//  Created by wuhan006 on 2019/4/16.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "LaunchManager.h"
#import "LoginViewController.h"

@implementation LaunchManager

{
    UIWindow *_loginWindow;
}

+ (void)load {
    [self sharedManager];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)sharedManager {
    static LaunchManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LaunchManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [self setup];
        }];
    }
    return self;
}

- (void)setup {
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.rootViewController = [UIViewController new];
    window.rootViewController.view.backgroundColor = [UIColor clearColor];
    window.rootViewController.view.userInteractionEnabled = NO;
    window.windowLevel = UIWindowLevelStatusBar + 1;
    window.hidden = NO;
    window.alpha = 1;
    _loginWindow = window;
    [window addSubview:[self imageViewFromLaunchScreen]];
    
    LoginViewController *loginVC = (LoginViewController *)(((UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController).topViewController);
    
    weakifySelf
    [loginVC autoLoginWithResult:^(BOOL result) {
        
        //登录操作完成,移除loginWindow
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            strongifySelf
             
            [self->_loginWindow.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if (obj) {
                    [obj removeFromSuperview];
                    obj = nil;
                }
                
            }];
            self->_loginWindow.hidden = YES;
            self->_loginWindow = nil;
        });
        
    }];
}

- (UIImageView *)imageViewFromLaunchScreen {
    UIImageView *imgV = [[UIImageView alloc] init];
    imgV.frame = [UIScreen mainScreen].bounds;
    imgV.image = [self imageFromLaunchScreen];
    return imgV;
}

- (UIImage *)imageFromLaunchScreen {
    NSString *UILaunchStoryboardName = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchStoryboardName"];
    if(UILaunchStoryboardName == nil){
        return nil;
    }
    UIViewController *LaunchScreenSb = [[UIStoryboard storyboardWithName:UILaunchStoryboardName bundle:nil] instantiateInitialViewController];
    if(LaunchScreenSb){
        UIView * view = LaunchScreenSb.view;
        view.frame = [UIScreen mainScreen].bounds;
        UIImage *image = [self imageFromView:view];
        return image;
    }
    return nil;
}

- (UIImage *)imageFromView:(UIView *)view {
    CGSize size = view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
