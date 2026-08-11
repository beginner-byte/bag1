//
//  NoaMessageSendHander.m
//  NoaKit
//
//  Created by Candy on 2026/10/28.
//

#import "NoaMessageSendHander.h"
#import "NoaMessageTools.h"
#import "NoaFileUploadModel.h"
#import <NoaChatCore/NSDate+SyncServer.h>

@implementation NoaMessageSendHander

/// 消息发送时间：优先服务器校准时间，未校准时回退设备时间
+ (long long)messageSendTimestamp {
    long long ts = [NSDate safeCurrentServerMillisecondTime];
    BOOL synced = [NSDate hasValidServerTimeSync];
    if (!synced) {
        NSLog(@"[MsgTime] send create fallback deviceTime=%lld (server sync missing)", ts);
    }
    return ts;
}


#pragma mark - 发送文本消息
+ (NoaIMChatMessageModel *)ZMessageTextSend:(NSString *)textMessage withToUserId:(NSString *)to withChatType:(CIMChatType)chatType referenceMsgId:(NSString *)referenceMsgId {
    NoaIMChatMessageModel *textChatMessage = [NoaIMChatMessageModel new];
    textChatMessage.messageSendType = CIMChatMessageSendTypeSending;
    textChatMessage.referenceMsgId = referenceMsgId;
    textChatMessage.chatType = chatType;
    textChatMessage.messageStatus = 1;  //正常状态
    textChatMessage.msgID = [[NoaIMManagerTool sharedManager] getMessageID];
    textChatMessage.messageType = CIMChatMessageType_TextMessage;
    textChatMessage.isAck = YES;
    textChatMessage.fromID = UserManager.userInfo.userUID;
    textChatMessage.fromNickname = UserManager.userInfo.nickname;
    textChatMessage.fromIcon = UserManager.userInfo.avatar;
    textChatMessage.toID = to;
    textChatMessage.sendTime = [self messageSendTimestamp];
    textChatMessage.textContent = textMessage;
    
    return textChatMessage;
}

//发送 @用户 消息
+ (NoaIMChatMessageModel *)ZMessageAtUserSend:(NSString *)content showContent:(NSString *)showContent withAtUsersDicList:(NSArray *)atUsersDicList withToUserId:(NSString *)to withChatType:(CIMChatType)chatType referenceMsgId:(NSString *)referenceMsgId {
    NoaIMChatMessageModel *atChatMessage = [NoaIMChatMessageModel new];
    atChatMessage.messageSendType = CIMChatMessageSendTypeSending;
    atChatMessage.referenceMsgId = referenceMsgId;
    atChatMessage.chatType = chatType;
    atChatMessage.messageStatus = 1;  //正常状态
    atChatMessage.msgID = [[NoaIMManagerTool sharedManager] getMessageID];
    atChatMessage.messageType = CIMChatMessageType_AtMessage;
    atChatMessage.isAck = YES;
    atChatMessage.fromID = UserManager.userInfo.userUID;
    atChatMessage.fromNickname = UserManager.userInfo.nickname;
    atChatMessage.fromIcon = UserManager.userInfo.avatar;
    atChatMessage.toID = to;
    atChatMessage.sendTime = [self messageSendTimestamp];
    atChatMessage.atContent = content;
    atChatMessage.atUsersInfoList = atUsersDicList;
    atChatMessage.showContent = showContent;
    
    return atChatMessage;
}

#pragma mark - 发送图片或者视频
+ (void)ZMessageMediaSend:(NSMutableArray<PHAsset *> *)mediaAssetArr withToUserId:(NSString *)to withChatType:(CIMChatType)chatType compelete:(void(^)(NSArray <NoaIMChatMessageModel *> * sendChatMsgArr))compelete {
    
    NSMutableArray * messageContentArray = [NSMutableArray array];
    
    __block NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dispatch_group_t myGroup = dispatch_group_create();
    for (int i = 0; i < mediaAssetArr.count; ++i) {
        dispatch_group_enter(myGroup);
        PHAsset *mediaAsset = mediaAssetArr[i];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            long long currentSendTime;
            if (mediaAsset.mediaType == PHAssetMediaTypeImage) {
                currentSendTime =  [self messageSendTimestamp];
                [NoaMessageSendHander assembleImageMessageWithAsset:mediaAsset withToUserId:to withChatType:chatType compelete:^(NoaIMChatMessageModel *sendChatMsg) {
                    if (sendChatMsg) {
                        sendChatMsg.sendTime = currentSendTime;
                        [dic setValue:sendChatMsg forKey:[NSString stringWithFormat:@"%i",i]];
                    }
                    dispatch_group_leave(myGroup);
                }];
            } else if (mediaAsset.mediaType == PHAssetMediaTypeVideo) {
                currentSendTime =  [self messageSendTimestamp];
                [NoaMessageSendHander assembleVideoMessageWithAsset:mediaAsset withToUserId:to withChatType:chatType compelete:^(NoaIMChatMessageModel *sendChatMsg) {
                    if (sendChatMsg) {
                        sendChatMsg.sendTime = currentSendTime;
                        [dic setValue:sendChatMsg forKey:[NSString stringWithFormat:@"%i",i]];
                    }
                    dispatch_group_leave(myGroup);
                }];
            } else {
                // 不支持的媒体类型，直接离开组
                dispatch_group_leave(myGroup);
            }
        });
    }
    
    dispatch_group_notify(myGroup, dispatch_get_main_queue(), ^{
        NSArray * sortKeys = [dic.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
             return [obj1 compare:obj2];
        }];
        for (NSString * key in sortKeys) {
            [messageContentArray addObject:[dic objectForKey:key]];
        }
        if (compelete) {
            compelete([messageContentArray copy]);
        }
    });
}

