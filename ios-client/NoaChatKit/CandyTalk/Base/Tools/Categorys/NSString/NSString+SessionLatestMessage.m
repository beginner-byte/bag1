//
//  NSString+SessionLatestMessage.m
//  NoaKit
//
//  Created by Candy on 2026/11/15.
//

#import "NSString+SessionLatestMessage.h"
#import "NoaMessageTools.h"
#import "NoaChatInputEmojiManager.h"

@implementation NSString (SessionLatestMessage)

#pragma mark - <<<<<<根据聊天消息内容确定会话列表展示内容>>>>>>
+ (NSMutableAttributedString *)getSessionLatestMessageAttributedStringWith:(LingIMSessionModel *)sessionModel {
    NoaIMChatMessageModel *chatMessage = sessionModel.sessionLatestMessage;
    
    NSMutableAttributedString *sessionAttStr = [[NSMutableAttributedString alloc] initWithString:@""];
    
    if (chatMessage) {
        
        if (chatMessage.messageType == CIMChatMessageType_TextMessage) {
            if ([chatMessage.fromID isEqualToString:UserManager.userInfo.userUID]) {
                sessionAttStr = [[NoaChatInputEmojiManager sharedManager] attributedString:(![NSString isNil:chatMessage.textContent] ? chatMessage.textContent : @"") imageRect:CGRectMake(0, -4, 18, 18)];
            } else {
                NSString *showContent = @"";
                if (![NSString isNil:chatMessage.againTranslateContent]) {
                    showContent = chatMessage.againTranslateContent;
                } else {
                    if (![NSString isNil:chatMessage.translateContent]) {
                        showContent = chatMessage.translateContent;
                    } else {
                        showContent = chatMessage.textContent;
                    }
                }
                sessionAttStr = [[NoaChatInputEmojiManager sharedManager] attributedString:showContent imageRect:CGRectMake(0, -4, 18, 18)];
            }
            [self configAttributedString:sessionAttStr fontNum:12];
        } else if (chatMessage.messageType == CIMChatMessageType_ImageMessage){
            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"[图片]")];
            [self configAttributedString:sessionAttStr fontNum:12];
        } else if (chatMessage.messageType == CIMChatMessageType_VoiceMessage){
            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"[语音]")];
            [self configAttributedString:sessionAttStr fontNum:12];
        } else if (chatMessage.messageType == CIMChatMessageType_FileMessage){
            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"[文件]")];
            [self configAttributedString:sessionAttStr fontNum:12];
        } else if (chatMessage.messageType == CIMChatMessageType_VideoMessage) {
            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"[视频]")];
            [self configAttributedString:sessionAttStr fontNum:12];
        } else if (chatMessage.messageType == CIMChatMessageType_StickersMessage) {
            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"[表情]")];
            [self configAttributedString:sessionAttStr fontNum:12];
        } else if (chatMessage.messageType == CIMChatMessageType_GameStickersMessage) {
            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"[表情]")];
            [self configAttributedString:sessionAttStr fontNum:12];
        }  else if (chatMessage.messageType == CIMChatMessageType_CardMessage) {
            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", LanguageToolMatch(@"[个人名片]"), chatMessage.cardNickName]];
            [self configAttributedString:sessionAttStr fontNum:12];
        } else if (chatMessage.messageType == CIMChatMessageType_GeoMessage) {
            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", LanguageToolMatch(@"[位置]"), chatMessage.geoName]];
            [self configAttributedString:sessionAttStr fontNum:12];
        } else if (chatMessage.messageType == CIMChatMessageType_ForwardMessage) {
            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"[会话记录]")];
            [self configAttributedString:sessionAttStr fontNum:12];
        } else if (chatMessage.messageType == CIMChatMessageType_AtMessage) {
            if ([chatMessage.fromID isEqualToString:UserManager.userInfo.userUID]) {
                chatMessage.showContent = [NoaMessageTools atContenTranslateToShowContent:(chatMessage.atContent.length > 0 ? chatMessage.atContent : @"") atUsersDictList:chatMessage.atUsersInfoList withMessage:chatMessage isGetShowName:YES];
                
                NSString *atContetnStr = [NSString stringWithString:(![NSString isNil:chatMessage.showContent] ? chatMessage.showContent : @"")];
                sessionAttStr = [[NoaChatInputEmojiManager sharedManager] attributedString:atContetnStr imageRect:CGRectMake(0, -4, 18, 18)];
            } else {
                if (![NSString isNil:chatMessage.againAtTranslateContent]) {
                    chatMessage.showTranslateContent = [NoaMessageTools atContenTranslateToShowContent:(![NSString isNil:chatMessage.againAtTranslateContent] ? chatMessage.againAtTranslateContent : chatMessage.atTranslateContent) atUsersDictList:chatMessage.atUsersInfoList withMessage:chatMessage isGetShowName:NO];
                    
                    NSString *atContetnStr = [NSString stringWithString:(![NSString isNil:chatMessage.showTranslateContent] ? chatMessage.showTranslateContent : @"")];
                    sessionAttStr = [[NoaChatInputEmojiManager sharedManager] attributedString:atContetnStr imageRect:CGRectMake(0, -4, 18, 18)];
                } else {
                    chatMessage.showContent = [NoaMessageTools atContenTranslateToShowContent:(chatMessage.atTranslateContent.length > 0 ? chatMessage.atTranslateContent : chatMessage.atContent) atUsersDictList:chatMessage.atUsersInfoList withMessage:chatMessage  isGetShowName:YES];
                    
                    NSString *atContetnStr = [NSString stringWithString:(![NSString isNil:chatMessage.showContent] ? chatMessage.showContent : @"")];
                    sessionAttStr = [[NoaChatInputEmojiManager sharedManager] attributedString:atContetnStr imageRect:CGRectMake(0, -4, 18, 18)];
                }
            }
            
            [self configAttributedString:sessionAttStr fontNum:12];
        } else if (chatMessage.messageType == CIMChatMessageType_BackMessage) {
            if (chatMessage.chatType == CIMChatType_GroupChat) {
                NSString *resutlContent = @"";
                if (chatMessage.backDelInformSwitch == 2) {
                    sessionAttStr = [[NSMutableAttributedString alloc] initWithString:resutlContent];
                } else {
                    if (chatMessage.backDelInformSwitch == 0) {
                        resutlContent = [NSString stringWithFormat:LanguageToolMatch(@"%@ 撤回了一条消息"), @""];
                        sessionAttStr = [[NSMutableAttributedString alloc] initWithString:resutlContent];
                    }
                    if (chatMessage.backDelInformSwitch == 1) {
                        if (chatMessage.backDelInformUidArray != nil) {
                            if (chatMessage.backDelInformUidArray.count == 0) {
                                resutlContent = [NSString stringWithFormat:LanguageToolMatch(@"%@ 撤回了一条消息"), @""];
                                sessionAttStr = [[NSMutableAttributedString alloc] initWithString:resutlContent];
                            } else {
                                if ([chatMessage.backDelInformUidArray containsObject:UserManager.userInfo.userUID]) {
                                    resutlContent = [NSString stringWithFormat:LanguageToolMatch(@"%@ 撤回了一条消息"), @""];
                                    sessionAttStr = [[NSMutableAttributedString alloc] initWithString:resutlContent];
                                }
                            }
                        } else {
                            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:resutlContent];
                        }
                    }
                }
            } else {
                //撤回消息
                sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"%@ 撤回了一条消息"), @""]];
            }
            [self configAttributedString:sessionAttStr fontNum:12];
        }else if (chatMessage.messageType == CIMChatMessageType_DelMessage) {
            //删除消息
        }else if (chatMessage.messageType == CIMChatMessageType_GroupNotice) {
            //群公告消息
            NSString *tempStr = [NSString stringWithFormat:LanguageToolMatch(@"“%@”设置了群公告"),chatMessage.fromNickname];
            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:tempStr];
            [self configAttributedString:sessionAttStr fontNum:12];
            
            NSMutableAttributedString *groupNoticeTip = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"[%@]",LanguageToolMatch(@"群公告")]];
            NSDictionary *dict = @{NSFontAttributeName:FONTR(12), NSForegroundColorAttributeName:COLOR_F93A2F};
            [groupNoticeTip addAttributes:dict range:NSMakeRange(0, groupNoticeTip.length)];
            [sessionAttStr insertAttributedString:groupNoticeTip atIndex:0];
        }else if (chatMessage.messageType == CIMChatMessageType_NetCallMessage) {
            //即构 音视频通话消息
            sessionAttStr = [self dealChatMessageForNetCallMessage:chatMessage];
            [self configAttributedString:sessionAttStr fontNum:12];
        }else if (chatMessage.messageType == CIMChatMessageType_ServerMessage) {
            //系统通知消息
            sessionAttStr = [self dealServerMessage:chatMessage];
            [self configAttributedString:sessionAttStr fontNum:12];
        }
        
        //非空
        if (sessionAttStr.length > 0) {
            
            if (chatMessage.chatType == CIMChatType_SingleChat) {
                //单聊 且 非通知类型消息，且不是撤回消息类型，且不是系统级的好友(文件助手)
                if (chatMessage.messageType != CIMChatMessageType_ServerMessage && chatMessage.messageType != CIMChatMessageType_BackMessage && ![chatMessage.toID isEqualToString:@"100002"]) {
                    if ([chatMessage.fromID isEqualToString:UserManager.userInfo.userUID]) {
                        //我发送的单聊消息
                        NSAttributedString *attributedImage;
                        if (chatMessage.messageSendType == CIMChatMessageSendTypeSending) {
                            //消息发送中
                            attributedImage = [self attributedStringWithImage:@"img_msg_send_loading"];
                        }else if (chatMessage.messageSendType == CIMChatMessageSendTypeFail) {
                            //消息发送失败
                            attributedImage = [self attributedStringWithImage:@"icon_msg_resend"];
                        }else {
                            if ([UserManager.userRoleAuthInfo.showUserRead.configValue isEqualToString:@"true"]) {
                                //消息发送成功
                                if (chatMessage.haveReadCount == 1) {
                                    //对方已读我发的消息
                                    attributedImage = [self attributedStringWithImage:@"s_cell_readed"];
                                }else {
                                    //对方未读我发的消息
                                    attributedImage = [self attributedStringWithImage:@"s_cell_unread"];
                                }
                            } else {
                                attributedImage = [self attributedStringWithImage:@""];
                            }
                        }
                        [sessionAttStr insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:0];
                        [sessionAttStr insertAttributedString:attributedImage atIndex:0];
                    }else {
                        //对方发送的单聊消息
                        sessionAttStr = sessionAttStr;
                    }
                };
                
            } else if (chatMessage.chatType == CIMChatType_GroupChat) {
                //群聊 且 非通知类型消息，且不是撤回消息类型，且不是群公告消息类型
                if (chatMessage.messageType != CIMChatMessageType_ServerMessage && chatMessage.messageType != CIMChatMessageType_BackMessage && chatMessage.messageType != CIMChatMessageType_GroupNotice) {
                    NSMutableAttributedString *attributedName;
                    if ([chatMessage.fromID isEqualToString:[IMSDKManager myUserID]]) {
                        //我发送的群聊消息
                        attributedName = [[NSMutableAttributedString alloc] initWithString:@""];
                        
                        NSAttributedString *attributedImage;
                        if (chatMessage.messageSendType == CIMChatMessageSendTypeSending) {
                            //消息发送中
                            attributedImage = [self attributedStringWithImage:@"img_msg_send_loading"];
                        }else if (chatMessage.messageSendType == CIMChatMessageSendTypeFail) {
                            //消息发送失败
                            attributedImage = [self attributedStringWithImage:@"icon_msg_resend"];
                        }else {
                        }
                        if (attributedImage) {
                            [sessionAttStr insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:0];
                            [sessionAttStr insertAttributedString:attributedImage atIndex:0];
                        }
                        
                    }else {
                        //别人发送的群聊消息
                        LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:chatMessage.fromID groupID:chatMessage.toID];
                        if (groupMemberModel) {
                            NSString *fromName = [NSString loadNickNameWithUserStatus:groupMemberModel.disableStatus realNickName:![NSString isNil:groupMemberModel.remarks]? groupMemberModel.remarks : groupMemberModel.showName];
                            attributedName = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@：", fromName]];
                        } else {
                            attributedName = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@：", chatMessage.fromNickname]];
                        }
                    }

                    [self configAttributedString:attributedName fontNum:12];
                    [sessionAttStr insertAttributedString:attributedName atIndex:0];
                }
            } else {
                //其他类型聊天消息
            }
            
            //@消息处理，且是别人发的
            if (chatMessage.messageType == CIMChatMessageType_AtMessage && ![chatMessage.fromID isEqualToString:UserManager.userInfo.userUID]) {
                BOOL isAtMe = NO;
                for (NSDictionary *atUserDic in chatMessage.atUsersInfoList) {
                    if ([[atUserDic allKeys] containsObject:UserManager.userInfo.userUID] || [[atUserDic allKeys] containsObject:@"-1"]) {
                        isAtMe = YES;
                    }
                }
                if (isAtMe) {
                    //有人 @ 我  @所有人
                    NSMutableAttributedString *atStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"[有人@我]")];
                    NSDictionary *dict = @{NSFontAttributeName:FONTR(12), NSForegroundColorAttributeName:COLOR_F93A2F};
                    [atStr addAttributes:dict range:NSMakeRange(0, atStr.length)];
                    [sessionAttStr insertAttributedString:atStr atIndex:0];
                }
            }
        };
        
        
    }else {
        sessionAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"[暂无新消息]")];
        [self configAttributedString:sessionAttStr fontNum:12];
    }
    
    return sessionAttStr;
}

