//
//  NoaCaptchaCodeTools.h
//  NoaKit
//
//  Created by Candy on 2024/7/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaCaptchaCodeTools : NSObject

@property (nonatomic, assign) NSInteger aliyunVerNum;

//腾讯云验证结果成功block
@property (nonatomic, copy) void(^tencentCaptchaResultSuccess)(NSString *ticket, NSString *randstr);
//阿里云验证结果成功block
@property (nonatomic, copy) void(^aliyunCaptchaResultSuccess)(NSString *captchaVerifyParam);
//验证失败block
@property (nonatomic, copy) void(^captchaResultFail)(void);

//腾讯云、阿里云 无感验证
- (void)verCaptchaCode;

//阿里云 二次验证
- (void)secondVerCaptchaCode;

@end

NS_ASSUME_NONNULL_END
