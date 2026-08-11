//
//  UIColor+Addition.h
//  NoaKit
//
//  Created by Candy on 2026/8/30.
//


#define HEXCOLOR(h) [UIColor colorWithHexStr:h]
#define HEXACOLOR(h,a) [UIColor colorWithHexStr:h alpha:(a)]
#define RGB(h) [UIColor colorWithRGB:h]
#define RGBA(h,a) [UIColor colorWithRGB:h alpha:a]

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Addition)

#pragma mark - 随机色
+ (UIColor *)randomColor;
#pragma mark - 16进制色
+ (UIColor *)colorWithHexStr:(NSString *)hexStr;
+ (UIColor *)colorWithHexStr:(NSString *)hexStr alpha:(CGFloat)alpha;
#pragma mark - RGB色
+ (UIColor *)colorWithRGB:(NSInteger)rgb;
+ (UIColor *)colorWithRGB:(NSInteger)rgb alpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END