#pragma mark - 系统通知类型消息
+ (NSMutableAttributedString *)dealServerMessage:(NoaIMChatMessageModel *)chatMessage{
    NSMutableAttributedString *sessionAttStr = [[NSMutableAttributedString alloc] initWithString:@""];
    
    IMServerMessage *serverMessage = chatMessage.serverMessage;
    
    switch (serverMessage.sMsgType) {
        case IMServerMessage_ServerMsgType_NullFriendMessage://好友不存在
        {
            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"您还不是对方好友，请先添加好友。")];
        }
            break;
        case IMServerMessage_ServerMsgType_BlackFriendMessage://好友黑名单
        {
            FriendBlackMessage *friendBlack = serverMessage.friendBlackMessage;
            if (friendBlack.type == 1) {
                //我拉黑好友
                sessionAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"已拉黑")];
            }else {
                //好友拉黑我
                sessionAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"对方已拒绝接受你的消息")];
            }
        }
            break;
        case IMServerMessage_ServerMsgType_UserAccountClose://好友账号已注销
        {
            //UserAccountClose *accountClose = serverMessage.userAccountClose;
            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"账号已注销")];
        }
            break;
            
            
            /*** 分割线：好友群组提示消息 ***/
        case IMServerMessage_ServerMsgType_CreateGroupMessage://创建群聊
        {
            CreateGroupMessage *createModel = serverMessage.createGroupMessage;
            
            NSString *user;
            if ([createModel.uid isEqualToString:UserManager.userInfo.userUID]) {
                //我创建的群聊
                user = LanguageToolMatch(@"你邀请了 ");
            }
            
            __block NSMutableArray *invitedUserArr = [NSMutableArray array];
            NSArray *invitedMemberArr = createModel.inviteUidArray;
            [invitedMemberArr enumerateObjectsUsingBlock:^(UserInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:obj.uId groupID:createModel.gid];
                if (![obj.uId isEqualToString:createModel.uid]) {
                    [invitedUserArr addObjectIfNotNil: groupMemberModel ? groupMemberModel.showName : obj.uNick];
                }
            }];
            
            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"%@“%@” 加入了群聊"),user,[invitedUserArr componentsJoinedByString:@"，"]]];
        }
            break;
        case IMServerMessage_ServerMsgType_InviteConfirmGroupMessage://邀请进群
        {
            InviteConfirmGroupMessage *inviteModel = serverMessage.inviteConfirmGroupMessage;
            if (inviteModel.informUidArray != nil) {
                if (inviteModel.informUidArray.count == 0) {
                    if (inviteModel.type == 4) {
                        //“xxx”通过扫描二维码加入群聊
                        __block NSMutableArray *invitedUserArr = [NSMutableArray array];
                        NSArray *invitedMemberArr = inviteModel.inviteUidArray;
                        [invitedMemberArr enumerateObjectsUsingBlock:^(UserInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            if ([obj.uId isEqualToString:UserManager.userInfo.userUID]) {
                                [invitedUserArr addObjectIfNotNil:LanguageToolMatch(@"你")];
                            }else {
                                [invitedUserArr addObjectIfNotNil:obj.uNick];
                            }
                        }];
                        
                        sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"“%@”通过扫描二维码加入群聊"), [invitedUserArr componentsJoinedByString:@"，"]]];
                    } else {
                        NSString *user;
                        if ([inviteModel.uid isEqualToString:UserManager.userInfo.userUID]) {
                            //我发起的邀请
                            user = LanguageToolMatch(@"你邀请了 ");
                        }else {
                            //别人发起的邀请
                            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:inviteModel.uid groupID:inviteModel.gid];
                            user = [NSString stringWithFormat:LanguageToolMatch(@"“%@”邀请了 "), groupMemberModel ? groupMemberModel.showName : inviteModel.nick];
                        }
                        
                        __block NSMutableArray *invitedUserArr = [NSMutableArray array];
                        
                        NSArray *invitedMemberArr = inviteModel.inviteUidArray;
                        [invitedMemberArr enumerateObjectsUsingBlock:^(UserInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            if ([obj.uId isEqualToString:UserManager.userInfo.userUID]) {
                                [invitedUserArr addObjectIfNotNil:LanguageToolMatch(@"你")];
                            }else {
                                LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:obj.uId groupID:inviteModel.gid];
                                [invitedUserArr addObjectIfNotNil:groupMemberModel ? groupMemberModel.showName : obj.uNick];
                            }
                        }];
                        
                        sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"%@“%@” 加入了群聊"),user,[invitedUserArr componentsJoinedByString:@"，"]]];
                    }
                } else {
                    if ([inviteModel.informUidArray containsObject:UserManager.userInfo.userUID]) {
                        if (inviteModel.type == 4) {
                            //“xxx”通过扫描二维码加入群聊
                            __block NSMutableArray *invitedUserArr = [NSMutableArray array];
                            NSArray *invitedMemberArr = inviteModel.inviteUidArray;
                            [invitedMemberArr enumerateObjectsUsingBlock:^(UserInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                if ([obj.uId isEqualToString:UserManager.userInfo.userUID]) {
                                    [invitedUserArr addObjectIfNotNil:LanguageToolMatch(@"你")];
                                }else {
                                    [invitedUserArr addObjectIfNotNil:obj.uNick];
                                }
                            }];
                            
                            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"“%@”通过扫描二维码加入群聊"), [invitedUserArr componentsJoinedByString:@"，"]]];
                        } else {
                            NSString *user;
                            if ([inviteModel.uid isEqualToString:UserManager.userInfo.userUID]) {
                                //我发起的邀请
                                user = LanguageToolMatch(@"你邀请了 ");
                            }else {
                                //别人发起的邀请
                                LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:inviteModel.uid groupID:inviteModel.gid];
                                user = [NSString stringWithFormat:LanguageToolMatch(@"“%@”邀请了 "), groupMemberModel ? groupMemberModel.showName : inviteModel.nick];
                            }
                            
                            __block NSMutableArray *invitedUserArr = [NSMutableArray array];
                            
                            NSArray *invitedMemberArr = inviteModel.inviteUidArray;
                            [invitedMemberArr enumerateObjectsUsingBlock:^(UserInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                if ([obj.uId isEqualToString:UserManager.userInfo.userUID]) {
                                    [invitedUserArr addObjectIfNotNil:LanguageToolMatch(@"你")];
                                }else {
                                    LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:obj.uId groupID:inviteModel.gid];
                                    [invitedUserArr addObjectIfNotNil:groupMemberModel ? groupMemberModel.showName : obj.uNick];
                                }
                            }];
                            
                            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"%@“%@” 加入了群聊"),user,[invitedUserArr componentsJoinedByString:@"，"]]];
                        }
                    }
                }
            } else  {
                if (inviteModel.type == 4) {
                    //“xxx”通过扫描二维码加入群聊
                    __block NSMutableArray *invitedUserArr = [NSMutableArray array];
                    NSArray *invitedMemberArr = inviteModel.inviteUidArray;
                    [invitedMemberArr enumerateObjectsUsingBlock:^(UserInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj.uId isEqualToString:UserManager.userInfo.userUID]) {
                            [invitedUserArr addObjectIfNotNil:LanguageToolMatch(@"你")];
                        }else {
                            [invitedUserArr addObjectIfNotNil:obj.uNick];
                        }
                    }];
                    
                    sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"“%@”通过扫描二维码加入群聊"), [invitedUserArr componentsJoinedByString:@"，"]]];
                } else {
                    NSString *user;
                    if ([inviteModel.uid isEqualToString:UserManager.userInfo.userUID]) {
                        //我发起的邀请
                        user = LanguageToolMatch(@"你邀请了 ");
                    }else {
                        //别人发起的邀请
                        LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:inviteModel.uid groupID:inviteModel.gid];
                        user = [NSString stringWithFormat:LanguageToolMatch(@"“%@”邀请了 "), groupMemberModel ? groupMemberModel.showName : inviteModel.nick];
                    }
                    
                    __block NSMutableArray *invitedUserArr = [NSMutableArray array];
                    
                    NSArray *invitedMemberArr = inviteModel.inviteUidArray;
                    [invitedMemberArr enumerateObjectsUsingBlock:^(UserInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj.uId isEqualToString:UserManager.userInfo.userUID]) {
                            [invitedUserArr addObjectIfNotNil:LanguageToolMatch(@"你")];
                        }else {
                            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:obj.uId groupID:inviteModel.gid];
                            [invitedUserArr addObjectIfNotNil:groupMemberModel ? groupMemberModel.showName : obj.uNick];
                        }
                    }];
                    
                    sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"%@“%@” 加入了群聊"),user,[invitedUserArr componentsJoinedByString:@"，"]]];
                }
            }
            
        }
            break;
        case IMServerMessage_ServerMsgType_GroupNoChatMessage://告知发消息的用户，群禁言已开启
        {
            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"群主开启了全员禁言")];
        }
            break;
        case IMServerMessage_ServerMsgType_NullGroupMessage://群组不存在
        {
            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"群组已解散")];
        }
            break;
        case IMServerMessage_ServerMsgType_MemberNoGroupMessage://用户不在群内
        {
            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"你已不在该群")];
        }
            break;
        case IMServerMessage_ServerMsgType_MemberGroupForbidMessage://用户在群组内被禁言
        {
            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"你已被禁言")];
        }
            break;
        case IMServerMessage_ServerMsgType_KickGroupMessage://群成员被踢
        {
//            KickGroupMessage *kickmember = serverMessage.kickGroupMessage;
//            if (kickmember.informUidArray != nil) {
//                if (kickmember.informUidArray.count == 0) {
//                    if ([kickmember.uid isEqualToString:UserManager.userInfo.userUID]) {
//                        sessionAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"你已被踢出群聊")];
//                    }else {
//                        //被踢成员
//                        LingIMGroupMemberModel *groupMemberKickModel = [IMSDKManager imSdkCheckGroupMemberWith:kickmember.uid groupID:kickmember.gid];
//                        //操作人
//                        LingIMGroupMemberModel *groupMemberOperateModel = [IMSDKManager imSdkCheckGroupMemberWith:kickmember.operateUid groupID:kickmember.gid];
//                        sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"“%@”将“%@”踢出群聊"),groupMemberOperateModel ? groupMemberOperateModel.showName : kickmember.operateNick, groupMemberKickModel ? groupMemberKickModel.showName : kickmember.nick]];
//                    }
//                } else {
//                    if ([kickmember.informUidArray containsObject:UserManager.userInfo.userUID]) {
//                        if ([kickmember.uid isEqualToString:UserManager.userInfo.userUID]) {
//                            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"你已被踢出群聊")];
//                        }else {
//                            //被踢成员
//                            LingIMGroupMemberModel *groupMemberKickModel = [IMSDKManager imSdkCheckGroupMemberWith:kickmember.uid groupID:kickmember.gid];
//                            //操作人
//                            LingIMGroupMemberModel *groupMemberOperateModel = [IMSDKManager imSdkCheckGroupMemberWith:kickmember.operateUid groupID:kickmember.gid];
//                            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"“%@”将“%@”踢出群聊"),groupMemberOperateModel ? groupMemberOperateModel.showName : kickmember.operateNick, groupMemberKickModel ? groupMemberKickModel.showName : kickmember.nick]];
//                        }
//                    }
//                }
//            } else {
//                if ([kickmember.uid isEqualToString:UserManager.userInfo.userUID]) {
//                    sessionAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"你已被踢出群聊")];
//                }else {
//                    //被踢成员
//                    LingIMGroupMemberModel *groupMemberKickModel = [IMSDKManager imSdkCheckGroupMemberWith:kickmember.uid groupID:kickmember.gid];
//                    //操作人
//                    LingIMGroupMemberModel *groupMemberOperateModel = [IMSDKManager imSdkCheckGroupMemberWith:kickmember.operateUid groupID:kickmember.gid];
//                    sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"“%@”将“%@”踢出群聊"),groupMemberOperateModel ? groupMemberOperateModel.showName : kickmember.operateNick, groupMemberKickModel ? groupMemberKickModel.showName : kickmember.nick]];
//                }
//            }
            
            
        }
            break;
        case IMServerMessage_ServerMsgType_OutGroupMessage://群成员退群
        {
//            OutGroupMessage *outGroupMember = serverMessage.outGroupMessage;
//            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:outGroupMember.uid groupID:outGroupMember.gid];
//            if (outGroupMember.informUidArray != nil) {
//                if (outGroupMember.informUidArray.count == 0) {
//                    sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"“%@”退出了群聊"),groupMemberModel ? groupMemberModel.showName : outGroupMember.nick]];
//                } else {
//                    if ([outGroupMember.informUidArray containsObject:UserManager.userInfo.userUID]) {
//                        sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"“%@”退出了群聊"),groupMemberModel ? groupMemberModel.showName : outGroupMember.nick]];
//                    }
//                }
//            } else  {
//                sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"“%@”退出了群聊"),groupMemberModel ? groupMemberModel.showName : outGroupMember.nick]];
//            }
            
        }
            break;
        case IMServerMessage_ServerMsgType_TransferOwnerMessage://转让群主
        {
            TransferOwnerMessage *groupOwnerTransfer = serverMessage.transferOwnerMessage;
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:groupOwnerTransfer.uid groupID:groupOwnerTransfer.gid];
            if (groupOwnerTransfer.informUidArray != nil) {
                if (groupOwnerTransfer.informUidArray.count == 0) {
                    sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"群主变更为“%@”"), groupMemberModel ? groupMemberModel.showName : groupOwnerTransfer.nick]];

                } else {
                    if ([groupOwnerTransfer.informUidArray containsObject:UserManager.userInfo.userUID]) {
                        sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"群主变更为“%@”"), groupMemberModel ? groupMemberModel.showName : groupOwnerTransfer.nick]];

                    }
                }
            } else  {
                sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"群主变更为“%@”"), groupMemberModel ? groupMemberModel.showName : groupOwnerTransfer.nick]];

            }
        }
            break;
        case IMServerMessage_ServerMsgType_EstoppelGroupMessage://告知全部群成员 群禁言 开启/关闭
        {
            GroupStatusMessage *groupStatus = serverMessage.groupStatusMessage;
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:groupStatus.uid groupID:groupStatus.gid];
            if (groupStatus.status == 1) {
                sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"“%@”开启了全员禁言"), groupMemberModel ? groupMemberModel.showName : groupStatus.nick]];
            }else {
                sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"“%@”关闭了全员禁言"), groupMemberModel ? groupMemberModel.showName : groupStatus.nick]];
            }
        }
            break;
        case IMServerMessage_ServerMsgType_AdminGroupMessage://变更管理员
        {
            AdminGroupMessage *groupAdmin = serverMessage.adminGroupMessage;
            if (groupAdmin.informUidArray != nil) {
                if (groupAdmin.informUidArray.count == 0) {
                    __block NSMutableArray *adminArr = [NSMutableArray array];
                    NSArray *adminInfoArr = groupAdmin.adminInfoArray;
                    [adminInfoArr enumerateObjectsUsingBlock:^(UserInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj.uId isEqualToString:UserManager.userInfo.userUID]) {
                            [adminArr addObjectIfNotNil:LanguageToolMatch(@"你")];
                        }else {
                            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:obj.uId groupID:groupAdmin.gid];
                            [adminArr addObjectIfNotNil:groupMemberModel ? groupMemberModel.showName : obj.uNick];
                        }
                    }];
                    
                    //操作人
                    LingIMGroupMemberModel *groupMemberOperateModel = [IMSDKManager imSdkCheckGroupMemberWith:groupAdmin.operateUid groupID:groupAdmin.gid];
                    if (groupAdmin.type == 1) {
                        sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"“%@”将“%@”设为管理员"),groupMemberOperateModel ? groupMemberOperateModel.showName : groupAdmin.operateNick, [adminArr componentsJoinedByString:@"，"]]];
                    }else {
                        sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"“%@”将“%@”从管理员中移除"),groupMemberOperateModel ? groupMemberOperateModel.showName : groupAdmin.operateNick, [adminArr componentsJoinedByString:@"，"]]];
                    }
                } else {
                    if ([groupAdmin.informUidArray containsObject:UserManager.userInfo.userUID]) {
                        __block NSMutableArray *adminArr = [NSMutableArray array];
                        NSArray *adminInfoArr = groupAdmin.adminInfoArray;
                        [adminInfoArr enumerateObjectsUsingBlock:^(UserInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            if ([obj.uId isEqualToString:UserManager.userInfo.userUID]) {
                                [adminArr addObjectIfNotNil:LanguageToolMatch(@"你")];
                            }else {
                                LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:obj.uId groupID:groupAdmin.gid];
                                [adminArr addObjectIfNotNil:groupMemberModel ? groupMemberModel.showName : obj.uNick];
                            }
                        }];
                        
                        //操作人
                        LingIMGroupMemberModel *groupMemberOperateModel = [IMSDKManager imSdkCheckGroupMemberWith:groupAdmin.operateUid groupID:groupAdmin.gid];
                        if (groupAdmin.type == 1) {
                            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"“%@”将“%@”设为管理员"),groupMemberOperateModel ? groupMemberOperateModel.showName : groupAdmin.operateNick, [adminArr componentsJoinedByString:@"，"]]];
                        }else {
                            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"“%@”将“%@”从管理员中移除"),groupMemberOperateModel ? groupMemberOperateModel.showName : groupAdmin.operateNick, [adminArr componentsJoinedByString:@"，"]]];
                        }
                    } else {
                        
                    }
                }
            } else  {
                __block NSMutableArray *adminArr = [NSMutableArray array];
                NSArray *adminInfoArr = groupAdmin.adminInfoArray;
                [adminInfoArr enumerateObjectsUsingBlock:^(UserInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj.uId isEqualToString:UserManager.userInfo.userUID]) {
                        [adminArr addObjectIfNotNil:LanguageToolMatch(@"你")];
                    }else {
                        LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:obj.uId groupID:groupAdmin.gid];
                        [adminArr addObjectIfNotNil:groupMemberModel ? groupMemberModel.showName : obj.uNick];
                    }
                }];
                
                //操作人
                LingIMGroupMemberModel *groupMemberOperateModel = [IMSDKManager imSdkCheckGroupMemberWith:groupAdmin.operateUid groupID:groupAdmin.gid];
                if (groupAdmin.type == 1) {
                    sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"“%@”将“%@”设为管理员"),groupMemberOperateModel ? groupMemberOperateModel.showName : groupAdmin.operateNick, [adminArr componentsJoinedByString:@"，"]]];
                }else {
                    sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"“%@”将“%@”从管理员中移除"),groupMemberOperateModel ? groupMemberOperateModel.showName : groupAdmin.operateNick, [adminArr componentsJoinedByString:@"，"]]];
                }
            }
            
        }
            break;
            
        case IMServerMessage_ServerMsgType_NameGroupMessage://群名称修改
        {
            NameGroupMessage *groupName = serverMessage.nameGroupMessage;
            
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:groupName.uid groupID:groupName.gid];
            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"“%@”将群名称修改为“%@”"), groupMemberModel ? groupMemberModel.showName : groupName.nick, groupName.gName]];
        }
            break;
        case IMServerMessage_ServerMsgType_NoticeGroupMessage://群公告设置
        {
            NoticeGroupMessage *groupNotice = serverMessage.noticeGroupMessage;
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:groupNotice.uid groupID:groupNotice.gid];
            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"“%@”设置了群公告"), groupMemberModel ? groupMemberModel.showName : groupNotice.nick]];
        }
            break;
            
        case IMServerMessage_ServerMsgType_IsShowHistoryMessage://群禁止私聊
        {
            GroupStatusMessage *groupStatusMessage = serverMessage.groupStatusMessage;
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:groupStatusMessage.uid groupID:groupStatusMessage.gid];
            if (groupStatusMessage.status == 1) {
                sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"“%@” 开启了新成员可查看历史消息"), groupMemberModel ? groupMemberModel.showName : groupStatusMessage.nick]];
            }else {
                sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"“%@” 关闭了新成员可查看历史消息"), groupMemberModel ? groupMemberModel.showName : groupStatusMessage.nick]];
            }
        }
            break;
        case IMServerMessage_ServerMsgType_GroupSingleForbidMessage://群主或管理员 禁言某个群成员
        {
            GroupSingleForbidMessage *memberBanned = serverMessage.groupSingleForbidMessage;
            
            LingIMGroupMemberModel *groupMemberFromModel = [IMSDKManager imSdkCheckGroupMemberWith:memberBanned.fromUid groupID:memberBanned.gid];
            LingIMGroupMemberModel *groupMemberToModel = [IMSDKManager imSdkCheckGroupMemberWith:memberBanned.toUid groupID:memberBanned.gid];
            
            if ([memberBanned.toUid isEqualToString:UserManager.userInfo.userUID]) {
                if (memberBanned.status == 1) {
                    sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"你被“%@”%@"), groupMemberFromModel ? groupMemberFromModel.showName : memberBanned.fromNick, [NSString convertBannedSendMsgTime:memberBanned.expireTime]]];
                }else {
                    sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"你被“%@”解除禁言"), groupMemberFromModel ? groupMemberFromModel.showName : memberBanned.fromNick]];
                }
                
            }else {
                if (memberBanned.status == 1) {
                    sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"“%@”被“%@”%@"), groupMemberToModel ? groupMemberToModel.showName : memberBanned.toNick, groupMemberFromModel ? groupMemberFromModel.showName : memberBanned.fromNick, [NSString convertBannedSendMsgTime:memberBanned.expireTime]]];
                }else {
                    sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"“%@”被“%@”解除禁言"),groupMemberToModel ? groupMemberToModel.showName : memberBanned.toNick, groupMemberFromModel ? groupMemberFromModel.showName : memberBanned.fromNick]];
                }
            }
        }
            break;
        case IMServerMessage_ServerMsgType_DelGroupMessage://解散群组  该消息只转发给在线的所有群成员
        {
//            DelGroupMessage *groupDissolve = serverMessage.delGroupMessage;
//            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:groupDissolve.uid groupID:groupDissolve.gid];
//            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"“%@”解散了该群"), groupMemberModel ? groupMemberModel.showName : groupDissolve.nick]];
        }
            break;
        case IMServerMessage_ServerMsgType_InviteJoinGroupNoFriendMessage://邀请好友进群，但是好友不存在，该消息只转发给邀请加入的用户
        {
            InviteJoinGroupNoFriendMessage *inviteJoinGroupNoFriend = serverMessage.inviteJoinGroupNoFriendMessage;
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:inviteJoinGroupNoFriend.operateUid groupID:inviteJoinGroupNoFriend.gid];
            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"“%@”未添加你为好友，无法邀请进入群聊"), groupMemberModel ? groupMemberModel.showName : inviteJoinGroupNoFriend.operateNick]];
        }
            break;
        case IMServerMessage_ServerMsgType_InviteJoinGroupBlackFriendMessage://邀请好友进群，但是已被拉黑，该消息只转发给邀请加入的用户
        {
            InviteJoinGroupBlackFriendMessage *inviteJoinGroupBlackFriend = serverMessage.inviteJoinGroupBlackFriendMessage;
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:inviteJoinGroupBlackFriend.operateUid groupID:inviteJoinGroupBlackFriend.gid];
            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"“%@”拒绝加入群聊"), groupMemberModel ? groupMemberModel.showName : inviteJoinGroupBlackFriend.operateNick]];
        }
            break;
        case IMServerMessage_ServerMsgType_AvatarGroupMessage://变更群头像  该消息只转发给在线的所有群成员
        {
            AvatarGroupMessage *avatarGroup = serverMessage.avatarGroupMessage;
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:avatarGroup.uid groupID:avatarGroup.gid];
            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"“%@”修改了群头像"), groupMemberModel ? groupMemberModel.showName : avatarGroup.nick]];
        }
            break;
        case IMServerMessage_ServerMsgType_DelGroupNotice://删除群公告
        {
            DelGroupNotice *groupNoticeDel = serverMessage.delGroupNotice;
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:groupNoticeDel.uid groupID:groupNoticeDel.gid];
            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"“%@”删除了群公告"), groupMemberModel ? groupMemberModel.showName : groupNoticeDel.nick]];
        }
            break;
        case IMServerMessage_ServerMsgType_CustomEvent://自定义系统通知事件消息
        {
            sessionAttStr = [self dealServerMessageOfCustomEvent:chatMessage];
        }
            break;
        case IMServerMessage_ServerMsgType_ScheduleDeleteMessage://消息定时自动删除消息
        {
            ScheduleDeleteMessage *messageTimeDelete = serverMessage.scheduleDeleteMessage;
            NSString *userName;
            if (messageTimeDelete.chatType == ChatType_SingleChat) {
                //单聊消息
                if ([messageTimeDelete.userId isEqualToString:UserManager.userInfo.userUID]) {
                    userName = LanguageToolMatch(@"你");
                }else {
                    //单聊
                    LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:messageTimeDelete.userId];
                    if (friendModel) {
                        userName = ![NSString isNil:friendModel.showName] ? friendModel.showName : friendModel.nickname;
                    }else {
                        userName = messageTimeDelete.userNick;
                    }
                }
            }else {
                //群聊消息
                if ([messageTimeDelete.userId isEqualToString:UserManager.userInfo.userUID]) {
                    userName = LanguageToolMatch(@"你");
                }else {
                    LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:messageTimeDelete.userId groupID:messageTimeDelete.peerUid];
                    if (groupMemberModel) {
                        userName = ![NSString isNil:groupMemberModel.showName] ? groupMemberModel.showName : (![NSString isNil:groupMemberModel.nicknameInGroup] ? groupMemberModel.nicknameInGroup : groupMemberModel.userNickname);
                    } else {
                        userName = messageTimeDelete.userNick;
                    }
                }
            }
            NSString *timeDeleteInfo;
            switch (messageTimeDelete.freq) {
                case 1:
                    timeDeleteInfo = LanguageToolMatch(@"已设置自动删除1天前发送的消息");
                    break;
                case 7:
                    timeDeleteInfo = LanguageToolMatch(@"已设置自动删除7天前发送的消息");
                    break;
                case 30:
                    timeDeleteInfo = LanguageToolMatch(@"已设置自动删除30天前发送的消息");
                    break;
                    
                default:
                    timeDeleteInfo = LanguageToolMatch(@"关闭了自动删除");
                    break;
            }
            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",userName,timeDeleteInfo]];
        }
            break;
            
        case IMServerMessage_ServerMsgType_JoinVerifyGroupMessage://是否进群验证  该消息只转发给在线的所有群成员213
        {
            GroupStatusMessage *groupStatus = serverMessage.groupStatusMessage;
            NSString *userName;
            if ([groupStatus.uid isEqualToString:UserManager.userInfo.userUID]) {
                userName = LanguageToolMatch(@"你");
            }else {
                LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:groupStatus.uid groupID:groupStatus.gid];
                userName = groupMemberModel ? groupMemberModel.showName : groupStatus.nick;
            }
            if (groupStatus.status == 1) {
                sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"“%@”已启用群里邀请确认"), userName]];
            }else {
                sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"“%@”已关闭群里邀请确认"), userName]];
            }
            
        }
            break;
        case IMServerMessage_ServerMsgType_InviteJoinRepGroupMessage://邀请进群申请  该消息发送给群主和群管理员214
        {
            InviteJoinRepGroupMessage *inviteJoinGroup = serverMessage.inviteJoinRepGroupMessage;
            //邀请者信息
            NSString *inviterName;
            if ([inviteJoinGroup.uid isEqualToString:UserManager.userInfo.userUID]) {
                inviterName = LanguageToolMatch(@"你");
            }else {
                LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:inviteJoinGroup.uid groupID:inviteJoinGroup.gid];
                inviterName = groupMemberModel ? groupMemberModel.showName : inviteJoinGroup.nick;
            }
            //被邀请者信息
            NSString *inviteeName;
            UserInfo *inviteeInfo = inviteJoinGroup.inviteUidArray.firstObject;
            inviteeName = inviteeInfo.uNick;
            if (inviteJoinGroup.inviteUidArray.count > 1) {
                inviteeName = [NSString stringWithFormat:LanguageToolMatch(@"%@等%ld人"),inviteeName, inviteJoinGroup.inviteUidArray.count];
            }
            //群信息
            NSString *groupName = inviteJoinGroup.gName;
            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"%@邀请%@加入%@"), inviterName, inviteeName, groupName]];
        }
            break;
            
        default:
            break;
    }

    return sessionAttStr;
}

