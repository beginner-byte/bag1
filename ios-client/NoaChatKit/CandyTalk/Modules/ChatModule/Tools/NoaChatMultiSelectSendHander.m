//
//  NoaChatMultiSelectSendHander.m
//  NoaKit
//
//  Created by Candy on 2023/4/18.
//

#import "NoaChatMultiSelectSendHander.h"
#import "NoaMessageSendHander.h"
#import "NoaMessageTools.h"
#import "NoaFileUploadManager.h"
#import "NoaBaseUserModel.h"

@interface NoaChatMultiSelectSendHander()

@end

@implementation NoaChatMultiSelectSendHander

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - 多选对象-转发消息
- (void)chatMultiSelectSendForwardMessageList:(NSArray *)forwardMsgList imMessage:(IMChatMessageList *)imMessage {
    NSData *messageData = [imMessage data];
    
    WeakSelf
    [[NoaIMSDKManager sharedTool] transpondMessage:messageData onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        NSDictionary *dataDic = (NSDictionary *)data;
        [weakSelf insertForwardMessageToDataBaseWithDic:dataDic forwardMessageList:forwardMsgList imMessageList:imMessage];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        if (self.navBackActionBlock) {
            self.navBackActionBlock(NO, code, msg);
        }
    }];
}
//消息转发接口调用成功后向本地数据库插入对应的转发消息
- (void)insertForwardMessageToDataBaseWithDic:(NSDictionary *)dic forwardMessageList:(NSArray *)forwardMsgList imMessageList:(IMChatMessageList *)imMessageList {
    NSArray *failIdArray = dic[@"failId"];
    NSArray * sMsgIdTempArr = dic[@"sMsgId"];
    
    NSMutableArray *sendToCurrentChatMsgList = [NSMutableArray array];
    
    NSArray *toMessages = imMessageList.toMessageArray;
    for (int i = 0; i<toMessages.count; i++) {
        ToMessage *toRecever = [toMessages objectAtIndex:i];
        NSArray *sMsgIdArr = [sMsgIdTempArr objectAtIndex:i];
        for (int j = 0; j<forwardMsgList.count; j++) {
            
            NoaMessageModel *forwardMessage = (NoaMessageModel *)[forwardMsgList objectAtIndex:j];
            IMChatMessage *messageChat = [NoaMessageTools getIMChatMessageFromLingIMChatMessageModelToMergeForward:forwardMessage.message];
            messageChat.from = UserManager.userInfo.userUID;
            NoaIMChatMessageModel *forwardSendMessage = [[LingIMModelTool sharedTool] getChatMessageModelFromIMChatMessage:messageChat];
            
            if ([failIdArray containsObject:toRecever.to]) {
                //转发失败
                forwardSendMessage.messageSendType = CIMChatMessageSendTypeFail;
            } else {
                forwardSendMessage.messageSendType = CIMChatMessageSendTypeSuccess;
            }
            forwardSendMessage.referenceMsgId = @"";
            forwardSendMessage.chatType = toRecever.chatType;
            forwardSendMessage.msgID = [toRecever.msgIdArray objectAtIndex:j];
            forwardSendMessage.messageType = forwardMessage.message.messageType;
            forwardSendMessage.isAck = YES;
            forwardSendMessage.fromID = UserManager.userInfo.userUID;
            forwardSendMessage.fromNickname = UserManager.userInfo.nickname;
            forwardSendMessage.fromIcon = UserManager.userInfo.avatar;
            forwardSendMessage.toID = toRecever.to;
            forwardSendMessage.serviceMsgID = [sMsgIdArr objectAtIndex:j];
            forwardSendMessage.sendTime = [NSDate getCurrentServerMillisecondTime];//采用服务器校准时间
            forwardSendMessage.messageStatus = 1;
            forwardSendMessage.localImgName = nil;
            forwardSendMessage.localVideoName = nil;
            forwardSendMessage.localVoiceName = nil;
            forwardSendMessage.localVideoCover = nil;
            forwardSendMessage.localGeoImgName = nil;
            forwardSendMessage.translateStatus = CIMTranslateStatusNone;
            if (forwardMessage.isSelf) {
                if (forwardMessage.message.messageType == CIMChatMessageType_AtMessage) {
                    forwardSendMessage.textContent = [NoaMessageTools forwardMessageAtContenTranslateToShowContent:forwardMessage.message.atContent atUsersDictList:forwardMessage.message.atUsersInfoList];
                    forwardSendMessage.messageType = CIMChatMessageType_TextMessage;
                }
                if (forwardMessage.message.messageType == CIMChatMessageType_TextMessage) {
                    forwardSendMessage.textContent = forwardMessage.message.textContent;
                }
            } else{
                if (forwardMessage.message.messageType == CIMChatMessageType_AtMessage) {
                    forwardSendMessage.atTranslateContent = ![NSString isNil:forwardMessage.message.againAtTranslateContent] ? forwardMessage.message.againAtTranslateContent : forwardMessage.message.atTranslateContent;
                    forwardSendMessage.textContent = [NoaMessageTools forwardMessageAtContenTranslateToShowContent:![NSString isNil:forwardMessage.message.atTranslateContent] ? forwardMessage.message.atTranslateContent : forwardMessage.message.atContent atUsersDictList:forwardMessage.message.atUsersInfoList];
                    forwardSendMessage.messageType = CIMChatMessageType_TextMessage;
                }
                if (forwardMessage.message.messageType == CIMChatMessageType_TextMessage) {
                    forwardSendMessage.translateContent = ![NSString isNil:forwardMessage.message.againTranslateContent] ? forwardMessage.message.againTranslateContent : forwardMessage.message.translateContent;
                    forwardSendMessage.textContent = ![NSString isNil:forwardMessage.message.translateContent] ? forwardMessage.message.translateContent : forwardMessage.message.textContent;
                }
            }
            forwardMessage.message.translateContent = nil;
            forwardMessage.message.atTranslateContent = nil;
            
            if (toRecever.chatType == ChatType_SingleChat) {
                //单聊
                forwardSendMessage.haveReadCount = 0;
                forwardSendMessage.totalNeedReadCount = 1;
            } else {
                //群聊
                forwardSendMessage.haveReadCount = 0;
                //获取接收转发消息群的群成员信息
                NSArray * groupMemberArr = [IMSDKManager imSdkGetAllGroupMemberWith:toRecever.to];
                forwardSendMessage.totalNeedReadCount = (groupMemberArr.count - 1);
            }
            //往本地数据库存储toolInsertOrUpdateSessionWith
            [IMSDKManager toolInsertOrUpdateSessionWith:forwardSendMessage isRemind:YES];

            if ([toRecever.to isEqualToString:self.fromSessionId]) {
                [sendToCurrentChatMsgList addObject:forwardSendMessage];
            }
        }
    }
    
    if (self.forwardComleteBlock) {
        self.forwardComleteBlock(sendToCurrentChatMsgList);
    }
    
    if (self.navBackActionBlock) {
        self.navBackActionBlock(YES, 0, @"");
    }
}

