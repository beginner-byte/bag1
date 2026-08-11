//
//  NoaRoleConfigModel.h
//  NoaKit
//
//  Created by Candy on 2024/3/20.
//

#import "NoaBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

//角色配置
@interface NoaRoleConfigModel : NoaBaseModel

@property (nonatomic, assign)NSInteger roleId;
@property (nonatomic, copy)NSString *roleName;
@property (nonatomic, copy)NSString *enName;
@property (nonatomic, assign)BOOL showRoleName;

/// 持久化角色配置信息
+ (void)saveRoleConfigInfoWithDict:(NSDictionary *)roleConfigDict;

/// 获得持久化的角色配置信息
+ (id)getRoleConfigInfo;


@end

NS_ASSUME_NONNULL_END
