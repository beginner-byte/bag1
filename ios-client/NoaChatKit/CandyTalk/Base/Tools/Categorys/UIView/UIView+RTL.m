//
//  UIView+RTL.m
//  NoaKit
//
//  Created by Candy on 2023/9/15.
//

#import "UIView+RTL.h"

@implementation UIView (RTL)

-(CGRect)RTLFrame{
    if (self.superview) {
        CGRect frame = self.frame;
        CGFloat superWidth = self.superview.frame.size.width;
        frame.origin.x = superWidth - frame.origin.x - frame.size.width;
        return frame;
    }else{
        return self.frame;
    }
}

-(void)resetFrameToFitRTL{
    if (ZLanguageTOOL.isRTL && self.superview) {
        self.frame = [self RTLFrame];
    }
}
@end
