//
//  NoaFileDownloadManager.h
//  NoaKit
//
//  Created by Candy on 2024/3/9.
//

#import <Foundation/Foundation.h>
#import "NoaFileDownloadTask.h"
#import "ModuleProtocol.h"

@interface NoaFileDownloadManager : NSObject<ModuleProtocol, ZFileDownloadTaskDelegate>

//需要执行的任务队列
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@property (nonatomic, assign) NSInteger maxConcurrentUploads;

- (void)addDownloadTask:(NoaFileDownloadTask *)task;

- (NoaFileDownloadTask *)getTaskWithId:(NSString *)taskId;


@end

