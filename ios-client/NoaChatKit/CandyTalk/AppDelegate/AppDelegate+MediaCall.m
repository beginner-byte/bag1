//
//  AppDelegate+MediaCall.m
//  NoaKit
//
//  Created by Candy on 2023/5/29.
//

#import "AppDelegate+MediaCall.h"
#import "NoaToolManager.h"
#import "NoaNavigationController.h"

//LiveKit音视频
#import "NoaMediaCallManager.h"
#import "NoaMediaCallMiniView.h"
#import "NoaMediaCallSingleVC.h"
#import "NoaMediaCallMoreVC.h"

//即构音视频
#import "NoaCallManager.h"
#import "NoaCallMiniView.h"
#import "NoaCallSingleVC.h"
#import "NoaCallGroupVC.h"

@implementation AppDelegate (MediaCall)
#pragma mark - 音视频配置
- (void)configMediaCall {
    if (!UserManager.isLogined) return;
    
    [IMSDKManager addMediaCallDelegate:self];//音视频通话代理
}

#pragma mark - <ZWindowFloatViewDelegate>
/// 开始拖动
- (void)beganDragFloatView:(NoaWindowFloatView *)floatView {
    
}
/// 拖动中...
- (void)duringDragFloatView:(NoaWindowFloatView *)floatView {
    
}
/// 结束拖动
- (void)endDragFloatView:(NoaWindowFloatView *)floatView {
    
}
/// 点击事件
- (void)clickFloatView:(NoaWindowFloatView *)floatView {
    
    //移除当前的浮窗
    [self removeWindowFloat];
    
    if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"0"]) {
        //LiveKit SDK
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            NoaMediaCallOptions *currentCallOptions = [NoaMediaCallManager sharedManager].currentCallOptions;
            
            if (currentCallOptions.callRoomType == ZIMCallRoomTypeSingle) {
                NoaMediaCallSingleVC *callVC = [NoaMediaCallSingleVC new];
                callVC.modalPresentationStyle = UIModalPresentationFullScreen;
                [CurrentVC presentViewController:callVC animated:YES completion:nil];
            }else {
                NoaMediaCallMoreVC *callVC = [NoaMediaCallMoreVC new];
                NoaNavigationController *nav = [[NoaNavigationController alloc] initWithRootViewController:callVC];
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                [CurrentVC presentViewController:nav animated:YES completion:nil];
            }
        });
        
    } else if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"1"]) {
        //即构 SDK
        NoaCallOptions *currentCallOptions = [NoaCallManager sharedManager].currentCallOptions;
        switch ([NoaCallManager sharedManager].callSDKType) {
            case LingIMCallSDKTypeZego:
            {
                //即构音视频
                if ([NoaCallManager sharedManager].callState != ZCallStateEnd) {
                    if (currentCallOptions.zgCallOptions.callRoomType == LingIMCallRoomTypeSingle) {
                        //单聊音视频
                        NoaCallSingleVC *vc = [NoaCallSingleVC new];
                        vc.modalPresentationStyle = UIModalPresentationFullScreen;
                        [CurrentVC presentViewController:vc animated:YES completion:nil];
                    }else {
                        //群聊音视频
                        NoaCallGroupVC *vc = [NoaCallGroupVC new];
                        NoaNavigationController *nav = [[NoaNavigationController alloc] initWithRootViewController:vc];
                        nav.modalPresentationStyle = UIModalPresentationFullScreen;
                        [CurrentVC presentViewController:nav animated:YES completion:nil];
                    }
                }
            }
                break;
                
            default:
                break;
        }
    }
    

}