#pragma mark - 组装图片消息
+ (void)assembleImageMessageWithAsset:(PHAsset *)mediaAsset withToUserId:(NSString *)to withChatType:(CIMChatType)chatType compelete:(void(^)(NoaIMChatMessageModel * sendChatMsg))compelete {
    //发送图片
    CGSize targetSize = CGSizeMake(mediaAsset.pixelWidth, mediaAsset.pixelHeight);
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.synchronous = NO;//同步，如果有卡顿的情况，可设置为NO异步
    options.networkAccessAllowed = YES; // 允许从 iCloud 下载
    [[PHImageManager defaultManager] requestImageDataAndOrientationForAsset:mediaAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary * _Nullable info) {
        // 检查是否是 iCloud 图片下载问题
        BOOL isInCloud = [info[PHImageResultIsInCloudKey] boolValue];
        NSError *error = info[PHImageErrorKey];
        
        if (isInCloud && error) {
            NSLog(@"图片在 iCloud 中，需要下载: %@", error);
            // 不发送错误消息，直接返回 nil 让回调被调用
            if (compelete) {
                compelete(nil);
            }
            return;
        }
        
        // 检查图片数据是否有效
        if (!imageData || imageData.length == 0) {
            NSLog(@"图片数据获取失败: %@", info);
            // 不发送错误消息，直接返回 nil 让回调被调用
            if (compelete) {
                compelete(nil);
            }
            return;
        }
        
        //该会话的中间目录
        NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, to];
        //此处做判断：图片大于30MB或者最长边大于25000,则按文件消息发送
        BOOL isSendForFile = NO;
        if (imageData.length > (30 * 1024 * 1024)) {
            isSendForFile = YES;
        } else {
            CGFloat maxSide;
            if (targetSize.width >= targetSize.height) {
                maxSide = targetSize.width;
            } else {
                maxSide = targetSize.height;
            }
            if (maxSide > 25000) {
                isSendForFile = YES;
            } else {
                isSendForFile = NO;
            }
        }
        if (isSendForFile) {
            //以文件形式发送
            //组合文件类型消息体
            NoaIMChatMessageModel *fileChatMessage = [NoaIMChatMessageModel new];
            fileChatMessage.messageSendType = CIMChatMessageSendTypeSending;
            fileChatMessage.chatType = chatType;
            fileChatMessage.messageStatus = 1;  //正常状态
            fileChatMessage.msgID = [[NoaIMManagerTool sharedManager] getMessageID];
            fileChatMessage.messageType = CIMChatMessageType_FileMessage;
            fileChatMessage.isAck = YES;
            fileChatMessage.fromID = UserManager.userInfo.userUID;
            fileChatMessage.fromNickname = UserManager.userInfo.nickname;
            fileChatMessage.fromIcon = UserManager.userInfo.avatar;
            fileChatMessage.toID = to;
            fileChatMessage.sendTime = [self messageSendTimestamp];
            fileChatMessage.isSendForFile = isSendForFile;
            //将图片转移放入沙盒目录下
            NSString *saxboxFileName = [mediaAsset valueForKey:@"filename"];
            //名称
            fileChatMessage.fileName = saxboxFileName;
            //视图片大小
            fileChatMessage.fileSize = [imageData length];
            
            //文件显示在UI上的名字
            NSRange range3 = [fileChatMessage.fileName rangeOfString:@"-"];
            if (range3.length == 0) {
                fileChatMessage.showFileName = fileChatMessage.fileName;
            } else {
                fileChatMessage.showFileName = [fileChatMessage.fileName safeSubstringWithRange:NSMakeRange(range3.location+1, fileChatMessage.fileName.length - (range3.location+1))];
            }
            
            __block NSString *saxboxFilePath = @"";
            [ZTOOL doAsync:^{
                //将文件保存到本地沙盒
                [NSString saveFileToSaxboxWithData:imageData CustomPath:customPath fileName:saxboxFileName];
                saxboxFilePath = [NSString getPathWithFileName:saxboxFileName CustomPath:customPath];
            } completion:^{
                //文件类型
                fileChatMessage.fileType = [NSString fileTranslateToFileType:saxboxFilePath];
                //将要发送的消息体传递出去
                if (compelete) {
                    compelete(fileChatMessage);
                }
            }];
        } else {
            //缩略图
            NSData *thumbImageData;
            NSData *originImageData;
            if ([[[NSString getImageFileFormat:imageData] lowercaseString] isEqualToString:@"gif"]) {
                //GIF图片
                thumbImageData = imageData;
                originImageData = imageData;
            } else {
                //静态图片（全部转成png）
                UIImage *tempHeicThumbImage = [UIImage imageWithData:[UIImage compressImageSize:[UIImage imageWithData:imageData] toByte:50*1024]];//压缩到50KB
                //原图也需采用这种方式压缩一下，尽量压缩小一些，不然PC端收到图片消息显示原图(竖图)时，方向会旋转90度
                UIImage *tempHeicOriginImage = [UIImage imageWithData:[UIImage compressImageSize:[UIImage imageWithData:imageData] toByte:100*1024]];//[UIImage imageWithData:imageData];
                 
                thumbImageData = UIImagePNGRepresentation(tempHeicThumbImage);
                originImageData = UIImagePNGRepresentation(tempHeicOriginImage);
            }
            //原图名称
            NSString *originImageName = [[NSString alloc] initWithFormat:@"%@_%lld.%@", UserManager.userInfo.userUID, [NSDate currentTimeIntervalWithMillisecond], [NSString getImageFileFormat:originImageData]];
            //缩略图名称
            NSString *thumbImgFileName = [[NSString alloc] initWithFormat:@"thumbil_%@", originImageName];
            
            //组装消息体
            NoaIMChatMessageModel *imgChatMessage = [NoaIMChatMessageModel new];
            imgChatMessage.messageSendType = CIMChatMessageSendTypeSending;
            imgChatMessage.chatType = chatType;
            imgChatMessage.messageStatus = 1;  //正常状态
            imgChatMessage.msgID = [[NoaIMManagerTool sharedManager] getMessageID];
            imgChatMessage.messageType = CIMChatMessageType_ImageMessage;
            imgChatMessage.isAck = YES;
            imgChatMessage.fromID = UserManager.userInfo.userUID;
            imgChatMessage.fromNickname = UserManager.userInfo.nickname;
            imgChatMessage.fromIcon = UserManager.userInfo.avatar;
            imgChatMessage.toID = to;
            imgChatMessage.sendTime = [self messageSendTimestamp];
            imgChatMessage.localImgName = originImageName;//本地沙盒图片地址
            imgChatMessage.localthumbImgName = thumbImgFileName;//本地沙盒图片缩略图地址
            imgChatMessage.localImg = [UIImage imageWithData:imageData];
            imgChatMessage.imgSize = imageData.length;
            imgChatMessage.imgWidth = targetSize.width;
            imgChatMessage.imgHeight = targetSize.height;
            
            [ZTOOL doAsync:^{
                //将图片放入沙盒目录下对应会话的文件夹目录里
                [NSString saveImageToSaxboxWithData:originImageData CustomPath:customPath ImgName:originImageName];
                [NSString saveImageToSaxboxWithData:thumbImageData CustomPath:customPath ImgName:thumbImgFileName];
            } completion:^{
                //将messageModel传出去，进行上传操作和UI展示
                if (compelete) {
                    compelete(imgChatMessage);
                }
            }];
        }
    }];
    
    /*
    //发送图片
    CGSize targetSize = CGSizeMake(mediaAsset.pixelWidth, mediaAsset.pixelHeight);
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.synchronous = YES;//同步，如果有卡顿的情况，可设置为NO异步
    [[PHImageManager defaultManager] requestImageForAsset:mediaAsset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *resultImage, NSDictionary *info) {
        // 这里获取的 resultImage是原图,将 resultImage 转成 NSData 类型的
        NSData *fileData = UIImageJPEGRepresentation(resultImage, 1.0);//原图
        //该会话的中间目录
        NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, to];
        //此处做判断：图片大于30MB或者最长边大于25000,则安文件消息发送
        BOOL isSendForFile = NO;
        if (fileData.length > (30 * 1024 * 1024)) {
            isSendForFile = YES;
        } else {
            CGFloat maxSide;
            if (resultImage.size.width >= resultImage.size.height) {
                maxSide = resultImage.size.width;
            } else {
                maxSide = resultImage.size.height;
            }
            if (maxSide > 25000) {
                isSendForFile = YES;
            } else {
                isSendForFile = NO;
            }
        }
        if (isSendForFile) {
            //以文件形式发送
            //组合文件类型消息体
            LingIMChatMessageModel *fileChatMessage = [LingIMChatMessageModel new];
            fileChatMessage.messageSendType = CIMChatMessageSendTypeSending;
            fileChatMessage.chatType = chatType;
            fileChatMessage.messageStatus = 1;  //正常状态
            fileChatMessage.msgID = [[LingIMManagerTool sharedManager] getMessageID];
            fileChatMessage.messageType = CIMChatMessageType_FileMessage;
            fileChatMessage.isAck = YES;
            fileChatMessage.fromID = UserManager.userInfo.userUID;
            fileChatMessage.fromNickname = UserManager.userInfo.nickname;
            fileChatMessage.fromIcon = UserManager.userInfo.avatar;
            fileChatMessage.toID = to;
            fileChatMessage.sendTime = [self messageSendTimestamp];
            fileChatMessage.isSendForFile = isSendForFile;
            //将图片转移放入沙盒目录下
            NSString *saxboxFileName = [mediaAsset valueForKey:@"filename"];
            //名称
            fileChatMessage.fileName = saxboxFileName;
            //视图片大小
            fileChatMessage.fileSize = [fileData length];
            
            //文件显示在UI上的名字
            NSRange range3 = [fileChatMessage.fileName rangeOfString:@"-"];
            if (range3.length == 0) {
                fileChatMessage.showFileName = fileChatMessage.fileName;
            } else {
                fileChatMessage.showFileName = [fileChatMessage.fileName safeSubstringWithRange:NSMakeRange(range3.location+1, fileChatMessage.fileName.length - (range3.location+1))];
            }
            
            __block NSString *saxboxFilePath = @"";
            [ZTOOL doAsync:^{
                //将文件保存到本地沙盒
                [NSString saveFileToSaxboxWithData:fileData CustomPath:customPath fileName:saxboxFileName];
                saxboxFilePath = [NSString getPathWithFileName:saxboxFileName CustomPath:customPath];
            } completion:^{
                //文件类型
                fileChatMessage.fileType = [NSString fileTranslateToFileType:saxboxFilePath];
                //将要发送的消息体传递出去
                if (compelete) {
                    compelete(fileChatMessage);
                }
            }];
        } else {
            //图片
            NSData *imageData = UIImageJPEGRepresentation(resultImage, 0.5);//压缩后的图
            NSString *imgFileName = [[NSString alloc] initWithFormat:@"%@_%lld.%@", UserManager.userInfo.userUID, [NSDate currentTimeIntervalWithMillisecond], [NSString getImageFileFormat:imageData]];
            
            //缩略图
            NSData *thumbImageData = [UIImage compressImageSize:[UIImage imageWithData:imageData] toByte:50*1024];//压缩到50KB
            NSString *thumbImgFileName = [[NSString alloc] initWithFormat:@"thumbil_%@", imgFileName];
            
            LingIMChatMessageModel *imgChatMessage = [LingIMChatMessageModel new];
            imgChatMessage.messageSendType = CIMChatMessageSendTypeSending;
            imgChatMessage.chatType = chatType;
            imgChatMessage.messageStatus = 1;  //正常状态
            imgChatMessage.msgID = [[LingIMManagerTool sharedManager] getMessageID];
            imgChatMessage.messageType = CIMChatMessageType_ImageMessage;
            imgChatMessage.isAck = YES;
            imgChatMessage.fromID = UserManager.userInfo.userUID;
            imgChatMessage.fromNickname = UserManager.userInfo.nickname;
            imgChatMessage.fromIcon = UserManager.userInfo.avatar;
            imgChatMessage.toID = to;
            imgChatMessage.sendTime = [self messageSendTimestamp];
            imgChatMessage.localImgName = imgFileName;//本地沙盒图片地址
            imgChatMessage.localthumbImgName = thumbImgFileName;//本地沙盒图片缩略图地址
            imgChatMessage.localImg = resultImage;
            imgChatMessage.imgSize = CGImageGetHeight(resultImage.CGImage) * CGImageGetBytesPerRow(resultImage.CGImage);
            imgChatMessage.imgWidth = resultImage.size.width;
            imgChatMessage.imgHeight = resultImage.size.height;
            
            [ZTOOL doAsync:^{
                //将图片放入沙盒目录下对应会话的文件夹目录里
                [NSString saveImageToSaxboxWithData:imageData CustomPath:customPath ImgName:imgFileName];
                [NSString saveImageToSaxboxWithData:thumbImageData CustomPath:customPath ImgName:thumbImgFileName];
            } completion:^{
                //将messageModel传出去，进行上传操作和UI展示
                if (compelete) {
                    compelete(imgChatMessage);
                }
            }];
        }
    }];
    */
}

