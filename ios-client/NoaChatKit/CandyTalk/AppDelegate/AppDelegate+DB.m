//
//  AppDelegate+DB.m
//  NoaKit
//
//  Created by Candy on 2026/10/26.
//

#import "AppDelegate+DB.h"
#import "AppDelegate+Push.h"
#import "NoaToolManager.h"
#import "NoaSensitiveManager.h" //敏感词过滤
#import "NoaFriendReqModel.h"
//#import "NoaCharacterBindViewController.h"
//#import "ZSessionModel.h"
//#import "ZServceMessageModel.h"
//#import "ZMessageRecordModel.h"
#import "NoaMessageTools.h"
#import "NoaChatKit-Swift.h"


@interface AppDelegate ()

@end

@implementation AppDelegate (DB)
#pragma mark - 配置SDK
- (void)configDB {
    
    if (!UserManager.isLogined) return;
    
    [IMSDKManager addConnectDelegate:self];//连接代理
    [IMSDKManager addUserDelegate:self];//用户代理
    [IMSDKManager addMessageDelegate:self];//消息代理
    [IMSDKManager addSessionDelegate:self];//会话代理
    
    //红点展示
    if ([self.window.rootViewController isKindOfClass:[CandyTabBarController class]]) {
        
        CandyTabBarController *tab = (CandyTabBarController *)self.window.rootViewController;
        //通讯录红点先取本地展示
        NSInteger friendInviteCount = [IMSDKManager toolFriendApplyCount];
        [tab setBadgeValue:2 number:friendInviteCount];
        //会话列表红点先取本地展示
        WeakSelf
        __block NSInteger sessionUnreadCount;
        [ZTOOL doAsync:^{
            sessionUnreadCount = [IMSDKManager toolGetAllSessionUnreadCount];
        } completion:^{
            [tab setBadgeValue:1 number:sessionUnreadCount];
            [weakSelf configAppUnreadBadgeWitMessageCount:sessionUnreadCount friendInviteCount:friendInviteCount];
        }];
    }
    
    [self upDeviceToken];
    //接口统一处理
    [self requestDataGroup];
}

- (void)configAppUnreadBadgeWitMessageCount:(NSInteger)messageCount friendInviteCount:(NSInteger)inviteCount {
    NSInteger totalUnReadCount = messageCount + inviteCount;
    //设置App的Badge数量
    [UIApplication sharedApplication].applicationIconBadgeNumber = totalUnReadCount;
}

#pragma mark - 上报设备
-(void)upDeviceToken{
    NSString *token = [[MMKV defaultMMKV] getStringForKey:L_DevicePushToken];
    if (token.length < 5) {
        return;
    }
    NoaUserModel *userModel = [NoaUserModel getUserInfo];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObjectSafe:[NSNumber numberWithInteger:1] forKey:@"osType"];
    [params setObjectSafe:@"apns" forKey:@"pushServer"];
    [params setObjectSafe:token?token:@"1" forKey:@"pushToken"];
    [params setObjectSafe:userModel.userUID forKey:@"userUid"];
    
    [IMSDKManager imSdkUpDeviceTokenWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        DLog(@"上报设备成功>>>>>%@",data);
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        DLog(@"上报设备失败>>>>>code===%ld===msg===%@",(long)code,msg);
    }];
}
#pragma mark - 接口统一处理
- (void)requestDataGroup {
    
    //更新服务端的好友请求数据
    [self updateFriendApplyCountFromService];

}
#pragma mark - CIMToolConnectDelegate
- (void)cimToolConnecting {
    //socket正在连接中...
    NSDictionary *dict = @{@"connectType" : @(0)};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IMConnectStateChange" object:nil userInfo:dict];
}
- (void)cimToolConnectSuccess {
    //socket连接成功
    NSDictionary *dict = @{@"connectType" : @(1)};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IMConnectStateChange" object:nil userInfo:dict];
}
//重连成功
- (void)cimToolReConnectSuccess {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IMConnectReConnect" object:nil userInfo:nil];
}
- (void)cimToolConnectFailWith:(NSError *)error {
    //socket连接失败
    NSDictionary *dict = @{@"connectType" : @(2)};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IMConnectStateChange" object:nil userInfo:dict];
}
- (void)cimToolDisconnect {
    //socket断开连接，需要单独进行socket竞速
    /**
     * TODO: 注释原因:socket连接断开后，会自动重连，禁止触发竞速逻辑
     [ZHostTool tcpNodePickOver];
     */
}


