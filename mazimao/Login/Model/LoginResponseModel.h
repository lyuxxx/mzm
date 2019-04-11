//
//  LoginResponseModel.h
//  mazimao
//
//  Created by wuhan006 on 2019/4/11.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FullAddress :NSObject

@end


@interface FullBankAddress :NSObject

@end


@interface User :NSObject <YYModel>
@property (nonatomic , copy) NSString              * userid;
@property (nonatomic , copy) NSString              * mobilenumber;
@property (nonatomic , copy) NSString              * penname;
@property (nonatomic , copy) NSString              * email;
@property (nonatomic , copy) NSString              * qq;
@property (nonatomic , strong) FullAddress              * fullAddress;
@property (nonatomic , strong) FullBankAddress              * fullBankAddress;

@end


@interface LoginModel :NSObject
@property (nonatomic , strong) User              * user;
@property (nonatomic , copy) NSString              * token;

@end


@interface LoginResponseModel :NSObject
@property (nonatomic , assign) NSInteger              code;
@property (nonatomic , strong) LoginModel              * model;
@property (nonatomic, copy) NSString *message;

@end

NS_ASSUME_NONNULL_END
