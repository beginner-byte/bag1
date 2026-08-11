//
//  NoaFixedSizeRightView.h
//  NoaChatKit
//
//  Created by phl on 2025/11/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 固定宽高的容器 View（用于 UITextField 的 rightView）
/// 解决 UITextField 的 rightView 被拉伸的问题
@interface NoaFixedSizeRightView : UIView

/// 固定尺寸（宽度和高度）
@property (nonatomic, assign) CGSize fixedSize;

/// 便捷初始化方法
/// @param size 固定尺寸
- (instancetype)initWithFixedSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END

