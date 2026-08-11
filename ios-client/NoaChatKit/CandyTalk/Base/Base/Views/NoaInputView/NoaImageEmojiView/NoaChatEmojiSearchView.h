//
//  NoaChatEmojiSearchView.h
//  NoaKit
//
//  Created by Candy on 2023/8/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZChatEmojiSearchViewDelegate <NSObject>
//更多表情
- (void)moreEmojiAction;
//点击发送搜索到的表情
- (void)sendSearchStickersForModel:(NoaIMStickersModel *)stickersModel;
//收藏表情
- (void)collectionStickerFromSearchResult;

@end

@interface NoaChatEmojiSearchView : UIView

@property (nonatomic, weak) id <ZChatEmojiSearchViewDelegate> delegate;

- (void)emojiSearchViewShow;
- (void)emojiSearchViewDismiss;

@end

NS_ASSUME_NONNULL_END
