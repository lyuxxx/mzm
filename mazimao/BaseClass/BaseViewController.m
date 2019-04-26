//
//  BaseViewController.m
//  mazimao
//
//  Created by wuhan006 on 2019/4/10.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "BaseViewController.h"

@implementation NavigationItemCustomView

- (UIEdgeInsets)alignmentRectInsets {
	if (UIEdgeInsetsEqualToEdgeInsets(self.alignmentRectInsetsOverride, UIEdgeInsetsZero)) {
		return super.alignmentRectInsets;
	} else {
		return self.alignmentRectInsetsOverride;
	}
}

@end

@interface BaseViewController () <UIGestureRecognizerDelegate>

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
    //主要是以下两个图片设置
    self.navigationController.navigationBar.backIndicatorImage = [UIImage imageNamed:@"set_icon_back"];
    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = [UIImage imageNamed:@"set_icon_back"];
    self.navigationItem.backBarButtonItem = backItem;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

@end