#pragma mark - 组装视频消息
+ (void)assembleVideoMessageWithAsset:(PHAsset *)mediaAsset withToUserId:(NSString *)to withChatType:(CIMChatType)chatType compelete:(void(^)(NoaIMChatMessageModel * sendChatMsg))compelete {
    //发送视频
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.networkAccessAllowed = YES; // 允许从 iCloud 下载
    [[PHImageManager defaultManager] requestAVAssetForVideo:mediaAsset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
        // 检查是否是 iCloud 视频下载问题
        BOOL isInCloud = [info[PHImageResultIsInCloudKey] boolValue];
        NSError *error = info[PHImageErrorKey];
        
        if (isInCloud && error) {
            NSLog(@"视频在 iCloud 中，需要下载: %@", error);
            // 不发送错误消息，直接返回 nil 让回调被调用
            if (compelete) {
                compelete(nil);
            }
            return;
        }
        
        // 检查视频资源是否有效
        if (!asset || ![asset isKindOfClass:[AVURLAsset class]]) {
            NSLog(@"视频资源获取失败: %@", info);
            // 不发送错误消息，直接返回 nil 让回调被调用
            if (compelete) {
                compelete(nil);
            }
            return;
        }
        
        if ([asset isKindOfClass:[AVURLAsset class]]) {
            AVURLAsset* urlAsset = (AVURLAsset*)asset;
            NSNumber *size;
            [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
            NSData *videoData = [NSData dataWithContentsOfURL:urlAsset.URL options:NSDataReadingMappedIfSafe error:nil];
            
            // 检查视频数据是否有效
            if (!videoData || videoData.length == 0) {
                NSLog(@"视频数据读取失败");
                // 不发送错误消息，直接返回 nil 让回调被调用
                if (compelete) {
                    compelete(nil);
                }
                return;
            }
            
            NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, to];
            //视频大小超过200M，转为文件发送
            if (videoData.length > (200 * 1024 * 1024)) {
                //以文件形式发送
                //组合文件类型消息体
                NoaIMChatMessageModel *fileChatMessage = [NoaIMChatMessageModel new];
                fileChatMessage.messageSendType = CIMChatMessageSendTypeSending;
                fileChatMessage.chatType = chatType;
                fileChatMessage.messageStatus = 1;  //正常状态
                fileChatMessage.msgID = [[NoaIMManagerTool sharedManager] getMessageID];
                fileChatMessage.messageType = CIMChatMessageType_FileMessage;
                fileChatMessage.isAck = YES;
                fileChatMessage.fromID = UserManager.userInfo.userUID;
                fileChatMessage.fromNickname = UserManager.userInfo.nickname;
                fileChatMessage.fromIcon = UserManager.userInfo.avatar;
                fileChatMessage.toID = to;
                fileChatMessage.sendTime = [self messageSendTimestamp];
                fileChatMessage.isSendForFile = YES;
                //将视频转移放入沙盒目录下
                //视频文件文件名
                NSArray<PHAssetResource *> *resources = [PHAssetResource assetResourcesForAsset:mediaAsset];
                PHAssetResource *resource = nil;
                for (PHAssetResource *res in resources) {
                    if ([res.assetLocalIdentifier isEqualToString:mediaAsset.localIdentifier]) {
                        resource = res;
                        break;
                    }
                }
                NSString *saxboxFileName = resource.originalFilename;
                //名称
                fileChatMessage.fileName = saxboxFileName;
                //视频大小
                fileChatMessage.fileSize = [videoData length];
                
                //文件显示在UI上的名字
                NSRange range3 = [fileChatMessage.fileName rangeOfString:@"-"];
                if (range3.length == 0) {
                    fileChatMessage.showFileName = fileChatMessage.fileName;
                } else {
                    fileChatMessage.showFileName = [fileChatMessage.fileName safeSubstringWithRange:NSMakeRange(range3.location+1, fileChatMessage.fileName.length - (range3.location+1))];
                }
                
                __block NSString *saxboxFilePath = @"";
                [ZTOOL doAsync:^{
                    //将文件保存到本地沙盒
                    [NSString saveFileToSaxboxWithData:videoData CustomPath:customPath fileName:saxboxFileName];
                    saxboxFilePath = [NSString getPathWithFileName:saxboxFileName CustomPath:customPath];
                } completion:^{
                    //文件类型
                    fileChatMessage.fileType = [NSString fileTranslateToFileType:saxboxFilePath];
                    //将要发送的消息体传递出去
                    if (compelete) {
                        compelete(fileChatMessage);
                    }
                }];
            } else {
                //fileName 文件名为：userid+当前时间戳
                NSString *videoName = [[NSString alloc] initWithFormat:@"%@_%lld.%@", UserManager.userInfo.userUID, [NSDate currentTimeIntervalWithMillisecond], [NSString getVideoFileFormat:urlAsset.URL]];
                
                UIImage *coverImg =  [UIImage thumbnailImageForVideo:urlAsset.URL atTime:1];
                NSData *coverImgData = UIImageJPEGRepresentation(coverImg, 0.5);
                NSString *coverName = [[NSString alloc] initWithFormat:@"cover_%@_%lld.%@", UserManager.userInfo.userUID, [NSDate currentTimeIntervalWithMillisecond], [NSString getImageFileFormat:coverImgData]];
                
                NoaIMChatMessageModel *videoChatMessage = [NoaIMChatMessageModel new];
                videoChatMessage.messageSendType = CIMChatMessageSendTypeSending;
                videoChatMessage.chatType = chatType;
                videoChatMessage.messageStatus = 1;  //正常状态
                videoChatMessage.msgID = [[NoaIMManagerTool sharedManager] getMessageID];
                videoChatMessage.messageType = CIMChatMessageType_VideoMessage;
                videoChatMessage.isAck = YES;
                videoChatMessage.fromID = UserManager.userInfo.userUID;
                videoChatMessage.fromNickname = UserManager.userInfo.nickname;
                videoChatMessage.fromIcon = UserManager.userInfo.avatar;
                videoChatMessage.toID = to;
                videoChatMessage.sendTime = [self messageSendTimestamp];
                
                //length
                CMTime time = [asset duration];
                int64_t seconds = time.value/time.timescale;
                videoChatMessage.videoLength = seconds;//视频时长
                videoChatMessage.videoSize = videoData.length;
                //name
                videoChatMessage.localVideoName = videoName;//视频沙盒名称
                //cImg
                
                
                videoChatMessage.videoCoverSize = coverImgData.length;
                videoChatMessage.localVideoCover = coverName;//视频封面沙盒名称
                //cWith   cHeight
                videoChatMessage.videoCoverW = coverImg.size.width;
                videoChatMessage.videoCoverH = coverImg.size.height;
                
                [ZTOOL doAsync:^{
                    //将视频封面图转移放入沙盒目录下
                    [NSString saveImageToSaxboxWithData:coverImgData CustomPath:customPath ImgName:coverName];
                    //将视频文件转移放入沙盒目录下
                    [NSString saveVideoToSaxboxWithData:videoData CustomPath:customPath VideoName:videoName];
                } completion:^{
                    //将messageModel传出去，进行上传操作和UI展示
                    if (compelete) {
                        compelete(videoChatMessage);
                    }
                }];
            }
        }
    }];
}

