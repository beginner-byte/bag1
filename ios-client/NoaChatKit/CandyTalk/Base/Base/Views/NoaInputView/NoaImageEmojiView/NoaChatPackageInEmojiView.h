//
//  NoaChatPackageInEmojiView.h
//  NoaKit
//
//  Created by Candy on 2023/8/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZChatPackageInEmojiViewDelegate <NSObject>

//点击表情包表情发送
- (void)stickerPackageItemSelected:(NoaIMStickersModel *)sendStickersModel;

//删除选中的表情包
- (void)deleteStickersPackageWithStickersSetId:(NSString *)stickersSetId;

@end

@interface NoaChatPackageInEmojiView : UIView

@property (nonatomic, copy) NSString *stickersId;
@property (nonatomic, copy) NSString *packageNameStr;
@property (nonatomic, strong) NSMutableArray *stickersList;
@property (nonatomic, weak) id <ZChatPackageInEmojiViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
