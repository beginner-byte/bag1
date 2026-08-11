//
//  NoaMessageModel.m
//  NoaKit
//
//  Created by Candy on 2026/9/28.
//

#import "NoaMessageModel.h"
#import "NoaMessageTimeTool.h"
#import "NoaMessageTools.h"
#import "NoaChatInputEmojiManager.h"
#import "NoaFileUploadManager.h"
#import "NoaMessageSendTask.h"

#define AudioMaxWidthSpace 100
#define AudioMaxDuration 60

@interface NoaMessageModel() <ZFileUploadTaskDelegate>

@end

@implementation NoaMessageModel

- (instancetype)initWithMessageModel:(NoaIMChatMessageModel *)message {
    self = [super init];
    if (self) {
        _message = message;
        
        if (_message.messageType == CIMChatMessageType_TextMessage || _message.messageType == CIMChatMessageType_AtMessage) {
            if (_message.translateStatus == CIMTranslateStatusNone) {
                if (![NSString isNil:_message.translateContent] || ![NSString isNil:_message.atTranslateContent] || ![NSString isNil:_message.againTranslateContent] || ![NSString isNil:_message.againAtTranslateContent]) {
                    _message.translateStatus = CIMTranslateStatusSuccess;
                } else {
                    _message.translateStatus = CIMTranslateStatusNone;
                }
            } else {
                if (![NSString isNil:_message.translateContent] || ![NSString isNil:_message.atTranslateContent] || ![NSString isNil:_message.againTranslateContent] || ![NSString isNil:_message.againAtTranslateContent]) {
                    _message.translateStatus = CIMTranslateStatusSuccess;
                } else {
                    if (_message.translateStatus == CIMTranslateStatusFail) {
                        _message.translateStatus = CIMTranslateStatusFail;
                    } else if (_message.translateStatus == CIMTranslateStatusLoading) {
                        _message.translateStatus = CIMTranslateStatusLoading;
                    } else {
                        _message.translateStatus = CIMTranslateStatusNone;
                    }
                }
            }
        }
        
        _isSelf = [message.fromID isEqualToString:UserManager.userInfo.userUID];
        //默认高度
        _messageWidth = CGFLOAT_MIN;
        _messageHeight = CGFLOAT_MIN;
        _cellHeight = CGFLOAT_MIN;
        _isShowSendTime = NO;
        
        //如果有引用消息，将引用消息从本地DB中取出
        if (![NSString isNil:_message.referenceMsgId]) {
            NSString *sessionId;
            if (_message.chatType == CIMChatType_SingleChat) {
                sessionId = _isSelf ? _message.toID : _message.fromID;
            } else {
                sessionId = _message.toID;
            }
            _referenceMsg = [IMSDKManager toolGetOneChatMessageWithServiceMessageID:_message.referenceMsgId sessionID:sessionId];
            _isReferenceSelf = [_referenceMsg.fromID isEqualToString:UserManager.userInfo.userUID];
        }
        
        //计算高度
        [self calculateModelInfoSize];
        //配置带有上传功能的data（图片消息、视频消息、文件消息、音频消息、地理位置消息）
        [self configUploadTask];
    }
    return self;
}

// 编辑通知可能同时携带发送端译文和本机二次译文，此初始化方法按消息归属决定展示哪一种。
- (instancetype)initWithEditMessageModel:(NoaIMChatMessageModel *)message {
    self = [super init];
    if (!self) {
        return nil;
    }

    _message = message;
    _isSelf = [message.fromID isEqualToString:UserManager.userInfo.userUID];
    if (_message.messageType == CIMChatMessageType_TextMessage || _message.messageType == CIMChatMessageType_AtMessage) {
        BOOL hasLocalTranslation = ![NSString isNil:_message.againTranslateContent] || ![NSString isNil:_message.againAtTranslateContent];
        BOOL hasSenderTranslation = ![NSString isNil:_message.translateContent] || ![NSString isNil:_message.atTranslateContent];
        if (hasLocalTranslation || (_isSelf && hasSenderTranslation)) {
            _message.translateStatus = CIMTranslateStatusSuccess;
        } else if (_message.translateStatus != CIMTranslateStatusFail && _message.translateStatus != CIMTranslateStatusLoading) {
            _message.translateStatus = CIMTranslateStatusNone;
        }
    }

    _messageWidth = CGFLOAT_MIN;
    _messageHeight = CGFLOAT_MIN;
    _cellHeight = CGFLOAT_MIN;
    _isShowSendTime = NO;
    if (![NSString isNil:_message.referenceMsgId]) {
        NSString *sessionID = _message.chatType == CIMChatType_SingleChat ? (_isSelf ? _message.toID : _message.fromID) : _message.toID;
        _referenceMsg = [IMSDKManager toolGetOneChatMessageWithServiceMessageID:_message.referenceMsgId sessionID:sessionID];
        _isReferenceSelf = [_referenceMsg.fromID isEqualToString:UserManager.userInfo.userUID];
    }
    [self calculateModelInfoSize];
    [self configUploadTask];
    return self;
}

- (instancetype)initWithMessageModel:(NoaIMChatMessageModel *)message isSelf:(BOOL)isSelf {
    self = [super init];
    if (self) {
        _message = message;
        _isSelf = isSelf;
        //默认高度
        _messageWidth = CGFLOAT_MIN;
        _messageHeight = CGFLOAT_MIN;
        _cellHeight = CGFLOAT_MIN;
        _isShowSendTime = NO;
        
        _message.referenceMsgId = nil;
        _referenceMsg = nil;
        
        //计算高度
        [self calculateModelInfoSize];
    }
    return self;
}


#pragma mark - Set
- (void)setIsShowSendTime:(BOOL)isShowSendTime {
    _isShowSendTime = isShowSendTime;
    if (_message.messageType == CIMChatMessageType_TextMessage || _message.messageType == CIMChatMessageType_ImageMessage || _message.messageType == CIMChatMessageType_VideoMessage || _message.messageType == CIMChatMessageType_AtMessage || _message.messageType == CIMChatMessageType_VoiceMessage || _message.messageType == CIMChatMessageType_FileMessage || _message.messageType == CIMChatMessageType_CardMessage || _message.messageType == CIMChatMessageType_GeoMessage || _message.messageType == CIMChatMessageType_ForwardMessage || _message.messageType == CIMChatMessageType_StickersMessage || _message.messageType == CIMChatMessageType_GameStickersMessage) {
        //是否显示消息的时间
        if (_isShowSendTime) {
            //计算时间
            [self transformTimestampToDataTime];
            _cellHeight = CellTop + _messageHeight + _translateMessageHeight + DWScale(3) + 9*2 + DWScale(20) + 12 + 19 + CellBottom;
        } else {
            _dataTime = @"";
            _cellHeight = CellTop + _messageHeight + _translateMessageHeight + DWScale(3) + 9*2 + DWScale(20) + CellBottom;
        }
        
        //群聊需要显示昵称
        if (_message.chatType == CIMChatType_GroupChat) {
            _cellHeight += 18;
        }
    } else if (_message.messageType ==  CIMChatMessageType_BackMessage || _message.messageType == CIMChatMessageType_ServerMessage) {
        IMServerMessage *serverMessage = _message.serverMessage;
        CustomEvent *customEvent = serverMessage.customEvent;
        if (customEvent.type == 101 || customEvent.type == 103) {
            //是否显示消息的时间
            if (_isShowSendTime) {
                //计算时间
                [self transformTimestampToDataTime];
                _cellHeight = CellTop + _messageHeight + 9*2 + 12 + 19 + CellBottom;
            } else {
                _dataTime = @"";
                _cellHeight = CellTop + _messageHeight + 9*2 + CellBottom;
            }
            
            //群聊需要显示昵称
            if (_message.chatType == CIMChatType_GroupChat) {
                _cellHeight += 18;
            }
        } else {
            //是否显示消息的时间
            if (_isShowSendTime) {
                //计算时间
                [self transformTimestampToDataTime];
                _cellHeight = 5 + _messageHeight + 12 + 19 + 5;
            } else {
                _dataTime = @"";
                _cellHeight = 5 + _messageHeight + 5;
            }
        }
    }
}

- (void)transformTimestampToDataTime {
    if (_message) {
        //将消息的时间戳转换成日期时间
        NSDate *msgTime = [NSDate dateWithTimeIntervalSince1970:_message.sendTime/1000];
        _dataTime = [NoaMessageTimeTool getTimeStringAutoShort2:msgTime mustIncludeTime:YES];
    }
}

- (void)calculateModelInfoSize {
    if (_message) {
        if (_message.messageType == CIMChatMessageType_TextMessage) {
            if (![NSString isNil:_message.referenceMsgId]) {
                //引用消息
                [self calculateReferenceMessage];
            } else {
                //文本消息
                [self calculateTextMessage];
            }
        } else if (_message.messageType == CIMChatMessageType_ImageMessage) {
            //图片消息
            [self calculateImageMessage];
        } else if (_message.messageType == CIMChatMessageType_VideoMessage) {
            //视频消息
            [self calculateVideoMessage];
        } else if (_message.messageType == CIMChatMessageType_AtMessage) {
            if (![NSString isNil:_message.referenceMsgId]) {
                //引用消息
                [self calculateReferenceMessage];
            } else {
                //At消息
                [self calculateAtUserMessage];
            }
        } else if (_message.messageType == CIMChatMessageType_BackMessage || _message.messageType == CIMChatMessageType_ServerMessage) {
            IMServerMessage *serverMessage = _message.serverMessage;
            CustomEvent *customEvent = serverMessage.customEvent;
            if (customEvent.type == 101 || customEvent.type == 103) {
                //音视频通话操作提示消息
                [self calculateMediaCallMessage];
            } else {
                //系统通知
                [self calculateSystemMessage];
            }
        } else if (_message.messageType == CIMChatMessageType_VoiceMessage) {
            //语言消息
            [self calculateVoiceMessage];
        } else if (_message.messageType == CIMChatMessageType_FileMessage) {
            //文件消息
            [self calculateFileMessage];
        } else if (_message.messageType == CIMChatMessageType_GroupNotice) {
            //群公告消息
            [self calculateGroupNoticeMessage];
        } else if(_message.messageType == CIMChatMessageType_LocationMessage){
            [self calculateLocationMessage];
        } else if (_message.messageType == CIMChatMessageType_CardMessage) {
            //名片消息
            [self calculateNameCardMessage];
        } else if (_message.messageType == CIMChatMessageType_GeoMessage) {
            //地理位置消息
            [self calculateGeoLocationMessage];
        } else if (_message.messageType == CIMChatMessageType_ForwardMessage) {
            //消息记录
            [self calculateMergeMsgRecordMessage];
        } else if (_message.messageType == CIMChatMessageType_NetCallMessage) {
            //即构 音视频通话消息
            [self calculateNetCallMessage];
        } else if (_message.messageType == CIMChatMessageType_StickersMessage) {
            //表情消息
            [self calculateStickersMessage];
        } else if (_message.messageType == CIMChatMessageType_GameStickersMessage) {
            //游戏表情消息
            [self calculateGameStickersMessage];
        } else {
            //忽略未解析的消息
            _messageWidth = DScreenWidth;
            _messageHeight = CGFLOAT_MIN;
            _cellHeight = CGFLOAT_MIN;
        }
    }
}

- (void)configUploadTask {
    if (_message && _isSelf) {
        if (_message.messageSendType == CIMChatMessageSendTypeSending) {
            NSMutableArray *taskArray = [NSMutableArray array];
            if (_message.messageType == CIMChatMessageType_ImageMessage) {
                NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, _message.toID];
                //缩略图
                NoaFileUploadTask *thumbImgTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:[NSString stringWithFormat:@"%@_thumb", _message.msgID]];
                if (thumbImgTask) {
                    thumbImgTask.beSendMessage = _message;
                    [thumbImgTask addDelegate:self];
                } else {
                    NSString *localThumbImgPath = [NSString getPathWithImageName:_message.localthumbImgName CustomPath:customPath];
                    NSData *thumbImgData = [NSData dataWithContentsOfFile:localThumbImgPath];
                    NSString *imagePath = [NSString getPathWithImageName:_message.localImgName CustomPath:customPath];

                    NoaFileUploadTask *thumbImgTask = [[NoaFileUploadTask alloc] initWithTaskId:[NSString stringWithFormat:@"%@_thumb", _message.msgID] filePath:localThumbImgPath originFilePath:imagePath fileName:_message.localthumbImgName fileType:@"" isEncrypt:YES dataLength:thumbImgData.length uploadType:ZHttpUploadTypeImageThumbnail beSendMessage:_message delegate:self];
                    thumbImgTask.messageTaskType = FileUploadMessageTaskTypeThumbImage;
                    [taskArray addObject:thumbImgTask];
                }
            
                //图片
                NoaFileUploadTask *imgTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:_message.msgID];
                if (imgTask) {
                    imgTask.beSendMessage = _message;
                    [imgTask addDelegate:self];
                } else {
                    NSString *imagePath = [NSString getPathWithImageName:_message.localImgName CustomPath:customPath];
                    imgTask = [[NoaFileUploadTask alloc] initWithTaskId:_message.msgID filePath:imagePath originFilePath:@"" fileName:_message.localImgName fileType:@"" isEncrypt:YES dataLength:_message.imgSize uploadType:ZHttpUploadTypeImage beSendMessage:_message delegate:self];
                    imgTask.messageTaskType = FileUploadMessageTaskTypeImage;
                    [taskArray addObject:imgTask];
                }
            } else if (_message.messageType == CIMChatMessageType_VideoMessage) {
                //视频
                NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, _message.toID];
                //视频封面上传
                NoaFileUploadTask *coverTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:[NSString stringWithFormat:@"%@_cover", _message.msgID]];
                if (coverTask) {
                    coverTask.beSendMessage = _message;
                    [coverTask addDelegate:self];
                } else {
                    NSString *coverPath = [NSString getPathWithImageName:_message.localVideoCover CustomPath:customPath];
                    coverTask = [[NoaFileUploadTask alloc] initWithTaskId:[NSString stringWithFormat:@"%@_cover", _message.msgID] filePath:coverPath originFilePath:@"" fileName:_message.localVideoCover fileType:@"" isEncrypt:YES dataLength:_message.videoCoverSize uploadType:ZHttpUploadTypeImage beSendMessage:_message delegate:self];
                    coverTask.messageTaskType = FileUploadMessageTaskTypeCover;
                    [taskArray addObject:coverTask];
                }
                //视频文件上传
                NoaFileUploadTask *videoTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:_message.msgID];
                if (videoTask) {
                    videoTask.beSendMessage = _message;
                    [videoTask addDelegate:self];
                } else {
                    NSString *videoPath = [NSString getPathWithVideoName:_message.localVideoName CustomPath:customPath];
                    videoTask = [[NoaFileUploadTask alloc] initWithTaskId:_message.msgID filePath:videoPath originFilePath:@"" fileName:_message.localVideoName fileType:@"" isEncrypt:YES dataLength:_message.videoSize uploadType:ZHttpUploadTypeVideo beSendMessage:_message delegate:self];
                    videoTask.messageTaskType = FileUploadMessageTaskTypeVideo;
                    [taskArray addObject:videoTask];
                }
            } else if (_message.messageType == CIMChatMessageType_VoiceMessage) {
                //音频
                NoaFileUploadTask *voiceTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:_message.msgID];
                if (voiceTask) {
                    voiceTask.beSendMessage = _message;
                    [voiceTask addDelegate:self];
                } else {
                    NSData *audioData = [NSData dataWithContentsOfFile:_message.localVoicePath options:NSDataReadingMappedIfSafe error:nil];
                    voiceTask = [[NoaFileUploadTask alloc] initWithTaskId:_message.msgID filePath:_message.localVoicePath originFilePath:@"" fileName:_message.localVoiceName fileType:@"" isEncrypt:NO dataLength:audioData.length uploadType:ZHttpUploadTypeVoice beSendMessage:_message delegate:self];
                    voiceTask.messageTaskType = FileUploadMessageTaskTypeVoice;
                    [taskArray addObject:voiceTask];
                }
            } else if (_message.messageType == CIMChatMessageType_FileMessage) {
                //文件
                NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, _message.toID];
        
                NoaFileUploadTask *fileTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:_message.msgID];
                if (fileTask) {
                    fileTask.beSendMessage = _message;
                    [fileTask addDelegate:self];
                } else {
                    NSString *filePath = [NSString getPathWithFileName:_message.fileName CustomPath:customPath];
                    fileTask = [[NoaFileUploadTask alloc] initWithTaskId:_message.msgID filePath:filePath originFilePath:@"" fileName:_message.fileName fileType:_message.fileType isEncrypt:YES dataLength:_message.fileSize uploadType:ZHttpUploadTypeFile beSendMessage:_message delegate:self];
                    fileTask.messageTaskType = FileUploadMessageTaskTypeFile;
                    [taskArray addObject:fileTask];
                }
            } else if (_message.messageType == CIMChatMessageType_GeoMessage) {
                //地理位置
                NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, _message.toID];
                
                NoaFileUploadTask *geoImgTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:_message.msgID];
                if (geoImgTask) {
                    geoImgTask.beSendMessage = _message;
                    [geoImgTask addDelegate:self];
                } else {
                    NSString *geoImgPath = [NSString getPathWithImageName:_message.localGeoImgName CustomPath:customPath];
                    NSData *geoImgData = [NSData dataWithContentsOfFile:_message.localVoicePath options:NSDataReadingMappedIfSafe error:nil];
                    geoImgTask = [[NoaFileUploadTask alloc] initWithTaskId:_message.msgID filePath:geoImgPath originFilePath:@"" fileName:_message.localImgName fileType:@"" isEncrypt:YES dataLength:geoImgData.length uploadType:ZHttpUploadTypeImage beSendMessage:_message delegate:self];
                    geoImgTask.messageTaskType = FileUploadMessageTaskTypeImage;
                    [taskArray addObject:geoImgTask];
                }
            }
            
            if (taskArray.count > 0) {
                NoaFileUploadGetSTSTask *getSTSTask = [[NoaFileUploadGetSTSTask alloc] init];
                getSTSTask.uploadTask = taskArray;
                [[NoaFileUploadManager sharedInstance].operationQueue addOperation:getSTSTask];

                NoaMessageSendTask *messageSendTask = [[NoaMessageSendTask alloc] init];
                messageSendTask.uploadTask = taskArray;
                for (NoaFileUploadTask * task in taskArray) {
                    [[NoaFileUploadManager sharedInstance] addUploadTask:task];
                }
                [[NoaFileUploadManager sharedInstance].operationQueue addOperation:messageSendTask];
            }
        }
    }
}

