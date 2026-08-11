//
//  NoaFriendManageVC.h
//  NoaKit
//
//  Created by Candy on 2026/10/22.
//

// 好友管理VC

#import "CandyBaseViewController.h"
#import "NoaUserModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface NoaFriendManageVC : CandyBaseViewController
@property (nonatomic, strong) NoaUserModel *userModel;
@property (nonatomic, copy) NSString *friendUID;
@end

NS_ASSUME_NONNULL_END
