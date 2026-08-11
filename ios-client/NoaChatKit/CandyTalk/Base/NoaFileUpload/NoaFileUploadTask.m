//
//  NoaFileUploadTask.m
//  MUIKit
//
//  Created by Candy on 2023/12/15.
//

#import "NoaFileUploadTask.h"
#import "NoaFileUploadManager.h"
#import "NoaFileUploadModel.h"
#import "LXChatEncrypt.h"
//阿里云OSS
#import <AliyunOSSiOS/OSSService.h>
//亚马逊云aws s3
#import <AWSS3/AWSS3.h>
//腾讯云
#import <QCloudCOSXML/QCloudCOSXML.h>
//华为云
#import <OBS/OBS.h>

static int slicing_offset = 1024 * 1024 * 50; // 每片的大小是50Mb(minio)
static int huaweiyun_obs_slicing_offset = 1024 * 1024 * 50; // 每片的大小是10MB(华为云OBS)

@interface NoaFileUploadTask ()

@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic , strong) OSSClient *client;//aliyun上传对象
@property (nonatomic, assign) NSInteger truncks;//分片数组

@end


@implementation NoaFileUploadTask


- (instancetype)initWithTaskId:(NSString *)taskId
                      filePath:(NSString *)filePath
                originFilePath:(NSString *)originFilePath
                      fileName:(NSString *)fileName
                      fileType:(NSString *)fileType
                     isEncrypt:(BOOL)isEncrypt
                    dataLength:(NSUInteger)dataLength
                    uploadType:(ZHttpUploadType)uploadType
                 beSendMessage:(NoaIMChatMessageModel *)beSendMessage
                      delegate:(id<ZFileUploadTaskDelegate>)delegate {
    if(self = [super init]){
        self.taskId = taskId;
        self.filePath = filePath;
        // filename上传的时候拼接后会有1,但是存储的没有，所以要删掉
        if ([filePath hasSuffix:@".ipa1"] || [filePath hasSuffix:@".apk1"]) {
            self.filePath = [filePath substringToIndex:filePath.length - 1];
        }
        // 上传的时候名字要加1
        if ([fileName hasSuffix:@".ipa"] || [fileName hasSuffix:@".apk"]) {
            self.fileName = [fileName stringByAppendingString:@"1"];
        } else {
            self.fileName = fileName;
        }
        self.fileType = fileType;
        self.isEncrypt = isEncrypt;
        self.dataLength = dataLength;
        self.uploadType = uploadType;
        self.beSendMessage = beSendMessage;
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
        [self getUploadPublicKey];
    }
}

- (NSString *)getUrlSignature:(long long)timestamp url:(NSString *)url {
    //接口名
    NSString *uri = @"";
    NSString *method = @"";
    if ([url hasPrefix:@"http"]) {
        url = [url stringByReplacingOccurrencesOfString:ZHostTool.uploadfileHost withString:@""];
    }
    uri = [url stringByReplacingOccurrencesOfString:@"/biz/" withString:@""];
    uri = [uri stringByReplacingOccurrencesOfString:@"/auth/" withString:@""];
    uri = [uri stringByReplacingOccurrencesOfString:@"/zim-file/" withString:@""];
    uri = [uri stringByReplacingOccurrencesOfString:@"/file/" withString:@""];
    method = ZHostTool.appSysSetModel.tenantCode;
    
    NSString *signature = [LXChatEncrypt method5:method uri:uri timestamp:timestamp];
    return signature;
}

- (void)getUploadPublicKey {
    if (self.uploadModelType == FileUploadModelTypeThirdOss) {
        if ([ZHostTool.appSysSetModel.oss_config_type isEqualToString:@"1"] ) {
            //阿里云上传
            self.uploadModelType = FileUploadModelTypeAliyun;
            [self startUploadAliyunFile];
        }
        if ([ZHostTool.appSysSetModel.oss_config_type isEqualToString:@"2"]) {
            //亚马逊云上传
            self.uploadModelType = FileUploadModelTypeAWS;
            [self startUploadAWSFile];
        }
        if ([ZHostTool.appSysSetModel.oss_config_type isEqualToString:@"3"]) {
            //腾讯云上传
            self.uploadModelType = FileUploadModelTypeTencent;
            [self startUploadTencentFile];
        }
        if ([ZHostTool.appSysSetModel.oss_config_type isEqualToString:@"4"]) {
            //华为云上传
            self.uploadModelType = FileUploadModelTypeOBS;
            [self startUploadHuaWeiOBSFile];
        }
    } else {
        self.semaphore = dispatch_semaphore_create(0);
        
        NSString *urlStr = [NSString stringWithFormat:@"%@%@", ZHostTool.uploadfileHost, ZIM_UPLOAD_PUBLIC_KEY_URL];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.connectionProxyDictionary = @{}; // 关闭系统代理
        
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:ZHostTool.uploadfileHost]
                                                                 sessionConfiguration:config];
        
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.requestSerializer.timeoutInterval = 60;
        @try {
            [ZHostTool confighttpSessionManagerCerAndP12Cer:manager isIPAddress:[ZHostTool.uploadfileHost checkUrlIsIPAddress]];
            
            // 如果confighttpSessionManagerCerAndP12Cer没有设置允许无效证书，重新设置
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
        /** 接口验签 */
        long long timeStamp = [NSDate getCurrentTimeIntervalWithSecond];
        //timestamp
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%lld", timeStamp] forHTTPHeaderField:@"timestamp"];
        //signature
        NSString *signature = [self getUrlSignature:timeStamp url:ZIM_UPLOAD_PUBLIC_KEY_URL];
        [manager.requestSerializer setValue:signature forHTTPHeaderField:@"signature"];
        
        __block NSString * taskId = self.taskId;
        
        WeakSelf
        __block NSURLSessionDataTask *publicKeyTask = [manager dataTaskWithHTTPMethod:@"POST" URLString:urlStr parameters:nil headers:nil uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
            
        } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            StrongSelf
            NoaFileUploadTask * uploadTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:taskId];
            
            NoaHttpResponse *resp = [NoaHttpResponse mj_objectWithKeyValues:responseObject];
            if (resp.isHttpSuccess) {
                id descryptData = [resp responseDataDescryptWithDataString:resp.data url:urlStr];
                NSString *publicKeyStr = (NSString *)descryptData;
                if (uploadTask.uploadModelType == FileUploadModelTypeMinioSingle) {
                    //minio单个文件上传
                    [strongSelf startUploadSingleFileWithPublicKey:publicKeyStr];
                } else if (uploadTask.uploadModelType == FileUploadModelTypeMinioFragment) {
                    //minio分片上传
                    [strongSelf uploadFragmentGetUploadIdWithPublicKey:publicKeyStr];
                } else {
                    return;
                }
            } else {
                [HUD showMessage:LanguageToolMatch(@"获取私钥失败")];
                [uploadTask setStatus:FileUploadTaskStatus_Failed error:nil];
                if(uploadTask){
                    dispatch_semaphore_signal(uploadTask.semaphore);
                }
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //            [HUD showMessage:LanguageToolMatch(@"网络异常~")];
            
            NoaFileUploadTask * uploadTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:taskId];
            [uploadTask setStatus:FileUploadTaskStatus_Failed error:nil];
            if (uploadTask) {
                dispatch_semaphore_signal(uploadTask.semaphore);
            }
        }];
        [publicKeyTask resume];
        
        //等待下载任务进入回调
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    }
}