#pragma mark - ZFileUploadTaskDelegate
//任务状态改变回调
- (void)fileUploadTask:(NoaFileUploadTask *)task didChangTaskStatus:(FileUploadTaskStatus)status error:(NSError *)error {
    /*
    if (status == FileUploadTaskStatus_Completed) {
        if (self.uploadFileSuccess) {
            self.uploadFileSuccess();
        }
    }
    */
    if (status == FileUploadTaskStatus_Failed) {
        _message.messageSendType = CIMChatMessageSendTypeFail;
        [IMSDKManager toolInsertOrUpdateChatMessageWith:_message];
        if (self.uploadFileFail) {
            self.uploadFileFail();
        }
    }
}

//任务上传进度回调
- (void)fileUploadTask:(NoaFileUploadTask *)task didChangTaskProgress:(float)progress {
    //NSLog(@" ====Model======== %@ 进度：%0.2f =============",  _message.showFileName, progress);
    if (self.uploadFileLoading) {
        self.uploadFileLoading(progress, task.taskId);
    }
}

//任务暂停
- (void)fileUploadTaskDidPause:(NoaFileUploadTask *)task {
}


#pragma mark - 计算文本消息
- (void)calculateTextMessage {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 2;
    NSDictionary *dict = @{NSFontAttributeName:FONTN(16),NSParagraphStyleAttributeName:[style copy]};
    //此处需要将表情内容"[表情]"替换为表情图片的富文本
    if (self.isSelf) {
        self.attStr = [[NoaChatInputEmojiManager sharedManager] yy_emojiAttributedString:_message.textContent];
        [self.attStr configAttStrLightColor:COLORWHITE darkColor:COLORWHITE range:NSMakeRange(0, self.attStr.length)];
    } else {
        self.attStr = [[NoaChatInputEmojiManager sharedManager] yy_emojiAttributedString:![NSString isNil:_message.translateContent] ? _message.translateContent : _message.textContent];
        [self.attStr configAttStrLightColor:COLOR_11 darkColor:COLORWHITE range:NSMakeRange(0, self.attStr.length)];
    }
    [self.attStr addAttributes:dict range:NSMakeRange(0, self.attStr.length)];
    CGSize size = [YYTextLayout layoutWithContainerSize:CGSizeMake(DScreenWidth - 140, CGFLOAT_MAX) text:self.attStr].textBoundingSize;
    //CGSize size = [self.attStr boundingRectWithSize:CGSizeMake(DScreenWidth - 140, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    _messageHeight = MAX(ceil(size.height), 20 + 5);
    _messageWidth = MAX(ceil(size.width > (DScreenWidth - 140) ? (DScreenWidth - 140) : size.width), 20 + 5);
    if(ZLanguageTOOL.isRTL){
        CGFloat width = [self.attStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width;
        _messageWidth = MIN(MAX(ceil(width), 20 + 5), DScreenWidth - 140);
    }
    
    BOOL shouldShowTranslate_text = ([IMSDKManager toolIsTranslateEnabled] || _message.localTranslatedShown == 1);
    if (!shouldShowTranslate_text) {
        _translateMessageHeight = 0;
        _translateMessageWidth =  0;
    } else if (_message.translateStatus == CIMTranslateStatusSuccess) {
        if (self.isSelf) {
            if (![NSString isNil:_message.translateContent]) {
                //此处需要将表情内容"[表情]"替换为表情图片的富文本
                self.translateAttStr = [[NoaChatInputEmojiManager sharedManager] yy_emojiAttributedString:_message.translateContent];
                [self.translateAttStr addAttributes:dict range:NSMakeRange(0, self.translateAttStr.length)];
                if (self.isSelf) {
                    [self.translateAttStr configAttStrLightColor:COLORWHITE darkColor:COLORWHITE range:NSMakeRange(0, self.translateAttStr.length)];
                } else {
                    [self.translateAttStr configAttStrLightColor:COLOR_11 darkColor:COLORWHITE range:NSMakeRange(0, self.translateAttStr.length)];
                }
                CGSize translateSize = [YYTextLayout layoutWithContainerSize:CGSizeMake(DScreenWidth - 140, CGFLOAT_MAX) text:self.translateAttStr].textBoundingSize;
                //CGSize translateSize = [self.translateAttStr boundingRectWithSize:CGSizeMake(DScreenWidth - 140, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
                _translateMessageHeight = MAX(ceil(translateSize.height), 20 + 5);
                _translateMessageWidth = MAX(ceil(translateSize.width > (DScreenWidth - 140) ? (DScreenWidth - 140) : translateSize.width), 20 + 5);
                if(ZLanguageTOOL.isRTL){
                    CGFloat width = [self.translateAttStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width;
                    _translateMessageWidth = MIN(MAX(ceil(width), 20 + 5), DScreenWidth - 140);
                }
            } else {
                _translateMessageHeight = 0;
                _translateMessageWidth =  0;
            }
        } else {
            if (![NSString isNil:_message.againTranslateContent]) {
                //此处需要将表情内容"[表情]"替换为表情图片的富文本
                self.translateAttStr = [[NoaChatInputEmojiManager sharedManager] yy_emojiAttributedString:![NSString isNil:_message.againTranslateContent] ? _message.againTranslateContent : _message.translateContent];
                [self.translateAttStr addAttributes:dict range:NSMakeRange(0, self.translateAttStr.length)];
                if (self.isSelf) {
                    [self.translateAttStr configAttStrLightColor:COLORWHITE darkColor:COLORWHITE range:NSMakeRange(0, self.translateAttStr.length)];
                } else {
                    [self.translateAttStr configAttStrLightColor:COLOR_11 darkColor:COLORWHITE range:NSMakeRange(0, self.translateAttStr.length)];
                }
                CGSize translateSize = [YYTextLayout layoutWithContainerSize:CGSizeMake(DScreenWidth - 140, CGFLOAT_MAX) text:self.translateAttStr].textBoundingSize;
                //CGSize translateSize = [self.translateAttStr boundingRectWithSize:CGSizeMake(DScreenWidth - 140, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
                _translateMessageHeight = MAX(ceil(translateSize.height), 20 + 5);
                _translateMessageWidth = MAX(ceil(translateSize.width > (DScreenWidth - 140) ? (DScreenWidth - 140) : translateSize.width), 20 + 5);
                if(ZLanguageTOOL.isRTL){
                    CGFloat width = [self.translateAttStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width;
                    _translateMessageWidth = MIN(MAX(ceil(width), 20 + 5), DScreenWidth - 140);
                }
            } else{
                _translateMessageHeight = 0;
                _translateMessageWidth =  0;
            }
        }
    } else if (_message.translateStatus == CIMTranslateStatusLoading) {
        _translateMessageHeight = MAX(ceil(DWScale(36)), 20 + 5);
        _translateMessageWidth =  MAX(ceil(DWScale(40)), 20 + 5);
    } else if (_message.translateStatus == CIMTranslateStatusFail) {
        _translateMessageHeight = MAX(ceil(DWScale(36)), 20 + 5);
        _translateMessageWidth =  MAX(ceil(DWScale(90)), 20 + 5);
    } else {
        _translateMessageHeight = 0;
        _translateMessageWidth =  0;
    }

    //如果要显示日期时间，还得 + 12 + 19
    if (![NSString isNil:_dataTime]) {
        _cellHeight = CellTop + _messageHeight + _translateMessageHeight + DWScale(3) + 9*2 + DWScale(20) + 12 + 19 + CellBottom;
    } else {
        _cellHeight = CellTop + _messageHeight + _translateMessageHeight + DWScale(3) + 9*2 + DWScale(20) + CellBottom;
    }
    //群聊需要显示昵称
    if (_message.chatType == CIMChatType_GroupChat) {
        _cellHeight += 18;
    }
}

#pragma mark - 计算@用户消息
- (void)calculateAtUserMessage {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 2;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:16],NSParagraphStyleAttributeName:[style copy]};
    
    /* 将后台返回的 atContent里 \vUid\v 替换为 @昵称 设置给showContent，方便UI展示*/
    if (_isSelf) {
        _message.showContent = [NoaMessageTools atContenTranslateToShowContent:![NSString isNil:_message.atContent] ? _message.atContent : @"" atUsersDictList:_message.atUsersInfoList withMessage:_message isGetShowName:YES];
    } else {
        _message.showContent = [NoaMessageTools atContenTranslateToShowContent:![NSString isNil:_message.atTranslateContent] ? _message.atTranslateContent : _message.atContent atUsersDictList:_message.atUsersInfoList withMessage:_message isGetShowName:YES];
    }
    
    if (_isSelf) {
        _message.showTranslateContent = [NoaMessageTools atContenTranslateToShowContent:![NSString isNil:_message.atTranslateContent] ? _message.atTranslateContent : @"" atUsersDictList:_message.atUsersInfoList withMessage:_message isGetShowName:YES];
    } else {
        _message.showTranslateContent = [NoaMessageTools atContenTranslateToShowContent:![NSString isNil:_message.againAtTranslateContent] ? _message.againAtTranslateContent : _message.atTranslateContent atUsersDictList:_message.atUsersInfoList withMessage:_message isGetShowName:YES];
    }
   
    //此处需要将表情内容"[表情]"替换为表情图片的富文本
    self.attStr = [[NoaChatInputEmojiManager sharedManager] yy_emojiAttributedString:_message.showContent];
    [self.attStr addAttributes:dict range:NSMakeRange(0, self.attStr.length)];
    
    self.translateAttStr = [[NoaChatInputEmojiManager sharedManager] yy_emojiAttributedString:_message.showTranslateContent];
    [self.translateAttStr addAttributes:dict range:NSMakeRange(0, self.translateAttStr.length)];
    
    //非自己发送的消息
    //原文
    if (!_isSelf) {
        [self.attStr configAttStrLightColor:COLOR_11 darkColor:COLOR_11_DARK range:NSMakeRange(0, self.attStr.length)];
        //改变被 @用户 字体为蓝色
        for (NSDictionary *atUserDic in _message.atUsersInfoList) {
            NSArray *atKeyArr = [atUserDic allKeys];
            NSString *atKey = (NSString *)[atKeyArr firstObject];
        
            if ([atKey isEqualToString:UserManager.userInfo.userUID]) {
                // @我
                [self.attStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 fullStr:self.attStr.string appointStr:LanguageToolMatch(@"@我")];
            } else if ([atKey isEqualToString:@"-1"]) {
                // @所有人
                [self.attStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 fullStr:self.attStr.string appointStr:LanguageToolMatch(@"@所有人")];
            } else {
                // @其他用户 显示 @昵称
                NSString *resultValue;
                if(_message.chatType == CIMChatType_GroupChat){
                    LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:atKey groupID:_message.toID];
                    resultValue = [NSString stringWithFormat:@"@%@",groupMemberModel ? groupMemberModel.showName : [atUserDic objectForKeySafe:atKey]];
                }else{
                    LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:atKey];
                    resultValue = [NSString stringWithFormat:@"@%@", friendModel ? friendModel.nickname : [atUserDic objectForKeySafe:atKey]];
                }
                [self.attStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 fullStr:self.attStr.string appointStr:resultValue];
            }
        }
    } else {
        [self.attStr configAttStrLightColor:COLORWHITE darkColor:COLORWHITE range:NSMakeRange(0, self.attStr.length)];
    }
    CGSize size = [YYTextLayout layoutWithContainerSize:CGSizeMake(DScreenWidth - 140, CGFLOAT_MAX) text:self.attStr].textBoundingSize;
    //CGSize size = [self.attStr boundingRectWithSize:CGSizeMake(DScreenWidth - 140, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    _messageHeight = MAX(ceil(size.height), 20 + 5);
    _messageWidth = MAX(ceil(size.width > (DScreenWidth - 140) ? (DScreenWidth - 140) : size.width), 20 + 5);
    
    if(ZLanguageTOOL.isRTL){
        CGFloat width = [self.attStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width;
        _messageWidth = MIN(MAX(ceil(width), 20 + 5), DScreenWidth - 140);
        
    }
    
    //译文
    BOOL shouldShowTranslate_at = ([IMSDKManager toolIsTranslateEnabled] || _message.localTranslatedShown == 1);
    if (!shouldShowTranslate_at) {
        _translateMessageHeight = 0;
        _translateMessageWidth =  0;
    } else if (_message.translateStatus == CIMTranslateStatusSuccess) {
        if (_isSelf) {
            if (![NSString isNil:_message.atTranslateContent]) {
                [self.translateAttStr configAttStrLightColor:COLORWHITE darkColor:COLORWHITE range:NSMakeRange(0, self.translateAttStr.length)];
                
                CGSize translateSize = [YYTextLayout layoutWithContainerSize:CGSizeMake(DScreenWidth - 140, CGFLOAT_MAX) text:self.translateAttStr].textBoundingSize;
                //CGSize translateSize = [self.translateAttStr boundingRectWithSize:CGSizeMake(DScreenWidth - 140, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
                _translateMessageHeight = MAX(ceil(translateSize.height), 20 + 5);
                _translateMessageWidth = MAX(ceil(translateSize.width > (DScreenWidth - 140) ? (DScreenWidth - 140) : translateSize.width), 20 + 5);
            } else {
                _translateMessageHeight = 0;
                _translateMessageWidth =  0;
            }
        } else {
            if (![NSString isNil:_message.againAtTranslateContent]) {
                [self.translateAttStr configAttStrLightColor:COLOR_11 darkColor:COLOR_11_DARK range:NSMakeRange(0, self.translateAttStr.length)];
                //改变被 @用户 字体为蓝色
                for (NSDictionary *atUserDic in _message.atUsersInfoList) {
                    NSArray *atKeyArr = [atUserDic allKeys];
                    NSString *atKey = (NSString *)[atKeyArr firstObject];
        
                    if ([atKey isEqualToString:UserManager.userInfo.userUID]) {
                        // @我
                        [self.translateAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 fullStr:self.translateAttStr.string appointStr:LanguageToolMatch(@"@我")];
                    } else if ([atKey isEqualToString:@"-1"]) {
                        // @所有人
                        [self.translateAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 fullStr:self.translateAttStr.string appointStr:LanguageToolMatch(@"@所有人")];
                    } else {
                        // @其他用户 显示 @昵称
                        NSString *resultValue;
                        if(_message.chatType == CIMChatType_GroupChat){
                            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:atKey groupID:_message.toID];
                            resultValue = [NSString stringWithFormat:@"@%@",groupMemberModel ? groupMemberModel.showName : [atUserDic objectForKeySafe:atKey]];
                        }else{
                            LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:atKey];
                            resultValue = [NSString stringWithFormat:@"@%@", friendModel ? friendModel.nickname : [atUserDic objectForKeySafe:atKey]];
                        }
                        [self.translateAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 fullStr:self.translateAttStr.string appointStr:resultValue];
                    }
                }
                CGSize translateSize = [YYTextLayout layoutWithContainerSize:CGSizeMake(DScreenWidth - 140, CGFLOAT_MAX) text:self.translateAttStr].textBoundingSize;
                //CGSize translateSize = [self.translateAttStr boundingRectWithSize:CGSizeMake(DScreenWidth - 140, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
                _translateMessageHeight = MAX(ceil(translateSize.height), 20 + 5);
                _translateMessageWidth = MAX(ceil(translateSize.width > (DScreenWidth - 140) ? (DScreenWidth - 140) : translateSize.width), 20 + 5);
            } else {
                _translateMessageHeight = 0;
                _translateMessageWidth =  0;
            }
        }
    } else if (_message.translateStatus == CIMTranslateStatusLoading) {
        _translateMessageHeight = MAX(ceil(DWScale(36)), 20 + 5);
        _translateMessageWidth =  MAX(ceil(DWScale(40)), 20 + 5);
    } else if (_message.translateStatus == CIMTranslateStatusFail) {
        _translateMessageHeight = MAX(ceil(DWScale(36)), 20 + 5);
        _translateMessageWidth =  MAX(ceil(DWScale(90)), 20 + 5);
    } else {
        _translateMessageHeight = 0;
        _translateMessageWidth =  0;
    }
    
    if(ZLanguageTOOL.isRTL){
        if (![NSString isNil:_message.translateContent]) {
            CGFloat translateWidth = [self.translateAttStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width;
            _translateMessageWidth = MIN(MAX(ceil(translateWidth), 20 + 5), DScreenWidth - 140);
        }
    }
    
    //如果要显示日期时间，还得 + 12 + 19
    if (![NSString isNil:_dataTime]) {
        _cellHeight = CellTop + _messageHeight + _translateMessageHeight + DWScale(3) + 9*2 + DWScale(20) + 12 + 19 + CellBottom;
    } else {
        _cellHeight = CellTop + _messageHeight + _translateMessageHeight + DWScale(3) + 9*2 + DWScale(20) + CellBottom;
    }
    //群聊需要显示昵称
    if (_message.chatType == CIMChatType_GroupChat) {
        _cellHeight += 18;
    }
}