//移除全局浮窗
- (void)removeWindowFloat {
    if (self.viewFloatWindow) {
        
        self.viewFloatWindow.delegate = nil;
        
        //移除浮窗里所有的子视图
        [self.viewFloatWindow.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        //移除浮窗
        [self.viewFloatWindow removeFromSuperview];
        self.viewFloatWindow = nil;
        
        /*
        WeakSelf
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            [ZTOOL doInMain:^{
                //移除浮窗里所有的子视图
                [weakSelf.viewFloatWindow.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                //移除浮窗
                [weakSelf.viewFloatWindow removeFromSuperview];
                weakSelf.viewFloatWindow = nil;
            }];
        });
        */
    }
}

#pragma mark - <LingIMMediaSessionDelegate>
#pragma mark - LiveKit单人音视频回调
- (void)imSdkMediaCallSingleInviteeReceiveRequestWith:(LIMMediaCallModel *)mediaCallModel {
    
    if ([NoaMediaCallManager sharedManager].mediaCallState != ZMediaCallStateEnd) {
        //当前正在通话进程中
        LIMMediaCallSingleModel *singleModel = mediaCallModel.callSingleModel;
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:singleModel.hashKey forKey:@"hash"];//房间唯一标识
        [dict setValue:@"refused" forKey:@"reason"];//当前正在通话中，拒绝新的通话邀请
        [[NoaMediaCallManager sharedManager] mediaCallDiscardWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            [HUD showMessageWithCode:code errorMsg:msg];
        }];
        
    }else {
        //提示接收到通话邀请
        LIMMediaCallSingleModel *singleModel = mediaCallModel.callSingleModel;
        
        NoaMediaCallOptions *callOptions = [NoaMediaCallOptions new];
        callOptions.callRoleType = LingIMCallRoleTypeResponse;//我是被邀请者
        callOptions.inviteeUid = UserManager.userInfo.userUID;//我是被邀请者
        callOptions.callRoomType = ZIMCallRoomTypeSingle;//单人音视频
        callOptions.callMediaModel = singleModel;//音视频信息
        callOptions.callType = singleModel.mode;//通话类型类型
        callOptions.inviterUid = singleModel.from_id;//发起者Uid
        callOptions.callMicState = LingIMCallMicrophoneMuteStateOff;//音频打开
        callOptions.callCameraState = LingIMCallCameraMuteStateOff;//视频打开
        
        [NoaMediaCallManager sharedManager].currentCallOptions = callOptions;
        
        //开始消息提醒
        [IMSDKManager toolMessageReceiveRemindForMediaCall];
        
        NoaMediaCallMiniView *viewCall = [NoaMediaCallMiniView new];
        viewCall.mediaCallOptions = callOptions;
        [viewCall mediaCallMiniViewShow];
    }
}
- (void)imSdkMediaCallSingleInviterWaitingInviteeDealWith:(LIMMediaCallModel *)mediaCallModel {
    DLog(@"A邀请者收到：B被邀请者已经接收到你的通话请求，请等待B被邀请者处理同意或拒绝");
}
- (void)imSdkMediaCallSingleInviteeAcceptRequestWith:(LIMMediaCallModel *)mediaCallModel {
    DLog(@"A邀请者收到：B被邀请者同意音视频通话，创建房间");
    
    LIMMediaCallSingleModel *singleModel = mediaCallModel.callSingleModel;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:singleModel.hashKey forKey:@"hash"];
    
    [[NoaMediaCallManager sharedManager] mediaCallConfirmWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *dataDict = (NSDictionary *)data;
            
            LIMMediaCallSingleModel *newCallModel = [LIMMediaCallSingleModel mj_objectWithKeyValues:dataDict];
            [NoaMediaCallManager sharedManager].currentCallOptions.callMediaModel = newCallModel;
            
            //通知更新了房间信息，邀请者可以加入房间了
            [[NSNotificationCenter defaultCenter] postNotificationName:CALLROOMJOIN object:nil];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

/// 邀请者 确认了 音视频通话的房间
- (void)imSdkMediaCallSingleInviterConfirmRoomWith:(LIMMediaCallModel *)mediaCallModel {
    
    //单人 被邀请者 可加入房间
    LIMMediaCallSingleModel *singleModel = mediaCallModel.callSingleModel;
    //更新房间信息
    [NoaMediaCallManager sharedManager].currentCallOptions.callMediaModel = singleModel;
    
    //通知更新了房间信息，被邀请者可以加入房间了
    [[NSNotificationCenter defaultCenter] postNotificationName:CALLROOMJOIN object:nil];
    
}

/// 单人音视频 断开通话房间连接
- (void)imSdkMediaCallSingleDiscardWith:(LIMMediaCallModel *)mediaCallModel {
    if ([NoaMediaCallManager sharedManager].currentRoomCalling) {
        //断开房间连接
        [[NoaMediaCallManager sharedManager] mediaCallDisconnect];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CALLROOMCANCEL object:nil];
    
    //通话进程结束
    [NoaMediaCallManager sharedManager].mediaCallState = ZMediaCallStateEnd;
    //取消消息提醒
    [IMSDKManager toolMessageReceiveRemindEndForMediaCall];
    
    //移除全局浮窗(如果有的话)
    [self removeWindowFloat];
    
    LIMMediaCallSingleModel *singleModel = mediaCallModel.callSingleModel;
    if ([singleModel.discard_reason isEqualToString:@"disconnect"]) {
        //通话中断、服务器强制挂断
        //告知 邀请者 展示 如：通话中断
        //告知 被邀请者 展示 如：通话中断
    }else if ([singleModel.discard_reason isEqualToString:@"missed"]) {
        //呼叫超时(被邀请者 长时间未响应 邀请)
        //告知 邀请者 展示 如：对方无应答
        //告知 被邀请者 展示 如：超时未应答
    }else if ([singleModel.discard_reason isEqualToString:@"cancel"]) {
        //呼叫取消(邀请者 在 被邀请者 接受之前 取消邀请)
        //告知 邀请者 展示 如：通话已取消
        //告知 被邀请者 展示 如：对方已取消
    }else if ([singleModel.discard_reason isEqualToString:@"refused"]) {
        //呼叫拒绝(被邀请者 拒绝 邀请)
        //告知 邀请者 展示 如：对方已拒绝
        //告知 被邀请者 展示 如：已拒绝
    }else if ([singleModel.discard_reason isEqualToString:@"accept"]) {
        //呼叫已接听(被邀请者 已接受 邀请，被邀请者的其他设备会收到此消息)
        //告知 被邀请者 展示 如：已在其他设备接听
    }else {
        //通话正常挂断
        //告知 邀请者 展示 如：10:00通话
        //告知 被邀请者 展示 如：10:00通话
    }
    
}

#pragma mark - LiveKit多人音视频回调
/// 多人音视频 发起申请音视频通话(被邀请者响应)(被邀请的人，才会出发此回调)
- (void)imSdkMediaCallGroupRequestWith:(LIMMediaCallModel *)mediaCallModel {
    if ([NoaMediaCallManager sharedManager].mediaCallState != ZMediaCallStateEnd) {
        //当前正在通话进程中
        LIMMediaCallGroupModel *groupModel = mediaCallModel.callGroupModel;
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:groupModel.hashKey forKey:@"hash"];//房间唯一标识
        [dict setValue:@"refused" forKey:@"reason"];//当前正在通话中，拒绝新的通话邀请
        [[NoaMediaCallManager sharedManager] mediaCallGroupDiscardWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            [HUD showMessageWithCode:code errorMsg:msg];
        }];
    }else {
        //提示接收到通话邀请
        LIMMediaCallGroupModel *groupModel = mediaCallModel.callGroupModel;
        
        NoaMediaCallOptions *callOptions = [NoaMediaCallOptions new];
        callOptions.callRoleType = LingIMCallRoleTypeResponse;//我是被邀请者
        callOptions.inviteeUid = UserManager.userInfo.userUID;//我是被邀请者
        callOptions.callRoomType = ZIMCallRoomTypeGroup;//多人音视频
        callOptions.callMediaGroupModel = groupModel;//音视频信息
        callOptions.callType = groupModel.mode;//通话类型类型
        callOptions.inviterUid = groupModel.args.firstObject;//对我发起邀请的 发起者Uid
        callOptions.groupId = groupModel.chat_id;//多人音视频通话群组ID
        callOptions.callMicState = LingIMCallMicrophoneMuteStateOff;//音频打开
        callOptions.callCameraState = LingIMCallCameraMuteStateOff;//视频打开
        
        __block NSMutableArray *participantList = [NSMutableArray array];
        [groupModel.participants enumerateObjectsUsingBlock:^(LIMMediaCallGroupParticipant * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NoaMediaCallGroupMemberModel *model = [NoaMediaCallGroupMemberModel new];
            model.memberState = obj.status == 0 ? ZCallUserStateCalling : ZCallUserStateAccept;//用户状态
            model.callType = groupModel.mode;//通话类型
            model.userUid = obj.userUid;
            model.groupID = groupModel.chat_id;
            [participantList addObjectIfNotNil:model];
        }];
        callOptions.callMediaGroupMemberList = participantList;//当前房间参与者列表
        
        [NoaMediaCallManager sharedManager].currentCallOptions = callOptions;
        
        NoaMediaCallMiniView *viewCall = [NoaMediaCallMiniView new];
        viewCall.mediaCallOptions = callOptions;
        [viewCall mediaCallMiniViewShow];
        
        //开始多人音视频的铃声提醒
        [IMSDKManager toolMessageReceiveRemindForMediaCall];
        
    }
}