#pragma mark - 多选对象-推荐名片给好友
- (void)chatMultiSelectRecommendFriendCard:(NSString *)friendUid receiverList:(NSArray *)receiverList {
    NSMutableArray *receiveUsers = [[NSMutableArray alloc] init];
    for (NoaBaseUserModel *receiverModel in receiverList) {
        NSMutableDictionary *singleRecevierDic = [NSMutableDictionary dictionary];
        [singleRecevierDic setObjectSafe:(receiverModel.isGroup ? @"GROUP_CHAT" : @"SINGLE_CHAT") forKey:@"chatType"];
        [singleRecevierDic setObjectSafe:receiverModel.userId forKey:@"friendIdOrGroupId"];
        [receiveUsers addObject:singleRecevierDic];
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:friendUid forKey:@"friendUserId"];
    [dict setObjectSafe:receiveUsers forKey:@"receiveUsers"];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    //请求接口
    WeakSelf
    [IMSDKManager MessageUserCardRecommend:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        NSDictionary *dataDic = (NSDictionary *)data;
        [weakSelf insertCardMessageToDataBaseWithDic:dataDic];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        if (self.navBackActionBlock) {
            self.navBackActionBlock(NO, code, msg);
        }
    }];
}
//推荐好友名片接口调用成功后向本地数据库插入对应的名片消息
- (void)insertCardMessageToDataBaseWithDic:(NSDictionary *)dic {
    NSArray *receiveUserMsgInfosArr = (NSArray *)dic[@"receiveUserMsgInfos"];
    
    for (NSDictionary *tempResultDic in receiveUserMsgInfosArr) {
        BOOL status = [[tempResultDic objectForKey:@"status"] boolValue];
        NSString *recevierChatType = (NSString *)[tempResultDic objectForKey:@"chatType"];
        NSString *userIdOrGroupId = (NSString *)[tempResultDic objectForKey:@"userIdOrGroupId"];
        NSString *smsgId = (NSString *)[tempResultDic objectForKey:@"smsgId"];
        NSString *msgId = (NSString *)[tempResultDic objectForKey:@"msgId"];
        //发送名片消息失败，本地需要组装失败的消息展示在UI上，成功的不用展示由socket发送
        if (status == NO) {
            NoaIMChatMessageModel *cardSendMessage = [NoaIMChatMessageModel new];
            cardSendMessage.messageSendType = CIMChatMessageSendTypeFail;
            cardSendMessage.referenceMsgId = @"";
            cardSendMessage.msgID = msgId;
            cardSendMessage.messageType = CIMChatMessageType_CardMessage;
            cardSendMessage.isAck = YES;
            cardSendMessage.fromID = UserManager.userInfo.userUID;
            cardSendMessage.fromNickname = UserManager.userInfo.nickname;
            cardSendMessage.fromIcon = UserManager.userInfo.avatar;
            cardSendMessage.toID = userIdOrGroupId;
            cardSendMessage.serviceMsgID = smsgId;
            cardSendMessage.sendTime = [NSDate getCurrentServerMillisecondTime];//采用服务器校准时间
            cardSendMessage.messageStatus = 1;
            if ([recevierChatType isEqualToString:@"SINGLE_CHAT"]) {
                //单聊
                cardSendMessage.chatType = CIMChatType_SingleChat;
                cardSendMessage.haveReadCount = 0;
                cardSendMessage.totalNeedReadCount = 1;
            } else {
                //群聊
                cardSendMessage.chatType = CIMChatType_GroupChat;
                cardSendMessage.haveReadCount = 0;
                //获取接收转发消息群的群成员信息
                NSArray * groupMemberArr = [IMSDKManager imSdkGetAllGroupMemberWith:userIdOrGroupId];
                cardSendMessage.totalNeedReadCount = (groupMemberArr.count - 1);
            }
            //往本地数据库存储toolInsertOrUpdateSessionWith
            [IMSDKManager toolInsertOrUpdateSessionWith:cardSendMessage isRemind:YES];
        }
    }
    if (self.navBackActionBlock) {
        self.navBackActionBlock(YES, 0, @"");
    }
}
#pragma mark - 多选对象-分享二维码图片(群二维码/个人二维码)，当成转发普通图片类型消息处理
- (void)chatMultiSelectShareQRcodeMessage:(UIImage *)qrImage selectObjectList:(NSArray *)selectObjectList {
    //先上传二维码图片
    WeakSelf
    [NoaMessageSendHander ZMessageAssembleQRcodeImage:qrImage compelete:^(NoaIMChatMessageModel * _Nonnull sendChatMsg) {
        NSMutableArray *taskArray = [NSMutableArray array];
        NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, @"qrcode_share"];
    
        NSString *imageName = sendChatMsg.localImgName;
        NSString *imagePath = [NSString getPathWithImageName:imageName CustomPath:customPath];
        NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
        
        NSString *thumbImageName =[NSString stringWithFormat:@"thumbnail_%@", imageName];
        NSString *thumbImagePath = [NSString getPathWithImageName:thumbImageName CustomPath:customPath];
        NSData *thumbImageData = [NSData dataWithContentsOfFile:thumbImagePath];
        
        //缩略图
        NoaFileUploadTask *thumbTask = [[NoaFileUploadTask alloc] initWithTaskId:[NSString stringWithFormat:@"thumbnail_%@", sendChatMsg.msgID] filePath:thumbImagePath originFilePath:imagePath fileName:thumbImageName fileType:@"" isEncrypt:YES dataLength:thumbImageData.length uploadType:ZHttpUploadTypeImageThumbnail beSendMessage:nil delegate:nil];
        thumbTask.messageTaskType = FileUploadMessageTaskTypeNoamlImgThumb;
        [taskArray addObject:thumbTask];
        
        //原图
        NoaFileUploadTask *task = [[NoaFileUploadTask alloc] initWithTaskId:sendChatMsg.msgID filePath:imagePath originFilePath:@"" fileName:imageName fileType:@"" isEncrypt:YES dataLength:imageData.length uploadType:ZHttpUploadTypeImage beSendMessage:nil delegate:nil];
        task.messageTaskType = FileUploadMessageTaskTypeNoamlImg;
        [taskArray addObject:task];
        
        __block NSInteger taskNum = 0;
        NSBlockOperation * blockOperation = [NSBlockOperation blockOperationWithBlock:^{
            //二维码图片上传任务完成
            for (NoaFileUploadTask *task in taskArray) {
                if (task.status == FileUploadTaskStatus_Completed) {
                    if (task.messageTaskType == FileUploadMessageTaskTypeNoamlImgThumb) {
                        sendChatMsg.thumbnailImg = task.originUrl;//缩略图地址
                        taskNum++;
                    }
                    if (task.messageTaskType == FileUploadMessageTaskTypeNoamlImg) {
                        sendChatMsg.imgName = task.originUrl;//原图地址
                        taskNum++;
                    }
                    if (taskNum == 2) {
                        //调用接口
                        [weakSelf assembleQRcodeMessageContentWithMessage:sendChatMsg selectObjectList:selectObjectList];
                    }
                } else {
                    [ZTOOL doInMain:^{
                        [HUD hideHUD];
                    }];
                }
            }
        }];
        NoaFileUploadGetSTSTask *getSTSTask = [[NoaFileUploadGetSTSTask alloc] init];
        getSTSTask.uploadTask = taskArray;
        [[NoaFileUploadManager sharedInstance].operationQueue addOperation:getSTSTask];

        for (NoaFileUploadTask *task in taskArray) {
            [blockOperation addDependency:task];
            [[NoaFileUploadManager sharedInstance] addUploadTask:task];
        }
        [[NoaFileUploadManager sharedInstance].operationQueue addOperation:blockOperation];
    }];
}