#pragma mark - 计算位置消息
- (void)calculateLocationMessage{
    self.attStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"[图片]")];
    CGFloat imgW;
    CGFloat imgH;
    //图片
    imgW = _message.imgWidth <= 0 ? 1 : _message.imgWidth;
    imgH = _message.imgHeight <= 0 ? 1 : _message.imgHeight;
    
    if (imgW >= imgH) {
        //横图，图片宽度固定为150
        _messageWidth = 251;
        _messageHeight = imgH / (imgW * 1.0) * 251;
    }else {
        //竖图，高度固定为150
        _messageWidth = imgW / (imgH * 1.0) * 251;
        _messageHeight = 251;
    }
    
    //如果要显示日期时间，还得 + 12 + 19
    if (![NSString isNil:_dataTime]) {
        _cellHeight = CellTop + _messageHeight + 9*2 + DWScale(20) + 12 + 19 + CellBottom;
    } else {
        _cellHeight = CellTop + _messageHeight + 9*2 + DWScale(20) + CellBottom;
    }
    //群聊需要显示昵称
    if (_message.chatType == CIMChatType_GroupChat) {
        _cellHeight += 18;
    }
}

#pragma mark - 计算图片消息
- (void)calculateImageMessage {
    
    self.attStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"[图片]")];
    CGFloat imgW;
    CGFloat imgH;
    //图片
    imgW = _message.imgWidth <= 0 ? 1 : _message.imgWidth;
    imgH = _message.imgHeight <= 0 ? 1 : _message.imgHeight;
    
    if (imgW >= imgH) {
        //横图，图片宽度固定为170
        _messageWidth = 170;
        _messageHeight = imgH / (imgW * 1.0) * 170;
    }else {
        //竖图，高度固定为170
        _messageWidth = imgW / (imgH * 1.0) * 170;
        _messageHeight = 170;
    }
    
    //如果要显示日期时间，还得 + 12 + 19
    if (![NSString isNil:_dataTime]) {
        _cellHeight = CellTop + _messageHeight + 9*2 + DWScale(20) + 12 + 19 + CellBottom;
    } else {
        _cellHeight = CellTop + _messageHeight + 9*2 + DWScale(20) + CellBottom;
    }
    //群聊需要显示昵称
    if (_message.chatType == CIMChatType_GroupChat) {
        _cellHeight += 18;
    }
}

#pragma mark - 计算表情消息
- (void)calculateStickersMessage {
    self.attStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"[表情]")];
    CGFloat imgW;
    CGFloat imgH;
    //图片
    imgW = _message.stickersWidth <= 0 ? 1 : _message.stickersWidth;
    imgH = _message.stickersHeight <= 0 ? 1 : _message.stickersHeight;
    
    if (imgW >= imgH) {
        //横图，图片宽度固定为106
        _messageWidth = DWScale(106);
        _messageHeight = imgH / (imgW * 1.0) * DWScale(106);
    }else {
        //竖图，高度固定为170
        _messageWidth = imgW / (imgH * 1.0) * DWScale(106);
        _messageHeight = DWScale(106);
    }
    
    //如果要显示日期时间，还得 + 12 + 19
    if (![NSString isNil:_dataTime]) {
        _cellHeight = CellTop + _messageHeight + 9*2 + DWScale(20) + 12 + 19 + CellBottom;
    } else {
        _cellHeight = CellTop + _messageHeight + 9*2 + DWScale(20) + CellBottom;
    }
    //群聊需要显示昵称
    if (_message.chatType == CIMChatType_GroupChat) {
        _cellHeight += 18;
    }
}

#pragma mark - 计算游戏表情
- (void)calculateGameStickersMessage {
    self.attStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"[表情]")];
    
    _messageWidth = DWScale(50);
    _messageHeight = DWScale(50);
    
    //如果要显示日期时间，还得 + 12 + 19
    if (![NSString isNil:_dataTime]) {
        _cellHeight = CellTop + _messageHeight + 9*2 + DWScale(20) + 12 + 19 + CellBottom;
    } else {
        _cellHeight = CellTop + _messageHeight + 9*2 + DWScale(20) + CellBottom;
    }
    //群聊需要显示昵称
    if (_message.chatType == CIMChatType_GroupChat) {
        _cellHeight += 18;
    }
}

#pragma mark - 计算视频消息
- (void)calculateVideoMessage {
    self.attStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"[视频]")];
    CGFloat imgW;
    CGFloat imgH;
    //视频封面
    imgW = _message.videoCoverW <= 0 ? 1 : _message.videoCoverW;
    imgH = _message.videoCoverH <= 0 ? 1 : _message.videoCoverH;
    
    if (imgW >= imgH) {
        //横图，图片宽度固定为150
        _messageWidth = 170;
        _messageHeight = imgH / (imgW * 1.0) * 170;
    }else {
        //竖图，高度固定为150
        _messageWidth = imgW / (imgH * 1.0) * 170;
        _messageHeight = 170;
    }
    
    //如果要显示日期时间，还得 + 12 + 19
    if (![NSString isNil:_dataTime]) {
        _cellHeight = CellTop + _messageHeight + 9*2 + DWScale(20) + 12 + 19 + CellBottom;
    } else {
        _cellHeight = CellTop + _messageHeight + 9*2 + DWScale(20) + CellBottom;
    }
    //群聊需要显示昵称
    if (_message.chatType == CIMChatType_GroupChat) {
        _cellHeight += 18;
    }
}

#pragma mark - 计算语音消息
- (void)calculateVoiceMessage {
    self.attStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"[语音]")];
    
    CGFloat width = 20.0;
    if (_message.voiceLength <= 1) {
        width = 20.0;
    } else if (_message.voiceLength <= 60) {
        width += _message.voiceLength/60 * AudioMaxWidthSpace;
    } else if (_message.voiceLength > 60) {
        width += AudioMaxWidthSpace;
    }

    _messageWidth = MAX(ceil(40 + width + 50), 20 + 40 + 50);
    _messageHeight = DWScale(22);
    
    //如果要显示日期时间，还得 + 12 + 19
    if (![NSString isNil:_dataTime]) {
        _cellHeight = CellTop + _messageHeight + 9*2 + DWScale(20) + 12 + 19 + CellBottom;
    } else {
        _cellHeight = CellTop + _messageHeight + 9*2 + DWScale(20) + CellBottom;
    }
    //群聊需要显示昵称
    if (_message.chatType == CIMChatType_GroupChat) {
        _cellHeight += 18;
    }
}

#pragma mark - 计算文件消息
- (void)calculateFileMessage {
    self.attStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"[文件]")];

    CGFloat fileTitleWidth = [_message.showFileName widthForFont:FONTN(16)];
    if (fileTitleWidth > (DScreenWidth - (65 + 62) - 10 - 18 - DWScale(32) - 10)) {
        fileTitleWidth = (DScreenWidth - (65 + 62) - 10 - 18 - DWScale(32) - 10);
    }
    CGFloat msgWidth = fileTitleWidth + 10 + 18 + DWScale(32);
    _messageHeight = DWScale(68);
    _messageWidth = MAX(ceil(msgWidth), DWScale(32) + 5);
    
    //如果要显示日期时间，还得 + 12 + 19
    if (![NSString isNil:_dataTime]) {
        _cellHeight = CellTop + _messageHeight + DWScale(20) + 12 + 19 + CellBottom;
    } else {
        _cellHeight = CellTop + _messageHeight + DWScale(20) + CellBottom;
    }
    //群聊需要显示昵称
    if (_message.chatType == CIMChatType_GroupChat) {
        _cellHeight += 18;
    }
}

