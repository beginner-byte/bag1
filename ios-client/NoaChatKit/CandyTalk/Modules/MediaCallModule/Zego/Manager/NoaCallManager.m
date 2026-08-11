//
//  NoaCallManager.m
//  NoaKit
//
//  Created by Candy on 2023/5/18.
//

#import "NoaCallManager.h"

#import "NoaToolManager.h"
#import "NoaAppPermissionTipView.h"//权限获取提示框
#import "NoaNavigationController.h"
#import "NoaCallSingleVC.h"//单聊音视频
#import "NoaCallGroupVC.h"//群聊音视频

#define CALL_HEART_BEAT_TIME        10

@interface NoaCallManager () <ZegoEventHandler>
@property (nonatomic, strong) dispatch_source_t callDurationTimer;//通话计时器
@property (nonatomic, strong) dispatch_source_t callHeartBeatTimer;//音视频通话心跳计时器
@property (nonatomic, assign) NSInteger currentCallDuration;
@end

static dispatch_once_t onceToken;

@implementation NoaCallManager

#pragma mark - 单例>>>>>>
+ (instancetype)sharedManager {
    static NoaCallManager *_manager = nil;
    
    dispatch_once(&onceToken, ^{
        //不再使用alloc方法，因为已经重写了allocWithZone方法，所以这里要调用父类的方法
        _manager = [[super allocWithZone:NULL] init];
    });
    
    return _manager;
}
// 防止外部调用alloc 或者 new
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [NoaCallManager sharedManager];
}
// 防止外部调用copy
- (id)copyWithZone:(nullable NSZone *)zone {
    return [NoaCallManager sharedManager];
}
// 防止外部调用mutableCopy
- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [NoaCallManager sharedManager];
}

#pragma mark - 单例一般不需要清空，但是在执行某些功能的时候，防止数据清空不及时可以清空一下
- (void)clearManager{
    onceToken = 0;
}

#pragma mark - 方法与属性>>>>>>
#pragma mark - 创建通话计时器
- (void)createCurrentCallDurationTimer {
    if (_callDurationTimer) return;
    
    _currentCallDuration = 0;
    
    __weak typeof(self) weakSelf = self;
    
    //定时器开始执行的延时时间
    NSTimeInterval delayTime = 0.0f;
    
    //定时器间隔时间
    NSTimeInterval timeInterval = 1.0f;
    
    //创建子线程队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    //使用之前创建的队列来创建计时器
    _callDurationTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);

    //设置延时执行时间，delayTime为要延时的秒数
    dispatch_time_t startDelayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC));
    
    //设置计时器(定时器，触发时刻，时间间隔，精度)
    dispatch_source_set_timer(_callDurationTimer, startDelayTime, timeInterval * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);

    dispatch_source_set_event_handler(_callDurationTimer, ^{
        //执行事件
        weakSelf.currentCallDuration++;
        weakSelf.currentCallOptions.zgCallOptions.callDuration = weakSelf.currentCallDuration;
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(currentCallDurationTime:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.delegate currentCallDurationTime:weakSelf.currentCallDuration];
            });
        }
    });
    
    // 启动计时器
    dispatch_resume(_callDurationTimer);
}
#pragma mark - 销毁通话计时器
- (void)deallocCurrentCallDurationTimer {
    if (_callDurationTimer) {
        dispatch_source_cancel(_callDurationTimer);
        _callDurationTimer = nil;
        _currentCallDuration = 0;
        _currentCallOptions.zgCallOptions.callDuration = 0;
    }
}