#pragma mark - 系统通知类型消息-自定义事件消息处理
+ (NSMutableAttributedString *)dealServerMessageOfCustomEvent:(NoaIMChatMessageModel *)chatMessage {
    NSMutableAttributedString *sessionAttStr = [[NSMutableAttributedString alloc] initWithString:@""];
    
    IMServerMessage *serverMessage = chatMessage.serverMessage;
    CustomEvent *customEvent = serverMessage.customEvent;
    NSString *jsonContent = customEvent.content;
    
    if (customEvent.type == 101) {
        //单人音视频
        LIMMediaCallSingleModel *mediaCallModel = [LIMMediaCallSingleModel mj_objectWithKeyValues:jsonContent];
        NSString *callMode;
        if (mediaCallModel.mode == 0) {
            //视频通话
            callMode = [NSString stringWithFormat:@"[%@]", LanguageToolMatch(@"视频通话")];
        } else {
            //语音通话
            callMode = [NSString stringWithFormat:@"[%@]", LanguageToolMatch(@"语音通话")];
        }
        sessionAttStr = [[NSMutableAttributedString alloc] initWithString:callMode];
        /*
        if ([mediaCallModel.discard_reason isEqualToString:@"disconnect"]) {
            //通话中断、服务器强制挂断
            //告知 邀请者 展示 如：通话中断
            //告知 被邀请者 展示 如：通话中断
            if ([mediaCallModel.from_id isEqualToString:UserManager.userInfo.userUID]) {
                //我是 邀请者
            }else {
                //我是 被邀请者
            }
            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:@"通话中断"];
            
        }else if ([mediaCallModel.discard_reason isEqualToString:@"missed"]) {
            //呼叫超时(被邀请者 长时间未响应 邀请)
            //告知 邀请者 展示 如：对方无应答
            //告知 被邀请者 展示 如：超时未应答
            if ([mediaCallModel.from_id isEqualToString:UserManager.userInfo.userUID]) {
                //我是 邀请者
                sessionAttStr = [[NSMutableAttributedString alloc] initWithString:@"对方无应答"];
            }else {
                //我是 被邀请者
                sessionAttStr = [[NSMutableAttributedString alloc] initWithString:@"超时未应答"];
            }
            
        }else if ([mediaCallModel.discard_reason isEqualToString:@"cancel"]) {
            //呼叫取消(邀请者 在 被邀请者 接受之前 取消邀请)
            //告知 邀请者 展示 如：通话已取消
            //告知 被邀请者 展示 如：对方已取消
            if ([mediaCallModel.from_id isEqualToString:UserManager.userInfo.userUID]) {
                //我是 邀请者
                sessionAttStr = [[NSMutableAttributedString alloc] initWithString:@"通话已取消"];
            }else {
                //我是 被邀请者
                sessionAttStr = [[NSMutableAttributedString alloc] initWithString:@"对方已取消"];
            }
        }else if ([mediaCallModel.discard_reason isEqualToString:@"refused"]) {
            //呼叫拒绝(被邀请者 拒绝 邀请)
            //告知 邀请者 展示 如：对方已拒绝
            //告知 被邀请者 展示 如：已拒绝
            if ([mediaCallModel.from_id isEqualToString:UserManager.userInfo.userUID]) {
                //我是 邀请者
                sessionAttStr = [[NSMutableAttributedString alloc] initWithString:@"对方已拒绝"];
            }else {
                //我是 被邀请者
                sessionAttStr = [[NSMutableAttributedString alloc] initWithString:@"已拒绝"];
            }
            
        }else if ([mediaCallModel.discard_reason isEqualToString:@"accept"]) {
            //呼叫已接听(被邀请者 已接受 邀请，被邀请者的其他设备会收到此消息)
            //告知 被邀请者 展示 如：已在其他设备接听
            if ([mediaCallModel.from_id isEqualToString:UserManager.userInfo.userUID]) {
                //我是 邀请者 不会收到此消息
            }else {
                //我是 被邀请者
                sessionAttStr = [[NSMutableAttributedString alloc] initWithString:@"已在其他设备接听"];
            }
        }else {
            //通话正常挂断
            //告知 邀请者 展示 如：10:00通话
            //告知 被邀请者 展示 如：10:00通话
            NSString *textContentStr;
            if ([mediaCallModel.from_id isEqualToString:UserManager.userInfo.userUID]) {
                //我是 邀请者
                textContentStr = [NSString stringWithFormat:@"%@ 通话结束", [NSString getTimeLength:mediaCallModel.duration]];
            } else {
                //我是 被邀请者
                textContentStr = [NSString stringWithFormat:@"通话结束 %@", [NSString getTimeLength:mediaCallModel.duration]];
            }
            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:textContentStr];
        }
        */
    }else if (customEvent.type == 103) {
        LIMMediaCallGroupParticipantAction *actionModel = [LIMMediaCallGroupParticipantAction mj_objectWithKeyValues:jsonContent];
        NSString *callMode;
        if (actionModel.mode == 0) {
            callMode = LanguageToolMatch(@"视频通话");
        }else {
            callMode = LanguageToolMatch(@"语音通话");
        }
        
        LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:actionModel.user_id groupID:actionModel.chat_id];
        if (groupMemberModel) {
            if ([actionModel.action isEqualToString:@"new"]) {
                sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"%@发起了%@"), groupMemberModel.showName, callMode]];
            } else if ([actionModel.action isEqualToString:@"discard"]) {
                sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"%@已经结束"), callMode]];
            }
        } else {
            if ([actionModel.action isEqualToString:@"new"]) {
                sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"群%@开始了"), callMode]];
            } else if ([actionModel.action isEqualToString:@"discard"]) {
                sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"%@已经结束"), callMode]];
            }
        }
    }
    return sessionAttStr;
}
#pragma mark - 根据消息内容，确定即构音视频通话相关的提示信息
+ (NSMutableAttributedString *)dealChatMessageForNetCallMessage:(NoaIMChatMessageModel *)chatMessage{
    NSMutableAttributedString *sessionAttStr = [[NSMutableAttributedString alloc] initWithString:@""];
    NSString *callType;
    if (chatMessage.netCallType == 1) {
        //语音通话
        callType = LanguageToolMatch(@"语音通话");
    }else {
        //视频通话
        callType = LanguageToolMatch(@"视频通话");
    }
    
    if (chatMessage.netCallChatType == 1) {
        //单聊
        sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"[%@]", callType]];
    }else {
        //群聊
        LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:chatMessage.netCallRoomCreateUser groupID:chatMessage.toID];
        if (groupMemberModel) {
            if (chatMessage.netCallStatus == 1) {
                sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"%@发起了%@"), groupMemberModel.showName, callType]];
            } else if (chatMessage.netCallStatus == 11) {
                sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"%@已经结束"), callType]];
            }
        } else {
            if (chatMessage.netCallStatus == 1) {
                sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"群%@开始了"), callType]];
            } else if (chatMessage.netCallStatus == 11) {
                sessionAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"%@已经结束"), callType]];
            }
        }
    }
    
    return sessionAttStr;
}

