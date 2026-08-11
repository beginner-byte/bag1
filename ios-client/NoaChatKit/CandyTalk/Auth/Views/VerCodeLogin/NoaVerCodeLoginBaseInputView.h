//
//  NoaVerCodeLoginBaseInputView.h
//  NoaChatKit
//
//  Created by phl on 2025/11/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 获取验证码点击事件
typedef void(^GetVerCodeActionBlock)(void);

@interface NoaVerCodeLoginBaseInputView : UIView<UITextFieldDelegate>

/// 设置验证码视图约束（子类可重写以自定义）
- (void)setupCodeViewConstraints;

/// 设置UI（子类需要调用 super 并实现自己的第一个输入框）
- (void)setupUI;

/// 处理数据（子类需要调用 super）
- (void)processData;

/// 输入验证结果信号（发送 BOOL 值，YES 表示验证通过，NO 表示验证失败）
@property (nonatomic, strong, readonly) RACSubject<NSNumber *> *validationResultSignal;

/// 手动触发验证（用于切换登录类型时立即更新按钮状态）
- (void)triggerValidation;

/// 获取验证码输入框文字
- (NSString *)getCodeText;

/// 子类需要实现：获取第一个输入框的文本（邮箱/手机号）- 账号目前暂不支持验证码登录
- (NSString *)getFirstInputText;

/// 子类需要实现：获取第一个输入框（用于约束布局）
- (UIView *)getFirstInputView;

/// 子类需要实现：设置第一个输入框的文本信号（用于验证）
- (RACSignal<NSString *> *)getFirstInputTextSignal;

/// 获取验证码点击事件
@property (nonatomic, copy) GetVerCodeActionBlock getVerCodeActionBlock;

/// 开启获取验证码按钮倒计时展示
- (void)startVerCodeCountDown;

/// 初始化方法
/// - Parameters:
///   - frame: frame
///   - currentLoginWay: 当前登录方式
- (instancetype)initWithFrame:(CGRect)frame
              CurrentLoginWay:(ZLoginAndRegisterTypeMenu)currentLoginWay;

@end

NS_ASSUME_NONNULL_END
