//
//  NoaCallOptions.h
//  NoaKit
//
//  Created by Candy on 2023/5/18.
//

#import <Foundation/Foundation.h>
#import "NoaCallUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaCallOptions : NSObject

//SDK即构音视频通话配置项
@property (nonatomic, strong) NoaIMZGCallOptions *zgCallOptions;

//单聊 / 群聊 音视频通话 邀请者信息
@property (nonatomic, strong) NoaCallUserModel *inviterUserModel;

//单聊音视频通话 被邀请者信息
@property (nonatomic, strong) NoaCallUserModel *inviteeUserModel;

//群聊通话 的 群组id
@property (nonatomic, copy) NSString *groupID;
//群聊通话 发起的 被邀请者列表
@property (nonatomic, copy) NSArray <NSString *> *inviteeUserList;
//群聊通话 的 房间成员列表(能进行群聊音视频通话的有效成员)(本地维护的一套成员列表)
@property (nonatomic, copy) __block NSMutableArray <NoaCallUserModel *> *callMemberList;

@end

NS_ASSUME_NONNULL_END
