//
//  NoaRoleConfigModel.m
//  NoaKit
//
//  Created by Candy on 2024/3/20.
//

#import "NoaRoleConfigModel.h"

@implementation NoaRoleConfigModel

#pragma mark - 持久化角色配置信息
+ (void)saveRoleConfigInfoWithDict:(NSDictionary *)roleConfigDict {
    if ([self conformsToProtocol:@protocol(NSCoding)]) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:roleConfigDict];
        [[MMKV defaultMMKV] setData:data forKey:NSStringFromClass([self class])];
    }
}

#pragma mark - 获得持久化的角色配置信息
+ (id)getRoleConfigInfo {
    if ([self conformsToProtocol:@protocol(NSCoding)]) {
        NSData *data = [[MMKV defaultMMKV] getDataForKey:NSStringFromClass([self class])];
        if (data) {
            id obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            return obj;
        }
    }
    return nil;
}


@end
