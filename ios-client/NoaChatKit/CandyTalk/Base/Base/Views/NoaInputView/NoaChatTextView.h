//
//  NoaChatTextView.h
//  NoaKit
//
//  Created by Candy on 2026/11/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaChatTextView : UITextView
@property (nonatomic, assign) BOOL isCanPerform;//是否有菜单功能
//@property (nonatomic, strong) UILabel * placeHolderLabel;//palceholdellabel

/// 拼接自定义表情富文本
/// @param emojiName 自定义表情名称
- (void)appendWithEmojiName:(NSString *)emojiName;

/// 给输入框赋值
/// @param textContent 赋值的内容
- (void)configTextContent:(NSString *)textContent;
@end

NS_ASSUME_NONNULL_END
