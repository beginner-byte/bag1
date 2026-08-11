//
//  NoaMyMiniAppView.h
//  NoaKit
//
//  Created by Candy on 2023/7/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT const CGFloat kNoaMyMiniAppPanelHeight;

@interface NoaMyMiniAppView : UIView

/// 内嵌在顶部栏下方使用（非全屏弹层）
+ (instancetype)embeddedMiniAppView;

@property (nonatomic, copy, nullable) void (^onEmbeddedDismiss)(void);

- (void)myMiniAppShow;
- (void)myMiniAppDismiss;

@end

NS_ASSUME_NONNULL_END