#pragma mark - CIMToolUserDelegate
- (void)cimToolUserFriendInvite:(FriendInviteMessage *)message {
    [self receivePushInviteWithEnterBackground:message];
    NSInteger friendApplyCount = [IMSDKManager toolFriendApplyCount];
    NoaFriendReqModel *model = [NoaFriendReqModel new];
    model.hashKey = message.hashKey;
    NSMutableArray *list = [[MMKV defaultMMKV] getObjectOfClass:[NSMutableArray class] forKey:[NSString stringWithFormat:@"%@_%@",FriendSyncReqList, UserManager.userInfo.userUID]];
    BOOL isHas = NO;
    for (int i = 0; i < list.count; i++) {
        NoaFriendReqModel *req = (NoaFriendReqModel *)list[i];
        if ([req.hashKey isEqualToString:message.hashKey]) {
            isHas = YES;
        }
    }
    if (!isHas) {
        [list addObject:model];
    }
    [[MMKV defaultMMKV] setObject:list forKey:[NSString stringWithFormat:@"%@_%@",FriendSyncReqList, UserManager.userInfo.userUID]];
    friendApplyCount = list.count;
    [IMSDKManager toolUpdateFriendApplyCount:friendApplyCount];
    //更新通讯录红点
    if ([self.window.rootViewController isKindOfClass:[CandyTabBarController class]]) {
        CandyTabBarController *tab = (CandyTabBarController *)self.window.rootViewController;
        [tab setBadgeValue:2 number:friendApplyCount];
        //通讯录好友申请，红点更新
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FriendApplyCountChange" object:nil];
    }
}

//好友申请消息数量发生变化
- (void)cimToolUserFriendInviteTotalUnreadCount:(NSInteger)inviteUnReadCount {
    //会话列表红点先取本地展示
    NSInteger sessionUnreadCount = [IMSDKManager toolGetAllSessionUnreadCount];
    [self configAppUnreadBadgeWitMessageCount:sessionUnreadCount friendInviteCount:inviteUnReadCount];
}

- (void)cimToolUserFriendConfirm:(IMServerMessage *)message {
    //用户同意/拒绝你发起的好友申请
    FriendConfirmMessage *friendConfirm = message.friendConfirmMessage;
    if (friendConfirm.status == 1) {
        //同意好友申请(暂时无这个推送提示)
        //[self receivePushAgreenWithEnterBackground:friendConfirm];
    }
}

- (void)cimToolUserFriendLineStatus:(IMServerMessage *)message {
    FriendLineStatus *onlineModel = message.friendLineStatus;
    NSMutableDictionary *userInfoDict = [NSMutableDictionary dictionary];
    [userInfoDict setValue:onlineModel.friendId forKey:@"friendID"];//好友ID
    [userInfoDict setValue:@(onlineModel.status) forKey:@"friendStatus"];//好友状态
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MyFriendOnlineStatusChange" object:nil userInfo:userInfoDict];
}

