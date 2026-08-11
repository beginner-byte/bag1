//
//  AppDelegate+ThirdSDK.h
//  NoaKit
//
//  Created by Candy on 2023/6/6.
//

#import "AppDelegate.h"
#import "OpenInstallSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (ThirdSDK) <OpenInstallDelegate>

- (void)configThirdSDK;
- (void)openInstallReportRegister;

@end

NS_ASSUME_NONNULL_END
