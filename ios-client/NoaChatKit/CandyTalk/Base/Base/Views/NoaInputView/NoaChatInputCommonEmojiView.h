//
//  NoaChatInputCommonEmojiView.h
//  NoaKit
//
//  Created by Candy on 2023/6/28.
//

// 常用表情View

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZChatInputCommonEmojiViewDelegate <NSObject>
- (void)commonEmojiSelected:(NSString *)emojiName;
@end

@interface NoaChatInputCommonEmojiView : UIView
@property (nonatomic, weak) id <ZChatInputCommonEmojiViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
