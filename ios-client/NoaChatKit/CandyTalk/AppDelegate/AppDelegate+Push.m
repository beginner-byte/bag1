//
//  AppDelegate+Push.m
//  NoaKit
//
//  Created by Apple on 2023/1/14.
//

#import "AppDelegate+Push.h"

@implementation AppDelegate(Push)

- (void)receivePushMessageWithEnterBackground:(NoaIMChatMessageModel *)message {
    
    NSString *sessionId;
    if (message.chatType == CIMChatType_SingleChat) {
        //单聊消息
        sessionId = message.fromID;
    } else if (message.chatType == CIMChatType_GroupChat) {
        //群聊消息
        sessionId = message.toID;
    } else {
        sessionId = @"";
    }
    //会话开启了免打扰后，app退到后台不提示有消息
    LingIMSessionModel *sessionModel = [IMSDKManager toolCheckMySessionWith:sessionId];
    if (sessionModel.sessionNoDisturb) {
        return;
    }

    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObjectSafe:@"chat" forKey:@"jumpType"];
    [userInfo setObjectSafe:@(message.chatType) forKey:@"chatType"];
    [userInfo setObjectSafe:sessionId forKey:@"sessionId"];
    [userInfo setObjectSafe:message.fromNickname forKey:@"chatName"];
    
    if (message.chatType == CIMChatType_SingleChat) {
        if (message.messageType == CIMChatMessageType_TextMessage || message.messageType == CIMChatMessageType_ImageMessage || message.messageType == CIMChatMessageType_VideoMessage || message.messageType == CIMChatMessageType_StickersMessage || message.messageType == CIMChatMessageType_VoiceMessage || message.messageType == CIMChatMessageType_FileMessage || message.messageType == CIMChatMessageType_GameStickersMessage || message.messageType == CIMChatMessageType_CardMessage || message.messageType == CIMChatMessageType_GeoMessage || message.messageType == CIMChatMessageType_ForwardMessage) {
         
            NSString * title;
            LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:message.fromID];
            if (friendModel) {
                title = friendModel.showName;
            } else {
               title = message.fromNickname;
            }
            NSString * body = @"";
            if(message.messageType == CIMChatMessageType_TextMessage) {
                body = [self replaceEmojiTextContent:[NSString isNil:message.translateContent] ? message.textContent : message.translateContent];
            } else if (message.messageType == CIMChatMessageType_ImageMessage) {
                body = LanguageToolMatch(@"[图片]");
            } else if (message.messageType == CIMChatMessageType_VideoMessage) {
                body = LanguageToolMatch(@"[视频]");
            } else if (message.messageType == CIMChatMessageType_StickersMessage) {
                body = LanguageToolMatch(@"[表情]");
            } else if (message.messageType == CIMChatMessageType_VoiceMessage) {
                body = LanguageToolMatch(@"[语音]");
            } else if (message.messageType == CIMChatMessageType_FileMessage) {
                body = LanguageToolMatch(@"[文件]");
            } else if (message.messageType == CIMChatMessageType_GameStickersMessage) {
                body = LanguageToolMatch(@"[表情]");
            } else if (message.messageType == CIMChatMessageType_CardMessage) {
                body = [NSString stringWithFormat:@"%@%@", LanguageToolMatch(@"[个人名片]"), message.cardNickName];
            } else if (message.messageType == CIMChatMessageType_GeoMessage){
                body = [NSString stringWithFormat:@"%@%@", LanguageToolMatch(@"[位置]"), message.geoName];
            } else if (message.messageType == CIMChatMessageType_ForwardMessage) {
                body = [NSString stringWithFormat:@"%@%@", LanguageToolMatch(@"[会话记录]"), message.forwardMessage.title];
            }  else{
                body = LanguageToolMatch(@"发了一条新消息");
            }
            [self showLocalPush:title body:body userInfo:userInfo withIdentifier:@"__LOCAL_PUSH__2" playSoud:YES soundName:nil];
        }
    } else if (message.chatType == CIMChatType_GroupChat){
        if (message.messageType == CIMChatMessageType_TextMessage || message.messageType == CIMChatMessageType_AtMessage || message.messageType == CIMChatMessageType_ImageMessage || message.messageType == CIMChatMessageType_VideoMessage || message.messageType == CIMChatMessageType_StickersMessage || message.messageType == CIMChatMessageType_VoiceMessage || message.messageType == CIMChatMessageType_FileMessage || message.messageType == CIMChatMessageType_GameStickersMessage || message.messageType == CIMChatMessageType_CardMessage || message.messageType == CIMChatMessageType_GeoMessage || message.messageType == CIMChatMessageType_ForwardMessage || message.serverMessage.sMsgType == IMServerMessage_ServerMsgType_NoticeGroupMessage) {
            
            NSString *title;
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:message.fromID groupID:message.toID];
            if (groupMemberModel) {
                title = groupMemberModel.showName;
            } else {
                title = message.fromNickname;
            }
            NSString * body = @"";
            if(message.messageType == CIMChatMessageType_TextMessage){
                body = [self replaceEmojiTextContent:[NSString isNil:message.translateContent] ? message.textContent : message.translateContent];
            } else if (message.messageType == CIMChatMessageType_AtMessage) {
                for (NSDictionary *atUserDic in message.atUsersInfoList) {
                    NSArray *atKeyArr = [atUserDic allKeys];
                    NSString *atKey = (NSString *)[atKeyArr firstObject];
                    
                    if ([atKey isEqualToString:UserManager.userInfo.userUID]) {
                        // @我
                        body = [NSString stringWithFormat:LanguageToolMatch(@"%@@了你"), groupMemberModel.showName];
                    } else if ([atKey isEqualToString:@"-1"]) {
                        // @所有人
                        body = [NSString stringWithFormat:LanguageToolMatch(@"%@@了你"), groupMemberModel.showName];
                    } else {
                        body = @"";
                    }
                }
            } else if (message.messageType == CIMChatMessageType_ImageMessage) {
                body = LanguageToolMatch(@"[图片]");
            } else if (message.messageType == CIMChatMessageType_VideoMessage) {
                body = LanguageToolMatch(@"[视频]");
            } else if (message.messageType == CIMChatMessageType_StickersMessage) {
                body = LanguageToolMatch(@"[表情]");
            } else if (message.messageType == CIMChatMessageType_VoiceMessage) {
                body = LanguageToolMatch(@"[语音]");
            } else if (message.messageType == CIMChatMessageType_FileMessage) {
                body = LanguageToolMatch(@"[文件]");
            } else if (message.messageType == CIMChatMessageType_GameStickersMessage) {
                body = LanguageToolMatch(@"[表情]");
            } else if (message.messageType == CIMChatMessageType_CardMessage) {
                body = [NSString stringWithFormat:@"%@%@", LanguageToolMatch(@"[个人名片]"), message.cardNickName];
            } else if (message.messageType == CIMChatMessageType_GeoMessage) {
                body = [NSString stringWithFormat:@"%@%@", LanguageToolMatch(@"[位置]"), message.geoName];
            } else if (message.serverMessage.sMsgType == IMServerMessage_ServerMsgType_NoticeGroupMessage) {
                body = [NSString stringWithFormat:@"%@：%@", message.fromNickname, LanguageToolMatch(@"[群公告]")];
            } else if (message.messageType == CIMChatMessageType_ForwardMessage) {
                body = [NSString stringWithFormat:@"%@%@", LanguageToolMatch(@"[会话记录]"), message.forwardMessage.title];
            } else{
                body = LanguageToolMatch(@"发了一条新消息");
            }
            [self showLocalPush:title body:body userInfo:userInfo withIdentifier:@"__LOCAL_PUSH__2" playSoud:YES soundName:nil];
        }
    } else{
        //DLog(@"CIMChatType_Other,未解析聊天消息类型:%ld",message.chatType);
    }
}
- (void)receivePushInviteWithEnterBackground:(FriendInviteMessage *)message{
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObjectSafe:@"friend" forKey:@"jumpType"];
    
    NSString * title = @"";
    NSString * body = @"";
    if(message.fNick.length){
        title = message.fNick;
    }
    if(message.reason.length){
        body= [NSString stringWithFormat:@"%@",message.reason];
    }else{
        body = LanguageToolMatch(@"请求添加您为好友~");
    }
    [self showLocalPush:title body:body userInfo:userInfo withIdentifier:@"__LOCAL_PUSH__3" playSoud:YES soundName:nil];
}