/// 多人音视频 邀请成员加入音视频通话
- (void)imSdkMediaCallGroupInviteWith:(LIMMediaCallModel *)mediaCallModel {
    LIMMediaCallGroupModel *groupModel = mediaCallModel.callGroupModel;
    DLog(@"多人音视频邀请了新成员加入：%@",groupModel);
    
    //当前会话信息
    NoaMediaCallOptions *currentOptions = [NoaMediaCallManager sharedManager].currentCallOptions;
    //取出当前房间参与者信息
    __block NSMutableArray *currentMemberUidList = [NSMutableArray array];
    __block NSMutableArray *currentMemberList = [NSMutableArray arrayWithArray:currentOptions.callMediaGroupMemberList];
    
    [currentOptions.callMediaGroupMemberList enumerateObjectsUsingBlock:^(NoaMediaCallGroupMemberModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [currentMemberUidList addObjectIfNotNil:obj.userUid];
    }];
    
    [groupModel.args enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![currentMemberUidList containsObject:obj]) {
            NoaMediaCallGroupMemberModel *model = [NoaMediaCallGroupMemberModel new];
            model.memberState = ZCallUserStateCalling;//用户状态
            model.callType = groupModel.mode;//通话类型
            model.userUid = obj;
            model.groupID = groupModel.chat_id;
            [currentMemberList addObjectIfNotNil:model];
        }
    }];
    currentOptions.callMediaGroupMemberList = currentMemberList;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CALLROOMGROUPMEMBERUPDATE object:nil];
    
}

/// 多人音视频 某成员加入音视频通话
- (void)imSdkMediaCallGroupJoinWith:(LIMMediaCallModel *)mediaCallModel {
    LIMMediaCallGroupModel *groupModel = mediaCallModel.callGroupModel;
    DLog(@"多人音视频新成员主动加入：%@--使用LiveKitSDK回调来实现UI更新",groupModel);
    
}