#pragma mark - 发送语音消息
+ (void)ZMessageVoiceSend:(NSString *)voicePath fileName:(NSString *)fileName voiceDuring:(float)voiceDuring withToUserId:(NSString *)to withChatType:(CIMChatType)chatType compelete:(void(^)(NoaIMChatMessageModel * sendChatMsg))compelete {
    //发送语音
    NoaIMChatMessageModel *voiceChatMessage = [NoaIMChatMessageModel new];
    voiceChatMessage.messageSendType = CIMChatMessageSendTypeSending;
    voiceChatMessage.chatType = chatType;
    voiceChatMessage.messageStatus = 1;  //正常状态
    voiceChatMessage.msgID = [[NoaIMManagerTool sharedManager] getMessageID];
    voiceChatMessage.messageType = CIMChatMessageType_VoiceMessage;
    voiceChatMessage.isAck = YES;
    voiceChatMessage.fromID = UserManager.userInfo.userUID;
    voiceChatMessage.fromNickname = UserManager.userInfo.nickname;
    voiceChatMessage.fromIcon = UserManager.userInfo.avatar;
    voiceChatMessage.toID = to;
    voiceChatMessage.sendTime = [self messageSendTimestamp];
    
    //length 语音时长
    voiceChatMessage.voiceLength = (float)ceil(voiceDuring);
    //localName 语音沙盒文件名称
    voiceChatMessage.localVoiceName = fileName;
    //localVoicePath
    voiceChatMessage.localVoicePath = voicePath;
    
    //将msg传出去
    if (compelete) {
        compelete(voiceChatMessage);
    }
}