//组装消息体
- (void)assembleQRcodeMessageContentWithMessage:(NoaIMChatMessageModel *)qrMsg selectObjectList:(NSArray *)selectObjectList {
    //组装分享二维码消息接口需要的数据格式(转发图片消息)
    IMChatMessageList *chatMessageList = [[IMChatMessageList alloc] init];
    chatMessageList.source = @"iOS";
    
    NSMutableArray *imMessages = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *toMessages = [NSMutableArray arrayWithCapacity:1];
    
    IMMessage *messageModel = [NoaMessageTools getIMMessageFromLingIMChatMessageModel:qrMsg withChatObject:selectObjectList.firstObject index:0];
    IMChatMessage *chatMessage = messageModel.chatMessage;
    chatMessage.deviceType = @"IOS";
    chatMessage.deviceUuid = [FCUUID uuidForDevice];
    [imMessages addObject:chatMessage];
    
    for (NoaBaseUserModel *receiver in selectObjectList) {
        NSMutableArray *msgIds = [[NSMutableArray alloc] init];
        NSString *msgIdStr = [NoaMessageTools getMessageID];
        [msgIds addObject:msgIdStr];
        [msgIds addObject:@""];
        
        ToMessage *toMessage = [[ToMessage alloc] init];
        toMessage.msgIdArray = msgIds;
        toMessage.to = receiver.userId;
        toMessage.chatType = (receiver.isGroup ? ChatType_GroupChat : ChatType_SingleChat);
        [toMessages addObject:toMessage];
    }
    
    chatMessageList.iMchatMessageArray = imMessages;
    chatMessageList.toMessageArray = toMessages;
    
    NSData *messageData = [chatMessageList data];
    WeakSelf
    [[NoaIMSDKManager sharedTool] transpondMessage:messageData onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        NSDictionary *dataDic = (NSDictionary *)data;
        [weakSelf insertShareQrcodeMessageToLocalDatabaseDic:dataDic qrCodeMessage:qrMsg imMessageList:chatMessageList];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        if (self.navBackActionBlock) {
            self.navBackActionBlock(NO, code, msg);
        }
    }];
}

