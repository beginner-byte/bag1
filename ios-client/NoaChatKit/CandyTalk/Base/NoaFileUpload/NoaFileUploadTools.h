//
//  NoaFileUploadTools.h
//  NoaKit
//
//  Created by Candy on 2024/3/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** minio URL */
//上传
#define ZIM_UPLOAD_FILE_URL         @"/file/upload"
//上传资源时先获取公钥
#define ZIM_UPLOAD_PUBLIC_KEY_URL   @"/public-key/getKey"
//下载
#define ZIM_DOWNLOAD_FILE_URL       @"/file/download"
/** 分片上传 */
//分片上传step1-获取uploadId
#define ZIM_SLICING_UPLOAD_STEP_ONE_URL     @"/file/multi/getId"
//分片上传step2-上传多片请求
#define ZIM_SLICING_UPLOAD_STEP_TWO_URL     @"/file/multi/upload"
//分片上传step3-上传多片请求
#define ZIM_SLICING_UPLOAD_STEP_THREE_URL   @"/file/multi/complete"

@interface NoaFileUploadTools : NSObject

/** minio 根据上传文件类型 获取桶名称*/
+ (NSString *)getMinioBucketNameFormUploadType:(ZHttpUploadType)uploadType;

/** aliyun 根据上传文件类型 获取文件存储路径*/
+ (NSString *)getAliyunObjectKeyPathFormUploadType:(ZHttpUploadType)uploadType;

/** AWS S3 根据上传文件类型 获取文件存储路径*/
+ (NSString *)getAWSS3ObjectKeyPathFormUploadType:(ZHttpUploadType)uploadType;

/** 腾讯云 根据上传文件类型 获取文件存储路径*/
+ (NSString *)getTencentCosObjectKeyPathFormUploadType:(ZHttpUploadType)uploadType;

/** 华为云 根据上传文件类型 获取文件存储路径*/
+ (NSString *)getHuaWeiOBSObjectKeyPathFormUploadType:(ZHttpUploadType)uploadType;

#pragma mark - 根据上传文件类型和文件路径 获取mimeType
+ (NSString *)getMimeTypeFormUploadType:(ZHttpUploadType)uploadType withFilePath:(NSString *)filePath;


@end

NS_ASSUME_NONNULL_END