#pragma mark - 创建音视频通话心跳计时器
- (void)createCallHeartBeatTimer {
    if (_callHeartBeatTimer) return;
    
    __weak typeof(self) weakSelf = self;
    
    //定时器开始执行的延时时间
    NSTimeInterval delayTime = 0.0f;
    
    //定时器间隔时间
    NSTimeInterval timeInterval = CALL_HEART_BEAT_TIME;
    
    //创建子线程队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    //使用之前创建的队列来创建计时器
    _callHeartBeatTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);

    //设置延时执行时间，delayTime为要延时的秒数
    dispatch_time_t startDelayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC));
    
    //设置计时器(定时器，触发时刻，时间间隔，精度)
    dispatch_source_set_timer(_callHeartBeatTimer, startDelayTime, timeInterval * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);

    dispatch_source_set_event_handler(_callHeartBeatTimer, ^{
        //执行事件
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObjectSafe:weakSelf.currentCallOptions.zgCallOptions.callID forKey:@"callId"];
        
        [IMSDKManager userHeartbeatCallWith:dict onSuccess:^(id  _Nullable data, NSString * _Nullable traceId) {
            
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                
        }];
    });
    
    // 启动计时器
    dispatch_resume(_callHeartBeatTimer);
}
#pragma mark - 销毁音视频通话心跳计时器
- (void)deallocCallHeartBeatTimer {
    if (_callHeartBeatTimer) {
        dispatch_source_cancel(_callHeartBeatTimer);
        _callHeartBeatTimer = nil;
    }
}
#pragma mark - <<<<<<业务层功能>>>>>>
#pragma mark - 发起 单聊 音视频通话
- (void)requestSingleCallWith:(NSMutableDictionary *)inviteeDict callType:(LingIMCallType)callType {
    WeakSelf
    //1.配置 单聊 音视频通话 邀请者信息 (我 邀请者)
    NoaCallUserModel *inviterUserModel = [NoaCallUserModel new];
    inviterUserModel.userUid = UserManager.userInfo.userUID;//用户ID(我 邀请者)
    inviterUserModel.userShowName = UserManager.userInfo.userName;//用户昵称(我 邀请者)
    inviterUserModel.userAvatar = UserManager.userInfo.avatar;//用户头像(我 邀请者)
    inviterUserModel.streamID = UserManager.userInfo.userUID;//音视频轨道流ID(我 邀请者)
    inviterUserModel.micState = LingIMCallMicrophoneMuteStateOff;//默认开启麦克风(我 邀请者)
    inviterUserModel.speakerState = LingIMCallSpeakerMuteStateOn;//默认关闭扬声器(我 邀请者)
    inviterUserModel.cameraState = LingIMCallCameraMuteStateOff;//默认开启摄像头(我 邀请者)
    inviterUserModel.cameraDirection = LingIMCallCameraDirectionFront;//默认前置摄像头(我 邀请者)
    
    //2.配置 单聊 音视频通话 被邀请者信息
    NoaCallUserModel *inviteeUserModel = [NoaCallUserModel new];
    inviteeUserModel.userUid = [inviteeDict objectForKeySafe:@"userID"];//用户ID
    inviteeUserModel.userShowName = [inviteeDict objectForKeySafe:@"userShowName"];//用户昵称
    inviteeUserModel.userAvatar = [inviteeDict objectForKeySafe:@"userAvatar"];//用户头像
    inviteeUserModel.streamID = [inviteeDict objectForKeySafe:@"userID"];//音视频轨道流ID
    inviteeUserModel.micState = LingIMCallMicrophoneMuteStateOff;//默认开启麦克风
    inviteeUserModel.speakerState = LingIMCallSpeakerMuteStateOn;//默认关闭扬声器
    inviteeUserModel.cameraState = LingIMCallCameraMuteStateOff;//默认开启摄像头
    inviteeUserModel.cameraDirection = LingIMCallCameraDirectionFront;//默认前置摄像头
    
    //3.配置 单聊 音视频通话 参数
    __block NoaIMZGCallOptions *zgCallOptions = [NoaIMZGCallOptions new];
    zgCallOptions.callRoomType = LingIMCallRoomTypeSingle;//单聊
    zgCallOptions.callRoomCreateUserID = UserManager.userInfo.userUID;//房间创建者 (我 邀请者)
    zgCallOptions.callRoomUserID = UserManager.userInfo.userUID;//音视频房间推流的用户ID(我 邀请者)
    zgCallOptions.callRoomUserNickname = UserManager.userInfo.nickname;//音视频房间推流的用户昵称(我 邀请者)
    zgCallOptions.callRoomUserStreamID = UserManager.userInfo.userUID;//音视频房间推流的音视频流ID(我 邀请者)
    zgCallOptions.callMicState = LingIMCallMicrophoneMuteStateOff;//房间推流默认开启麦克风(本地 我的 推流设置)
    zgCallOptions.callSpeakerState = LingIMCallSpeakerMuteStateOn;//房间推流默认关闭扬声器(本地 我的 推流设置)
    zgCallOptions.callCameraState = LingIMCallCameraMuteStateOff;//房间推流默认开启摄像头(本地 我的 推流设置)
    zgCallOptions.callCameraDirection = LingIMCallCameraDirectionFront;//房间推流默认前置摄像头(本地 我的 推流设置)
    zgCallOptions.callType = callType;//通话类型
    
    
    //4.业务层 配置 单聊 音视频通话 参数
    __block NoaCallOptions *callOptions = [NoaCallOptions new];
    callOptions.zgCallOptions = zgCallOptions;
    callOptions.inviterUserModel = inviterUserModel;
    callOptions.inviteeUserModel = inviteeUserModel;
    
    NoaCallManager *callManager = [NoaCallManager sharedManager];
    callManager.currentCallOptions = callOptions;
    callManager.showMeTrack = YES;//单聊，默认 我 在固定主屏幕上
    [callManager callRequestWith:callOptions onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        
        if ([data isKindOfClass:[NSDictionary class]]) {
            
            callManager.callState = ZCallStateBegin;//开始一个音视频通话的进程，等待对方的处理
            
            NSDictionary *dataDict = (NSDictionary *)data;
            NSString *callID = [dataDict objectForKeySafe:@"callId"];//音视频通话ID
            NSString *callRoomID = [dataDict objectForKeySafe:@"roomId"];//音视频通话房间ID
            NSString *callRoomToken = [dataDict objectForKeySafe:@"token"];//音视频通话房间token
            NSInteger callRoomTimeout = [[dataDict objectForKeySafe:@"timeOut"] integerValue];//音视频通话呼叫超时时间
            //receiveUserInfo数组是被邀请的用户信息(userUid,nickname,avatar)
            
            
            //更新房间信息
            zgCallOptions.callID = callID;
            zgCallOptions.callRoomID = callRoomID;
            zgCallOptions.callRoomToken = callRoomToken;
            zgCallOptions.callTimeout = callRoomTimeout;
            
            NoaCallSingleVC *callVC = [NoaCallSingleVC new];
            callVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [CurrentVC presentViewController:callVC animated:YES completion:nil];
        }
        
        
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        //清空本次通话的配置
        [weakSelf clearManagerConfig];
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

#pragma mark - 发起 群聊 音视频通话
- (void)requestGroupCallWith:(NSMutableArray *)inviteeList group:(NSString *)groupID callType:(LingIMCallType)callType {
    if (inviteeList.count > 0) {
        WeakSelf
        
        //1.配置 单聊 音视频通话 参数
        NoaIMZGCallOptions *zgCallOptions = [NoaIMZGCallOptions new];
        zgCallOptions.callType = callType;//通话类型
        zgCallOptions.callRoomType = LingIMCallRoomTypeGroup;//群聊
        zgCallOptions.callRoomCreateUserID = UserManager.userInfo.userUID;//房间创建者
        zgCallOptions.callRoomUserID = UserManager.userInfo.userUID;//音视频房间推流的用户ID
        zgCallOptions.callRoomUserNickname = UserManager.userInfo.nickname;//音视频房间推流的用户昵称
        zgCallOptions.callRoomUserStreamID = UserManager.userInfo.userUID;//音视频房间推流的音视频流ID
        zgCallOptions.callMicState = LingIMCallMicrophoneMuteStateOff;//房间推流默认开启麦克风(本地 我的 推流设置)
        zgCallOptions.callSpeakerState = LingIMCallSpeakerMuteStateOff;//房间推流默认开启扬声器(本地 我的 推流设置)
        zgCallOptions.callCameraState = LingIMCallCameraMuteStateOff;//房间推流默认开启摄像头(本地 我的 推流设置)
        zgCallOptions.callCameraDirection = LingIMCallCameraDirectionFront;//房间推流默认前置摄像头(本地 我的 推流设置)
        
        //2.本地维护的房间成员信息
        __block NSMutableArray *callMemberList = [NSMutableArray array];
        //我在本房间的信息
        NoaCallUserModel *userModelMine = [NoaCallUserModel new];
        userModelMine.userUid = UserManager.userInfo.userUID;//用户ID
        userModelMine.userShowName = UserManager.userInfo.userName;//用户昵称
        userModelMine.userAvatar = UserManager.userInfo.avatar;//用户头像
        userModelMine.streamID = UserManager.userInfo.userUID;//音视频轨道流ID
        userModelMine.micState = LingIMCallMicrophoneMuteStateOff;//默认开启麦克风
        userModelMine.speakerState = LingIMCallSpeakerMuteStateOff;//默认开启扬声器
        userModelMine.cameraState = LingIMCallCameraMuteStateOff;//默认开启摄像头
        userModelMine.cameraDirection = LingIMCallCameraDirectionFront;//默认前置摄像头
        userModelMine.callState = ZCallUserStateAccept;//默认接通
        [callMemberList addObjectIfNotNil:userModelMine];
        
        
        //3.业务层 配置 单聊 音视频通话 参数
        __block NoaCallOptions *callOptions = [NoaCallOptions new];
        callOptions.zgCallOptions = zgCallOptions;
        callOptions.groupID = groupID;
        callOptions.inviterUserModel = userModelMine;//我是邀请者
        callOptions.inviteeUserList = inviteeList;
        
        NoaCallManager *callManager = [NoaCallManager sharedManager];
        callManager.currentCallOptions = callOptions;
        [callManager callRequestWith:callOptions onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            
            if ([data isKindOfClass:[NSDictionary class]]) {
                
                callManager.callState = ZCallStateBegin;//开始一个音视频通话的进程
                
                NSDictionary *dataDict = (NSDictionary *)data;
                NSString *callID = [NSString stringWithFormat:@"%@", [dataDict objectForKeySafe:@"callId"]];//音视频通话ID
                NSString *callRoomID = [NSString stringWithFormat:@"%@", [dataDict objectForKeySafe:@"roomId"]];//音视频通话房间ID
                NSString *callRoomToken = [NSString stringWithFormat:@"%@", [dataDict objectForKeySafe:@"token"]];//音视频通话房间token
                NSInteger callRoomTimeout = [[dataDict objectForKeySafe:@"timeOut"] integerValue];//音视频通话呼叫超时时间
                NSArray *callReceiveUserInfo = [dataDict objectForKeySafe:@"receiveUserInfo"];//被邀请的用户信息(userUid,nickname,avatar)
                [callReceiveUserInfo enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NoaCallUserModel *userModel = [NoaCallUserModel new];
                    userModel.userUid = [NSString stringWithFormat:@"%@", [obj objectForKeySafe:@"userUid"]];//用户ID
                    userModel.userShowName = [NSString stringWithFormat:@"%@", [obj objectForKeySafe:@"nickname"]];//用户昵称
                    userModel.userAvatar = [NSString stringWithFormat:@"%@", [obj objectForKeySafe:@"avatar"]];//用户头像
                    userModel.streamID = [NSString stringWithFormat:@"%@", [obj objectForKeySafe:@"userUid"]];//音视频轨道流ID
                    userModel.micState = LingIMCallMicrophoneMuteStateOff;//默认开启麦克风
                    userModel.speakerState = LingIMCallSpeakerMuteStateOn;//默认关闭扬声器
                    userModel.cameraState = LingIMCallCameraMuteStateOn;//默认关闭摄像头
                    userModel.cameraDirection = LingIMCallCameraDirectionFront;//默认前置摄像头
                    userModel.callState = ZCallUserStateCalling;//默认正在呼叫中
                    
                    [callMemberList addObjectIfNotNil:userModel];
                }];
                callOptions.callMemberList = callMemberList;
                
                
                //更新房间信息
                zgCallOptions.callID = callID;
                zgCallOptions.callRoomID = callRoomID;
                zgCallOptions.callRoomToken = callRoomToken;
                zgCallOptions.callTimeout = callRoomTimeout;
                
                //跳转到群聊音视频VC
                NoaCallGroupVC *vc = [NoaCallGroupVC new];
                [vc callRoomJoin];
                NoaNavigationController *nav = [[NoaNavigationController alloc] initWithRootViewController:vc];
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                [CurrentVC presentViewController:nav animated:YES completion:nil];
            }
            
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            //清空本次通话的配置
            [weakSelf clearManagerConfig];
            [HUD showMessageWithCode:code errorMsg:msg];
        }];
        
    }
    
    
}

