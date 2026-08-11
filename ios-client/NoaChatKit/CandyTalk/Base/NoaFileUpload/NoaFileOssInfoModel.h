//
//  NoaFileOssInfoModel.h
//  NoaKit
//
//  Created by Candy on 2023/6/16.
//

#import "NoaBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaFileOssInfoModel : NoaBaseModel

/** aliyun */
@property (nonatomic, copy) NSString *aliyunAccessKeyId;
@property (nonatomic, copy) NSString *aliyunSecretKeyId;
@property (nonatomic, copy) NSString *aliyunSecurityToken;
@property (nonatomic, copy) NSString *aliyunExpiration;

/** AWS S3 */
@property (nonatomic, copy) NSString *awss3AccessKey;
@property (nonatomic, copy) NSString *awss3SecretKey;
@property (nonatomic, copy) NSString *awss3sessionToken;
@property (nonatomic, copy) NSString *awss3Expiration;

/** 腾讯云 */
@property (nonatomic, copy) NSString *tencentsecretId;
@property (nonatomic, copy) NSString *tencentsecretKey;
@property (nonatomic, copy) NSString *tencentToken;
@property (nonatomic, copy) NSString *tencentExpiration;

/** 华为云 */
@property (nonatomic, copy) NSString *obsAccessKey;
@property (nonatomic, copy) NSString *obsSecretKey;
@property (nonatomic, copy) NSString *obsToken;
@property (nonatomic, copy) NSString *obsExpiration;

@end

NS_ASSUME_NONNULL_END
