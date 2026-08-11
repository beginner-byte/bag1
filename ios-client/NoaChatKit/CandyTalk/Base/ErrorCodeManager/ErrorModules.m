//
//  ErrorModules.m
//  NoaKit
//
//  Created by 小梦雯 on 2025/4/21.
//

// ErrorModules.m
#import "ErrorModules.h"

@implementation ErrorModules

+ (NSString *)INITIALIZATION { return @"01"; }
+ (NSString *)NETWORK        { return @"02"; }
+ (NSString *)SINGLE_CHAT    { return @"03"; }
+ (NSString *)GROUP_CHAT     { return @"04"; }
+ (NSString *)AUTHENTICATION { return @"05"; }
+ (NSString *)STORAGE        { return @"06"; }
+ (NSString *)MESSAGE        { return @"07"; }
+ (NSString *)MEDIA          { return @"08"; }
+ (NSString *)OTHER          { return @"99"; }
+ (NSString *)UNKNOWN        { return @"00"; }

+ (NSString *)getModuleDescription:(NSString *)code {
    if (code == nil) {
        return @"未知模块";
    }
    if ([code isEqualToString:[ErrorModules INITIALIZATION]]) {
        return @"初始化模块";
    } else if ([code isEqualToString:[ErrorModules NETWORK]]) {
        return @"网络通讯模块";
    } else if ([code isEqualToString:[ErrorModules SINGLE_CHAT]]) {
        return @"单聊业务模块";
    } else if ([code isEqualToString:[ErrorModules GROUP_CHAT]]) {
        return @"群聊业务模块";
    } else if ([code isEqualToString:[ErrorModules AUTHENTICATION]]) {
        return @"用户认证模块";
    } else if ([code isEqualToString:[ErrorModules STORAGE]]) {
        return @"数据存储模块";
    } else if ([code isEqualToString:[ErrorModules MESSAGE]]) {
        return @"消息处理模块";
    } else if ([code isEqualToString:[ErrorModules MEDIA]]) {
        return @"多媒体模块";
    } else if ([code isEqualToString:[ErrorModules OTHER]]) {
        return @"其他模块";
    } else {
        return @"未知模块";
    }
}

+ (BOOL)isValidModule:(NSString *)code {
    if (code == nil) {
        return NO;
    }
    return ([code isEqualToString:[ErrorModules INITIALIZATION]] ||
            [code isEqualToString:[ErrorModules NETWORK]] ||
            [code isEqualToString:[ErrorModules SINGLE_CHAT]] ||
            [code isEqualToString:[ErrorModules GROUP_CHAT]] ||
            [code isEqualToString:[ErrorModules AUTHENTICATION]] ||
            [code isEqualToString:[ErrorModules STORAGE]] ||
            [code isEqualToString:[ErrorModules MESSAGE]] ||
            [code isEqualToString:[ErrorModules MEDIA]] ||
            [code isEqualToString:[ErrorModules OTHER]]);
}

@end

