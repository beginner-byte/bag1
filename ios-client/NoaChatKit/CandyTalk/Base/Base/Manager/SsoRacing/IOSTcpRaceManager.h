//
//  IOSTcpRaceManager.h
//  NoaKit
//
//  Created by Candy on 2025/1/15.
//

#import <Foundation/Foundation.h>
#import "NoaUrlHostModel.h"
#import "Nav.pbobjc.h"
NS_ASSUME_NONNULL_BEGIN

/**
 * iOS TCP直连竞速管理器
 * 用于通过TCP连接发送Protobuf消息进行网络竞速
 */
@interface IOSTcpRaceManager : NSObject

/**
 * 初始化方法
 * @param appId 应用ID/邀请码
 * @param appType 应用类型 (0:公共打包 1:独立打包)
 * @param bucket 目标服务器信息 (NoaUrlHostModel)
 * @param useProxy 是否使用代理
 * @param publicIp 公网ip
 */
- (instancetype)initWithAppId:(NSString *)appId
                      appType:(int)appType
                       bucket:(NoaUrlHostModel *)bucket
                     useProxy:(BOOL)useProxy
                     publicIp:(NSString *)publicIp;

/**
 * 执行TCP竞速任务
 * @param success 成功回调，返回解密后的OSS信息
 * @param failure 失败回调
 */
- (void)executeWithSuccess:(void(^)(IMServerListResponseBody *serverResponse))success
                   failure:(void(^)(NSError *error))failure;

/**
 * 取消当前任务
 */
- (void)cancel;

/**
 * 获取任务标识
 */
- (NSString *)getTaskTag;

@end

NS_ASSUME_NONNULL_END
