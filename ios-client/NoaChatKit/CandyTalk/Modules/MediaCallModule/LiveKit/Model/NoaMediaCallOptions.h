//
//  NoaMediaCallOptions.h
//  NoaKit
//
//  Created by Candy on 2023/1/6.
//

#import <Foundation/Foundation.h>
#import "NoaMediaCallGroupMemberModel.h"

//多媒体会话房间类型
typedef NS_ENUM(NSUInteger, ZIMCallRoomType) {
    ZIMCallRoomTypeSingle = 0,        //单人
    ZIMCallRoomTypeGroup = 1,         //多人
    ZIMCallRoomTypeMeeting = 2,       //会议
};

NS_ASSUME_NONNULL_BEGIN

@interface NoaMediaCallOptions : NSObject

@property (nonatomic, assign) ZIMCallRoomType callRoomType;//音视频房间类型
@property (nonatomic, assign) LingIMCallType callType;//音视频类型
@property (nonatomic, assign) LingIMCallRoleType callRoleType;//音视频角色类型
@property (nonatomic, copy) NSString *inviterUid;//邀请者Uid
@property (nonatomic, copy) NSString *inviteeUid;//被邀请者Uid
@property (nonatomic, strong) NSArray *inviteeUidList;//多人通话发起邀请时，邀请的人员信息
@property (nonatomic, copy) NSString *groupId;//多人通话群组id


@property (nonatomic, assign) LingIMCallMicrophoneMuteState callMicState;//音频状态
@property (nonatomic, assign) LingIMCallCameraMuteState callCameraState;//视频状态

@property (nonatomic, strong) LIMMediaCallSingleModel *callMediaModel;//单人音视频信息
@property (nonatomic, strong) LIMMediaCallGroupModel *callMediaGroupModel;//多人音视频信息
@property (nonatomic, strong) LIMMediaCallMeetingModel *callMediaMeetingModel;//会议音视频信息

@property (nonatomic, strong) NSMutableArray <NoaMediaCallGroupMemberModel *> *callMediaGroupMemberList;//多人音视频 当前参与者列表



@property (nonatomic, copy) NSString *callRoomUrl;//房间地址
@property (nonatomic, copy) NSString *callRoomToken;//房间令牌
@property (nonatomic, copy) NSString *callRoomId;//房间id
@property (nonatomic, assign) NSInteger callMode;//音视频通话类型 0音视频 1音频
@property (nonatomic, copy) NSString *callState;//音视频通话状态 request请求、waiting等待、accept接受、confirm确认、discard断开连接
@property (nonatomic, copy) NSString *callHashKey;//音视频通话唯一标识id
@property (nonatomic, copy) NSString *callFrom;//音视频通话发起者
@property (nonatomic, copy) NSString *callTo;//音视频通话对方接收者
@property (nonatomic, copy) NSString *callDiscardReason;//音视频通结束原因
@property (nonatomic, assign) NSInteger callDuration;//通话时长
@end

NS_ASSUME_NONNULL_END