- (NSString *)replaceEmojiTextContent:(NSString *)textContent {
    if ([ZLanguageTOOL.currentLanguage.languageAbbr isEqualToString:@"zh-Hans"] ||
        [ZLanguageTOOL.currentLanguage.languageAbbr isEqualToString:@"zh-Hant"]) {
        
        return textContent;
    } else {
        NSString *resultContent = [textContent copy];
        //匹配 emoji
        NSError *error;
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:@"\\[[^ \\[\\]]+?\\]"
                                      options:0
                                      error:&error];
        if (!error) {
            NSArray *matchs = [regex matchesInString:textContent
                                             options:0
                                               range:NSMakeRange(0, [textContent length])];
            for (NSTextCheckingResult *match in matchs) {
                NSString *result = [textContent safeSubstringWithRange:match.range];
                resultContent = [resultContent stringByReplacingOccurrencesOfString:result withString:@"[emoji]"];
            }
        }
        return resultContent;
    }
}


/*
- (void)receivePushAgreenWithEnterBackground:(FriendConfirmMessage *)message{
    NSString * title = @"";
    NSString * body = @"";
    if(message.nick.length){
        title = [NSString stringWithFormat:@"%@已同意好友申请",message.nick];
    }
    if(message.reason.length){
        body= [NSString stringWithFormat:@"%@",message.reason];
    }else{
        body = @"我们已经是好友了";
    }
    [self showLocalPush:title body:body userInfo:@{} withIdentifier:@"__LOCAL_PUSH__4" playSoud:YES soundName:nil];
}
*/
@end
