//
//  NoaEmojiShopFeaturedCell.h
//  NoaKit
//
//  Created by Candy on 2023/10/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZEmojiShopFeaturedCellDelegate <NSObject>

- (void)shopFeaturedStickerLongTapAction:(NSIndexPath *)indexPath;

@end

@interface NoaEmojiShopFeaturedCell : UICollectionViewCell

@property (nonatomic, strong) NoaIMStickersModel *model;
@property (nonatomic, strong) NSIndexPath *cellIndexPath;
@property (nonatomic, weak) id <ZEmojiShopFeaturedCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
