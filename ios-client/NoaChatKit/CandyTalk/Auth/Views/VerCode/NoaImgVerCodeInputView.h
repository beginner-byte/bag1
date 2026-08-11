//
//  NoaImgVerCodeInputView.h
//  NoaKit
//
//  Created by Candy on 2026/9/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaImgVerCodeInputView : UIView

@property (nonatomic, copy) NSString *loginName;
@property (nonatomic, assign) NSInteger verCodeType;    //验证码类型，0:用户名登录，1:手机号注册 2:手机号登录 3:手机号找回密码

@property (nonatomic, copy)NSString *imgCodeStr;
@property (nonatomic, strong)UITextField *imgCodeInput;
- (void)getImgCodeAction;
@end

NS_ASSUME_NONNULL_END
