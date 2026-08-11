//
//  NoaLoginAccountInputView.h
//  NoaChatKit
//
//  Created by phl on 2025/11/7.
//

#import "NoaLoginBaseInputView.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaLoginAccountInputView : NoaLoginBaseInputView

/// 输入验证结果信号（发送 BOOL 值，YES 表示验证通过，NO 表示验证失败）
@property (nonatomic, strong, readonly) RACSubject<NSNumber *> *accountValidationResultSignal;

/// 获取账号输入框文字
- (NSString *)getAccountText;

@end

NS_ASSUME_NONNULL_END
