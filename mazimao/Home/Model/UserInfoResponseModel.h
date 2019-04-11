//
//  UserInfoResponseModel.h
//  mazimao
//
//  Created by wuhan006 on 2019/4/11.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FullAddress :NSObject <YYModel>
@property (nonatomic, copy) NSString *addressid;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *district;
@property (nonatomic , copy) NSString              * details;
@end


@interface FullBankAddress :NSObject
@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *city;
@property (nonatomic , copy) NSString              * details;

@end


@interface User :NSObject <YYModel>
@property (nonatomic , copy) NSString              * userid;
@property (nonatomic , copy) NSString              * mobilenumber;
@property (nonatomic , copy) NSString              * penname;
@property (nonatomic , copy) NSString              * email;
@property (nonatomic , copy) NSString              * qq;
@property (nonatomic , copy) NSString              * address;
@property (nonatomic , copy) NSString              * name;
@property (nonatomic , copy) NSString              * idcard;
@property (nonatomic , copy) NSString              * bank_card;
@property (nonatomic , copy) NSString              * bank_name;
@property (nonatomic , copy) NSString              * bank_address;
@property (nonatomic , copy) NSString              * zipCode;
@property (nonatomic , copy) NSString              * faceIDCardImg;
@property (nonatomic , copy) NSString              * rearIDCardImg;
@property (nonatomic , copy) NSString              * bankCardImg;
@property (nonatomic , copy) NSString              * faceIDCardImgUrl;
@property (nonatomic , copy) NSString              * rearIDCardImgUrl;
@property (nonatomic , copy) NSString              * bankCardImgUrl;
@property (nonatomic , copy) NSString              * workUnit;
@property (nonatomic , copy) NSString              * fixedTelephone;
@property (nonatomic , copy) NSString              * gender;
@property (nonatomic , copy) NSString              * image;
@property (nonatomic, copy) NSString *signCellPhoneNum;
@property (nonatomic , strong) FullAddress              * fullAddress;
@property (nonatomic , strong) FullBankAddress              * fullBankAddress;

@end


@interface UserInfoModel :NSObject
@property (nonatomic , strong) User              * data;

@end


@interface UserInfoResponseModel :NSObject
@property (nonatomic , assign) NSInteger              code;
@property (nonatomic , strong) UserInfoModel              * model;
@property (nonatomic, copy) NSString *message;
@end

NS_ASSUME_NONNULL_END
