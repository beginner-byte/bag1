//
//  NoaAuthInputTools.m
//  NoaKit
//
//  Created by Candy on 2023/4/7.
//

#import "NoaAuthInputTools.h"

@implementation NoaAuthInputTools

#pragma mark - 校验手机号
+ (BOOL)loginCheckPhoneWithText:(NSString *)text
                    IsShowToast:(BOOL)isShowToast {
    if (text.length <= 0) {
        if (isShowToast) {
            [HUD showMessage:LanguageToolMatch(@"请输入有效手机号")];
        }
        return NO;
    }
    NSString *numberRegex = @".*[0-9]+.*";
    NSPredicate *numberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegex];
    BOOL containsNumber = [numberTest evaluateWithObject:text];
    if (!containsNumber) {
        if (isShowToast) {
            [HUD showMessage:LanguageToolMatch(@"请输入有效手机号")];
        }
        return NO;
    }
    return YES;
}


+ (BOOL)registerCheckPhoneWithText:(NSString *)text
                       IsShowToast:(BOOL)isShowToast {
    if (text.length <= 0) {
        if (isShowToast) {
            [HUD showMessage:LanguageToolMatch(@"请输入有效的手机号码")];
        }
        return NO;
    }
    NSString *numberRegex = @".*[0-9]+.*";
    NSPredicate *numberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegex];
    BOOL containsNumber = [numberTest evaluateWithObject:text];
    if (!containsNumber) {
        if (isShowToast) {
            [HUD showMessage:LanguageToolMatch(@"请输入有效的手机号码")];
        }
        return NO;
    }
    return YES;
}

#pragma mark - 校验邮箱
+ (BOOL)loginCheckEmailWithText:(NSString *)text
                    IsShowToast:(BOOL)isShowToast {
    if (text.length <= 0) {
        if (isShowToast) {
            [HUD showMessage:LanguageToolMatch(@"请输入有效邮箱")];
        }
        return NO;
    }
    
    //邮箱格式校验(不包含 "@" 符号触发)
    NSRange range = [text rangeOfString:@"@"];
    BOOL result = range.location != NSNotFound;
    if (!result) {
        if (isShowToast) {
            [HUD showMessage:LanguageToolMatch(@"请输入有效邮箱")];
        }
        return NO;
    }
    return YES;
}

+ (BOOL)registerCheckEmailWithText:(NSString *)text
                       IsShowToast:(BOOL)isShowToast {
    if (text.length <= 0) {
        if (isShowToast) {
            [HUD showMessage:LanguageToolMatch(@"请输入正确的邮箱格式，如：google@mail.com")];
        }
        return NO;
    }
    
    //邮箱格式校验(不包含 "@" 符号触发)
    NSRange range = [text rangeOfString:@"@"];
    BOOL result = range.location != NSNotFound;
    if (!result) {
        if (isShowToast) {
            [HUD showMessage:LanguageToolMatch(@"请输入正确的邮箱格式，如：google@mail.com")];
        }
        return NO;
    }
    return YES;
}

#pragma mark - 校验账号
+ (BOOL)loginCheckAccountWithText:(NSString *)text
                      IsShowToast:(BOOL)isShowToast {
    if (text.length <= 0) {
        if (isShowToast) {
            [HUD showMessage:LanguageToolMatch(@"请输入账号")];
        }
        return NO;
    }
    if (text.length < 6 || text.length > 16) {
        if (isShowToast) {
            [HUD showMessage:LanguageToolMatch(@"账号长度为6-16位")];
        }
        return NO;
    }
    return YES;
}

+ (BOOL)registerCheckAccountWithText:(NSString *)text
                         IsShowToast:(BOOL)isShowToast {
    if (text.length <= 0) {
        if (isShowToast) {
            [HUD showMessage:LanguageToolMatch(@"请输入账号")];
        }
        return NO;
    }
    if (text.length < 6 || text.length > 16) {
        if (isShowToast) {
            [HUD showMessage:LanguageToolMatch(@"账号长度为6-16位")];
        }
        return NO;
    }
    return YES;
}

