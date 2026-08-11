//
//  NoaChatImageEmojiView.h
//  NoaKit
//
//  Created by Candy on 2023/8/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZChatImageEmojiViewDelegate <NSObject>
/* 表情符号 */
//选中表情
- (void)imageEmojiViewSelected:(NSString *)emojiName;
//删除
- (void)imageEmojiViewDelete;
//表情包表情或者动图表情或搜索出来的表情
- (void)imageGifPackageSelected:(NoaIMStickersModel *)sendStickersModel;
//打开相册(添加相册图片到收藏的表情里)
- (void)openAlumAddCollectGifImg;
//石头剪刀布、//摇骰子
- (void)chatGameStickerAction:(ZChatGameStickerType)gameType;
//搜索表情-更多表情
- (void)searchEmojiMoreAction;

@end

@interface NoaChatImageEmojiView : UIView

@property (nonatomic, weak) id <ZChatImageEmojiViewDelegate> delegate;

//请求 收藏的表情和已使用的表情包
- (void)reloadStickersData;
//单独刷新收藏的表情
- (void)relaodCollectionData;

@end

NS_ASSUME_NONNULL_END
