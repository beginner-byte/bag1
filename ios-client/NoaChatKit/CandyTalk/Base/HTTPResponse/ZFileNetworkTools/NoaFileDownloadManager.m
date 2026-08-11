//
//  ZFileUploadManager.m
//  MUIKit
//
//  Created by Candy on 2023/12/15.
//

#import "NoaFileUploadManager.h"

@interface NoaFileUploadManager ()

//需要执行的任务队列
@property (nonatomic, strong) NSOperationQueue * operationQueue;

//任务缓存队列，存放 暂停，失败，完成的任务
@property (nonatomic, strong) NSMutableArray <NoaFileDownloadTask *> * taskCache;


@end

@implementation NoaFileUploadManager

SharedInstance(NoaFileUploadManager)


- (void)addDownloadTask:(NoaFileDownloadTask *)task{
    if(![self.operationQueue.operations containsObject:task]){
        [task addDelegate:self];
        [self.operationQueue addOperation:task];
    }
    
}

- (NoaFileDownloadTask *)getTaskWithId:(NSString *)taskId{
    NoaFileDownloadTask * downloadTask;
    for (NoaFileDownloadTask * task in self.operationQueue.operations) {
        if ([task.taskId isEqualToString:taskId]) {
            downloadTask = task;
        }
    }
    if(downloadTask == nil){
        for (NoaFileDownloadTask * task in self.taskCache) {
            if ([task.taskId isEqualToString:taskId]) {
                downloadTask = task;
            }
        }
    }
    return downloadTask;
}


#pragma mark- --------<ZFileDownloadTaskDelegate>--------
- (void)fileDownloadTask:(NoaFileDownloadTask *)task didChangTaskProgress:(float)progress {
    
}

- (void)fileDownloadTask:(NoaFileDownloadTask *)task didChangTaskStatus:(FileDownloadTaskStatus)status error:(NSError *)error {
    if((status == FileDownloadTaskStatus_Failed ||
       status == FileDownloadTaskStatus_Completed ||
       status == FileDownloadTaskStatus_Paused) &&
       ![self.taskCache containsObject:task]){
        [self.taskCache addObject:task];
    }
}

- (void)fileDownloadTaskDidPause:(NoaFileDownloadTask *)task {
    
}

//继续下载
- (void)fileDownloadTaskDidResume:(NoaFileDownloadTask *)task {
    //将任务 从新添加到队列中
    //创建一个新的 task 对象 ，否则addDownloadTask会报错，
    //这里可以决定是放在 队列末尾 还是放在队列最前面。
    NoaFileDownloadTask * newTask = [[NoaFileDownloadTask alloc] initWithTaskId:task.taskId sourceURL:task.sourceURL downloadPath:task.downloadPath delegate:nil];
    newTask.delegates = task.delegates;
    newTask.progress = task.progress;
    newTask.status = task.status;
    newTask.session = task.session;
    [self addDownloadTask:newTask];
    [self.taskCache removeObject:task];
}

//重新下载
- (void)fileDownloadTaskDidRedownload:(NoaFileDownloadTask *)task {
    NoaFileDownloadTask * newTask = [[NoaFileDownloadTask alloc] initWithTaskId:task.taskId sourceURL:task.sourceURL downloadPath:task.downloadPath delegate:nil];
    newTask.delegates = task.delegates;
    [self addDownloadTask:newTask];
    [self.taskCache removeObject:task];
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
