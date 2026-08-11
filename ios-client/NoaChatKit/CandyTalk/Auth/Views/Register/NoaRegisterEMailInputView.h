//
//  NoaRegisterEMailInputView.h
//  NoaChatKit
//
//  Created by phl on 2025/11/13.
//

#import "NoaRegisterBaseInputView.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaRegisterEMailInputView : NoaRegisterBaseInputView

/// 输入验证结果信号（发送 BOOL 值，YES 表示验证通过，NO 表示验证失败）
@property (nonatomic, strong, readonly) RACSubject<NSNumber *> *emailValidationResultSignal;

/// 获取邮箱输入框文字
- (NSString *)getEmailText;

/// 展示上个页面输入的邮箱账号
/// - Parameter eMail: 上个页面传入的邮箱地址
- (void)showPrepareEmail:(NSString *)eMail;

@end

NS_ASSUME_NONNULL_END
