//
//  ZFileManager.m
//  CIMKit
//
//  Created by Apple on 2023/8/17.
//

#import "NoaFileManager.h"
#import "ZFileNetProgressManager.h"
@implementation NoaFileManager
+ (instancetype)shareFileManager{
    static dispatch_once_t onceToken;
    static NoaFileManager *_manager = nil;
    dispatch_once(&onceToken, ^{
        //不能再使用alloc方法
        //因为已经重写了allocWithZone方法，所以这里要调用父类的分配空间的方法
        _manager = [[super allocWithZone:NULL] init];
    });
    return _manager;
}

// 防止外部调用alloc 或者 new
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [NoaFileManager shareFileManager];
}

// 防止外部调用copy
- (id)copyWithZone:(nullable NSZone *)zone {
    return [NoaFileManager shareFileManager];
}

// 防止外部调用mutableCopy
- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [NoaFileManager shareFileManager];
}
- (void)sendImageUploadFileWithData:(NSData *)fileData
                  filePath:(NSString *)filePath
                  fileName:(NSString *)fileName
                  chatMessageModel:(LingIMChatMessageModel * _Nullable)chatMsgModel
                uploadType:(ZHttpUploadType)uploadType
              messageModel:(NoaMessageModel * _Nullable)model
           progressHandler:(progressBlock)progressHandler
           completeHandler:(completeBlock)completeHandler
            failureHandler:(failureBlock)failureHandler{
    
    [[ZFileNetProgressManager shareFileManager] uploadFileWithData:fileData filePath:filePath fileName:fileName uploadType:ZHttpUploadTypeImage messageModel:nil progressHandler:^(long long byteSent, long long totalByte) {
        
    } completeHandler:^(NSString * _Nullable fileUrl, NSString * _Nullable thumbnailUrl) {
        
        NSData *thumbnailImgData = [UIImage compressImageSize:chatMsgModel.localImg toByte:50*1024];
        NSString *thumbnailFileName = [NSString stringWithFormat:@"thumbnail_%@",fileName];
        
        NSString *customPath = [NSString stringWithFormat:@"thumbnail_%@", filePath];
        NSString *thumbnailFilePath = [NSString getPathWithImageName:thumbnailFileName CustomPath:customPath];
        
        NSData * encryThumbnailImgData = [[NoaEncryptManager shareEncryManager] xorEncrypt:thumbnailImgData];
        
        [[ZFileNetProgressManager shareFileManager] uploadFileWithData:encryThumbnailImgData filePath:thumbnailFilePath fileName:thumbnailFileName uploadType:ZHttpUploadTypeImage messageModel:nil progressHandler:^(long long byteSent, long long totalByte) {
        
        } completeHandler:^(NSString * _Nullable fileUrl, NSString * _Nullable thumbnailUrl) {
            chatMsgModel.thumbnailImg = fileUrl;
            [IMSDKManager toolSendChatMessageWith:chatMsgModel];
        } failureHandler:^(NSString * _Nullable msg) {
            if(failureHandler){
                failureHandler(msg);
            }
        }];
        chatMsgModel.imgName = fileUrl;
        //上传成功
    } failureHandler:^(NSString * _Nullable msg) {
        if(failureHandler){
            failureHandler(msg);
        }
    }];
}
- (void)sendVideoUploadFileWithData:(NSData *)videofileData
                       coverImgData:(NSData *)coverImageData
                      coverFilePath:(NSString *)coverFilePath
                      coverFileName:(NSString *)coverImageName
                           fileName:(NSString *)fileName
                          sessionID:(NSString *)sessionID
                   chatMessageModel:(LingIMChatMessageModel *)chatMsgModel
                         uploadType:(ZHttpUploadType)uploadType
                       messageModel:(NoaMessageModel * _Nullable)model
                    progressHandler:(progressBlock)progressHandler
                    completeHandler:(completeBlock)completeHandler
                  imgfailureHandler:(failureBlock)imgFailureHandler
                videofailureHandler:(failureBlock)videoFailureHandler{
    
    [ [ZFileNetProgressManager shareFileManager] uploadFileWithData:coverImageData filePath:coverFilePath fileName:coverImageName uploadType:ZHttpUploadTypeImage messageModel:nil progressHandler:^(long long byteSent, long long totalByte) {
    } completeHandler:^(NSString * _Nullable fileUrl, NSString * _Nullable thumbnailUrl) {
        chatMsgModel.videoCover = fileUrl;
        //上传视频
        NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, sessionID];
        NSString *filePath = [NSString getPathWithVideoName:fileName CustomPath:customPath];
        NSString *tempFileName = [fileName stringByReplacingOccurrencesOfString:@".mp4" withString:@""];
        NSString *resultFileName = [NSString stringWithFormat:@"%@.mp4", [tempFileName MD5Encryption]];
        [[ZFileNetProgressManager shareFileManager] uploadFileWithData:videofileData filePath:filePath fileName:resultFileName uploadType:ZHttpUploadTypeVideo messageModel:nil progressHandler:^(long long byteSent, long long totalByte) {
            
        } completeHandler:^(NSString * _Nullable fileUrl, NSString * _Nullable thumbnailUrl) {
            chatMsgModel.videoName = fileUrl;
            //上传成功
            [IMSDKManager toolSendChatMessageWith:chatMsgModel];

        } failureHandler:^(NSString * _Nullable msg) {
            if(videoFailureHandler){
                videoFailureHandler(@"");
            }
        }];
    } failureHandler:^(NSString * _Nullable msg) {
        if(imgFailureHandler){
            imgFailureHandler(@"");
        }
    }];
}
- (void)sendUploadFileWithData:(NSData *)fileData
                  filePath:(NSString *)filePath
                  fileName:(NSString *)fileName
                uploadType:(ZHttpUploadType)uploadType
              messageModel:(NoaMessageModel * _Nullable)model
           progressHandler:(progressBlock)progressHandler
           completeHandler:(completeBlock)completeHandler
            failureHandler:(failureBlock)failureHandler{
    [[ZFileNetProgressManager shareFileManager] uploadFileWithData:fileData filePath:filePath fileName:model.message.fileName uploadType:ZHttpUploadTypeFile messageModel:model progressHandler:^(long long byteSent, long long totalByte) {
        DLog(@"totalByteSent %lld totalBytesExpectedToSend %lld",byteSent,totalByte);
    } completeHandler:^(NSString * _Nullable fileUrl, NSString * _Nullable thumbnailUrl) {
        model.message.filePath = fileUrl;
        LingIMChatMessageModel *tempFileChatMessageModel = [IMSDKManager toolGetOneChatMessageWithMessageID:model.message.msgID sessionID:model.message.toID];
        if ([NSString isNil:tempFileChatMessageModel.filePath]) {
            //防止重复发送同一条消息，上传文件方法，放在Cell有问题
            [IMSDKManager toolSendChatMessageWith:model.message];
        }
    } failureHandler:^(NSString * _Nullable msg) {
        if(failureHandler){
            failureHandler(@"");
        }
    }];
}
- (void)sendVoiceUploadFileWithData:(NSData *)fileData
                  filePath:(NSString *)filePath
                  fileName:(NSString *)fileName
                   chatMessageModel:(LingIMChatMessageModel *)chatMsgModel
                uploadType:(ZHttpUploadType)uploadType
              messageModel:(NoaMessageModel * _Nullable)model
           progressHandler:(progressBlock)progressHandler
           completeHandler:(completeBlock)completeHandler
                     failureHandler:(failureBlock)failureHandler{
    [[ZFileNetProgressManager shareFileManager] uploadFileWithData:fileData filePath:@"" fileName:fileName uploadType:ZHttpUploadTypeVoice messageModel:nil progressHandler:^(long long byteSent, long long totalByte) {
    } completeHandler:^(NSString * _Nullable fileUrl, NSString * _Nullable thumbnailUrl) {
        //需要等语音文件上传完成后，拿到文件路径，再发送消息
        chatMsgModel.voiceName = fileUrl;
        [IMSDKManager toolSendChatMessageWith:chatMsgModel];
    } failureHandler:^(NSString * _Nullable msg) {
        if(failureHandler){
            failureHandler(@"");
        }
    }];
}
@end
