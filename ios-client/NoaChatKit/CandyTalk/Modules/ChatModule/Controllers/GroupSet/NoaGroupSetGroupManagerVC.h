//
//  NoaGroupSetGroupManagerVC.h
//  NoaKit
//
//  Created by Candy on 2026/11/16.
//

#import "CandyBaseViewController.h"
#import "LingIMGroup.h"
NS_ASSUME_NONNULL_BEGIN

@interface NoaGroupSetGroupManagerVC : CandyBaseViewController

@property (nonatomic,strong)LingIMGroup * groupInfoModel;
@property (nonatomic,strong)NSArray * mangerIdArr;

@end

NS_ASSUME_NONNULL_END
