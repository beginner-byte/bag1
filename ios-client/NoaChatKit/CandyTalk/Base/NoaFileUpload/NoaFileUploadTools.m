//
//  NoaFileUploadTools.m
//  NoaKit
//
//  Created by Candy on 2024/3/5.
//

#import "NoaFileUploadTools.h"

@implementation NoaFileUploadTools

#pragma mark - minio 根据上传文件类型 获取桶名称
+ (NSString *)getMinioBucketNameFormUploadType:(ZHttpUploadType)uploadType;{
    NSString *bucketName;
    if (uploadType == ZHttpUploadTypeImage || uploadType == ZHttpUploadTypeImageThumbnail) {
        //图片
        bucketName = [NSString stringWithFormat:UPLAOD_ZIM_MSG_IMAGE, [NSDate dateForBucketName]];
    } else if(uploadType == ZHttpUploadTypeVideo){
        //视频
        bucketName = [NSString stringWithFormat:UPLAOD_ZIM_SHORT_VIDEO, [NSDate dateForBucketName]];
    } else if(uploadType == ZHttpUploadTypeVoice){
        //语音音频
        bucketName = [NSString stringWithFormat:UPLAOD_ZIM_VOICE_MP3, [NSDate dateForBucketName]];
    } else if(uploadType == ZHttpUploadTypeFile){
        //聊天文件
        bucketName = [NSString stringWithFormat:UPLAOD_ZIM_BIG_FILE, [NSDate dateForBucketName]];
    } else if(uploadType == ZHttpUploadTypeGroupAvatar){
        //群组头像
        bucketName = UPLAOD_ZIM_AVATAR_GROUP;
    } else if (uploadType == ZHttpUploadTypeUserAvatar) {
        //个人信息头像
        bucketName = UPLAOD_ZIM_AVATAR;
    } else if (uploadType == ZHttpUploadTypeUniversal) {
        //通用文件保存路径
        bucketName = UPLAOD_ZIM_UNIVERSAL;
    } else if (uploadType == ZHttpUploadTypeMiniApp) {
        //小程序图标保存路径
        bucketName = UPLAOD_ZIM_MINIAPP;
    } else if (uploadType == ZHttpUploadTypeStickers) {
        //表情文件保存路径
        bucketName = [NSString stringWithFormat:UPLAOD_ZIM_STICKERS, [NSDate dateForBucketName]];
    }  else {
        bucketName = @"";
    }
    return bucketName;
}

#pragma mark - 根据上传文件类型 获取文件存储路径
+ (NSString *)getAliyunObjectKeyPathFormUploadType:(ZHttpUploadType)uploadType {
    NSString *objectKeyPath;
    if (uploadType == ZHttpUploadTypeImage || uploadType == ZHttpUploadTypeImageThumbnail) {
        //图片
        objectKeyPath = [NSString stringWithFormat:UPLAOD_ALIYUN_MSG_IMAGE, [NSDate dateForBucketName]];
    } else if(uploadType == ZHttpUploadTypeVideo){
        //视频
        objectKeyPath = [NSString stringWithFormat:UPLAOD_ALIYUN_SHORT_VIDEO, [NSDate dateForBucketName]];
    } else if(uploadType == ZHttpUploadTypeVoice){
        //语音音频
        objectKeyPath = [NSString stringWithFormat:UPLAOD_ALIYUN_VOICE_MP3, [NSDate dateForBucketName]];
    } else if(uploadType == ZHttpUploadTypeFile){
        //聊天文件
        objectKeyPath = [NSString stringWithFormat:UPLAOD_ALIYUN_BIG_FILE, [NSDate dateForBucketName]];
    } else if(uploadType == ZHttpUploadTypeGroupAvatar){
        //群组头像
        objectKeyPath = UPLAOD_ALIYUN_AVATAR_GROUP;
    }  else if (uploadType == ZHttpUploadTypeUserAvatar) {
        //个人信息头像
        objectKeyPath = UPLAOD_ALIYUN_AVATAR;
    } else if (uploadType == ZHttpUploadTypeUniversal) {
        //通用文件保存路径
        objectKeyPath = UPLAOD_ALIYUN_UNIVERSAL;
    } else if (uploadType == ZHttpUploadTypeMiniApp) {
        //小程序图标保存路径
        objectKeyPath = UPLAOD_ALIYUN_MINIAPP;
    } else if (uploadType == ZHttpUploadTypeStickers) {
        //表情文件保存路径
        objectKeyPath = [NSString stringWithFormat:UPLAOD_ALIYUN_STICKERS, [NSDate dateForBucketName]];
    } else {
        objectKeyPath = @"";
    }
    return objectKeyPath;
}

