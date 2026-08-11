//
//  NoaLoginBaseInputView.h
//  NoaChatKit
//
//  Created by phl on 2025/11/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 点击了刷新验证码按钮
typedef void(^ClickRefreshVerificationCodeBtnAction)(void);

/// 登录输入视图基类
@interface NoaLoginBaseInputView : UIView<UITextFieldDelegate>

/// 设置UI（子类需要调用 super 并实现自己的第一个输入框）
- (void)setupUI;

/// 处理数据（子类需要调用 super）
- (void)processData;

/// 点击了切换验证码按钮
@property (nonatomic, copy) ClickRefreshVerificationCodeBtnAction clickRefreshVerificationCodeBtnAction;

/// 输入验证结果信号（发送 BOOL 值，YES 表示验证通过，NO 表示验证失败）
@property (nonatomic, strong, readonly) RACSubject<NSNumber *> *validationResultSignal;

/// 手动触发验证（用于切换登录类型时立即更新按钮状态）
- (void)triggerValidation;

/// 获取密码输入框文字
- (NSString *)getPasswordText;

/// 获取验证码输入框文字
- (NSString *)getCodeText;

/// 是否展示图文验证码
@property (nonatomic, assign) BOOL isNeedShowImageCode;

/// 子类需要实现：获取第一个输入框的文本（账号/邮箱/手机号）
- (NSString *)getFirstInputText;

/// 子类需要实现：获取第一个输入框（用于约束布局）
- (UIView *)getFirstInputView;

/// 子类需要实现：设置第一个输入框的文本信号（用于验证）
- (RACSignal<NSString *> *)getFirstInputTextSignal;

/// 图文验证码展示的文字
@property (nonatomic, copy) NSString *imageCodeText;

@end

NS_ASSUME_NONNULL_END



