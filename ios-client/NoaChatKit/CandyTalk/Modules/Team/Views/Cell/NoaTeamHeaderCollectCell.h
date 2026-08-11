//
//  NoaTeamHeaderCollectCell.h
//  NoaKit
//
//  Created by Candy on 2023/9/7.
//

#import "NoaBaseCollectionCell.h"
#import "NoaTeamModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZTeamHeaderCollectCellDelegate <NSObject>

- (void)selectedTeamForDefaultAction:(NoaTeamModel *)teamMode;

@end

@interface NoaTeamHeaderCollectCell : NoaBaseCollectionCell

@property (nonatomic, strong) NoaTeamModel *teamModel;
@property (nonatomic, weak) id <ZTeamHeaderCollectCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