#pragma mark - 发送文件消息
+ (void)ZMessageFileSendData:(NoaFilePickModel *)fileModel withToUserId:(NSString *)to withChatType:(CIMChatType)chatType compelete:(void(^)(NoaIMChatMessageModel * sendChatMsg))compelete {
    //组合文件类型消息体
    NoaIMChatMessageModel *fileChatMessage = [NoaIMChatMessageModel new];
    fileChatMessage.messageSendType = CIMChatMessageSendTypeSending;
    fileChatMessage.chatType = chatType;
    fileChatMessage.messageStatus = 1;  //正常状态
    fileChatMessage.msgID = [[NoaIMManagerTool sharedManager] getMessageID];
    fileChatMessage.messageType = CIMChatMessageType_FileMessage;
    fileChatMessage.isAck = YES;
    fileChatMessage.fromID = UserManager.userInfo.userUID;
    fileChatMessage.fromNickname = UserManager.userInfo.nickname;
    fileChatMessage.fromIcon = UserManager.userInfo.avatar;
    fileChatMessage.toID = to;
    fileChatMessage.sendTime = [self messageSendTimestamp];
    
    //该会话的中间目录
    NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, to];
    
    //发送的是手机里的文件
    if (fileModel.fileSource == ZMsgFileSourceTypePhone) {
        NSError *error;
        NSString *encodingNewURL = [fileModel.phoneFileUrl.absoluteString stringByRemovingPercentEncoding];
        NSArray  *encodingNewURLArr = [encodingNewURL componentsSeparatedByString:@"/"];
        NSString *rawFileName = [NSString stringWithFormat:@"%@",encodingNewURLArr.lastObject];
        //将文件转换成data，并保存到指定会话的沙盒目录下
        NSData *fileData = [NSData dataWithContentsOfURL:fileModel.phoneFileUrl options:NSDataReadingMappedIfSafe error:&error];
        NSString *saxboxFileName = [NSString stringWithFormat:@"%@%lld-%@", UserManager.userInfo.userUID, [NSDate currentTimeIntervalWithMillisecond], rawFileName];
        if ([saxboxFileName hasSuffix:@".ipa1"] || [saxboxFileName hasSuffix:@".apk1"]) {
            saxboxFileName = [saxboxFileName substringToIndex:saxboxFileName.length - 1];
        }
        NSString *originFileName = saxboxFileName;
        //发送出去和展示的要加+1,本地存储不用
        if ([saxboxFileName hasSuffix:@".ipa"] || [saxboxFileName hasSuffix:@".apk"]) {
            originFileName = [saxboxFileName stringByAppendingString:@"1"];
        }
        //文件大小
        fileChatMessage.fileSize = fileData.length;
        //文件名称
        fileChatMessage.fileName = originFileName;
        //文件类型
        fileChatMessage.fileType = fileModel.fileType;
        //文件显示在UI上的名字
        NSRange range1 = [fileChatMessage.fileName rangeOfString:@"-"];
        if (range1.length == 0) {
            fileChatMessage.showFileName = fileChatMessage.fileName;
        } else {
            fileChatMessage.showFileName = [fileChatMessage.fileName safeSubstringWithRange:NSMakeRange(range1.location+1, fileChatMessage.fileName.length - (range1.location+1))];
        }
        
        [ZTOOL doAsync:^{
            [NSString saveFileToSaxboxWithData:fileData CustomPath:customPath fileName:saxboxFileName];
        } completion:^{
            if (compelete) {
                compelete(fileChatMessage);
            }
        }];
    }
    
    //发送的是App中的文件
    if (fileModel.fileSource == ZMsgFileSourceTypeLingxin) {
        NSString *fileName = fileModel.fileName;
        // 本地存储没有1,要加上
        if ([fileName hasSuffix:@".ipa"] || [fileName hasSuffix:@".apk"]) {
            fileName = [fileName stringByAppendingString:@"1"];
        }
        NSRange range = [fileName rangeOfString:@"-"];
        NSString *rawFileName;
        if(range.length == 0){
            rawFileName = fileName;
        }else{
            rawFileName = [fileName safeSubstringWithRange:NSMakeRange(range.location+1, fileName.length - (range.location+1))];
        }
        //文件大小
        fileChatMessage.fileSize = fileModel.fileSize;
        //文件类型
        fileChatMessage.fileType = fileModel.fileType;
        //文件名称
        fileChatMessage.fileName = fileName;
        //文件显示在UI上的名字
        fileChatMessage.showFileName = rawFileName;
        
        //将要发生的消息体传递出去
        if (compelete) {
            compelete(fileChatMessage);
        }
    }
    
    //发送的是相册的视频文件
    if (fileModel.fileSource == ZMsgFileSourceTypeAlbumVideo) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHVideoRequestOptionsVersionOriginal;
        options.networkAccessAllowed = YES; // 允许从 iCloud 下载
        [[PHImageManager defaultManager] requestAVAssetForVideo:fileModel.videoAsset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
            // 检查是否是 iCloud 视频下载问题
            BOOL isInCloud = [info[PHImageResultIsInCloudKey] boolValue];
            NSError *error = info[PHImageErrorKey];
            
            if (isInCloud && error) {
                NSLog(@"相册视频在 iCloud 中，需要下载: %@", error);
                // 不发送错误消息，直接返回 nil 让回调被调用
                if (compelete) {
                    compelete(nil);
                }
                return;
            }
            
            // 检查视频资源是否有效
            if (!asset || ![asset isKindOfClass:[AVURLAsset class]]) {
                NSLog(@"相册视频资源获取失败: %@", info);
                // 不发送错误消息，直接返回 nil 让回调被调用
                if (compelete) {
                    compelete(nil);
                }
                return;
            }
            
            if ([asset isKindOfClass:[AVURLAsset class]]) {
                AVURLAsset* urlAsset = (AVURLAsset*)asset;
                NSNumber *size;
                [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                //视频data
                NSData *fileVideoData = [NSData dataWithContentsOfURL:urlAsset.URL options:NSDataReadingMappedIfSafe error:nil];
                
                // 检查视频数据是否有效
                if (!fileVideoData || fileVideoData.length == 0) {
                    NSLog(@"相册视频数据读取失败");
                    // 不发送错误消息，直接返回 nil 让回调被调用
                    if (compelete) {
                        compelete(nil);
                    }
                    return;
                }
                
                //视频名称原始名称
                NSArray<PHAssetResource *> *resources = [PHAssetResource assetResourcesForAsset:fileModel.videoAsset];
                PHAssetResource *resource = nil;
                for (PHAssetResource *res in resources) {
                    if ([res.assetLocalIdentifier isEqualToString:fileModel.videoAsset.localIdentifier]) {
                        resource = res;
                        break;
                    }
                }
                NSString *videoName = resource.originalFilename;
                //文件在本地沙盒名称
                NSString *saxboxFileName = [NSString stringWithFormat:@"%@%lld-%@", UserManager.userInfo.userUID, [NSDate currentTimeIntervalWithMillisecond], videoName];
                //名称
                fileChatMessage.fileName = saxboxFileName;
                //视频大小
                fileChatMessage.fileSize = [size floatValue];
                //文件显示在UI上的名字
                NSRange range3 = [fileChatMessage.fileName rangeOfString:@"-"];
                if (range3.length == 0) {
                    fileChatMessage.showFileName = fileChatMessage.fileName;
                } else {
                    fileChatMessage.showFileName = [fileChatMessage.fileName safeSubstringWithRange:NSMakeRange(range3.location+1, fileChatMessage.fileName.length - (range3.location+1))];
                }
                
                [ZTOOL doAsync:^{
                    //将文件保存到本地沙盒
                    [NSString saveFileToSaxboxWithData:fileVideoData CustomPath:customPath fileName:saxboxFileName];
                } completion:^{
                    //文件类型
                    fileChatMessage.fileType = [NSString fileTranslateToFileType:[NSString getPathWithFileName:saxboxFileName CustomPath:customPath]];
                    //将要发生的消息体传递出去
                    if (compelete) {
                        compelete(fileChatMessage);
                    }
                }];
            }
        }];
    }
}

