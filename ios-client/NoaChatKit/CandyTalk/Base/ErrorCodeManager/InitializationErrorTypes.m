//
//  InitializationErrorTypes.m
//  NoaKit
//
//  Created by 小梦雯 on 2025/4/21.
//

// InitializationErrorTypes.m
#import "InitializationErrorTypes.h"

@implementation InitializationErrorTypes
+ (NSString *)UNKNOWN {
    return @"";
}

+ (NSString *)OSS_FAILURE {
    return @"00";
}

+ (NSString *)OSS_NONEXISTENT_FAILURE {
    return @"01";
}

+ (NSString *)OSS_VOID_FAILURE {
    return @"02";
}

+ (NSString *)OSS_DECODE_FAILURE {
    return @"03";
}

+ (NSString *)HTTP_FAILURE {
    return @"10";
}

+ (NSString *)HTTP_DECODE_FAILURE {
    return @"11";
}

+ (NSString *)TCP_FAILURE {
    return @"20";
}

+ (NSString *)systemConfig_failure {
    return @"21";
}

+ (NSString *)getErrorTypeDescription:(NSString *)code {
    if (code == nil) {
            return @"未知错误类型";
        }

        if ([code isEqualToString:[self OSS_FAILURE]] ||
            [code isEqualToString:[self OSS_NONEXISTENT_FAILURE]] ||
            [code isEqualToString:[self OSS_VOID_FAILURE]] ||
            [code isEqualToString:[self OSS_DECODE_FAILURE]]) {
            return @"获取邀请码失败";
        } else if ([code isEqualToString:[self HTTP_FAILURE]] ||
                   [code isEqualToString:[self HTTP_DECODE_FAILURE]]) {
            return @"短链接竞速失败";
        } else if ([code isEqualToString:[self TCP_FAILURE]] || [code isEqualToString:[self systemConfig_failure]]) {
            return @"长链接竞速失败";
        } else {
            return @"未知错误类型";
        }
}

+ (BOOL)isValidErrorType:(NSString *)code {
    if (code == nil) {
            return NO;
        }

        return [code isEqualToString:[self OSS_FAILURE]] ||
               [code isEqualToString:[self OSS_NONEXISTENT_FAILURE]] ||
               [code isEqualToString:[self OSS_VOID_FAILURE]] ||
               [code isEqualToString:[self OSS_DECODE_FAILURE]] ||
               [code isEqualToString:[self HTTP_FAILURE]] ||
               [code isEqualToString:[self HTTP_DECODE_FAILURE]] ||
               [code isEqualToString:[self TCP_FAILURE]] ||
               [code isEqualToString:[self systemConfig_failure]];
}

+ (BOOL)isErrorCodeGreater:(NSString *)newCode than:(NSString *)currentCode {
    if ([[self UNKNOWN] isEqualToString:currentCode]) {
        return YES;
    }

    @try {
        NSInteger newNum = [newCode integerValue];
        NSInteger currentNum = [currentCode integerValue];
        return newNum > currentNum;
    } @catch (NSException *exception) {
        return NO;
    }
}
@end
