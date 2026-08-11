//
//  NoaMediaCallManager.m
//  NoaKit
//
//  Created by Candy on 2023/1/6.
//

#import "NoaMediaCallManager.h"
#import "NoaToolManager.h"
#import "NoaAppPermissionTipView.h"//权限获取提示框
#import "NoaMediaCallSingleVC.h"//单人
#import "NoaMediaCallMoreVC.h"//多人
#import "NoaNavigationController.h"


@interface NoaMediaCallManager ()
@property (nonatomic, strong) dispatch_source_t callDurationTimer;//通话计时器
@property (nonatomic, assign) NSInteger currentCallDuration;
@end

static dispatch_once_t onceToken;

@implementation NoaMediaCallManager

#pragma mark - 单例>>>>>>
+ (instancetype)sharedManager {
    static NoaMediaCallManager *_manager = nil;
    
    dispatch_once(&onceToken, ^{
        //不再使用alloc方法，因为已经重写了allocWithZone方法，所以这里要调用父类的方法
        _manager = [[super allocWithZone:NULL] init];
    });
    
    return _manager;
}
// 防止外部调用alloc 或者 new
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [NoaMediaCallManager sharedManager];
}
// 防止外部调用copy
- (id)copyWithZone:(nullable NSZone *)zone {
    return [NoaMediaCallManager sharedManager];
}
// 防止外部调用mutableCopy
- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [NoaMediaCallManager sharedManager];
}

#pragma mark - 单例一般不需要清空，但是在执行某些功能的时候，防止数据清空不及时可以清空一下
- (void)clearManager{
    onceToken = 0;
}

#pragma mark - 方法与属性

#pragma mark - 当前是否正在通话中
- (BOOL)currentRoomCalling {
    Room *callRoom = [IMSDKManager imSdkCallRoom];
    if (callRoom.connectionState == ConnectionStateDisconnected) {
        return NO;
    }else {
        return YES;
    }
}

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
        weakSelf.currentCallOptions.callDuration = weakSelf.currentCallDuration;
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(mediaCallCurrentDuration:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.delegate mediaCallCurrentDuration:weakSelf.currentCallDuration];                
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
    }
}

