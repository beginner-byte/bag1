//
//  UITextView+Addition.m
//  NoaKit
//
//  Created by Candy on 2026/9/13.
//

#import "UITextView+Addition.h"
#import <objc/runtime.h>

static const void *limitLengthKey = &limitLengthKey;

@interface UITextView ()
@end

@implementation UITextView (Addition)



//限制输入个数
- (void)setLimitLength:(NSNumber *)limitLength {
    objc_setAssociatedObject(self, limitLengthKey, limitLength, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    //监听文本变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewContentChanged) name:UITextViewTextDidChangeNotification object:self];
    [self setWordCountLable:limitLength];
    
}
- (NSNumber *)limitLength {
    return objc_getAssociatedObject(self, limitLengthKey);
}

#pragma mark - 配置字数限制标签
- (void)setWordCountLable:(NSNumber *)limitLength {
    if (self.text.length > [limitLength integerValue]) {
        self.text = [self.text substringToIndex:[self.limitLength integerValue]];
    }
    
    if (self.attributedText.length > [limitLength integerValue]) {
        self.attributedText = [self.attributedText attributedSubstringFromRange:NSMakeRange(0, [self.limitLength integerValue])];
    }
}
#pragma mark - 内容变化监听
- (void)textViewContentChanged {
    
    if ([self.text length] > [self.limitLength intValue]) {
        
        NSInteger wordCount = self.text.length;
        if (wordCount > [self.limitLength integerValue]) {
            wordCount = [self.limitLength integerValue];
        }
        
        //当前手机支持的键盘模式的第一个类型
        //[[[UITextInputMode activeInputModes] firstObject] primaryLanguage];
        
        NSString *lang = [[self textInputMode] primaryLanguage];//当前的输入模式
        if ([lang isEqualToString:@"zh-Hans"]){
            UITextRange *range = [self markedTextRange];
            UITextPosition *start = range.start;
            UITextPosition *end = range.end;
            NSInteger selectLength = [self offsetFromPosition:start toPosition:end];
            NSInteger contentLength = self.text.length - selectLength;
            
            if (contentLength > [self.limitLength integerValue]){
                //文字超过了字数限制，截取内容
                self.text = [self.text substringToIndex:[self.limitLength integerValue]];
                //解决复制粘贴的时候内容超过限制光标位置的问题
                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.selectedRange = NSMakeRange(wordCount, 0);
                });
                //解决复制粘贴的时候内容过大出现空白的现象
                [self scrollRangeToVisible:self.selectedRange];
            }
            
        }else{
            //文字超过了字数限制，截取内容
            if(self.text.length > [self.limitLength integerValue]){
                self.text = [self.text substringToIndex:[self.limitLength integerValue]];
                //解决复制粘贴的时候内容超过限制光标位置的问题
                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.selectedRange = NSMakeRange(wordCount, 0);
                });
                //解决复制粘贴的时候内容过大出现空白的现象
                [self scrollRangeToVisible:self.selectedRange];
            }
        }
        
    }
    
    DLog(@"当前输入框文本内容长度：%ld",self.text.length);
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
