//
//  UISwipeGestureRecognizer+RTL.m
//  NoaKit
//
//  Created by Candy on 2023/9/15.
//

#import "UISwipeGestureRecognizer+RTL.h"

@implementation UISwipeGestureRecognizer (RTL)

+ (void)load{
    Method oldAttMethod = class_getInstanceMethod(self,@selector(setDirection:));
    Method newAttMethod = class_getInstanceMethod(self,@selector(rtl_setDirection:));
    method_exchangeImplementations(oldAttMethod, newAttMethod);  //交换成功
   
}

- (void)rtl_setDirection:(UISwipeGestureRecognizerDirection)direction{
    
    if (ZLanguageTOOL.isRTL) {
        if (direction == UISwipeGestureRecognizerDirectionRight) {
            direction = UISwipeGestureRecognizerDirectionLeft;
        } else if (direction == UISwipeGestureRecognizerDirectionLeft) {
            direction = UISwipeGestureRecognizerDirectionRight;
        }
    }
    [self rtl_setDirection:direction];
}

@end