#pragma mark - 发起音视频通话申请
- (void)mediaCallRequestWith:(NoaMediaCallOptions *)callOptions onSuccess:(ZMediaCallSuccessCallBack)onSuccess onFailure:(ZMediaCallFailureCallback)onFailure {
    
    if (callOptions.callType == LingIMCallTypeAudio) {
        //音频通话
        //检查麦克风权限
        BOOL microphoneState = [ZTOOL checkMicrophoneState];
        if (microphoneState) {
            [self callRequestWith:callOptions onSuccess:onSuccess onFailure:onFailure];
        }else {
            [self showPermissionTip];
        }
    }else {
        //视频通话
        //检查麦克风权限
        BOOL microphoneState = [ZTOOL checkMicrophoneState];
        if (microphoneState) {
            //检查摄像头权限
            BOOL cameraState = [ZTOOL checkCameraState];
            if (cameraState) {
                [self callRequestWith:callOptions onSuccess:onSuccess onFailure:onFailure];
            }else {
                [self showPermissionTip];
            }
        }else {
            [self showPermissionTip];
        }
    }
    
}
- (void)callRequestWith:(NoaMediaCallOptions *)callOptions onSuccess:(ZMediaCallSuccessCallBack)onSuccess onFailure:(ZMediaCallFailureCallback)onFailure {
    if (callOptions) {
        
        Room *callRoom = [IMSDKManager imSdkCallRoom];
        
        if (callRoom.connectionState == ConnectionStateDisconnected) {
            //先销毁一下定时器，防止某些原因造成上次计时器不销毁
            [self deallocCurrentCallDurationTimer];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:callOptions.inviteeUid forKey:@"to_id"];//被邀请方
            if (callOptions.callType == LingIMCallTypeAudio) {
                [dict setValue:@(1) forKey:@"mode"];//音频通话
            }else if (callOptions.callType == LingIMCallTypeVideo) {
                [dict setValue:@(0) forKey:@"mode"];//视频通话
            }
            [IMSDKManager imSdkCallRequestCallWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                if ([data isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dataDict = (NSDictionary *)data;
                    LIMMediaCallSingleModel *mediaCallModel = [LIMMediaCallSingleModel mj_objectWithKeyValues:dataDict];
                    callOptions.callMediaModel = mediaCallModel;
                    
                    [NoaMediaCallManager sharedManager].currentCallOptions = callOptions;
                    
                    NoaMediaCallSingleVC *callVC = [NoaMediaCallSingleVC new];
                    callVC.modalPresentationStyle = UIModalPresentationFullScreen;
                    [CurrentVC presentViewController:callVC animated:YES completion:nil];
                }
                if (onSuccess) {
                    onSuccess(data, traceId);
                }
            } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                if (onFailure) {
                    onFailure(code, msg, traceId);
                }
                [HUD showMessageWithCode:code errorMsg:msg];
            }];
            
            
        }else {
            [HUD showErrorMessage:LanguageToolMatch(@"你当前正在通话中")];
        }
        
    }else {
        [HUD showErrorMessage:LanguageToolMatch(@"传入参数不合法")];
    }
}
#pragma mark - 接受音视频通话的邀请(被邀请者同意邀请)
- (void)mediaCallAcceptWith:(NoaMediaCallOptions *)callOptions onSuccess:(ZMediaCallSuccessCallBack)onSuccess onFailure:(ZMediaCallFailureCallback)onFailure {
    if (callOptions) {
        if (callOptions.callType == LingIMCallTypeAudio) {
            //音频通话
            //检查麦克风权限
            BOOL microphoneState = [ZTOOL checkMicrophoneState];
            if (microphoneState) {
                [self callAcceptWith:callOptions onSuccess:onSuccess onFailure:onFailure];
            }else {
                [self showPermissionTip];
            }
        } else {
            //视频通话
            //检查麦克风权限
            BOOL microphoneState = [ZTOOL checkMicrophoneState];
            if (microphoneState) {
                //检查摄像头权限
                BOOL cameraState = [ZTOOL checkCameraState];
                if (cameraState) {
                    [self callAcceptWith:callOptions onSuccess:onSuccess onFailure:onFailure];
                }else {
                    [self showPermissionTip];
                }
            }
        }
    } else {
        [HUD showErrorMessage:LanguageToolMatch(@"传入参数不合法")];
    }
    
}
- (void)callAcceptWith:(NoaMediaCallOptions *)callOptions onSuccess:(ZMediaCallSuccessCallBack)onSuccess onFailure:(ZMediaCallFailureCallback)onFailure {
    Room *callRoom = [IMSDKManager imSdkCallRoom];
    
    if (callRoom.connectionState == ConnectionStateDisconnected) {
    
        //先销毁一下定时器，防止某些原因造成上次计时器不销毁
        [self deallocCurrentCallDurationTimer];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:callOptions.callHashKey forKey:@"hash"];
        
        [IMSDKManager imSdkCallAcceptCallWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dataDict = (NSDictionary *)data;
                LIMMediaCallSingleModel *mediaCallModel = [LIMMediaCallSingleModel mj_objectWithKeyValues:dataDict];
                callOptions.callMediaModel = mediaCallModel;
                
                [NoaMediaCallManager sharedManager].currentCallOptions = callOptions;
                
                NoaMediaCallSingleVC *callVC = [NoaMediaCallSingleVC new];
                callVC.modalPresentationStyle = UIModalPresentationFullScreen;
                [CurrentVC presentViewController:callVC animated:YES completion:nil];
            }
            
            //取消音视频提醒
            [IMSDKManager toolMessageReceiveRemindEndForMediaCall];
            
            if (onSuccess) {
                onSuccess(data, traceId);
            }
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            if (onFailure) {
                onFailure(code, msg, traceId);
            }
            [HUD showMessageWithCode:code errorMsg:msg];
        }];
        
    }else {
        [HUD showErrorMessage:LanguageToolMatch(@"你当前正在通话中")];
    }
    
}

#pragma mark - 取消音视频通话(邀请者/被邀请者取消、挂断、拒绝...)
- (void)mediaCallDiscardWith:(NSMutableDictionary *)params onSuccess:(ZMediaCallSuccessCallBack)onSuccess onFailure:(ZMediaCallFailureCallback)onFailure {
    WeakSelf
    [IMSDKManager imSdkCallDiscardCallWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if (onSuccess) {
            onSuccess(data, traceId);
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        if (onFailure) {
            onFailure(code, msg, traceId);
        }
    }];
    
    //取消音视频提醒
    [IMSDKManager toolMessageReceiveRemindEndForMediaCall];
    
}