/// 多人音视频 某成员离开音视频通话
- (void)imSdkMediaCallGroupLeaveWith:(LIMMediaCallModel *)mediaCallModel {
    LIMMediaCallGroupModel *groupModel = mediaCallModel.callGroupModel;
    DLog(@"多人音视频成员离开：%@--离开原因:%@", groupModel, groupModel.reason);
    
    //当前会话信息
    NoaMediaCallOptions *currentOptions = [NoaMediaCallManager sharedManager].currentCallOptions;
    NSString *leaveUserUid = groupModel.args.firstObject;//目前是单个人
    
    if ([groupModel.reason isEqualToString:@"refused"]) {
        //拒绝接听
        
        [currentOptions.callMediaGroupMemberList enumerateObjectsUsingBlock:^(NoaMediaCallGroupMemberModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([model.userUid isEqualToString:leaveUserUid]) {
                //删除本地维护的该成员信息
                [currentOptions.callMediaGroupMemberList removeObjectAtIndex:idx];
                *stop = YES;
            }
        }];
        
        //通知UI修改
        NoaMediaCallGroupMemberModel *leaveModel = [NoaMediaCallGroupMemberModel new];
        leaveModel.userUid = leaveUserUid;
        leaveModel.callType = groupModel.mode;
        leaveModel.memberState = ZCallUserStateRefuse;
        leaveModel.groupID = groupModel.chat_id;
        NSDictionary *modelDict = [leaveModel mj_JSONObject];
        [[NSNotificationCenter defaultCenter] postNotificationName:CALLROOMGROUPMEMBERLEAVE object:nil userInfo:modelDict];
        
    }else if ([groupModel.reason isEqualToString:@"timeout"]) {
        //呼叫超时
        [currentOptions.callMediaGroupMemberList enumerateObjectsUsingBlock:^(NoaMediaCallGroupMemberModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([model.userUid isEqualToString:leaveUserUid]) {
                //删除本地维护的该成员信息
                [currentOptions.callMediaGroupMemberList removeObjectAtIndex:idx];
                *stop = YES;
            }
        }];
        
        //通知UI修改
        NoaMediaCallGroupMemberModel *leaveModel = [NoaMediaCallGroupMemberModel new];
        leaveModel.userUid = leaveUserUid;
        leaveModel.callType = groupModel.mode;
        leaveModel.memberState = ZCallUserStateTimeOut;
        leaveModel.groupID = groupModel.chat_id;
        NSDictionary *modelDict = [leaveModel mj_JSONObject];
        [[NSNotificationCenter defaultCenter] postNotificationName:CALLROOMGROUPMEMBERLEAVE object:nil userInfo:modelDict];
        
        if ([leaveUserUid isEqualToString:UserManager.userInfo.userUID]) {
            //我超时未响应通话邀请，离开
            [[NSNotificationCenter defaultCenter] postNotificationName:CALLROOMCANCEL object:nil];
            
            //取消音视频提醒
            [IMSDKManager toolMessageReceiveRemindEndForMediaCall];
            //通话进程状态为结束
            [NoaMediaCallManager sharedManager].mediaCallState = ZMediaCallStateEnd;
            
            //移除全局浮窗(如果有的话)
            [self removeWindowFloat];
        }
        
    }else {
        //正常离开房间
        DLog(@"正常离开成员，使用LiveKitSDK回调来实现UI更新");
    }
    
}

/// 多人音视频 挂断音视频通话(根据挂断原因处理)
- (void)imSdkMediaCallGroupDiscardWith:(LIMMediaCallModel *)mediaCallModel {
    LIMMediaCallGroupModel *groupModel = mediaCallModel.callGroupModel;
    DLog(@"多人音视频挂断：%@--挂断原因:%@", groupModel, groupModel.reason);
    //""通话正常结束 accept已在其他设备接听
    
    if ([NoaMediaCallManager sharedManager].currentRoomCalling) {
        //断开房间连接
        [[NoaMediaCallManager sharedManager] mediaCallDisconnect];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CALLROOMCANCEL object:nil];
    
    //通话进程状态为结束
    [NoaMediaCallManager sharedManager].mediaCallState = ZMediaCallStateEnd;
    
    if ([groupModel.reason isEqualToString:@"accept"]) {
        //我已在其他设备接听，挂断还需如下操作
    }else {
        //通话正常挂断
    }
    
    //取消音视频提醒(逻辑上，其实可以不用调用此方法的，但是防止发送收到错误的消息，导致挂断还有消息提醒的问题，所以也调用一下)
    [IMSDKManager toolMessageReceiveRemindEndForMediaCall];
    
    //移除全局浮窗(如果有的话)
    [self removeWindowFloat];
    
}