#pragma mark - 字体 颜色 配置
+ (void)configAttributedString:(NSMutableAttributedString *)sessionAttStr fontNum:(NSInteger)fontNum {


    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 2;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;//NSLineBreakByCharWrapping;
    
    sessionAttStr.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        
        NSMutableAttributedString * it = itself;
        NSDictionary *dict = @{
            NSFontAttributeName:FONTR(fontNum),
            NSForegroundColorAttributeName:COLOR_99,
            NSParagraphStyleAttributeName:paragraphStyle,
        };
        switch (themeIndex) {
            case 1:
            {
                //暗黑
                dict = @{
                    NSFontAttributeName:FONTR(fontNum),
                    NSForegroundColorAttributeName:COLOR_99_DARK,
                    NSParagraphStyleAttributeName:paragraphStyle,
//                    NSKernAttributeName:@(1)
                };
            }
                break;
                
            default:
            {
                dict = @{
                    NSFontAttributeName:FONTR(fontNum),
                    NSForegroundColorAttributeName:COLOR_99,
                    NSParagraphStyleAttributeName:paragraphStyle,
//                    NSKernAttributeName:@(1)
                };
            }
                break;
        }
        [it addAttributes:dict range:NSMakeRange(0, it.length)];
    };
    
    
}
#pragma mark - 富文本图片
+ (NSAttributedString *)attributedStringWithImage:(NSString *)imageName {
    //s_cell_readed / s_cell_unread
    NSAttributedString *stringImage;
    if (![NSString isNil:imageName]) {
        NSTextAttachment *attchImage = [[NSTextAttachment alloc] init];
        attchImage.image = [UIImage imageNamed:imageName];
        attchImage.bounds = CGRectMake(0, roundf(FONTR(12).capHeight - DWScale(10))/2.f, DWScale(10), DWScale(10));
        stringImage = [NSAttributedString attributedStringWithAttachment:attchImage];
    } else {
        NSTextAttachment *attchImage = [[NSTextAttachment alloc] init];
        attchImage.image = [[UIImage alloc] init];
        attchImage.bounds = CGRectMake(0, roundf(FONTR(12).capHeight - DWScale(10))/2.f, 0, 0);
        stringImage = [NSAttributedString attributedStringWithAttachment:attchImage];
    }
    return stringImage;
}


