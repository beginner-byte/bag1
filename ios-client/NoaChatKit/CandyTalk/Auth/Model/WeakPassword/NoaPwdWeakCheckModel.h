//
//  NoaPwdWeakCheckModel.h
//  NoaChatKit
//
//  Created by blackcat on 2025/10/13.
//

#import <Foundation/Foundation.h>


@interface NoaPwdWeakCheckModelRoleConfigMap : NSObject
/// forced_password_reset 是否强制重置
@property (nonatomic, assign) BOOL forcedPasswordReset;

@end

@interface NoaPwdWeakCheckModel : NSObject
/// 是否是弱密码或与账号相同
@property (nonatomic, assign) BOOL isWeakPassword;
/// type的类型： PASSWORD_EQ_ACCOUNT 与账号相同，WEEK_PASSWORD 弱密码
@property (nonatomic, copy) NSString *type;
/// roleConfigMap的类型： forced_password_reset 是否强制重置
@property (nonatomic, strong) NoaPwdWeakCheckModelRoleConfigMap *roleConfigMap;

@end