#pragma mark - 单个文件上传
- (void)startUploadSingleFileWithPublicKey:(NSString *)publicKey {
    if(self.session && self.status == FileUploadTaskStatus_Paused){
        //如果是暂停状态
        self.status = FileUploadTaskStatus_Upload;
        [self.session resume];
        NSLog(@"任务继续");
        //等待任务进入回调
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    }else{
        self.status = FileUploadTaskStatus_Upload;
        
        __block NSString * taskId = self.taskId;
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.connectionProxyDictionary = @{}; // 关闭系统代理
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:ZHostTool.uploadfileHost]
                                                                 sessionConfiguration:config];
        
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.requestSerializer.timeoutInterval = 60;
        @try {
            [ZHostTool confighttpSessionManagerCerAndP12Cer:manager isIPAddress:[ZHostTool.uploadfileHost checkUrlIsIPAddress]];
            
            // 如果confighttpSessionManagerCerAndP12Cer没有设置允许无效证书，重新设置
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
        
        NSString *bucketName = [NoaFileUploadTools getMinioBucketNameFormUploadType:self.uploadType];
        NSString *mimeType = [NoaFileUploadTools getMimeTypeFormUploadType:self.uploadType withFilePath:self.filePath];
        NSString *urlStr = [NSString stringWithFormat:@"%@%@?bucketName=%@", ZHostTool.uploadfileHost, ZIM_UPLOAD_FILE_URL, bucketName];
        
        /** 上传文件时，header里增加：
         osToken: 加密 公钥和osFileName 后的信息(AES加密) 公钥+osFileName 与登录加密保持一致
         osFileName：文件名字
         */
        NSString *osTokenStr = [NSString stringWithFormat:@"%@%@", publicKey, self.fileName];
        NSString *osToken = [LXChatEncrypt method4:osTokenStr];
        [manager.requestSerializer setValue:osToken forHTTPHeaderField:@"osToken"];
        [manager.requestSerializer setValue:self.fileName forHTTPHeaderField:@"osFileName"];
        /** 接口验签 */
        long long timeStamp = [NSDate getCurrentTimeIntervalWithSecond];
        //timestamp
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%lld", timeStamp] forHTTPHeaderField:@"timestamp"];
        //signature
        NSString *signature = [self getUrlSignature:timeStamp url:ZIM_UPLOAD_FILE_URL];
        [manager.requestSerializer setValue:signature forHTTPHeaderField:@"signature"];
        
        self.session =  [manager POST:urlStr parameters:nil headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            NoaFileUploadTask *uploadTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:taskId];
            NSData *encryFileData = [uploadTask imageDataEncry];
            [formData appendPartWithFileData:encryFileData name:@"file" fileName:uploadTask.fileName mimeType:mimeType];
            
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NoaFileUploadTask *uploadTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:taskId];
                float progress =  1.0 * uploadProgress.completedUnitCount/uploadProgress.totalUnitCount;
                uploadTask.progress = progress;
            });
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NoaFileUploadTask * uploadTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:taskId];
            NoaHttpResponse *resp = [NoaHttpResponse mj_objectWithKeyValues:responseObject];
            if (resp.isHttpSuccess) {
                id descryptData = [resp responseDataDescryptWithDataString:resp.data url:urlStr];
                NoaFileUploadModel *fileUploadModel = [NoaFileUploadModel mj_objectWithKeyValues:descryptData];
                uploadTask.thumbUrl = fileUploadModel.thumbnailUri;
                uploadTask.originUrl = fileUploadModel.uri;
                uploadTask.status = FileUploadTaskStatus_Completed;
            } else {
                if (uploadTask.status != FileUploadTaskStatus_Paused) {
                    [uploadTask setStatus:FileUploadTaskStatus_Failed error:nil];
                }
            }
            if (uploadTask) {
                dispatch_semaphore_signal(uploadTask.semaphore);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //            [HUD showMessage:LanguageToolMatch(@"网络异常~")];
            NoaFileUploadTask * uploadTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:taskId];
            if (uploadTask.status != FileUploadTaskStatus_Paused){
                [uploadTask setStatus:FileUploadTaskStatus_Failed error:error];
            }
            //上传错误日志上报
            NSMutableDictionary *loganDict = [NSMutableDictionary dictionary];
            [loganDict setValue:error.description forKey:@"failReason"];//失败原因
            //写入日志
            [IMSDKManager imSdkWriteLoganWith:LingIMLoganTypeApi loganContent:[[NoaIMLoganManager sharedManager] configLoganContent:loganDict]];
            [self sentryCaptureWithDictionary:loganDict];
            
            // 转换为 JSON 字符串
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:loganDict
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:&error];
            if (jsonData) {
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
            }
            
            if (uploadTask){
                dispatch_semaphore_signal(uploadTask.semaphore);
            }
        }];
        [self.session resume];
    }
}

#pragma mark - 大文件分片上传
//1、通过publicKey获取uploadId
- (void)uploadFragmentGetUploadIdWithPublicKey:(NSString *)publicKey {
    //taskId
    __block NSString * taskId = self.taskId;
    //桶名称
    NSString *bucketName = [NoaFileUploadTools getMinioBucketNameFormUploadType:self.uploadType];
    //url
    NSString *urlStr = [NSString stringWithFormat:@"%@%@?bucketName=%@&fileUri=%@", ZHostTool.uploadfileHost, ZIM_SLICING_UPLOAD_STEP_ONE_URL, bucketName, self.fileName];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.connectionProxyDictionary = @{}; // 关闭系统代理
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:ZHostTool.uploadfileHost]
                                                             sessionConfiguration:config];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 60;
    @try {
        [ZHostTool confighttpSessionManagerCerAndP12Cer:manager isIPAddress:[ZHostTool.uploadfileHost checkUrlIsIPAddress]];
        
        // 如果confighttpSessionManagerCerAndP12Cer没有设置允许无效证书，重新设置
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
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    /** 接口验签 */
    long long timeStamp = [NSDate getCurrentTimeIntervalWithSecond];
    //timestamp
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%lld", timeStamp] forHTTPHeaderField:@"timestamp"];
    //signature
    NSString *signature = [self getUrlSignature:timeStamp url:ZIM_SLICING_UPLOAD_STEP_ONE_URL];
    [manager.requestSerializer setValue:signature forHTTPHeaderField:@"signature"];
    
    /** 上传文件时，header里增加：
     osToken: 加密 公钥和osFileName 后的信息(AES加密) 公钥+osFileName 与登录加密保持一致
     osFileName：文件名字
     */
    NSString *osTokenStr =  [NSString stringWithFormat:@"%@%@", publicKey, self.fileName];
    NSString *osToken = [LXChatEncrypt method4:osTokenStr];
    [manager.requestSerializer setValue:osToken forHTTPHeaderField:@"osToken"];
    [manager.requestSerializer setValue:self.fileName forHTTPHeaderField:@"osFileName"];
    
    WeakSelf
    __block NSURLSessionDataTask *uploadIdTask = [manager dataTaskWithHTTPMethod:@"POST" URLString:urlStr parameters:nil headers:nil uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        StrongSelf
        NoaFileUploadTask * uploadTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:taskId];
        
        NoaHttpResponse *resp = [NoaHttpResponse mj_objectWithKeyValues:responseObject];
        if (resp.isHttpSuccess) {
            id descryptData = [resp responseDataDescryptWithDataString:resp.data url:urlStr];
            NSString *uploadId = (NSString *)descryptData;
            [strongSelf uploadAllFragmentFileWithPublicKey:publicKey uploadId:uploadId];
        } else {
            [HUD showMessage:LanguageToolMatch(@"获取UploadId失败")];
            [uploadTask setStatus:FileUploadTaskStatus_Failed error:nil];
            if (uploadTask) {
                dispatch_semaphore_signal(uploadTask.semaphore);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //            [HUD showMessage:LanguageToolMatch(@"网络异常~")];
        NoaFileUploadTask * uploadTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:taskId];
        [uploadTask setStatus:FileUploadTaskStatus_Failed error:nil];
        if(uploadTask) {
            dispatch_semaphore_signal(uploadTask.semaphore);
        }
    }];
    [uploadIdTask resume];
}

