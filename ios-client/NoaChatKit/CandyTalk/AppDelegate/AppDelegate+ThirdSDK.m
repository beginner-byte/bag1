//
//  AppDelegate+ThirdSDK.m
//  NoaKit
//
//  Created by Candy on 2023/6/6.
//

#import "AppDelegate+ThirdSDK.h"
//Bugly
#import <pdns-sdk-ios/DNSResolver.h>
@implementation AppDelegate (ThirdSDK)

#pragma mark - 初始化第三方SDK信息
- (void)configThirdSDK {
    [self configAliyunCloundPDNS];
    [self configOpenInstallSDK];
}


//初始化阿里云 云解析DNS
- (void)configAliyunCloundPDNS {
    //DNSResolver初始化
    
}

//初始化openinstall
- (void)configOpenInstallSDK {
    if ([self hasAppInfoOpenInstallAppKey]) {
        [OpenInstallSDK initWithDelegate:self];
    }
}

- (void)openInstallReportRegister {
    if ([self hasAppInfoOpenInstallAppKey]) {
        //用户注册成功后调用
        [OpenInstallSDK reportRegister];
    }
}

- (BOOL)hasAppInfoOpenInstallAppKey {
    NSString *openinstallAppKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"com.openinstall.APP_KEY"];
    if ([NSString isNil:openinstallAppKey]) {
        return NO;
    } else {
        return YES;
    }
}


@end
