//
//  NoaNetworkQualityDetector.h
//  NoaKit
//
//  Created by Assistant on 2025/01/10.
//

#import <Foundation/Foundation.h>
#import "Nav.pbobjc.h"
#import <NoaChatCore/NoaIMSDKManager.h>

NS_ASSUME_NONNULL_BEGIN

/// 网络质量检测错误码
typedef NS_ENUM(NSInteger, ZNetworkQualityErrorCode) {
    /// 所有服务器不可达
    ZNetworkQualityErrorCodeAllServersUnreachable = 1001,
    /// 没有可检测的服务器列表
    ZNetworkQualityErrorCodeNoServerList = 1002,
    /// 连接测试失败
    ZNetworkQualityErrorCodeConnectionTestFailed = 1003,
    /// 网络不可用
    ZNetworkQualityErrorCodeNetworkDisconnected = 1004,
};

/// 网络质量检测结果
@interface NoaNetworkQualityResult : NSObject

/// 服务器端点信息
@property (nonatomic, strong) IMServerEndpoint *endpoint;

/// 检测类型 (TCP)
@property (nonatomic, copy) NSString *probeType;

/// 连接延迟 (毫秒)
@property (nonatomic, assign) NSTimeInterval latency;

/// 连接成功率 (0.0-1.0)
@property (nonatomic, assign) double successRate;

/// 网络质量评分 (0-100)
@property (nonatomic, assign) NSInteger qualityScore;

/// 检测时间戳
@property (nonatomic, assign) NSTimeInterval probeTimestamp;

/// 错误信息
@property (nonatomic, copy, nullable) NSString *errorMessage;

/// 是否可用
@property (nonatomic, assign) BOOL isAvailable;

/// 连续失败次数
@property (nonatomic, assign) NSInteger consecutiveFailures;

/// 连续高延迟次数
@property (nonatomic, assign) NSInteger consecutiveHighLatency;

@end

/// 网络质量检测配置
@interface NoaNetworkQualityConfig : NSObject

/// 检测间隔时间 (秒)
@property (nonatomic, assign) NSTimeInterval probeInterval;

/// TCP连接超时时间 (秒)
@property (nonatomic, assign) NSTimeInterval tcpTimeout;


/// 最大重试次数
@property (nonatomic, assign) NSInteger maxRetryCount;

/// 是否启用网络质量检测
@property (nonatomic, assign) BOOL enableNetworkDetection;

/// 质量评分权重配置
@property (nonatomic, assign) double latencyWeight;      // 延迟权重
@property (nonatomic, assign) double successRateWeight;  // 成功率权重
@property (nonatomic, assign) double stabilityWeight;    // 稳定性权重

/// 质量阈值配置
@property (nonatomic, assign) NSTimeInterval maxAcceptableLatency;  // 最大可接受延迟
@property (nonatomic, assign) double minAcceptableSuccessRate;      // 最小可接受成功率

/// 跳出条件配置
@property (nonatomic, assign) NSInteger maxConsecutiveHighLatency;   // 最大连续高延迟次数
@property (nonatomic, assign) NSInteger maxConsecutiveFailures;      // 最大连续失败次数
@property (nonatomic, assign) NSTimeInterval latencySpikeThreshold;  // 延迟突增阈值
@property (nonatomic, assign) double maxPacketLossRate;              // 最大丢包率

+ (instancetype)defaultConfig;

@end

/// 网络质量异常类型
typedef NS_ENUM(NSInteger, ZNetworkQualityExceptionType) {
    ZNetworkQualityExceptionTypeNone = 0,
    
    // 延迟相关异常
    ZNetworkQualityExceptionTypeHighLatency = 1001,           // 高延迟
    ZNetworkQualityExceptionTypeConsecutiveHighLatency = 1002, // 连续高延迟
    ZNetworkQualityExceptionTypeLatencySpike = 1003,          // 延迟突增
    
    // 连接稳定性异常
    ZNetworkQualityExceptionTypeConnectionTimeout = 2001,     // 连接超时
    ZNetworkQualityExceptionTypeHighPacketLoss = 2002,        // 高丢包率
    ZNetworkQualityExceptionTypeConsecutiveFailures = 2003,   // 连续失败
    
    // 网络环境变化异常
    ZNetworkQualityExceptionTypeNetworkTypeChanged = 3001,    // 网络类型变化
    ZNetworkQualityExceptionTypeIPAddressChanged = 3002,      // IP地址变化
    ZNetworkQualityExceptionTypeDNSResolutionFailed = 3003,   // DNS解析失败
    
    // 应用状态异常
    ZNetworkQualityExceptionTypeAppBackgroundResume = 4001,   // 应用后台恢复
    ZNetworkQualityExceptionTypeManualRefresh = 4002,         // 手动刷新
    ZNetworkQualityExceptionTypeSwitchEnterprise = 4003,      // 切换邀请码
    
    // 时间相关异常已移除 - 由外部组件处理
    
    // 服务器状态异常
    ZNetworkQualityExceptionTypeAllServersUnreachable = 6001, // 所有服务器不可达
    ZNetworkQualityExceptionTypeServerOverloaded = 6002,      // 服务器负载过高
    ZNetworkQualityExceptionTypeServerMaintenance = 6003,     // 服务器维护模式
    ZNetworkQualityExceptionTypeServerResponseError = 6004    // 服务器响应错误
};