#pragma mark - 发起音视频通话者确认通话并创建房间
- (void)mediaCallConfirmWith:(NSMutableDictionary *)params onSuccess:(ZMediaCallSuccessCallBack)onSuccess onFailure:(ZMediaCallFailureCallback)onFailure {
    [IMSDKManager imSdkCallConfirmCallWith:params onSuccess:onSuccess onFailure:onFailure];
}

#pragma mark - 发起 多人音视频通话(邀请者发起)
- (void)mediaCallGroupRequestWith:(NoaMediaCallOptions *)callOptions onSuccess:(ZMediaCallSuccessCallBack)onSuccess onFailure:(ZMediaCallFailureCallback)onFailure {
    if (callOptions.callType == LingIMCallTypeAudio) {
        //音频通话
        //检查麦克风权限
        BOOL microphoneState = [ZTOOL checkMicrophoneState];
        if (microphoneState) {
            [self callGroupRequestWith:callOptions onSuccess:onSuccess onFailure:onFailure];
        }else {
            [self showPermissionTip];
        }
    }else {
        //视频通话
        //检查麦克风权限
        BOOL microphoneState = [ZTOOL checkMicrophoneState];
        if (microphoneState) {
            //检查摄像头权限
            BOOL cameraState = [ZTOOL checkCameraState];
            if (cameraState) {
                [self callGroupRequestWith:callOptions onSuccess:onSuccess onFailure:onFailure];
            }else {
                [self showPermissionTip];
            }
        }else {
            [self showPermissionTip];
        }
    }
}
//多人通话
- (void)callGroupRequestWith:(NoaMediaCallOptions *)callOptions onSuccess:(ZMediaCallSuccessCallBack)onSuccess onFailure:(ZMediaCallFailureCallback)onFailure {
    if (callOptions) {
        Room *callRoom = [IMSDKManager imSdkCallRoom];
        
        if (callRoom.connectionState == ConnectionStateDisconnected) {
            
            //先销毁一下定时器，防止某些原因造成上次计时器不销毁
            [self deallocCurrentCallDurationTimer];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:callOptions.inviteeUidList forKey:@"to_id"];//被邀请方
            [dict setValue:callOptions.groupId forKey:@"chat_id"];//群组ID
            if (callOptions.callType == LingIMCallTypeAudio) {
                [dict setValue:@(1) forKey:@"mode"];//音频通话
            }else if (callOptions.callType == LingIMCallTypeVideo) {
                [dict setValue:@(0) forKey:@"mode"];//视频通话
            }
            
            [IMSDKManager imSdkCallGroupRequestWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                
                if ([data isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dataDict = (NSDictionary *)data;
                    
                    LIMMediaCallGroupModel *mediaCallModel = [LIMMediaCallGroupModel mj_objectWithKeyValues:dataDict];
                    
                    callOptions.callMediaGroupModel = mediaCallModel;
                    
                    __block NSMutableArray *participantList = [NSMutableArray array];
                    [mediaCallModel.participants enumerateObjectsUsingBlock:^(LIMMediaCallGroupParticipant * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NoaMediaCallGroupMemberModel *model = [NoaMediaCallGroupMemberModel new];
                        model.memberState = obj.status == 0 ? ZCallUserStateCalling : ZCallUserStateAccept;//用户状态
                        model.callType = mediaCallModel.mode;//通话类型
                        model.userUid = obj.userUid;
                        model.groupID = mediaCallModel.chat_id;
                        [participantList addObjectIfNotNil:model];
                    }];
                    callOptions.callMediaGroupMemberList = participantList;//当前房间参与者列表
                    
                    [NoaMediaCallManager sharedManager].currentCallOptions = callOptions;
                    
                    NoaMediaCallMoreVC *callVC = [NoaMediaCallMoreVC new];
                    [callVC mediaCallRoomJoin];
                    NoaNavigationController *nav = [[NoaNavigationController alloc] initWithRootViewController:callVC];
                    nav.modalPresentationStyle = UIModalPresentationFullScreen;
                    [CurrentVC presentViewController:nav animated:YES completion:nil];
                }
                if (onSuccess) {
                    onSuccess(data, traceId);
                }
                
            } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                
                if (onFailure) {
                    onFailure(code, msg, traceId);
                }
                [HUD showMessageWithCode:code errorMsg:msg];
                
            }];
            
        }else {
            [HUD showErrorMessage:LanguageToolMatch(@"你当前正在通话中")];
        }
        
    }else {
        [HUD showErrorMessage:LanguageToolMatch(@"传入参数不合法")];
    }
}
#pragma mark - 接受 多人音视频通话 的邀请(被邀请者同意邀请)
- (void)mediaCallGroupAcceptWith:(NoaMediaCallOptions *)callOptions onSuccess:(ZMediaCallSuccessCallBack)onSuccess onFailure:(ZMediaCallFailureCallback)onFailure {
    
    if (callOptions) {
        if (callOptions.callType == LingIMCallTypeAudio) {
            //音频通话
            //检查麦克风权限
            BOOL microphoneState = [ZTOOL checkMicrophoneState];
            if (microphoneState) {
                [self callGroupAcceptWith:callOptions onSuccess:onSuccess onFailure:onFailure];
            }else {
                [self showPermissionTip];
            }
        } else {
            //视频通话
            //检查麦克风权限
            BOOL microphoneState = [ZTOOL checkMicrophoneState];
            if (microphoneState) {
                //检查摄像头权限
                BOOL cameraState = [ZTOOL checkCameraState];
                if (cameraState) {
                    [self callGroupAcceptWith:callOptions onSuccess:onSuccess onFailure:onFailure];
                }else {
                    [self showPermissionTip];
                }
            }
        }
    } else {
        [HUD showErrorMessage:LanguageToolMatch(@"传入参数不合法")];
    }
    
}

