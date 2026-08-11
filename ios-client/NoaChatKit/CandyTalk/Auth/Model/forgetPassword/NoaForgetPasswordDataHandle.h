//
//  NoaForgetPasswordDataHandle.h
//  NoaChatKit
//
//  Created by phl on 2025/11/17.
//

#import "NoaAuthBaseDataHandle.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaForgetPasswordDataHandle : NoaAuthBaseDataHandle

/// 获取验证码成功，开启倒计时
@property (nonatomic, strong) RACSubject *startVerCodeCountDownSubject;

/// 标题
@property (nonatomic, copy, readonly) NSString *title;

/// 上个页面传入的用户在账号页面输入的账号，只进行绘制UI时的回显，不用来处理业务
@property (nonatomic, copy, readonly) NSString *resetAccount;

/// 初始化找回密码数据处理
/// - Parameters:
///   - currentForgetPasswordWay: 当前用户选择的找回密码方式
///   - areaCode: 手机号找回密码时的区号
///   - resetAccount: 登录页面传入的重置密码账号(可为空)
- (instancetype)initWithResetPasswordWay:(ZLoginAndRegisterTypeMenu)currentForgetPasswordWay
                                AreaCode:(NSString *)areaCode
                            ResetAccount:(NSString * _Nullable)resetAccount;

/// 找回密码并登录
@property (nonatomic, strong) RACCommand *resetPasswordAndLoginCommand;

/// 找回密码时，检测参数是否合规
- (BOOL)checkParamIsAvaliable;

/// 获取验证码接口参数
/// - Parameters:
///   - imgVerCode: 图文验证码，若未开启为空
///   - ticket: 腾讯验证回参，若未开启为空
///   - randstr: 腾讯验证码回参，若未开启为空
///   - captchaVerifyParam: 阿里验证码回参，若未开启为空
- (NSDictionary *)getVerCodeParamWithImgCode:(NSString *)imgVerCode
                                      Ticket:(NSString *)ticket
                                     Randstr:(NSString *)randstr
                          CaptchaVerifyParam:(NSString *)captchaVerifyParam;

@end

NS_ASSUME_NONNULL_END
