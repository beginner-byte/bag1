//
//  NoaMassMessageUserVC.h
//  NoaKit
//
//  Created by Candy on 2023/4/19.
//

// 群发助手-转发接收人展示列表(全部列表和失败列表)

#import "CandyBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaMassMessageUserVC : CandyBaseViewController
@property (nonatomic, assign) BOOL allUsers;
@property (nonatomic, strong) LIMMassMessageModel *messageModel;
@end

NS_ASSUME_NONNULL_END
