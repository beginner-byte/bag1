//
//  NoaFileDownloadTask.m
//  NoaKit
//
//  Created by Candy on 2024/3/9.
//

#import "NoaFileDownloadTask.h"
#import "NoaFileDownloadManager.h"

@interface NoaFileDownloadTask()

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation NoaFileDownloadTask

- (instancetype)initWithTaskId:(NSString *)taskId
                       fileUrl:(NSString *)fileUrl
                      saveName:(NSString *)saveName
                      savePath:(NSString *)savePath
                      delegate:(id<ZFileDownloadTaskDelegate>)delegate {
    
    if(self = [super init]){
        self.taskId = taskId;
        self.fileUrl = fileUrl;
        self.saveName = saveName;
        self.savePath = savePath;
        if(delegate){
            [self.delegates addObject:delegate];
        }
    }
    return self;
}

- (void)main{
    @autoreleasepool {
        if (self.isCancelled) {
            // 任务被取消，退出执行
            return;
        }
        [self startDonwloadTask];
    }
}

- (void)startDonwloadTask {
    self.status = FileDownloadTaskStatus_Download;

    __block NSString * taskId = self.taskId;
    
    self.semaphore = dispatch_semaphore_create(0);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.fileUrl]];

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.connectionProxyDictionary = @{}; // 关闭系统代理
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://www.baidu.com"] sessionConfiguration:config];
    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];

    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 60;
    @try {
        [ZHostTool confighttpSessionManagerCerAndP12Cer:manager isIPAddress:[ZHostTool.uploadfileHost checkUrlIsIPAddress]];
        AFSecurityPolicy *currentPolicy = manager.securityPolicy;
        if (!currentPolicy.allowInvalidCertificates) {
            AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
            policy.allowInvalidCertificates = YES; // 允许无效证书（包括自签名证书）
            policy.validatesDomainName = NO;       // 不校验证书中的域名
            [manager setSecurityPolicy:policy];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }

    /// Header
    [manager.requestSerializer setValue:@"IOS" forHTTPHeaderField:@"deviceType"];
    NSString *deviceID = [FCUUID uuidForDevice];
    [manager.requestSerializer setValue:deviceID forHTTPHeaderField:@"deviceUuid"];//deviceUuid多租户
    [manager.requestSerializer setValue:Z_OrgName forHTTPHeaderField:@"orgName"];//租户信息
    [manager.requestSerializer setValue:@"1.0.0" forHTTPHeaderField:@"version"];//版本号
    [manager.requestSerializer setValue:UserManager.userInfo.userUID forHTTPHeaderField:@"token"];  //UID
    
    
    __block NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NoaFileDownloadTask *downloadTask = [[NoaFileDownloadManager sharedInstance] getTaskWithId:taskId];
            float progress =  1.0 * downloadProgress.completedUnitCount/downloadProgress.totalUnitCount;
            downloadTask.progress = progress;
        });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NoaFileDownloadTask *downloadTask = [[NoaFileDownloadManager sharedInstance] getTaskWithId:taskId];
        return [NSURL fileURLWithPath:downloadTask.savePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NoaFileDownloadTask * downloadTask = [[NoaFileDownloadManager sharedInstance] getTaskWithId:taskId];
        
        if (error == nil) {
            downloadTask.status = FileDownloadTaskStatus_Completed;
            NSData *resultData = [NSData dataWithContentsOfFile:downloadTask.savePath];
//            NSData * encryptfileData = [[ZEncryptManager shareEncryManager] decrypt:resultData];
            NSData * encryptfileData = [[EncryptManager shareEncryManager] decrypt:resultData];
            [encryptfileData writeToFile:downloadTask.savePath options:0 error:&error];
            if (!error) { }
        } else {
            [downloadTask setStatus:FileDownloadTaskStatus_Failed error:error];
        }
        if (downloadTask) {
            dispatch_semaphore_signal(downloadTask.semaphore);
        }
    }];
    [task resume];
    
    //等待下载任务进入回调
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
}

-(void)setStatus:(FileDownloadTaskStatus)status error:(NSError *)error {
    _status = status;
    for (id<ZFileDownloadTaskDelegate> delegate in self.delegates) {
        if(delegate && [delegate respondsToSelector:@selector(fileDownloadTask:didChangTaskStatus:error:)] ){
            [delegate fileDownloadTask:self didChangTaskStatus:status error:error];
        }
    }
}

-(void)setStatus:(FileDownloadTaskStatus)status {
    _status = status;
    for (id<ZFileDownloadTaskDelegate> delegate in self.delegates) {
        if(delegate && [delegate respondsToSelector:@selector(fileDownloadTask:didChangTaskStatus:error:)] ){
            [delegate fileDownloadTask:self didChangTaskStatus:status error:nil];
        }
    }
}

-(void)setProgress:(CGFloat)progress{
    _progress = progress;
    for (id<ZFileDownloadTaskDelegate> delegate in self.delegates) {
        if(delegate && [delegate respondsToSelector:@selector(fileDownloadTask:didChangTaskProgress:)] ){
            [delegate fileDownloadTask:self didChangTaskProgress:progress];
        }
    }
}

-(void)addDelegate:(id<ZFileDownloadTaskDelegate>)delegate{
    if(![self.delegates containsObject:delegate]){
        [self.delegates addObject:delegate];
    }
}
- (void)removeDelegate:(id<ZFileDownloadTaskDelegate>)delegate{
    if([self.delegates containsObject:delegate]){
        [self.delegates removeObject:delegate];
    }
}

-(NSHashTable<id<ZFileDownloadTaskDelegate>> *)delegates{
    if (_delegates == nil) {
        _delegates = [NSHashTable weakObjectsHashTable];
    }
    return _delegates;
}

- (BOOL)isEqual:(id)object{
    if(object == nil){
        return NO;
    }
    if(![object isKindOfClass:[self class]]){
        return NO;
    }
    return [self.taskId isEqualToString:((NoaFileDownloadTask *)object).taskId];
}

-(void)dealloc{
    NSLog(@"任务销毁");
}

@end
