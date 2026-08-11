//
//  NSMutableAttributedString+Addition.m
//  NoaKit
//
//  Created by Candy on 2026/12/17.
//

#import "NSMutableAttributedString+Addition.h"

@implementation NSMutableAttributedString (Addition)

#pragma mark - 富文本颜色设置(适配浅色、暗黑模式)
- (void)configAttStrLightColor:(UIColor *)lightColor darkColor:(UIColor *)darkColor range:(NSRange)range {
    // 保存原始范围，避免在异步回调中访问可能已失效的范围
    NSRange safeRange = range;
    self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        UIColor *color = nil;
        if (themeIndex == 0) {
            color = lightColor;
        } else {
            color = darkColor;
        }
        // 检查范围是否有效，避免崩溃
        NSString *currentString = [(NSMutableAttributedString *)itself string];
        if (safeRange.location < currentString.length && 
            safeRange.location + safeRange.length <= currentString.length) {
            [(NSMutableAttributedString *)itself addAttribute:NSForegroundColorAttributeName value:color range:safeRange];
        }
    };
}

//富文本颜色设置(适配浅色、暗黑模式) 改变指定内容字符串的颜色
- (void)configAttStrLightColor:(UIColor *)lightColor darkColor:(UIColor *)darkColor fullStr:(NSString *)fullStr appointStr:(NSString *)appointStr {
    for (int i = 0; i < fullStr.length; i++) {
        if ((fullStr.length - i) < appointStr.length) {  //防止遍历剩下的字符少于搜索条件的字符而崩溃
        
        } else {
            NSString *str = [fullStr safeSubstringWithRange:NSMakeRange(i, appointStr.length)];
            if ([appointStr isEqualToString:str]) {
                // 保存当前循环中的范围，避免在异步回调中访问可能已失效的范围
                NSRange currentRange = NSMakeRange(i, appointStr.length);
                self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
                    UIColor *color = nil;
                    if (themeIndex == 0) {
                        color = lightColor;
                    } else {
                        color = darkColor;
                    }
                    // 检查范围是否有效，避免崩溃
                    NSString *currentString = [(NSMutableAttributedString *)itself string];
                    if (currentRange.location < currentString.length && 
                        currentRange.location + currentRange.length <= currentString.length) {
                        [(NSMutableAttributedString *)itself addAttribute:NSForegroundColorAttributeName value:color range:currentRange];
                    }
                };
                i = i + (int)(appointStr.length) - 1;
            }
        }
    }
}


@end
