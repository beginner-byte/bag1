//
//  NoaMyMiniAppItem.h
//  NoaKit
//
//  Created by Candy on 2023/7/18.
//

#import "NoaBaseCollectionCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZMyMiniAppItemDelete <NSObject>

- (void)myMiniAppDelete:(NSIndexPath *)indexPath;

@end

@interface NoaMyMiniAppItem : NoaBaseCollectionCell

@property (nonatomic, weak) id <ZMyMiniAppItemDelete> delegate;

- (void)configItemWith:(LingIMMiniAppModel *)miniAppModel manage:(BOOL)manageItem;

@end

NS_ASSUME_NONNULL_END
