//
//  AppDelegate+DB.h
//  NoaKit
//
//  Created by Candy on 2026/10/26.
//

#import "AppDelegate.h"
#import "CandyTabBarController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (DB)
<
NoaToolUserDelegate,
NoaToolConnectDelegate,
NoaToolMessageDelegate,
NoaToolSessionDelegate
>

//配置SDK
- (void)configDB;

@end

NS_ASSUME_NONNULL_END