//账号被强制下线
- (void)imSdkUserForceLogout:(NSInteger)type message:(NSString *)message {
    //10:IP被封禁, 11:设备被封禁, 2:账号被封禁(账号被锁定)
    if (type == 10 || type == 11 || type == 2) {
        // 需要先跳转到登录页面，然后弹窗---避免先弹窗，然后跳转登录页面后，主动断开连接导致数据丢失
        [ZTOOL setupLoginUI];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (type == 10) {
                //IP被锁定
                [ZTOOL setupAlertUserBannedUIWithErrorCode:Auth_User_IPAddress_Banned withContent:message loginType:0];
            }
            if (type == 11) {
                //设备被封禁
                [ZTOOL setupAlertUserBannedUIWithErrorCode:Auth_User_Device_Banned withContent:message loginType:0];
            }
            if (type == 2) {
                //账号被封禁(账号被锁定)
                [ZTOOL setupAlertUserBannedUIWithErrorCode:Auth_User_Account_Banned withContent:message loginType:0];
            }
        });
        return;
    }
    //13:账号信息发生变化，请重新登录
    if (type == 13) {
        [ZTOOL setupUserInfoChangeAlert];
        return;
    }
    if (type == 888) {
        [HUD showMessage:LanguageToolMatch(@"用户已经注销")];
    }
    if (type == 90018) {
        //登录不在白名单内，需展示IP地址
        [HUD showMessage:[NSString stringWithFormat:LanguageToolMatch(@"登录IP：%@ 不在白名单内"), message]];
    }
    NoaUserModel *userModel = [NoaUserModel getUserInfo];
    if (userModel == nil || userModel.userUID.length <= 0) {
        return;
    }
    //账号被强制退出登录
    [ZTOOL setupLoginUI];
}

// 用户token失效，触发刷新token接口获取最新token并更新给KIT层
- (void)imSdkRefreshUsetToken:(NSString *)userToken errorMsg:(nonnull NSString *)msg {
    if (![NSString isNil:userToken]) {
        NoaUserModel *refreshUserModel = UserManager.userInfo;
        refreshUserModel.token = userToken;
        [refreshUserModel saveUserInfo];
        [UserManager setUserInfo:refreshUserModel];
    } else {
        if(msg){
            [HUD showMessage:LanguageToolMatch(msg)];
        }
        //退出账号之前调用一下 删除设备推送信息接口，对接口返回不做任何处理
        NoaUserModel *userModel = [NoaUserModel getUserInfo];
        if (userModel == nil || userModel.userUID.length <= 0) {
            return;
        }
        [ZTOOL setupLoginUI];
    }
}

/// 账号封禁、设备封禁、IP封禁
- (void)imSdkRefreshTokenAuthBanned:(NSInteger)errorCode {
    [ZTOOL setupAlertUserBannedUIWithErrorCode:errorCode withContent:@"" loginType:0];
}

//通讯录同步完成
- (void)imSdkUserContactsSyncFinish {
    //更新通讯录文件助手本地化语言配置
    [ZTOOL connectFileHelperLanguageUpdate];
}

- (void)cimUserUpdateHttpNode:(NSString *)httpNode {
    //Kit层
    ZHostTool.apiHost = httpNode;
    ZHostTool.getFileHost = httpNode;
    ZHostTool.uploadfileHost = [NSString stringWithFormat:@"%@/oss", httpNode];
}

/// 更新httpNode时，无可用node时提示语展示
- (void)cimUserUnableHttpNode:(NSString *)tipsContent {
    [HUD showMessage:LanguageToolMatch(tipsContent)];
}

#pragma mark - CIMToolMessageDelegate
/// 接收到聊天消息
/// @param message 聊天消息model
- (void)cimToolChatMessageReceive:(NoaIMChatMessageModel *)message{
    
    //判断是否为移除群成员信息
    if (message.serverMessage.sMsgType == IMServerMessage_ServerMsgType_KickGroupMessage) {
        //判断移除的群成员是否为自己
        if ([message.serverMessage.kickGroupMessage.uid isEqualToString:UserManager.userInfo.userUID]) {
            [self deleteSessionAndChatMessage:message];
        } else {
            if (message.serverMessage.kickGroupMessage.msgDel) {
                //移除群成员时选择了同时移除该成员在本群发出的所有消息
                [IMSDKManager toolDeleteGroupMemberAllSendMessageWith:message.serverMessage.kickGroupMessage.uid groupID:message.serverMessage.kickGroupMessage.gid];
            }
        }
    }
    
    //判断是否为解散群组
    if (message.serverMessage.sMsgType == IMServerMessage_ServerMsgType_DelGroupMessage) {
        // Worker only deletes a bound task when the authenticated user is its creator;
        // ordinary CandyTalk groups and other members' callbacks are idempotent no-ops.
        [[CoHereWorkModuleManager shared] notifyTaskGroupDissolvedWithGroupID:message.serverMessage.delGroupMessage.gid];
        [self deleteSessionAndChatMessage:message];
    }
    
    //退出群聊
    if (message.serverMessage.sMsgType == IMServerMessage_ServerMsgType_OutGroupMessage) {
        OutGroupMessage *outGroup = message.serverMessage.outGroupMessage;
        if ([outGroup.uid isEqualToString:UserManager.userInfo.userUID]) {
            //我退出了群聊
            [self deleteSessionAndChatMessage:message];
        }
    }
    
    [self receivePushMessageWithEnterBackground:message];
}