#pragma mark - 清空配置
- (void)clearManagerConfig {
    //清空单例数据
    self.currentCallOptions = nil;
    self.callState = ZCallStateEnd;
    
    //销毁通话计时器
    [self deallocCurrentCallDurationTimer];
    [self deallocCallHeartBeatTimer];
}

#pragma mark - <<<<<<SDK功能>>>>>>
#pragma mark - sdk基本信息配置
- (void)callSdkConfigWith:(NoaIMZGCallConfig *)config {
    [IMSDKManager imSdkZGConfigWith:config];
}
#pragma mark - 创建 ZegoExpressEngine 单例对象并初始化 SDK(第一步)
- (void)callRoomCreateEngineWithOptions:(NoaIMZGCallOptions *)callOptions {
    
    [IMSDKManager imSdkZGCallRoomLogout];
    
    [IMSDKManager imSdkZGCallRoomCreateEngineWithOptions:callOptions delegate:self];
}

#pragma mark - 登录房间(第二步)
- (void)callRoomLogin:(LingIMZGLoginRoomBlock)block {
    //登录房间 先销毁通话计时器(如果有的话)防止有上次通话的计时器未销毁
    [self deallocCurrentCallDurationTimer];
    [self deallocCallHeartBeatTimer];
    
    WeakSelf
    [IMSDKManager imSdkZGCallRoomLoginRoom:^(int errorCode, NSDictionary * _Nullable extendedData) {
        if (block) {
            block(errorCode, extendedData);
        }
        
        if (errorCode == 0) {
            //登录房间成功，告知后端，确认加入了音视频通话
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:weakSelf.currentCallOptions.zgCallOptions.callID forKey:@"callId"];
            [weakSelf zegoCallConfirmJoinCallWith:dict onSuccess:nil onFailure:nil];
        }else {
            //登录房间失败
        }
        
    }];
}