/** AWS S3 根据上传文件类型 获取文件存储路径*/
+ (NSString *)getAWSS3ObjectKeyPathFormUploadType:(ZHttpUploadType)uploadType {
    NSString *objectKeyPath;
    if (uploadType == ZHttpUploadTypeImage || uploadType == ZHttpUploadTypeImageThumbnail) {
        //图片
        objectKeyPath = [NSString stringWithFormat:UPLAOD_AWS_MSG_IMAGE, [NSDate dateForBucketName]];
    } else if(uploadType == ZHttpUploadTypeVideo){
        //视频
        objectKeyPath = [NSString stringWithFormat:UPLAOD_AWS_SHORT_VIDEO, [NSDate dateForBucketName]];
    } else if(uploadType == ZHttpUploadTypeVoice){
        //语音音频
        objectKeyPath = [NSString stringWithFormat:UPLAOD_AWS_VOICE_MP3, [NSDate dateForBucketName]];
    } else if(uploadType == ZHttpUploadTypeFile){
        //聊天文件
        objectKeyPath = [NSString stringWithFormat:UPLAOD_AWS_BIG_FILE, [NSDate dateForBucketName]];
    } else if(uploadType == ZHttpUploadTypeGroupAvatar){
        //群组头像
        objectKeyPath = UPLAOD_AWS_AVATAR_GROUP;
    }  else if (uploadType == ZHttpUploadTypeUserAvatar) {
        //个人信息头像
        objectKeyPath = UPLAOD_AWS_AVATAR;
    } else if (uploadType == ZHttpUploadTypeUniversal) {
        //通用文件保存路径
        objectKeyPath = UPLAOD_AWS_UNIVERSAL;
    } else if (uploadType == ZHttpUploadTypeMiniApp) {
        //小程序图标保存路径
        objectKeyPath = UPLAOD_AWS_MINIAPP;
    } else if (uploadType == ZHttpUploadTypeStickers) {
        //表情文件保存路径
        objectKeyPath = [NSString stringWithFormat:UPLAOD_AWS_STICKERS, [NSDate dateForBucketName]];
    } else {
        objectKeyPath = @"";
    }
    return objectKeyPath;
}

/** 腾讯云 根据上传文件类型 获取文件存储路径*/
+ (NSString *)getTencentCosObjectKeyPathFormUploadType:(ZHttpUploadType)uploadType {
    NSString *objectKeyPath;
    if (uploadType == ZHttpUploadTypeImage || uploadType == ZHttpUploadTypeImageThumbnail) {
        //图片
        objectKeyPath = [NSString stringWithFormat:UPLAOD_TENCENT_MSG_IMAGE, [NSDate dateForBucketName]];
    } else if(uploadType == ZHttpUploadTypeVideo){
        //视频
        objectKeyPath = [NSString stringWithFormat:UPLAOD_TENCENT_SHORT_VIDEO, [NSDate dateForBucketName]];
    } else if(uploadType == ZHttpUploadTypeVoice){
        //语音音频
        objectKeyPath = [NSString stringWithFormat:UPLAOD_TENCENT_VOICE_MP3, [NSDate dateForBucketName]];
    } else if(uploadType == ZHttpUploadTypeFile){
        //聊天文件
        objectKeyPath = [NSString stringWithFormat:UPLAOD_TENCENT_BIG_FILE, [NSDate dateForBucketName]];
    } else if(uploadType == ZHttpUploadTypeGroupAvatar){
        //群组头像
        objectKeyPath = UPLAOD_TENCENT_AVATAR_GROUP;
    }  else if (uploadType == ZHttpUploadTypeUserAvatar) {
        //个人信息头像
        objectKeyPath = UPLAOD_TENCENT_AVATAR;
    } else if (uploadType == ZHttpUploadTypeUniversal) {
        //通用文件保存路径
        objectKeyPath = UPLAOD_TENCENT_UNIVERSAL;
    } else if (uploadType == ZHttpUploadTypeMiniApp) {
        //小程序图标保存路径
        objectKeyPath = UPLAOD_TENCENT_MINIAPP;
    } else if (uploadType == ZHttpUploadTypeStickers) {
        //表情文件保存路径
        objectKeyPath = [NSString stringWithFormat:UPLAOD_TENCENT_STICKERS, [NSDate dateForBucketName]];
    } else {
        objectKeyPath = @"";
    }
    return objectKeyPath;
}

