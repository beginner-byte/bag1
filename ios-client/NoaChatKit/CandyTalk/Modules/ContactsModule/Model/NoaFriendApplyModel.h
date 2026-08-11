//
//  NoaFriendApplyModel.h
//  NoaKit
//
//  Created by Candy on 2026/10/20.
//

#import "NoaBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaFriendApplyModel : NoaBaseModel
@property (nonatomic, copy) NSString *beUserUid;//被邀请的用户ID
@property (nonatomic, copy) NSString *beUserAvatar;//被邀请的用户头像
@property (nonatomic, copy) NSString *beUserNickname;//被邀请的用户昵称、
@property (nonatomic, assign) NSInteger beStatus;//请求状态 0: 申请中 1:已通过 2:已过期
@property (nonatomic, assign) NSInteger beDisableStatus;//是否注销状态 4：已注销
@property (nonatomic, assign) NSInteger beRoleId;//角色Id

@property (nonatomic, copy) NSString *fromUserUid;//发起邀请的用户ID
@property (nonatomic, copy) NSString *fromUserAvatar;//发起邀请的用户头像
@property (nonatomic, copy) NSString *nickname;//用户昵称
@property (nonatomic, assign) NSInteger fromDisableStatus;//是否注销状态 4：已注销
@property (nonatomic, assign) NSInteger fromRoleId;//角色Id

@property (nonatomic, assign) NSInteger friendAddType;//好友添加方式 1搜索 0扫码
@property (nonatomic, copy) NSString *userUid;//当前视角的用户ID
@property (nonatomic, copy) NSString *beTime;//添加好友时间戳
@property (nonatomic, copy) NSString *sendTime;//添加时间
@property (nonatomic, copy) NSString *sendIp;//添加IP
@property (nonatomic, copy) NSString *ID;//主键ID
@property (nonatomic, copy) NSString *hashKey;//hash索引


@end

NS_ASSUME_NONNULL_END