#pragma mark - 即构音视频代理回调
//被邀请者收到邀请者发来的音视频通话请求
- (void)imSdkCallInviteeReceiveRequestWith:(IMChatMessage *)chatMessageCall {
    
    NetCallMessage *callMessage = chatMessageCall.netCallMessage;
    
    if ([NoaCallManager sharedManager].callState == ZCallStateEnd) {
        //当前没有通话进程
        
        if (callMessage.chatType == 1) {
            //1单聊音视频
            
            //开始消息提醒
            [IMSDKManager toolMessageReceiveRemindForMediaCall];
            //单聊被邀请者配置
            [self zgCallInviteeWith:chatMessageCall];
            //展示小弹窗，提示，我 收到了音视频通话的邀请
            NoaCallMiniView *viewCall = [NoaCallMiniView new];
            [viewCall mediaCallMiniViewShow];
            
        }else if (callMessage.chatType == 2) {
            //2群聊音视频
            NSString *mineUserUid = [NSString stringWithFormat:@"%@", UserManager.userInfo.userUID];
            
            if ([callMessage.operationUsersArray containsObject:mineUserUid] && ![chatMessageCall.from isEqualToString:mineUserUid]) {
                //我被邀请加入
                //开始消息提醒
                [IMSDKManager toolMessageReceiveRemindForMediaCall];
                //群聊被邀请者配置
                [self zgCallGroupInviteeWith:chatMessageCall];
                //展示小弹窗，提示，我 收到了音视频通话的邀请
                NoaCallMiniView *viewCall = [NoaCallMiniView new];
                [viewCall mediaCallMiniViewShow];
                
            }else {
                //我所在的群，发起了群聊音视频通话，我没有参与通话
                [self zgCallOtherGroupChangeWith:chatMessageCall];
            }
            
            
        }
        
    }else {
        //当前有通话进程，不处理新的音视频通话申请，交给后台进行超时的处理
    }
    
}

//被邀请者同意了邀请者发来的音视频通话请求
- (void)imSdkCallInviteeAcceptRequestWith:(IMChatMessage *)chatMessageCall {
    
    NetCallMessage *callMessage = chatMessageCall.netCallMessage;
    
    if (callMessage.chatType == 1) {
        //1单聊音视频
        //通知更新了房间信息，邀请者可以加入房间了
        [[NSNotificationCenter defaultCenter] postNotificationName:ZGCALLROOMJOIN object:nil];
    }else {
        //2.群聊音视频，不会触发该回调
    }
    
    
    //        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC));
    //        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
    //        });
    
}
//音视频通话结束了
- (void)imSdkCallDiscardWith:(IMChatMessage *)chatMessageCall {
    NetCallMessage *callMessage = chatMessageCall.netCallMessage;
    if (callMessage.chatType == 1) {
        //单聊音视频
        [self zgCallDiscard];
        
    }else {
        //群聊音视频
        
        //群聊 结束 的群ID
        NSString *discardGroupID = [NSString stringWithFormat:@"%@", chatMessageCall.to];
        //判断我当前群聊音视频是不是已经结束
        NoaCallOptions *currentCallOptions = [NoaCallManager sharedManager].currentCallOptions;
        NSString *currentCallGroupID = [NSString stringWithFormat:@"%@", currentCallOptions.groupID];
        
        if ([currentCallGroupID isEqualToString:discardGroupID]) {
            //我当前参与的 群聊 音视频通话 结束了
            [self zgCallDiscard];
        }else {
            //我所在的其他群的音视频通话结束了
            [self zgCallOtherGroupChangeWith:chatMessageCall];
        }
        
    }
}

//音视频通话 群聊 成员状态变化
- (void)imSdkCallGroupMemberStateChangeWith:(IMChatMessage *)chatMessageCall {
    NoaCallOptions *currentCallOptions = [NoaCallManager sharedManager].currentCallOptions;
    
    NSString *callGroupID = [NSString stringWithFormat:@"%@", chatMessageCall.to];
    
    NSString *currentCallGroupID = [NSString stringWithFormat:@"%@", currentCallOptions.groupID];
    
    if ([currentCallGroupID isEqualToString:callGroupID]) {
        //我当前参与的群聊音视频通话，成员发生变化
        [self zgCallGroupMemberChangeWith:chatMessageCall];
    }else {
        //我所在的其他群组的音视频通话成员发生变化
        [self zgCallOtherGroupChangeWith:chatMessageCall];
    }
}


