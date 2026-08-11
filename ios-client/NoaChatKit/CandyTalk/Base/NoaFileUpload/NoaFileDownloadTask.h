//
//  NoaFileDownloadTask.h
//  NoaKit
//
//  Created by Candy on 2024/3/9.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FileDownloadTaskStatus) {
    FileDownloadTaskStatus_Download,         //下载中
    FileDownloadTaskStatus_Failed,         //下载失败
    FileDownloadTaskStatus_Completed       //下载完成
};

@class NoaFileDownloadTask;
@protocol ZFileDownloadTaskDelegate <NSObject>

//任务状态改变回调
-(void)fileDownloadTask:(NoaFileDownloadTask *)task didChangTaskStatus:(FileDownloadTaskStatus)status error:(NSError *)error;

//任务上传进度回调
-(void)fileDownloadTask:(NoaFileDownloadTask *)task didChangTaskProgress:(float)progress;

@end

@interface NoaFileDownloadTask : NSOperation

@property (nonatomic, copy) NSString * taskId;

//要下载的资源文件Url
@property (nonatomic, copy) NSString * fileUrl;

//要下载保存本地的资源文件名称
@property (nonatomic, copy) NSString * saveName;

//要下载的资源文件本地路径
@property (nonatomic, copy) NSString * savePath;

//进度
@property (nonatomic, assign) CGFloat progress;

//任务状态
@property (nonatomic, assign) FileDownloadTaskStatus status;

//下载后是否需要解密
@property (nonatomic, assign) BOOL isDecryption;

//多代理回调 使用 weakObjectsHashTable 防止循环引用
@property (nonatomic, strong) NSHashTable <id<ZFileDownloadTaskDelegate>> * delegates;



- (instancetype)initWithTaskId:(NSString *)taskId
                       fileUrl:(NSString *)fileUrl
                      saveName:(NSString *)saveName
                      savePath:(NSString *)savePath
                      delegate:(id<ZFileDownloadTaskDelegate>)delegate;

-(void)addDelegate:(id<ZFileDownloadTaskDelegate>)delegate;

- (void)removeDelegate:(id<ZFileDownloadTaskDelegate>)delegate;

@end

