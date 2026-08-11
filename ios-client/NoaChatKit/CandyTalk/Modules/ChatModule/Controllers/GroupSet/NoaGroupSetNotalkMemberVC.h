//
//  NoaGroupSetNotalkMemberVC.h
//  NoaKit
//
//  Created by Candy on 2026/11/15.
//

#import "CandyBaseViewController.h"
#import "LingIMGroup.h"
NS_ASSUME_NONNULL_BEGIN

@interface NoaGroupSetNotalkMemberVC : CandyBaseViewController
@property (nonatomic,strong)LingIMGroup * groupInfoModel;
@property (nonatomic,strong)NSArray * notalkFriendIDArr;//已经禁言好友ID
@end

NS_ASSUME_NONNULL_END
