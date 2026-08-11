//
//  NoaTeamManagerCell.h
//  NoaKit
//
//  Created by Candy on 2023/7/20.
//

#import "NoaBaseCell.h"
#import "NoaTeamModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZTeamManagerType) {
    ZTeamManagerTypeNone = 0,      //无状态
    ZTeamManagerTypeEdit,          //编辑状态
};

@protocol ZTeamManagerCellDelegate <NSObject>

- (void)teamManagerOperator:(NSIndexPath *)cellIndex;

@end

@interface NoaTeamManagerCell : NoaBaseCell
@property (nonatomic, weak) id <ZTeamManagerCellDelegate> delegate;

- (void)configCell:(ZTeamManagerType)managerType model:(NoaTeamModel * _Nullable)model;
@end

NS_ASSUME_NONNULL_END
