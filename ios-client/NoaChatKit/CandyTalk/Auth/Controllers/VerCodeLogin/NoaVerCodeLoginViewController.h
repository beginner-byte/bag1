//
//  NoaVerCodeLoginViewController.h
//  NoaChatKit
//
//  Created by phl on 2025/11/17.
//

#import "NoaRegisterAccountAndForgetPasswordBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaVerCodeLoginViewController : NoaRegisterAccountAndForgetPasswordBaseViewController

/// 手机验证码登录 - 区号
@property (nonatomic, copy, readwrite) NSString *areaCode;

/// 验证码登录的类型
@property (nonatomic, assign, readwrite) ZLoginAndRegisterTypeMenu currentVerCodeLoginType;

/// 登录页面传入的的账号
@property (nonatomic, copy, readwrite) NSString *loginAccount;

@end

NS_ASSUME_NONNULL_END