#pragma mark - 即构 单聊 音视频通话 被邀请者配置相关参数
- (void)zgCallInviteeWith:(IMChatMessage *)chatMessageCall {
    //此时，我一定是被邀请者
    NetCallMessage *callMessage = chatMessageCall.netCallMessage;
    
    //1.配置 单聊 音视频通话 被邀请者信息
    NoaCallUserModel *inviteeUserModel = [NoaCallUserModel new];
    inviteeUserModel.userUid = UserManager.userInfo.userUID;//用户ID
    inviteeUserModel.userShowName = UserManager.userInfo.userName;//用户昵称
    inviteeUserModel.userAvatar = UserManager.userInfo.avatar;//用户头像
    inviteeUserModel.micState = LingIMCallMicrophoneMuteStateOff;//默认开启麦克风
    inviteeUserModel.speakerState = LingIMCallSpeakerMuteStateOn;//默认关闭扬声器
    inviteeUserModel.cameraState = LingIMCallCameraMuteStateOff;//默认开启摄像头(我被邀请者)
    inviteeUserModel.cameraDirection = LingIMCallCameraDirectionFront;//默认前置摄像头(我被邀请者)
    inviteeUserModel.streamID = UserManager.userInfo.userUID;//音视频轨道流ID
    
    //2.配置 单聊 音视频通话 邀请者信息
    NoaCallUserModel *inviterUserModel = [NoaCallUserModel new];
    inviterUserModel.userUid = callMessage.roomCreateUser;//用户ID
    inviterUserModel.userShowName = chatMessageCall.nick;//用户昵称
    inviterUserModel.userAvatar = chatMessageCall.icon;//用户头像
    inviterUserModel.streamID = callMessage.roomCreateUser;//音视频轨道流ID
    inviterUserModel.cameraState = LingIMCallCameraMuteStateOn;//默认关闭摄像头，因为此时邀请者没有响应，先展示邀请者的头像
    inviterUserModel.micState = LingIMCallMicrophoneMuteStateOff;//默认开启麦克风
    inviterUserModel.cameraDirection = LingIMCallCameraDirectionFront;//默认前置摄像头
    inviterUserModel.speakerState = LingIMCallSpeakerMuteStateOff;//默认开启扬声器
    
    //3.配置 单聊 音视频通话 参数
    NoaIMZGCallOptions *zgCallOptions = [NoaIMZGCallOptions new];
    zgCallOptions.callRoomCreateUserID = callMessage.roomCreateUser;//房间创建者(邀请者)
    zgCallOptions.callType = callMessage.callType;//1语音通话2视频通话
    zgCallOptions.callRoomType = callMessage.chatType;//1单聊2群聊 此处为单聊
    zgCallOptions.callID = callMessage.callId;//通话ID
    zgCallOptions.callRoomID = callMessage.roomId;//房间ID
    zgCallOptions.callRoomToken = callMessage.token;//房间token令牌
    //zgCallOptions.callTimeout = callMessage.timeout;//呼叫超时市场
    //zgCallOptions.callStatus = callMessage.status;//通话状态
    //zgCallOptions.callDuration = callMessage.duration;//通话时长
    zgCallOptions.callRoomUserID = UserManager.userInfo.userUID;//音视频房间推流的用户ID(被邀请者)
    zgCallOptions.callRoomUserNickname = UserManager.userInfo.nickname;//音视频房间推流的用户昵称(被邀请者)
    zgCallOptions.callRoomUserStreamID = UserManager.userInfo.userUID;//音视频房间推流的音视频流ID(被邀请者)
    zgCallOptions.callMicState = LingIMCallMicrophoneMuteStateOff;//音视频房间推流默认开启麦克风(被邀请者)
    zgCallOptions.callSpeakerState = LingIMCallSpeakerMuteStateOn;//音视频房间推流默认关闭扬声器(被邀请者)
    zgCallOptions.callCameraState = LingIMCallCameraMuteStateOff;//音视频房间推流默认开启摄像头(被邀请者)
    zgCallOptions.callCameraDirection = LingIMCallCameraDirectionFront;//音视频房间推流默认前置摄像头(被邀请者)
    
    
    //4.业务层 配置 单聊 音视频通话 参数
    __block NoaCallOptions *callOptions = [NoaCallOptions new];
    callOptions.zgCallOptions = zgCallOptions;
    callOptions.inviterUserModel = inviterUserModel;
    callOptions.inviteeUserModel = inviteeUserModel;
    
    NoaCallManager *callManager = [NoaCallManager sharedManager];
    callManager.currentCallOptions = callOptions;
    callManager.showMeTrack = YES;//默认，本地 我 的轨道流 固定在主屏幕上
    callManager.callState = ZCallStateBegin;
}

