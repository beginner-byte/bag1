//
//  NoaGroupModifyNoticeVC.h
//  NoaKit
//
//  Created by Candy on 2026/11/11.
//

#import "CandyBaseViewController.h"
#import "LingIMGroup.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^SendGroupNoticeSuccessBlock)(void);
@interface NoaGroupModifyNoticeVC : CandyBaseViewController

@property (nonatomic,strong)LingIMGroup * groupInfoModel;

@property (nonatomic, copy) SendGroupNoticeSuccessBlock groupNoticeSuccessBlock;

@end

NS_ASSUME_NONNULL_END
