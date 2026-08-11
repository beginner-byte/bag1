//
//  InitializationSubModules.m
//  NoaKit
//
//  Created by 小梦雯 on 2025/4/21.
//

// InitializationSubModules.m
#import "InitializationSubModules.h"


@implementation InitializationSubModules
//DNS全部失败
+ (NSString *)DNS_ALL_FAILED {
    return @"0";
}
//DNS主域名成功
+ (NSString *)DNS_MAIN {
    return @"1";
}
//DNS备域名成功
+ (NSString *)DNS_BACKUP {
    return @"2";
}
//DNS全部成功
+ (NSString *)DNS_ALL_SUCCESS {
    return @"3";
}

//全部失败
+ (NSString *)BUCKET_ALL_FAIL {
    return @"0";
}
//主域名主桶成功
+ (NSString *)BUCKET_MAIN_MAIN{
    return @"1";
}
//主域名备桶成功
+ (NSString *)BUCKET_MAIN_BACKUP{
    return @"2";
}
//备域名主桶成功
+ (NSString *)BUCKET_BACKUP_MAIN{
    return @"3";
}
//备域名备桶成功
+ (NSString *)BUCKET_BACKUP_BACKUP{
    return @"4";
}
//内置主桶成功
+ (NSString *)BUCKET_INNER_MAIN{
    return @"5";
}
//内置备桶成功
+ (NSString *)BUCKET_INNER_BACKUP{
    return @"6";
}
//aws桶成功
+ (NSString *)BUCKET_AWS{
    return @"7";
}

+ (NSString *)UNKNOWN {
    return @"00";
}

+ (NSString *)getSubModuleDescription:(NSString *)code {
    if (code == nil) {
        return @"未知子模块";
    }
    return @"未知子模块";
}

+ (BOOL)isValidSubModule:(NSString *)code {
    if (code == nil) {
        return NO;
    }
    return YES;
}

@end