#pragma mark - 开始推流(第三步)
- (void)callRoomStartPublish {
    [IMSDKManager imSdkZGCallRoomStartPublish];
}

#pragma mark - 停止推流
- (void)callRoomStopPublish {
    [IMSDKManager imSdkZGCallRoomStopPublish];
}

#pragma mark - 退出房间
- (void)callRoomLogout {
    [IMSDKManager imSdkZGCallRoomLogout];
}

#pragma mark - 开始拉流
- (void)callRoomStartPlayingStream:(NSString *)streamID with:(UIView *)viewPreview;{
    [IMSDKManager imSdkZGCallRoomStartPlayingStream:streamID with:viewPreview];
}

#pragma mark - 停止拉流
- (void)callRoomStopPlayingStram:(NSString *)streamID {
    [IMSDKManager imSdkZGCallRoomStopPlayingStram:streamID];
}

#pragma mark - 服从代理
- (void)callRoomDelegate:(id <ZegoEventHandler>)roomDelegate {
    [IMSDKManager imSdkZGCallRoomDelegate:roomDelegate];
}

#pragma mark - 开始视频预览
- (void)callRoomStartPreviewWith:(UIView *)viewPreview {
    [IMSDKManager imSdkZGCallRoomStartPreviewWith:viewPreview];
}

#pragma mark - 停止视频预览
- (void)callRoomStopPreview {
    [IMSDKManager imSdkZGCallRoomStopPreview];
}

#pragma mark - 用户房间类型
- (LingIMCallType)callRoomType {
    return [IMSDKManager imSdkZGCallRoomType];
}

#pragma mark - 麦克风静默
- (void)callRoomMicrophoneMute:(BOOL)mute {
    [IMSDKManager imSdkZGCallRoomMicrophoneMute:mute];
}

#pragma mark - 麦克风静默状态
- (LingIMCallMicrophoneMuteState)callRoomMirophoneState {
    return [IMSDKManager imSdkZGCallRoomMicrophoneState];
}

#pragma mark - 摄像头静默
- (void)callRoomCameraMute:(BOOL)mute {
    [IMSDKManager imSdkZGCallRoomCameraMute:mute];
}

#pragma mark - 摄像头静默状态
- (LingIMCallCameraMuteState)callRoomCameraState {
    return [IMSDKManager imSdkZGCallRoomCameraState];
}

