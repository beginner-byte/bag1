//
//  NoaBubbleReceiveView.m
//  NoaKit
//
//  Created by Candy on 2026/9/28.
//

#define k_width self.bounds.size.width
#define k_height self.bounds.size.height
#define k_radius 18
#define k_arrow_radius 3

#import "NoaBubbleReceiveView.h"
@implementation NoaBubbleReceiveView

- (void)drawRect:(CGRect)rect {
    UIUserInterfaceStyle isDarkMode = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
    UIColor *fillColor;
    
//    DDLog(@"Theme changed: source-%@, isDark-%@", @"ZBubbleReceiveView", isDarkMode ? @"YES" : @"NO");
    
    if (!isDarkMode) {
        fillColor = COLORWHITE;
    } else {
        fillColor = COLOR_66;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (_bgFillColor) {
        //气泡颜色
        CGContextSetFillColorWithColor(context, _bgFillColor.CGColor);
    } else {
        //气泡颜色
        CGContextSetFillColorWithColor(context, fillColor.CGColor);
    }
    
    if (ZLanguageTOOL.isRTL) {
        CGContextMoveToPoint(context, k_radius, k_height);
        CGContextAddArcToPoint(context, 0, k_height, 0, k_height - k_radius, k_radius); //左下
        CGContextAddArcToPoint(context, 0, 0, k_radius, 0, k_radius); //左上
        CGContextAddArcToPoint(context, k_width, 0, k_width, k_arrow_radius, k_arrow_radius); //右上
        CGContextAddArcToPoint(context, k_width, k_height, k_width - k_radius, k_height, k_radius); //右下
        CGContextClosePath(context);
        CGContextDrawPath(context, kCGPathFill);
    } else {
        CGContextMoveToPoint(context, k_radius, k_height);
        CGContextAddArcToPoint(context, 0, k_height, 0, k_height - k_radius, k_radius); //左下
        CGContextAddArcToPoint(context, 0, 0, k_arrow_radius, 0, k_arrow_radius); //左上
        CGContextAddArcToPoint(context, k_width, 0, k_width, k_radius, k_radius); //右上
        CGContextAddArcToPoint(context, k_width, k_height, k_width - k_radius, k_height, k_radius); //右下
        CGContextClosePath(context);
        CGContextDrawPath(context, kCGPathFill);
    }
    
}

@end
