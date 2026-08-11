//
//  NoaRegisterAccountInputView.h
//  NoaChatKit
//
//  Created by phl on 2025/11/13.
//

#import "NoaRegisterBaseInputView.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaRegisterAccountInputView : NoaRegisterBaseInputView

/// 输入验证结果信号（发送 BOOL 值，YES 表示验证通过，NO 表示验证失败）
@property (nonatomic, strong, readonly) RACSubject<NSNumber *> *accountValidationResultSignal;

/// 获取账号输入框文字
- (NSString *)getAccountText;

/// 展示上个页面输入的账号
/// - Parameter account: 上个页面传入的账号
- (void)showPrepareAccount:(NSString *)account;

@end

NS_ASSUME_NONNULL_END