#pragma mark - 使用前置摄像头
- (void)callRoomCameraUseFront:(BOOL)frontEnable {
    [IMSDKManager imSdkZGCallRoomCameraUseFront:frontEnable];
}

#pragma mark - 摄像头方向
- (LingIMCallCameraDirection)callRoomCameraDirection {
    return [IMSDKManager imSdkZGCallRoomCameraDirection];
}

#pragma mark - 扬声器静默
- (void)callRoomSpeakerMute:(BOOL)mute {
    [IMSDKManager imSdkZGCallRoomSpeakerMute:mute];
}

#pragma mark - 扬声器静默状态
- (LingIMCallSpeakerMuteState)callRoomSpeakerState {
    return [IMSDKManager imSdkZGCallRoomSpeakderState];
}

#pragma mark - <<<<<<接口>>>>>>
#pragma mark - 发起音视频通话请求接口
- (void)callRequestWith:(NoaCallOptions *)callOptions onSuccess:(ZCallSuccessBlock)onSuccess onFailure:(ZCallFailureBlock)onFailure {
    
    //检查麦克风权限
    BOOL microphoneState = [ZTOOL checkMicrophoneState];
    if (microphoneState) {
        
        if (callOptions.zgCallOptions.callType == LingIMCallTypeVideo) {
            //检查摄像头权限
            BOOL cameraState = [ZTOOL checkCameraState];
            if (!cameraState) {
                [self showPermissionTip];
                return;
            }
        }
        
       if (_callSDKType == LingIMCallSDKTypeZego) {
            //即构音视频通话逻辑
            [self zegoCallCreateWith:callOptions onSuccess:onSuccess onFailure:onFailure];
        }
        
    }else {
        [self showPermissionTip];
    }
    
}

#pragma mark - 接受音视频通话请求
- (void)callAcceptWith:(NSMutableDictionary *)params onSuccess:(ZCallSuccessBlock)onSuccess onFailure:(ZCallFailureBlock)onFailure {
   
   if (_callSDKType == LingIMCallSDKTypeZego) {
       
       //获取用户音视频鉴权token
       [self zegoCallCallInfoTokenWith:params onSuccess:onSuccess onFailure:onFailure];
       
    }
}

#pragma mark - 音视频通话取消，拒绝，结束
- (void)callDiscardWith:(NSMutableDictionary *)params onSuccess:(ZCallSuccessBlock)onSuccess onFailure:(ZCallFailureBlock)onFailure {
    
   if (_callSDKType == LingIMCallSDKTypeZego) {
        //即构音视频通话逻辑
        if (params) {
            NSString *discardType = [params objectForKeySafe:@"discardType"];
            NSString *callId = [params objectForKeySafe:@"callId"];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:callId forKey:@"callId"];
            
            if ([discardType isEqualToString:@"refuse"]) {
                //拒绝通话
                [self zegoCallRejectWith:dict onSuccess:onSuccess onFailure:onFailure];
            }else if ([discardType isEqualToString:@"cancel"]) {
                //取消通话
                [self zegoCallCancelWith:dict onSuccess:onSuccess onFailure:onFailure];
            }else if ([discardType isEqualToString:@"hangup"]) {
                //挂断通话
                [self zegoCallHangUpWith:dict onSuccess:onSuccess onFailure:onFailure];
            }
            
            //退出房间
            [self callRoomLogout];
            //清空本次通话的配置
            [self clearManagerConfig];
        }
    }
}

#pragma mark - 多人音视频通话，邀请新成员加入音视频通话
- (void)callGroupInviteWith:(NSMutableDictionary *)params onSuccess:(ZCallSuccessBlock)onSuccess onFailure:(ZCallFailureBlock)onFailure {
   if (_callSDKType == LingIMCallSDKTypeZego) {
        //即构音视频通话逻辑
        [self zegoCallGroupInviteWith:params onSuccess:onSuccess onFailure:onFailure];
    }
}

#pragma mark - 多人音视频通话，主动加入音视频通话
- (void)callGroupJoinWith:(NSMutableDictionary *)params onSuccess:(ZCallSuccessBlock)onSuccess onFailure:(ZCallFailureBlock)onFailure {
   if (_callSDKType == LingIMCallSDKTypeZego) {
        //即构音视频通话逻辑
        [self zegoCallGroupJoinWith:params onSuccess:onSuccess onFailure:onFailure];
    }
}
#pragma mark - 多人音视频通话，获取群组的音视频通话信息(判断群组当前是否有正在进行的音视频通话)
- (void)callGetGroupCallInfoWith:(NSMutableDictionary *)params onSuccess:(ZCallSuccessBlock)onSuccess onFailure:(ZCallFailureBlock)onFailure {
    if (_callSDKType == LingIMCallSDKTypeZego) {
         //即构音视频通话逻辑
        [self zegoCallGroupCallInfoWith:params onSuccess:onSuccess onFailure:onFailure];
     }
}

#pragma mark - 音视频通话权限提示框
- (void)showPermissionTip {
    [ZTOOL doInMain:^{
        NoaAppPermissionTipView *viewTip = [NoaAppPermissionTipView new];
        [viewTip permissionTipViewSHow];
    }];
}

