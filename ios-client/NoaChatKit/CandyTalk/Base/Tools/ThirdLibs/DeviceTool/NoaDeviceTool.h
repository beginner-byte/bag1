//
//  NoaDeviceTool.h
//  NoaKit
//
//  Created by Candy on 2026/8/30.
//

/**
！根据不同尺寸区分设备！ 同尺寸设备以"_"区分
设备最新尺寸参考官方原文：https://developer.apple.com/ios/human-interface-guidelines/icons-and-images/launch-screen/
*/

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaDeviceTool : NSObject

//小屏幕判断(4寸)
+ (BOOL)isSmallScreen;

//3.5寸
+ (BOOL)isPhone35;//iPhone 1 3G 3GS 4 4S
//4寸
+ (BOOL)isPhone40;//iPhone 5 5S 5C SE
//4.7寸
+ (BOOL)isPhone47;//iPhone 6 6S 7 8 SE2
//5.4寸
+ (BOOL)isPhone54;//iPhone 12mini 13mini
//5.5寸
+ (BOOL)isPhone55;//iPhone 6Plus 6SPlus 7Plus 8Plus
//5.8寸
+ (BOOL)isPhone58;//iPhone X XS 11Pro
//6.1寸
+ (BOOL)isPhone61;//iPhone XR 11 12 12Pro 13 13Pro
//6.5寸
+ (BOOL)isPhone65;//iPhone XSMax 11ProMax
//6.7寸
+ (BOOL)isPhone67;//iPhone 12ProMax 13ProMax

//plus手机
+ (BOOL)isPhonePlus;

//全面屏手机
+ (BOOL)isPhone_X;
//全面屏手机(根据底部安全区)
+ (BOOL)isPhone_X_New;

//手机状态栏高度
+ (CGFloat)phoneStatusHeight;

//当前设备型号
+ (NSString *)currentDeviceModel;

//App版本号
+ (NSString *)appVersion;

//AppBuildID
+ (NSString *)appBuild;

//AppBundleIdentifier
+ (NSString *)appBundleIdentifier;

//UUID
+ (NSString *)appUUID;

//IDFV
+ (NSString *)appIDFV;

//设备唯一标识
+ (NSString *)appUniqueIdentifier;

//设备系统类型
+ (NSInteger)devicePlatform;

//获取当前系统版本
+ (NSString*)systemVersion;

//获取设备状态栏高度
+ (CGFloat)statusBarHeight;

@end

NS_ASSUME_NONNULL_END