//删除会话 + 清空聊天内容 + 删除群组
- (void)deleteSessionAndChatMessage:(NoaIMChatMessageModel *)messageModel {
    LingIMSessionModel *model = [IMSDKManager toolCheckMySessionWith:messageModel.toID];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:model.sessionID forKey:@"peerUid"];
    if (![NSString isNil:UserManager.userInfo.userUID]) {
        [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    }
    if (model.sessionType == CIMSessionTypeSingle) {
        //单聊
        [dict setValue:@(0) forKey:@"dialogType"];
    }else {
        //群聊
        [dict setValue:@(1) forKey:@"dialogType"];
    }
    [[NoaIMSDKManager sharedTool] deleteServerConversation:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [IMSDKManager toolDeleteSessionModelWith:model andDeleteAllChatModel:YES];
        //清除缓存
        [NoaMessageTools clearChatLocalImgAndVideoFromSessionId:model.sessionID];
        [IMSDKManager toolDeleteMyGroupWith:model.sessionID];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showErrorMessage:msg];
    }];
}

- (void)imSdkChatMessageSensitiveSyncFinish {
    //重新加载本地敏感词词库
    [ZTOOL doInBackground:^{
        [ZSensitiveTOOL setupLocalSensitiveFilter];
    }];
}

#pragma mark - CIMToolSessionDelegate
//会话列表消息总数量发生变化
- (void)cimToolSessionTotalUnreadCountChange:(NSInteger)totalUnreadCount {
    //通讯录红点先取本地展示
    NSInteger friendInviteCount = [IMSDKManager toolFriendApplyCount];
    if ([self.window.rootViewController isKindOfClass:[CandyTabBarController class]]) {
        CandyTabBarController *tab = (CandyTabBarController *)self.window.rootViewController;
        [tab setBadgeValue:1 number:totalUnreadCount];
        [tab setBadgeValue:2 number:friendInviteCount];
    }
    
    [self configAppUnreadBadgeWitMessageCount:totalUnreadCount friendInviteCount:friendInviteCount];
}
//会话列表同步完成
- (void)imSdkSessionSyncFinish {
    //更新会话列表文件助手
    [ZTOOL sessionFileHelperLanguageUpdate];
}
//会话列表新增
- (void)cimToolSessionReceiveWith:(LingIMSessionModel *)model {
    if ([model.sessionID isEqualToString:@"100002"]) {
        //更新会话列表文件助手
        [ZTOOL sessionFileHelperLanguageUpdate];        
    }
    if ([model.sessionID isEqualToString:@"100003"]) {
        //更新会话列表签到提醒
        [ZTOOL sessionSignInRemainderLanguageUpdate];
    }
}