#pragma mark - 即构接口相关处理******
//发起音视频通话
- (void)zegoCallCreateWith:(NoaCallOptions *)callOptions onSuccess:(ZCallSuccessBlock)onSuccess onFailure:(ZCallFailureBlock)onFailure {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    //音频/视频通话
    if (callOptions.zgCallOptions.callType == LingIMCallTypeAudio) {
        [dict setValue:@"Voice" forKey:@"callType"];
    }else if (callOptions.zgCallOptions.callType == LingIMCallTypeVideo) {
        [dict setValue:@"Video" forKey:@"callType"];
    }
    
    if (callOptions.zgCallOptions.callRoomType == LingIMCallRoomTypeSingle) {
        //单聊音视频
        [dict setValue:@"SINGLE_CHAT" forKey:@"chatType"];
        
        //被邀请者列表
        NSArray *inviteeUserList = @[callOptions.inviteeUserModel.userUid];
        [dict setValue:inviteeUserList forKey:@"friendIds"];
    }else if (callOptions.zgCallOptions.callRoomType == LingIMCallRoomTypeGroup) {
        //群聊音视频
        [dict setValue:@"GROUP_CHAT" forKey:@"chatType"];
        //群ID
        [dict setValue:callOptions.groupID forKey:@"groupId"];
        //被邀请者列表
        [dict setValue:callOptions.inviteeUserList forKey:@"friendIds"];
    }
    
    
    [IMSDKManager imSdkUserCreateCallWith:dict onSuccess:onSuccess onFailure:onFailure];
}
//拒绝接听音视频通话
- (void)zegoCallRejectWith:(NSMutableDictionary *)params onSuccess:(ZCallSuccessBlock)onSuccess onFailure:(ZCallFailureBlock)onFailure {
    [IMSDKManager imSdkUserRejectCallWith:params onSuccess:onSuccess onFailure:onFailure];
    
    [IMSDKManager toolMessageReceiveRemindEndForMediaCall];
}
//取消发起音视频通话
- (void)zegoCallCancelWith:(NSMutableDictionary *)params onSuccess:(ZCallSuccessBlock)onSuccess onFailure:(ZCallFailureBlock)onFailure {
    [IMSDKManager imSdkUserCancelCallWith:params onSuccess:onSuccess onFailure:onFailure];
    
    [IMSDKManager toolMessageReceiveRemindEndForMediaCall];
}
//挂断音视频通话
- (void)zegoCallHangUpWith:(NSMutableDictionary *)params onSuccess:(ZCallSuccessBlock)onSuccess onFailure:(ZCallFailureBlock)onFailure {
    [IMSDKManager imSdkUserHangUpCallWith:params onSuccess:onSuccess onFailure:onFailure];
    
    [IMSDKManager toolMessageReceiveRemindEndForMediaCall];
}
//接听音视频通话
- (void)zegoCallAcceptWith:(NSMutableDictionary *)params onSuccess:(ZCallSuccessBlock)onSuccess onFailure:(ZCallFailureBlock)onFailure {
    [IMSDKManager imSdkUserAcceptCallWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        //接口请求结果传递出去
        if (onSuccess) {
            onSuccess(data, traceId);
        }
    } onFailure:onFailure];
    
    //取消消息提醒
    [IMSDKManager toolMessageReceiveRemindEndForMediaCall];
}
//群聊 主动加入某个音视频通话
- (void)zegoCallGroupJoinWith:(NSMutableDictionary *)params onSuccess:(ZCallSuccessBlock)onSuccess onFailure:(ZCallFailureBlock)onFailure {
    [IMSDKManager imSdkUserJoinCallWith:params onSuccess:onSuccess onFailure:onFailure];
}
//群聊 邀请加入某个音视频通话
- (void)zegoCallGroupInviteWith:(NSMutableDictionary *)params onSuccess:(ZCallSuccessBlock)onSuccess onFailure:(ZCallFailureBlock)onFailure {
    [IMSDKManager imSdkUserInviteToCallWith:params onSuccess:onSuccess onFailure:onFailure];
}
//群聊 获取某个群当前正在进行的音视频通话信息
- (void)zegoCallGroupCallInfoWith:(NSMutableDictionary *)params onSuccess:(ZCallSuccessBlock)onSuccess onFailure:(ZCallFailureBlock)onFailure {
    [IMSDKManager imSdkUserGetGroupCallInfoWith:params onSuccess:onSuccess onFailure:onFailure];
}
//根据callId获取某个用户的token鉴权信息
- (void)zegoCallCallInfoTokenWith:(NSMutableDictionary *)params onSuccess:(ZCallSuccessBlock)onSuccess onFailure:(ZCallFailureBlock)onFailure {
    
    //接听音视频通话
    WeakSelf
    //第一步: 获取该用户 在本次音视频通话房间的token鉴权信息
    [IMSDKManager imSdkUserGetCallInfoTokenWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *dataDict = (NSDictionary *)data;
            //用户在该音视频通话房间的token
            NSString *roomUserToken = [NSString stringWithFormat:@"%@", [dataDict objectForKeySafe:@"token"]];
            weakSelf.currentCallOptions.zgCallOptions.callRoomToken = roomUserToken;
            
            if (weakSelf.currentCallOptions.zgCallOptions.callRoomType == LingIMCallRoomTypeGroup) {
                //群聊音视频，本地维护的一套群聊音视频成员列表
                //房间全部成员信息
                NSArray *receiveUserInfoArray = [dataDict objectForKeySafe:@"receiveUserInfo"];
                //更新本地维护的成员列表
                __block NSMutableArray *callMemberList = [NSMutableArray array];
                [receiveUserInfoArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NoaCallUserModel *model = [NoaCallUserModel new];
                    NSString *userUid = [NSString stringWithFormat:@"%@", [obj objectForKeySafe:@"userUid"]];
                    NSString *userAvatar = [NSString stringWithFormat:@"%@", [obj objectForKeySafe:@"avatar"]];
                    NSString *userNickname = [NSString stringWithFormat:@"%@", [obj objectForKeySafe:@"nickname"]];
                    model.userUid = userUid;//用户ID
                    model.userAvatar = userAvatar;//用户头像
                    model.userShowName = userNickname;//用户昵称
                    model.streamID = userUid;//音视频轨道流ID
                    model.micState = LingIMCallMicrophoneMuteStateOff;//默认开启麦克风
                    model.cameraDirection = LingIMCallCameraDirectionFront;//默认前置摄像头
                    model.speakerState = LingIMCallSpeakerMuteStateOff;//默认开启扬声器
                    model.cameraState = LingIMCallCameraMuteStateOn;//默认关闭摄像头
                    model.callState = ZCallUserStateCalling;//默认正在呼叫中
                    NSString *mineUserUid = [NSString stringWithFormat:@"%@", UserManager.userInfo.userUID];
                    if ([userUid isEqualToString:mineUserUid]) {
                        //我的 推流相关配置
                        model.cameraState = LingIMCallCameraMuteStateOff;//默认开启摄像头
                        model.callState = ZCallUserStateAccept;//默认接通
                    }
                    
                    [callMemberList addObjectIfNotNil:model];
                }];
                
                weakSelf.currentCallOptions.callMemberList = callMemberList;
            }
            
            //第二步: 用户同意音视频通话
            [self zegoCallAcceptWith:params onSuccess:onSuccess onFailure:onFailure];
        }
    } onFailure:onFailure];
}
//音视频通话确认完成了整个加入流程
- (void)zegoCallConfirmJoinCallWith:(NSMutableDictionary *)params onSuccess:(ZCallSuccessBlock)onSuccess onFailure:(ZCallFailureBlock)onFailure {
    [IMSDKManager imSdkUserConfirmJoinCallWith:params onSuccess:onSuccess onFailure:onFailure];
}

