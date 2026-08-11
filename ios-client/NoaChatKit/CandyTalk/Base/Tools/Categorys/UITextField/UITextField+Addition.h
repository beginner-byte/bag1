//
//  UITextField+Addition.h
//  NoaKit
//
//  Created by Candy on 2026/8/31.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextField (Addition)

/** 检查输入的内容只包含数字和字母 */
- (BOOL)avalidateContentWithNumAndLetter;

/** 检查输入的内容只包含字母和汉字 */
- (BOOL)avalidateContentWithLetterAndChinese;

/** 检查SSO设置的网络地址格式是否正确 */
- (BOOL)avalidateUrlAddress;

/** 设置textField光标的位置*/
- (void)updateLocationAfterCopyWithTextField:(UITextField *)textField offset:(NSInteger)offset;

@end

NS_ASSUME_NONNULL_END