//2、对大文件分片，上传每一个分片
- (void)uploadAllFragmentFileWithPublicKey:(NSString *)publicKey uploadId:(NSString *)uploadId {
    if(self.session && self.status == FileUploadTaskStatus_Paused){
        //如果是暂停状态
        self.status = FileUploadTaskStatus_Upload;
        [self.session resume];
        NSLog(@"任务继续");
        //等待任务进入回调
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    } else{
        self.status = FileUploadTaskStatus_Upload;
        //taskId
        __block NSString * taskId = self.taskId;
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.connectionProxyDictionary = @{}; // 关闭系统代理
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:ZHostTool.uploadfileHost]
                                                                 sessionConfiguration:config];
        
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.requestSerializer.timeoutInterval = 60;
        @try {
            [ZHostTool confighttpSessionManagerCerAndP12Cer:manager isIPAddress:[ZHostTool.uploadfileHost checkUrlIsIPAddress]];
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
        /** 接口验签 */
        long long timeStamp = [NSDate getCurrentTimeIntervalWithSecond];
        //timestamp
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%lld", timeStamp] forHTTPHeaderField:@"timestamp"];
        //signature
        NSString *signature = [self getUrlSignature:timeStamp url:ZIM_SLICING_UPLOAD_STEP_TWO_URL];
        [manager.requestSerializer setValue:signature forHTTPHeaderField:@"signature"];
        
        /** 上传文件时，header里增加：
         osToken: 加密 公钥和osFileName 后的信息(AES加密) 公钥+osFileName 与登录加密保持一致
         osFileName：文件名字
         */
        NSString *osTokenStr =  [NSString stringWithFormat:@"%@%@", publicKey, self.fileName];
        NSString *osToken = [LXChatEncrypt method4:osTokenStr];
        [manager.requestSerializer setValue:osToken forHTTPHeaderField:@"osToken"];
        [manager.requestSerializer setValue:self.fileName forHTTPHeaderField:@"osFileName"];
        
        //桶名称 & mimeType
        NSString *bucketName = [NoaFileUploadTools getMinioBucketNameFormUploadType:self.uploadType];
        NSString *mimeType = [NoaFileUploadTools getMimeTypeFormUploadType:self.uploadType withFilePath:self.filePath];
        
        //文件分片总数
        NSData *encryFileData = [self imageDataEncry];
        self.truncks = encryFileData.length % slicing_offset == 0 ? encryFileData.length/slicing_offset : encryFileData.length/slicing_offset + 1;
        
        WeakSelf
        __block long long totalSentedByte = 0; //当前已经上传的数据量(累加)
        __block NSInteger httpFinishCount = 0;
        __block NSMutableArray *eTagList = [NSMutableArray array];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            StrongSelf
            for (int i = 1; i <= self.truncks; i++) {
                //DLog(@"======== 分片上传 总共 %ld 片", (long)self.truncks);
                //DLog(@"======== 分片上传 第二步 第 %d 片 开始上传", i);
                NSString *urlStr = [NSString stringWithFormat:@"%@%@?bucketName=%@&key=%@&partNumber=%d&uploadId=%@", ZHostTool.uploadfileHost, ZIM_SLICING_UPLOAD_STEP_TWO_URL, bucketName, strongSelf.fileName, i, uploadId];
                
                NSFileHandle *readHandler = [NSFileHandle fileHandleForReadingAtPath:strongSelf.filePath];
                [readHandler seekToFileOffset:slicing_offset * (i-1)];
                NSData *currentData = [readHandler readDataOfLength:slicing_offset];
                
                __block NSURLSessionDataTask *task =  [manager POST:urlStr parameters:nil headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                    NoaFileUploadTask *uploadTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:taskId];
                    [formData appendPartWithFileData:currentData name:@"file" fileName:uploadTask.fileName mimeType:mimeType];
                    
                } progress:^(NSProgress * _Nonnull uploadProgress) {
                    
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    StrongSelf
                    NoaFileUploadTask *uploadTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:taskId];
                    
                    NoaHttpResponse *resp = [NoaHttpResponse mj_objectWithKeyValues:responseObject];
                    if (resp.isHttpSuccess) {
                        totalSentedByte += currentData.length;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            float progress =  1.0 * totalSentedByte/uploadTask.dataLength;
                            uploadTask.progress = progress;
                        });
                        id descryptData = [resp responseDataDescryptWithDataString:resp.data url:urlStr];
                        NSDictionary *resultDic = (NSDictionary *)descryptData;
                        NSMutableDictionary *eTagDic = [[NSMutableDictionary alloc] init];
                        [eTagDic setObjectSafe:[resultDic objectForKeySafe:@"partNumber"] forKey:@"partNumber"];
                        [eTagDic setObjectSafe:[resultDic objectForKeySafe:@"etag"] forKey:@"tag"];
                        [eTagList addObject:eTagDic];
                        
                        //DLog(@"======== 分片上传 第二步 第 %ld 片 上传成功", (long)httpFinishCount + 1);
                        if (++httpFinishCount == self.truncks) {
                            [strongSelf uploadFragmentMergeFileWithPublicKey:publicKey uploadId:uploadId TagList:eTagList bucketName:bucketName key:uploadTask.fileName];
                        }
                    } else {
                        if (uploadTask.status != FileUploadTaskStatus_Paused) {
                            [uploadTask setStatus:FileUploadTaskStatus_Failed error:nil];
                        }
                        if (uploadTask){
                            dispatch_semaphore_signal(uploadTask.semaphore);
                        }
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    //                        [HUD showMessage:LanguageToolMatch(@"网络异常~")];
                    NoaFileUploadTask * uploadTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:taskId];
                    if (uploadTask.status != FileUploadTaskStatus_Paused){
                        [uploadTask setStatus:FileUploadTaskStatus_Failed error:error];
                    }
                    if (uploadTask){
                        dispatch_semaphore_signal(uploadTask.semaphore);
                    }
                }];
                [task resume];
            }
        });
    }
}