- (void)insertShareQrcodeMessageToLocalDatabaseDic:(NSDictionary *)dic qrCodeMessage:(NoaIMChatMessageModel *)qrCodeMessage imMessageList:(IMChatMessageList *)imMessageList {
    NSArray *failIdArray = dic[@"failId"];
    NSArray * sMsgIdTempArr = dic[@"sMsgId"];
    
    NSArray *toMessages = imMessageList.toMessageArray;
    for (int i = 0; i<toMessages.count; i++) {
        ToMessage *toRecever = [toMessages objectAtIndex:i];
        NSArray *sMsgIdArr = [sMsgIdTempArr objectAtIndex:i];
        NoaIMChatMessageModel *qrcodeSendMessage = [NoaIMChatMessageModel new];
        qrcodeSendMessage = qrCodeMessage;
        if ([failIdArray containsObject:toRecever.to]) {//转发失败
            qrcodeSendMessage.messageSendType = CIMChatMessageSendTypeFail;
        } else {
            qrcodeSendMessage.messageSendType = CIMChatMessageSendTypeSuccess;
        }
        qrcodeSendMessage.referenceMsgId = @"";
        qrcodeSendMessage.chatType = toRecever.chatType;
        qrcodeSendMessage.msgID = toRecever.msgIdArray.firstObject;
        qrcodeSendMessage.messageType = qrCodeMessage.messageType;
        qrcodeSendMessage.isAck = YES;
        qrcodeSendMessage.fromID = UserManager.userInfo.userUID;
        qrcodeSendMessage.fromNickname = UserManager.userInfo.nickname;
        qrcodeSendMessage.fromIcon = UserManager.userInfo.avatar;
        qrcodeSendMessage.toID = toRecever.to;
        qrcodeSendMessage.serviceMsgID = [sMsgIdArr firstObject];
        qrcodeSendMessage.sendTime = [NSDate getCurrentServerMillisecondTime];//采用服务器校准时间
        qrcodeSendMessage.messageStatus = 1;
        qrcodeSendMessage.localGeoImgName = nil;
        qrcodeSendMessage.localImgName = nil;
        if (toRecever.chatType == ChatType_SingleChat) {
            //单聊
            qrcodeSendMessage.haveReadCount = 0;
            qrcodeSendMessage.totalNeedReadCount = 1;
        } else {
            //群聊
            qrcodeSendMessage.haveReadCount = 0;
            //获取接收转发消息群的群成员信息
            NSArray * groupMemberArr = [IMSDKManager imSdkGetAllGroupMemberWith:toRecever.to];
            qrcodeSendMessage.totalNeedReadCount = (groupMemberArr.count - 1);
        }
        
        //往本地数据库存储toolInsertOrUpdateSessionWith
        [IMSDKManager toolInsertOrUpdateSessionWith:qrcodeSendMessage isRemind:YES];
        
        if ([toRecever.to isEqualToString:self.fromSessionId]) {
            if (self.shareQRcodeComleteBlock) {
                self.shareQRcodeComleteBlock(qrcodeSendMessage);
            }
        }
    }
    if (self.navBackActionBlock) {
        self.navBackActionBlock(YES, 0, @"");
    }
}