#pragma mark - CIMToolUserDelegate
- (void)imSdkUserCloseAutoTranslateAndErrorCode:(NSInteger)errorCode errorMsg:(NSString *)errorMsg sessionModel:(LingIMSessionModel *)sessionModel {
    if (errorCode == Translate_yuuee_no_balance_code) {
        //字符不足时应将设置字段翻译关闭并同步到服务端
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObjectSafe:![NSString isNil:sessionModel.sendTranslateChannel] ? sessionModel.sendTranslateChannel : @"" forKey:@"channel"];
        [dict setObjectSafe:![NSString isNil:sessionModel.sendTranslateChannelName] ? sessionModel.sendTranslateChannelName : @"" forKey:@"channelName"];
        [dict setObjectSafe:sessionModel.sessionID forKey:@"dialogId"];
        [dict setObjectSafe:sessionModel.translateConfigId forKey:@"id"];
        [dict setObjectSafe:@(1) forKey:@"level"];      //级别：0：用户全局配置；1:会话级别
        [dict setObjectSafe:![NSString isNil:sessionModel.sendTranslateLanguage] ? sessionModel.sendTranslateLanguage : @"" forKey:@"targetLang"];
        [dict setObjectSafe:![NSString isNil:sessionModel.sendTranslateLanguageName] ? sessionModel.sendTranslateLanguageName : @"" forKey:@"targetLangName"];
        [dict setObjectSafe:@(sessionModel.isSendAutoTranslate) forKey:@"translateSwitch"];
        [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
        [dict setObjectSafe:![NSString isNil:sessionModel.receiveTranslateChannel] ? sessionModel.receiveTranslateChannel : @"" forKey:@"receiveChannel"];
        [dict setObjectSafe:![NSString isNil:sessionModel.receiveTranslateChannelName] ? sessionModel.receiveTranslateChannelName : @"" forKey:@"receiveChannelName"];
        [dict setObjectSafe:![NSString isNil:sessionModel.receiveTranslateLanguage] ? sessionModel.receiveTranslateLanguage : @"" forKey:@"receiveTargetLang"];
        [dict setObjectSafe:![NSString isNil:sessionModel.receiveTranslateLanguageName] ? sessionModel.receiveTranslateLanguageName : @"" forKey:@"receiveTargetLangName"];
        [dict setObjectSafe:@(sessionModel.isReceiveAutoTranslate) forKey:@"receiveTranslateSwitch"];
        [IMSDKManager imSdkTranslateUploadNewTranslateConfig:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            
        }];

        //提示
        [HUD showMessage:LanguageToolMatch(@"当前账户字符数不足，已关闭翻译功能，请增加字符后使用。")];
    } else if (errorCode == Translate_yuuee_unbind_error_code) {
        [HUD showMessage:LanguageToolMatch(@"您尚未绑定字符账号，无法使用翻译功能，请绑定后使用。")];
    } else {
        [HUD showMessageWithCode:errorCode errorMsg:errorMsg];
    }
}

/// 其他登录端更新了翻译配置信息
- (void)imsdkUserUpdateTranslateConfigInfo:(UserTranslateConfigUploadMessage *)translateConfig {
    if (![translateConfig.dialogId isEqualToString:@"0"]) {
        //某个会话翻译配置信息修改
        LingIMSessionModel *sessionModel = [IMSDKManager toolCheckMySessionWith:translateConfig.dialogId];
        if (sessionModel) {
            sessionModel.isSendAutoTranslate = translateConfig.translateSwitch;
            sessionModel.sendTranslateChannel = translateConfig.channel;
            sessionModel.sendTranslateChannelName = translateConfig.channelName;
            sessionModel.sendTranslateLanguage = translateConfig.targetLang;
            sessionModel.sendTranslateLanguageName = translateConfig.targetLangName;
            sessionModel.isReceiveAutoTranslate = translateConfig.receiveTranslateSwitch;
            sessionModel.receiveTranslateChannel = translateConfig.receiveChannel;
            sessionModel.receiveTranslateChannelName = translateConfig.receiveChannelName;
            sessionModel.receiveTranslateLanguage = translateConfig.receiveTargetLang;
            sessionModel.receiveTranslateLanguageName = translateConfig.receiveTargetLangName;
            sessionModel.translateConfigId = [NSString stringWithFormat:@"%lld", translateConfig.id_p];
            //更新到本地
            [DBTOOL insertOrUpdateSessionModelWith:sessionModel];
        }
    }
}

