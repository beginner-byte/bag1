//
//  NoaMediaCallManager.h
//  NoaKit
//
//  Created by Candy on 2023/1/6.
//

//加入房间通知
#define CALLROOMJOIN      @"callRoomJoin"
//取消通话
#define CALLROOMCANCEL    @"callRoomCancel"
//多人音视频通话 成员信息更新
#define CALLROOMGROUPMEMBERUPDATE   @"callRoomGroupMemberUpdate"
//多人音视频通话 成员离开当前通话
#define CALLROOMGROUPMEMBERLEAVE    @"callRoomGroupMemberLeave"

#import <Foundation/Foundation.h>
#import "NoaMediaCallOptions.h"

//成功回调
typedef void (^ZMediaCallSuccessCallBack)(id _Nullable data, NSString * _Nullable traceId);
//失败回调
typedef void (^ZMediaCallFailureCallback)(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId);

//代理方法
@protocol ZMediaCallManagerDelegate <NSObject>
@optional
//当前通话持续时间
- (void)mediaCallCurrentDuration:(NSInteger)duration;
@end

typedef NS_ENUM(NSUInteger, ZMediaCallState) {
    ZMediaCallStateEnd = 0,   //结束通话进程
    ZMediaCallStateBegin = 1, //开始通话进程
    ZMediaCallStateCall = 2,  //正在通话进程
};

NS_ASSUME_NONNULL_BEGIN

@interface NoaMediaCallManager : NSObject

#pragma mark - 单例
+ (instancetype)sharedManager;
// 单例一般不需要清空，但是在执行某些功能的时候，防止数据清空不及时可以清空一下
- (void)clearManager;

#pragma mark - 方法与属性

//当前通话的信息
@property (nonatomic, strong) NoaMediaCallOptions *currentCallOptions;

//当前房间是否正在通话中(通话已连接成功YES,未成功NO,根据房间状态返回)
@property (nonatomic, assign) BOOL currentRoomCalling;

//当前通话进程的状态(本地维护的一套状态)
@property (nonatomic, assign) ZMediaCallState mediaCallState;

//当前是否是我在屏幕轨道上(YES大屏渲染我的视频轨道，NO大屏渲染远端视频轨道)(单人音视频)
@property (nonatomic, assign) BOOL currentScreenTrackMe;

//当前通话对方用户的信息
@property (nonatomic, strong) NoaUserModel *userModel;

//当前通话时长
@property (nonatomic, weak) id <ZMediaCallManagerDelegate> delegate;

//创建通话计时器
- (void)createCurrentCallDurationTimer;

//销毁通话计时器
- (void)deallocCurrentCallDurationTimer;

#pragma mark - LiveKit SDK
//发起音视频通话(邀请者发起)
- (void)mediaCallRequestWith:(NoaMediaCallOptions *)callOptions onSuccess:(ZMediaCallSuccessCallBack)onSuccess onFailure:(ZMediaCallFailureCallback)onFailure;

//接受音视频通话的邀请(被邀请者同意邀请)
- (void)mediaCallAcceptWith:(NoaMediaCallOptions *)callOptions onSuccess:(ZMediaCallSuccessCallBack)onSuccess onFailure:(ZMediaCallFailureCallback)onFailure;

//取消音视频通话(邀请者/被邀请者取消、挂断、拒绝...)
- (void)mediaCallDiscardWith:(NSMutableDictionary *)params onSuccess:(ZMediaCallSuccessCallBack)onSuccess onFailure:(ZMediaCallFailureCallback)onFailure;

//发起音视频通话者确认通话并创建房间
- (void)mediaCallConfirmWith:(NSMutableDictionary *)params onSuccess:(ZMediaCallSuccessCallBack)onSuccess onFailure:(ZMediaCallFailureCallback)onFailure;

//发起多人音视频通话(邀请者发起)
- (void)mediaCallGroupRequestWith:(NoaMediaCallOptions *)callOptions onSuccess:(ZMediaCallSuccessCallBack)onSuccess onFailure:(ZMediaCallFailureCallback)onFailure;

//接受多人音视频通话的邀请(被邀请者同意邀请)
- (void)mediaCallGroupAcceptWith:(NoaMediaCallOptions *)callOptions onSuccess:(ZMediaCallSuccessCallBack)onSuccess onFailure:(ZMediaCallFailureCallback)onFailure;

//邀请加入多人音视频通话
- (void)mediaCallGroupInviteWith:(NSMutableDictionary *)params onSuccess:(ZMediaCallSuccessCallBack)onSuccess onFailure:(ZMediaCallFailureCallback)onFailure;

//主动加入多人音视频通话
- (void)mediaCallGroupJoinWith:(NSMutableDictionary *)params onSuccess:(ZMediaCallSuccessCallBack)onSuccess onFailure:(ZMediaCallFailureCallback)onFailure;

//取消多人音视频通话(邀请者/被邀请者取消、挂断、拒绝...)
- (void)mediaCallGroupDiscardWith:(NSMutableDictionary *)params onSuccess:(ZMediaCallSuccessCallBack)onSuccess onFailure:(ZMediaCallFailureCallback)onFailure;

//多人音视频通话状态(用于判断某群是否有多人通话)
- (void)mediaCallGroupState:(NSMutableDictionary *)params onSuccess:(ZMediaCallSuccessCallBack)onSuccess onFailure:(ZMediaCallFailureCallback)onFailure;

//断开音视频连接
- (void)mediaCallDisconnect;

//音视频房间信息
- (Room *)mediaCallRoom;

//房间远端参与者
- (NSArray *)mediaCallRoomRemotePaticipants;

//音频是否静默(isMuted:YES开启静默 NO关闭静默)
- (void)mediaCallAudioMute:(BOOL)isMuted complete:(void (^) (BOOL isMuted))muteBlock;

//视频是否静默(isMuted:YES开启静默 NO关闭静默)
- (void)mediaCallVideoMute:(BOOL)isMuted complete:(void (^) (BOOL isMuted))muteBlock;

//音频输出方式(isSpeaker:NO听筒YES扬声器)
- (void)mediaCallAudioSpeaker:(BOOL)isSpeaker;

//视频摄像头方向切换
- (void)mediaCallVideoCameraSwitch:(void (^) (BOOL success))cameraSwitchResult;

//连接房间
- (void)mediaCallConnectRoomWith:(NoaIMCallOptions *)callOptions delegate:(id <RoomDelegateObjC> _Nullable)roomDelegate;

//服从房间代理
- (void)mediaCallRoomDelegate:(id <RoomDelegateObjC> _Nullable)roomDelegate;

//某轨道参与者的视频是否静默
- (BOOL)mediaCallRoomVideoMutedWith:(Participant *)aParticipant;

//某轨道参与者的音频是否静默
- (BOOL)mediaCallRoomAudioMutedWith:(Participant *)aParticipant;


//音视频通话权限提示框
- (void)showPermissionTip;
@end

NS_ASSUME_NONNULL_END