#pragma mark - 单条收藏消息发送给会话(走单条消息转发单个会话逻辑)
- (void)chatCollectionMessagSendWith:(NoaMyCollectionItemModel *)collectionMsg chatType:(CIMChatType)chatType sessionId:(NSString *)sessionId {
    
    if ([collectionMsg.fromUid isEqualToString:UserManager.userInfo.userUID]) {
        if (collectionMsg.mtype == CIMChatMessageType_TextMessage) {
            collectionMsg.body.content = collectionMsg.body.content;
        }
    } else{
        if (collectionMsg.mtype == CIMChatMessageType_TextMessage) {
            collectionMsg.body.content = ![NSString isNil:collectionMsg.body.translate] ? collectionMsg.body.translate : collectionMsg.body.content;
        }
    }
    collectionMsg.body.translate = @"";
    
    IMMessage *sendImMessage = [NoaMessageTools getIMMessageFromCollection:collectionMsg withChatType:chatType chatSessionId:sessionId];

    IMChatMessageList *chatMessageList = [[IMChatMessageList alloc] init];
    chatMessageList.source = @"iOS";
    
    NSMutableArray *imMessages = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *toMessages = [NSMutableArray arrayWithCapacity:1];
    
    //消息内容
    IMChatMessage *chatMessage = sendImMessage.chatMessage;
    chatMessage.deviceType = @"IOS";
    chatMessage.deviceUuid = [FCUUID uuidForDevice];
    [imMessages addObject:chatMessage];
    //消息接受者
    NSMutableArray *msgIds = [[NSMutableArray alloc] init];
    NSString *msgIdStr = [NoaMessageTools getMessageID];
    [msgIds addObject:msgIdStr];
    [msgIds addObject:@""];
    ToMessage *toMessage = [[ToMessage alloc] init];
    toMessage.msgIdArray = msgIds;
    toMessage.to = sessionId;
    toMessage.chatType = (chatType == CIMChatType_SingleChat ? ChatType_SingleChat : ChatType_GroupChat);
    [toMessages addObject:toMessage];
    
    chatMessageList.iMchatMessageArray = imMessages;
    chatMessageList.toMessageArray = toMessages;
    
    NSData *messageData = [chatMessageList data];
    WeakSelf
    [[NoaIMSDKManager sharedTool] transpondMessage:messageData onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        NSDictionary *dataDic = (NSDictionary *)data;
        [weakSelf insertCollectionMessageToDataBaseWithDic:dataDic imMessage:sendImMessage imMessageList:chatMessageList];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}
//收藏消息转发接口调用成功后向本地数据库插入对应的转发消息
- (void)insertCollectionMessageToDataBaseWithDic:(NSDictionary *)dic imMessage:(IMMessage *)imMessage imMessageList:(IMChatMessageList *)imMessageList {
    NSArray *failIdArray = dic[@"failId"];
    NSArray * sMsgIdTempArr = dic[@"sMsgId"];
    
    NSArray *toMessages = imMessageList.toMessageArray;
    for (int i = 0; i<toMessages.count; i++) {
        ToMessage *toRecever = [toMessages objectAtIndex:i];
        NSArray *sMsgIdArr = [sMsgIdTempArr objectAtIndex:i];

        IMChatMessage *messageChat = imMessage.chatMessage;
        NoaIMChatMessageModel *chatModel = [[LingIMModelTool sharedTool] getChatMessageModelFromIMChatMessage:messageChat];
        if ([failIdArray containsObject:toRecever.to]) {//转发失败
            chatModel.messageSendType = CIMChatMessageSendTypeFail;
        } else {
            chatModel.messageSendType = CIMChatMessageSendTypeSuccess;
        }
        chatModel.msgID = toRecever.msgIdArray.firstObject;
        chatModel.fromID = UserManager.userInfo.userUID;
        chatModel.fromNickname = UserManager.userInfo.nickname;
        chatModel.fromIcon = UserManager.userInfo.avatar;
        chatModel.toID = toRecever.to;
        chatModel.serviceMsgID = [sMsgIdArr firstObject];
        chatModel.sendTime = [NSDate getCurrentServerMillisecondTime];
        chatModel.messageStatus = 1;
        chatModel.localImgName = nil;
        chatModel.localVideoName = nil;
        chatModel.localVoiceName = nil;
        chatModel.localVideoCover = nil;
        chatModel.localGeoImgName = nil;
        if (toRecever.chatType == ChatType_SingleChat) {
            //单聊
            chatModel.haveReadCount = 0;
            chatModel.totalNeedReadCount = 1;
        } else {
            //群聊
            chatModel.haveReadCount = 0;
            //获取接收转发消息群的群成员信息
            NSArray * groupMemberArr = [IMSDKManager imSdkGetAllGroupMemberWith:toRecever.to];
            chatModel.totalNeedReadCount = (groupMemberArr.count - 1);
        }
        //往本地数据库存储toolInsertOrUpdateSessionWith
        [IMSDKManager toolInsertOrUpdateSessionWith:chatModel isRemind:YES];
        if (self.collectionSendCompleteBlock) {
            self.collectionSendCompleteBlock(YES, chatModel);
        }
    }
}

@end
