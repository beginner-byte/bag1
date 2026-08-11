//
//  NoaChatTextView.m
//  NoaKit
//
//  Created by Candy on 2026/11/26.
//

#import "NoaChatTextView.h"
#import "NoaChatInputEmojiManager.h"
#import "UITextView+Placeholder.h"

@implementation NoaChatTextView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //self.returnKeyType = UIReturnKeySend;//回车按钮 发送
        self.backgroundColor = UIColor.clearColor;
        self.showsVerticalScrollIndicator = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.textContainerInset = UIEdgeInsetsZero;
//        self.contentInset = UIEdgeInsetsZero;
//        self.contentOffset = CGPointZero;
//        self.textContainerInset = UIEdgeInsetsZero;
//        self.textContainer.lineFragmentPadding = 0;
        
        self.isCanPerform = YES;
        
        [self addNotification];
        [self setPalceHolderLabel];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChange) name:UITextViewTextDidChangeNotification object:nil];
        
    }
    return self;
}

- (void)textViewDidChange{
    DLog(@"textViewDidChange");
}

- (void)setPalceHolderLabel{
    self.placeholder = LanguageToolMatch(@"请输入...");
}

#pragma mark - 通知监听
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTextViewNotification:) name:UITextViewTextDidChangeNotification object:self];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTextViewNotification:) name:UITextViewTextDidBeginEditingNotification object:self];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTextViewNotification:) name:UITextViewTextDidEndEditingNotification object:self];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideMenuController:) name:UIMenuControllerWillHideMenuNotification object:nil];
}

#pragma mark - 通知监听执行方法
- (void)didReceiveTextViewNotification:(NSNotification *)notification {
  [self setNeedsDisplay];
}

- (void)hideMenuController:(NSNotification *)notification {
  [[UIMenuController sharedMenuController] setMenuItems:nil];
}

#pragma mark - 重写UITextView的方法
- (BOOL)canBecomeFocused {
    return YES;
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (!self.isCanPerform) {
        return NO;
    }
    
    if (action == @selector(paste:)) {
      UIPasteboard* defaultPasteboard = [UIPasteboard generalPasteboard];
      return (defaultPasteboard.string && defaultPasteboard.string.length > 0);
    }
    if (action == @selector(selectAll:) || action == @selector(select:)) {
      return self.text.length > 0;
    }
    if (action == @selector(cut:) || action == @selector(copy:)) {
      return self.selectedRange.length > 0;
    }
    
    return NO;
}

#pragma mark - 重写菜单方法
//粘贴
- (void)paste:(id)sender {
    
    UIPasteboard *defaultPasteboard = [UIPasteboard generalPasteboard];
    
    if (defaultPasteboard.string.length > 0) {
        
        NSRange range = self.selectedRange;
        
        if (range.location == NSNotFound) {
            range.location = self.text.length;
        }
        
        if ([self.delegate textView:self shouldChangeTextInRange:range replacementText:defaultPasteboard.string]) {
            
            NSAttributedString *newAttributedString = [self getEmojiText:defaultPasteboard.string];
            
            [self insertAttriStringToTextView:newAttributedString];
        }
        
    }
}

//复制
- (void)copy:(id)sender {
    
    NSRange range = self.selectedRange;
    
    NSString *content = [self getStringContentInRange:range];
    [super copy:sender];
    if (content.length > 0) {
        UIPasteboard *defaultPasteboard = [UIPasteboard generalPasteboard];
        [defaultPasteboard setString:content];
    }
    
}

//剪切
- (void)cut:(id)sender {
    NSRange range = self.selectedRange;
    NSString *content = [self getStringContentInRange:range];
    [super cut:sender];
    if (content.length > 0) {
        UIPasteboard *defaultPasteboard = [UIPasteboard generalPasteboard];
        [defaultPasteboard setString:content];
    }
}
#pragma mark - 拼接自定义表情
- (void)appendWithEmojiName:(NSString *)emojiName {
    
    //self.typingAttributes = _typingAttributes;
    
    WeakSelf;
    self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        if (themeIndex == 1) {
            weakSelf.typingAttributes = @{
                NSFontAttributeName:FONTR(16),
                NSForegroundColorAttributeName:COLORWHITE
            };
        }else {
            weakSelf.typingAttributes = @{
                NSFontAttributeName:FONTR(16),
                NSForegroundColorAttributeName:COLOR_11
            };
        }
    };
    
