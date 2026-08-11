//
//  NoaSafeCodeAuthViewController.h
//  NoaKit
//
//  Created by Candy on 2024/12/30.
//

#import "CandyBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaSafeCodeAuthViewController : CandyBaseViewController

@property (nonatomic, copy)NSString *loginInfo;
@property (nonatomic, assign)int loginType;
@property (nonatomic, copy)NSString *scKey;

@end

NS_ASSUME_NONNULL_END
