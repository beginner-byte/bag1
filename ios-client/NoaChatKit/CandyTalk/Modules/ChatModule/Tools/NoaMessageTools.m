//
//  NoaMessageTools.m
//  NoaKit
//
//  Created by Candy on 2026/10/23.
//

#import "NoaMessageTools.h"

@implementation NoaMessageTools

#pragma mark - 获得消息的唯一标识
+ (NSString *)getMessageID {
    //iOS6出现的方法，每次调用，都会产生一个新值
    NSString *uuid = [[NSUUID UUID] UUIDString];//973FC752-75EA-4217-BEB3-CF5DD0610FC2
    uuid = [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    uuid = [uuid lowercaseString];
    return uuid;
}

/** 将数据库存储的LingIMChatMessageModel 转换为 IMMessage 不改变任何数据，用户消息多选-合并转发*/
+ (IMChatMessage *)getIMChatMessageFromLingIMChatMessageModelToMergeForward:(NoaIMChatMessageModel *)message {
    if (message) {
        IMChatMessage *chatMessage = [[IMChatMessage alloc] init];
        chatMessage.msgId = message.msgID;
        chatMessage.from = message.fromID;
        chatMessage.nick = message.fromNickname;
        chatMessage.icon = message.fromIcon;
        chatMessage.isAck = YES;
        chatMessage.isEncry = YES;
        chatMessage.sendTime = message.sendTime;
        chatMessage.to = message.toID;
        if (message.chatType == CIMSessionTypeSingle) {
            //单聊
            chatMessage.cType = ChatType_SingleChat;
        } else {
            //群聊
            chatMessage.cType = ChatType_GroupChat;
        }
        switch (message.messageType) {
            case IMChatMessage_MessageType_TextMessage:
            {
                chatMessage.mType = IMChatMessage_MessageType_TextMessage;
                TextMessage *textMessage = [[TextMessage alloc] init];
                textMessage.content = message.textContent;
                textMessage.translate = @"";
                chatMessage.textMessage = textMessage;
            }
                break;
            case IMChatMessage_MessageType_ImageMessage:
            {
                chatMessage.mType = IMChatMessage_MessageType_ImageMessage;
                ImageMessage *imageMessage = [[ImageMessage alloc] init];
                imageMessage.height = message.imgHeight ;
                imageMessage.width = message.imgWidth;
                imageMessage.size = message.imgSize;
                imageMessage.name = message.imgName;
                imageMessage.iImg = message.thumbnailImg;
                imageMessage.ext = message.imgExt;
                chatMessage.imageMessage = imageMessage;
            }
                break;
            case IMChatMessage_MessageType_StickersMessage:
            {
                chatMessage.mType = IMChatMessage_MessageType_StickersMessage;
                StickersMessage *stickersMessage = [[StickersMessage alloc] init];
                stickersMessage.height = message.stickersHeight ;
                stickersMessage.width = message.stickersWidth;
                stickersMessage.size = message.stickersSize;
                stickersMessage.name = message.stickersName;
                stickersMessage.id_p = message.stickersId;
                stickersMessage.thumbImg = message.stickersThumbnailImg;
                stickersMessage.img = message.stickersImg;
                stickersMessage.isStickersSet = message.isStickersSet;
                stickersMessage.ext = message.stickersExt;
                chatMessage.stickersMessage = stickersMessage;
            }
                break;
            case IMChatMessage_MessageType_GameStickersMessage:
            {
                chatMessage.mType = IMChatMessage_MessageType_GameStickersMessage;
                GameStickersMessage *gameStickersMessage = [[GameStickersMessage alloc] init];
                gameStickersMessage.type = message.gameSticekersType ;
                gameStickersMessage.result = message.gameStickersResut;
                gameStickersMessage.ext = message.gameStickersExt;
                chatMessage.gameStickersMessage = gameStickersMessage;
            }
                break;
            case IMChatMessage_MessageType_VideoMessage:
            {
                chatMessage.mType = IMChatMessage_MessageType_VideoMessage;
                VideoMessage *videoMessage = [[VideoMessage alloc] init];
                videoMessage.cImg =  message.videoCover;
                videoMessage.cHeight = message.videoCoverH;
                videoMessage.cWidth = message.videoCoverW;
                videoMessage.length =  message.videoLength;
                videoMessage.name = message.videoName;
                videoMessage.ext = message.videoExt;
                chatMessage.videoMessage = videoMessage;
            }
                break;
            case IMChatMessage_MessageType_AtMessage:
            {
                chatMessage.mType = IMChatMessage_MessageType_TextMessage;
                TextMessage *textMessage = [[TextMessage alloc] init];
                textMessage.content = [NoaMessageTools forwardMessageAtContenTranslateToShowContent:message.atContent atUsersDictList:message.atUsersInfoList];
                textMessage.translate = @"";
                chatMessage.textMessage = textMessage;
            }
                break;
            case IMChatMessage_MessageType_VoiceMessage:
            {
                chatMessage.mType = IMChatMessage_MessageType_VoiceMessage;
                VoiceMessage *voiceMessage = [[VoiceMessage alloc] init];
                voiceMessage.name = message.voiceName;
                voiceMessage.length = message.voiceLength;
                chatMessage.voiceMessage = voiceMessage;
            }
                break;
            case IMChatMessage_MessageType_FileMessage:
            {
                chatMessage.mType = IMChatMessage_MessageType_FileMessage;
                FileMessage *fileMessage = [[FileMessage alloc] init];
                fileMessage.size =  message.fileSize;
                fileMessage.name = message.fileName;
                fileMessage.ext = message.fileExt;
                fileMessage.path = message.filePath;
                fileMessage.type = message.fileType;
                chatMessage.fileMessage = fileMessage;
            }
                break;
            case IMChatMessage_MessageType_CardMessage:
            {
                chatMessage.mType = IMChatMessage_MessageType_CardMessage;
                CardMessage *cardMessage = [[CardMessage alloc] init];
                cardMessage.URL =  message.cardUrl;
                cardMessage.name = message.cardName;
                cardMessage.userId = message.cardUserId;
                cardMessage.headPicURL = message.cardHeadPicUrl;
                cardMessage.nickName = message.cardNickName;
                cardMessage.userName = message.cardUserName;
                cardMessage.ext = message.cardExt;
                chatMessage.cardMessage = cardMessage;
            }
                break;
            case IMChatMessage_MessageType_Geomessage:
            {
                chatMessage.mType = IMChatMessage_MessageType_Geomessage;
                GEOMessage *geoMessage = [[GEOMessage alloc] init];
                geoMessage.lng =  message.geoLng;
                geoMessage.lat = message.geoLat;
                geoMessage.name = message.geoName;
                geoMessage.cImg = message.geoImg;
                geoMessage.cHeight = message.geoImgHeight;
                geoMessage.cWidth = message.geoImgWidth;
                geoMessage.ext = message.geoExt;
                geoMessage.details = message.geoDetails;
                chatMessage.geoMessage = geoMessage;
            }
                break;
            case IMChatMessage_MessageType_ForwardMessage:
            {
                chatMessage.mType = IMChatMessage_MessageType_ForwardMessage;
                chatMessage.forwardMessage = message.forwardMessage;
            }
                break;
            default:
            {
                TextMessage *textMessage = [[TextMessage alloc] init];
                textMessage.content = message.textContent;
                chatMessage.textMessage = textMessage;
            }
                break;
        }
        //等转发消息接口成功后,添加进数据库
        return chatMessage;
    } else {
        return nil;
    }
}

/** 将数据库存储的LingIMChatMessageModel 转换为 IMMessage*/
+ (IMMessage *)getIMMessageFromLingIMChatMessageModel:(NoaIMChatMessageModel *)message withChatObject:(NoaBaseUserModel *)chatObject index:(int)index {
    if (message) {
        IMMessage *imMessage = [[IMMessage alloc] init];
        imMessage.dataType = IMMessage_DataType_ImchatMessage;
        
        IMChatMessage *chatMessage = [[IMChatMessage alloc] init];
        chatMessage.msgId = [NoaMessageTools getMessageID];
        chatMessage.from = UserManager.userInfo.userUID;
        chatMessage.nick = UserManager.userInfo.nickname;
        chatMessage.isAck = YES;
        chatMessage.isEncry = YES;
        chatMessage.sendTime = [NSDate getCurrentServerMillisecondTime] + index;
        chatMessage.to = chatObject.userId;
        chatMessage.cType = (chatObject.isGroup ? ChatType_GroupChat : ChatType_SingleChat);
    
        switch (message.messageType) {
            case IMChatMessage_MessageType_TextMessage:
            {
                chatMessage.mType = IMChatMessage_MessageType_TextMessage;
                TextMessage *textMessage = [[TextMessage alloc] init];
                textMessage.content = message.textContent;
                textMessage.translate = @"";
                chatMessage.textMessage = textMessage;
            }
                break;
            case IMChatMessage_MessageType_ImageMessage:
            {
                chatMessage.mType = IMChatMessage_MessageType_ImageMessage;
                ImageMessage *imageMessage = [[ImageMessage alloc] init];
                imageMessage.height = message.imgHeight ;
                imageMessage.width = message.imgWidth;
                imageMessage.size = message.imgSize;
                imageMessage.name = message.imgName;
                imageMessage.iImg = message.thumbnailImg;
                imageMessage.ext = message.imgExt;
                chatMessage.imageMessage = imageMessage;
            }
                break;
            case IMChatMessage_MessageType_StickersMessage:
            {
                chatMessage.mType = IMChatMessage_MessageType_StickersMessage;
                StickersMessage *stickersMessage = [[StickersMessage alloc] init];
                stickersMessage.height = message.stickersHeight ;
                stickersMessage.width = message.stickersWidth;
                stickersMessage.size = message.stickersSize;
                stickersMessage.name = message.stickersName;
                stickersMessage.id_p = message.stickersId;
                stickersMessage.thumbImg = message.stickersThumbnailImg;
                stickersMessage.img = message.stickersImg;
                stickersMessage.isStickersSet = message.isStickersSet;
                stickersMessage.ext = message.stickersExt;
                chatMessage.stickersMessage = stickersMessage;
            }
                break;
            case IMChatMessage_MessageType_GameStickersMessage:
            {
                chatMessage.mType = IMChatMessage_MessageType_GameStickersMessage;
                GameStickersMessage *gameStickersMessage = [[GameStickersMessage alloc] init];
                gameStickersMessage.type = message.gameSticekersType ;
                gameStickersMessage.result = message.gameStickersResut;
                gameStickersMessage.ext = message.gameStickersExt;
                chatMessage.gameStickersMessage = gameStickersMessage;
            }
                break;
            case IMChatMessage_MessageType_VideoMessage:
            {
                chatMessage.mType = IMChatMessage_MessageType_VideoMessage;
                VideoMessage *videoMessage = [[VideoMessage alloc] init];
                videoMessage.cImg =  message.videoCover;
                videoMessage.cHeight = message.videoCoverH;
                videoMessage.cWidth = message.videoCoverW;
                videoMessage.length =  message.videoLength;
                videoMessage.name = message.videoName;
                videoMessage.ext = message.videoExt;
                chatMessage.videoMessage = videoMessage;
            }
                break;
            case IMChatMessage_MessageType_AtMessage:
            {
                chatMessage.mType = IMChatMessage_MessageType_TextMessage;
                TextMessage *textMessage = [[TextMessage alloc] init];
                textMessage.content = [NoaMessageTools forwardMessageAtContenTranslateToShowContent:message.atContent atUsersDictList:message.atUsersInfoList];
                textMessage.translate = @"";
                chatMessage.textMessage = textMessage;
            }
                break;
            case IMChatMessage_MessageType_VoiceMessage:
            {
                chatMessage.mType = IMChatMessage_MessageType_VoiceMessage;
                VoiceMessage *voiceMessage = [[VoiceMessage alloc] init];
                voiceMessage.name = message.voiceName;
                voiceMessage.length = message.voiceLength;
                chatMessage.voiceMessage = voiceMessage;
            }
                break;
            case IMChatMessage_MessageType_FileMessage:
            {
                chatMessage.mType = IMChatMessage_MessageType_FileMessage;
                FileMessage *fileMessage = [[FileMessage alloc] init];
                fileMessage.size =  message.fileSize;
                fileMessage.name = message.fileName;
                fileMessage.ext = message.fileExt;
                fileMessage.path = message.filePath;
                fileMessage.type = message.fileType;
                chatMessage.fileMessage = fileMessage;
            }
                break;
            case IMChatMessage_MessageType_CardMessage:
            {
                chatMessage.mType = IMChatMessage_MessageType_CardMessage;
                CardMessage *cardMessage = [[CardMessage alloc] init];
                cardMessage.URL =  message.cardUrl;
                cardMessage.name = message.cardName;
                cardMessage.userId = message.cardUserId;
                cardMessage.headPicURL = message.cardHeadPicUrl;
                cardMessage.nickName = message.cardNickName;
                cardMessage.userName = message.cardUserName;
                cardMessage.ext = message.cardExt;
                chatMessage.cardMessage = cardMessage;
            }
                break;
            case IMChatMessage_MessageType_Geomessage:
            {
                chatMessage.mType = IMChatMessage_MessageType_Geomessage;
                GEOMessage *geoMessage = [[GEOMessage alloc] init];
                geoMessage.lng =  message.geoLng;
                geoMessage.lat = message.geoLat;
                geoMessage.name = message.geoName;
                geoMessage.cImg = message.geoImg;
                geoMessage.cHeight = message.geoImgHeight;
                geoMessage.cWidth = message.geoImgWidth;
                geoMessage.ext = message.geoExt;
                geoMessage.details = message.geoDetails;
                chatMessage.geoMessage = geoMessage;
            }
                break;
            case IMChatMessage_MessageType_ForwardMessage:
            {
                chatMessage.mType = IMChatMessage_MessageType_ForwardMessage;
                ForwardMessage *forwardMessage = [[ForwardMessage alloc] init];
                forwardMessage.type =  message.forwardMessage.type;
                forwardMessage.title = message.forwardMessage.title;
                forwardMessage.messageListArray = message.forwardMessage.messageListArray;
                chatMessage.forwardMessage = message.forwardMessage;
            }
                break;
            default:
            {
                TextMessage *textMessage = [[TextMessage alloc] init];
                textMessage.content = message.textContent;
                chatMessage.textMessage = textMessage;
            }
                break;
        }
        //等转发消息接口成功后,添加进数据库
        imMessage.chatMessage = chatMessage;
        return imMessage;
    } else {
        return nil;
    }
}

/** 将数据库存储的LingIMChatMessageModel 转换为 IMMessage*/
+ (IMMessage *)getIMMessageFromCollection:(NoaMyCollectionItemModel *)collectionMsg withChatType:(CIMChatType)chatType chatSessionId:(NSString *)chatSession {
    if (collectionMsg) {
        IMMessage *imMessage = [[IMMessage alloc] init];
        imMessage.dataType = IMMessage_DataType_ImchatMessage;
        
        IMChatMessage *chatMessage = [[IMChatMessage alloc] init];
        chatMessage.msgId = [NoaMessageTools getMessageID];
        chatMessage.from = UserManager.userInfo.userUID;
        chatMessage.nick = UserManager.userInfo.nickname;
        chatMessage.isAck = YES;
        chatMessage.isEncry = YES;
        chatMessage.sendTime = [NSDate getCurrentServerMillisecondTime];
        chatMessage.to = chatSession;
        chatMessage.cType = (chatType == CIMChatType_SingleChat ? ChatType_SingleChat : ChatType_GroupChat);
        
        switch (collectionMsg.mtype) {
            case IMChatMessage_MessageType_TextMessage:
            case IMChatMessage_MessageType_AtMessage:
            {
                chatMessage.mType = IMChatMessage_MessageType_TextMessage;
                TextMessage *textMessage = [[TextMessage alloc] init];
                textMessage.content = collectionMsg.body.content;
                textMessage.translate = @"";
                chatMessage.textMessage = textMessage;
            }
                break;
            case IMChatMessage_MessageType_ImageMessage:
            {
                chatMessage.mType = IMChatMessage_MessageType_ImageMessage;
                ImageMessage *imageMessage = [[ImageMessage alloc] init];
                imageMessage.height = collectionMsg.body.height;
                imageMessage.width = collectionMsg.body.width;
                imageMessage.size = collectionMsg.body.size;
                imageMessage.name = collectionMsg.body.name;
                imageMessage.iImg = collectionMsg.body.iImg;
                imageMessage.ext = collectionMsg.body.ext;
                chatMessage.imageMessage = imageMessage;
            }
                break;
            case IMChatMessage_MessageType_VideoMessage:
            {
                chatMessage.mType = IMChatMessage_MessageType_VideoMessage;
                VideoMessage *videoMessage = [[VideoMessage alloc] init];
                videoMessage.cImg =  collectionMsg.body.cImg;
                videoMessage.cHeight = collectionMsg.body.cHeight;
                videoMessage.cWidth = collectionMsg.body.cWidth;
                videoMessage.length =  collectionMsg.body.length;
                videoMessage.name = collectionMsg.body.name;
                videoMessage.ext = collectionMsg.body.ext;
                chatMessage.videoMessage = videoMessage;
            }
                break;
            case IMChatMessage_MessageType_FileMessage:
            {
                chatMessage.mType = IMChatMessage_MessageType_FileMessage;
                FileMessage *fileMessage = [[FileMessage alloc] init];
                fileMessage.size =  collectionMsg.body.size;
                fileMessage.name = collectionMsg.body.name;
                fileMessage.ext = collectionMsg.body.ext;
                fileMessage.path = collectionMsg.body.path;
                fileMessage.type = collectionMsg.body.type;
                chatMessage.fileMessage = fileMessage;
            }
                break;
            case IMChatMessage_MessageType_Geomessage:
            {
                chatMessage.mType = IMChatMessage_MessageType_Geomessage;
                GEOMessage *geoMessage = [[GEOMessage alloc] init];
                geoMessage.lng =  collectionMsg.body.lng;
                geoMessage.lat = collectionMsg.body.lat;
                geoMessage.name = collectionMsg.body.name;
                geoMessage.cImg = collectionMsg.body.cImg;
                geoMessage.cHeight = collectionMsg.body.cHeight;
                geoMessage.cWidth = collectionMsg.body.cWidth;
                geoMessage.ext = collectionMsg.body.ext;
                geoMessage.details = collectionMsg.body.details;
                chatMessage.geoMessage = geoMessage;
            }
                break;
            default:
            {
                TextMessage *textMessage = [[TextMessage alloc] init];
                textMessage.content = collectionMsg.body.content;
                chatMessage.textMessage = textMessage;
            }
                break;
        }
        //等转发消息接口成功后,添加进数据库
        imMessage.chatMessage = chatMessage;
        return imMessage;
    } else {
        return nil;
    }
}

+ (void)clearChatLocalImgAndVideoFromSessionId:(NSString *)sessionID {
    NSError *error = nil;
    
    //清除图片
    NSString *openImagePath = [NSString stringWithFormat:@"OpenIM/Image/%@-%@", UserManager.userInfo.userUID, sessionID];
    NSString *imageDiectoryPath = [NSTemporaryDirectory() stringByAppendingPathComponent:openImagePath];
    NSArray *subImagePathArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:imageDiectoryPath error:nil];

    NSString *imgFilePath = nil;
    for (NSString *subImgPath in subImagePathArr)
    {
        imgFilePath = [imageDiectoryPath stringByAppendingPathComponent:subImgPath];
        //删除子文件夹
        [[NSFileManager defaultManager] removeItemAtPath:imgFilePath error:&error];
    }
    
    //清除视频
    NSString *openVideoPath = [NSString stringWithFormat:@"OpenIM/Video/%@-%@", UserManager.userInfo.userUID, sessionID];
    NSString *imVideoDiectoryPath = [NSTemporaryDirectory() stringByAppendingPathComponent:openVideoPath];
    NSArray *subVideoPathArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:imVideoDiectoryPath error:nil];

    NSString *videoFilePath = nil;
    for (NSString *subVideoPath in subVideoPathArr)
    {
        videoFilePath = [imVideoDiectoryPath stringByAppendingPathComponent:subVideoPath];
        //删除子文件夹
        [[NSFileManager defaultManager] removeItemAtPath:videoFilePath error:&error];
    }
    
    //清除语音
    NSString *openVoicePath = [NSString stringWithFormat:@"OpenIM/Voice/%@-%@", UserManager.userInfo.userUID, sessionID];
    NSString *imVoiceDiectoryPath = [NSTemporaryDirectory() stringByAppendingPathComponent:openVoicePath];
    NSArray *subVoicePathArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:imVoiceDiectoryPath error:nil];

    NSString *voiceFilePath = nil;
    for (NSString *subVoicePath in subVoicePathArr)
    {
        voiceFilePath = [imVoiceDiectoryPath stringByAppendingPathComponent:subVoicePath];
        //删除子文件夹
        [[NSFileManager defaultManager] removeItemAtPath:voiceFilePath error:&error];
    }
    
    //清除文件
    NSString *openFilePath = [NSString stringWithFormat:@"OpenIM/File/%@-%@", UserManager.userInfo.userUID, sessionID];
    NSString *imFileDiectoryPath = [NSTemporaryDirectory() stringByAppendingPathComponent:openFilePath];
    NSArray *subFilePathArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:imFileDiectoryPath error:nil];

    NSString *filePath = nil;
    for (NSString *subFilePath in subFilePathArr)
    {
        filePath = [imVideoDiectoryPath stringByAppendingPathComponent:subFilePath];
        //删除子文件夹
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    }

    //清除SDWebImage缓存数据
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{}];
    
}