//    self.placeHolderLabel.hidden = YES;
    
    if (emojiName.length > 0) {
        NSAttributedString *newAttributedString = [self getEmojiText:emojiName];
        [self insertAttriStringToTextView:newAttributedString];
    }
}
#pragma mark - 给输入框赋值
- (void)configTextContent:(NSString *)textContent {
    if (textContent.length > 0) {
        
        NSRange range = self.selectedRange;
        
        if (range.location == NSNotFound) {
            range.location = self.text.length;
        }
        
        if ([self.delegate textView:self shouldChangeTextInRange:range replacementText:textContent]) {
            
            NSAttributedString *newAttributedString = [self getEmojiText:textContent];
            
            [self insertAttriStringToTextView:newAttributedString];
        }
        
    }
}
#pragma mark - 私有方法

//富文本插入指定位置
- (void)insertAttriStringToTextView:(NSAttributedString *)attriString {
    
    NSMutableAttributedString *mAttriString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    
    NSRange range = self.selectedRange;
    
    if (range.location == NSNotFound) {
        range.location = self.text.length;
    }
    
    [mAttriString insertAttributedString:attriString atIndex:range.location];
    
    self.attributedText = [mAttriString copy];
    
    self.selectedRange = NSMakeRange(range.location + attriString.length, 0);
    //让输入框自动往下移动
    [self scrollRangeToVisible:NSMakeRange(range.location, 1)];
    
}

//构造NSTextAttachment(自定义表情)
- (NSTextAttachment *)createEmojiAttachment:(NSString *)emojiText {
    if(emojiText.length==0){
        return nil;
    }
    
    NSString *imageName = [EMOJI.emojiDict objectForKey:emojiText];
    if(imageName.length == 0){
        return nil;
    }
    
    UIImage *image = [UIImage imageNamed:imageName];
    if(image == nil){
        return nil;
    }
    
    //把图片缩放到符合当前textview行高的大小
    CGFloat emojiWHScale = image.size.width /1.0 / image.size.height;
    
    CGSize emojiSize = CGSizeMake(self.font.lineHeight * emojiWHScale, self.font.lineHeight);
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, emojiSize.width, emojiSize.height)];
    imageView.image = image;
    //防止模糊
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, [UIScreen mainScreen].scale);
    [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *emojiImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = emojiImage;
    attachment.accessibilityValue = emojiText;
    attachment.bounds = CGRectMake(0, -3, emojiImage.size.width, emojiImage.size.height);
    return attachment;
}

//获取表情富文本
- (NSMutableAttributedString *)getEmojiText:(NSString *)content {
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:content attributes:self.typingAttributes];
    
    static NSRegularExpression *regExpress = nil;
    if(regExpress == nil){
        regExpress = [NSRegularExpression regularExpressionWithPattern:@"\\[[^ \\[\\]]+?\\]" options:0 error:nil];
    }
    //通过正则表达式识别出emojiText
    NSArray *matches = [regExpress matchesInString:content options:0 range:NSMakeRange(0, content.length)];
    
    if(matches.count > 0){
        for(NSTextCheckingResult *result in [matches reverseObjectEnumerator]){
            NSString *emojiText = [content safeSubstringWithRange:result.range];
            //构造NSTextAttachment对象
            NSTextAttachment *attachment = [self createEmojiAttachment:emojiText];
            if(attachment){
                NSAttributedString *rep = [NSAttributedString attributedStringWithAttachment:attachment];
                //在对应的位置替换
                [attributedString replaceCharactersInRange:result.range withAttributedString:rep];
            }
        }
    }
    
    
    
    [attributedString addAttributes:self.typingAttributes range:NSMakeRange(0, attributedString.length)];
    
    return attributedString;
}

//把textview的attributedText转化为NSString，其中把自定义表情转化为emojiText
- (NSString *)getStringContentInRange:(NSRange)range {
    
    NSMutableString *result = [[NSMutableString alloc] initWithCapacity:1];
    
    NSRange effectiveRange = NSMakeRange(range.location, 0);
    
    NSUInteger length = NSMaxRange(range);
    
    while (NSMaxRange(effectiveRange) < length) {
        NSTextAttachment *attachment = [self.attributedText attribute:NSAttachmentAttributeName atIndex:NSMaxRange(effectiveRange) effectiveRange:&effectiveRange];
        
        if (attachment) {
            [result appendString:attachment.accessibilityValue];
        }else {
            NSString *subStr = [self.text safeSubstringWithRange:effectiveRange];
            [result appendString:subStr];
        }
        
    }
    
    return [result copy];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
