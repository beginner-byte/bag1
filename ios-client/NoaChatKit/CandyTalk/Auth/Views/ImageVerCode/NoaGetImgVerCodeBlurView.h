//
//  NoaGetImgVerCodeBlurView.h
//  NoaChatKit
//
//  Created by phl on 2025/11/14.
//

#import "NoaLoginBaseBlurView.h"

NS_ASSUME_NONNULL_BEGIN

@class NoaGetImgVerCodeBlurDataHandle;

@interface NoaGetImgVerCodeBlurView : NoaLoginBaseBlurView

/// 初始化页面
/// - Parameters:
///   - frame: frame
///   - isPopWindows: 是否是弹窗形式
///   - dataHandle: 数据处理
- (instancetype)initWithFrame:(CGRect)frame
                 IsPopWindows:(BOOL)isPopWindows
                   DataHandle:(NoaGetImgVerCodeBlurDataHandle *)dataHandle;

@end

NS_ASSUME_NONNULL_END
