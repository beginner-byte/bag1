//
//  NoaCallManager.h
//  NoaKit
//
//  Created by Candy on 2023/5/18.
//

//加入房间通知
#define ZGCALLROOMJOIN         @"zgCallRoomJoin"
//结束房间通知(我参与的)
#define ZGCALLROOMEND          @"zgCallRoomEnd"
//房间里用户摄像头静默状态改变通知
#define ZGCALLROOMCAMERAMUTE   @"zgCallRoomCameraMute"
//单人音视频通话 成员信息更新
#define ZGCALLROOMSINGLEMEMBERUPDATE   @"zgCallRoomSingleMemberUpdate"
//多人音视频通话 成员信息更新
#define ZGCALLROOMGROUPMEMBERUPDATE   @"zgCallRoomGroupMemberUpdate"
//其它房间变化通知(我所在的某个群 有群聊音视频，但是我没有参与；其房间变化：开始/结束/成员变化)
#define ZGCALLROOMOTHERCHANGE   @"zgCallRoomOtherChange"

#import <Foundation/Foundation.h>
#import "NoaCallOptions.h"

NS_ASSUME_NONNULL_BEGIN

//成功回调
typedef void (^ZCallSuccessBlock)(id _Nullable data, NSString * _Nullable traceId);
//失败回调
typedef void (^ZCallFailureBlock)(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId);


//当前通话状态
typedef NS_ENUM(NSUInteger, ZCallState) {
    ZCallStateEnd = 0,      //结束通话进程
    ZCallStateBegin = 1,    //开始通话进程
    ZCallStateCalling = 2,  //正在通话进程
};

//代理方法
@protocol ZCallManagerDelegate <NSObject>
@optional
//当前通话持续时间
- (void)currentCallDurationTime:(NSInteger)duration;
@end


@interface NoaCallManager : NSObject

#pragma mark - 单例
+ (instancetype)sharedManager;
// 单例一般不需要清空，但是在执行某些功能的时候，防止数据清空不及时可以清空一下
- (void)clearManager;

#pragma mark - 方法与属性
//采用哪个SDK实现音视频通话
@property (nonatomic, assign) LingIMCallSDKType callSDKType;
//当前通话进程的状态(本地维护的一套状态)
@property (nonatomic, assign) ZCallState callState;
//当前通话的信息
@property (nonatomic, strong) __block NoaCallOptions * _Nullable currentCallOptions;

//当前是否我的轨道在主屏幕上(单人音视频模式)
@property (nonatomic, assign) BOOL showMeTrack;

//代理方法
@property (nonatomic, weak) id <ZCallManagerDelegate> delegate;

//创建通话计时器
- (void)createCurrentCallDurationTimer;
//销毁通话计时器
- (void)deallocCurrentCallDurationTimer;

//创建音视频通话心跳计时器
- (void)createCallHeartBeatTimer;
//销毁音视频通话心跳计时器
- (void)deallocCallHeartBeatTimer;

#pragma mark - 业务层功能
/// 发起 单聊 音视频通话
/// - Parameters:
///   - inviteeDict: 被邀请者信息
///   - callType: 通话类型，语音/视频通话
- (void)requestSingleCallWith:(NSMutableDictionary *)inviteeDict callType:(LingIMCallType)callType;

/// 发起 群聊 音视频通话
/// - Parameters:
///   - inviteeList: 被邀请者列表
///   - groupID: 群ID
///   - callType: 通话类型，语音/视频通话
- (void)requestGroupCallWith:(NSMutableArray *)inviteeList group:(NSString *)groupID callType:(LingIMCallType)callType;

