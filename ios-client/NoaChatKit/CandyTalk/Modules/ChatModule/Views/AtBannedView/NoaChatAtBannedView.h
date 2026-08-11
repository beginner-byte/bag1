//
//  NoaChatAtBannedView.h
//  NoaKit
//
//  Created by Candy on 2025/7/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaChatAtBannedView : UIView

@property (nonatomic, copy) NSString *userName;

/// @用户消息回调
@property (nonatomic, copy) void(^atCallback)(void);

/// 禁言消息回调
@property (nonatomic, copy) void(^bannedCallback)(void);

/// 清除用户消息回调
@property (nonatomic, copy) void(^cleanUserMessageCallback)(void);

- (void)showWithTargetRect:(CGRect)targetRect;
@end

NS_ASSUME_NONNULL_END