#pragma mark - 即构 群聊 音视频通话 被邀请者配置相关参数
- (void)zgCallGroupInviteeWith:(IMChatMessage *)chatMessageCall {
    //此时，我一定是被邀请者
    NetCallMessage *callMessage = chatMessageCall.netCallMessage;
    
    //1.配置 群聊 音视频通话 参数
    NoaIMZGCallOptions *zgCallOptions = [NoaIMZGCallOptions new];
    zgCallOptions.callRoomCreateUserID = callMessage.roomCreateUser;//房间创建者
    zgCallOptions.callRoomType = callMessage.chatType;//1单聊2群聊 此处为群聊
    zgCallOptions.callType = callMessage.callType;//1语音通话2视频通话
    zgCallOptions.callID = callMessage.callId;//通话标识
    zgCallOptions.callRoomID = callMessage.roomId;//房间ID
    //zgCallOptions.callRoomToken = callMessage.token;//房间token令牌，群聊的需要在用户点击同意成功后，获取该用户的有效token
    //zgCallOptions.callTimeout = callMessage.timeout;//呼叫超时市场
    //zgCallOptions.callStatus = callMessage.status;//通话状态
    //zgCallOptions.callDuration = callMessage.duration;//通话时长
    zgCallOptions.callRoomUserID = UserManager.userInfo.userUID;//音视频房间推流的用户ID
    zgCallOptions.callRoomUserNickname = UserManager.userInfo.nickname;//音视频房间推流的用户昵称
    zgCallOptions.callRoomUserStreamID = UserManager.userInfo.userUID;//音视频房间推流的音视频流ID
    zgCallOptions.callMicState = LingIMCallMicrophoneMuteStateOff;//房间推流默认开启麦克风(本地 我的 推流设置)
    zgCallOptions.callSpeakerState = LingIMCallSpeakerMuteStateOff;//房间推流默认开启扬声器(本地 我的 推流设置) 群聊 默认开启扬声器
    zgCallOptions.callCameraState = LingIMCallCameraMuteStateOff;//房间推流默认开启摄像头(本地 我的 推流设置)
    zgCallOptions.callCameraDirection = LingIMCallCameraDirectionFront;//房间推流默认前置摄像头(本地 我的 推流设置)
    
    //2.本地维护的房间成员信息，放在用户点击同意成功后
    
    //3.邀请者信息
    NoaCallUserModel *inviterModel = [NoaCallUserModel new];
    inviterModel.userUid = chatMessageCall.from;//用户ID
    inviterModel.streamID = chatMessageCall.from;//音视频轨道流ID
    inviterModel.userShowName = chatMessageCall.nick;//用户昵称
    inviterModel.userAvatar = chatMessageCall.icon;//用户头像
    inviterModel.micState = LingIMCallMicrophoneMuteStateOff;//默认开启麦克风
    inviterModel.cameraDirection = LingIMCallCameraDirectionFront;//默认前置摄像头
    inviterModel.speakerState = LingIMCallSpeakerMuteStateOff;//默认开启扬声器
    inviterModel.cameraState = LingIMCallCameraMuteStateOff;//默认开启摄像头
    
    
    //3.业务层 配置 群聊 音视频通话 参数
    __block NoaCallOptions *callOptions = [NoaCallOptions new];
    callOptions.zgCallOptions = zgCallOptions;
    callOptions.groupID = chatMessageCall.to;
    callOptions.inviterUserModel = inviterModel;
    //callOptions.inviteeUserList;//发起群聊邀请时有效
    //callOptions.callMemberList;//本地维护的群聊成员列表
    
    NoaCallManager *callManager = [NoaCallManager sharedManager];
    callManager.currentCallOptions = callOptions;
    callManager.callState = ZCallStateBegin;//开始一个音视频通话的进程，等待被邀请者的处理
}