#pragma mark - 服务端，更新好友申请信息
- (void)updateFriendApplyCountFromService {
    
    //删除隐藏的好友申请
    NSString *hashKeyStr = [[MMKV defaultMMKV] getStringForKey:@"HiddenFriendApply"];
    NSArray *hiddenArr = [hashKeyStr componentsSeparatedByString:@","];
    
    //已读红点好友申请
    NSString *hashKeyReadStr = [[MMKV defaultMMKV] getStringForKey:@"ReadFriendApply"];
    NSArray *readArr = [hashKeyReadStr componentsSeparatedByString:@","];
    
    NSString *lastSyncTime = [[MMKV defaultMMKV] getStringForKey:[NSString stringWithFormat:@"%@_%@",FriendSyncReqTime, UserManager.userInfo.userUID]];
    
    WeakSelf
    __block NSInteger friendApplyCount = 0;
    if ([NSString isNil:lastSyncTime]) {
        friendApplyCount = [IMSDKManager toolFriendApplyCount];
        
    }
    
    __block NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:lastSyncTime forKey:@"lastSyncTime"];
    [param setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    
    [IMSDKManager getFriendSyncReqListWith:param onSuccess:^(id  _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *reqDict = (NSDictionary *)data;
            NSMutableArray *reqArr = [reqDict objectForKeySafe:@"records"];
            NSMutableArray<NoaFriendReqModel *> *reqList = [NSMutableArray array];
            [reqArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NoaFriendReqModel *model = [NoaFriendReqModel mj_objectWithKeyValues:obj];
                [reqList addObject:model];
            }];
            
            if ([NSString isNil:lastSyncTime]) {
                [[MMKV defaultMMKV] setObject:reqList forKey:[NSString stringWithFormat:@"%@_%@",FriendSyncReqList, UserManager.userInfo.userUID]];
                friendApplyCount = reqList.count;
            } else {
                NSMutableArray *list = [[MMKV defaultMMKV] getObjectOfClass:[NSMutableArray class] forKey:[NSString stringWithFormat:@"%@_%@",FriendSyncReqList, UserManager.userInfo.userUID]];
                for (int i = 0; i < reqList.count; i++) {
                    BOOL isHas = NO;
                    for (int j = 0; j < list.count; j++) {
                        NoaFriendReqModel *model = (NoaFriendReqModel *)list[j];
                        NoaFriendReqModel *reqModel = (NoaFriendReqModel *)reqList[i];
                        if ([model.hashKey isEqualToString:reqModel.hashKey]) {
                            isHas = YES;
                        }
                    }
                    if (!isHas) {
                        [list addObject:reqList[i]];
                    }
                    
                }
                [[MMKV defaultMMKV] setObject:list forKey:[NSString stringWithFormat:@"%@_%@",FriendSyncReqList, UserManager.userInfo.userUID]];
                friendApplyCount = friendApplyCount + reqList.count;
            }
            [[MMKV defaultMMKV] setString:reqList.firstObject.latestUpdateTime forKey:[NSString stringWithFormat:@"%@_%@",FriendSyncReqTime, UserManager.userInfo.userUID]];
            //先存储一下每页的红点数
            [IMSDKManager toolUpdateFriendApplyCount:friendApplyCount];
            //更新通讯录红点
            if ([weakSelf.window.rootViewController isKindOfClass:[CandyTabBarController class]]) {
                CandyTabBarController *tab = (CandyTabBarController *)weakSelf.window.rootViewController;
                [tab setBadgeValue:2 number:friendApplyCount];
                //通讯录好友申请，红点更新
                [[NSNotificationCenter defaultCenter] postNotificationName:@"FriendApplyCountChange" object:nil];
            }
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        
    }];
}

- (void)dealloc {
    [IMSDKManager removeUserDelegate:self];
    [IMSDKManager removeMessageDelegate:self];
    [IMSDKManager removeConnectDelegate:self];
    [IMSDKManager removeSessionDelegate:self];
}
@end