//3、分片上传完成后，将分片合成一个完整文件
- (void)uploadFragmentMergeFileWithPublicKey:(NSString *)publicKey uploadId:(NSString *)uploadId TagList:(NSArray *)eTagList bucketName:(NSString *)bucketName key:(NSString *)key {
    
    __block NSString * taskId = self.taskId;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", ZHostTool.uploadfileHost, ZIM_SLICING_UPLOAD_STEP_THREE_URL];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.connectionProxyDictionary = @{}; // 关闭系统代理
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:ZHostTool.uploadfileHost]
                                                             sessionConfiguration:config];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 60;
    @try {
        [ZHostTool confighttpSessionManagerCerAndP12Cer:manager isIPAddress:[ZHostTool.uploadfileHost checkUrlIsIPAddress]];
        
        // 如果confighttpSessionManagerCerAndP12Cer没有设置允许无效证书，重新设置
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
    /** 接口验签 */
    long long timeStamp = [NSDate getCurrentTimeIntervalWithSecond];
    //timestamp
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%lld", timeStamp] forHTTPHeaderField:@"timestamp"];
    //signature
    NSString *signature = [self getUrlSignature:timeStamp url:ZIM_SLICING_UPLOAD_STEP_THREE_URL];
    [manager.requestSerializer setValue:signature forHTTPHeaderField:@"signature"];
    /** 上传文件时，header里增加：
     osToken: 加密 公钥和osFileName 后的信息(AES加密) 公钥+osFileName 与登录加密保持一致
     osFileName：文件名字
     */
    NSString *osTokenStr =  [NSString stringWithFormat:@"%@%@", publicKey, key];
    NSString *osToken = [LXChatEncrypt method4:osTokenStr];
    [manager.requestSerializer setValue:osToken forHTTPHeaderField:@"osToken"];
    [manager.requestSerializer setValue:key forHTTPHeaderField:@"osFileName"];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   bucketName,@"bucketName",
                                   eTagList,@"eTagList",
                                   key,@"fileUri",
                                   uploadId,@"uploadId",nil];
    
    __block long long totalSentedByte = self.dataLength * 0.99; //当前已经上传的数据量(累加)
    
    __block NSURLSessionDataTask *task =  [manager dataTaskWithHTTPMethod:@"POST" URLString:urlStr parameters:params headers:nil uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NoaFileUploadTask *uploadTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:taskId];
        
        NoaHttpResponse *resp = [NoaHttpResponse mj_objectWithKeyValues:responseObject];
        if (resp.isHttpSuccess) {
            totalSentedByte = uploadTask.dataLength * 1.0;
            dispatch_async(dispatch_get_main_queue(), ^{
                float progress =  1.0 * totalSentedByte/uploadTask.dataLength;
                uploadTask.progress = progress;
            });
            id descryptData = [resp responseDataDescryptWithDataString:resp.data url:urlStr];
            NoaFileUploadModel *fileUploadModel = [NoaFileUploadModel mj_objectWithKeyValues:descryptData];
            uploadTask.thumbUrl = fileUploadModel.thumbnailUri;
            uploadTask.originUrl = fileUploadModel.uri;
            uploadTask.status = FileUploadTaskStatus_Completed;
        } else {
            if (uploadTask.status != FileUploadTaskStatus_Paused) {
                [uploadTask setStatus:FileUploadTaskStatus_Failed error:nil];
            }
        }
        if (uploadTask){
            dispatch_semaphore_signal(uploadTask.semaphore);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //            [HUD showMessage:LanguageToolMatch(@"网络异常~")];
        NoaFileUploadTask * uploadTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:taskId];
        if (uploadTask.status != FileUploadTaskStatus_Paused){
            [uploadTask setStatus:FileUploadTaskStatus_Failed error:error];
        }
        
        //上传错误日志上报
        NSMutableDictionary *loganDict = [NSMutableDictionary dictionary];
        [loganDict setValue:error.description forKey:@"failReason"];//失败原因
        //写入日志
        [IMSDKManager imSdkWriteLoganWith:LingIMLoganTypeApi loganContent:[[NoaIMLoganManager sharedManager] configLoganContent:loganDict]];
        [self sentryCaptureWithDictionary:loganDict];
        
        if (uploadTask){
            dispatch_semaphore_signal(uploadTask.semaphore);
        }
    }];
    [task resume];
}

#pragma mark - 阿里云上传
- (void)startUploadAliyunFile {
    
    self.semaphore = dispatch_semaphore_create(0);
    
    self.status = FileUploadTaskStatus_Upload;
    __block NSString * taskId = self.taskId;
    
    //拼接file的Url时需要用到endPointUrl(去掉 http:// 和 https:// )
    NSString *endPointUrl = [ZHostTool.appSysSetModel.oss_config_end_point stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    endPointUrl = [endPointUrl stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    
    //文件存储路径+文件名
    NSString *objectKey = [NSString stringWithFormat:@"%@%@", [NoaFileUploadTools getAliyunObjectKeyPathFormUploadType:self.uploadType], self.fileName];
    //上传单个文件
    //每次都要重新创建client，防止token失效后，client里存的还是已失效的token
    id<OSSCredentialProvider> credentialProvider = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:[NoaFileUploadManager sharedInstance].stsInfo.aliyunAccessKeyId secretKeyId:[NoaFileUploadManager sharedInstance].stsInfo.aliyunSecretKeyId securityToken:[NoaFileUploadManager sharedInstance].stsInfo.aliyunSecurityToken];
    if (self.client == nil) {
        if ([NSString isNil:ZHostTool.appSysSetModel.oss_config_end_point]) {
            [HUD showMessage:LanguageToolMatch(@"操作失败")];
            NoaFileUploadTask * uploadTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:taskId];
            if (uploadTask.status != FileUploadTaskStatus_Paused) {
                [uploadTask setStatus:FileUploadTaskStatus_Failed error:nil];
            }
            dispatch_semaphore_signal(uploadTask.semaphore);
            //上传错误日志上报
            NSMutableDictionary *loganDict = [NSMutableDictionary dictionary];
            [loganDict setValue:@"oss_config_end_point为空" forKey:@"failReason"];//失败原因
            //写入日志
            [IMSDKManager imSdkWriteLoganWith:LingIMLoganTypeApi loganContent:[[NoaIMLoganManager sharedManager] configLoganContent:loganDict]];
            [self sentryCaptureWithDictionary:loganDict];
            
            return;
        }
        self.client = [[OSSClient alloc] initWithEndpoint:ZHostTool.appSysSetModel.oss_config_end_point credentialProvider:credentialProvider];
    } else {
        self.client.credentialProvider = credentialProvider;
    }
    
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    // 填写Bucket名称，例如examplebucket。
    put.bucketName = ZHostTool.appSysSetModel.oss_config_bucket_name;
    // 填写Object完整路径。Object完整路径中不能包含Bucket名称，例如exampledir/testdir/exampleobject.txt。
    put.objectKey = objectKey;
    // 直接上传NSData格式的文件数据
    NSData *encryFileData = [self imageDataEncry];
    put.uploadingData = encryFileData;
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NoaFileUploadTask *uploadTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:taskId];
            float progress =  1.0 * totalByteSent/totalBytesExpectedToSend;
            uploadTask.progress = progress;
        });
    };
    OSSTask * putTask = [self.client putObject:put];
    [putTask continueWithBlock:^id(OSSTask *task) {
        
        NoaFileUploadTask * uploadTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:taskId];
        
        if (!task.error) {
            NSLog(@"OSS上传成功");
            //原图url
            NSString *fileUrl = [NSString stringWithFormat:@"https://%@.%@/%@", ZHostTool.appSysSetModel.oss_config_bucket_name, endPointUrl, objectKey];
            //缩略图url
            NSString *thumbnailUrl = [NSString stringWithFormat:@"https://%@.%@/%@?x-oss-process=image/resize,h_200,m_lfit", ZHostTool.appSysSetModel.oss_config_bucket_name, endPointUrl, objectKey];
            uploadTask.thumbUrl = thumbnailUrl;
            uploadTask.originUrl = fileUrl;
            uploadTask.status = FileUploadTaskStatus_Completed;
        } else {
            NSLog(@"OSS上传失败, error: %@" , task.error);
            if (uploadTask.status != FileUploadTaskStatus_Paused) {
                [uploadTask setStatus:FileUploadTaskStatus_Failed error:nil];
            }
            
            //上传错误日志上报
            NSMutableDictionary *loganDict = [NSMutableDictionary dictionary];
            [loganDict setValue:task.error.description forKey:@"failReason"];//失败原因
            //写入日志
            [IMSDKManager imSdkWriteLoganWith:LingIMLoganTypeApi loganContent:[[NoaIMLoganManager sharedManager] configLoganContent:loganDict]];
            [self sentryCaptureWithDictionary:loganDict];
            
        }
        
        if(uploadTask){
            dispatch_semaphore_signal(uploadTask.semaphore);
        }
        
        return nil;
    }];
    
    //等待任务进入回调
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
}

