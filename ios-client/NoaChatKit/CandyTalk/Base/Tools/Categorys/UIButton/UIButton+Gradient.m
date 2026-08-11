//
//  UIButton+Gradient.m
//  NoaSNewsMedia
//
//  Created by 郑开 on 2023/3/20.
//  Copyright © 2023 HNZS. All rights reserved.
//

#import "UIButton+Gradient.h"

@implementation UIButton (Gradient)
/**
 图片在左边
 @param space 图文间隙
 */
- (void)setIconInLeftWithSpacing:(CGFloat)space
{
    self.titleEdgeInsets = UIEdgeInsetsMake(0, space/2, 0, -space/2);
    self.imageEdgeInsets = UIEdgeInsetsMake(0, -space/2, 0, space/2);
}
 
/**
 图片在右边
 @param space 图文间隙
 */
- (void)setIconInRightWithSpacing:(CGFloat)space
{
    CGFloat img_W = self.imageView.frame.size.width;
    CGFloat tit_W = self.titleLabel.frame.size.width;
    
    self.titleEdgeInsets = UIEdgeInsetsMake(0, - (img_W + space / 2), 0, (img_W + space / 2));
    self.imageEdgeInsets = UIEdgeInsetsMake(0, (tit_W + space / 2), 0, - (tit_W + space / 2));
}
 
/**
 图片在上
 @param space 图文间隙
 */
- (void)setIconInTopWithSpacing:(CGFloat)space{
    [self layoutSubviews];
    if(ZLanguageTOOL.isRTL){
        CGFloat img_W = self.imageView.frame.size.width;
        CGFloat img_H = self.imageView.frame.size.height;
        CGSize size = [self.titleLabel sizeThatFits:CGSizeMake(self.frame.size.width, MAXFLOAT)];
        CGFloat tit_W = size.width;
        CGFloat tit_H = size.height;
        self.imageEdgeInsets = UIEdgeInsetsMake(MAX(-tit_H - space, -self.imageView.frame.origin.y), 0, 0, -tit_W);
        self.titleEdgeInsets = UIEdgeInsetsMake(space, -img_W, -img_H - space, 0);
    }else{
        CGFloat img_W = self.imageView.frame.size.width;
        CGFloat img_H = self.imageView.frame.size.height;
        CGFloat tit_W = self.titleLabel.frame.size.width;
        CGFloat tit_H = self.titleLabel.frame.size.height;
        self.imageEdgeInsets = UIEdgeInsetsMake(MAX(-tit_H - space, -self.imageView.frame.origin.y), 0, 0, -tit_W);
        self.titleEdgeInsets = UIEdgeInsetsMake(space, -img_W, -img_H - space, 0);
    }
}
 
/**
 图片在下
 @param space 图文间隙
 */
- (void)setIconInBottomWithSpacing:(CGFloat)space
{
    CGFloat img_W = self.imageView.frame.size.width;
    CGFloat img_H = self.imageView.frame.size.height;
    CGFloat tit_W = self.titleLabel.frame.size.width;
    CGFloat tit_H = self.titleLabel.frame.size.height;
    
    self.titleEdgeInsets = UIEdgeInsetsMake(- (tit_H / 2 + space / 2), - (img_W / 2), (tit_H / 2 + space / 2), (img_W / 2));
    self.imageEdgeInsets = UIEdgeInsetsMake((img_H / 2 + space / 2), (tit_W / 2), - (img_H / 2 + space / 2), - (tit_W / 2));
}

@end