#pragma mark - <ZegoEventHandler>即构音视频通话SDK代理
//实时监控自己在本房间内的连接状态
- (void)onRoomStateChanged:(ZegoRoomStateChangedReason)reason errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    
    switch (reason) {
        case ZegoRoomStateChangedReasonLogining:
            //正在登录房间。当调用 [loginRoom] 登录房间或 [switchRoom] 切换到目标房间时，进入该状态，表示正在请求连接服务器。通常通过该状态进行应用界面的展示。
        case ZegoRoomStateChangedReasonLogined:
            //登录房间成功。当登录房间或切换房间成功后，进入该状态，表示登录房间已经成功，用户可以正常收到房间内的其他用户和所有流信息增删的回调通知。
            //只有当房间状态是登录成功或重连成功时，推流（startPublishingStream）、拉流（startPlayingStream）才能正常收发音视频
        case ZegoRoomStateChangedReasonReconnecting:
            //房间连接临时中断。如果因为网络质量不佳产生的中断，SDK 会进行内部重试。
        case ZegoRoomStateChangedReasonReconnected:
            //房间重新连接成功。如果因为网络质量不佳产生的中断，SDK 会进行内部重试，重连成功后进入该状态。
        case ZegoRoomStateChangedReasonReconnectFailed:
            //房间重新连接失败。如果因为网络质量不佳产生的中断，SDK 会进行内部重试，重连失败后进入该状态
        case ZegoRoomStateChangedReasonLogout:
            //登出房间成功。没有登录房间前默认为该状态，当调用 [logoutRoom] 登出房间成功或 [switchRoom] 内部登出当前房间成功后，进入该状态。
        case ZegoRoomStateChangedReasonLogoutFailed:
            //登出房间失败。当调用 [logoutRoom] 登出房间失败或 [switchRoom] 内部登出当前房间失败后，进入该状态。
        case ZegoRoomStateChangedReasonLoginFailed:
            //登录房间失败。当登录房间或切换房间失败后，进入该状态，表示登录房间或切换房间已经失败，例如 AppID 或 Token 不正确等。
        case ZegoRoomStateChangedReasonKickOut:
            //被服务器踢出房间。例如有相同用户名在其他地方登录房间导致本端被踢出房间，会进入该状态
            break;
            
        default:
            break;
    }
    
}

