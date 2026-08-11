//
//  NoaDeviceTool.m
//  NoaKit
//
//  Created by Candy on 2026/8/30.
//

#import "NoaDeviceTool.h"
#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import <SAMKeychain.h>


@implementation NoaDeviceTool

//3.5 / 4 寸手机
+ (BOOL)isSmallScreen{
    return [[UIScreen mainScreen] currentMode].size.width <= 640;
}

//3.5寸
+ (BOOL)isPhone35{
    return [UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO;
}
//4.0寸
+ (BOOL)isPhone40{
    return [UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO;
}
//4.7寸
+ (BOOL)isPhone47{
    return [UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO;
}
//5.5寸
+ (BOOL)isPhone55{
    return [UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO;
}
//5.8寸
+ (BOOL)isPhone58{
    return [UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO;
}
//6.1寸
+ (BOOL)isPhone61{
    return [UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) : NO;
}
//6.5寸
+ (BOOL)isPhone65{
    return [UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) : NO;
}
//5.4寸
+ (BOOL)isPhone54{
    return [UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1080, 2340), [[UIScreen mainScreen] currentMode].size) : NO;
}
//6.7寸
+ (BOOL)isPhone67{
    return [UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1284, 2778), [[UIScreen mainScreen] currentMode].size) : NO;
}

+ (BOOL)isPhonePlus{
    return [UIScreen mainScreen].scale == 3;
}

+ (BOOL)isPhone_X{
    //return [self isPhoneX] || [self isPhoneXR] || [self isPhoneXM];
    return (![self isPhone35] && ![self isPhone40] && ![self isPhone47] && ![self isPhone55]);
}

+ (BOOL)isPhone_X_New{
    // 根据安全区域判断
    if (@available(iOS 11.0, *)) {
        CGFloat height = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom;
        return (height > 0);
    } else {
        return NO;
    }
}

//手机状态栏高度
+ (CGFloat)phoneStatusHeight {
    // 20
    // iPhone X/11 Pro/ 11 Pro Max/12 mini : 44
    // iPhone XR/11 : 48
    // iPhone 12/12 Pro/Pro Max : 47
    
    //因为采用了自定义导航栏，直接取用44
    if ([self isPhone_X_New]) {
        return 44;
    }
    return 20;
}

+ (NSString *)currentDeviceModel{
    
    //https://www.theiphonewiki.com/wiki/Models
    
    struct utsname systemInfo;
    uname(&systemInfo);
       
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
       
    if ([deviceModel isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceModel isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceModel isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceModel isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceModel isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceModel isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceModel isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceModel isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceModel isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
    if ([deviceModel isEqualToString:@"iPhone9,1"])    return @"iPhone 7";//国行、日版、港行
    if ([deviceModel isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";//港行、国行
    if ([deviceModel isEqualToString:@"iPhone9,3"])    return @"iPhone 7";//美版、台版
    if ([deviceModel isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";//美版、台版
    if ([deviceModel isEqualToString:@"iPhone10,1"])   return @"iPhone_8";//国行(A1863)、日行(A1906)
    if ([deviceModel isEqualToString:@"iPhone10,4"])   return @"iPhone_8";//美版(Global/A1905)
    if ([deviceModel isEqualToString:@"iPhone10,2"])   return @"iPhone_8_Plus";//国行(A1864)、日行(A1898)
    if ([deviceModel isEqualToString:@"iPhone10,5"])   return @"iPhone_8_Plus";//美版(Global/A1897)
    if ([deviceModel isEqualToString:@"iPhone10,3"])   return @"iPhone X";//国行(A1865)、日行(A1902)
    if ([deviceModel isEqualToString:@"iPhone10,6"])   return @"iPhone X";//美版(Global/A1901)
    if ([deviceModel isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
    if ([deviceModel isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    if ([deviceModel isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
    if ([deviceModel isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";
    if ([deviceModel isEqualToString:@"iPhone12,1"])   return @"iPhone 11";
    if ([deviceModel isEqualToString:@"iPhone12,3"])   return @"iPhone 11 Pro";
    if ([deviceModel isEqualToString:@"iPhone12,5"])   return @"iPhone 11 Pro Max";
    if ([deviceModel isEqualToString:@"iPhone12,8"])   return @"iPhone SE2";
    if ([deviceModel isEqualToString:@"iPhone13,1"])   return @"iPhone 12 mini";
    if ([deviceModel isEqualToString:@"iPhone13,2"])   return @"iPhone 12";
    if ([deviceModel isEqualToString:@"iPhone13,3"])   return @"iPhone 12  Pro";
    if ([deviceModel isEqualToString:@"iPhone13,4"])   return @"iPhone 12  Pro Max";
    if ([deviceModel isEqualToString:@"iPhone14,4"])   return @"iPhone 13 mini";
    if ([deviceModel isEqualToString:@"iPhone14,5"])   return @"iPhone 13";
    if ([deviceModel isEqualToString:@"iPhone14,2"])   return @"iPhone 13  Pro";
    if ([deviceModel isEqualToString:@"iPhone14,3"])   return @"iPhone 13  Pro Max";
    if ([deviceModel isEqualToString:@"iPhone14,6"])   return @"iPhone SE3";
    if ([deviceModel isEqualToString:@"iPhone14,7"])   return @"iPhone_14";
    if ([deviceModel isEqualToString:@"iPhone14,8"])   return @"iPhone_14_Plus";
    if ([deviceModel isEqualToString:@"iPhone15,2"])   return @"iPhone_14_Pro";
    if ([deviceModel isEqualToString:@"iPhone15,3"])   return @"iPhone_14_Pro_Max";
    
    if ([deviceModel isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceModel isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceModel isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceModel isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceModel isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    if ([deviceModel isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceModel isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([deviceModel isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([deviceModel isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceModel isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([deviceModel isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([deviceModel isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([deviceModel isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceModel isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceModel isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceModel isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([deviceModel isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([deviceModel isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([deviceModel isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([deviceModel isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([deviceModel isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([deviceModel isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([deviceModel isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([deviceModel isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([deviceModel isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";

    if ([deviceModel isEqualToString:@"AppleTV1,1"])      return @"Apple TV 1";
    if ([deviceModel isEqualToString:@"AppleTV2,1"])      return @"Apple TV 2";
    if ([deviceModel isEqualToString:@"AppleTV3,1"])      return @"Apple TV 3";
    if ([deviceModel isEqualToString:@"AppleTV3,2"])      return @"Apple TV 3";
    if ([deviceModel isEqualToString:@"AppleTV5,3"])      return @"Apple TV 4";
    if ([deviceModel isEqualToString:@"AppleTV6,2"])      return @"Apple TV 4K";
    if ([deviceModel isEqualToString:@"AppleTV11,1"])      return @"Apple TV 4K 2";
    
    //模拟器
    if ([deviceModel isEqualToString:@"i386"])         return @"iPhone Simulator";
    if ([deviceModel isEqualToString:@"x86_64"])       return @"iPhone Simulator";
        
    return deviceModel;
}

+ (NSString *)appVersion{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
}

+ (NSString *)appBuild{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+ (NSString *)appBundleIdentifier{
    return [NSBundle mainBundle].bundleIdentifier;
}

+ (NSString *)appUUID{
    CFUUIDRef uuid_ref = CFUUIDCreate(nil);
    CFStringRef uuid_string_ref = CFUUIDCreateString(nil,uuid_ref);
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString * _Nonnull)(uuid_string_ref)];
    CFRelease(uuid_string_ref);
    return uuid;
}

+ (NSString *)appIDFV{
    NSString *strIDFV = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    return strIDFV;
}

+ (NSString *)appUniqueIdentifier{
    //将(IDFV+keychain)作为设备唯一标识
    NSString *IDFVStr = [SAMKeychain passwordForService:APP_SERVICE account:APP_ACCOUNT];
    if ([IDFVStr isEqualToString:@""] || IDFVStr == nil) {
        IDFVStr = [self appIDFV];
        [SAMKeychain setPassword:IDFVStr forService:APP_SERVICE account:APP_ACCOUNT];
    }
    return IDFVStr ? IDFVStr : @"未知设备";
//    return @"5DDD17B7-1DF8-4DF4-BB50-1E318446B90A";
}

//设备系统类型
+ (NSInteger)devicePlatform {
    //平台: IOS 1, ANDROID 2, WEB 3
    return 1;
}

#pragma mark -获取当前系统版本
+ (NSString*)systemVersion {
    NSString * sysVersion = [NSString stringWithFormat:@"iOS%.1f",[[[UIDevice currentDevice] systemVersion] floatValue]];
    return sysVersion;
}

+ (CGFloat)statusBarHeight {
    if (@available(iOS 13.0, *)) {
        return [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager.statusBarFrame.size.height;
     }
     return [UIApplication sharedApplication].statusBarFrame.size.height;
}

@end
