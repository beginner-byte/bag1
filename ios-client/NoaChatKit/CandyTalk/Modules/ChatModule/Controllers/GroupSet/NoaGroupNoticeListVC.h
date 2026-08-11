//
//  NoaGroupNoticeListVC.h
//  NoaKit
//
//  Created by phl on 2025/8/11.
//

#import "CandyBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
@class LingIMGroup;
@interface NoaGroupNoticeListVC : CandyBaseViewController

/// 当前群信息
@property (nonatomic, strong) LingIMGroup *groupInfoModel;

/// 刷新公告列表
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
