//
//  NoaDrawerPresentationController.h
//  NoaKit
//
//  Created by AI on 2025/11/05.
//

#import <UIKit/UIKit.h>

@interface NoaDrawerPresentationController : UIPresentationController

/// 内容宽度比例，默认 0.8
@property (nonatomic, assign) CGFloat contentWidthRatio;
/// 遮罩颜色（建议使用动态色）
@property (nonatomic, strong) UIColor *dimmingColor;
/// 动画时长参考（非强约束）
@property (nonatomic, assign) NSTimeInterval preferredDuration;

/// 动态更新抽屉内容宽度比例（0~1），支持动画
- (void)updateContentWidthRatio:(CGFloat)ratio animated:(BOOL)animated;

/// 动态更新抽屉内容宽度比例（0~1），支持动画与完成回调
- (void)updateContentWidthRatio:(CGFloat)ratio animated:(BOOL)animated completion:(void (^ __nullable)(void))completion;

@end


