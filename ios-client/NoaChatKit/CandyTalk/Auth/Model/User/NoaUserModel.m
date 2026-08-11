//
//  NoaUserModel.m
//  NoaKit
//
//  Created by Candy on 2026/9/15.
//

#import "NoaUserModel.h"

#define USER_AUTH_LOCAL_PER_PHONE     @"user_auth_local_per_phone"
#define USER_AUTH_LOCAL_PER_EMAIL     @"user_auth_local_per_email"
#define USER_AUTH_LOCAL_PER_ACCOUNT   @"user_auth_local_per_account"

@implementation NoaUserModel

- (NSString *)showName{
    if([self.remarks isEqualToString:@""] || !self.remarks){
        return self.nickname ? self.nickname : @"";
    } else {
        return self.remarks ? self.remarks : @"";
    }
}

#pragma mark - 是否是自己
- (BOOL)isMySelf {
    return [self.userUID isEqualToString:UserManager.userInfo.userUID];
}

#pragma mark - 持久化用户信息
- (void)saveUserInfo {
    if ([self conformsToProtocol:@protocol(NSCoding)]) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
        [[MMKV defaultMMKV] setData:data forKey:NSStringFromClass([self class])];
    }
}

#pragma mark - 获得持久化的用户信息
+ (id)getUserInfo {
    if ([self conformsToProtocol:@protocol(NSCoding)]) {
        NSData *data = [[MMKV defaultMMKV] getDataForKey:NSStringFromClass([self class])];
        if (data) {
            id obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            return obj;
        }
    }
    return nil;
}

#pragma mark - 清除持久化的用户信息
+ (void)clearUserInfo {
    [[MMKV defaultMMKV] removeValueForKey:NSStringFromClass([self class])];
}
- (void)clearUserLoginInfo{
    [[MMKV defaultMMKV] removeValueForKey:NSStringFromClass([self class])];
    
}

#pragma mark - 保存上次登录的账号，下次登录时自动填充到输入框
+ (void)savePreAccount:(NSString *)perAccount Type:(int)accountType {
    if (![NSString isNil:perAccount]) {
        if(accountType == UserAuthTypePhone) {
            [[MMKV defaultMMKV] setString:perAccount forKey:USER_AUTH_LOCAL_PER_PHONE];
        }
        if(accountType == UserAuthTypeEmail) {
            [[MMKV defaultMMKV] setString:perAccount forKey:USER_AUTH_LOCAL_PER_EMAIL];
        }
        if(accountType == UserAuthTypeAccount) {
            [[MMKV defaultMMKV] setString:perAccount forKey:USER_AUTH_LOCAL_PER_ACCOUNT];
        }
    }
}

#pragma mark - 获取本地保存上次登录的账号，登录时自动填充到输入框
+ (NSString *)getPreAccountWithType:(int)accountType {
    NSString *localPerAccount = @"";
    if(accountType == UserAuthTypePhone) {
        localPerAccount = [[MMKV defaultMMKV] getStringForKey:USER_AUTH_LOCAL_PER_PHONE];
    }
    if(accountType == UserAuthTypeEmail) {
        localPerAccount = [[MMKV defaultMMKV] getStringForKey:USER_AUTH_LOCAL_PER_EMAIL];
    }
    if(accountType == UserAuthTypeAccount) {
        localPerAccount = [[MMKV defaultMMKV] getStringForKey:USER_AUTH_LOCAL_PER_ACCOUNT];
    }
    if (![NSString isNil:localPerAccount]) {
        return localPerAccount;
    }
    return @"";
}

@end