/** 华为云 根据上传文件类型 获取文件存储路径*/
+ (NSString *)getHuaWeiOBSObjectKeyPathFormUploadType:(ZHttpUploadType)uploadType {
    NSString *objectKeyPath;
    if (uploadType == ZHttpUploadTypeImage || uploadType == ZHttpUploadTypeImageThumbnail) {
        //图片
        objectKeyPath = [NSString stringWithFormat:UPLAOD_HUAWEIOBS_MSG_IMAGE, [NSDate dateForBucketName]];
    } else if(uploadType == ZHttpUploadTypeVideo){
        //视频
        objectKeyPath = [NSString stringWithFormat:UPLAOD_HUAWEIOBS_SHORT_VIDEO, [NSDate dateForBucketName]];
    } else if(uploadType == ZHttpUploadTypeVoice){
        //语音音频
        objectKeyPath = [NSString stringWithFormat:UPLAOD_HUAWEIOBS_VOICE_MP3, [NSDate dateForBucketName]];
    } else if(uploadType == ZHttpUploadTypeFile){
        //聊天文件
        objectKeyPath = [NSString stringWithFormat:UPLAOD_HUAWEIOBS_BIG_FILE, [NSDate dateForBucketName]];
    } else if(uploadType == ZHttpUploadTypeGroupAvatar){
        //群组头像
        objectKeyPath = UPLAOD_HUAWEIOBS_AVATAR_GROUP;
    }  else if (uploadType == ZHttpUploadTypeUserAvatar) {
        //个人信息头像
        objectKeyPath = UPLAOD_HUAWEIOBS_AVATAR;
    } else if (uploadType == ZHttpUploadTypeUniversal) {
        //通用文件保存路径
        objectKeyPath = UPLAOD_HUAWEIOBS_UNIVERSAL;
    } else if (uploadType == ZHttpUploadTypeMiniApp) {
        //小程序图标保存路径
        objectKeyPath = UPLAOD_HUAWEIOBS_MINIAPP;
    } else if (uploadType == ZHttpUploadTypeStickers) {
        //表情文件保存路径
        objectKeyPath = [NSString stringWithFormat:UPLAOD_HUAWEIOBS_STICKERS, [NSDate dateForBucketName]];
    } else {
        objectKeyPath = @"";
    }
    return objectKeyPath;
}


#pragma mark - 根据上传文件类型 获取mimeType
+ (NSString *)getMimeTypeFormUploadType:(ZHttpUploadType)uploadType withFilePath:(NSString *)filePath {
    NSString *mimeType = @"";
    switch (uploadType) {
        case ZHttpUploadTypeImage:  //图片
        case ZHttpUploadTypeImageThumbnail:
            mimeType = @"image/jpeg";
            break;
        case ZHttpUploadTypeVideo:  //视频
            mimeType = @"video/mp4";
            break;
        case ZHttpUploadTypeVoice:  //语音音频
            mimeType = @"application/octet-stream";
            break;
        case ZHttpUploadTypeFile:  //文件
            mimeType = [NSString fileTranslateToMimeTypeWithPath:filePath];
            break;
        case ZHttpUploadTypeGroupAvatar:  //群组头像
            mimeType = @"image/jpeg";
            break;
        case ZHttpUploadTypeUserAvatar:  //个人信息头像
            mimeType = @"image/jpeg";
            break;
        case ZHttpUploadTypeUniversal:  //通用文件
            mimeType = @"image/jpeg";
            break;
        case ZHttpUploadTypeMiniApp:  //小程序图标
            mimeType = @"image/jpeg";
            break;
        case ZHttpUploadTypeStickers:  //表情文件
            mimeType = @"image/jpeg";
            break;
        default:
            break;
    }
    return mimeType;
}

@end
