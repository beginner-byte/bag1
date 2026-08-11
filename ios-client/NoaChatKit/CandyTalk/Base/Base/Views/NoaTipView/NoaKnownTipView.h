//
//  NoaKnownTipView.h
//  NoaKit
//
//  Created by Candy on 2026/9/13.
//

// 知道了 提示View

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaKnownTipView : UIView
@property (nonatomic, strong) UILabel *lblTip;//提示内容
@property (nonatomic, strong) UIButton *btnKnown;//知道了
@property (nonatomic, copy) void(^btnKnownBlock)(void);   //知道了 按钮Block

- (void)knownTipViewSHow;
- (void)knownTipViewDismiss;
@end

NS_ASSUME_NONNULL_END
