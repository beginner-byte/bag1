//
//  NoaMediaCallGroupMemberModel.h
//  NoaKit
//
//  Created by Candy on 2023/2/9.
//

#import "NoaBaseModel.h"
#import "NoaCallUserModel.h"//即构SDK用户信息

NS_ASSUME_NONNULL_BEGIN

@interface NoaMediaCallGroupMemberModel : NoaBaseModel
@property (nonatomic, assign) ZCallUserState memberState;//成员通话状态
@property (nonatomic, copy) NSString *userUid;//用户Uid
@property (nonatomic, assign) LingIMCallType callType;//通话类型
@property (nonatomic, copy) NSString *groupID;//群ID

//LiveKit参与者成员
@property (nonatomic, strong) Participant *participantMember;

//即构参与者成员
@property (nonatomic, strong) NoaCallUserModel *callUserModel;

@end

NS_ASSUME_NONNULL_END
