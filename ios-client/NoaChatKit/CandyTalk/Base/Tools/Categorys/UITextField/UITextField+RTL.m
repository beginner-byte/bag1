//
//  UITextField+RTL.m
//  NoaKit
//
//  Created by Candy on 2023/9/15.
//

#import "UITextField+RTL.h"

@implementation UITextField (RTL)

+ (void)load{
    //RTL 布局 相关 方法交换
    Method oldInitMethod = class_getInstanceMethod(self,@selector(initWithFrame:));
    Method newInitMethod = class_getInstanceMethod(self, @selector(rtl_initWithFrame:));
    method_exchangeImplementations(oldInitMethod, newInitMethod);
    
    Method oldSetTextAlignment = class_getInstanceMethod(self,@selector(setTextAlignment:));
    Method newSetTextAlignment = class_getInstanceMethod(self, @selector(rtl_setTextAlignment:));
    method_exchangeImplementations(oldSetTextAlignment, newSetTextAlignment);
    
    Method oldAttMethod = class_getInstanceMethod(self,@selector(setAttributedText:));
    Method newAttMethod = class_getInstanceMethod(self, @selector(rtl_setAttributedText:));
    method_exchangeImplementations(oldAttMethod, newAttMethod);
    
    Method oldTextMethod = class_getInstanceMethod(self,@selector(setText:));
    Method newTextMethod = class_getInstanceMethod(self,@selector(rtl_setText:));
    method_exchangeImplementations(oldTextMethod, newTextMethod);
}

- (instancetype)rtl_initWithFrame:(CGRect)frame{
    if ([self rtl_initWithFrame:frame]) {
        self.textAlignment = NSTextAlignmentNatural;
    }
    return self;
}

- (void)rtl_setTextAlignment:(NSTextAlignment)textAlignment{
    if (ZLanguageTOOL.isRTL) {
        if (textAlignment == NSTextAlignmentNatural || textAlignment == NSTextAlignmentLeft) {
            textAlignment = NSTextAlignmentRight;
        } else if (textAlignment == NSTextAlignmentRight) {
            textAlignment = NSTextAlignmentLeft;
        }
    }else{
        if (textAlignment == NSTextAlignmentNatural || textAlignment == NSTextAlignmentLeft) {
            textAlignment = NSTextAlignmentLeft;
        } else if (textAlignment == NSTextAlignmentRight) {
            textAlignment = NSTextAlignmentRight;
        }
    }
    [self rtl_setTextAlignment:textAlignment];
}

- (void)rtl_setAttributedText:(NSAttributedString *)attributedText{
    if (ZLanguageTOOL.isRTL) {
        attributedText = RTLAttributeString(attributedText);
    }
    [self rtl_setAttributedText:attributedText];
}

- (void)rtl_setText:(NSString *)text{
    [self rtl_setText:text];
}

@end