#pragma mark - SDK功能
//sdk基本信息配置
- (void)callSdkConfigWith:(NoaIMZGCallConfig *)config;
// 创建 ZegoExpressEngine 单例对象并初始化 SDK(第一步)
- (void)callRoomCreateEngineWithOptions:(NoaIMZGCallOptions *)callOptions;
// 登录房间(第二步)
- (void)callRoomLogin:(LingIMZGLoginRoomBlock)block;
// 开始推流(第三步)
- (void)callRoomStartPublish;
// 停止推流
- (void)callRoomStopPublish;
// 退出房间
- (void)callRoomLogout;
// 开始拉流
- (void)callRoomStartPlayingStream:(NSString *)streamID with:(UIView  * _Nullable)viewPreview;
// 停止拉流
- (void)callRoomStopPlayingStram:(NSString *)streamID;
// 服从代理
- (void)callRoomDelegate:(id <ZegoEventHandler>)roomDelegate;
// 开始视频预览
- (void)callRoomStartPreviewWith:(UIView *)viewPreview;
// 停止视频预览
- (void)callRoomStopPreview;
// 用户房间类型
- (LingIMCallType)callRoomType;
//麦克风静默
- (void)callRoomMicrophoneMute:(BOOL)mute;
//麦克风静默状态
- (LingIMCallMicrophoneMuteState)callRoomMirophoneState;
//摄像头静默
- (void)callRoomCameraMute:(BOOL)mute;
//摄像头静默状态
- (LingIMCallCameraMuteState)callRoomCameraState;
//使用前置摄像头
- (void)callRoomCameraUseFront:(BOOL)frontEnable;
//摄像头方向
- (LingIMCallCameraDirection)callRoomCameraDirection;
//扬声器静默
- (void)callRoomSpeakerMute:(BOOL)mute;
//扬声器静默状态
- (LingIMCallSpeakerMuteState)callRoomSpeakerState;
//清除通话配置信息
- (void)clearManagerConfig;

#pragma mark - 接口
/// 发起音视频通话请求接口
/// - Parameters:
///   - callOptions: 发起请求时，相关的参数
///   即构：{callType:Voice语音通话，Video视频通话；chatType:SINGLE_CHAT单聊，GROUP_CHAT群聊；friendIds:好友/用户ID(数组)；groupId:群聊时必填}
- (void)callRequestWith:(NoaCallOptions *)callOptions onSuccess:(ZCallSuccessBlock)onSuccess onFailure:(ZCallFailureBlock)onFailure;

/// 接受音视频通话请求
/// - Parameters:
///   - params: 参数(根据使用的SDK不同，参数是不同的，注意区分)
///   即构：{callId:通话ID}
- (void)callAcceptWith:(NSMutableDictionary *)params onSuccess:(ZCallSuccessBlock)onSuccess onFailure:(ZCallFailureBlock)onFailure;

/// 音视频通话取消，拒绝，结束
/// - Parameters:
///   - params: 参数(根据使用的SDK的不同，参数是不同的，注意区分)
///   即构：{callId:通话ID}
- (void)callDiscardWith:(NSMutableDictionary *)params onSuccess:(ZCallSuccessBlock)onSuccess onFailure:(ZCallFailureBlock)onFailure;

/// 多人音视频通话，邀请新成员加入音视频通话
/// - Parameters:
///   - params: 参数(根据使用的SDK的不同，参数是不同的，注意区分)
///   即构：{callId:通话ID；friendIds:好友/用户ID(数组)}
- (void)callGroupInviteWith:(NSMutableDictionary *)params onSuccess:(ZCallSuccessBlock)onSuccess onFailure:(ZCallFailureBlock)onFailure;

/// 多人音视频通话，主动加入音视频通话
/// - Parameters:
///   - params: 参数(根据使用的SDK的不同，参数是不同的，注意区分)
///   即构：{callId:通话ID}
- (void)callGroupJoinWith:(NSMutableDictionary *)params onSuccess:(ZCallSuccessBlock)onSuccess onFailure:(ZCallFailureBlock)onFailure;

/// 多人音视频通话，获取群组的音视频通话信息(判断群组当前是否有正在进行的音视频通话)
/// - Parameters:
///   - params: 参数(根据使用的SDK的不同，参数是不同的，注意区分)
///   即构：{groupId:群组ID}
- (void)callGetGroupCallInfoWith:(NSMutableDictionary *)params onSuccess:(ZCallSuccessBlock)onSuccess onFailure:(ZCallFailureBlock)onFailure;

//音视频通话权限提示框
- (void)showPermissionTip;
@end

NS_ASSUME_NONNULL_END
