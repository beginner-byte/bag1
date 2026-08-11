//
//  NoaAuthBaseDataHandle.h
//  NoaChatKit
//
//  Created by phl on 2025/11/18.
//

#import <Foundation/Foundation.h>
// MARK:常规参数定义↓
// 账号key
#define kLoginModuleParamAccountKey @"LoginModuleParamAccountKey"
// 手机号码key
#define kLoginModuleParamPhoneNumberKey @"LoginModuleParamPhoneNumberKey"
// 邮箱验证码key
#define kLoginModuleParamEmailKey @"LoginModuleParamEmailKey"
// 密码key
#define kLoginModuleParamPasswordKey @"LoginModuleParamPasswordKey"
// 确认密码key
#define kLoginModuleParamConfirmPasswordKey @"LoginModuleParamConfirmPasswordKey"
// 图文验证码key
#define kLoginModuleParamImgCodeKey @"LoginModuleParamImgCodeKey"
// 登录、注册、重置密码-验证码key
#define kLoginModuleParamVerCodeKey @"LoginModuleParamVerCodeKey"
// 邀请码key
#define kLoginModuleParamInviteCodeKey @"LoginModuleParamInviteCodeKey"
// 密码配合加密密钥key
#define kLoginModuleParamPasswordEncryptKey @"LoginModuleParamPasswordEncryptKey"
// 加密密钥key
#define kLoginModuleParamEncryptKeyKey @"LoginModuleParamEncryptKeyKey"
// MARK:常规参数定义↑

NS_ASSUME_NONNULL_BEGIN

/// 获取输入框文字的回调 block
/// @param loginType 登录类型
/// @return 返回字典，key如下:
/// 账号密码-kLoginModuleParamAccountKey
/// 手机号码-kLoginModuleParamPhoneNumberKey
/// 邮箱-kLoginModuleParamEmailKey
/// 密码-kLoginModuleParamPasswordKey
/// 确认密码-kLoginModuleParamConfirmPasswordKey
/// 图文验证码-kLoginModuleParamImgCodeKey
/// 登录、注册、重置密码-验证码-kLoginModuleParamVerCodeKey
/// 邀请码-kLoginModuleParamInviteCodeKey
/// 密码配合加密密钥-kLoginModuleParamPasswordEncryptKey
/// 加密密钥-kLoginModuleParamEncryptKeyKey
typedef NSDictionary<NSString *, NSString *> *_Nullable(^GetInputTextBlock)(ZLoginAndRegisterTypeMenu loginType);

/// 认证相关数据处理的基类
/// 提供验证码、加密密钥等通用功能的实现
@interface NoaAuthBaseDataHandle : NSObject

// getEncryptKeyCommand调用时，临时保存中转参数(用于收到加密数据后，进行登录验证)
@property (nonatomic, strong, nullable) NSMutableDictionary *tempParamWhenGetEncrypt;

// MARK: 基本参数

/// 获取输入框文字的回调 block（由 View 层实现）
@property (nonatomic, copy, nullable) GetInputTextBlock getInputTextBlock;

/// 当前登录方式
@property (nonatomic, assign) ZLoginAndRegisterTypeMenu currentLoginTypeMenu;

/// 展示Toast
@property (nonatomic, strong) RACSubject *showToastSubject;

/// 获取图文验证码
@property (nonatomic, strong) RACSubject *showImgVerCodeSubject;

/// 跳转至切换区号页面
@property (nonatomic, strong) RACSubject *jumpChangeAreaCodeSubject;

/// 验证码类型
/// 0:用户名登录
/// 1:注册
/// 2:验证码登录、手机号登录
/// 3:重置密码
@property (nonatomic, assign) NSInteger verCodeType;

// MARK: 请求

/// 获取密钥请求
@property (nonatomic, strong) RACCommand *getEncryptKeyCommand;

/// 获取图文验证码的请求(1. 点击获取手机号码、邮箱验证码的时候 2. 密码输入多次)
@property (nonatomic, strong) RACCommand *getImgVerCommand;

/// 腾讯无痕验证请求
@property (nonatomic, strong) RACCommand *getTencentCaptchaCommand;

/// 阿里无痕验证请求
@property (nonatomic, strong) RACCommand *getAliCaptchaCommand;

/// 图文验证码验证成功后，发送的验证码请求
@property (nonatomic, strong) RACCommand *getVerCommand;

/// 检测用户是否存在
@property (nonatomic, strong) RACCommand *checkUserIsExistCommand;

/// 检测用户是否存在、是否设置了密码
@property (nonatomic, strong) RACCommand *checkUserIsExistAndHadPasswordCommand;