#pragma mark - 亚马逊云上传
- (void)startUploadAWSFile {
    
    self.semaphore = dispatch_semaphore_create(0);
    
    self.status = FileUploadTaskStatus_Upload;
    __block NSString * taskId = self.taskId;
    
    //拼接file的Url时需要用到endPointUrl(去掉 http:// 和 https:// )
    NSString *endPointUrl = [ZHostTool.appSysSetModel.oss_config_end_point stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    endPointUrl = [endPointUrl stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    //objectKey
    NSString *objectKey = [NSString stringWithFormat:@"%@%@", [NoaFileUploadTools getAWSS3ObjectKeyPathFormUploadType:self.uploadType], self.fileName];
    
    //临时性的accessKey、secretKey，需要增加一个参数sessionToken
    AWSBasicSessionCredentialsProvider *credentialsProvider = [[AWSBasicSessionCredentialsProvider alloc] initWithAccessKey:[NoaFileUploadManager sharedInstance].stsInfo.awss3AccessKey secretKey:[NoaFileUploadManager sharedInstance].stsInfo.awss3SecretKey sessionToken:[NoaFileUploadManager sharedInstance].stsInfo.awss3sessionToken];
    //endPoint
    AWSEndpoint *endPoint = [[AWSEndpoint alloc] initWithURLString:ZHostTool.appSysSetModel.oss_config_end_point];
    //ServiceConfig
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:[ZHostTool.appSysSetModel.oss_config_region_id aws_regionTypeValue] endpoint:endPoint credentialsProvider:credentialsProvider];
    //设置ServiceConfig
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    // 上传进度回调
    AWSS3TransferUtilityUploadExpression * expression = [AWSS3TransferUtilityUploadExpression new];
    expression.progressBlock = ^(AWSS3TransferUtilityTask * _Nonnull task, NSProgress * _Nonnull progress) {
        NSLog(@"上传进度=%f, %lld, %lld", progress.fractionCompleted, progress.completedUnitCount, progress.totalUnitCount);
        dispatch_async(dispatch_get_main_queue(), ^{
            NoaFileUploadTask *uploadTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:taskId];
            float progressNum =  1.0 * progress.completedUnitCount/progress.totalUnitCount;
            uploadTask.progress = progressNum;
        });
    };
    // 上传结果回调
    AWSS3TransferUtilityUploadCompletionHandlerBlock completionHandler = ^(AWSS3TransferUtilityUploadTask *task, NSError *error) {
        NoaFileUploadTask * uploadTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:taskId];
        if (!error) {
            //原图url
            NSString *fileUrl = [NSString stringWithFormat:@"https://%@.%@/%@", ZHostTool.appSysSetModel.oss_config_bucket_name, endPointUrl, objectKey];
            //缩略图url
            NSString *thumbnailUrl = [NSString stringWithFormat:@"https://%@.%@/%@", ZHostTool.appSysSetModel.oss_config_bucket_name, endPointUrl, objectKey];
            uploadTask.thumbUrl = thumbnailUrl;
            uploadTask.originUrl = fileUrl;
            uploadTask.status = FileUploadTaskStatus_Completed;
        } else {
            NSLog(@"AWS S3 上传失败, error: %@" , error);
            if (uploadTask.status != FileUploadTaskStatus_Paused) {
                [uploadTask setStatus:FileUploadTaskStatus_Failed error:nil];
            }
            //上传错误日志上报
            NSMutableDictionary *loganDict = [NSMutableDictionary dictionary];
            [loganDict setValue:error.description forKey:@"failReason"];//失败原因
            //写入日志
            [IMSDKManager imSdkWriteLoganWith:LingIMLoganTypeApi loganContent:[[NoaIMLoganManager sharedManager] configLoganContent:loganDict]];
            [self sentryCaptureWithDictionary:loganDict];
            
        }
        if(uploadTask){
            dispatch_semaphore_signal(uploadTask.semaphore);
        }
    };
    //上传操作
    AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
    NSData *encryFileData = [self imageDataEncry];
    [[transferUtility uploadData:encryFileData
                          bucket:ZHostTool.appSysSetModel.oss_config_bucket_name
                             key:objectKey
                     contentType:@"text/plain"
                      expression:expression
               completionHandler:completionHandler] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"Error: %@", task.error);
        }
        if (task.result) {
            //AWSS3TransferUtilityUploadTask *uploadTask = task.result;
            // Do something with uploadTask.
            NSLog(@"Upload Starting!");
        }
        return nil;
    }];
    
    //等待任务进入回调
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
}

