//
//  NoaGroupNotalkMemberModel.h
//  NoaKit
//
//  Created by Candy on 2026/11/17.
//

#import "NoaBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaGroupNotalkMemberModel : NoaBaseModel
@property (nonatomic, copy) NSString *expireTime;//禁言时间
@property (nonatomic, copy) NSString *forbidUserIcon;//头像
@property (nonatomic, copy) NSString *forbidUserNickName;//昵称
@property (nonatomic, copy) NSString *forbidUserUid;//ID
@property (nonatomic, copy) NSString *updateTime;//时间
@property (nonatomic, copy) NSString *groupId;//群id
@property (nonatomic, assign) NSInteger roleId;//角色Id
@end

NS_ASSUME_NONNULL_END
