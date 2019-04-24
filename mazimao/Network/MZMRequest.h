//
//  MZMRequest.h
//  mazimao
//
//  Created by wuhan006 on 2019/4/22.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "YBBaseRequest.h"
#import "URIManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface MZMRequest : YBBaseRequest

- (instancetype)initWithType:(URIType)type paras:(NSDictionary *)paras ;
- (instancetype)initWithYype:(URIType)type paras:(NSDictionary *)paras  delegate:(id<YBResponseDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
