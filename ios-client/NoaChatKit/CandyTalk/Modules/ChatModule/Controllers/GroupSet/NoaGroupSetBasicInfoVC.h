//
//  NoaGropuSetBasicInfoVC.h
//  NoaKit
//
//  Created by Candy on 2026/11/7.
//

#import "CandyBaseViewController.h"
#import "LingIMGroup.h"
NS_ASSUME_NONNULL_BEGIN

@interface NoaGroupSetBasicInfoVC : CandyBaseViewController

@property (nonatomic,strong)LingIMGroup * groupInfoModel;

- (void)reloadCurData;

@end

NS_ASSUME_NONNULL_END