#pragma mark - 校验账号 输入完成失去焦点时校验是否为6-16位
+ (BOOL)registerCheckInputAccountEndWithTextLength:(NSString *)text {
    if (text.length < 6 || text.length > 16) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - 校验账号 输入完成失去焦点时校验：账号前两位必须为英文，只支持英文或数字
+ (BOOL)registerCheckInputAccountEndWithTextFormat:(NSString *)text {
    //校验是否为数字+字母组合
    NSString *formatRegex = @"^[a-zA-Z]+$|^[0-9]+$|^[a-zA-Z0-9]+$";
    NSPredicate *formatPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", formatRegex];
    BOOL formatResult = [formatPredicate evaluateWithObject:text];
    
    //校验 前2位是否为字母
    NSString *topTwoStr = [text safeSubstringWithRange:NSMakeRange(0, 2)];
    NSString *topTwoRegex = @"^[A-Za-z]+$";//纯字母
    NSPredicate *topTwoPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", topTwoRegex];
    BOOL topTwoResult = [topTwoPredicate evaluateWithObject:topTwoStr];

    if (formatResult == NO || topTwoResult == NO) {
        return NO;
    }
    return YES;
}

#pragma mark - 校验验证码
+ (BOOL)checkVerCodeWithText:(NSString *)text
                 IsShowToast:(BOOL)isShowToast {
    if (text.length != 6) {
        if (isShowToast) {
            [HUD showMessage:LanguageToolMatch(@"请输入验证码")];
        }
        return NO;
    }
    return YES;
}

//校验密码
+ (BOOL)checkPasswordWithText:(NSString *)text
                  IsShowToast:(BOOL)isShowToast {
    if (text.length <= 0) {
        if (isShowToast) {
            [HUD showMessage:LanguageToolMatch(@"请输入密码")];
        }
        return NO;
    }
    if (text.length < 6 || text.length > 16) {
        if (isShowToast) {
            [HUD showMessage:LanguageToolMatch(@"密码长度为6-16位")];
        }
        return NO;
    }
    return YES;
}

#pragma mark - 校验密码 输入中/粘贴
+ (BOOL)checkCreatPasswordInputWithText:(NSString *)text {
    // 正则表达式
    NSString *validCharactersRegex = @"^[A-Za-z0-9!@#$%^&*\\-+=/\\\\?;:,.~`_\"']*$";

    NSPredicate *validCharactersTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", validCharactersRegex];
        
    BOOL isValidCharacters = [validCharactersTest evaluateWithObject:text];
        
    return isValidCharacters;
}

#pragma mark - 校验密码 输入完成失去焦点时校验是否为6-16位
+ (BOOL)checkCreatPasswordEndWithTextLength:(NSString *)text {
    if (text.length < 6 || text.length > 16) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - 校验密码 输入完成失去焦点时校验是否包含字母和数字
+ (BOOL)checkCreatPasswordEndWithTextFormat:(NSString *)text {
    NSString *letterRegex = @".*[A-Za-z]+.*";
    NSString *numberRegex = @".*[0-9]+.*";
        
    NSPredicate *letterTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", letterRegex];
    NSPredicate *numberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegex];
        
    BOOL containsLetter = [letterTest evaluateWithObject:text];
    BOOL containsNumber = [numberTest evaluateWithObject:text];
        
    return containsLetter && containsNumber;
}

#pragma mark - 校验邀请码
+ (BOOL)checkInviteCodeWithText:(NSString *)text
                    IsShowToast:(BOOL)isShowToast {
    if (text.length <= 0) {
        if (isShowToast) {
            [HUD showMessage:LanguageToolMatch(@"邀请码不能为空")];
        }
        return NO;
    }
    return YES;
}

#pragma mark - 校验昵称
+ (BOOL)checkNickNameWithText:(NSString *)text
                  IsShowToast:(BOOL)isShowToast {
    if (text.length <= 0) {
        if (isShowToast) {
            [HUD showMessage:LanguageToolMatch(@"昵称不能为空")];
        }
        return NO;
    }
    return YES;
}

@end
