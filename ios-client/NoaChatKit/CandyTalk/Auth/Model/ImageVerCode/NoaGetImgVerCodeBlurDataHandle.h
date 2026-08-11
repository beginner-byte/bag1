//
//  NoaGetImgVerCodeBlurDataHandle.h
//  NoaChatKit
//
//  Created by phl on 2025/11/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaGetImgVerCodeBlurDataHandle : NSObject

/// 展示Toast
@property (nonatomic, strong) RACSubject *showToastSubject;

/// 页面消失
@property (nonatomic, strong) RACSubject *dismissSubject;

/// 点击确认，配置完成
@property (nonatomic, strong) RACSubject *configureFinishSubject;

/// 账号
@property (nonatomic, copy) NSString *account;

/**
 验证码类型
 0:用户名登录
 1:手机号注册
 2:手机号登录
 3:手机号找回密码
 */
@property (nonatomic, assign) NSInteger verCodeType;

/// 外部传入的图文验证码、如果重新请求，此值会更新
@property (nonatomic, copy) NSString *imgVerCode;

/// 点击获取验证码的时候，先获取图文验证码
@property (nonatomic, strong) RACCommand *getImgVerCommand;

@end

NS_ASSUME_NONNULL_END
