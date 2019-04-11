//
//  LoginResponseModel.h
//  mazimao
//
//  Created by wuhan006 on 2019/4/11.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LoginModel :NSObject
@property (nonatomic , copy) NSString              * token;

@end


@interface LoginResponseModel :NSObject
@property (nonatomic , assign) NSInteger              code;
@property (nonatomic , strong) LoginModel              * model;
@property (nonatomic, copy) NSString *message;

@end

NS_ASSUME_NONNULL_END