- (void)callGroupAcceptWith:(NoaMediaCallOptions *)callOptions onSuccess:(ZMediaCallSuccessCallBack)onSuccess onFailure:(ZMediaCallFailureCallback)onFailure {
    Room *callRoom = [IMSDKManager imSdkCallRoom];
    
    if (callRoom.connectionState == ConnectionStateDisconnected) {
        
        //先销毁一下定时器，防止某些原因造成上次计时器不销毁
        [self deallocCurrentCallDurationTimer];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:callOptions.callHashKey forKey:@"hash"];
        
        [IMSDKManager imSdkCallGroupAcceptWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            if (onSuccess) {
                onSuccess(data, traceId);
            }
            
            //取消音视频提醒
            [IMSDKManager toolMessageReceiveRemindEndForMediaCall];
            
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            if (onFailure) {
                onFailure(code, msg, traceId);
            }
            [HUD showMessageWithCode:code errorMsg:msg];
            
        }];
        
    }else {
        [HUD showErrorMessage:LanguageToolMatch(@"你当前正在通话中")];
    }
    
}
#pragma mark - 邀请加入 多人音视频通话
- (void)mediaCallGroupInviteWith:(NSMutableDictionary *)params onSuccess:(ZMediaCallSuccessCallBack)onSuccess onFailure:(ZMediaCallFailureCallback)onFailure {
    [IMSDKManager imSdkCallGroupInviteWith:params onSuccess:onSuccess onFailure:onFailure];
}

#pragma mark - 主动加入多人音视频通话
- (void)mediaCallGroupJoinWith:(NSMutableDictionary *)params onSuccess:(ZMediaCallSuccessCallBack)onSuccess onFailure:(ZMediaCallFailureCallback)onFailure {
    
    //先销毁一下定时器，防止某些原因造成上次计时器不销毁
    [self deallocCurrentCallDurationTimer];
    
    [IMSDKManager imSdkCallGroupJoinWith:params onSuccess:onSuccess onFailure:onFailure];
}

#pragma mark - 取消 多人音视频通话(邀请者/被邀请者取消、挂断、拒绝...)
- (void)mediaCallGroupDiscardWith:(NSMutableDictionary *)params onSuccess:(ZMediaCallSuccessCallBack)onSuccess onFailure:(ZMediaCallFailureCallback)onFailure {
    WeakSelf
    [IMSDKManager imSdkCallGroupDiscardWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if (onSuccess) {
            onSuccess(data, traceId);
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        if (onFailure) {
            onFailure(code, msg, traceId);
        }
    }];
    
    //取消音视频提醒
    [IMSDKManager toolMessageReceiveRemindEndForMediaCall];
}

#pragma mark - 多人音视频通话状态(用于判断某群是否有多人通话)
- (void)mediaCallGroupState:(NSMutableDictionary *)params onSuccess:(ZMediaCallSuccessCallBack)onSuccess onFailure:(ZMediaCallFailureCallback)onFailure {
    [IMSDKManager imSdkCallGroupStateWith:params onSuccess:onSuccess onFailure:onFailure];
}