/** 将 at消息里的 \vuid\v 转换成 @nickName */
+ (NSString *)atContenTranslateToShowContent:(NSString *)atContentStr atUsersDictList:(NSArray *)atUsersDictList withMessage:(nonnull NoaIMChatMessageModel *)chatMessage isGetShowName:(BOOL)isGetShowName {
    if (![NSString isNil:atContentStr]) {
        // 基于正则定位所有 \vuid\v 片段，倒序逐一替换，避免串联污染
        NSMutableString *mutable = [NSMutableString stringWithString:atContentStr];
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\v([^\\v]+)\\v" options:0 error:&error];
        if (error) {
            return atContentStr;
        }
        NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:atContentStr options:0 range:NSMakeRange(0, atContentStr.length)];
        for (NSInteger i = matches.count - 1; i >= 0; i--) {
            NSTextCheckingResult *match = [matches objectAtIndex:i];
            NSRange uidRange = [match rangeAtIndex:1];
            NSString *uid = [atContentStr substringWithRange:uidRange];

            NSString *replaceText = nil;
            if ([uid isEqualToString:UserManager.userInfo.userUID]) {
                if ([chatMessage.fromID isEqualToString:UserManager.userInfo.userUID]) {
                    replaceText = LanguageToolMatch(@"@我自己");
                } else {
                    replaceText = LanguageToolMatch(@"@我");
                }
            } else if ([uid isEqualToString:@"-1"]) {
                replaceText = LanguageToolMatch(@"@所有人");
            } else {
                NSString *displayName = nil;
                if (isGetShowName) {
                    LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:uid groupID:chatMessage.toID];
                    if (groupMemberModel) {
                        displayName = groupMemberModel.showName;
                    } else {
                        LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:uid];
                        if (friendModel) {
                            displayName = ![NSString isNil:friendModel.remarks] ? friendModel.remarks : friendModel.nickname;
                        }
                    }
                }
                if ([NSString isNil:displayName]) {
                    for (NSDictionary *atUserDic in atUsersDictList) {
                        NSString *key = (NSString *)[[atUserDic allKeys] firstObject];
                        if ([key isEqualToString:uid]) {
                            displayName = (NSString *)[atUserDic objectForKey:key];
                            break;
                        }
                    }
                }
                replaceText = [NSString stringWithFormat:@"@%@", displayName ?: uid];
            }

            if (replaceText) {
                [mutable replaceCharactersInRange:match.range withString:replaceText];
            }
        }
        return [mutable copy];
    } else {
        return @"";
    }
}