#pragma mark - 腾讯云上传
- (void)startUploadTencentFile {
    self.semaphore = dispatch_semaphore_create(0);
    
    self.status = FileUploadTaskStatus_Upload;
    __block NSString * taskId = self.taskId;
    if ([NoaFileUploadManager sharedInstance].stsInfo.tencentsecretId == nil || [NoaFileUploadManager sharedInstance].stsInfo.tencentsecretKey == nil || [NoaFileUploadManager sharedInstance].stsInfo.tencentToken == nil) {
        NoaFileUploadTask * uploadTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:taskId];
        if (uploadTask.status != FileUploadTaskStatus_Paused) {
            [uploadTask setStatus:FileUploadTaskStatus_Failed error:nil];
        }
        //上传错误日志上报
        NSMutableDictionary *loganDict = [NSMutableDictionary dictionary];
        [loganDict setValue:@"tencent_upload_ststoken为空" forKey:@"failReason"];//失败原因
        //写入日志
        [IMSDKManager imSdkWriteLoganWith:LingIMLoganTypeApi loganContent:[[NoaIMLoganManager sharedManager] configLoganContent:loganDict]];
        [self sentryCaptureWithDictionary:loganDict];
        
        return;
    }
    
    //拼接file的Url时需要用到endPointUrl(去掉 http:// 和 https:// )
    NSString *endPointUrl = [ZHostTool.appSysSetModel.oss_config_end_point stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    endPointUrl = [endPointUrl stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    //objectKey
    NSString *objectKey = [NSString stringWithFormat:@"%@%@", [NoaFileUploadTools getTencentCosObjectKeyPathFormUploadType:self.uploadType], self.fileName];
    
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
    // <BucketName-APPID>.cos.ap-beijing-1.myqcloud.com
    endpoint.regionName = ZHostTool.appSysSetModel.oss_config_region_id;
    if (![NSString isNil:ZHostTool.appSysSetModel.oss_config_end_point]) {
        endpoint.suffix = ZHostTool.appSysSetModel.oss_config_end_point;
    }
    // 使用 HTTPS
    endpoint.useHTTPS = true;
    configuration.endpoint = endpoint;
    
    // 初始化 COS 服务示例
    [QCloudCOSXMLService registerDefaultCOSXMLWithConfiguration:configuration];
    [QCloudCOSTransferMangerService registerDefaultCOSTransferMangerWithConfiguration:configuration];
    
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    QCloudCredential * credential = [QCloudCredential new];
    credential.secretID = [NoaFileUploadManager sharedInstance].stsInfo.tencentsecretId;
    credential.secretKey = [NoaFileUploadManager sharedInstance].stsInfo.tencentsecretKey;
    credential.token = [NoaFileUploadManager sharedInstance].stsInfo.tencentToken;
    // 设置临时密钥
    put.credential = credential;
    // 存储桶名称，由BucketName-Appid 组成，可以在COS控制台查看 https://console.cloud.tencent.com/cos5/bucket
    put.bucket = ZHostTool.appSysSetModel.oss_config_bucket_name;
    // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "video/xxx/movie.mp4"
    put.object = objectKey;
    //需要上传的对象内容。可以传入NSData*或者NSURL*类型的变量
    put.body = [self imageDataEncry];
    //监听上传进度
    [put setSendProcessBlock:^(int64_t bytesSent,
                               int64_t totalBytesSent,
                               int64_t totalBytesExpectedToSend) {
        //bytesSent                 本次要发送的字节数（一个大文件可能要分多次发送）
        //totalBytesSent            已发送的字节数
        //totalBytesExpectedToSend  本次上传要发送的总字节数（即一个文件大小）
        dispatch_async(dispatch_get_main_queue(), ^{
            NoaFileUploadTask *uploadTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:taskId];
            float progressNum =  1.0 * totalBytesSent/totalBytesExpectedToSend;
            uploadTask.progress = progressNum;
        });
    }];
    //监听上传结果
    [put setFinishBlock:^(id outputObject, NSError *error) {
        //可以从 outputObject 中获取 response 中 etag 或者自定义头部等信
        NoaFileUploadTask * uploadTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:taskId];
        if (!error) {
            QCloudUploadObjectResult *result = (QCloudUploadObjectResult *)outputObject;
            if (result != nil && ![NSString isNil:result.location]) {
                uploadTask.originUrl = result.location;
            }
            if (![NSString isNil:uploadTask.originUrl]) {
                uploadTask.status = FileUploadTaskStatus_Completed;
            }
        } else {
            NSLog(@"腾讯云上传失败, error: %@" , error);
            if (uploadTask.status != FileUploadTaskStatus_Paused) {
                [uploadTask setStatus:FileUploadTaskStatus_Failed error:nil];
            }
            //上传错误日志上报
            NSMutableDictionary *loganDict = [NSMutableDictionary dictionary];
            [loganDict setValue:error.description forKey:@"failReason"];//失败原因
            //写入日志
            [IMSDKManager imSdkWriteLoganWith:LingIMLoganTypeApi loganContent:[[NoaIMLoganManager sharedManager] configLoganContent:loganDict]];
            [self sentryCaptureWithDictionary:loganDict];
            
        }
        if(uploadTask){
            dispatch_semaphore_signal(uploadTask.semaphore);
        }
    }];
    [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:put];
    
    //等待任务进入回调
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
}

#pragma mark - 华为云上传
- (void)startUploadHuaWeiOBSFile {
    self.semaphore = dispatch_semaphore_create(0);
    
    self.status = FileUploadTaskStatus_Upload;
    __block NSString * taskId = self.taskId;
    if ([NoaFileUploadManager sharedInstance].stsInfo.obsAccessKey == nil || [NoaFileUploadManager sharedInstance].stsInfo.obsSecretKey == nil) {
        NoaFileUploadTask * uploadTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:taskId];
        if (uploadTask.status != FileUploadTaskStatus_Paused) {
            [uploadTask setStatus:FileUploadTaskStatus_Failed error:nil];
        }
        //上传错误日志上报
        NSMutableDictionary *loganDict = [NSMutableDictionary dictionary];
        [loganDict setValue:@"obs_upload_ststoken为空" forKey:@"failReason"];//失败原因
        //写入日志
        [IMSDKManager imSdkWriteLoganWith:LingIMLoganTypeApi loganContent:[[NoaIMLoganManager sharedManager] configLoganContent:loganDict]];
        [self sentryCaptureWithDictionary:loganDict];
        
        return;
    }
    
    //文件存储路径+文件名
    NSString *objectKey = [NSString stringWithFormat:@"%@%@", [NoaFileUploadTools getHuaWeiOBSObjectKeyPathFormUploadType:self.uploadType], self.fileName];
    
    // 初始化身份验证
    OBSStaticCredentialProvider *credentialProvider = [[OBSStaticCredentialProvider alloc] initWithAccessKey:[NoaFileUploadManager sharedInstance].stsInfo.obsAccessKey secretKey:[NoaFileUploadManager sharedInstance].stsInfo.obsSecretKey];
    credentialProvider.securityToken = [NoaFileUploadManager sharedInstance].stsInfo.obsToken;
    // 初始化服务配置
    OBSServiceConfiguration *conf;
    if (![NSString isNil:ZHostTool.appSysSetModel.oss_obs_custom_domain_put]) {
        conf = [[OBSServiceConfiguration alloc] initWithURLString:ZHostTool.appSysSetModel.oss_obs_custom_domain_put credentialProvider:credentialProvider];
        conf.defaultDomainMode = OBSDomainModeCustom;
    } else {
        conf = [[OBSServiceConfiguration alloc] initWithURLString:ZHostTool.appSysSetModel.oss_obs_end_point credentialProvider:credentialProvider];
        conf.defaultDomainMode = OBSDomainModeNULL0;
    }
    // 初始化client
    conf.uploadSessionConfiguration.timeoutIntervalForRequest = (self.dataLength / huaweiyun_obs_slicing_offset) * 40;
    OBSClient *client = [[OBSClient alloc] initWithConfiguration:conf];
    if (self.dataLength <= (100 * 1024 * 1024)) {
        //单个文件上传
        OBSPutObjectWithDataRequest *request = [[OBSPutObjectWithDataRequest alloc] initWithBucketName:ZHostTool.appSysSetModel.oss_obs_bucket_name objectKey:objectKey uploadData:[self imageDataEncry]];
        
        // 上传进度
        request.uploadProgressBlock = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            //NSLog(@"%0.1f%%",(float)floor(totalBytesSent*10000/totalBytesExpectedToSend)/100);
            dispatch_async(dispatch_get_main_queue(), ^{
                NoaFileUploadTask *uploadTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:taskId];
                float progressNum = 1.0 * totalBytesSent/totalBytesExpectedToSend;
                uploadTask.progress = progressNum;
            });
        };
        // 上传文件
        [client putObject:request completionHandler:^(OBSPutObjectResponse *response, NSError *error){
            NoaFileUploadTask * uploadTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:taskId];
            if (!error) {
                //url
                NSString *fileUrl;
                if (![NSString isNil:ZHostTool.appSysSetModel.oss_obs_custom_domain_get]) {
                    fileUrl = [NSString stringWithFormat:@"%@/%@", ZHostTool.appSysSetModel.oss_obs_custom_domain_get, objectKey];
                } else {
                    NSURL *endPointUrl = [NSURL URLWithString:ZHostTool.appSysSetModel.oss_obs_end_point];
                    NSString *schemeStr = endPointUrl.scheme;
                    NSString *domianStr = endPointUrl.host;
                    fileUrl = [NSString stringWithFormat:@"%@://%@.%@/%@", schemeStr, ZHostTool.appSysSetModel.oss_obs_bucket_name, domianStr, objectKey];
                }
                uploadTask.originUrl = fileUrl;
                uploadTask.status = FileUploadTaskStatus_Completed;
            } else {
                if (uploadTask.status != FileUploadTaskStatus_Paused) {
                    [uploadTask setStatus:FileUploadTaskStatus_Failed error:nil];
                }
                //上传错误日志上报
                NSMutableDictionary *loganDict = [NSMutableDictionary dictionary];
                [loganDict setValue:error.description forKey:@"failReason"];//失败原因
                //写入日志
                [IMSDKManager imSdkWriteLoganWith:LingIMLoganTypeApi loganContent:[[NoaIMLoganManager sharedManager] configLoganContent:loganDict]];
                [self sentryCaptureWithDictionary:loganDict];
                
            }
            if(uploadTask){
                dispatch_semaphore_signal(uploadTask.semaphore);
            }
        }];
    } else {
        // 初始化多段上传任务
        WeakSelf
        OBSInitiateMultipartUploadRequest *request = [[OBSInitiateMultipartUploadRequest alloc]initWithBucketName:ZHostTool.appSysSetModel.oss_obs_bucket_name objectKey:objectKey];
        [client initiateMultipartUpload:request completionHandler:^(OBSInitiateMultipartUploadResponse *response, NSError *error) {
            //开始分段上传
            [weakSelf huaweiOBSMultipartUploadWithUploadId:response.uploadID client:client objectkey:objectKey];
        }];
    }
    //等待任务进入回调
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
}