#pragma mark - <<<<<<根据群发助手消息内容，确定回话列表展示内容>>>>>>
+ (NSMutableAttributedString *)getSessionLatestMassMessageAttributedStringWith:(LingIMSessionModel *)sessionModel {
    LIMMassMessageModel *massMessage = sessionModel.sessionLatestMassMessage;
    
    NSMutableAttributedString *sessionAttStr = [[NSMutableAttributedString alloc] initWithString:@""];
    
    if (massMessage) {
        if (massMessage.mtype == 0) {
            //文本
            sessionAttStr = [[NoaChatInputEmojiManager sharedManager] attributedString:massMessage.bodyModel.content imageRect:CGRectMake(0, -4, 18, 18)];
            [self configAttributedString:sessionAttStr fontNum:12];
        } else if (massMessage.mtype == 1){
            //图片
            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"[图片]")];
            [self configAttributedString:sessionAttStr fontNum:12];
        } else if (massMessage.mtype == 2) {
            //视频
            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"[视频]")];
            [self configAttributedString:sessionAttStr fontNum:12];
        } else if (massMessage.mtype == 5){
            //文件
            sessionAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"[文件]")];
            [self configAttributedString:sessionAttStr fontNum:12];
        }
        
    }else {
        sessionAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"[暂无新消息]")];
        [self configAttributedString:sessionAttStr fontNum:12];
    }
    
    return sessionAttStr;
}



