//
//  NSMutableAttributedString+Addition.h
//  NoaKit
//
//  Created by Candy on 2026/12/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (Addition)

//富文本颜色设置(适配浅色、暗黑模式) 改变指定位置的颜色
- (void)configAttStrLightColor:(UIColor *)lightColor darkColor:(UIColor *)darkColor range:(NSRange)range;

//富文本颜色设置(适配浅色、暗黑模式) 改变指定内容字符串的颜色
- (void)configAttStrLightColor:(UIColor *)lightColor darkColor:(UIColor *)darkColor fullStr:(NSString *)fullStr appointStr:(NSString *)appointStr;


@end

NS_ASSUME_NONNULL_END
