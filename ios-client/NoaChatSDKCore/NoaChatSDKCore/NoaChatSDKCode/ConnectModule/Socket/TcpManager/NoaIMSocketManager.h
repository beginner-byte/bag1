//
//  NoaIMSocketManager.h
//  NoaChatSDKCore
//
//  Created by Candy on 2023/5/22.
//

// Socket封装
//长连接封装
#define SOCKETMANAGER [NoaIMSocketManager sharedTool]

#define LingIMMessageTag        1         //消息标签
#define LingIMHeartTag          6868      //心跳标签
#define LingIMHeartInterval     30        //心跳间隔
#define LingIMHeartFailureCount 5         //心跳失败次数(未收到pong次数)
#define LingIMReconnectPow      2         //2的n次方 重连时间间隔0 2 4 8 16...，2的n次方，从第5次开始，时间间隔固定为16
#define LingIMConnectTimeout    60        //长连接超时时间
#define LingIMMessageTimeout    3        //消息发送超时时间/消息重发时间间隔

#import <Foundation/Foundation.h>
#import "NoaIMSocketHostOptions.h"//网关配置信息
#import "NoaIMSocketUserOptions.h"//用户配置信息
#import "LingImmessage.pbobjc.h"//消息体
#import <GCDAsyncSocket.h>//长连接

NS_ASSUME_NONNULL_BEGIN
/// 检查是否有最优节点可用
typedef BOOL(^HasOptimalServerAvailableBlock)(void);

/// 获取最优服务器节点
typedef NSDictionary * _Nullable(^GetOptimalServerInfoBlock)(void);

@interface NoaIMSocketManager : NSObject

#pragma mark - <<<<<<单例>>>>>>
+ (instancetype)sharedTool;

/// 套接字对象
@property (nonatomic, strong, readonly) GCDAsyncSocket *gcdSocket;

#pragma mark - <<<<<<业务>>>>>>
/// 配置/更新socket用户信息
/// - Parameter userOptions: 用户信息
- (void)configureSocketUser:(NoaIMSocketUserOptions *)userOptions;

#pragma mark - 配置socket网关信息
/// 配置/更新socket网关信息
/// - Parameter hostOptions: 网关信息
- (void)configureSocketHost:(NoaIMSocketHostOptions *)hostOptions;

/// 开始连接
-(void)startSocketConnect;

/// 断开socket连接
- (void)disconnectSocket;

/// 重连socket
- (void)startingSocketReconnect;

/// 当前socket连接状态
- (BOOL)currentSocketConnectStatus;

/// 是否交换ecdh key成功
- (BOOL)isExchangeEcdhKeySuccess;

/// 鉴权socket用户
- (void)authSocketUser;

/// 恢复是否是重连reConnect状态为初始状态
- (void)configSetIsReconenctStatus;

/// 发送socket消息
/// - Parameter message: 消息体
/// - Parameter messageTag: 消息标签
- (void)sendSocketMessage:(id)message tag:(NSInteger)messageTag;

/// 发送socket消息
/// - Parameters:
///   - message: 消息体
///   - timeOut:· 超时时间，单位秒
///   - messageTag: 消息标签
- (void)sendSocketMessage:(id)message
                  timeOut:(NSInteger)timeOut
                      tag:(NSInteger)messageTag;

/// 开始心跳机制(用户鉴权成功后开始)
- (void)startSocketHeartbeat;

/// 重置未收到Pong响应次数
- (void)resetSocketHeartNoPongCount;

/// socket的用户id
- (NSString *)socketUserID;

/// socket的用户token
- (NSString *)socketUserToken;

/// socket 主机 地址
- (NSString *)socketHostValue;

/// socket 主机 端口
- (NSInteger)socketPortValue;

/// 清空用户信息
- (void)clearUserInfo;

/// 清理接收缓冲区
- (void)cleanupReceiveBuffers;

@property (nonatomic, copy) HasOptimalServerAvailableBlock hasOptimalServerAvailableBlock;

@property (nonatomic, copy) GetOptimalServerInfoBlock getOptimalServerInfoBlock;

/// 是否能够重新连接
@property (nonatomic, assign) BOOL isCanReconnect;

@end

NS_ASSUME_NONNULL_END
