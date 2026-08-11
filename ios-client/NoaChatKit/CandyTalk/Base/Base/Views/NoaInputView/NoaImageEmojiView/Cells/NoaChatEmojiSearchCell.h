//
//  NoaChatEmojiSearchCell.h
//  NoaKit
//
//  Created by Candy on 2023/10/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZChatEmojiSearchCellDelegate <NSObject>

- (void)searchStickerResultLongTapAction:(NSIndexPath *)indexPath;

@end

@interface NoaChatEmojiSearchCell : UICollectionViewCell

@property (nonatomic, strong) NSIndexPath *cellIndexPath;
@property (nonatomic, strong) NoaIMStickersModel *stickersModel;
@property (nonatomic, weak) id <ZChatEmojiSearchCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
