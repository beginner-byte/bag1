//
//  NoaRegisterDataHandle.h
//  NoaChatKit
//
//  Created by phl on 2025/11/12.
//

#import "NoaAuthBaseDataHandle.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaRegisterDataHandle : NoaAuthBaseDataHandle

/// 已有账号，返回登录页面
@property (nonatomic, strong) RACSubject *popLoginVCSubject;

/// 获取验证码成功，开启倒计时
@property (nonatomic, strong) RACSubject *startVerCodeCountDownSubject;

/// 标题
@property (nonatomic, strong, readonly) NSArray *titleArr;

/// 登录页面传入的未注册的账号
@property (nonatomic, copy, readonly) NSString *unRegisterAccount;

/// 初始化注册数据处理
/// - Parameters:
///   - currentRegisterWay: 当前用户选择的注册方式
///   - areaCode: 手机号注册时的区号
///   - unusedAccount: 登录页面传入的未注册的账号
- (instancetype)initWithRegisterWay:(ZLoginAndRegisterTypeMenu)currentRegisterWay
                           AreaCode:(NSString *)areaCode
                      UnRegisterAccount:(NSString *)unusedAccount;

/// 注册并登录
@property (nonatomic, strong) RACCommand *registerAndLoginCommand;

/// 注册时，检测参数是否合规
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