#pragma mark - 计算群公告消息
- (void)calculateGroupNoticeMessage {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 2;
    //style.lineBreakMode = NSLineBreakByTruncatingTail;//设置为abc...后会高度计算不准确
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:16],NSParagraphStyleAttributeName:[style copy]};
    //处理公告文字内容
    NSString *groupNoticeStr = @"";
    if (![NSString isNil:_message.groupNoticeTranslateContent]) {
        NSString *currentLanguageMapCode = [ZLanguageTOOL languageCodeFromDevieInfo];
        NSDictionary *noticeDict = [NSString  jsonStringToDic:_message.groupNoticeTranslateContent];
        if (![[noticeDict allKeys] containsObject:currentLanguageMapCode]) {
            if ([currentLanguageMapCode isEqualToString:@"lb"]) {
                groupNoticeStr = (NSString *)[noticeDict objectForKeySafe:@"lbb"];
            } else if ([currentLanguageMapCode isEqualToString:@"no"]) {
                groupNoticeStr = (NSString *)[noticeDict objectForKeySafe:@"nor"];
            } else {
                NSString *notice_en = (NSString *)[noticeDict objectForKeySafe:@"en"];
                groupNoticeStr = notice_en;
            }
        } else {
            NSString *notice_current = (NSString *)[noticeDict objectForKeySafe:currentLanguageMapCode];
            groupNoticeStr = notice_current;
        }
    } else {
        groupNoticeStr = ![NSString isNil:_message.groupNoticeContent] ? _message.groupNoticeContent : LanguageToolMatch(@"群公告");
    }
    if(groupNoticeStr == nil){
        groupNoticeStr = _message.groupNoticeContent;
    }
    self.attStr = [[NSMutableAttributedString alloc] initWithString:groupNoticeStr];
    [self.attStr addAttributes:dict range:NSMakeRange(0, self.attStr.length)];
    //群公告文本高度
    CGSize size = [self.attStr boundingRectWithSize:CGSizeMake(DWScale(230), CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    CGFloat groupNoticeHeight = size.height;
    
    //计算一行文本的高度
    CGRect oneLineRect = [@"临时一行文本" boundingRectWithSize:CGSizeMake(DWScale(230), CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    
    if (groupNoticeHeight > oneLineRect.size.height * 4) {
        groupNoticeHeight = oneLineRect.size.height * 4;
    }
    
    _messageHeight = MAX(ceil(groupNoticeHeight), 20 + 5) + DWScale(50);
    _messageWidth = DWScale(250);//群公告宽度固定
    
    //如果要显示日期时间，还得 + 12 + 19
    if (![NSString isNil:_dataTime]) {
        _cellHeight = CellTop + _messageHeight + 9*2 + DWScale(20) + 12 + 19 + CellBottom;
    } else {
        _cellHeight = CellTop + _messageHeight + 9*2 + DWScale(20) + CellBottom;
    }
    
    //群聊需要显示昵称
    if (_message.chatType == CIMChatType_GroupChat) {
        _cellHeight += 18;
    }
}

#pragma mark - 音视频通话操作提示消息
- (void)calculateMediaCallMessage {
    self.attStr = [[NSMutableAttributedString alloc] initWithString:@""];
    
//    NSMutableAttributedString *sessionAttStr = [[NSMutableAttributedString alloc] initWithString:@""];
    
    IMServerMessage *serverMessage = _message.serverMessage;
    CustomEvent *customEvent = serverMessage.customEvent;
    NSString *jsonContent = customEvent.content;
    
    NSString *textContentStr = [NSString string];
    if (customEvent.type == 101) {
        //单人音视频
        LIMMediaCallSingleModel *mediaCallModel = [LIMMediaCallSingleModel mj_objectWithKeyValues:jsonContent];
        
        if ([mediaCallModel.discard_reason isEqualToString:@"disconnect"]) {
            //通话中断、服务器强制挂断
            //告知 邀请者 展示 如：通话中断
            //告知 被邀请者 展示 如：通话中断
            if ([mediaCallModel.from_id isEqualToString:UserManager.userInfo.userUID]) {
                //我是 邀请者
                textContentStr = [NSString stringWithFormat:LanguageToolMatch(@"%@ 通话中断"), [NSString getTimeLength:mediaCallModel.duration]];
            } else {
                //我是 被邀请者
                textContentStr = [NSString stringWithFormat:LanguageToolMatch(@"通话中断 %@"), [NSString getTimeLength:mediaCallModel.duration]];
            }
        } else if ([mediaCallModel.discard_reason isEqualToString:@"missed"]) {
            //呼叫超时(被邀请者 长时间未响应 邀请)
            //告知 邀请者 展示 如：对方无应答
            //告知 被邀请者 展示 如：超时未应答
            if ([mediaCallModel.from_id isEqualToString:UserManager.userInfo.userUID]) {
                //我是 邀请者
                textContentStr = LanguageToolMatch(@"对方无应答");
            } else {
                //我是 被邀请者
                textContentStr = LanguageToolMatch(@"超时未应答");
            }
        } else if ([mediaCallModel.discard_reason isEqualToString:@"cancel"]) {
            //呼叫取消(邀请者 在 被邀请者 接受之前 取消邀请)
            //告知 邀请者 展示 如：通话已取消
            //告知 被邀请者 展示 如：对方已取消
            if ([mediaCallModel.from_id isEqualToString:UserManager.userInfo.userUID]) {
                //我是 邀请者
                textContentStr = LanguageToolMatch(@"已取消");
            } else {
                //我是 被邀请者
                textContentStr = LanguageToolMatch(@"对方已取消");
            }
        } else if ([mediaCallModel.discard_reason isEqualToString:@"refused"]) {
            //呼叫拒绝(被邀请者 拒绝 邀请)
            //告知 邀请者 展示 如：对方已拒绝
            //告知 被邀请者 展示 如：已拒绝
            if ([mediaCallModel.from_id isEqualToString:UserManager.userInfo.userUID]) {
                //我是 邀请者
                textContentStr = LanguageToolMatch(@"对方已拒绝");
            } else {
                //我是 被邀请者
                textContentStr = LanguageToolMatch(@"已拒绝");
            }
        } else if ([mediaCallModel.discard_reason isEqualToString:@"accept"]) {
            //呼叫已接听(被邀请者 已接受 邀请，被邀请者的其他设备会收到此消息)
            //告知 被邀请者 展示 如：已在其他设备接听
            //我是 邀请者 不会收到此消息
            if (![mediaCallModel.from_id isEqualToString:UserManager.userInfo.userUID]) {
                //我是 被邀请者
                textContentStr = LanguageToolMatch(@"已在其他设备接听");
            }
        } else {
            //通话正常挂断
            //告知 邀请者 展示 如：10:00通话
            //告知 被邀请者 展示 如：10:00通话
            if ([mediaCallModel.from_id isEqualToString:UserManager.userInfo.userUID]) {
                textContentStr = [NSString stringWithFormat:LanguageToolMatch(@"%@ 通话结束"), [NSString getTimeLength:mediaCallModel.duration]];
            } else {
                textContentStr = [NSString stringWithFormat:LanguageToolMatch(@"通话结束 %@"), [NSString getTimeLength:mediaCallModel.duration]];
            }
        }
    } else if (customEvent.type == 103) {
        
        LIMMediaCallGroupParticipantAction *actionModel = [LIMMediaCallGroupParticipantAction mj_objectWithKeyValues:jsonContent];
        NSString *callMode;
        if (actionModel.mode == 0) {
            callMode = LanguageToolMatch(@"视频通话");
        } else {
            callMode = LanguageToolMatch(@"语音通话");
        }
        LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:actionModel.user_id groupID:actionModel.chat_id];
        if (groupMemberModel) {
            if ([actionModel.action isEqualToString:@"new"]) {
                textContentStr = [NSString stringWithFormat:@"%@", callMode];
            } else if ([actionModel.action isEqualToString:@"discard"]) {
                textContentStr = [NSString stringWithFormat:LanguageToolMatch(@"%@已经结束"), callMode];
            }
        } else {
            if ([actionModel.action isEqualToString:@"new"]) {
                textContentStr = [NSString stringWithFormat:@"%@", callMode];
            } else if ([actionModel.action isEqualToString:@"discard"]) {
                textContentStr = [NSString stringWithFormat:LanguageToolMatch(@"%@已经结束"), callMode];
            }
        }
    }
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 2;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:16],NSParagraphStyleAttributeName:[style copy]};
    self.attStr = [[NSMutableAttributedString alloc] initWithString:textContentStr];
    [self.attStr addAttributes:dict range:NSMakeRange(0, textContentStr.length)];
    
    CGSize size = [self.attStr boundingRectWithSize:CGSizeMake(DScreenWidth - 140, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    _messageWidth = MAX(ceil(size.width), 20 + 5) + 6 + DWScale(18);
    _messageHeight = DWScale(22);
    
    if(ZLanguageTOOL.isRTL){
        CGFloat width = [self.attStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width;
        _messageWidth = MIN(MAX(ceil(width), 20 + 5), DScreenWidth - 140) + 6 + DWScale(18);
    }
    
    
    //如果要显示日期时间，还得 + 12 + 19
    if (![NSString isNil:_dataTime]) {
        _cellHeight = CellTop + _messageHeight + 9*2 + DWScale(20) + 12 + 19 + CellBottom;
    } else {
        _cellHeight = CellTop + _messageHeight + 9*2 + DWScale(20) + CellBottom;
    }
    //群聊需要显示昵称
    if (_message.chatType == CIMChatType_GroupChat) {
        _cellHeight += 18;
    }
}

#pragma mark - 即构音视频通话操作提示消息
- (void)calculateNetCallMessage {
    self.attStr = [[NSMutableAttributedString alloc] initWithString:@""];
    NSString *textContentStr = [NSString string];
    
    if (_message.netCallChatType == 1) {
        //单人音视频
        //1:发起，2:取消，3:超时未应答，4:拒绝，5:挂断，6:接受，7:通话中断,8:其他设备已接听 12加入房间超时
        switch (_message.netCallStatus) {
            case 2://邀请者 取消了通话
            {
                if ([_message.netCallRoomCreateUser isEqualToString:UserManager.userInfo.userUID]) {
                    //我是邀请者
                    textContentStr = LanguageToolMatch(@"已取消");
                }else {
                    //我是被邀请者
                    textContentStr = LanguageToolMatch(@"对方已取消");
                }
            }
                break;
            case 3://被邀请者 超时未接听
            {
                if ([_message.netCallRoomCreateUser isEqualToString:UserManager.userInfo.userUID]) {
                    //我是邀请者
                    textContentStr = LanguageToolMatch(@"对方无应答");
                }else {
                    //我是被邀请者
                    textContentStr = LanguageToolMatch(@"超时未应答");
                }
                
            }
                break;
            case 12://加入房间超时
            {
                //可能是 邀请者超时加入 / 被邀请者超时加入
                textContentStr = LanguageToolMatch(@"超时未应答");
            }
                break;
            case 4://被邀请者 拒绝接听
            {
                if ([_message.netCallRoomCreateUser isEqualToString:UserManager.userInfo.userUID]) {
                    //我是邀请者
                    textContentStr = LanguageToolMatch(@"对方已拒绝");
                }else {
                    //我是被邀请者
                    textContentStr = LanguageToolMatch(@"已拒绝");
                }
                
            }
                break;
            case 5://通话挂断结束
            {
                if ([_message.netCallRoomCreateUser isEqualToString:UserManager.userInfo.userUID]) {
                    //我是邀请者
                    textContentStr = [NSString stringWithFormat:LanguageToolMatch(@"%@ 通话结束"), [NSString getTimeLength:_message.netCallDuration]];
                }else {
                    //我是被邀请者
                    textContentStr = [NSString stringWithFormat:LanguageToolMatch(@"通话结束 %@"), [NSString getTimeLength:_message.netCallDuration]];
                }
                
            }
                break;
            case 7://通话中断
            {
                if ([_message.netCallRoomCreateUser isEqualToString:UserManager.userInfo.userUID]) {
                    //我是邀请者
                    textContentStr = [NSString stringWithFormat:LanguageToolMatch(@"%@ 通话中断"), [NSString getTimeLength:_message.netCallDuration]];
                }else {
                    //我是被邀请者
                    textContentStr = [NSString stringWithFormat:LanguageToolMatch(@"通话中断 %@"), [NSString getTimeLength:_message.netCallDuration]];
                }
            }
                break;
            case 8://被邀请者 已在其他设备接听通话
            {
                if (![_message.netCallRoomCreateUser isEqualToString:UserManager.userInfo.userUID]) {
                    //我是被邀请者
                    textContentStr = LanguageToolMatch(@"已在其他设备接听");
                }
            }
                break;
            default:
                break;
        }
        
    }else {
        //多人音视频
        //1:发起，3:超时未应答，4:拒绝，5:挂断，6:接受，7:通话中断,8:其他设备已接听，9:邀请加入，10：主动加入，11:结束
        //群聊
        NSString *callMode;
        if (_message.netCallType == 1) {
            callMode = LanguageToolMatch(@"语音通话");
        } else {
            callMode = LanguageToolMatch(@"视频通话");
        }
        switch (_message.netCallStatus) {
            case 1://群聊音视频 发起
            {
                textContentStr = [NSString stringWithFormat:@"%@", callMode];
            }
                break;
            case 11://群聊音视频 结束
            {
                textContentStr = [NSString stringWithFormat:LanguageToolMatch(@"%@已经结束"), callMode];
            }
                break;
            default:
                break;
        }
    }
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 2;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:16],NSParagraphStyleAttributeName:[style copy]};
    self.attStr = [[NSMutableAttributedString alloc] initWithString:textContentStr];
    [self.attStr addAttributes:dict range:NSMakeRange(0, textContentStr.length)];
    
    CGSize size = [self.attStr boundingRectWithSize:CGSizeMake(DScreenWidth - 140, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    _messageWidth = MAX(ceil(size.width), 20 + 5) + 6 + DWScale(18);
    _messageHeight = DWScale(22);
    
    if(ZLanguageTOOL.isRTL){
        CGFloat width = [self.attStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width;
        _messageWidth = MIN(MAX(ceil(width), 20 + 5), DScreenWidth - 140) + 6 + DWScale(18);;
    }
    
    
    //如果要显示日期时间，还得 + 12 + 19
    if (![NSString isNil:_dataTime]) {
        _cellHeight = CellTop + _messageHeight + 9*2 + DWScale(20) + 12 + 19 + CellBottom;
    } else {
        _cellHeight = CellTop + _messageHeight + 9*2 + DWScale(20) + CellBottom;
    }
    //群聊需要显示昵称
    if (_message.chatType == CIMChatType_GroupChat) {
        _cellHeight += 18;
    }
}

#pragma mark - 计算名片消息
- (void)calculateNameCardMessage {
    self.attStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"[个人名片]")];
    
    _messageWidth = DWScale(230);
    _messageHeight = DWScale(85);
    
    //如果要显示日期时间，还得 + 12 + 19
    if (![NSString isNil:_dataTime]) {
        _cellHeight = CellTop + _messageHeight + 9*2 + DWScale(20) + 12 + 19 + CellBottom;
    } else {
        _cellHeight = CellTop + _messageHeight + 9*2 + DWScale(20) + CellBottom;
    }
    //群聊需要显示昵称
    if (_message.chatType == CIMChatType_GroupChat) {
        _cellHeight += 18;
    }
}

#pragma mark - 计算地理位置消息
- (void)calculateGeoLocationMessage {
    self.attStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"[地理位置]")];
    
    _messageWidth = DWScale(230);
    _messageHeight = DWScale(66) + DWScale(94);
    
    //如果要显示日期时间，还得 + 12 + 19
    if (![NSString isNil:_dataTime]) {
        _cellHeight = CellTop + _messageHeight + 9*2 + DWScale(20) + 12 + 19 + CellBottom;
    } else {
        _cellHeight = CellTop + _messageHeight + 9*2 + DWScale(20) + CellBottom;
    }
    //群聊需要显示昵称
    if (_message.chatType == CIMChatType_GroupChat) {
        _cellHeight += 18;
    }
}

#pragma mark - 计算合并转发的消息记录类型消息
- (void)calculateMergeMsgRecordMessage {
    self.attStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"[会话记录]")];
    
    //最多展示4条
    NSInteger max_num = _message.forwardMessage.messageListArray.count > 4 ? 4 : _message.forwardMessage.messageListArray.count;
    
    _messageWidth = DWScale(230);
    _messageHeight = 10 + DWScale(22) + DWScale(6) + DWScale(16)*max_num + DWScale(1)*max_num + 10;
    
    //如果要显示日期时间，还得 + 12 + 19
    if (![NSString isNil:_dataTime]) {
        _cellHeight = CellTop + _messageHeight + 9*2 + DWScale(20) + 12 + 19 + CellBottom;
    } else {
        _cellHeight = CellTop + _messageHeight + 9*2 + DWScale(20) + CellBottom;
    }
    //群聊需要显示昵称
    if (_message.chatType == CIMChatType_GroupChat) {
        _cellHeight += 18;
    }
}

