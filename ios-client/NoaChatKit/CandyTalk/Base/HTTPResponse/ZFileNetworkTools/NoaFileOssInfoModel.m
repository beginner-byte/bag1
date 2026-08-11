//
//  ZFileOssInfoModel.m
//  CIMKit
//
//  Created by Candy on 2023/6/16.
//

#import "NoaFileOssInfoModel.h"

@implementation NoaFileOssInfoModel

#pragma mark - 检查云存储平台信息是否存在并检查是否过期
+ (BOOL)isTokenAvailableUse {
    if ([self conformsToProtocol:@protocol(NSCoding)]) {
        NSData *data = [USERDEFAULTS objectForKey:NSStringFromClass([self class])];
        if (data) {
            NoaFileOssInfoModel *obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            if (obj) {
                //检查是否存在
                if ([ZHostTool.appSysSetModel.oss_config_type isEqualToString:@"1"] && ![NSString isNil:obj.aliyunSecurityToken]) {
                    /// aliyun
                    //检查是否过期
                    BOOL isExpire = [NSDate checkCloudStoreageDataTimeExpireWith:obj.aliyunExpiration];
                    if (isExpire) {
                        //已过期，token不可用
                        return NO;
                    } else {
                        //未过期，token可用
                        return YES;
                    }
                }
                if ([ZHostTool.appSysSetModel.oss_config_type isEqualToString:@"2"] && ![NSString isNil:obj.awss3sessionToken]) {
                    // AWS S3
                    //检查是否过期
                    BOOL isExpire = [NSDate checkCloudStoreageDataTimeExpireWith:obj.awss3Expiration];
                    if (isExpire) {
                        //已过期，token不可用
                        return NO;
                    } else {
                        //未过期，token可用
                        return YES;
                    }
                }
            } else {
                //token不可用
                return NO;
            }
        }
    }
    return NO;
}

#pragma mark - 保存云存储平台信息
- (void)saveCloudStorageInfo {
    //保存
    if ([self conformsToProtocol:@protocol(NSCoding)]) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
        [USERDEFAULTS setObject:data forKey:NSStringFromClass([self class])];
        [USERDEFAULTS synchronize];
    }
}

#pragma mark - 获取云存储平台信息
+ (NoaFileOssInfoModel *)getCloudStorageInfo {
    if ([self conformsToProtocol:@protocol(NSCoding)]) {
        NSData *data = [USERDEFAULTS objectForKey:NSStringFromClass([self class])];
        if (data) {
            NoaFileOssInfoModel *obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            return obj;
        }
    }
    return nil;
}

#pragma mark - 清除上传token信息
+ (void)clearCloudStorageInfo {
    [USERDEFAULTS removeObjectForKey:NSStringFromClass([self class])];
    [USERDEFAULTS synchronize];
}


@end
