//
//  NoaRegisterBaseInputView.h
//  NoaChatKit
//
//  Created by phl on 2025/11/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 获取验证码点击事件
typedef void(^GetVerCodeActionBlock)(void);

@interface NoaRegisterBaseInputView : UIView<UITextFieldDelegate>

/// 设置验证码视图约束（子类可重写以自定义）
- (void)setupCodeViewConstraints;

/// 设置密码输入框约束（子类可重写以自定义）
- (void)setupPasswordTextFieldConstraints;

/// 设置确认密码输入框约束（子类可重写以自定义）
- (void)setupConfirmPasswordTextFieldConstraints;

/// 设置邀请码输入框约束（子类可重写以自定义）
- (void)setupInviteTextFieldConstraints;

/// 设置UI（子类需要调用 super 并实现自己的第一个输入框）
- (void)setupUI;

/// 处理数据（子类需要调用 super）
- (void)processData;

/// 输入验证结果信号（发送 BOOL 值，YES 表示验证通过，NO 表示验证失败）
@property (nonatomic, strong, readonly) RACSubject<NSNumber *> *validationResultSignal;

/// 手动触发验证（用于切换登录类型时立即更新按钮状态）
- (void)triggerValidation;

/// 获取密码输入框文字
- (NSString *)getPasswordText;

/// 获取确认密码输入框文字
- (NSString *)getConfirmPasswordText;

/// 获取验证码输入框文字
- (NSString *)getCodeText;

/// 获取邀请码输入框文字
- (NSString *)getInviteText;

/// 子类需要实现：获取第一个输入框的文本（账号/邮箱/手机号）
- (NSString *)getFirstInputText;

/// 子类需要实现：获取第一个输入框（用于约束布局）
- (UIView *)getFirstInputView;

/// 子类需要实现：设置第一个输入框的文本信号（用于验证）
- (RACSignal<NSString *> *)getFirstInputTextSignal;

/// 获取验证码点击事件
@property (nonatomic, copy) GetVerCodeActionBlock getVerCodeActionBlock;

/// 是否支持邀请码
@property (nonatomic, assign) BOOL isSupportInviteCode;

/// 是否支持验证码
@property (nonatomic, assign) BOOL isSupportVerCode;

/// 开启获取验证码按钮倒计时展示
- (void)startVerCodeCountDown;

/// 初始化方法
/// - Parameters:
///   - frame: frame
///   - currentRegisterWay: 当前注册方式
- (instancetype)initWithFrame:(CGRect)frame
           CurrentRegisterWay:(ZLoginAndRegisterTypeMenu)currentRegisterWay;

@end

NS_ASSUME_NONNULL_END
