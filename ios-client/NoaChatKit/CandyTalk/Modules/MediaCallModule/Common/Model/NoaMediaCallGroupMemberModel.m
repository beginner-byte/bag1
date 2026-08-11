//
//  NoaMediaCallGroupMemberModel.m
//  NoaKit
//
//  Created by Candy on 2023/2/9.
//

#import "NoaMediaCallGroupMemberModel.h"

@implementation NoaMediaCallGroupMemberModel

- (id)copyWithZone:(NSZone *)zone {
    NoaMediaCallGroupMemberModel *model = [[NoaMediaCallGroupMemberModel allocWithZone:zone] init];
    model.memberState = self.memberState;//成员通话状态
    model.userUid = self.userUid;//用户ID
    model.callType = self.callType;//通话类型
    model.groupID = self.groupID;//群聊 群组ID
    model.participantMember = self.participantMember;//LiveKit参与者成员
    model.callUserModel = self.callUserModel;//即构参与者成员
    return model;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    NoaMediaCallGroupMemberModel *model = [[NoaMediaCallGroupMemberModel allocWithZone:zone] init];
    model.memberState = self.memberState;//成员通话状态
    model.userUid = self.userUid;//用户ID
    model.callType = self.callType;//通话类型
    model.groupID = self.groupID;//群聊 群组ID
    model.participantMember = self.participantMember;//LiveKit参与者成员
    model.callUserModel = self.callUserModel;//即构参与者成员
    return model;
}

@end
