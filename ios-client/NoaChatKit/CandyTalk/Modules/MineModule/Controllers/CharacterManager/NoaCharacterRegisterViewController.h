//
//  NoaCharacterRegisterViewController.h
//  NoaKit
//
//  Created by Candy on 2023/9/15.
//

#import "CandyBaseViewController.h"

@class NoaCharacterManagerViewController;

NS_ASSUME_NONNULL_BEGIN

@interface NoaCharacterRegisterViewController : CandyBaseViewController

@property (nonatomic, assign) BOOL isFromBind;
@property (nonatomic, assign) BOOL isBinded;
//注册登录绑定结果
@property (nonatomic, copy) void(^chartManageBindResult)(BOOL result);

@end

NS_ASSUME_NONNULL_END
