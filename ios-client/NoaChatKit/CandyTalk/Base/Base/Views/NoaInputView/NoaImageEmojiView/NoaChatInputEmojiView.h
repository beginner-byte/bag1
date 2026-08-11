//
//  NoaChatInputEmojiView.h
//  NoaKit
//
//  Created by Candy on 2026/10/12.
//

// 自定义表情 View

#import <UIKit/UIKit.h>
#import "NoaChatInputEmojiManager.h"

NS_ASSUME_NONNULL_BEGIN
@protocol ZChatInputEmojiViewDelegate <NSObject>
//选中表情
- (void)inputEmojiViewSelected:(NSString *)emojiName;
//删除
- (void)inputEmojiViewDelete;
@end

@interface NoaChatInputEmojiView : UIView
@property (nonatomic, weak) id <ZChatInputEmojiViewDelegate> delegate;
@end


@interface NoaChatInputEmojiCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *ivEmoji;
@end

NS_ASSUME_NONNULL_END
