//
//  NoaGroupInviteFriendVC.h
//  NoaKit
//
//  Created by Candy on 2026/11/9.
//

#import "CandyBaseViewController.h"
#import "LingIMGroup.h"
NS_ASSUME_NONNULL_BEGIN

@interface NoaGroupInviteFriendVC : CandyBaseViewController

@property (nonatomic,strong)NSArray<LingIMGroupMemberModel *> *groupMemberList;
@property (nonatomic,strong)LingIMGroup *groupInfoModel;

@end

NS_ASSUME_NONNULL_END
