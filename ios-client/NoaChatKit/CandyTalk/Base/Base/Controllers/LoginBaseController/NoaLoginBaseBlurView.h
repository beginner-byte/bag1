//
//  NoaLoginBaseBlurView.h
//  NoaChatKit
//
//  Created by phl on 2025/11/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaLoginBaseBlurView : UIView

/// 初始化页面
/// - Parameters:
///   - frame: frame
///   - isPopWindows: 是否是弹窗形式
- (instancetype)initWithFrame:(CGRect)frame
                 IsPopWindows:(BOOL)isPopWindows;

/// 是否是悬浮弹窗
@property (nonatomic, assign, readonly) BOOL isPopWindows;

/// 根据文本计算长度
/// - Parameters:
///   - text: 展示的文字
///   - font: 文字大小
- (CGFloat)calculateButtonWidthForText:(NSString *)text font:(UIFont *)font;

@end

NS_ASSUME_NONNULL_END