#pragma mark - 发送位置信息消息
+ (void)ZMessageLocationSendWithLng:(NSString *)geoLng lat:(NSString *)geoLat name:(NSString *)geoName cImg:(UIImage *)geoImg detail:(NSString *)geoDetail withToUserId:(NSString *)to withChatType:(CIMChatType)chatType compelete:(void(^)(NoaIMChatMessageModel * sendChatMsg))compelete {
    
    //cImg 文件名为：userid+当前时间戳
    NSData *geoImgData = UIImageJPEGRepresentation(geoImg, 1.0);
    NSString *geoImgName = [[NSString alloc] initWithFormat:@"%@_%lld.%@", UserManager.userInfo.userUID, [NSDate currentTimeIntervalWithMillisecond], [NSString getImageFileFormat:geoImgData]];
    //将图片放入沙盒目录下对应会话的文件夹目录里
    NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, to];
    [NSString saveImageToSaxboxWithData:geoImgData CustomPath:customPath ImgName:geoImgName];
    
    NoaIMChatMessageModel *geoChatMessage = [NoaIMChatMessageModel new];
    geoChatMessage.messageSendType = CIMChatMessageSendTypeSending;
    geoChatMessage.chatType = chatType;
    geoChatMessage.messageStatus = 1;  //正常状态
    geoChatMessage.msgID = [[NoaIMManagerTool sharedManager] getMessageID];
    geoChatMessage.messageType = CIMChatMessageType_GeoMessage;
    geoChatMessage.isAck = YES;
    geoChatMessage.fromID = UserManager.userInfo.userUID;
    geoChatMessage.fromNickname = UserManager.userInfo.nickname;
    geoChatMessage.fromIcon = UserManager.userInfo.avatar;
    geoChatMessage.toID = to;
    geoChatMessage.sendTime = [self messageSendTimestamp];
    geoChatMessage.localGeoImgName = geoImgName;//本地沙盒图片名称
    geoChatMessage.geoLat = geoLat;
    geoChatMessage.geoLng = geoLng;
    geoChatMessage.geoName = geoName;
    geoChatMessage.geoDetails = geoDetail;
    geoChatMessage.geoImgWidth = geoImg.size.width;
    geoChatMessage.geoImgHeight = geoImg.size.height;
    
    //将msg传出去，UI展示
    if (compelete) {
        compelete(geoChatMessage);
    }
}

#pragma mark - 组装图片消息-用于分享二维码
+ (void)ZMessageAssembleQRcodeImage:(UIImage *)qrImage compelete:(void(^)(NoaIMChatMessageModel * sendChatMsg))compelete {
    //fileName 文件名为：userid+当前时间戳
    NSData *imageData = UIImageJPEGRepresentation(qrImage, 1.0);
    NSString *imageName = [[NSString alloc] initWithFormat:@"%@_%lld.%@", UserManager.userInfo.userUID, [NSDate currentTimeIntervalWithMillisecond], [NSString getImageFileFormat:imageData]];
    NSString *thumbImageName =[NSString stringWithFormat:@"thumbnail_%@", imageName];
    NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, @"qrcode_share"];
    //组装消息体
    NoaIMChatMessageModel *qrImgChatMessage = [NoaIMChatMessageModel new];
    qrImgChatMessage.messageSendType = CIMChatMessageSendTypeSending;
    qrImgChatMessage.messageStatus = 1;  //正常状态
    qrImgChatMessage.msgID = [[NoaIMManagerTool sharedManager] getMessageID];
    qrImgChatMessage.messageType = CIMChatMessageType_ImageMessage;
    qrImgChatMessage.isAck = YES;
    qrImgChatMessage.fromID = UserManager.userInfo.userUID;
    qrImgChatMessage.fromNickname = UserManager.userInfo.nickname;
    qrImgChatMessage.fromIcon = UserManager.userInfo.avatar;
    qrImgChatMessage.sendTime = [self messageSendTimestamp];
    qrImgChatMessage.localImgName = imageName;//本地沙盒图片名称
    qrImgChatMessage.imgSize = CGImageGetHeight(qrImage.CGImage) * CGImageGetBytesPerRow(qrImage.CGImage);
    qrImgChatMessage.imgWidth = qrImage.size.width;
    qrImgChatMessage.imgHeight = qrImage.size.height;
    
    //将图片放入沙盒目录下对应会话的文件夹目录里
    [ZTOOL doAsync:^{
        [NSString saveImageToSaxboxWithData:imageData CustomPath:customPath ImgName:imageName];
        
        NSData *thumbnailImgData = [UIImage compressImageSize:[UIImage imageWithData:imageData] toByte:50*1024];
        [NSString saveImageToSaxboxWithData:thumbnailImgData CustomPath:customPath ImgName:thumbImageName];
    } completion:^{
        if (compelete) {
            compelete(qrImgChatMessage);
        }
    }];
}

#pragma mark - 发送 多选-合并转发 的消息记录类型的消息
+ (void)ZMessageMergeForwardSendWith:(NSArray *)multiSelectedItmeArr withTitle:(NSString *)title withToUserInfoArr:(NSArray *)userInfoArr compelete:(void(^)(NSArray <NoaIMChatMessageModel *> *sendChatMsgList))compelete {
    //组装IMChatMessage
    NSMutableArray *sendMsgList = [[NSMutableArray alloc] init];
    
    for ( NSDictionary *dict in userInfoArr) {
        NSString *receverId = [dict objectForKey:@"dialogId"];
        NSInteger chatTypeNum = [[dict objectForKey:@"dialogType"] integerValue];
        ChatType chatType = chatTypeNum == 0 ? ChatType_SingleChat : ChatType_GroupChat;
        
        NSMutableArray <IMChatMessage *> *mergeMsgList = [[NSMutableArray alloc] init];
        for (NoaMessageModel *selectedMsgModel in multiSelectedItmeArr) {
            if (selectedMsgModel.isSelf) {
                if (selectedMsgModel.message.messageType == CIMChatMessageType_AtMessage) {
                    selectedMsgModel.message.textContent = [NoaMessageTools forwardMessageAtContenTranslateToShowContent:selectedMsgModel.message.atContent atUsersDictList:selectedMsgModel.message.atUsersInfoList];
                    selectedMsgModel.message.messageType = CIMChatMessageType_TextMessage;
                } else {
                    selectedMsgModel.message.textContent = selectedMsgModel.message.textContent;
                }
            } else{
                if (selectedMsgModel.message.messageType == CIMChatMessageType_AtMessage) {
                    selectedMsgModel.message.textContent = [NoaMessageTools forwardMessageAtContenTranslateToShowContent:![NSString isNil:selectedMsgModel.message.atTranslateContent] ? selectedMsgModel.message.atTranslateContent : selectedMsgModel.message.atContent atUsersDictList:selectedMsgModel.message.atUsersInfoList];
                    selectedMsgModel.message.messageType = CIMChatMessageType_TextMessage;
                } else {
                    selectedMsgModel.message.textContent = ![NSString isNil:selectedMsgModel.message.translateContent] ? selectedMsgModel.message.translateContent : selectedMsgModel.message.textContent;
                }
            }
            IMChatMessage *imChatMessage = [NoaMessageTools getIMChatMessageFromLingIMChatMessageModelToMergeForward:selectedMsgModel.message];
            [mergeMsgList addObject:imChatMessage];
        }
        
        NoaIMChatMessageModel *recordChatMessage = [NoaIMChatMessageModel new];
        recordChatMessage.messageSendType = CIMChatMessageSendTypeSending;
        recordChatMessage.chatType = chatType;
        recordChatMessage.messageStatus = 1;  //正常状态
        recordChatMessage.msgID = [[NoaIMManagerTool sharedManager] getMessageID];
        recordChatMessage.messageType = CIMChatMessageType_ForwardMessage;
        recordChatMessage.isAck = YES;
        recordChatMessage.fromID = UserManager.userInfo.userUID;
        recordChatMessage.fromNickname = UserManager.userInfo.nickname;
        recordChatMessage.fromIcon = UserManager.userInfo.avatar;
        recordChatMessage.toID = receverId;
        recordChatMessage.sendTime = [self messageSendTimestamp];
        
        ForwardMessage *forwardMsg = [[ForwardMessage alloc] init];
        forwardMsg.type = chatType;
        forwardMsg.title = title;
        forwardMsg.messageListArray = mergeMsgList;
        
        recordChatMessage.forwardMessage = forwardMsg;
        recordChatMessage.forwardMessageProtobuf = forwardMsg.delimitedData;
        
        [sendMsgList addObject:recordChatMessage];
    }
    //组装好消息后传递给chatVC
    if (compelete) {
        compelete(sendMsgList);
    }
}

