//
//  NoaFileDownloadManager.m
//  NoaKit
//
//  Created by Candy on 2024/3/9.
//

#import "NoaFileDownloadManager.h"
#import "NoaFileOssInfoModel.h"

@interface NoaFileDownloadManager ()

//任务缓存队列，存放 暂停，失败，完成的任务
@property (nonatomic, strong) NSMutableArray <NoaFileDownloadTask *> * taskCache;

@end

@implementation NoaFileDownloadManager

SharedInstance(NoaFileDownloadManager)

- (void)addDownloadTask:(NoaFileDownloadTask *)task {
    if(![self.operationQueue.operations containsObject:task]){
        [task addDelegate:self];
        [self.operationQueue addOperation:task];
    }
}

- (NoaFileDownloadTask *)getTaskWithId:(NSString *)taskId{
    NoaFileDownloadTask * downloadTask;
       for (NoaFileDownloadTask * task in self.operationQueue.operations) {
           if ([task isKindOfClass:[NoaFileDownloadTask class]] &&[task.taskId isEqualToString:taskId]) {
               downloadTask = task;
           }
       }
       if(downloadTask == nil){
           for (NoaFileDownloadTask * task in self.taskCache) {
               if ([task isKindOfClass:[NoaFileDownloadTask class]] &&[task.taskId isEqualToString:taskId]) {
                   downloadTask = task;
               }
           }
       }
       return downloadTask;
}

#pragma mark- --------<ZFileUploadTaskDelegate>--------
- (void)fileDownloadTask:(NoaFileDownloadTask *)task didChangTaskProgress:(float)progress {
    
}

- (void)fileDownloadTask:(NoaFileDownloadTask *)task didChangTaskStatus:(FileDownloadTaskStatus)status error:(NSError *)error {
    if((status == FileDownloadTaskStatus_Failed ||
        status == FileDownloadTaskStatus_Completed) &&
       ![self.taskCache containsObject:task]){
        [self.taskCache addObject:task];
    }
}

-(NSOperationQueue *)operationQueue{
    if (_operationQueue == nil) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 5; // Default value
    }
    return _operationQueue;
}

-(NSMutableArray<NoaFileDownloadTask *> *)taskCache{
    if (_taskCache == nil) {
        _taskCache = [[NSMutableArray alloc] init];
    }
    return _taskCache;
}


@end