#pragma mark - 断开音视频连接
- (void)mediaCallDisconnect {
    [IMSDKManager imSdkCallRoomDisconnect];
    //设置为可息屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

#pragma mark - 音视频房间信息
- (Room *)mediaCallRoom {
    return [IMSDKManager imSdkCallRoom];
}

#pragma mark - 房间远端参与者
- (NSArray *)mediaCallRoomRemotePaticipants {
    return [IMSDKManager imSdkCallRoomGetRemoteParticipants];
}

#pragma mark - 音频是否静默
- (void)mediaCallAudioMute:(BOOL)isMuted complete:(nonnull void (^)(BOOL))muteBlock{
    [IMSDKManager imSdkCallRoomAudioMuteWith:isMuted complete:^(BOOL isMuted) {
        if (muteBlock) {
            muteBlock(isMuted);
        }
    }];
}

#pragma mark - 视频是否静默
- (void)mediaCallVideoMute:(BOOL)isMuted complete:(void (^)(BOOL))muteBlock {
    [IMSDKManager imSdkCallRoomVideoMuteWith:isMuted complete:^(BOOL isMuted) {
        if (muteBlock) {
            muteBlock(isMuted);
        }
    }];
}

#pragma mark - 音频输出方式
- (void)mediaCallAudioSpeaker:(BOOL)isSpeaker {
    
    if (!isSpeaker) {
        //听筒
        [IMSDKManager imSdkCallRoomAudioExternalMuteWith:YES];
    }else {
        //扬声器
        [IMSDKManager imSdkCallRoomAudioExternalMuteWith:NO];
    }
    
}

#pragma mark - 视频摄像头方向切换
- (void)mediaCallVideoCameraSwitch:(void (^)(BOOL))cameraSwitchResult {
    [IMSDKManager imSdkCallRoomVideoCameraSwitch:^(BOOL success) {
        if (cameraSwitchResult) {
            cameraSwitchResult(success);
        }
    }];
}

#pragma mark - 连接房间
- (void)mediaCallConnectRoomWith:(NoaIMCallOptions *)callOptions delegate:(id <RoomDelegateObjC>)roomDelegate {
    //先判断是否有上次的计时器需要销毁
    [self deallocCurrentCallDurationTimer];
    //连接音视频房间
    [IMSDKManager imSdkCallRoomConnectWithOptions:callOptions delegate:roomDelegate];
}

#pragma mark - 服从房间代理
- (void)mediaCallRoomDelegate:(id <RoomDelegateObjC>)roomDelegate {
    [IMSDKManager imSdkCallRoomDelegate:roomDelegate];
}

#pragma mark - 某轨道的视频是否静默
- (BOOL)mediaCallRoomVideoMutedWith:(Participant *)aParticipant {
    if ([aParticipant isKindOfClass:[LocalParticipant class]]) {
        //本地参与者
        LocalParticipant *loacalParticipant = (LocalParticipant *)aParticipant;
        LocalTrackPublication *localVideoTrack = loacalParticipant.localVideoTracks.firstObject;
        return localVideoTrack.muted;
    }else {
        //远端参与者
        RemoteParticipant *remoteParticipant = (RemoteParticipant *)aParticipant;
        TrackPublication *remoteVideoTrack = remoteParticipant.videoTracks.firstObject;
        return remoteVideoTrack.muted;
    }
}

#pragma mark - 某轨道的音频是否静默
- (BOOL)mediaCallRoomAudioMutedWith:(Participant *)aParticipant {
    if ([aParticipant isKindOfClass:[LocalParticipant class]]) {
        //本地参与者
        LocalParticipant *loacalParticipant = (LocalParticipant *)aParticipant;
        LocalTrackPublication *localAudioTrack = loacalParticipant.localAudioTracks.firstObject;
        return localAudioTrack.muted;
    }else {
        //远端参与者
        RemoteParticipant *remoteParticipant = (RemoteParticipant *)aParticipant;
        TrackPublication *remoteAudioTrack = remoteParticipant.audioTracks.firstObject;
        return remoteAudioTrack.muted;
    }
}

#pragma mark - 音视频通话权限提示框
- (void)showPermissionTip {
    [ZTOOL doInMain:^{
        NoaAppPermissionTipView *viewTip = [NoaAppPermissionTipView new];
        [viewTip permissionTipViewSHow];
    }];
}

@end
