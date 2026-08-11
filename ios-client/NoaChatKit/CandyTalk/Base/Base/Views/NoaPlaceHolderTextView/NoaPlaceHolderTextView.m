//
//  NoaPlaceHolderTextView.m
//  NoaKit
//
//  Created by Candy on 2023/5/4.
//

#import "NoaPlaceHolderTextView.h"

@implementation NoaPlaceHolderTextView

#pragma mark - 初始化方法
- (instancetype)initWithFrame:(CGRect)frame hiddenMaxText:(BOOL)hiddenMaxText {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTextDidChangeNotification:) name:UITextViewTextDidChangeNotification object:self];
        
        self.textContainerInset = UIEdgeInsetsMake(10, 8, 10, 8);
        self.contentInset = UIEdgeInsetsZero;
        self.scrollIndicatorInsets = UIEdgeInsetsMake(10.0, 0.0, 10.0, 1.0);
        if (_hiddenMaxText == NO) {
            self.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
            self.scrollIndicatorInsets = UIEdgeInsetsMake(10.0, 0.0, 50.0, 1.0);
        }
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.scrollEnabled = YES;
        self.scrollsToTop = NO;
        self.userInteractionEnabled = YES;
        self.keyboardAppearance = UIKeyboardAppearanceDefault;
        self.keyboardType = UIKeyboardTypeDefault;
        self.returnKeyType = UIReturnKeyDefault;
        self.textAlignment = NSTextAlignmentLeft;
    }
    return self;
}

#pragma mark - Setters
- (void)setPlaceHolder:(NSString *)placeHolder {
    if([placeHolder isEqualToString:_placeHolder]) {
        return;
    }
    
    _placeHolder = placeHolder;
    [self setNeedsDisplay];
}

- (void)setPlaceHolderTextColor:(UIColor *)placeHolderTextColor {
    if([placeHolderTextColor isEqual:_placeHolderTextColor]) {
        return;
    }
    
    _placeHolderTextColor = placeHolderTextColor;
    [self setNeedsDisplay];
}


- (void)setText:(NSString *)text {
    [super setText:text];
    [self setNeedsDisplay];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [self setNeedsDisplay];
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    [super setContentInset:contentInset];
    [self setNeedsDisplay];
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset {
    [super setTextContainerInset:textContainerInset];
    [self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self setNeedsDisplay];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    [super setTextAlignment:textAlignment];
    [self setNeedsDisplay];
}

- (void)setMaxTextLength:(NSInteger)maxTextLength {
    _maxTextLength = maxTextLength;
    [self setNeedsDisplay];
}

- (void)setHiddenMaxText:(BOOL)hiddenMaxText {
    _hiddenMaxText = hiddenMaxText;
    [self setNeedsDisplay];
}

- (void)setTextViewDelegate:(id<ZPlaceHolderTextViewDelegate>)textViewDelegate {
    _textViewDelegate = textViewDelegate;
    //    self.deletage = textViewDelegate;
    [self setNeedsDisplay];
}
#pragma mark - 通知
- (void)didReceiveTextDidChangeNotification:(NSNotification *)notification {
    
    if (self.text.length > _maxTextLength) {
        self.text = [self.text substringToIndex:_maxTextLength];
    }
    
    [self setNeedsDisplay];
}

//销毁时，移除通知
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
}

#pragma mark - 绘制提示语和文字限制
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    //提示语
    if([self.text length] == 0 && self.placeHolder) {
        
        CGRect placeHolderRect = CGRectMake(self.textContainerInset.top + 2,
                                            self.textContainerInset.left,
                                            rect.size.width - 20,
                                            rect.size.height);
        
        [self.placeHolderTextColor set];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        //        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        paragraphStyle.alignment = self.textAlignment;
        
        [self.placeHolder drawInRect:placeHolderRect
                      withAttributes:@{ NSFontAttributeName : self.font,
                                        NSForegroundColorAttributeName : self.placeHolderTextColor,
                                        NSParagraphStyleAttributeName : paragraphStyle }];
    }
    
    //字数限制
    if(self.hiddenMaxText == NO && [self.textViewDelegate respondsToSelector:@selector(refreshTextLimit)])
        //    if(self.hiddenMaxText == NO)
    {
        [self.textViewDelegate refreshTextLimit];
        
        CGRect textLimitRect = CGRectMake(rect.size.width - 110, rect.origin.y + rect.size.height - 20, 100, 20);
        
        [self.textColor set];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        paragraphStyle.alignment = NSTextAlignmentRight;
        
        NSString *str = [NSString stringWithFormat:@"%@/%ld", [NSString stringWithFormat:@"%ld", self.maxTextLength - self.text.length], self.maxTextLength];
        
        [str drawInRect:textLimitRect
         withAttributes:@{ NSFontAttributeName : self.font,
                           NSForegroundColorAttributeName : self.placeHolderTextColor,
                           NSParagraphStyleAttributeName : paragraphStyle }];
    }
    
}


@end