/** 将 at消息里的 \vuid\v 转换成 @nickName   只用于转发消息*/
+ (NSString *)forwardMessageAtContenTranslateToShowContent:(NSString *)atContentStr atUsersDictList:(NSArray *)atUsersDictList {
    if (![NSString isNil:atContentStr]) {
        NSString *showContent = [NSString stringWithString:atContentStr];
        for (NSDictionary *atUserDic in atUsersDictList) {
            NSArray *atKeyArr = [atUserDic allKeys];
            NSString *atKey = (NSString *)[atKeyArr firstObject];
            
            if ([atKey isEqualToString:@"-1"]) {
                showContent = [showContent stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"\v%@\v", atKey] withString:LanguageToolMatch(@"@所有人")];
            } else {
                showContent = [showContent stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"\v%@\v", atKey] withString:[NSString stringWithFormat:@"@%@", [atUserDic objectForKey:atKey]]];
            }
        }
        return showContent;
    } else {
        return @"";
    }
}

#pragma mark - 语音的音频文件下载缓存到本地
+ (void)downloadAudioWith:(NSString *)audioUrlStr AudioCachePath:(NSString *)audioCachePath completion:(void (^)(BOOL, NSString * _Nonnull))completion {
    //语音文件缓存路径 /tmp/OpenIM/Voice/...
    NSFileManager *fileManager  = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:audioCachePath];
    if (existed) {
        //语音音频已有缓存
        if (completion) {
            completion(YES, audioCachePath);
        }
    } else {
        //下载语音音频
        NSString *downloadUrl = [audioUrlStr getImageFullString];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.connectionProxyDictionary = @{}; // 关闭系统代理
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://www.baidu.com"] sessionConfiguration:config];
        @try {
            [ZHostTool confighttpSessionManagerCerAndP12Cer:manager isIPAddress:[downloadUrl checkUrlIsIPAddress]];
            
            // 如果confighttpSessionManagerCerAndP12Cer没有设置允许无效证书，重新设置
            AFSecurityPolicy *currentPolicy = manager.securityPolicy;
            if (!currentPolicy.allowInvalidCertificates) {
                AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
                policy.allowInvalidCertificates = YES; // 允许无效证书（包括自签名证书）
                policy.validatesDomainName = NO;       // 不校验证书中的域名
                [manager setSecurityPolicy:policy];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception);
        }
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadUrl]];
        NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            //开始下载
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [NSURL fileURLWithPath:audioCachePath];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            if (completion && !error) {
                completion(YES, audioCachePath);
            } else {
                completion(NO, audioCachePath);
            }
        }];
        [task resume];
    }
}

