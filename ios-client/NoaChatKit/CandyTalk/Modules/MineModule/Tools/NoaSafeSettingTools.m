//
//  NoaSafeSettingTools.m
//  NoaKit
//
//  Created by Candy on 2025/1/2.
//

#import "NoaSafeSettingTools.h"

@implementation NoaSafeSettingTools

#pragma mark - 校验安全码 输入完成失去焦点时校验是否为6位，同时包含字母、数字
+ (BOOL)checkInputDeviceSafeCodeEndWithText:(NSString *)text {
    if ([text trimString].length != 6) {
        return NO;
    }
    
    NSString *letterRegex = @".*[A-Za-z]+.*";
    NSString *numberRegex = @".*[0-9]+.*";
        
    NSPredicate *letterTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", letterRegex];
    NSPredicate *numberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegex];
        
    BOOL containsLetter = [letterTest evaluateWithObject:text];
    BOOL containsNumber = [numberTest evaluateWithObject:text];
        
    return containsLetter && containsNumber;
}

@end