#pragma mark - 计算系统通知消息
- (void)calculateSystemMessage {
    NSString *resutlContent = @"";
    //撤回消息通知
    if (_message.messageType == CIMChatMessageType_BackMessage) {
        //群主或者管理员撤回了群成员发的消息
        if (_message.chatType == CIMChatType_GroupChat && ![NSString isNil:_message.backDeleteExt]) {
            if ([_message.backDeleteExt isEqualToString:UserManager.userInfo.userUID]) {
                resutlContent = [NSString stringWithFormat:LanguageToolMatch(@"您的消息已被“%@”撤回"),_message.fromNickname];
            } else if ([UserManager.userInfo.userUID isEqualToString:_message.fromID]) {
                LingIMGroupMemberModel *originMessageUserModel = [IMSDKManager imSdkCheckGroupMemberWith:_message.backDeleteExt groupID:_message.toID];
                if (originMessageUserModel != nil) {
                    //群主视角
                    resutlContent = [NSString stringWithFormat:LanguageToolMatch(@"您已撤回了“%@”的消息"), originMessageUserModel.showName];
                }
            } else {
                LingIMGroupMemberModel *originMessageUserModel = [IMSDKManager imSdkCheckGroupMemberWith:_message.backDeleteExt groupID:_message.toID];
                if (originMessageUserModel != nil) {
                    resutlContent = [NSString stringWithFormat:LanguageToolMatch(@"“%@”撤回了“%@”的消息"), _message.fromNickname, originMessageUserModel.showName];
                }
            }
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineSpacing = 2;
            style.alignment = NSTextAlignmentCenter;
            NSDictionary *dict = @{NSFontAttributeName:FONTN(13),NSParagraphStyleAttributeName:[style copy]};
            self.attStr = [[NSMutableAttributedString alloc] initWithString:resutlContent];
            [self.attStr addAttributes:dict range:NSMakeRange(0, self.attStr.length)];
            //先设置全部为 66颜色
            [self.attStr configAttStrLightColor:COLOR_66 darkColor:COLOR_66_DARK range:NSMakeRange(0, resutlContent.length)];
            if ([_message.backDeleteExt isEqualToString:UserManager.userInfo.userUID]) {
                [self.attStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 range:[resutlContent rangeOfString:_message.fromNickname]];
            } else if ([UserManager.userInfo.userUID isEqualToString:_message.fromID]) {
                LingIMGroupMemberModel *originMessageUserModel = [IMSDKManager imSdkCheckGroupMemberWith:_message.backDeleteExt groupID:_message.toID];
                if (originMessageUserModel) {
                    [self.attStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 range:[resutlContent rangeOfString:originMessageUserModel.showName]];
                }
            } else {
                LingIMGroupMemberModel *originMessageUserModel = [IMSDKManager imSdkCheckGroupMemberWith:_message.backDeleteExt groupID:_message.toID];
                if (originMessageUserModel) {
                    [self.attStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 range:[resutlContent rangeOfString:_message.fromNickname]];
                    [self.attStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 range:[resutlContent rangeOfString:originMessageUserModel.showName == nil ? @"" : originMessageUserModel.showName]];
                }
            }
        } else {
            if ([_message.fromID isEqualToString:UserManager.userInfo.userUID]) {
                resutlContent = LanguageToolMatch(@"你撤回了一条消息");
            } else {
                if (_message.chatType == CIMChatType_SingleChat) {
                    resutlContent = LanguageToolMatch(@"对方撤回了一条消息");
                } else if (_message.chatType == CIMChatType_GroupChat) {
                    LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:_message.fromID groupID:_message.toID];
                    resutlContent = [NSString stringWithFormat:LanguageToolMatch(@"“%@”撤回了一条消息"), groupMemberModel ? groupMemberModel.showName : _message.fromNickname];
                } else {
                    resutlContent = @"";
                }
            }
            
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineSpacing = 2;
            style.alignment = NSTextAlignmentCenter;
            NSDictionary *dict = @{NSFontAttributeName:FONTN(13),NSParagraphStyleAttributeName:[style copy]};
            self.attStr = [[NSMutableAttributedString alloc] initWithString:resutlContent];
            [self.attStr addAttributes:dict range:NSMakeRange(0, self.attStr.length)];
            //先设置全部为 66颜色
            [self.attStr configAttStrLightColor:COLOR_66 darkColor:COLOR_66_DARK range:NSMakeRange(0, resutlContent.length)];
            if (_message.chatType == CIMChatType_GroupChat) {
                LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:_message.fromID groupID:_message.toID];
                // 用户昵称需变为蓝色
                [self.attStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 range:[resutlContent rangeOfString:groupMemberModel ? groupMemberModel.showName : _message.fromNickname]];
            }
        }
        CGSize size = [self.attStr boundingRectWithSize:CGSizeMake(DScreenWidth - 20*2, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        _messageHeight = MAX(ceil(size.height), 20);
        _messageWidth = MAX(ceil(size.width), 60);
        if(ZLanguageTOOL.isRTL){
            CGFloat width = [self.attStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width;
            _messageWidth = MIN(MAX(ceil(width), 60), DScreenWidth - 20*2);
        }
    }
    if (_message.messageType == CIMChatMessageType_ServerMessage) {
        //系统通知类消息
        [self calculateServerMsgHeight];
    }

    _cellHeight = 5 + _messageHeight + 5;
}

#pragma mark - 计算引用消息
- (void)calculateReferenceMessage {
    //当前消息文本内容
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 2;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:16],NSParagraphStyleAttributeName:[style copy]};
    if (_message.messageType == CIMChatMessageType_TextMessage) {
        //文本消息
        if (_isSelf) {
            self.attStr = [[NoaChatInputEmojiManager sharedManager] yy_emojiAttributedString:_message.textContent];
            [self.attStr configAttStrLightColor:COLORWHITE darkColor:COLORWHITE range:NSMakeRange(0, self.attStr.length)];
        } else {
            self.attStr = [[NoaChatInputEmojiManager sharedManager] yy_emojiAttributedString:![NSString isNil:_message.translateContent] ? _message.translateContent : _message.textContent];
            [self.attStr configAttStrLightColor:COLOR_11 darkColor:COLORWHITE range:NSMakeRange(0, self.attStr.length)];
        }
        [self.attStr addAttributes:dict range:NSMakeRange(0, self.attStr.length)];
    } else if (_message.messageType == CIMChatMessageType_AtMessage) {
        //如果是 At消息
        if ([NSString isNil:_message.showContent]) {
            if (_isSelf) {
                _message.showContent = [NoaMessageTools atContenTranslateToShowContent:![NSString isNil:_message.atContent] ? _message.atContent : @"" atUsersDictList:_message.atUsersInfoList withMessage:_message isGetShowName:YES];
            } else {
                _message.showContent = [NoaMessageTools atContenTranslateToShowContent:![NSString isNil:_message.atTranslateContent] ? _message.atTranslateContent : _message.atContent atUsersDictList:_message.atUsersInfoList withMessage:_message isGetShowName:YES];
            }
        }
        
        if (_isSelf) {
            _message.showTranslateContent = [NoaMessageTools atContenTranslateToShowContent:![NSString isNil:_message.atTranslateContent] ? _message.atTranslateContent : @"" atUsersDictList:_message.atUsersInfoList withMessage:_message isGetShowName:YES];
        } else {
            _message.showTranslateContent = [NoaMessageTools atContenTranslateToShowContent:![NSString isNil:_message.againAtTranslateContent] ? _message.againAtTranslateContent : _message.atTranslateContent atUsersDictList:_message.atUsersInfoList withMessage:_message isGetShowName:YES];
        }
       
        //emoij表情
        self.attStr = [[NoaChatInputEmojiManager sharedManager] attributedString:_message.showContent];
        [self.attStr addAttributes:dict range:NSMakeRange(0, self.attStr.length)];

        
        if (!_isSelf) { //非自己发送的消息
            //不是自己发的消息先全部设置为 33
            [self.attStr configAttStrLightColor:COLOR_11 darkColor:COLOR_11_DARK range:NSMakeRange(0, self.attStr.length)];
            //改变被 @用户 字体为蓝色
            for (NSDictionary *atUserDic in _message.atUsersInfoList) {
                NSArray *atKeyArr = [atUserDic allKeys];
                NSString *atKey = (NSString *)[atKeyArr firstObject];
            
                if ([atKey isEqualToString:UserManager.userInfo.userUID]) {
                    // @我
                    [self.attStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 fullStr:self.attStr.string appointStr:LanguageToolMatch(@"@我")];
                } else if ([atKey isEqualToString:@"-1"]) {
                    // @所有人
                    [self.attStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 fullStr:self.attStr.string appointStr:LanguageToolMatch(@"@所有人")];
                } else {
                    NSString *resultValue = [NSString stringWithFormat:@"@%@", [atUserDic objectForKey:atKey]];
                    // @昵称
                    [self.attStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 fullStr:self.attStr.string appointStr:resultValue];
                }
            }
        } else {
            //自己发的消息，全部设置为 白色
            [self.attStr configAttStrLightColor:COLORWHITE darkColor:COLORWHITE range:NSMakeRange(0, self.attStr.length)];
        }
    } else {
        self.attStr = [[NoaChatInputEmojiManager sharedManager] attributedString:_message.textContent];
        [self.attStr addAttributes:dict range:NSMakeRange(0, self.attStr.length)];
    }
    
    //计算文字内存尺寸
    CGSize size = [YYTextLayout layoutWithContainerSize:CGSizeMake(DScreenWidth - 140, CGFLOAT_MAX) text:self.attStr].textBoundingSize;
    //CGSize size = [self.attStr boundingRectWithSize:CGSizeMake(DScreenWidth - 140, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    //译文
    if (_message.translateStatus == CIMTranslateStatusSuccess) {
        if (_isSelf) {
            if (_message.messageType == CIMChatMessageType_TextMessage) {
                if (![NSString isNil:_message.translateContent]) {
                    self.translateAttStr = [[NoaChatInputEmojiManager sharedManager] yy_emojiAttributedString:_message.translateContent];
                    [self.translateAttStr addAttributes:dict range:NSMakeRange(0, self.translateAttStr.length)];
                    
                    [self.translateAttStr configAttStrLightColor:COLORWHITE darkColor:COLORWHITE range:NSMakeRange(0, self.translateAttStr.length)];
                    
                    CGSize translateSize = [YYTextLayout layoutWithContainerSize:CGSizeMake(DScreenWidth - 140, CGFLOAT_MAX) text:self.translateAttStr].textBoundingSize;
                    //CGSize translateSize = [self.translateAttStr boundingRectWithSize:CGSizeMake(DScreenWidth - 140, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
                    _translateMessageHeight = MAX(ceil(translateSize.height), 20 + 5);
                    _translateMessageWidth = MAX(ceil(translateSize.width > (DScreenWidth - 140) ? (DScreenWidth - 140) : translateSize.width), 20 + 5);
                } else {
                    _translateMessageHeight = 0;
                    _translateMessageWidth =  0;
                }
            }
            if (_message.messageType == CIMChatMessageType_AtMessage) {
                if (![NSString isNil:_message.atTranslateContent]) {
                    if ([NSString isNil:_message.showTranslateContent]) {
                        _message.showTranslateContent = [NoaMessageTools atContenTranslateToShowContent:_message.atTranslateContent == nil ? @"" : _message.atTranslateContent atUsersDictList:_message.atUsersInfoList withMessage:_message isGetShowName:YES];
                    }
                    self.translateAttStr = [[NoaChatInputEmojiManager sharedManager] yy_emojiAttributedString:_message.showTranslateContent];
                    [self.translateAttStr addAttributes:dict range:NSMakeRange(0, self.translateAttStr.length)];
                    
                    [self.translateAttStr configAttStrLightColor:COLORWHITE darkColor:COLORWHITE range:NSMakeRange(0, self.translateAttStr.length)];
                    
                    CGSize translateSize = [YYTextLayout layoutWithContainerSize:CGSizeMake(DScreenWidth - 140, CGFLOAT_MAX) text:self.translateAttStr].textBoundingSize;
                    //CGSize translateSize = [self.translateAttStr boundingRectWithSize:CGSizeMake(DScreenWidth - 140, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
                    _translateMessageHeight = MAX(ceil(translateSize.height), 20 + 5);
                    _translateMessageWidth = MAX(ceil(translateSize.width > (DScreenWidth - 140) ? (DScreenWidth - 140) : translateSize.width), 20 + 5);
                } else {
                    _translateMessageHeight = 0;
                    _translateMessageWidth =  0;
                }
            }
        } else {
            if (_message.messageType == CIMChatMessageType_TextMessage) {
                if (![NSString isNil:_message.againTranslateContent]) {
                    self.translateAttStr = [[NoaChatInputEmojiManager sharedManager] yy_emojiAttributedString:![NSString isNil:_message.againTranslateContent] ? _message.againTranslateContent : _message.translateContent];
                    [self.translateAttStr configAttStrLightColor:COLOR_11 darkColor:COLOR_11_DARK range:NSMakeRange(0, self.translateAttStr.length)];
                    
                    CGSize translateSize = [YYTextLayout layoutWithContainerSize:CGSizeMake(DScreenWidth - 140, CGFLOAT_MAX) text:self.translateAttStr].textBoundingSize;
                    //CGSize translateSize = [self.translateAttStr boundingRectWithSize:CGSizeMake(DScreenWidth - 140, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
                    _translateMessageHeight = MAX(ceil(translateSize.height), 20 + 5);
                    _translateMessageWidth = MAX(ceil(translateSize.width > (DScreenWidth - 140) ? (DScreenWidth - 140) : translateSize.width), 20 + 5);
                } else {
                    _translateMessageHeight = 0;
                    _translateMessageWidth =  0;
                }
            }
            if (_message.messageType == CIMChatMessageType_AtMessage) {
                if (![NSString isNil:_message.againTranslateContent]) {
                    self.translateAttStr = [[NoaChatInputEmojiManager sharedManager] yy_emojiAttributedString:_message.showTranslateContent];
                    [self.translateAttStr configAttStrLightColor:COLOR_11 darkColor:COLOR_11_DARK range:NSMakeRange(0, self.translateAttStr.length)];
                    //改变被 @用户 字体为蓝色
                    for (NSDictionary *atUserDic in _message.atUsersInfoList) {
                        NSArray *atKeyArr = [atUserDic allKeys];
                        NSString *atKey = (NSString *)[atKeyArr firstObject];
                    
                        if ([atKey isEqualToString:UserManager.userInfo.userUID]) {
                            // @我
                            [self.translateAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 fullStr:self.translateAttStr.string appointStr:LanguageToolMatch(@"@我")];
                        } else if ([atKey isEqualToString:@"-1"]) {
                            // @所有人
                            [self.translateAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 fullStr:self.translateAttStr.string appointStr:LanguageToolMatch(@"@所有人")];
                        } else {
                            // @其他用户 显示 @昵称
                            NSString *resultValue;
                            if(_message.chatType == CIMChatType_GroupChat){
                                LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:atKey groupID:_message.toID];
                                resultValue = [NSString stringWithFormat:@"@%@",groupMemberModel ? groupMemberModel.showName : [atUserDic objectForKeySafe:atKey]];
                            }else{
                                LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:atKey];
                                resultValue = [NSString stringWithFormat:@"@%@", friendModel ? friendModel.nickname : [atUserDic objectForKeySafe:atKey]];
                            }
                            [self.translateAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 fullStr:self.translateAttStr.string appointStr:resultValue];
                        }
                    }
                    CGSize translateSize = [YYTextLayout layoutWithContainerSize:CGSizeMake(DScreenWidth - 140, CGFLOAT_MAX) text:self.translateAttStr].textBoundingSize;
                    //CGSize translateSize = [self.translateAttStr boundingRectWithSize:CGSizeMake(DScreenWidth - 140, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
                    _translateMessageHeight = MAX(ceil(translateSize.height), 20 + 5);
                    _translateMessageWidth = MAX(ceil(translateSize.width > (DScreenWidth - 140) ? (DScreenWidth - 140) : translateSize.width), 20 + 5);
                } else {
                    _translateMessageHeight = 0;
                    _translateMessageWidth =  0;
                }
            }
        }
    } else if (_message.translateStatus == CIMTranslateStatusLoading) {
        _translateMessageHeight = MAX(ceil(DWScale(36)), 20 + 5);
        _translateMessageWidth =  MAX(ceil(DWScale(40)), 20 + 5);
    } else if (_message.translateStatus == CIMTranslateStatusFail) {
        _translateMessageHeight = MAX(ceil(DWScale(36)), 20 + 5);
        _translateMessageWidth =  MAX(ceil(DWScale(90)), 20 + 5);
    } else {
        _translateMessageHeight = 0;
        _translateMessageWidth =  0;
    }
    
    if(ZLanguageTOOL.isRTL){
        if (![NSString isNil:_message.translateContent]) {
            CGFloat translateWidth = [self.translateAttStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width;
            _translateMessageWidth = MIN(MAX(ceil(translateWidth), 20 + 5), DScreenWidth - 140);
        }
    }
    
    //计算引用消息
    CGSize referenceSize;
    CGFloat referenceNickWidth;
    if (_referenceMsg == nil) {
        //被引用的消息查找不到
        NSDictionary *referenceDict = @{NSFontAttributeName:[UIFont systemFontOfSize:12],NSParagraphStyleAttributeName:[style copy]};
        self.referenceAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"该引用不存在")];
        [self.referenceAttStr addAttributes:referenceDict range:NSMakeRange(0, self.referenceAttStr.length)];
        //引用消息size
        referenceSize = [self.referenceAttStr boundingRectWithSize:CGSizeMake(DScreenWidth - 140 - 6, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        if (referenceSize.height > 34) {
            _referenceMsgHeight = 17 + 34 + 6;
        } else {
            _referenceMsgHeight = 17 + referenceSize.height + 6;
        }
        //昵称
        referenceNickWidth = [LanguageToolMatch(@"未知") widthForFont:FONTN(12)];
    } else {
        if (_referenceMsg.messageType == CIMChatMessageType_TextMessage) {
            //引用文本消息
            NSDictionary *referenceDict = @{NSFontAttributeName:[UIFont systemFontOfSize:12],NSParagraphStyleAttributeName:[style copy]};
            if (_referenceMsg == nil) {
                self.referenceAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"该引用不存在")];
            } else {
                if (_referenceMsg.messageStatus == 1) { //正常
                    if ([_referenceMsg.fromID isEqualToString:UserManager.userInfo.userUID]) {
                        self.referenceAttStr = [[NoaChatInputEmojiManager sharedManager] attributedString:_referenceMsg.textContent];
                    } else {
                        NSString *resultStr = @"";
                        if (![NSString isNil:_referenceMsg.againTranslateContent]) {
                            resultStr = _referenceMsg.againTranslateContent;
                        } else {
                            if (![NSString isNil:_referenceMsg.translateContent]) {
                                resultStr = _referenceMsg.translateContent;
                            } else {
                                resultStr = _referenceMsg.textContent;
                            }
                        }
                        
                        self.referenceAttStr = [[NoaChatInputEmojiManager sharedManager] attributedString:resultStr];
                    }
                } else if (_referenceMsg.messageStatus == 0) {  //已删除
                    self.referenceAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"该引用已删除")];
                } else if (_referenceMsg.messageStatus == 2) {  //已撤回
                    self.referenceAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"该引用已撤回")];
                }  else {
                    self.referenceMsg.fromNickname = LanguageToolMatch(@"未知");
                    self.referenceAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"未知错误")];
                }
            }
            [self.referenceAttStr addAttributes:referenceDict range:NSMakeRange(0, self.referenceAttStr.length)];
            if (!_isSelf) {
                [self.referenceAttStr configAttStrLightColor:COLOR_99 darkColor:COLOR_99_DARK range:NSMakeRange(0, self.referenceAttStr.length)];
            } else {
                [self.referenceAttStr configAttStrLightColor:COLORWHITE darkColor:COLORWHITE range:NSMakeRange(0, self.referenceAttStr.length)];
            }
            //引用消息size
            referenceSize = [self.referenceAttStr boundingRectWithSize:CGSizeMake(DScreenWidth - 140 - 6, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            if (referenceSize.height > 34) {
                _referenceMsgHeight = 17 + 34 + 6;
            } else {
                _referenceMsgHeight = 17 + referenceSize.height + 6;
            }
        } else if (_referenceMsg.messageType == CIMChatMessageType_ImageMessage || _referenceMsg.messageType == CIMChatMessageType_VideoMessage || _referenceMsg.messageType == CIMChatMessageType_StickersMessage || _referenceMsg.messageType == CIMChatMessageType_GameStickersMessage) {
            //引用 图片/视频/表情 消息
            if (_referenceMsg.messageStatus == 1) { //正常
                referenceSize.width = DWScale(50);
                referenceSize.height = DWScale(50);
                _referenceMsgHeight = 17 + 4 + referenceSize.height + 10;
            } else {
                NSDictionary *referenceDict = @{NSFontAttributeName:[UIFont systemFontOfSize:12],NSParagraphStyleAttributeName:[style copy]};
                if (_referenceMsg.messageStatus == 0) {  //已删除
                    self.referenceAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"该引用已删除")];
                } else if (_referenceMsg.messageStatus == 2) {  //已撤回
                    self.referenceAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"该引用已撤回")];
                }  else {
                    self.referenceMsg.fromNickname = LanguageToolMatch(@"未知");
                    self.referenceAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"未知错误")];
                }
                [self.referenceAttStr addAttributes:referenceDict range:NSMakeRange(0, self.referenceAttStr.length)];
                //引用消息size
                referenceSize = [self.referenceAttStr boundingRectWithSize:CGSizeMake(DScreenWidth - 140 - 6, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
                if (referenceSize.height > 34) {
                    _referenceMsgHeight = 17 + 34 + 6;
                } else {
                    _referenceMsgHeight = 17 + referenceSize.height + 6;
                }
            }
        } else if (_referenceMsg.messageType == CIMChatMessageType_AtMessage) {
            //引用 @消息
            NSDictionary *referenceDict = @{NSFontAttributeName:[UIFont systemFontOfSize:12],NSParagraphStyleAttributeName:[style copy]};
            if (_referenceMsg == nil) {
                self.referenceAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"该引用不存在")];
            } else {
                if (_referenceMsg.messageStatus == 1) { //正常
                    NSString *atContentStr = @"";
                    if ([_referenceMsg.fromID isEqualToString:UserManager.userInfo.userUID]) {
                        atContentStr = [NoaMessageTools atContenTranslateToShowContent:_referenceMsg.atContent atUsersDictList:_referenceMsg.atUsersInfoList withMessage:_referenceMsg isGetShowName:YES];
                        self.referenceAttStr = [[NoaChatInputEmojiManager sharedManager] attributedString:atContentStr];
                    } else {
                        NSString *resultStr = @"";
                        if (![NSString isNil:_referenceMsg.againAtTranslateContent]) {
                            resultStr = _referenceMsg.atTranslateContent;
                        } else {
                            if (![NSString isNil:_referenceMsg.atTranslateContent]) {
                                resultStr = _referenceMsg.atTranslateContent;
                            } else {
                                resultStr = _referenceMsg.atContent;
                            }
                        }
                        
                        atContentStr = [NoaMessageTools atContenTranslateToShowContent:resultStr atUsersDictList:_referenceMsg.atUsersInfoList withMessage:_referenceMsg isGetShowName:YES];
                        self.referenceAttStr = [[NoaChatInputEmojiManager sharedManager] attributedString:atContentStr];
                    }
                } else if (_referenceMsg.messageStatus == 0) {  //已删除
                    self.referenceAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"该引用已删除")];
                } else if (_referenceMsg.messageStatus == 2) {  //已撤回
                    self.referenceAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"该引用已撤回")];
                }  else {
                    self.referenceMsg.fromNickname = LanguageToolMatch(@"未知");
                    self.referenceAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"未知错误")];
                }
            }
            [self.referenceAttStr addAttributes:referenceDict range:NSMakeRange(0, self.referenceAttStr.length)];
            if (!_isSelf) {
                [self.referenceAttStr configAttStrLightColor:COLOR_99 darkColor:COLOR_99_DARK range:NSMakeRange(0, self.referenceAttStr.length)];
            } else {
                [self.referenceAttStr configAttStrLightColor:COLORWHITE darkColor:COLORWHITE range:NSMakeRange(0, self.referenceAttStr.length)];
            }
            //引用消息size
            referenceSize = [self.referenceAttStr boundingRectWithSize:CGSizeMake(DScreenWidth - 140 - 6, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            if (referenceSize.height > 34) {
                _referenceMsgHeight = 17 + 34 + 6;
            } else {
                _referenceMsgHeight = 17 + referenceSize.height + 6;
            }
        } else if (_referenceMsg.messageType == CIMChatMessageType_VoiceMessage || _referenceMsg.messageType == CIMChatMessageType_FileMessage) {
            //引用语音消息、文件消息
            NSDictionary *referenceDict = @{NSFontAttributeName:[UIFont systemFontOfSize:12],NSParagraphStyleAttributeName:[style copy]};
            if (_referenceMsg == nil) {
                self.referenceAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"该引用不存在")];
            } else {
                if (_referenceMsg.messageStatus == 1) { //正常
                    NSString *referenceContentStr;
                    if (_referenceMsg.messageType == CIMChatMessageType_VoiceMessage) {
                        referenceContentStr = LanguageToolMatch(@"[语音]");
                    } else {
                        referenceContentStr = _referenceMsg.showFileName;
                    }
                    self.referenceAttStr = [[NoaChatInputEmojiManager sharedManager] attributedString:referenceContentStr];
                } else if (_referenceMsg.messageStatus == 0) {  //已删除
                    self.referenceAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"该引用已删除")];
                } else if (_referenceMsg.messageStatus == 2) {  //已撤回
                    self.referenceAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"该引用已撤回")];
                }  else {
                    self.referenceMsg.fromNickname = LanguageToolMatch(@"未知");
                    self.referenceAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"未知错误")];
                }
            }
            [self.referenceAttStr addAttributes:referenceDict range:NSMakeRange(0, self.referenceAttStr.length)];
            if (!_isSelf) {
                [self.referenceAttStr configAttStrLightColor:COLOR_99 darkColor:COLOR_99_DARK range:NSMakeRange(0, self.referenceAttStr.length)];
            } else {
                [self.referenceAttStr configAttStrLightColor:COLORWHITE darkColor:COLORWHITE range:NSMakeRange(0, self.referenceAttStr.length)];
            }
            //引用消息size
            referenceSize = [self.referenceAttStr boundingRectWithSize:CGSizeMake(DScreenWidth - 140 - 6, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            if (referenceSize.height > 34) {
                _referenceMsgHeight = 17 + 34 + 6;
            } else {
                _referenceMsgHeight = 17 + referenceSize.height + 6;
            }
        } else if (_referenceMsg.messageType == CIMChatMessageType_CardMessage) {
            //引用名片消息
            NSDictionary *referenceDict = @{NSFontAttributeName:[UIFont systemFontOfSize:12],NSParagraphStyleAttributeName:[style copy]};
            if (_referenceMsg == nil) {
                self.referenceAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"该引用不存在")];
            } else {
                if (_referenceMsg.messageStatus == 1) { //正常
                    NSString *referenceContentStr = [NSString stringWithFormat:@"%@%@", LanguageToolMatch(@"[个人名片]"), _referenceMsg.cardNickName];
                    self.referenceAttStr = [[NoaChatInputEmojiManager sharedManager] attributedString:referenceContentStr];
                } else if (_referenceMsg.messageStatus == 0) {  //已删除
                    self.referenceAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"该引用已删除")];
                } else if (_referenceMsg.messageStatus == 2) {  //已撤回
                    self.referenceAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"该引用已撤回")];
                }  else {
                    self.referenceMsg.fromNickname = LanguageToolMatch(@"未知");
                    self.referenceAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"未知错误")];
                }
            }
            [self.referenceAttStr addAttributes:referenceDict range:NSMakeRange(0, self.referenceAttStr.length)];
            if (!_isSelf) {
                [self.referenceAttStr configAttStrLightColor:COLOR_99 darkColor:COLOR_99_DARK range:NSMakeRange(0, self.referenceAttStr.length)];
            } else {
                [self.referenceAttStr configAttStrLightColor:COLORWHITE darkColor:COLORWHITE range:NSMakeRange(0, self.referenceAttStr.length)];
            }
            //引用消息size
            referenceSize = [self.referenceAttStr boundingRectWithSize:CGSizeMake(DScreenWidth - 140 - 6, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            if (referenceSize.height > 34) {
                _referenceMsgHeight = 17 + 34 + 6;
            } else {
                _referenceMsgHeight = 17 + referenceSize.height + 6;
            }
        } else if (_referenceMsg.messageType == CIMChatMessageType_GeoMessage) {
            //引用地理位置消息
            NSDictionary *referenceDict = @{NSFontAttributeName:[UIFont systemFontOfSize:12],NSParagraphStyleAttributeName:[style copy]};
            if (_referenceMsg == nil) {
                self.referenceAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"该引用不存在")];
            } else {
                if (_referenceMsg.messageStatus == 1) { //正常
                    NSString *referenceContentStr = [NSString stringWithFormat:@"%@%@", LanguageToolMatch(@"[位置]"), _referenceMsg.geoName];
                    self.referenceAttStr = [[NoaChatInputEmojiManager sharedManager] attributedString:referenceContentStr];
                } else if (_referenceMsg.messageStatus == 0) {  //已删除
                    self.referenceAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"该引用已删除")];
                } else if (_referenceMsg.messageStatus == 2) {  //已撤回
                    self.referenceAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"该引用已撤回")];
                }  else {
                    self.referenceMsg.fromNickname = LanguageToolMatch(@"未知");
                    self.referenceAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"未知错误")];
                }
            }
            [self.referenceAttStr addAttributes:referenceDict range:NSMakeRange(0, self.referenceAttStr.length)];
            if (!_isSelf) {
                [self.referenceAttStr configAttStrLightColor:COLOR_99 darkColor:COLOR_99_DARK range:NSMakeRange(0, self.referenceAttStr.length)];
            } else {
                [self.referenceAttStr configAttStrLightColor:COLORWHITE darkColor:COLORWHITE range:NSMakeRange(0, self.referenceAttStr.length)];
            }
            //引用消息size
            referenceSize = [self.referenceAttStr boundingRectWithSize:CGSizeMake(DScreenWidth - 140 - 6, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            if (referenceSize.height > 34) {
                _referenceMsgHeight = 17 + 34 + 6;
            } else {
                _referenceMsgHeight = 17 + referenceSize.height + 6;
            }
        } else if (_referenceMsg.messageType == CIMChatMessageType_ForwardMessage) {
            //引用消息记录类型消息
            NSDictionary *referenceDict = @{NSFontAttributeName:[UIFont systemFontOfSize:12],NSParagraphStyleAttributeName:[style copy]};
            if (_referenceMsg == nil) {
                self.referenceAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"该引用不存在")];
            } else {
                if (_referenceMsg.messageStatus == 1) { //正常
                    NSString *referenceContentStr = [NSString stringWithFormat:@"%@%@", LanguageToolMatch(@"[会话记录]"), _referenceMsg.forwardMessage.title];
                    self.referenceAttStr = [[NoaChatInputEmojiManager sharedManager] attributedString:referenceContentStr];
                } else if (_referenceMsg.messageStatus == 0) {  //已删除
                    self.referenceAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"该引用已删除")];
                } else if (_referenceMsg.messageStatus == 2) {  //已撤回
                    self.referenceAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"该引用已撤回")];
                }  else {
                    self.referenceMsg.fromNickname = LanguageToolMatch(@"未知");
                    self.referenceAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"未知错误")];
                }
            }
            [self.referenceAttStr addAttributes:referenceDict range:NSMakeRange(0, self.referenceAttStr.length)];
            if (!_isSelf) {
                [self.referenceAttStr configAttStrLightColor:COLOR_99 darkColor:COLOR_99_DARK range:NSMakeRange(0, self.referenceAttStr.length)];
            } else {
                [self.referenceAttStr configAttStrLightColor:COLORWHITE darkColor:COLORWHITE range:NSMakeRange(0, self.referenceAttStr.length)];
            }
            //引用消息size
            referenceSize = [self.referenceAttStr boundingRectWithSize:CGSizeMake(DScreenWidth - 140 - 6, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            if (referenceSize.height > 34) {
                _referenceMsgHeight = 17 + 34 + 6;
            } else {
                _referenceMsgHeight = 17 + referenceSize.height + 6;
            }
        }  else {
            //引用视频消息
            referenceSize.width = CGFLOAT_MIN;
            referenceSize.height = CGFLOAT_MIN;
            
            _referenceMsgHeight = CGFLOAT_MIN;
        }
        
        //被引用消息发送者的昵称
        NSString *refreshMsgNick = _referenceMsg.fromNickname;
        //别人发的消息
        if (_referenceMsg.chatType == CIMChatType_GroupChat) {
            //群聊
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:_referenceMsg.fromID groupID:_referenceMsg.toID];
            if (groupMemberModel) {
                refreshMsgNick = [NSString loadNickNameWithUserStatus:groupMemberModel.disableStatus realNickName:groupMemberModel.showName];
            }
        } else {
            //单聊
            if ([_referenceMsg.fromID isEqualToString:UserManager.userInfo.userUID]) {
                //自己发的消息
                refreshMsgNick = UserManager.userInfo.nickname;
            } else {
                LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:_referenceMsg.fromID];
                if (friendModel) {
                    refreshMsgNick = [NSString loadNickNameWithUserStatus:friendModel.disableStatus realNickName:friendModel.showName];
                }
            }
        }
        _referenceMsg.fromNickname = refreshMsgNick;
        //获取被引用消息发送者昵称size
        referenceNickWidth = [refreshMsgNick widthForFont:FONTN(12)];
    }
 
    //计算气泡宽度
    CGFloat tempMsgWidth = size.width;
    if (tempMsgWidth < (referenceNickWidth + 2 + DWScale(10) + 5)) {
        tempMsgWidth = referenceNickWidth + + 2 + DWScale(10) + 5;
    }
    if (tempMsgWidth < (referenceSize.width  + 2 + DWScale(10) + 5)) {
        tempMsgWidth = referenceSize.width + 2 + DWScale(10) + 5;
    }
    if (tempMsgWidth < _translateMessageWidth) {
        tempMsgWidth = _translateMessageWidth;
    }
    
    if (tempMsgWidth > (DScreenWidth - 140)) {
        tempMsgWidth = (DScreenWidth - 140);
    }
    _messageHeight = MAX(ceil(size.height + _referenceMsgHeight), 20 + 5);
    _messageWidth = MAX(ceil(tempMsgWidth), 20 + 5);
  
    
    //如果要显示日期时间，还得 + 12 + 19
    if (![NSString isNil:_dataTime]) {
        _cellHeight = CellTop + _messageHeight + _translateMessageHeight + DWScale(3) + 9*2 + DWScale(20) + 12 + 19 + CellBottom;
    } else {
        _cellHeight = CellTop + _messageHeight + _translateMessageHeight + DWScale(3) + 9*2 + DWScale(20) + CellBottom;
    }
    //群聊需要显示昵称
    if (_message.chatType == CIMChatType_GroupChat) {
        _cellHeight += 18;
    }
}