//将内容 拆分为 翻译内容  + at字符串 + 表情字符串 三部分
+ (void)translationSplit:(NSString *)messageStr
              atUserList:(NSArray *)atUserList
                  finish:(void(^)(NSString * translationString,
                                  NSString * atString,
                                  NSString * emojiString))finish{
    if (messageStr.length > 0) {
        NSMutableString *translationString = [NSMutableString stringWithString:messageStr];
        NSMutableString *atString = [NSMutableString string];
        NSMutableString *emojiString = [NSMutableString string];
        // 先匹配 emoji，避免表情符号的]和@消息的\v紧邻时出现误匹配
        NSError *error;
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:@"\\[[^ \\[\\]]+?\\]"
                                      options:0
                                      error:&error];
        NSArray *matchs = [regex matchesInString:translationString
                                         options:0
                                           range:NSMakeRange(0, [translationString length])];
        //找到所有的 表情字符串 存放起来（倒序处理，避免索引偏移）

        NSMutableArray *emojiArray = [NSMutableArray array];
        for (NSTextCheckingResult *match in matchs) {
            [emojiArray addObject:@{@"text": [translationString safeSubstringWithRange:match.range], @"range": [NSValue valueWithRange:match.range]}];
        }
        // 按位置倒序排序，从后往前移除，避免索引偏移
        [emojiArray sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
            NSRange range1 = [obj1[@"range"] rangeValue];
            NSRange range2 = [obj2[@"range"] rangeValue];
            if (range1.location > range2.location) {
                return NSOrderedAscending;
            } else if (range1.location < range2.location) {
                return NSOrderedDescending;
            }
            return NSOrderedSame;
        }];
        // 从后往前移除表情字符串，避免索引偏移
        for (NSDictionary *emojiDict in emojiArray) {
            NSRange emojiRang = [emojiDict[@"range"] rangeValue];

            [translationString replaceCharactersInRange:emojiRang withString:@""];
            [emojiString appendString:emojiDict[@"text"]];
        }
        //匹配 at信息（在移除表情符号后再移除@信息）
        for (NSDictionary *atUserDic in atUserList) {
            NSArray *atKeyArr = [atUserDic allKeys];
            NSString *atKey = (NSString *)[atKeyArr firstObject];
            
            NSString * atUidStr = [NSString stringWithFormat:@"\v%@\v",atKey];
            if (translationString.length >= atUidStr.length) {
                NSRange atRange = [translationString rangeOfString:atUidStr];
                if (atRange.location != NSNotFound) {
                    [translationString replaceCharactersInRange:atRange withString:@""];
                    [atString appendString:atUidStr];
        }
            }
        }

        [translationString trimString];
        [atString trimString];
        [emojiString trimString];
        finish(translationString,atString,emojiString);
    }else{
        finish(messageStr,nil,nil);
    }
}


