//
//  NoaChatRecordDetailViewController.h
//  NoaKit
//
//  Created by Candy on 2023/4/25.
//

#import "CandyBaseViewController.h"
#import "NoaMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaChatRecordDetailViewController : CandyBaseViewController

@property (nonatomic, assign) NSInteger levelNum;
@property (nonatomic, strong) NoaMessageModel *model;

@end

NS_ASSUME_NONNULL_END
