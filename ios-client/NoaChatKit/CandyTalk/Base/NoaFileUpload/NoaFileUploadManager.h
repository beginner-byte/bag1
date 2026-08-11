//
//  NoaFileUploadManager.h
//  NoaKit
//
//  Created by Candy on 2024/3/9.
//

#import <Foundation/Foundation.h>
#import "NoaFileUploadTask.h"
#import "ModuleProtocol.h"
#import "NoaFileOssInfoModel.h"
#import "NoaFileUploadGetSTSTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaFileUploadManager : NSObject<ModuleProtocol,ZFileUploadTaskDelegate>

//需要执行的任务队列
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@property (nonatomic, assign) NSInteger maxConcurrentUploads;

//STSInfo
@property (nonatomic, strong) NoaFileOssInfoModel * stsInfo;

- (void)addUploadTask:(NoaFileUploadTask *)task;

- (NoaFileUploadTask *)getTaskWithId:(NSString *)taskId;


@end

NS_ASSUME_NONNULL_END