#pragma mark - <<<<<<根据聊天消息内容确定消息记录里展示内容>>>>>>
+ (NSMutableAttributedString *)getMessageRecordAttributedStringWith:(IMChatMessage * _Nullable)imChatMessage {
    
    NSMutableAttributedString *recordMsgAttStr = [[NSMutableAttributedString alloc] initWithString:@""];
    
    if (imChatMessage) {
        if (imChatMessage.mType == IMChatMessage_MessageType_TextMessage) {
            recordMsgAttStr = [[NoaChatInputEmojiManager sharedManager] attributedString:[NSString stringWithFormat:@"%@：%@", imChatMessage.nick, imChatMessage.textMessage.content] imageRect:CGRectMake(0, -4, 18, 18)];
            [self configAttributedString:recordMsgAttStr fontNum:10];
        } else if (imChatMessage.mType == IMChatMessage_MessageType_ImageMessage){
            recordMsgAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@：%@", imChatMessage.nick, LanguageToolMatch(@"[图片]")]];
            [self configAttributedString:recordMsgAttStr fontNum:10];
        } else if (imChatMessage.mType == IMChatMessage_MessageType_StickersMessage){
            recordMsgAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@：%@", imChatMessage.nick, LanguageToolMatch(@"[表情]")]];
            [self configAttributedString:recordMsgAttStr fontNum:10];
        } else if (imChatMessage.mType == IMChatMessage_MessageType_GameStickersMessage){
            recordMsgAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@：%@", imChatMessage.nick, LanguageToolMatch(@"[表情]")]];
            [self configAttributedString:recordMsgAttStr fontNum:10];
        } else if (imChatMessage.mType == IMChatMessage_MessageType_VoiceMessage){
            recordMsgAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@：%@", imChatMessage.nick, LanguageToolMatch(@"[语音]")]];
            [self configAttributedString:recordMsgAttStr fontNum:10];
        } else if (imChatMessage.mType == IMChatMessage_MessageType_FileMessage){
            recordMsgAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@：%@", imChatMessage.nick, LanguageToolMatch(@"[文件]")]];
            [self configAttributedString:recordMsgAttStr fontNum:10];
        } else if (imChatMessage.mType == IMChatMessage_MessageType_VideoMessage) {
            recordMsgAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@：%@", imChatMessage.nick, LanguageToolMatch(@"[视频]")]];
            [self configAttributedString:recordMsgAttStr fontNum:10];
        } else if (imChatMessage.mType == IMChatMessage_MessageType_CardMessage) {
            recordMsgAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@：%@%@", imChatMessage.nick, LanguageToolMatch(@"[个人名片]"), imChatMessage.cardMessage.name]];
            [self configAttributedString:recordMsgAttStr fontNum:10];
        } else if (imChatMessage.mType == IMChatMessage_MessageType_Geomessage) {
            recordMsgAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@：%@%@", imChatMessage.nick, LanguageToolMatch(@"[位置]"), imChatMessage.geoMessage.name]];
            [self configAttributedString:recordMsgAttStr fontNum:10];
        } else if (imChatMessage.mType == IMChatMessage_MessageType_ForwardMessage) {
            recordMsgAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@：%@%@", imChatMessage.nick, LanguageToolMatch(@"[会话记录]"), imChatMessage.forwardMessage.title]];
            [self configAttributedString:recordMsgAttStr fontNum:10];
        }  else if (imChatMessage.mType == IMChatMessage_MessageType_AtMessage) {
            NSString *showContent = [NSString stringWithString:imChatMessage.atMessage.content];
            NSMutableDictionary *atUsersDict = [NSMutableDictionary dictionary];
            for (AtInfo *atInfo in imChatMessage.atMessage.atInfoArray) {
                [atUsersDict setValue:atInfo.uNick forKey:atInfo.uId];
            }
            NSArray *atKeyArr = [atUsersDict allKeys];
            for (NSString *atKey in atKeyArr) {
                if ([atKey isEqualToString:UserManager.userInfo.userUID]) {
                    if ([imChatMessage.from isEqualToString:UserManager.userInfo.userUID]) {
                        showContent = [showContent stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"\v%@\v", atKey] withString:LanguageToolMatch(@"@我自己")];
                    } else {
                        showContent = [showContent stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"\v%@\v", atKey] withString:LanguageToolMatch(@"@我")];
                    }
                } else if ([atKey isEqualToString:@"-1"]) {
                    showContent = [showContent stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"\v%@\v", atKey] withString:LanguageToolMatch(@"@所有人")];
                } else {
                    LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:atKey];
                    if(friendModel){
                        //是我的好友，展示好友showName
                        showContent = [showContent stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"\v%@\v", atKey] withString:[NSString stringWithFormat:@"@%@", friendModel.showName]];
                    }else {
                        LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:atKey groupID:imChatMessage.to];
                        if (groupMemberModel) {
                            //查询到了群成员信息，展示群成员的showName
                            showContent = [showContent stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"\v%@\v", atKey] withString:[NSString stringWithFormat:@"@%@", groupMemberModel.showName]];
                        }else {
                            showContent = [showContent stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"\v%@\v", atKey] withString:[NSString stringWithFormat:@"@%@", [atUsersDict objectForKey:atKey]]];
                        }
                    }
                }
            }
            
            NSString *atContetnStr = [NSString stringWithString:showContent.length > 0 ? showContent : @""];
            recordMsgAttStr = [[NoaChatInputEmojiManager sharedManager] attributedString:[NSString stringWithFormat:@"%@：%@", imChatMessage.nick, atContetnStr] imageRect:CGRectMake(0, -4, 18, 18)];
            [self configAttributedString:recordMsgAttStr fontNum:10];
        }
    } else {
        recordMsgAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"[未知]")];
        [self configAttributedString:recordMsgAttStr fontNum:10];
    }
    
    return recordMsgAttStr;
}