//远端摄像头设备状态通知
//用户首次登录房间时，若此房间内存在其他用户正在推流，也会触发，用于告知已推流用户的摄像头状态
- (void)onRemoteCameraStateUpdate:(ZegoRemoteDeviceState)state streamID:(NSString *)streamID {
    
    if ([NSString isNil:streamID]) return;
    
    if (_currentCallOptions.zgCallOptions.callType == LingIMCallTypeAudio) {
        //音频通话
    }else {
        //视频通话
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:streamID forKey:@"userUid"];//摄像头状态改变的用户
        if (state == ZegoRemoteDeviceStateMute) {
            //摄像头静默
            [dict setValue:@(YES) forKey:@"cameraMute"];
        }else if (state == ZegoRemoteDeviceStateGenericError) {
            //兼容Web摄像头静默
            [dict setValue:@(YES) forKey:@"cameraMute"];
        }else if (state == ZegoRemoteDeviceStateOpen) {
            //摄像头打开
            [dict setValue:@(NO) forKey:@"cameraMute"];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:ZGCALLROOMCAMERAMUTE object:nil userInfo:dict];
        
    }
    
}

//我 推流网络质量回调
- (void)onPublisherQualityUpdate:(ZegoPublishStreamQuality *)quality streamID:(NSString *)streamID {
    if (quality.level > ZegoStreamQualityLevelMedium){
        [HUD showMessage:LanguageToolMatch(@"当前网络信号差")];
    }
}

//房间里 其他用户 推流质量回调
- (void)onPlayerQualityUpdate:(ZegoPlayStreamQuality *)quality streamID:(NSString *)streamID {
    if (_currentCallOptions.zgCallOptions.callRoomType == LingIMCallRoomTypeSingle) {
        //单聊音视频
        if (quality.level > ZegoStreamQualityLevelMedium){
            [HUD showMessage:LanguageToolMatch(@"对方网络信号差")];
        }
    }else {
        //群聊音视频
    }
}

//监听房间内的流变化 streamList为当前新增或减少的流列表
//用户首次登录房间时，若此房间内存在其他用户正在推流，会接收到流新增列表，即 “updateType” 为 “ZegoUpdateTypeADD” 的回调 streamList为当前总的流列表
- (void)onRoomStreamUpdate:(ZegoUpdateType)updateType streamList:(NSArray<ZegoStream *> *)streamList extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    if (_currentCallOptions.zgCallOptions.callRoomType == LingIMCallRoomTypeSingle) {
        //单聊音视频
        for (ZegoStream *zegoStream in streamList) {
            //流变化用户
            NSString *zegoUid = [NSString stringWithFormat:@"%@", zegoStream.user.userID];
            NSString *inviterUid = [NSString stringWithFormat:@"%@", _currentCallOptions.inviterUserModel.userUid];
            NSString *inviteeUid = [NSString stringWithFormat:@"%@", _currentCallOptions.inviteeUserModel.userUid];
            if ([zegoUid isEqualToString:inviterUid]) {
                //邀请者更新
                if (updateType == ZegoUpdateTypeAdd) {
                    //有 新增 音视频流
                    _currentCallOptions.inviterUserModel.callState = ZCallUserStateAccept;
                    _currentCallOptions.inviterUserModel.cameraState = LingIMCallCameraMuteStateOff;//默认是开启摄像头的
                }else if (updateType == ZegoUpdateTypeDelete) {
                    //有 减少 音视频流
                    _currentCallOptions.inviterUserModel.callState = ZCallUserStateHangup;
                }
                
                break;
            }else if ([zegoUid isEqualToString:inviteeUid]) {
                //被邀请者更新
                if (updateType == ZegoUpdateTypeAdd) {
                    //有 新增 音视频流
                    _currentCallOptions.inviteeUserModel.callState = ZCallUserStateAccept;
                    _currentCallOptions.inviteeUserModel.cameraState = LingIMCallCameraMuteStateOff;//默认是开启摄像头的
                }else if (updateType == ZegoUpdateTypeDelete) {
                    //有 减少 音视频流
                    _currentCallOptions.inviteeUserModel.callState = ZCallUserStateHangup;
                }
                
                break;
            }
        }
        
        //通知更新UI
        [[NSNotificationCenter defaultCenter] postNotificationName:ZGCALLROOMSINGLEMEMBERUPDATE object:nil userInfo:nil];
        
    }else if (_currentCallOptions.zgCallOptions.callRoomType == LingIMCallRoomTypeGroup){
        //群聊音视频
        
        //更新成员的状态
        for (NoaCallUserModel *userModel in self.currentCallOptions.callMemberList) {
            
            for (ZegoStream *zegoStream in streamList) {
                NSString *userModelUid = [NSString stringWithFormat:@"%@", userModel.userUid];
                NSString *zegoUid = [NSString stringWithFormat:@"%@", zegoStream.user.userID];
                if ([userModelUid isEqualToString:zegoUid]) {
                    //更新状态
                    if (updateType == ZegoUpdateTypeAdd) {
                        //有 新增 音视频流
                        userModel.callState = ZCallUserStateAccept;
                        userModel.cameraState = LingIMCallCameraMuteStateOff;//默认是开启摄像头的
                    }else if (updateType == ZegoUpdateTypeDelete) {
                        //有 减少 音视频流
                        userModel.callState = ZCallUserStateHangup;
                    }
                    break;
                }
            }
            
        }
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:self.currentCallOptions.groupID forKey:@"groupID"];
        [[NSNotificationCenter defaultCenter] postNotificationName:ZGCALLROOMGROUPMEMBERUPDATE object:nil userInfo:dict];
        
    }
}



@end
