//
//  NoaLoginBaseViewController.h
//  NoaChatKit
//
//  Created by phl on 2025/11/4.
//

#import "CandyBaseViewController.h"
#import "NoaLoginBaseBlurView.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaLoginBaseViewController : CandyBaseViewController

/// 上方标题
@property (nonatomic, strong, readonly) UILabel *topTitleLabel;

/// 上方小标题
@property (nonatomic, strong, readonly) UILabel *topSubTitleLabel;

/// 高斯模糊view
@property (nonatomic, strong, readonly) NoaLoginBaseBlurView *blurView;

/// 设置网络按钮点击事件（当前类实现通用，有差异子类重写实现）
- (void)clickNetworkSetAction;

/// 设置系统语言点击事件（当前类实现通用，有差异子类重写实现）
- (void)clickSystemLanguage;

/// 设置邀请码点击事件（当前类未实现，子类重写实现）
- (void)clickSetSsoAccount;

/// 是否展示左上角网络设置、系统语言
/// - Parameter isShow: 是否展示
- (void)showNetworkDetectionAndSystemLanguageButton:(BOOL)isShow;

/// 是否展示邀请码设置按钮
/// - Parameter isShow: 首付展示
- (void)showSsoAccountSetButton:(BOOL)isShow;

@end

NS_ASSUME_NONNULL_END