//华为云分段上传
- (void)huaweiOBSMultipartUploadWithUploadId:(NSString *)uploadId client:(OBSClient *)client objectkey:(NSString *)objectkey {
    //大文件分片上传
    WeakSelf
    NSData *encryData = [self imageDataEncry];
    //文件分片总数
    self.truncks = encryData.length % huaweiyun_obs_slicing_offset == 0 ? encryData.length/huaweiyun_obs_slicing_offset : encryData.length/huaweiyun_obs_slicing_offset + 1;
    
    __block long long totalSentedByte = 0; //当前已经上传的数据量(累加)
    __block NSInteger httpFinishCount = 0;
    __block NSMutableArray *eTagList = [NSMutableArray array];
    NoaFileUploadTask * uploadTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:self.taskId];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 1; i <= self.truncks; i++) {
            //DLog(@"======== 分片上传 总共 %ld 片", (long)self.truncks);
            //DLog(@"======== 分片上传 第二步 第 %d 片 开始上传", i);
            long long currentLength = huaweiyun_obs_slicing_offset;
            if ((encryData.length - huaweiyun_obs_slicing_offset * (i-1)) < huaweiyun_obs_slicing_offset) {
                currentLength = encryData.length - huaweiyun_obs_slicing_offset * (i-1);
            }
            
            NSData *currentUploadData = [encryData subdataWithRange:NSMakeRange(huaweiyun_obs_slicing_offset * (i-1), currentLength)];
            OBSUploadPartWithDataRequest *trunchUpload = [[OBSUploadPartWithDataRequest alloc] initWithBucketName:ZHostTool.appSysSetModel.oss_obs_bucket_name
                                                                                                        objectkey:objectkey
                                                                                                       partNumber:@(i) uploadID:uploadId
                                                                                                       uploadData:currentUploadData];
            trunchUpload.uploadProgressBlock = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
                totalSentedByte += bytesSent;
                dispatch_async(dispatch_get_main_queue(), ^{
                    float progress =  1.0 * totalSentedByte/weakSelf.dataLength;
                    uploadTask.progress = progress;
                });
            };
            [client uploadPart:trunchUpload completionHandler:^(OBSUploadPartResponse *response, NSError *error) {
                StrongSelf
                if (error == nil) {
                    OBSPart *eTagPart = [[OBSPart alloc] initWithPartNumber:@(i) etag:response.etag];
                    [eTagList addObject:eTagPart];
                    
                    //DLog(@"======== 分片上传 第二步 第 %ld 片 上传成功", (long)httpFinishCount + 1);
                    if (++httpFinishCount == strongSelf.truncks) {
                        //合并分段
                        //eTagList排序
                        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"partNumber" ascending:true];
                        NSMutableArray<OBSPart *> *sortedArray = [[eTagList sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
                        
                        [strongSelf huaweiOBSMultipartUploadMerge:uploadId client:client objectkey:objectkey eTagList:sortedArray];
                    }
                } else {
                    if (uploadTask.status != FileUploadTaskStatus_Paused) {
                        [uploadTask setStatus:FileUploadTaskStatus_Failed error:nil];
                    }
                    if(uploadTask){
                        dispatch_semaphore_signal(uploadTask.semaphore);
                    }
                }
            }];
        }
    });
}

//华为云分段上传完成合并分段
- (void)huaweiOBSMultipartUploadMerge:(NSString *)uploadId client:(OBSClient *)client objectkey:(NSString *)objectkey eTagList:(NSMutableArray *)eTagList {
    __block NSString * taskId = self.taskId;
    //合并分段
    OBSCompleteMultipartUploadRequest* comRequest = [[OBSCompleteMultipartUploadRequest alloc] initWithBucketName:ZHostTool.appSysSetModel.oss_obs_bucket_name objectKey:objectkey uploadID:uploadId];
    comRequest.partsList = eTagList;
    [client completeMultipartUpload:comRequest completionHandler:^(OBSCompleteMultipartUploadResponse *response, NSError *error) {
        NoaFileUploadTask * uploadTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:taskId];
        if (!error) {
            //url
            NSString *fileUrl;
            if (![NSString isNil:ZHostTool.appSysSetModel.oss_obs_custom_domain_get]) {
                fileUrl = [NSString stringWithFormat:@"%@/%@", ZHostTool.appSysSetModel.oss_obs_custom_domain_get, objectkey];
            } else {
                NSURL *endPointUrl = [NSURL URLWithString:ZHostTool.appSysSetModel.oss_obs_end_point];
                NSString *schemeStr = endPointUrl.scheme;
                NSString *domianStr = endPointUrl.host;
                fileUrl = [NSString stringWithFormat:@"%@://%@.%@/%@", schemeStr, ZHostTool.appSysSetModel.oss_obs_bucket_name, domianStr, objectkey];
            }
            uploadTask.originUrl = fileUrl;
            uploadTask.status = FileUploadTaskStatus_Completed;
        } else {
            if (uploadTask.status != FileUploadTaskStatus_Paused) {
                [uploadTask setStatus:FileUploadTaskStatus_Failed error:nil];
            }
            //上传错误日志上报
            NSMutableDictionary *loganDict = [NSMutableDictionary dictionary];
            [loganDict setValue:error.description forKey:@"failReason"];//失败原因
            //写入日志
            [IMSDKManager imSdkWriteLoganWith:LingIMLoganTypeApi loganContent:[[NoaIMLoganManager sharedManager] configLoganContent:loganDict]];
            [self sentryCaptureWithDictionary:loganDict];
            
        }
        if(uploadTask){
            dispatch_semaphore_signal(uploadTask.semaphore);
        }
    }];
}