#pragma mark - 发送表情消息
+ (NoaIMChatMessageModel *)ZMessageStickersSendContentUrl:(NSString *)stickersImgUrl stickerThumbImgUrl:(NSString *)stickerThumbImgUrl stickerId:(NSString *)stickerId stickerName:(NSString *)stickerName stickerHeight:(float)stickerHeight stickerWidth:(float)stickerWidth stickerSize:(long long)stickerSize isStickersSet:(BOOL)isStickersSet stickerExt:(NSString *)stickerExt withToUserId:(NSString *)to withChatType:(CIMChatType)chatType {
    
    NoaIMChatMessageModel *stickersChatMessage = [NoaIMChatMessageModel new];
    stickersChatMessage.messageSendType = CIMChatMessageSendTypeSending;
    stickersChatMessage.referenceMsgId = nil;
    stickersChatMessage.chatType = chatType;
    stickersChatMessage.messageStatus = 1;  //正常状态
    stickersChatMessage.msgID = [[NoaIMManagerTool sharedManager] getMessageID];
    stickersChatMessage.messageType = CIMChatMessageType_StickersMessage;
    stickersChatMessage.isAck = YES;
    stickersChatMessage.fromID = UserManager.userInfo.userUID;
    stickersChatMessage.fromNickname = UserManager.userInfo.nickname;
    stickersChatMessage.fromIcon = UserManager.userInfo.avatar;
    stickersChatMessage.toID = to;
    stickersChatMessage.sendTime = [self messageSendTimestamp];
    
    stickersChatMessage.stickersHeight = stickerHeight;
    stickersChatMessage.stickersWidth = stickerWidth;
    stickersChatMessage.stickersSize = stickerSize;
    stickersChatMessage.stickersName = stickerName;
    stickersChatMessage.stickersId = stickerId;
    stickersChatMessage.stickersThumbnailImg = stickerThumbImgUrl;
    stickersChatMessage.stickersImg = stickersImgUrl;
    stickersChatMessage.isStickersSet = isStickersSet;
    stickersChatMessage.stickersExt = stickerExt;
    
    return stickersChatMessage;
}

#pragma mark - 发送游戏表情消息
+ (NoaIMChatMessageModel *)ZMessageGameStickersSendResultContent:(NSString *)resultContent gameStickersType:(ZChatGameStickerType)gameStickersType gameStickerExt:(NSString *)gameStickerExt withToUserId:(NSString *)to withChatType:(CIMChatType)chatType {
    
    NoaIMChatMessageModel *gameStickersChatMessage = [NoaIMChatMessageModel new];
    gameStickersChatMessage.messageSendType = CIMChatMessageSendTypeSending;
    gameStickersChatMessage.referenceMsgId = nil;
    gameStickersChatMessage.chatType = chatType;
    gameStickersChatMessage.messageStatus = 1;  //正常状态
    gameStickersChatMessage.msgID = [[NoaIMManagerTool sharedManager] getMessageID];
    gameStickersChatMessage.messageType = CIMChatMessageType_GameStickersMessage;
    gameStickersChatMessage.isAck = YES;
    gameStickersChatMessage.fromID = UserManager.userInfo.userUID;
    gameStickersChatMessage.fromNickname = UserManager.userInfo.nickname;
    gameStickersChatMessage.fromIcon = UserManager.userInfo.avatar;
    gameStickersChatMessage.toID = to;
    gameStickersChatMessage.sendTime = [self messageSendTimestamp];
    
    int gameType = 0;
    if (gameStickersType == ZChatGameStickerTypeFingerGuessing) {
        gameType = 1;//剪刀石头布
    } else {
        gameType = 2;//摇骰子
    }
    gameStickersChatMessage.gameSticekersType = gameType;
    gameStickersChatMessage.gameStickersResut = resultContent;
    gameStickersChatMessage.gameStickersExt = gameStickerExt;
    gameStickersChatMessage.isGameAnimationed = NO;
    
    return gameStickersChatMessage;
}

#pragma mark - 组装已读类型消息HaveReadMessage
+ (NoaIMChatMessageModel *)ZMessageReadedWithMsgSidList:(NSArray *)readedMsgSidList withToUserId:(NSString *)to withChatType:(CIMChatType)chatType {
    
    NoaIMChatMessageModel *haveReadMessage = [NoaIMChatMessageModel new];
    haveReadMessage.messageSendType = CIMChatMessageSendTypeSending;
    haveReadMessage.referenceMsgId = nil;
    haveReadMessage.chatType = chatType;
    haveReadMessage.messageStatus = 1;  //正常状态
    haveReadMessage.msgID = [[NoaIMManagerTool sharedManager] getMessageID];
    haveReadMessage.messageType = CIMChatMessageType_HaveReadMessage;
    haveReadMessage.isAck = NO;
    haveReadMessage.fromID = UserManager.userInfo.userUID;
    haveReadMessage.fromNickname = UserManager.userInfo.nickname;
    haveReadMessage.fromIcon = UserManager.userInfo.avatar;
    haveReadMessage.toID = to;
    haveReadMessage.sendTime = [self messageSendTimestamp];
    
    haveReadMessage.sMsgIdArray = [readedMsgSidList mutableCopy];
    
    return haveReadMessage;
}

