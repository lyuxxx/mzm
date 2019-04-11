//
//  NavigationController.m
//  mazimao
//
//  Created by wuhan006 on 2019/4/10.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "NavigationController.h"

@interface NavigationController ()

@end

@implementation NavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationBar.tintColor = [UIColor colorWithHexString:@"222222"];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"222222"],NSFontAttributeName:[UIFont systemFontOfSize:16]};
    [self.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    //todo:设置阴影
}


@end