#pragma mark - 单独计算 ServerMessage
- (void)calculateServerMsgHeight {
    NSMutableAttributedString *serverMsgAttStr;
    switch (_message.serverMessage.sMsgType) {
        case IMServerMessage_ServerMsgType_NullFriendMessage://好友不存在 该消息转发给发送消息的用户
        {
            NSString *msgContent = LanguageToolMatch(@"您还不是对方好友，请先添加好友。");
            serverMsgAttStr = [[NSMutableAttributedString alloc] initWithString:msgContent];
            //全部先设置为 66
            [serverMsgAttStr configAttStrLightColor:COLOR_66 darkColor:COLOR_66_DARK range:NSMakeRange(0, msgContent.length)];
            //需要突出的地方设置为 COLOR_5966F2
            [serverMsgAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 range:[msgContent rangeOfString:LanguageToolMatch(@"添加好友")]];
        }
            break;
        case IMServerMessage_ServerMsgType_BlackFriendMessage://好友黑名单
        {
            FriendBlackMessage *friendBlack = _message.serverMessage.friendBlackMessage;
            NSString *msgContent;
            if (friendBlack.type == 1) {
                //我拉黑好友
                msgContent = LanguageToolMatch(@"已拉黑");
            }else {
                //好友拉黑我
                msgContent = LanguageToolMatch(@"对方已拒绝接受你的消息");
            }
            serverMsgAttStr = [[NSMutableAttributedString alloc] initWithString:msgContent];
            [serverMsgAttStr configAttStrLightColor:COLOR_66 darkColor:COLOR_66_DARK range:NSMakeRange(0, msgContent.length)];
        }
            break;
        case IMServerMessage_ServerMsgType_UserAccountClose://好友 账号已注销
        {
            //UserAccountClose *accountClose = _message.serverMessage.userAccountClose;
            NSString *msgContent;
            msgContent = LanguageToolMatch(@"账号已注销");
            serverMsgAttStr = [[NSMutableAttributedString alloc] initWithString:msgContent];
            [serverMsgAttStr configAttStrLightColor:COLOR_66 darkColor:COLOR_66_DARK range:NSMakeRange(0, msgContent.length)];
        }
            break;
        case IMServerMessage_ServerMsgType_CreateGroupMessage://创建群聊
        {
            //群聊创建成功
            CreateGroupMessage *createModel = _message.serverMessage.createGroupMessage;
            LingIMGroupMemberModel *groupMemberCreateModel = [IMSDKManager imSdkCheckGroupMemberWith:createModel.uid groupID:createModel.gid];
            NSString *user;
            if ([createModel.uid isEqualToString:UserManager.userInfo.userUID]) {
                //我创建的群聊
                user = LanguageToolMatch(@"你邀请了 ");
            }
            
            __block NSMutableString *invitedUserNameStr = [NSMutableString string];
            NSArray *invitedMemberArr = createModel.inviteUidArray;
            [invitedMemberArr enumerateObjectsUsingBlock:^(UserInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![obj.uId isEqualToString:createModel.uid]) {
                    LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:obj.uId];
                    if (friendModel) {
                        [invitedUserNameStr appendFormat:@"“%@”", friendModel ? friendModel.showName: obj.uNick];
                    } else {
                        LingIMGroupMemberModel *memberModel = [IMSDKManager imSdkCheckGroupMemberWith:obj.uId groupID:createModel.gid];
                        [invitedUserNameStr appendFormat:@"“%@”", memberModel ? memberModel.showName: obj.uNick];
                    }
                }
            }];
            NSString *msgContent = [NSString stringWithFormat:LanguageToolMatch(@"%@%@ 加入了群聊"),user, invitedUserNameStr];
            serverMsgAttStr = [[NSMutableAttributedString alloc] initWithString:msgContent];
            
            //富文本处理，颜色处理
            [serverMsgAttStr configAttStrLightColor:COLOR_66 darkColor:COLOR_66_DARK range:NSMakeRange(0, msgContent.length)];
            if (![createModel.uid isEqualToString:UserManager.userInfo.userUID]) {
                [serverMsgAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 range:[msgContent rangeOfString:groupMemberCreateModel ? groupMemberCreateModel.showName : createModel.nick]];
            }
            for (UserInfo *obj in invitedMemberArr) {
                if (![obj.uId isEqualToString:createModel.uid]) {
                    LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:obj.uId];
                    if (friendModel) {
                        [serverMsgAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 fullStr:msgContent appointStr:friendModel ? friendModel.showName: obj.uNick];
                    } else {
                        LingIMGroupMemberModel *memberModel = [IMSDKManager imSdkCheckGroupMemberWith:obj.uId groupID:createModel.gid];
                        [serverMsgAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 fullStr:msgContent appointStr:memberModel ? memberModel.showName : obj.uNick];
                    }
                }
            }
        }
            break;
        case IMServerMessage_ServerMsgType_InviteConfirmGroupMessage://邀请进群
        {
            InviteConfirmGroupMessage *inviteModel = _message.serverMessage.inviteConfirmGroupMessage;
            if (inviteModel.type == 5) {
                //邀请机器人进群
                return;
            }
            LingIMGroupMemberModel *groupMemberInviteModel = [IMSDKManager imSdkCheckGroupMemberWith:inviteModel.uid groupID:inviteModel.gid];
            if (inviteModel.type == 4) {
                //“xxx”通过扫描二维码加入群聊
                __block NSMutableString *invitedUserNameStr = [NSMutableString string];
                NSArray *invitedMemberArr = inviteModel.inviteUidArray;
                [invitedMemberArr enumerateObjectsUsingBlock:^(UserInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj.uId isEqualToString:UserManager.userInfo.userUID]) {
                        [invitedUserNameStr appendFormat:@"%@", LanguageToolMatch(@"你")];
                    }else {
                        LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:obj.uId];
                        if (friendModel) {
                            [invitedUserNameStr appendFormat:@"“%@”", friendModel ? friendModel.showName: obj.uNick];
                        } else {
                            [invitedUserNameStr appendFormat:@"“%@”",obj.uNick];
                        }
                    }
                }];
                NSString *msgContent = [NSString stringWithFormat:LanguageToolMatch(@"%@通过扫描二维码加入群聊"), invitedUserNameStr];
                serverMsgAttStr = [[NSMutableAttributedString alloc] initWithString:msgContent];
                //富文本处理，颜色处理
                [serverMsgAttStr configAttStrLightColor:COLOR_66 darkColor:COLOR_66_DARK range:NSMakeRange(0, msgContent.length)];
                for (UserInfo *obj in invitedMemberArr) {
                    if (![obj.uId isEqualToString:UserManager.userInfo.userUID]) {
                        LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:obj.uId];
                        if (friendModel) {
                            [invitedUserNameStr appendFormat:@"“%@”", friendModel ? friendModel.showName: obj.uNick];
                            [serverMsgAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 fullStr:msgContent appointStr:friendModel ? friendModel.showName: obj.uNick];
                        } else {
                            [serverMsgAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 fullStr:msgContent appointStr:obj.uNick];
                        }
                    }
                }
            } else {
                NSString *user;
                if ([inviteModel.uid isEqualToString:UserManager.userInfo.userUID]) {
                    //我发起的邀请
                    user = LanguageToolMatch(@"你邀请了 ");
                }else {
                    user = [NSString stringWithFormat:LanguageToolMatch(@"“%@”邀请了 "), groupMemberInviteModel ? groupMemberInviteModel.showName : inviteModel.nick];
                }
                
                __block NSMutableString *invitedUserNameStr = [NSMutableString string];
                NSArray *invitedMemberArr = inviteModel.inviteUidArray;
                [invitedMemberArr enumerateObjectsUsingBlock:^(UserInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj.uId isEqualToString:UserManager.userInfo.userUID]) {
                        [invitedUserNameStr appendFormat:@"%@", LanguageToolMatch(@"你")];
                    }else {
                        LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:obj.uId];
                        if (friendModel) {
                            [invitedUserNameStr appendFormat:@"“%@”", friendModel ? friendModel.showName: obj.uNick];
                        } else {
                            LingIMGroupMemberModel *memberModel = [IMSDKManager imSdkCheckGroupMemberWith:obj.uId groupID:inviteModel.gid];
                            [invitedUserNameStr appendFormat:@"“%@”", memberModel ? memberModel.showName : obj.uNick];
                        }
                    }
                }];
                NSString *msgContent = [NSString stringWithFormat:LanguageToolMatch(@"%@%@ 加入了群聊"),user, invitedUserNameStr];
                serverMsgAttStr = [[NSMutableAttributedString alloc] initWithString:msgContent];
                
                //富文本处理，颜色处理
                [serverMsgAttStr configAttStrLightColor:COLOR_66 darkColor:COLOR_66_DARK range:NSMakeRange(0, msgContent.length)];
                if (![inviteModel.uid isEqualToString:UserManager.userInfo.userUID]) {
                    [serverMsgAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 range:[msgContent rangeOfString:groupMemberInviteModel ? groupMemberInviteModel.showName : inviteModel.nick]];
                }
                for (UserInfo *obj in invitedMemberArr) {
                    if (![obj.uId isEqualToString:UserManager.userInfo.userUID]) {
                        LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:obj.uId];
                        if (friendModel) {
                            [invitedUserNameStr appendFormat:@"“%@”", friendModel ? friendModel.showName: obj.uNick];
                            [serverMsgAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 fullStr:msgContent appointStr:friendModel ? friendModel.showName : obj.uNick];
                        } else {
                            LingIMGroupMemberModel *memberModel = [IMSDKManager imSdkCheckGroupMemberWith:obj.uId groupID:inviteModel.gid];
                            [serverMsgAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 fullStr:msgContent appointStr:memberModel ? memberModel.showName : obj.uNick];
                        }
                    }
                }
            }
        }
            break;
        case IMServerMessage_ServerMsgType_GroupNoChatMessage://告知发消息的用户，群禁言已开启
        {
            NSString *msgContent = LanguageToolMatch(@"该群开启了全员禁言");
            serverMsgAttStr = [[NSMutableAttributedString alloc] initWithString:msgContent];
            [serverMsgAttStr configAttStrLightColor:COLOR_66 darkColor:COLOR_66_DARK range:NSMakeRange(0, msgContent.length)];
        }
            break;
        case IMServerMessage_ServerMsgType_NullGroupMessage://群组不存在
        {
            NSString *msgContent = LanguageToolMatch(@"群组已解散");
            serverMsgAttStr = [[NSMutableAttributedString alloc] initWithString:msgContent];
            [serverMsgAttStr configAttStrLightColor:COLOR_66 darkColor:COLOR_66_DARK range:NSMakeRange(0, msgContent.length)];
        }
            break;
        case IMServerMessage_ServerMsgType_MemberNoGroupMessage://用户不在群内
        {
            NSString *msgContent = LanguageToolMatch(@"你已不在该群");
            serverMsgAttStr = [[NSMutableAttributedString alloc] initWithString:msgContent];
            [serverMsgAttStr configAttStrLightColor:COLOR_66 darkColor:COLOR_66_DARK range:NSMakeRange(0, msgContent.length)];
        }
            break;
        case IMServerMessage_ServerMsgType_MemberGroupForbidMessage://用户在群组内被禁言
        {
            NSString *msgContent = LanguageToolMatch(@"你已被禁言");
            serverMsgAttStr = [[NSMutableAttributedString alloc] initWithString:msgContent];
            [serverMsgAttStr configAttStrLightColor:COLOR_66 darkColor:COLOR_66_DARK range:NSMakeRange(0, msgContent.length)];
        }
            break;
        case IMServerMessage_ServerMsgType_KickGroupMessage://群成员被踢
        {
            KickGroupMessage *kickmember = _message.serverMessage.kickGroupMessage;
            LingIMGroupMemberModel *groupMemberKickModel = [IMSDKManager imSdkCheckGroupMemberWith:kickmember.uid groupID:kickmember.gid];
            LingIMGroupMemberModel *groupMemberOperateModel = [IMSDKManager imSdkCheckGroupMemberWith:kickmember.operateUid groupID:kickmember.gid];
            
            
            NSString *msgContent;
            if ([kickmember.uid isEqualToString:UserManager.userInfo.userUID]) {
                msgContent = [NSString stringWithFormat:@"%@", LanguageToolMatch(@"你已被移出群聊")];
            }else {
                msgContent = [NSString stringWithFormat:LanguageToolMatch(@"“%@”将“%@”移出群聊"),groupMemberOperateModel ? groupMemberOperateModel.showName : kickmember.operateNick, groupMemberKickModel ? groupMemberKickModel.showName : kickmember.nick];
            }
            serverMsgAttStr = [[NSMutableAttributedString alloc] initWithString:msgContent];
            //富文本处理，颜色处理
            [serverMsgAttStr configAttStrLightColor:COLOR_66 darkColor:COLOR_66_DARK range:NSMakeRange(0, msgContent.length)];
            
            if (![kickmember.uid isEqualToString:UserManager.userInfo.userUID]) {
                
                [serverMsgAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 range:[msgContent rangeOfString:groupMemberOperateModel ? groupMemberOperateModel.showName : kickmember.operateNick]];
                [serverMsgAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 range:[msgContent rangeOfString:groupMemberKickModel ? groupMemberKickModel.showName : kickmember.nick]];
            }
        }
            break;
        case IMServerMessage_ServerMsgType_OutGroupMessage://群成员退群
        {
            OutGroupMessage *outGroupMember = _message.serverMessage.outGroupMessage;
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:outGroupMember.uid groupID:outGroupMember.gid];
            NSString *msgContent = [NSString stringWithFormat:LanguageToolMatch(@"“%@”退出了群聊"),groupMemberModel ? groupMemberModel.showName : outGroupMember.nick];
            serverMsgAttStr = [[NSMutableAttributedString alloc] initWithString:msgContent];
            
            [serverMsgAttStr configAttStrLightColor:COLOR_66 darkColor:COLOR_66_DARK range:NSMakeRange(0, msgContent.length)];
            [serverMsgAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 range:[msgContent rangeOfString:groupMemberModel ? groupMemberModel.showName : outGroupMember.nick]];
        }
            break;
        case IMServerMessage_ServerMsgType_TransferOwnerMessage://转让群主
        {
            TransferOwnerMessage *groupOwnerTransfer = _message.serverMessage.transferOwnerMessage;
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:groupOwnerTransfer.uid groupID:groupOwnerTransfer.gid];
            NSString *msgContent = [NSString stringWithFormat:LanguageToolMatch(@"群主变更为“%@”"),groupMemberModel ? groupMemberModel.showName : groupOwnerTransfer.nick];
            serverMsgAttStr = [[NSMutableAttributedString alloc] initWithString:msgContent];
            [serverMsgAttStr configAttStrLightColor:COLOR_66 darkColor:COLOR_66_DARK range:NSMakeRange(0, msgContent.length)];
            [serverMsgAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 range:[msgContent rangeOfString:groupMemberModel ? groupMemberModel.showName : groupOwnerTransfer.nick]];
        }
            break;
        case IMServerMessage_ServerMsgType_EstoppelGroupMessage://告知全部群成员 群禁言 开启/关闭
        {
            GroupStatusMessage *groupStatus = _message.serverMessage.groupStatusMessage;
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:groupStatus.uid groupID:groupStatus.gid];
            NSString *userName = groupMemberModel ? groupMemberModel.showName : groupStatus.nick;
            NSString *msgContent;
            if (groupStatus.status == 1) {
                msgContent = [NSString stringWithFormat:LanguageToolMatch(@"“%@”开启了全员禁言"), userName];
            }else {
                msgContent = [NSString stringWithFormat:LanguageToolMatch(@"“%@”关闭了全员禁言"), userName];
            }
            serverMsgAttStr = [[NSMutableAttributedString alloc] initWithString:msgContent];
            [serverMsgAttStr configAttStrLightColor:COLOR_66 darkColor:COLOR_66_DARK range:NSMakeRange(0, msgContent.length)];
            [serverMsgAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 range:[msgContent rangeOfString:userName]];
        }
            break;
            
        case IMServerMessage_ServerMsgType_IsShowHistoryMessage://新成员是否可查看历史消息
        {
            GroupStatusMessage *groupStatusMessage = _message.serverMessage.groupStatusMessage;
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:groupStatusMessage.uid groupID:groupStatusMessage.gid];
            NSString *userName = groupMemberModel ? groupMemberModel.showName : groupStatusMessage.nick;
            NSString *msgContent;
            if (groupStatusMessage.status == 1) {
                msgContent = [NSString stringWithFormat:LanguageToolMatch(@"“%@” 开启了新成员可查看历史消息"), userName];
            }else {
                msgContent = [NSString stringWithFormat:LanguageToolMatch(@"“%@” 关闭了新成员可查看历史消息"), userName];
            }
            serverMsgAttStr = [[NSMutableAttributedString alloc] initWithString:msgContent];
            [serverMsgAttStr configAttStrLightColor:COLOR_66 darkColor:COLOR_66_DARK range:NSMakeRange(0, msgContent.length)];
            [serverMsgAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 range:[msgContent rangeOfString:userName]];
        }
            break;
        case IMServerMessage_ServerMsgType_AdminGroupMessage://变更管理员
        {
            AdminGroupMessage *groupAdmin = _message.serverMessage.adminGroupMessage;
            __block NSMutableString *adminStr = [NSMutableString string];
            NSArray *adminInfoArr = groupAdmin.adminInfoArray;
            [adminInfoArr enumerateObjectsUsingBlock:^(UserInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.uId isEqualToString:UserManager.userInfo.userUID]) {
                    [adminStr appendFormat:@"%@", LanguageToolMatch(@"你")];
                }else {
                    LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:obj.uId groupID:groupAdmin.gid];
                    [adminStr appendFormat:@"“%@”", groupMemberModel ? groupMemberModel.showName : obj.uNick];
                }
            }];
            
            LingIMGroupMemberModel *groupMemberOperateModel = [IMSDKManager imSdkCheckGroupMemberWith:groupAdmin.operateUid groupID:groupAdmin.gid];

            NSString *msgContent;
            if (groupAdmin.type == 1) {
                msgContent = [NSString stringWithFormat:LanguageToolMatch(@"“%@”将%@设为管理员"), groupMemberOperateModel ? groupMemberOperateModel.showName : groupAdmin.operateNick, adminStr];
            }else {
                msgContent = [NSString stringWithFormat:LanguageToolMatch(@"“%@”将%@从管理员中移除"),groupMemberOperateModel ? groupMemberOperateModel.showName : groupAdmin.operateNick, adminStr];
            }
            serverMsgAttStr = [[NSMutableAttributedString alloc] initWithString:msgContent];
            
            //富文本处理，颜色处理
            [serverMsgAttStr configAttStrLightColor:COLOR_66 darkColor:COLOR_66_DARK range:NSMakeRange(0, msgContent.length)];
            
            [adminInfoArr enumerateObjectsUsingBlock:^(UserInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![obj.uId isEqualToString:UserManager.userInfo.userUID]) {
                    LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:obj.uId groupID:groupAdmin.gid];
                    [serverMsgAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 range:[msgContent rangeOfString:groupMemberModel ? groupMemberModel.showName : obj.uNick]];
                }
            }];
            
            [serverMsgAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 range:[msgContent rangeOfString:groupMemberOperateModel ? groupMemberOperateModel.showName : groupAdmin.operateNick]];
        }
            break;
        case IMServerMessage_ServerMsgType_NameGroupMessage://群名称修改
        {
            NameGroupMessage *groupName = _message.serverMessage.nameGroupMessage;
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:groupName.uid groupID:groupName.gid];
            NSString *msgContent = [NSString stringWithFormat:LanguageToolMatch(@"“%@”将群名称修改为：%@"),groupMemberModel ? groupMemberModel.showName : groupName.nick, groupName.gName];
            serverMsgAttStr = [[NSMutableAttributedString alloc] initWithString:msgContent];
            //颜色
            [serverMsgAttStr configAttStrLightColor:COLOR_66 darkColor:COLOR_66_DARK range:NSMakeRange(0, msgContent.length)];
            [serverMsgAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 range:[msgContent rangeOfString:groupMemberModel ? groupMemberModel.showName : groupName.nick]];
        }
            break;
        case IMServerMessage_ServerMsgType_NoticeGroupMessage://群公告设置
        {
            NoticeGroupMessage *groupNotice = _message.serverMessage.noticeGroupMessage;
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:groupNotice.uid groupID:groupNotice.gid];
            NSString *msgContent = [NSString stringWithFormat:LanguageToolMatch(@"“%@”设置了群公告"),groupMemberModel ? groupMemberModel.showName : groupNotice.nick];
            serverMsgAttStr = [[NSMutableAttributedString alloc] initWithString:msgContent];
            //颜色
            [serverMsgAttStr configAttStrLightColor:COLOR_66 darkColor:COLOR_66_DARK range:NSMakeRange(0, msgContent.length)];
            [serverMsgAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 range:[msgContent rangeOfString:groupMemberModel ? groupMemberModel.showName : groupNotice.nick]];
        }
            break;
        case IMServerMessage_ServerMsgType_GroupSingleForbidMessage://群主或管理员 禁言某个群成员
        {
            GroupSingleForbidMessage *memberBanned = _message.serverMessage.groupSingleForbidMessage;
            //被禁言群成员
            LingIMGroupMemberModel *groupMemberToModel = [IMSDKManager imSdkCheckGroupMemberWith:memberBanned.toUid groupID:memberBanned.gid];
            //操作人
            LingIMGroupMemberModel *groupMemberFromModel = [IMSDKManager imSdkCheckGroupMemberWith:memberBanned.fromUid groupID:memberBanned.gid];

            NSString *msgContent;
            /** status 是否开启禁言 0：关闭禁言 1：开启禁言 */
            if ([memberBanned.toUid isEqualToString:UserManager.userInfo.userUID]) {
                if (memberBanned.status == 1) {
                    //"你被“%@”禁言%lld分钟"
                    msgContent = [NSString stringWithFormat:LanguageToolMatch(@"你被“%@”%@"),groupMemberFromModel ? groupMemberFromModel.showName : memberBanned.fromNick, [NSString convertBannedSendMsgTime:memberBanned.expireTime]];
                } else {
                    msgContent = [NSString stringWithFormat:LanguageToolMatch(@"你被“%@”解除禁言"),groupMemberFromModel ? groupMemberFromModel.showName : memberBanned.fromNick];
                }
            }else {
                if (memberBanned.status == 1) {
                    //"“%@”被“%@”禁言%lld分钟"
                    msgContent = [NSString stringWithFormat:LanguageToolMatch(@"“%@”被“%@”%@"),groupMemberToModel ? groupMemberToModel.showName : memberBanned.toNick, groupMemberFromModel ? groupMemberFromModel.showName : memberBanned.fromNick, [NSString convertBannedSendMsgTime:memberBanned.expireTime]];
                } else {
                    msgContent = [NSString stringWithFormat:LanguageToolMatch(@"“%@”被“%@”解除禁言"),groupMemberToModel ? groupMemberToModel.showName : memberBanned.toNick, groupMemberFromModel ? groupMemberFromModel.showName : memberBanned.fromNick];
                }
            }
            serverMsgAttStr = [[NSMutableAttributedString alloc] initWithString:msgContent];
            //富文本颜色
            [serverMsgAttStr configAttStrLightColor:COLOR_66 darkColor:COLOR_66_DARK range:NSMakeRange(0, msgContent.length)];
            if ([memberBanned.toUid isEqualToString:UserManager.userInfo.userUID]) {
                [serverMsgAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 range:[msgContent rangeOfString:groupMemberFromModel ? groupMemberFromModel.showName : memberBanned.fromNick]];
            } else {
                [serverMsgAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 range:[msgContent rangeOfString:groupMemberToModel ? groupMemberToModel.showName : memberBanned.toNick]];
                [serverMsgAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 range:[msgContent rangeOfString:groupMemberFromModel ? groupMemberFromModel.showName : memberBanned.fromNick]];
            }
        }
            break;
        case IMServerMessage_ServerMsgType_DelGroupMessage://解散群组  该消息只转发给在线的所有群成员
        {
            DelGroupMessage *groupDissolve = _message.serverMessage.delGroupMessage;
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:groupDissolve.uid groupID:groupDissolve.gid];
            NSString *msgContent = [NSString stringWithFormat:LanguageToolMatch(@"“%@”解散了该群"), groupMemberModel ? groupMemberModel.showName : groupDissolve.nick];
            serverMsgAttStr = [[NSMutableAttributedString alloc] initWithString:msgContent];
            [serverMsgAttStr configAttStrLightColor:COLOR_66 darkColor:COLOR_66_DARK range:NSMakeRange(0, msgContent.length)];
            [serverMsgAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 range:[msgContent rangeOfString:groupMemberModel ? groupMemberModel.showName : groupDissolve.nick]];
        }
            break;
        case IMServerMessage_ServerMsgType_InviteJoinGroupNoFriendMessage://邀请好友进群，但是好友不存在，该消息只转发给邀请加入的用户
        {
            InviteJoinGroupNoFriendMessage *inviteJoinGroupNoFriend = _message.serverMessage.inviteJoinGroupNoFriendMessage;
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:inviteJoinGroupNoFriend.operateUid groupID:inviteJoinGroupNoFriend.gid];
            NSString *msgContent = [NSString stringWithFormat:LanguageToolMatch(@"“%@”未添加你为好友，无法邀请进入群聊"), groupMemberModel ? groupMemberModel.showName : inviteJoinGroupNoFriend.operateNick];
            serverMsgAttStr = [[NSMutableAttributedString alloc] initWithString:msgContent];
            [serverMsgAttStr configAttStrLightColor:COLOR_66 darkColor:COLOR_66_DARK range:NSMakeRange(0, msgContent.length)];
            [serverMsgAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 range:[msgContent rangeOfString:groupMemberModel ? groupMemberModel.showName : inviteJoinGroupNoFriend.operateNick]];
        }
            break;
        case IMServerMessage_ServerMsgType_InviteJoinGroupBlackFriendMessage://邀请好友进群，但是已被拉黑，该消息只转发给邀请加入的用户
        {
            InviteJoinGroupBlackFriendMessage *inviteJoinGroupBlackFriend = _message.serverMessage.inviteJoinGroupBlackFriendMessage;
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:inviteJoinGroupBlackFriend.operateUid groupID:inviteJoinGroupBlackFriend.gid];
            NSString *msgContent = [NSString stringWithFormat:LanguageToolMatch(@"“%@”拒绝加入群聊"), groupMemberModel ? groupMemberModel.showName : inviteJoinGroupBlackFriend.operateNick];
            serverMsgAttStr = [[NSMutableAttributedString alloc] initWithString:msgContent];
            [serverMsgAttStr configAttStrLightColor:COLOR_66 darkColor:COLOR_66_DARK range:NSMakeRange(0, msgContent.length)];
            [serverMsgAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 range:[msgContent rangeOfString:groupMemberModel ? groupMemberModel.showName : inviteJoinGroupBlackFriend.operateNick]];
        }
            break;
        case IMServerMessage_ServerMsgType_AvatarGroupMessage://变更群头像  该消息只转发给在线的所有群成员
        {
            AvatarGroupMessage *avatarGroup = _message.serverMessage.avatarGroupMessage;
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:avatarGroup.uid groupID:avatarGroup.gid];
            NSString *msgContent = [NSString stringWithFormat:LanguageToolMatch(@"“%@”修改了群头像"), groupMemberModel ? groupMemberModel.showName : avatarGroup.nick];
            serverMsgAttStr = [[NSMutableAttributedString alloc] initWithString:msgContent];
            [serverMsgAttStr configAttStrLightColor:COLOR_66 darkColor:COLOR_66_DARK range:NSMakeRange(0, msgContent.length)];
            [serverMsgAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 range:[msgContent rangeOfString:groupMemberModel ? groupMemberModel.showName : avatarGroup.nick]];
        }
            break;
            
        case IMServerMessage_ServerMsgType_DelGroupNotice://删除群公告
        {
            DelGroupNotice *groupNoticeDel = _message.serverMessage.delGroupNotice;
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:groupNoticeDel.uid groupID:groupNoticeDel.gid];
            NSString *msgContent = [NSString stringWithFormat:LanguageToolMatch(@"“%@”删除了群公告"),groupMemberModel ? groupMemberModel.showName : groupNoticeDel.nick];
            serverMsgAttStr = [[NSMutableAttributedString alloc] initWithString:msgContent];
            //颜色
            [serverMsgAttStr configAttStrLightColor:COLOR_66 darkColor:COLOR_66_DARK range:NSMakeRange(0, msgContent.length)];
            [serverMsgAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 range:[msgContent rangeOfString:groupMemberModel ? groupMemberModel.showName : groupNoticeDel.nick]];
        }
            break;
        case IMServerMessage_ServerMsgType_ScheduleDeleteMessage://消息定时自动删除
        {
            ScheduleDeleteMessage *messageTimeDelete = _message.serverMessage.scheduleDeleteMessage;
            NSString *userName;
            if (messageTimeDelete.chatType == ChatType_SingleChat) {
                //单聊消息
                if ([messageTimeDelete.userId isEqualToString:UserManager.userInfo.userUID]) {
                    userName = LanguageToolMatch(@"你");
                }else {
                    //单聊
                    LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:messageTimeDelete.userId];
                    if (friendModel) {
                        userName = friendModel.showName;
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
                    userName = groupMemberModel ? groupMemberModel.showName : messageTimeDelete.userNick;
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
            NSString *msgContent = [NSString stringWithFormat:@"%@%@",userName, timeDeleteInfo];
            serverMsgAttStr = [[NSMutableAttributedString alloc] initWithString:msgContent];
            [serverMsgAttStr configAttStrLightColor:COLOR_66 darkColor:COLOR_66_DARK range:NSMakeRange(0, msgContent.length)];
            if (![messageTimeDelete.userId isEqualToString:UserManager.userInfo.userUID]) {
                //颜色
                [serverMsgAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 range:[msgContent rangeOfString:userName]];
            }
            
        }
            break;
        case IMServerMessage_ServerMsgType_JoinVerifyGroupMessage://开启了入群验证
        {
            GroupStatusMessage *groupStatus = _message.serverMessage.groupStatusMessage;
            
            NSString *userName;
            if ([groupStatus.uid isEqualToString:UserManager.userInfo.userUID]) {
                userName = LanguageToolMatch(@"你");
            }else {
                LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:groupStatus.uid groupID:groupStatus.gid];
                userName = groupMemberModel ? groupMemberModel.showName : groupStatus.nick;
            }
            
            NSString *groupStatusInfo;
            if (groupStatus.status == 1) {
                groupStatusInfo = [NSString stringWithFormat:LanguageToolMatch(@"“%@”已启用群里邀请确认"), userName];
            }else {
                groupStatusInfo = [NSString stringWithFormat:LanguageToolMatch(@"“%@”已关闭群里邀请确认"), userName];
            }
            
            serverMsgAttStr = [[NSMutableAttributedString alloc] initWithString:groupStatusInfo];
            [serverMsgAttStr configAttStrLightColor:COLOR_66 darkColor:COLOR_66_DARK range:NSMakeRange(0, groupStatusInfo.length)];
            if (![groupStatus.uid isEqualToString:UserManager.userInfo.userUID]) {
                //颜色
                [serverMsgAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 range:[groupStatusInfo rangeOfString:userName]];
            }
            
        }
            break;
            
        default:
            break;
    }
    
    self.attStr = serverMsgAttStr;
    [self.attStr addAttributes:@{NSFontAttributeName:FONTN(13)} range:NSMakeRange(0, serverMsgAttStr.string.length)];
    CGSize size = [self.attStr boundingRectWithSize:CGSizeMake(DScreenWidth - 20*2, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    _messageHeight = MAX(ceil(size.height), 20);
    _messageWidth = MAX(ceil(size.width), 60);
    if(ZLanguageTOOL.isRTL){
        CGFloat width = [self.attStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width;
        _messageWidth = MIN(MAX(ceil(width), 60), DScreenWidth - 20*2);
    }
}

#pragma mark - GET
//获取attstr,每次获取都更新一下
- (NSMutableAttributedString *)getCurAttStr{
    self.attStr = nil;
    //计算高度
    [self calculateModelInfoSize];
    return self.attStr;
}

#pragma mark - Lazy
- (NSMutableAttributedString *)attStr {
    if (!_attStr) {
        _attStr = [NSMutableAttributedString new];
    }
    return _attStr;
}

- (NSMutableAttributedString *)translateAttStr {
    if (!_translateAttStr) {
        _translateAttStr = [NSMutableAttributedString new];
    }
    return _translateAttStr;
}


- (NSMutableAttributedString *)referenceAttStr {
    if (!_referenceAttStr) {
        _referenceAttStr = [NSMutableAttributedString new];
    }
    return _referenceAttStr;
}

#pragma mark - 模型支持copy
- (instancetype)copyWithZone:(NSZone *)zone {
    
    NoaMessageModel *model = [[NoaMessageModel allocWithZone:zone] init];
    model.message = self.message;//消息Model
    model.referenceMsg = self.referenceMsg;//被引用的消息Model
    model.attStr = self.attStr;//富文本(消息内容)
    model.translateAttStr = self.translateAttStr;//富文本(消息内容)译文
    model.referenceAttStr = self.referenceAttStr;//富文本(被引用的消息内容)
    model.messageWidth = self.messageWidth;//message内容宽度
    model.messageHeight = self.messageHeight;//message内容高度
    model.referenceMsgHeight = self.referenceMsgHeight;//引用message内容高度
    model.cellHeight = self.cellHeight;//cell高度
    model.isSelf = self.isSelf;//消息是否是自己发送的
    model.isReferenceSelf = self.isReferenceSelf;//引用消息是否是自己发送的
    model.isShowSendTime = self.isShowSendTime;//是否要显示消息的发送时间
    model.dataTime = self.dataTime;//将消息的时间戳转换成日期时间
    model.byteSent = self.byteSent;//已经下载的大小
    model.totalByte = self.totalByte;//总大小
    model.taskState = self.taskState;//请求任务状态
    model.isShowSelectBox = self.isShowSelectBox;//是否是多选状态(是否显示左边的选中按钮)
    model.multiSelected = self.multiSelected;//多选-选中的状态(是否选中)
    
    return model;
    
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [self copyWithZone:zone];
}
@end
