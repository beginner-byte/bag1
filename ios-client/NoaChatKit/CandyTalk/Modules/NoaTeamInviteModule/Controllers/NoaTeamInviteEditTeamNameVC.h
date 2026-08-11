//
//  NoaTeamInviteEditTeamNameVC.h
//  NoaKit
//
//  Created by phl on 2025/7/25.
//

#import "CandyBaseViewController.h"
#import "NoaTeamModel.h"
NS_ASSUME_NONNULL_BEGIN
typedef void(^ChangeTeamNameHandle)(NSString *newTeamName);
@interface NoaTeamInviteEditTeamNameVC : CandyBaseViewController

/// 从上个页面传入的团队信息
@property (nonatomic, strong, readwrite) NoaTeamModel *currentTeamModel;

/// 修改名称成功回调
@property (nonatomic, copy) ChangeTeamNameHandle changeTeamNameHandle;

@end

NS_ASSUME_NONNULL_END
