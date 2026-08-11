//
//  NoaFileUploadManager.m
//  NoaKit
//
//  Created by Candy on 2024/3/9.
//

#import "NoaFileUploadManager.h"
#import "NoaFileOssInfoModel.h"

@interface NoaFileUploadManager ()

//任务缓存队列，存放 暂停，失败，完成的任务
@property (nonatomic, strong) NSMutableArray <NoaFileUploadTask *> * taskCache;

@end


@implementation NoaFileUploadManager

SharedInstance(NoaFileUploadManager)

- (void)addUploadTask:(NoaFileUploadTask *)task {
    //最大允许上传文件大小权限判断
    if (task.uploadType == ZHttpUploadTypeFile) {
        //文件
        if ([UserManager.userRoleAuthInfo.upFile.configValue isEqualToString:@"false"]) {
            return;
        } else {
            if (task.dataLength > 1024 * 1024 * [UserManager.userRoleAuthInfo.upFile.configData integerValue]) {
                NSString *tipsStr = [NSString stringWithFormat: LanguageToolMatch(@"最大可发送%@MB文件"), UserManager.userRoleAuthInfo.upFile.configData];
                [HUD showMessage:tipsStr];
                return;
            }
        }
    }
    if (task.uploadType == ZHttpUploadTypeImage || task.uploadType == ZHttpUploadTypeImageThumbnail || task.uploadType == ZHttpUploadTypeVideo) {
        //图片/视频
        if ([UserManager.userRoleAuthInfo.upImageVideoFile.configValue isEqualToString:@"false"]) {
            return;
        } else {
            if (task.dataLength > 1024 * 1024 * [UserManager.userRoleAuthInfo.upImageVideoFile.configData integerValue]) {
                NSString *tipsStr = [NSString stringWithFormat: LanguageToolMatch(@"最大可发送%@MB文件"), UserManager.userRoleAuthInfo.upImageVideoFile.configData];
                [HUD showMessage:tipsStr];
                return;
            }
        }
    }
  
    //判断当前设置的是哪种存储方式：minio / oss / aws
    if ([ZHostTool.appSysSetModel.oss_config_type isEqualToString:@"0"]) {
        //minio上传方式
        [self minioUploadWithTask:task];
    }
    if ([ZHostTool.appSysSetModel.oss_config_type isEqualToString:@"1"] || [ZHostTool.appSysSetModel.oss_config_type isEqualToString:@"2"] || [ZHostTool.appSysSetModel.oss_config_type isEqualToString:@"3"] ||
        [ZHostTool.appSysSetModel.oss_config_type isEqualToString:@"4"]) {
        //阿里云 / 亚马逊云 / 腾讯云 / 华为云 需先检查上传token是否失效
        [self thirdOssUploadWithTask:task];
    }
}

- (NoaFileUploadTask *)getTaskWithId:(NSString *)taskId{
    NoaFileUploadTask * uploadTask;
       for (NoaFileUploadTask * task in self.operationQueue.operations) {
           if ([task isKindOfClass:[NoaFileUploadTask class]] &&[task.taskId isEqualToString:taskId]) {
               uploadTask = task;
           }
       }
       if(uploadTask == nil){
           for (NoaFileUploadTask * task in self.taskCache) {
               if ([task isKindOfClass:[NoaFileUploadTask class]] &&[task.taskId isEqualToString:taskId]) {
                   uploadTask = task;
               }
           }
       }
       return uploadTask;
}

#pragma mark - minio上传
- (void)minioUploadWithTask:(NoaFileUploadTask *)task {
    if (task.dataLength > (1024*1024*100)) {
        //大文件分片上传
        if(![self.operationQueue.operations containsObject:task]){
            task.uploadModelType = FileUploadModelTypeMinioFragment;
            [task addDelegate:self];
            [self.operationQueue addOperation:task];
        }
    } else {
        //单个文件上传
        if(![self.operationQueue.operations containsObject:task]){
            task.uploadModelType = FileUploadModelTypeMinioSingle;
            [task addDelegate:self];
            [self.operationQueue addOperation:task];
        }
    }
}

//阿里云/亚马逊云/腾讯云 上传
- (void)thirdOssUploadWithTask:(NoaFileUploadTask *)task {
    if(![self.operationQueue.operations containsObject:task]){
        task.uploadModelType = FileUploadModelTypeThirdOss;
        [task addDelegate:self];
        [self.operationQueue addOperation:task];
    }
}

#pragma mark- --------<ZFileUploadTaskDelegate>--------
- (void)fileUploadTask:(NoaFileUploadTask *)task didChangTaskProgress:(float)progress {
    
}

- (void)fileUploadTask:(NoaFileUploadTask *)task didChangTaskStatus:(FileUploadTaskStatus)status error:(NSError *)error {
    if (task == nil) {
        return;
    }
    if((status == FileUploadTaskStatus_Failed ||
        status == FileUploadTaskStatus_Completed) &&
       ![self.taskCache containsObject:task]){
        [self.taskCache addObject:task];
    }
}

- (void)fileUploadTaskDidPause:(NoaFileUploadTask *)task {
    
}

//继续下载
- (void)fileUploadTaskDidResume:(NoaFileUploadTask *)task {
    //将任务 从新添加到队列中
}

//重新下载
- (void)fileUploadTaskDidReupload:(NoaFileUploadTask *)task {
}

-(NSOperationQueue *)operationQueue{
    if (_operationQueue == nil) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 5; // Default value
    }
    return _operationQueue;
}

-(NSMutableArray<NoaFileUploadTask *> *)taskCache{
    if (_taskCache == nil) {
        _taskCache = [[NSMutableArray alloc] init];
    }
    return _taskCache;
}


@end
