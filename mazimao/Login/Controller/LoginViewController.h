//
//  LoginViewController.h
//  mazimao
//
//  Created by wuhan006 on 2019/4/11.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^LoginResult)(BOOL result);

NS_ASSUME_NONNULL_BEGIN

@interface LoginViewController : BaseViewController
- (void)autoLoginWithResult:(LoginResult)result;
@end

NS_ASSUME_NONNULL_END
