//
//  NoaSystemMessageModel.h
//  NoaKit
//
//  Created by Candy on 2023/5/10.
//

#import "NoaBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaSystemMessageModel : NoaBaseModel

@property (nonatomic, copy) NSString *batchId;
@property (nonatomic, copy) NSString *beDesc;
@property (nonatomic, copy) NSString *beInviteNickname; 
@property (nonatomic, copy) NSString *beInviteTime;
@property (nonatomic, assign) NSInteger beInviteType;
@property (nonatomic, copy) NSString *beInviteUserId;
@property (nonatomic, assign) NSInteger beStatus;//状态  1：申请  4:已进群  5:已拒绝
@property (nonatomic, copy) NSString *beUserAvatarFileName;
@property (nonatomic, assign) NSInteger roleId;//角色Id
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, assign) NSInteger num;
@property (nonatomic, copy) NSString *userAvatarFileName;
@property (nonatomic, copy) NSString *userNickName;
@property (nonatomic, copy) NSString *userUid;
@property (nonatomic, copy) NSString *memreqUuid;

//选中的状态(是否选中)
@property (nonatomic, assign)BOOL selectedStatus;

@end

NS_ASSUME_NONNULL_END
