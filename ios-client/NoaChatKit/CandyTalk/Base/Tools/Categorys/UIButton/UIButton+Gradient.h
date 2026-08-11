//
//  UIButton+Gradient.h
//  NoaSNewsMedia
//
//  Created by 郑开 on 2023/3/20.
//  Copyright © 2023 HNZS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (Gradient)

//图片在上
- (void)setIconInTopWithSpacing:(CGFloat)Spacing;
//图片在左
- (void)setIconInLeftWithSpacing:(CGFloat)Spacing;
//图片在右
- (void)setIconInRightWithSpacing:(CGFloat)Spacing;
//图片在下
- (void)setIconInBottomWithSpacing:(CGFloat)Spacing;

@end

NS_ASSUME_NONNULL_END
