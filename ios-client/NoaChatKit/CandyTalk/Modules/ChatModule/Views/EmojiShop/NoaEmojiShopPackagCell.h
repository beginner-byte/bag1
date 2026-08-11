//
//  NoaEmojiShopPackagCell.h
//  NoaKit
//
//  Created by Candy on 2023/10/25.
//

#import "NoaBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZEmojiShopPackagCellDelegate <NSObject>

- (void)emojiPackageAddNewEmoji:(NSIndexPath *)cellIndexPath;

@end

@interface NoaEmojiShopPackagCell : NoaBaseCell

@property (nonatomic, strong) NoaIMStickersPackageModel *model;
@property (nonatomic, weak) id<ZEmojiShopPackagCellDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
