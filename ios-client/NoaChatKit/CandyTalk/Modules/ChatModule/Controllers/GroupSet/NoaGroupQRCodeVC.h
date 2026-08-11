//
//  NoaGroupQRCodeVC.h
//  NoaKit
//
//  Created by Candy on 2026/11/7.
//

#import "CandyBaseViewController.h"
#import "LingIMGroup.h"
NS_ASSUME_NONNULL_BEGIN

@interface NoaGroupQRCodeVC : CandyBaseViewController

@property (nonatomic, strong)LingIMGroup * groupInfoModel;
@property (nonatomic, copy)NSString *qrcoceContent;
@property (nonatomic, assign) NSInteger expireTime; //过期时间
@end

NS_ASSUME_NONNULL_END