#pragma mark - <<<<<<展示会话的草稿内容>>>>>>
+ (NSMutableAttributedString *)getSessionDraftContentAttributedStringWith:(LingIMSessionModel *)sessionModel {
    NSMutableAttributedString *sessionAttStr;
    
    if (sessionModel.draftDict.count > 0) {
        //草稿内容
        NSString *draftContent = [sessionModel.draftDict objectForKeySafe:@"draftContent"];
        sessionAttStr = [[NoaChatInputEmojiManager sharedManager] attributedString:draftContent imageRect:CGRectMake(0, -4, 18, 18)];
        [self configAttributedString:sessionAttStr fontNum:12];
        
        NSMutableAttributedString *atStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"[草稿]")];
        NSDictionary *dict = @{NSFontAttributeName:FONTR(12), NSForegroundColorAttributeName:COLOR_F93A2F};
        [atStr addAttributes:dict range:NSMakeRange(0, atStr.length)];
        [sessionAttStr insertAttributedString:atStr atIndex:0];
    }else {
        sessionAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"[暂无新消息]")];
        [self configAttributedString:sessionAttStr fontNum:12];
    }
    
    
    return sessionAttStr;
}

/// 展示会话的最新消息或提醒的默认样式
/// @param sessionLastContent 会话展示的最新消息内容
+ (NSMutableAttributedString *)getSessionDefaultLastMsgContentAttributedStringWith:(NSString * _Nullable)sessionLastContent {
    
    NSMutableAttributedString *sessionAttStr = [[NSMutableAttributedString alloc] initWithString:sessionLastContent];
    [self configAttributedString:sessionAttStr fontNum:12];
    
    return sessionAttStr;
}

@end
