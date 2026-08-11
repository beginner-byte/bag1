//
//  UILabel+Addition.m
//  NoaIMChatService
//
//  Created by Candy on 2026/7/8.
//

#import "UILabel+Addition.h"

@implementation UILabel (Addition)
#pragma mark - 修改指定范围内容字体和颜色
- (void)changeTextRange:(NSRange)range font:(UIFont * _Nullable)font color:(UIColor * _Nullable)color{
    font = font ? font : self.font;
    color = color ? color : self.textColor;
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:self.text];
    [attStr addAttribute:NSForegroundColorAttributeName value:color range:range];
    [attStr addAttribute:NSFontAttributeName value:font range:range];
    [self setAttributedText:attStr];
}

//改变行间距
- (void)changeLineSpace:(float)space {
    NSString *labelText = self.text;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:space];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
    self.attributedText = attributedString;
}

//改变字间距
- (void)changeWordSpace:(float)space {
    NSString *labelText = self.text;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText attributes:@{NSKernAttributeName:@(space)}];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
    self.attributedText = attributedString;
}

//改变行间距和字间距
- (void)changeLineSpace:(float)lineSpace WordSpace:(float)wordSpace {
    NSString *labelText = self.text;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText attributes:@{NSKernAttributeName:@(wordSpace)}];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpace];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
    self.attributedText = attributedString;
}

@end
