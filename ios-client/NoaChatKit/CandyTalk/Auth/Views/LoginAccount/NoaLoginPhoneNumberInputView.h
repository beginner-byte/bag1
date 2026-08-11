//
//  NoaLoginPhoneNumberInputView.h
//  NoaChatKit
//
//  Created by phl on 2025/11/7.
//

#import "NoaLoginBaseInputView.h"

NS_ASSUME_NONNULL_BEGIN

/// 点击了切换区域按钮
typedef void(^ClickChangeAreaCodeBtnAction)(void);

@interface NoaLoginPhoneNumberInputView : NoaLoginBaseInputView

/// 点击了切换区域按钮
@property (nonatomic, copy) ClickChangeAreaCodeBtnAction clickChangeAreaCodeBtnAction;

/// 输入验证结果信号（发送 BOOL 值，YES 表示验证通过，NO 表示验证失败）
@property (nonatomic, strong, readonly) RACSubject<NSNumber *> *phoneNumberValidationResultSignal;

/// 刷新区号
/// - Parameter areaCode: 最新设置的区号
- (void)refreshAreaCode:(NSString *)areaCode;

/// 获取手机号输入框文字
- (NSString *)getPhoneNumberText;

@end

NS_ASSUME_NONNULL_END