#pragma mark - 即构 群聊 房间成员变化处理
- (void)zgCallGroupMemberChangeWith:(IMChatMessage *)chatMessageCall {
    NoaCallOptions *currentCallOptions = [NoaCallManager sharedManager].currentCallOptions;
    NetCallMessage *netCallMessage = chatMessageCall.netCallMessage;
    //3:超时未应答，4:拒绝，5:挂断，6:接受，7:通话中断,8:其他设备已接听，9:邀请加入，10：主动加入
    switch (netCallMessage.status) {
        case 3://超时未接听
        case 4://拒绝
        case 5://挂断
        case 6://接受
        case 7://通话中断
        case 12://加入房间超时
        {
            //更新成员的状态
            __block NSMutableArray *callMemberListUpdate = [NSMutableArray array];
            [currentCallOptions.callMemberList enumerateObjectsUsingBlock:^(NoaCallUserModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
                
                [netCallMessage.operationUsersArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger objIdx, BOOL * _Nonnull objStop) {
                    
                    NSString *objStr = [NSString stringWithFormat:@"%@", obj];
                    
                    NSString *modelUserUid = [NSString stringWithFormat:@"%@", model.userUid];
                    
                    if ([objStr isEqualToString:modelUserUid]) {
                        //更新成员状态
                        if (netCallMessage.status == 3) {
                            model.callState = ZCallUserStateTimeOut;
                        }else if (netCallMessage.status == 4) {
                            model.callState = ZCallUserStateRefuse;
                        }else if (netCallMessage.status == 6) {
                            model.callState = ZCallUserStateAccept;
                            model.cameraState = LingIMCallCameraMuteStateOff;//默认开启摄像头
                        }else {//默认挂断
                            model.callState = ZCallUserStateHangup;
                        }
                        *objStop = YES;
                    }
                }];
                
                [callMemberListUpdate addObjectIfNotNil:model];
                
            }];
            
            //发送 群聊 成员状态变化的通知
            currentCallOptions.callMemberList = callMemberListUpdate;
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:chatMessageCall.to forKey:@"groupID"];
            [[NSNotificationCenter defaultCenter] postNotificationName:ZGCALLROOMGROUPMEMBERUPDATE object:nil userInfo:dict];
        }
            break;
        case 8://已在其他设备接听
        {
            //群聊 结束 的群ID
            NSString *discardGroupID = chatMessageCall.to;
            
            //判断我当前群聊音视频是不是已在其他设备接听
            NoaCallOptions *currentCallOptions = [NoaCallManager sharedManager].currentCallOptions;
            if ([currentCallOptions.groupID isEqualToString:discardGroupID]) {
                [self zgCallDiscard];
            }
            
        }
            break;
        case 9://邀请加入
        case 10://主动加入
        {
            __block NSMutableArray *newCallMemberIDList = [NSMutableArray array];
            [currentCallOptions.callMemberList enumerateObjectsUsingBlock:^(NoaCallUserModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [newCallMemberIDList addObjectIfNotNil:obj.userUid];
            }];
            
            __block NSMutableArray *newCallMemberList = [NSMutableArray arrayWithArray:currentCallOptions.callMemberList];
            
            [netCallMessage.operationUsersArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *objID = [NSString stringWithFormat:@"%@", obj];
                if (![newCallMemberIDList containsObject:objID]) {
                    //防止 我自己主动加入时，多创建一个用户
                    [newCallMemberIDList addObjectIfNotNil:objID];
                    
                    NoaCallUserModel *model = [NoaCallUserModel new];
                    model.userUid = objID;
                    model.streamID = objID;
                    model.cameraDirection = LingIMCallCameraDirectionFront;//默认前置摄像头
                    model.micState = LingIMCallMicrophoneMuteStateOff;//默认开启麦克风
                    model.speakerState = LingIMCallSpeakerMuteStateOff;//默认开启扬声器
                    if (netCallMessage.status == 9) {
                        model.callState = ZCallUserStateCalling;
                        model.cameraState = LingIMCallCameraMuteStateOn;//默认关闭摄像头，需要等待被邀请的用户操作
                    }else if (netCallMessage.status == 10) {
                        model.callState = ZCallUserStateAccept;
                        model.cameraState = LingIMCallCameraMuteStateOff;//默认开启摄像头
                    }
                    [newCallMemberList addObjectIfNotNil:model];
                }
                
            }];
            
            //更新本地维护的群聊成员列表
            currentCallOptions.callMemberList = newCallMemberList;
            
            //发送 群聊 成员状态变化的通知
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:chatMessageCall.to forKey:@"groupID"];
            [[NSNotificationCenter defaultCenter] postNotificationName:ZGCALLROOMGROUPMEMBERUPDATE object:nil userInfo:dict];
            
        }
            break;
            
        default:
            break;
    }
}
#pragma mark - 即构 我所在的其他群聊的音视频通话 成员变化处理(我当前没有参与该音视频通话)
- (void)zgCallOtherGroupChangeWith:(IMChatMessage *)chatMessageCall {
    
    NetCallMessage *netCallMessage = chatMessageCall.netCallMessage;
    //1:发起，3:超时未应答，4:拒绝，5:挂断，6:接受，7:通话中断,8:其他设备已接听，9:邀请加入，10：主动加入，11:结束
    NSString *callAction;
    switch (netCallMessage.status) {
        case 1://发起
        {
            callAction = @"callBegin";//发起了群聊音视频
            //音视频成员总个数相当于增加
        }
            break;
        case 11://结束
        {
            callAction = @"callEnd";//群聊音视频结束
        }
            break;
//        case 3://超时未接听 音视频成员离开
//        case 4://拒绝 音视频成员离开
//        case 5://挂断 音视频成员离开
//        case 7://通话中断 音视频成员离开
//        case 6://接受 不影响总的音视频成员个数
//        case 8://已在其他设备接听 不影响总的音视频成员个数
//        case 9://邀请加入 音视频成员总个数增加
//        case 10://主动加入 音视频成员总个数增加
//            break;
            
        default:
        {
            callAction = @"callMemberChange";
        }
            break;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:chatMessageCall.to forKey:@"groupID"];//通话群组ID
    [dict setValue:callAction forKey:@"callAction"];//通话行为 通话成员发生改变
    [dict setValue:@(netCallMessage.status) forKey:@"callMemberChangeState"];//成员列表变化类型
    [dict setValue:netCallMessage.roomUsersArray forKey:@"callMemberList"];//群聊：房间成员(已接听)
    [dict setValue:netCallMessage.operationUsersArray forKey:@"callOperationMemberList"];//本次通话行为 操作用户ID列表
    [[NSNotificationCenter defaultCenter] postNotificationName:ZGCALLROOMOTHERCHANGE object:nil userInfo:dict];
}
#pragma mark - 即构 音视频通话结束的本地处理
- (void)zgCallDiscard {
    //当前房间的通话已结束
    [NoaCallManager sharedManager].currentCallOptions = nil;
    [NoaCallManager sharedManager].callState = ZCallStateEnd;
    //离开房间
    [[NoaCallManager sharedManager] callRoomLogout];
    //销毁通话计时器
    [[NoaCallManager sharedManager] deallocCurrentCallDurationTimer];
    [[NoaCallManager sharedManager] deallocCallHeartBeatTimer];
    
    //通知UI更新
    [[NSNotificationCenter defaultCenter] postNotificationName:ZGCALLROOMEND object:nil];
    
    [IMSDKManager toolMessageReceiveRemindEndForMediaCall];
    
    //移除全局浮窗(如果有的话)
    [self removeWindowFloat];
}

- (void)dealloc {
    [IMSDKManager removeMediaCallDelegate:self];
}
@end