/// 获取图文验证码类型-请求图文验证码时调用
- (NSInteger)getImageCodeType;

/// 获取验证码类型
- (NSInteger)getVerCodeType;

/// 获取是否支持邀请码
- (BOOL)getInviteCodeSupportState;

// MARK: UI输入框信息获取↓
/// 获取当前登录类型的账号输入框文字
- (NSString *)getAccountText;

/// 获取当前登录类型的密码输入框文字
- (NSString *)getPasswordText;

/// 获取当前登录类型的确认密码输入框文字
- (NSString *)getConfirmPasswordText;

/// 获取当前登录类型的验证码输入框文字
- (NSString *)getVerCodeText;

/// 获取当前登录类型的图文验证码输入框文字
- (NSString *)getImgVerCodeText;

/// 获取当前注册类型的邀请码输入框文字
- (NSString *)getInviteCodeText;

/// 获取手机号码区号
- (NSString *)getAreaCode;

/// 修改areaCode
- (void)changeAreaCode:(NSString *)areaCode;

// MARK: UI输入框信息获取↑

/// 展示图文验证码
/// - Parameters:
///   - code: 图文验证码(如果为空，会在图文验证码弹窗页面进行数据请求)
- (void)showImgVerCodePopWindowWithCode:(NSString *)code;

/// 重置sdk验证方式信息
- (void)resetSDKCaptchaChannel;

/// 根据登录方式，将其转换为接口要求的对应的数字
/// - Parameter loginTypeMenu: 登录类型
- (int)covertInterfaceParamWithLoginTypeMenu:(ZLoginAndRegisterTypeMenu)loginTypeMenu;

/// 检查注册账号、手机号、邮箱合法性
/// - Parameters:
///   - registerType: 注册类型
///   - accountInputString: 账号、手机号、邮箱号
///   - resultFunc: 回调: res-是否通过，errorText-错误文案
+ (void)checkAccountInputWithRegisterType:(ZLoginAndRegisterTypeMenu)registerType
                             AccountInput:(NSString * _Nullable)accountInputString
                           WhenEditFinish:(void(^)(BOOL res,  NSString * _Nullable errorText))resultFunc;

/// 检查密码合法性
/// - Parameters:
///   - registerType: 注册类型
///   - passwordInputString: 密码
///   - resultFunc: 回调: res-是否通过，errorText-错误文案
+ (void)checkPasswordInputWithRegisterType:(ZLoginAndRegisterTypeMenu)registerType
                             PasswordInput:(NSString * _Nullable)passwordInputString
                            WhenEditFinish:(void(^)(BOOL res,  NSString * _Nullable errorText))resultFunc;

/// 检查确认密码合法性
/// - Parameters:
///   - registerType: 注册类型
///   - PasswordInput: 密码
///   - ConfirmPasswordInput: 确认密码
///   - resultFunc: 回调: res-是否通过，errorText-错误文案
+ (void)checkConfirmPasswordInputWithRegisterType:(ZLoginAndRegisterTypeMenu)registerType
                                    PasswordInput:(NSString * _Nullable)passwordInputString
                             ConfirmPasswordInput:(NSString * _Nullable)confirmPasswordInputString
                                   WhenEditFinish:(void(^)(BOOL res,  NSString * _Nullable errorText))resultFunc;

/// 检查验证码合法性
/// - Parameters:
///   - registerType: 注册类型
///   - verCodeInputString: 验证码
///   - resultFunc: 回调: res-是否通过，errorText-错误文案
+ (void)checkVerCodeInputWithRegisterType:(ZLoginAndRegisterTypeMenu)registerType
                             VerCodeInput:(NSString * _Nullable)verCodeInputString
                           WhenEditFinish:(void(^)(BOOL res,  NSString * _Nullable errorText))resultFunc;

/// 检查邀请码合法性
/// - Parameters:
///   - registerType: 注册类型
///   - inviteCodeInputString: 邀请码
///   - resultFunc: 回调: res-是否通过，errorText-错误文案
+ (void)checkInviteCodeInputWithRegisterType:(ZLoginAndRegisterTypeMenu)registerType
                             InviteCodeInput:(NSString * _Nullable)inviteCodeInputString
                              WhenEditFinish:(void(^)(BOOL res,  NSString * _Nullable errorText))resultFunc;

/// 发送用户查询是否存在时，检测用户是否存在参数是否合规
- (BOOL)checkUserParamIsAvaliable;

/// 获取验证码时，检测手机号码、邮箱号码是否合规
- (BOOL)checkGetVerCodeParamIsAvaliable;

@end

NS_ASSUME_NONNULL_END

