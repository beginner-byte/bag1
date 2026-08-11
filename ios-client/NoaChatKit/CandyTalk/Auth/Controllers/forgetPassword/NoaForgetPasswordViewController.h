//
//  NoaForgetPasswordViewController.h
//  NoaChatKit
//
//  Created by phl on 2025/11/17.
//

#import "NoaRegisterAccountAndForgetPasswordBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaForgetPasswordViewController : NoaRegisterAccountAndForgetPasswordBaseViewController

/// 手机重置账号 - 区号
@property (nonatomic, copy, readwrite) NSString *areaCode;

/// 重置账号的类型
@property (nonatomic, assign, readwrite) ZLoginAndRegisterTypeMenu currentResetPasswordType;

/// 登录页面传入的的账号
@property (nonatomic, copy, readwrite) NSString *resetAccount;

@end

NS_ASSUME_NONNULL_END
