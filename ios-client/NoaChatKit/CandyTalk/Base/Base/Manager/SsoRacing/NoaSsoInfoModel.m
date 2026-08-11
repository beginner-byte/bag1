//
//  NoaSsoInfoModel.m
//  NoaKit
//
//  Created by Candy on 2026/9/15.
//

#import "NoaSsoInfoModel.h"

@implementation NoaSsoInfoModel

#pragma mark - 是否设置SSO
+ (BOOL)isConfigSSO {
    if ([self conformsToProtocol:@protocol(NSCoding)]) {
        NSData *data = [[MMKV defaultMMKV] getDataForKey:NSStringFromClass([self class])];
        if (data) {
            NoaSsoInfoModel *obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            if (obj && ![NSString isNil:obj.liceseId]) {
                return YES;
            } else {
                return NO;
            }
        }
    }
    return NO;
}

#pragma mark - Getter
- (NSString *)liceseId {
    return _liceseId ? _liceseId : @"";
}

//获取IP或者域名
- (NSString *)ipDomainPortStr {
    return _ipDomainPortStr ? _ipDomainPortStr : @"";
}

#pragma mark - 保存SSO信息
- (void)saveSSOInfo {
    //保存
    if ([self conformsToProtocol:@protocol(NSCoding)]) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
        //NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self requiringSecureCoding:YES error:nil];
        [[MMKV defaultMMKV] setData:data forKey:NSStringFromClass([self class])];
    }
}

#pragma mark - 保存对应邀请码SSO信息
- (void)saveSSOInfoWithLiceseId:(NSString *)liceseId {
    //保存
    if ([self conformsToProtocol:@protocol(NSCoding)]) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
//        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self requiringSecureCoding:YES error:nil];
        NSString *key = [NSString stringWithFormat:@"%@%@",OSS_LOCAL_CACHE,liceseId];
        [[MMKV defaultMMKV] setData:data forKey:key];
    }
}

#pragma mark - 获取SSO信息
+ (NoaSsoInfoModel *)getSSOInfo {
    if ([self conformsToProtocol:@protocol(NSCoding)]) {
        NSData *data = [[MMKV defaultMMKV] getDataForKey:NSStringFromClass([self class])];
        if (data) {
            NoaSsoInfoModel *obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            //ZSsoInfoModel *obj = [NSKeyedUnarchiver unarchivedObjectOfClass:self fromData:data error:nil];
            return obj;
        }
    }
    return nil;
}

#pragma mark - 获取对应邀请码SSO信息整体model
+ (NoaSsoInfoModel *)getSSOInfoWithLiceseId:(NSString *)liceseId {
    if ([self conformsToProtocol:@protocol(NSCoding)]) {
        NSString *key = [NSString stringWithFormat:@"%@%@",OSS_LOCAL_CACHE,liceseId];
        NSData *data = [[MMKV defaultMMKV] getDataForKey:key];
        if (data) {
            NoaSsoInfoModel *obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            //ZSsoInfoModel *obj = [NSKeyedUnarchiver unarchivedObjectOfClass:self fromData:data error:nil];
            return obj;
        }
    }
    return nil;
}

#pragma mark - 获取SSO信息里的邀请码或者直连的ip/域名+端口号
+ (NSString *)getSSOInfoDetailInfo {
    NSString *ssoDetailInfo = @"";
    if ([self conformsToProtocol:@protocol(NSCoding)]) {
        NSData *data = [[MMKV defaultMMKV] getDataForKey:NSStringFromClass([self class])];
        if (data) {
            NoaSsoInfoModel *obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            if (obj) {
                if (![NSString isNil:obj.liceseId]) {
                    ssoDetailInfo = obj.liceseId;
                }
                if (![NSString isNil:obj.ipDomainPortStr]) {
                    ssoDetailInfo = obj.ipDomainPortStr;
                }
            }
            return ssoDetailInfo;
        }
    }
    return ssoDetailInfo;
}

#pragma mark - 清除SSO信息
+ (void)clearSSOInfo {
    [[MMKV defaultMMKV] removeValueForKey:NSStringFromClass([self class])];
}

#pragma mark - 清除对应邀请码SSO信息
+ (void)clearSSOInfoWithLiceseId:(NSString *)liceseId{
    NSString *key = [NSString stringWithFormat:@"%@%@",OSS_LOCAL_CACHE,liceseId];
    [[MMKV defaultMMKV] removeValueForKey:key];
}


@end