- (void)sentryCaptureWithDictionary:(NSDictionary *)dict {
    [ZTOOL sentryUploadWithDictionary:dict sentryUploadType:ZSentryUploadTypeUpload errorCode:@""];
}


#pragma mark - 图片/视频 加密
- (NSData *)imageDataEncry {
    NSError *err = nil;
    NSData *fileData = [NSData dataWithContentsOfFile:self.filePath];
    if (self.isEncrypt) {
        if (self.uploadType == ZHttpUploadTypeFile) {
            //文件类型
            NSString *fileType = [self.fileType uppercaseString];
            if ([fileType isEqualToString:@"JPEG"]||
                [fileType isEqualToString:@"jpeg"]||
                [fileType isEqualToString:@"PNG"]||
                [fileType isEqualToString:@"png"]||
                [fileType isEqualToString:@"GIF"]||
                [fileType isEqualToString:@"gif"]||
                [fileType isEqualToString:@"JPG"]||
                [fileType isEqualToString:@"jpg"]||
                [fileType isEqualToString:@"JPE"]||
                [fileType isEqualToString:@"jpe"]||
                [fileType isEqualToString:@"MP4"]||
                [fileType isEqualToString:@"mp4"]||
                [fileType isEqualToString:@"MOV"]||
                [fileType isEqualToString:@"mov"]||
                [fileType isEqualToString:@"AVI"]||
                [fileType isEqualToString:@"avi"]||
                [fileType isEqualToString:@"FLV"]||
                [fileType isEqualToString:@"flv"]||
                [fileType isEqualToString:@"RM"]||
                [fileType isEqualToString:@"rm"]||
                [fileType isEqualToString:@"RMVB"]||
                [fileType isEqualToString:@"rmvb"] ||
                [fileType isEqualToString:@"MKV"]||
                [fileType isEqualToString:@"mkv"] ||
                [fileType isEqualToString:@"WMV"]||
                [fileType isEqualToString:@"wmv"]) {
                
                //                    return [[ZEncryptManager shareEncryManager] encryptFileToData:fileData error:&err];
                return [[EncryptManager shareEncryManager] encryptFileToData:fileData];
            }
        }
        if (self.uploadType == ZHttpUploadTypeUserAvatar || self.uploadType == ZHttpUploadTypeGroupAvatar || self.uploadType == ZHttpUploadTypeImage || self.uploadType == ZHttpUploadTypeMiniApp || self.uploadType == ZHttpUploadTypeStickers || self.uploadType == ZHttpUploadTypeUniversal || self.uploadType == ZHttpUploadTypeVideo) {
            
            //                return [[ZEncryptManager shareEncryManager] encryptFileToData:fileData error:&err];
            return [[EncryptManager shareEncryManager] encryptFileToData:fileData];
        }
        if (self.uploadType == ZHttpUploadTypeImageThumbnail) { //缩略图
            NSString *beforeEncryMD5Str = [fileData dataGetMD5Encry]; //加密前md5
            //                NSData *encryData = [[ZEncryptManager shareEncryManager] encryptFileToData:fileData error:&err];//加密
            //                NSData *decryptData = [[ZEncryptManager shareEncryManager] decrypt:encryData];//解密
            NSData *encryData = [[EncryptManager shareEncryManager] encryptFileToData:fileData];//加密
            NSData *decryptData = [[EncryptManager shareEncryManager] decrypt:encryData];
            NSString *afterEncryMD5Str = [decryptData dataGetMD5Encry]; //加密后md5
            if ([beforeEncryMD5Str isEqualToString:afterEncryMD5Str]) {
                return encryData;
            } else {
                if (![NSString isNil:self.originFilePath]) {
                    //使用原图
                    NSData *originFileData = [NSData dataWithContentsOfFile:self.originFilePath];
                    return [[EncryptManager shareEncryManager] encryptFileToData:originFileData];
                    //                        return [[ZEncryptManager shareEncryManager] encryptFileToData:[NSData dataWithContentsOfFile:self.originFilePath] error:&err];
                } else {
                    //如果缩略图加密失败，并且不存在原图沙盒路径，则将缩略图未加密data上传
                    return fileData;
                }
            }
        }
    }
    return fileData;
}

-(void)setStatus:(FileUploadTaskStatus)status error:(NSError *)error {
    _status = status;
    for (id<ZFileUploadTaskDelegate> delegate in self.delegates) {
        if(delegate && [delegate respondsToSelector:@selector(fileUploadTask:didChangTaskStatus:error:)] ){
            [delegate fileUploadTask:self didChangTaskStatus:status error:error];
        }
    }
}

-(void)setStatus:(FileUploadTaskStatus)status {
    _status = status;
    for (id<ZFileUploadTaskDelegate> delegate in self.delegates) {
        if(delegate && [delegate respondsToSelector:@selector(fileUploadTask:didChangTaskStatus:error:)] ){
            [delegate fileUploadTask:self didChangTaskStatus:status error:nil];
        }
    }
}

-(void)setProgress:(CGFloat)progress{
    _progress = progress;
    for (id<ZFileUploadTaskDelegate> delegate in self.delegates) {
        if(delegate && [delegate respondsToSelector:@selector(fileUploadTask:didChangTaskProgress:)] ){
            [delegate fileUploadTask:self didChangTaskProgress:progress];
        }
    }
}

-(void)pause{
    self.status = FileUploadTaskStatus_Paused;
    [self.session suspend];
    if(self.semaphore){
        dispatch_semaphore_signal(self.semaphore);
    }
    for (id<ZFileUploadTaskDelegate> delegate in self.delegates) {
        if(delegate && [delegate respondsToSelector:@selector(fileUploadTaskDidPause:)] ){
            [delegate fileUploadTaskDidPause:self];
        }
    }
}

- (void)resume{
    for (id<ZFileUploadTaskDelegate> delegate in self.delegates) {
        if(delegate && [delegate respondsToSelector:@selector(fileUploadTaskDidResume:)] ){
            [delegate fileUploadTaskDidResume:self];
        }
    }
}

-(void)addDelegate:(id<ZFileUploadTaskDelegate>)delegate{
    if(![self.delegates containsObject:delegate]){
        [self.delegates addObject:delegate];
    }
}
- (void)removeDelegate:(id<ZFileUploadTaskDelegate>)delegate{
    if([self.delegates containsObject:delegate]){
        [self.delegates removeObject:delegate];
    }
}

-(NSHashTable<id<ZFileUploadTaskDelegate>> *)delegates{
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
    return [self.taskId isEqualToString:((NoaFileUploadTask *)object).taskId];
}

-(void)dealloc{
    NSLog(@"任务销毁");
}

@end
