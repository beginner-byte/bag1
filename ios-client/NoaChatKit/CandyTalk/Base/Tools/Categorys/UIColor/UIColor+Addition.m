//
//  UIColor+Addition.m
//  NoaKit
//
//  Created by Candy on 2026/8/30.
//

#import "UIColor+Addition.h"

const CGFloat FLOAT_1_255 = 1.f / 255;

# define RGB2FLOAT(val) ((val) * FLOAT_1_255)
# define FLOAT2RGB(val) ((val) * 255)

# define ARGB_ALPHA(val) (((val) & 0xff000000) >> 24)
# define RGB_RED(val) (((val) & 0xff0000) >> 16)
# define RGB_GREEN(val) (((val) & 0xff00) >> 8)
# define RGB_BLUE(val) ((val) & 0xff)


@implementation UIColor (Addition)

#pragma mark - 随机色
+ (UIColor *)randomColor{
    CGFloat r = (arc4random() % 256) / 255.0;
    CGFloat g = (arc4random() % 256) / 255.0;
    CGFloat b = (arc4random() % 256) / 255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:1.0];
}

#pragma mark - 16进制色
+ (UIColor *)colorWithHexStr:(NSString *)hexStr{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    NSInteger location = [hexStr rangeOfString:@"#"].length;
    location = location >0 ? ([hexStr rangeOfString:@"#"].location+1) : 0;
    [scanner setScanLocation:location];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRGB:rgbValue];
}
+ (UIColor *)colorWithHexStr:(NSString *)hexStr alpha:(CGFloat)alpha{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    NSInteger location = [hexStr rangeOfString:@"#"].length;
    location = location >0 ? ([hexStr rangeOfString:@"#"].location+1) : 0;
    [scanner setScanLocation:location];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRGB:rgbValue alpha:alpha];
}

#pragma mark - RGB色
+ (UIColor *)colorWithRGB:(NSInteger)rgb{
    return [UIColor colorWithRed:RGB2FLOAT(RGB_RED(rgb)) green:RGB2FLOAT(RGB_GREEN(rgb)) blue:RGB2FLOAT(RGB_BLUE(rgb)) alpha:1];
}
+ (UIColor *)colorWithRGB:(NSInteger)rgb alpha:(CGFloat)alpha{
    return [UIColor colorWithRed:RGB2FLOAT(RGB_RED(rgb)) green:RGB2FLOAT(RGB_GREEN(rgb)) blue:RGB2FLOAT(RGB_BLUE(rgb)) alpha:alpha];
}


@end
