//
//  NoaFileUploadGetSTSTask.m
//  NoaKit
//
//  Created by Candy on 2024/8/23.
//

#import "NoaFileUploadGetSTSTask.h"
#import "NoaFileUploadManager.h"

@interface NoaFileUploadGetSTSTask ()

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end


@implementation NoaFileUploadGetSTSTask

- (void)main{
    @autoreleasepool {
        if (self.isCancelled) {
            // 任务被取消，退出执行
            return;
        }
        [self chekStsInfo];
    }
}

-(void)setUploadTask:(NSArray<NoaFileUploadTask *> *)uploadTask{
    _uploadTask = uploadTask;
    for (NoaFileUploadTask * task in uploadTask) {
        [task addDependency:self];
    }
}

-(void)chekStsInfo{
    self.semaphore = dispatch_semaphore_create(0);
    
    // 每次重新获取token重新获取
    WeakSelf
    [IMSDKManager userGetFileUploadTokenWithOnSuccess:^(id  _Nullable data, NSString * _Nullable traceId) {
        if([data isKindOfClass:[NSDictionary class]]){
            NSDictionary *dataDic = (NSDictionary *)data;
            NSDictionary *credentialsDic = (NSDictionary *)[dataDic objectForKey:@"credentials"];
            NSString *accessKey = (NSString *)[credentialsDic objectForKey:@"accessKeyId"];
            NSString *secretKey = (NSString *)[credentialsDic objectForKey:@"accessKeySecret"];
            NSString *accessToken = (NSString *)[credentialsDic objectForKey:@"securityToken"];
            NSString *expirTime = (NSString *)[credentialsDic objectForKey:@"expiration"];
            
            NoaFileOssInfoModel *fileOssModel = [[NoaFileOssInfoModel alloc] init];
            if ([ZHostTool.appSysSetModel.oss_config_type isEqualToString:@"1"] ) {
                //阿里云上传
                fileOssModel.aliyunAccessKeyId = accessKey;
                fileOssModel.aliyunSecretKeyId = secretKey;
                fileOssModel.aliyunSecurityToken = accessToken;
                fileOssModel.aliyunExpiration = expirTime;
                [NoaFileUploadManager sharedInstance].stsInfo = fileOssModel;
            }
            if ([ZHostTool.appSysSetModel.oss_config_type isEqualToString:@"2"]) {
                //AWS S3 亚马逊云上传
                fileOssModel.awss3AccessKey = accessKey;
                fileOssModel.awss3SecretKey = secretKey;
                fileOssModel.awss3sessionToken = accessToken;
                fileOssModel.awss3Expiration = expirTime;
                [NoaFileUploadManager sharedInstance].stsInfo = fileOssModel;
            }
            if ([ZHostTool.appSysSetModel.oss_config_type isEqualToString:@"3"]) {
                //Tencent腾讯云上传
                fileOssModel.tencentsecretId = accessKey;
                fileOssModel.tencentsecretKey = secretKey;
                fileOssModel.tencentToken = accessToken;
                fileOssModel.tencentExpiration = expirTime;
                [NoaFileUploadManager sharedInstance].stsInfo = fileOssModel;
            }
            if ([ZHostTool.appSysSetModel.oss_config_type isEqualToString:@"4"]) {
                //OBS华为云上传
                fileOssModel.obsAccessKey = accessKey;
                fileOssModel.obsSecretKey = secretKey;
                fileOssModel.obsToken = accessToken;
                fileOssModel.obsExpiration = expirTime;
                [NoaFileUploadManager sharedInstance].stsInfo = fileOssModel;
            }
        }
        dispatch_semaphore_signal(weakSelf.semaphore);
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
       dispatch_semaphore_signal(weakSelf.semaphore);
    }];
    
    //等待任务进入回调
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
}


@end
