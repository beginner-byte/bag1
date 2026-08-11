//
//  NoaMsgReadProgressView.h
//  NoaKit
//
//  Created by Candy on 2026/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaMsgReadProgressView : UIView

//进度
@property(nonatomic, assign) float progress;

//构造方法
- (instancetype)initWithRadius:(CGFloat)radius fillColor:(UIColor *)fillColor;

/* 配置边框颜色和宽度
 @param borderColor 边框颜色
 @param borderWidth 边框宽度
*/
- (void)configBorderWithColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth;


@end

NS_ASSUME_NONNULL_END