/// 网络质量异常信息
@interface NoaNetworkQualityException : NSObject

/// 异常类型
@property (nonatomic, assign) ZNetworkQualityExceptionType exceptionType;

/// 异常描述
@property (nonatomic, copy) NSString *exceptionDescription;

/// 异常时间戳
@property (nonatomic, assign) NSTimeInterval exceptionTimestamp;

/// 相关服务器端点
@property (nonatomic, strong, nullable) IMServerEndpoint *relatedEndpoint;

/// 异常数据
@property (nonatomic, strong, nullable) NSDictionary *exceptionData;

/// 是否触发重新竞速
@property (nonatomic, assign) BOOL shouldTriggerRerace;

/// 是否立即触发
@property (nonatomic, assign) BOOL isImmediateTrigger;

/// 触发级别 (0: 服务器列表级别, 1: 当前连接级别)
@property (nonatomic, assign) NSInteger triggerLevel;

@end

/// 网络质量检测回调
@protocol ZNetworkQualityDetectorDelegate <NSObject>

@optional
/// 检测完成回调
- (void)networkQualityDetector:(id)detector didCompleteProbeWithResults:(NSArray<NoaNetworkQualityResult *> *)results;

/// 网络质量异常回调
- (void)networkQualityDetector:(id)detector didDetectException:(NoaNetworkQualityException *)exception;

/// 检测失败回调
- (void)networkQualityDetector:(id)detector didFailWithError:(NSError *)error;

@end

/// 网络质量检测器（支持ECDH探测，包含TCP连接和密钥交换）
@interface NoaNetworkQualityDetector : NSObject

/// 代理
@property (nonatomic, weak) id<ZNetworkQualityDetectorDelegate> delegate;

/// 配置
@property (nonatomic, strong) NoaNetworkQualityConfig *config;

/// 当前检测的TCP服务器列表
@property (nonatomic, strong) NSArray<IMServerEndpoint *> *tcpServers;

/// 当前连接的服务器
@property (nonatomic, strong, nullable) IMServerEndpoint *currentConnectedServer;

/// 是否启用网络质量检测 (YES: 启用检测, NO: 禁用检测)
@property (nonatomic, assign, readonly) BOOL enableDetection;

/// 当前正在网络质量检测的邀请码
@property (nonatomic, copy) NSString *currentLiceseId;

/// 单例
+ (instancetype)sharedDetector;

/// 开始网络质量监控
- (void)startNetworkQualityDetection;

/// 停止网络质量监控
- (void)stopNetworkQualityDetection;

/// 更新服务器列表
- (void)updateServerLists:(NSArray<IMServerEndpoint *> *)tcpServers;

/// 获取最优服务器
- (IMServerEndpoint *)getOptimalServer;

/// 获取当前不可用的服务器列表
- (NSArray<IMServerEndpoint *> *)getUnavailableServers;

/// 设置是否启用网络质量检测
/// @param enable YES: 启用检测, NO: 禁用检测
- (void)setEnableDetection:(BOOL)enable;

/// 测试单个服务器的ECDH探测（包含TCP连接和密钥交换）
/// @param host 服务器地址
/// @param port 服务器端口
/// @param timeout 超时时间
/// @param completion 完成回调
- (void)testSingleServerConnectivity:(NSString *)host
                                port:(int)port
                             timeout:(NSTimeInterval)timeout
                           completion:(void(^)(BOOL success, NSTimeInterval latency, NSString *errorMessage))completion;

@end

#pragma mark - 错误码便利方法

/// 网络质量检测错误码便利方法
@interface NSError (NoaNetworkQualityDetector)

/// 创建网络质量检测错误
+ (instancetype)networkQualityErrorWithCode:(ZNetworkQualityErrorCode)code
                               description:(NSString *)description
                               failureReason:(NSString *)failureReason
                               userInfo:(NSDictionary * _Nullable)userInfo;

/// 判断是否为网络质量检测错误
- (BOOL)isNetworkQualityError;

/// 获取网络质量检测错误码
- (ZNetworkQualityErrorCode)networkQualityErrorCode;

@end

NS_ASSUME_NONNULL_END
