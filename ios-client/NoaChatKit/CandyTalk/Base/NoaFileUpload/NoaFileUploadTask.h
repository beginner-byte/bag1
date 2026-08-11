//
//  NoaFileUploadTask.h
//  MUIKit
//
//  Created by Candy on 2023/12/15.
//

#import <Foundation/Foundation.h>
#import "NoaFileUploadTools.h"

typedef NS_ENUM(NSInteger, FileUploadTaskStatus) {
    FileUploadTaskStatus_Weating,        //等待上传
    FileUploadTaskStatus_Upload,         //上传中
    FileUploadTaskStatus_Paused,         //暂停
    FileUploadTaskStatus_Failed,         //上传失败
    FileUploadTaskStatus_Completed       //上传完成
};

typedef NS_ENUM(NSInteger, FileUploadModelType) {
    FileUploadModelTypeMinioSingle = 1,     //minio单个文件上次
    FileUploadModelTypeMinioFragment = 2,   //minio分片上传
    FileUploadModelTypeThirdOss = 3,        //第三方云存储上传
    FileUploadModelTypeAliyun = 4,          //阿里云上传
    FileUploadModelTypeAWS = 5,             //亚马逊云上传
    FileUploadModelTypeTencent = 6,         //腾讯云云上传
    FileUploadModelTypeOBS = 7,             //华为云云上传
};

typedef NS_ENUM(NSInteger, FileUploadMessageTaskType) {
    FileUploadMessageTaskTypeImage,         //图片消息-图片
    FileUploadMessageTaskTypeThumbImage,    //图片消息-图片缩略图
    FileUploadMessageTaskTypeCover,         //视频消息-封面图
    FileUploadMessageTaskTypeVideo,         //视频消息-视频
    FileUploadMessageTaskTypeFile,          //文件消息-文件
    FileUploadMessageTaskTypeVoice,         //语音消息-语音
    FileUploadMessageTaskTypeGeoImg,        //地理位置消息-地图截图
    FileUploadMessageTaskTypeStickerThumb,  //上传表情图片-缩略图
    FileUploadMessageTaskTypeSticker,       //上传表情图片-原图
    FileUploadMessageTaskTypeNoamlImgThumb, //上传图片-缩略图
    FileUploadMessageTaskTypeNoamlImg,       //上传图片-原图
};

@class NoaFileUploadTask;
@protocol ZFileUploadTaskDelegate <NSObject>

//任务状态改变回调
-(void)fileUploadTask:(NoaFileUploadTask *)task didChangTaskStatus:(FileUploadTaskStatus)status error:(NSError *)error;

//任务上传进度回调
-(void)fileUploadTask:(NoaFileUploadTask *)task didChangTaskProgress:(float)progress;

//任务暂停
-(void)fileUploadTaskDidPause:(NoaFileUploadTask *)task;

//任务继续
-(void)fileUploadTaskDidResume:(NoaFileUploadTask *)task;

@end


@interface NoaFileUploadTask : NSOperation

//任务ID
@property (nonatomic, copy) NSString * taskId;

//要上传的资源文件路径
@property (nonatomic, copy) NSString * filePath;

//如果上传的是图片消息里的缩略图，此处存放原图沙盒路径
@property (nonatomic, copy) NSString * originFilePath;

//要上传的资源文件名称
@property (nonatomic, copy) NSString * fileName;

//要上传的资源文件类型
@property (nonatomic, copy) NSString * fileType;

//上传时是否需要加密
@property (nonatomic, assign) BOOL isEncrypt;

//上传文件的大小
@property (nonatomic, assign) NSUInteger dataLength;

//上传文件类型
@property (nonatomic, assign) ZHttpUploadType uploadType;

//上传方式
@property (nonatomic, assign) FileUploadModelType uploadModelType;

//task对应的消息的文件类型
@property (nonatomic, assign) FileUploadMessageTaskType messageTaskType;

//要上传的资源文件名称（缩略图）
@property (nonatomic, copy) NSString * thumbUrl;

//要上传的资源文件名称（原图/原始文件）
@property (nonatomic, copy) NSString * originUrl;

//该资源对应的消息体
@property (nonatomic, strong) NoaIMChatMessageModel * beSendMessage;

//进度
@property (nonatomic, assign) CGFloat progress;

//任务状态
@property (nonatomic, assign) FileUploadTaskStatus status;

//多代理回调 使用 weakObjectsHashTable 防止循环引用
@property (nonatomic, strong) NSHashTable <id<ZFileUploadTaskDelegate>> * delegates;

@property (nonatomic, strong) NSURLSessionDataTask *session;



- (instancetype)initWithTaskId:(NSString *)taskId
                      filePath:(NSString *)filePath
                originFilePath:(NSString *)originFilePath
                      fileName:(NSString *)fileName
                      fileType:(NSString *)fileType
                     isEncrypt:(BOOL)isEncrypt
                    dataLength:(NSUInteger)dataLength
                    uploadType:(ZHttpUploadType)uploadType
                 beSendMessage:(NoaIMChatMessageModel *)beSendMessage
                      delegate:(id<ZFileUploadTaskDelegate>)delegate;

//任务暂停
- (void)pause;

//任务继续
- (void)resume;

-(void)addDelegate:(id<ZFileUploadTaskDelegate>)delegate;

- (void)removeDelegate:(id<ZFileUploadTaskDelegate>)delegate;


@end


