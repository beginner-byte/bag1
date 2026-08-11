//
//  NoaTeamHomeHeaderView.h
//  NoaKit
//
//  Created by Candy on 2023/9/7.
//

#import <UIKit/UIKit.h>
#import "NoaTeamModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZTeamHomeHeaderViewDelegate <NSObject>

- (void)headerTeamListTitleAction;
- (void)headerTeamItemAction:(NoaTeamModel *)teamModel;
- (void)headerSetDefaultTeamAction:(NoaTeamModel *)teamModel;

@end

@interface NoaTeamHomeHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) NSArray *headerTeamList;
@property (nonatomic, weak) id <ZTeamHomeHeaderViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