//将接口返回的群信息转换成数据库存储的数据类型
+ (LingIMGroupModel *)netWorkGroupModelToDBGroupModel:(LingIMGroup *)groupModel {
    if (groupModel) {
        LingIMGroupModel *localGroupInfo = [[LingIMGroupModel alloc] init];
        localGroupInfo.groupId = groupModel.groupId;//群组ID
        localGroupInfo.groupName = groupModel.groupName;//群组名称
        localGroupInfo.groupAvatar = groupModel.groupAvatar;//群组头像
        localGroupInfo.msgTop = groupModel.msgTop;//群聊会话置顶
        localGroupInfo.msgNoPromt = groupModel.msgNoPromt;//群聊消息免打扰
        localGroupInfo.isGroupChat = groupModel.isGroupChat;//全群是否禁言
        localGroupInfo.isNeedVerify = groupModel.isNeedVerify;//进群是否需要验证
        localGroupInfo.isPrivateChat = groupModel.isPrivateChat;//全群是否禁止私聊
        localGroupInfo.isNetCall = groupModel.isNetCall;//是否开启全员禁止拨打音视频
        localGroupInfo.isMessageInform = groupModel.isMessageInform;//是否开启群提示
        localGroupInfo.groupStatus = groupModel.groupStatus;//群状态0封禁1正常2删除
        localGroupInfo.userGroupRole = groupModel.userGroupRole;//我在本群的角色(0普通成员;1管理员;2群主)
        localGroupInfo.memberCount = groupModel.memberCount;//群成员数量
        localGroupInfo.groupInformStatus = groupModel.groupInformStatus;//开启/关闭群通知：0:关闭群通知 1:开启群通知 (默认为1 开启)
        localGroupInfo.isShowQrCode = groupModel.isShowQrCode;
        localGroupInfo.closeSearchUser = groupModel.closeSearchUser;//关闭搜索用户0:否1:是
        localGroupInfo.canMsgTime = groupModel.canMsgTime;//删除该时间戳之前的本地消息
        localGroupInfo.isActiveEnabled = groupModel.isActiveEnabled;//是否启用群活跃功能（0：关闭，1：开启）
        
        return localGroupInfo;
    }
    return nil;
}

