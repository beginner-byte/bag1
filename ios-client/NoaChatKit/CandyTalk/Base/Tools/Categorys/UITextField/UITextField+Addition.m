//
//  UITextField+Addition.m
//  NoaKit
//
//  Created by Candy on 2026/8/31.
//

#import "UITextField+Addition.h"

@implementation UITextField (Addition)

/** 检查输入的内容必须包含数字和字母 */
- (BOOL)avalidateContentWithNumAndLetter {
    //去掉空格
    self.text = [self.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    BOOL result = false;
    NSString * regex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,16}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    result = [pred evaluateWithObject:self.text];
    
    return result;
}

/** 检查输入的内容只包含字母和汉字 */
- (BOOL)avalidateContentWithLetterAndChinese {
    NSString *regex = @"[a-zA-Z\u4e00-\u9fa5]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if(![pred evaluateWithObject:self.text]){
        return NO;
    }
    return YES;
}

/** 检查SSO设置的网络地址格式是否正确*/
- (BOOL)avalidateUrlAddress {
    NSString *url = self.text;
    if(url.length < 1)
        return NO;
    if (url.length>4 && [[url substringToIndex:4] isEqualToString:@"www."]) {
        url = [NSString stringWithFormat:@"http://%@",url];
    } else {
        url = url;
    }
    NSString *urlRegex = @"(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]";
    NSPredicate* urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegex];

    return [urlTest evaluateWithObject:url];
}

/** 设置textField光标的位置*/
- (void)updateLocationAfterCopyWithTextField:(UITextField *)textField offset:(NSInteger)offset {
    
    NSRange currentRange = [self selectedRangeWithTextField:textField];
    if (currentRange.location < offset) {
        offset = currentRange.location;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ //必须加延迟，否则无法更新光标位置
        [self setSelectedRange:NSMakeRange(offset, 0) textField:textField];
    });
}

#pragma mark - Zachary - 获取&设置光标位置
- (NSRange)selectedRangeWithTextField:(UITextField *)textField {
    
    NSInteger location = [textField offsetFromPosition:textField.beginningOfDocument toPosition:textField.selectedTextRange.start];
    
    NSInteger length = [textField offsetFromPosition:textField.selectedTextRange.start toPosition:textField.selectedTextRange.end];
    
    return NSMakeRange(location, length);
}

- (void)setSelectedRange:(NSRange)selectedRange textField:(UITextField *)textField {
    //beginningOfDocument 内容启始位置
    UITextPosition *startPosition = [textField positionFromPosition:textField.beginningOfDocument offset:selectedRange.location];
    //selectedRange.length 选中的
    UITextPosition *endPosition = [textField positionFromPosition:textField.beginningOfDocument offset:selectedRange.location + selectedRange.length];
    
    UITextRange *selectedTextRange = [textField textRangeFromPosition:startPosition toPosition:endPosition];
    [textField setSelectedTextRange:selectedTextRange];
}


@end