#pragma mark - 消息发送失败，重新发送
+ (void)ZMessageReSendWithFailMsg:(NoaMessageModel *)failMsg compelete:(void(^)(NoaIMChatMessageModel * sendChatMsg))compelete {
    
    failMsg.message.sendTime = [self messageSendTimestamp];
    failMsg.message.messageSendType = CIMChatMessageSendTypeSending;
    failMsg.message.messageStatus = 1;
    // 重发游戏表情消息时，重新生成随机结果，避免复用旧值导致博弈性卡顿
    if (failMsg.message.messageType == CIMChatMessageType_GameStickersMessage) {
        // 1: 剪刀石头布(1..3)，2: 摇骰子(1..6)
        NSInteger type = failMsg.message.gameSticekersType;
        NSString *newResult = nil;
        if (type == 1) {
            newResult = [NSString randomNumWithMin:1 max:3];
        } else {
            newResult = [NSString randomNumWithMin:1 max:6];
        }
        if (newResult.length > 0) {
            failMsg.message.gameStickersResut = newResult;
            // 重置动画播放标志，确保UI按新结果播放
            failMsg.message.isGameAnimationed = NO;
        }
    }
    //将msg传出去，UI展示
    if (compelete) {
        compelete(failMsg.message);
    }
    
    /*
    if (failMsg.message.messageType == CIMChatMessageType_TextMessage) { //重发文本消息
        failMsg.message.sendTime = [self messageSendTimestamp];
        failMsg.message.messageSendType = CIMChatMessageSendTypeSending;
        failMsg.message.messageStatus = 1;
        //将msg传出去，UI展示
        if (compelete) {
            compelete(failMsg.message);
        }
    } else if (failMsg.message.messageType == CIMChatMessageType_ImageMessage) { //重发图片消息
        failMsg.message.sendTime = [self messageSendTimestamp];
        failMsg.message.messageSendType = CIMChatMessageSendTypeSending;
        failMsg.message.messageStatus = 1;
        //将msg传出去，UI展示
        if (compelete) {
            compelete(failMsg.message);
        }
    } else if (failMsg.message.messageType == CIMChatMessageType_StickersMessage) { //重发表情消息
        failMsg.message.sendTime = [self messageSendTimestamp];
        failMsg.message.messageSendType = CIMChatMessageSendTypeSending;
        failMsg.message.messageStatus = 1;
        //将msg传出去，UI展示
        if (compelete) {
            compelete(failMsg.message);
        }
    } else if (failMsg.message.messageType == CIMChatMessageType_GameStickersMessage) { //重发游戏表情消息
        failMsg.message.sendTime = [self messageSendTimestamp];
        failMsg.message.messageSendType = CIMChatMessageSendTypeSending;
        failMsg.message.messageStatus = 1;
        //将msg传出去，UI展示
        if (compelete) {
            compelete(failMsg.message);
        }
    } else if (failMsg.message.messageType == CIMChatMessageType_VideoMessage) { //重发视频消息
        failMsg.message.sendTime = [self messageSendTimestamp];
        failMsg.message.messageSendType = CIMChatMessageSendTypeSending;
        failMsg.message.messageStatus = 1;
        //将msg传出去，UI展示
        if (compelete) {
            compelete(failMsg.message);
        }
        
        //专属目录
        NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, failMsg.message.toID];
        //封面图
        UIImage *reSendCover = [NSString getImageWithImgName:failMsg.message.localVideoCover CustomPath:customPath];
        NSData *coverImgData = UIImageJPEGRepresentation(reSendCover, 0.5);
        //视频文件
        NSData *videoData = [NSString getVideoDataWithVideoName:failMsg.message.localVideoName CustomPath:customPath];
        //上传视频封面图和视频
        if (fileUpload) {
            fileUpload(videoData, coverImgData, failMsg.message.localVideoCover, failMsg.message);
        }
    } else if (failMsg.message.messageType == CIMChatMessageType_AtMessage) {  //重发 @消息
        failMsg.message.sendTime = [self messageSendTimestamp];
        failMsg.message.messageSendType = CIMChatMessageSendTypeSending;
        failMsg.message.messageStatus = 1;
        //将msg传出去，UI展示
        if (compelete) {
            compelete(failMsg.message);
        }
    } else if (failMsg.message.messageType == CIMChatMessageType_VoiceMessage) {  //重发 语音消息
        failMsg.message.sendTime = [self messageSendTimestamp];
        failMsg.message.messageSendType = CIMChatMessageSendTypeSending;
        failMsg.message.messageStatus = 1;
        //将msg传出去，UI展示
        if (compelete) {
            compelete(failMsg.message);
        }
        
        NSString *folderPath = [NSString getVoiceDiectoryWithCustomPath:[NSString stringWithFormat:@"%@-%@",UserManager.userInfo.userUID, failMsg.message.toID]];
        NSString *voicePath = [NSString stringWithFormat:@"%@/%@", folderPath, failMsg.message.localVoiceName];
        NSData *audioData = [NSData dataWithContentsOfFile:voicePath options:NSDataReadingMappedIfSafe error:nil];
        //上传语音文件
        if (fileUpload) {
            fileUpload(audioData, nil, failMsg.message.localVoiceName, failMsg.message);
        }
    } else if (failMsg.message.messageType == CIMChatMessageType_FileMessage) {  //重发 文件类型消息
        failMsg.message.sendTime = [self messageSendTimestamp];
        failMsg.message.messageSendType = CIMChatMessageSendTypeSending;
        failMsg.message.messageStatus = 1;
        //将msg传出去，UI展示
        if (compelete) {
            compelete(failMsg.message);
        }
    } else if (failMsg.message.messageType == CIMChatMessageType_CardMessage) { //重发 名片消息
        failMsg.message.sendTime = [self messageSendTimestamp];
        failMsg.message.messageSendType = CIMChatMessageSendTypeSending;
        failMsg.message.messageStatus = 1;
        //将msg传出去，UI展示
        if (compelete) {
            compelete(failMsg.message);
        }
    } else if (failMsg.message.messageType == CIMChatMessageType_GeoMessage) { //重发 地理位置消息
        failMsg.message.sendTime = [self messageSendTimestamp];
        failMsg.message.messageSendType = CIMChatMessageSendTypeSending;
        failMsg.message.messageStatus = 1;
        //将msg传出去，UI展示
        if (compelete) {
            compelete(failMsg.message);
        }
        
        NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, failMsg.message.toID];
        UIImage *reSendImage = [NSString getImageWithImgName:failMsg.message.localGeoImgName CustomPath:customPath];
        NSData *imageData = UIImageJPEGRepresentation(reSendImage, 0.5);
        //上传图片
        if (fileUpload) {
            fileUpload(imageData, nil, failMsg.message.localGeoImgName, failMsg.message);
        }
    } else if (failMsg.message.messageType == CIMChatMessageType_ForwardMessage) {  //重发 @消息
        failMsg.message.sendTime = [self messageSendTimestamp];
        failMsg.message.messageSendType = CIMChatMessageSendTypeSending;
        failMsg.message.messageStatus = 1;
        //将msg传出去，UI展示
        if (compelete) {
            compelete(failMsg.message);
        }
    } else {
        return;
    }
    */
    
}

@end