//将数据库存储的数据类型转换成接口返回的群信息
+ (LingIMGroup *)DBGroupModelToNetWorkGroupModel:(LingIMGroupModel *)groupModel {
    if (groupModel) {
        LingIMGroup *groupInfo = [[LingIMGroup alloc] init];
        groupInfo.groupId = groupModel.groupId;//群组ID
        groupInfo.groupName = groupModel.groupName;//群组名称
        groupInfo.groupAvatar = groupModel.groupAvatar;//群组头像
        groupInfo.msgTop = groupModel.msgTop;//群聊会话置顶
        groupInfo.msgNoPromt = groupModel.msgNoPromt;//群聊消息免打扰
        groupInfo.isGroupChat = groupModel.isGroupChat;//全群是否禁言
        groupInfo.isNeedVerify = groupModel.isNeedVerify;//进群是否需要验证
        groupInfo.isPrivateChat = groupModel.isPrivateChat;//全群是否禁止私聊
        groupInfo.isNetCall = groupModel.isNetCall;//是否开启全员禁止拨打音视频
        groupInfo.isMessageInform = groupModel.isMessageInform;//是否开启群提示
        groupInfo.groupStatus = groupModel.groupStatus;//群状态0封禁1正常2删除
        groupInfo.userGroupRole = groupModel.userGroupRole;//我在本群的角色(0普通成员;1管理员;2群主)
        groupInfo.memberCount = groupModel.memberCount;//群成员数量
        groupInfo.groupInformStatus = groupModel.groupInformStatus;//开启/关闭群通知：0:关闭群通知 1:开启群通知 (默认为1 开启)
        groupInfo.isShowQrCode = groupModel.isShowQrCode;
        groupInfo.closeSearchUser = groupModel.closeSearchUser;//关闭搜索用户0:否1:是
        groupInfo.canMsgTime = groupModel.canMsgTime;//删除该时间戳之前的本地消息
        groupInfo.isActiveEnabled = groupModel.isActiveEnabled;//是否启用群活跃功能（0：关闭，1：开启）

        
        return groupInfo;
    }
    return nil;
}

@end
