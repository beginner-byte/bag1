//
//  NoaMiniAppFloatListCell.h
//  NoaKit
//
//  Created by Candy on 2023/7/19.
//

#import "NoaBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZMiniAppFloatListCellDelegate <NSObject>
- (void)miniAppDeleteWith:(NSIndexPath *)cellIndex;
@end

@interface NoaMiniAppFloatListCell : NoaBaseCell

@property (nonatomic, weak) id <ZMiniAppFloatListCellDelegate> delegate;
@property (nonatomic, strong) NoaFloatMiniAppModel * floatMiniAppModel;
@end

NS_ASSUME_NONNULL_END
