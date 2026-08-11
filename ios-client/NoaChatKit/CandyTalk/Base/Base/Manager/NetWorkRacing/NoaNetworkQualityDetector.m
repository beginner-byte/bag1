//
//  NoaNetworkQualityDetector.m
//  NoaKit
//
//  Created by Assistant on 2025/01/10.
//

#import "NoaNetworkQualityDetector.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <netdb.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "NoaToolManager.h"
#import "Nav.pbobjc.h"
#import <ifaddrs.h>
#import <NoaChatCore/NoaIMSDKManager.h>

@interface NoaNetworkQualityDetector ()

/// 检测定时器
@property (nonatomic, strong) dispatch_source_t monitorTimer;

/// 检测队列
@property (nonatomic, strong) dispatch_queue_t monitorQueue;

/// 网络质量结果缓存
@property (nonatomic, strong) NSMutableDictionary<NSString *, NoaNetworkQualityResult *> *qualityResultsCache;

/// 连续高延迟计数
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *consecutiveHighLatencyCount;

/// 连续失败计数
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *consecutiveFailureCount;

/// 是否启用网络质量检测 (YES: 启用检测, NO: 禁用检测)
@property (nonatomic, assign, readwrite) BOOL enableDetection;

@end

@implementation NoaNetworkQualityDetector

#pragma mark - 单例

+ (instancetype)sharedDetector {
    static NoaNetworkQualityDetector *detector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        detector = [[NoaNetworkQualityDetector alloc] init];
    });
    return detector;
}

#pragma mark - 初始化

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupInitialConfiguration];
    }
    return self;
}

- (void)setupInitialConfiguration {
    // 设置默认配置
    _config = [NoaNetworkQualityConfig defaultConfig];
    
    // 创建检测队列
    _monitorQueue = dispatch_queue_create("com.cim.network.quality.detector", DISPATCH_QUEUE_CONCURRENT);
    
    // 初始化缓存
    _qualityResultsCache = [NSMutableDictionary dictionary];
    _consecutiveHighLatencyCount = [NSMutableDictionary dictionary];
    _consecutiveFailureCount = [NSMutableDictionary dictionary];
    
    // 初始化服务器列表
    _tcpServers = @[];
    
    // 默认启用检测
    _enableDetection = YES;
}

#pragma mark - 公共方法

- (void)startNetworkQualityDetection {
    // 检查是否启用检测
    if (!self.enableDetection) {
        NSLog(@"[网络检测] 网络质量检测已被禁用，跳过启动");
        return;
    }
    
    BOOL isConnectNet = [[NetWorkStatusManager shared] getConnectStatus];
    if (!isConnectNet) {
        [self clearPreviousDetection];
        // 创建失败错误
        NSError *error = [NSError networkQualityErrorWithCode:ZNetworkQualityErrorCodeNetworkDisconnected
                                                  description:@"网络中断"
                                                failureReason:@"网络连接中断，当前无法连接外网"
                                                      userInfo:@{@"serverCount": @0}];
        
        // 通知代理检测失败
        if ([self.delegate respondsToSelector:@selector(networkQualityDetector:didFailWithError:)]) {
            [self.delegate networkQualityDetector:self didFailWithError:error];
        }
        NSLog(@"[网络检测] 网络连接中断，请检查网络");
        return;
    }
    
    if (!self.config.enableNetworkDetection) {
        NSLog(@"[网络检测] 网络质量检测已禁用");
        return;
    }
    
    if (self.isMonitoring) {
        NSLog(@"[网络检测] 网络质量检测已在运行中");
        return;
    }
    
    NSLog(@"[网络检测] 启动网络质量检测，检测间隔: %.1f秒", self.config.probeInterval);
    
    // 创建定时器,定时检测网络质量
    self.monitorTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.monitorQueue);
    
    if (self.monitorTimer) {
        dispatch_source_set_timer(self.monitorTimer,
                                dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.config.probeInterval * NSEC_PER_SEC)),
                                (uint64_t)(self.config.probeInterval * NSEC_PER_SEC),
                                0);
        
        __weak typeof(self) weakSelf = self;
        dispatch_source_set_event_handler(self.monitorTimer, ^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            
            [self performNetworkQualityProbe];
        });
        
        dispatch_resume(self.monitorTimer);
        
        // 立即执行一次检测
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), self.monitorQueue, ^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            [self performNetworkQualityProbe];
        });
    }
}

/// 终止网络质量检测
- (void)stopNetworkQualityDetection {
    // 清除上一次数据
    [self clearPreviousDetection];
    // 清理计时器
    if (self.monitorTimer) {
        dispatch_source_cancel(self.monitorTimer);
        self.monitorTimer = nil;
        NSLog(@"[网络检测] 停止网络质量检测");
    }
}

/// 更新需要检测的ip、端口号
/// - Parameter tcpServers: tcp服务信息
- (void)updateServerLists:(NSArray<IMServerEndpoint *> *)tcpServers {
    self.tcpServers = tcpServers ?: @[];
    
    NSLog(@"[网络检测] 更新服务器列表 - TCP: %lu个",
          (unsigned long)self.tcpServers.count);
}

/// 获取排序后的网络质量结果（统一的数据源）
- (NSArray<NoaNetworkQualityResult *> *)getSortedQualityResults {
    @synchronized(self.qualityResultsCache) {
        NSArray<NoaNetworkQualityResult *> *allResults = [self.qualityResultsCache allValues];
        return [self sortResultsByQuality:allResults];
    }
}

/// 获取最优的服务器地址
- (IMServerEndpoint *)getOptimalServer {
    // 使用统一的数据源获取排序后的结果
    NSArray<NoaNetworkQualityResult *> *sortedResults = [self getSortedQualityResults];
    
    if (sortedResults.count == 0) {
        NSLog(@"[网络检测] 没有可用的网络质量检测结果，返回nil");
        return nil;
    }
    
    // 检查第一个结果是否有效
    NoaNetworkQualityResult *firstResult = sortedResults.firstObject;
    if (!firstResult || !firstResult.endpoint) {
        NSLog(@"[网络检测] 第一个结果无效，返回nil");
        return nil;
    }
    
    // 返回排序后的第一个结果（最优的服务器）
    IMServerEndpoint *optimalServer = firstResult.endpoint;
    NSLog(@"[网络检测] 获取最优服务器: %@:%d", optimalServer.ip, optimalServer.port);
    
    return optimalServer;
}

/// 获取不可用的服务器地址
- (NSArray<IMServerEndpoint *> *)getUnavailableServers {
    // 使用统一的数据源获取排序后的结果
    NSArray<NoaNetworkQualityResult *> *sortedResults = [self getSortedQualityResults];
    
    if (sortedResults.count == 0) {
        NSLog(@"[网络检测] 没有网络质量检测结果，返回空数组");
        return @[];
    }
    
    // 过滤出不可用的服务器
    NSMutableArray<IMServerEndpoint *> *unavailableServers = [NSMutableArray array];
    for (NoaNetworkQualityResult *result in sortedResults) {
        if (!result.isAvailable && result.endpoint) {
            [unavailableServers addObject:result.endpoint];
        }
    }
    
    NSLog(@"[网络检测] 获取不可用服务器列表，共 %lu 个", (unsigned long)unavailableServers.count);
    for (IMServerEndpoint *server in unavailableServers) {
        NSLog(@"[网络检测] 不可用服务器: %@:%d", server.ip, server.port);
    }
    
    return [unavailableServers copy];
}

/// 设置是否启用网络质量检测
/// @param enable YES: 启用检测, NO: 禁用检测
- (void)setEnableDetection:(BOOL)enable {
    _enableDetection = enable;
    NSLog(@"[网络检测] 设置检测启用状态: %@", enable ? @"启用" : @"禁用");
    
    // 如果禁用检测且当前正在检测，则停止检测
    if (!enable && self.isMonitoring) {
        NSLog(@"[网络检测] 检测被禁用，停止当前检测");
        [self stopNetworkQualityDetection];
    }
}

/// 测试单个服务器的ECDH探测（包含TCP连接和密钥交换）
/// @param host 服务器地址
/// @param port 服务器端口
/// @param timeout 超时时间
/// @param completion 完成回调
- (void)testSingleServerConnectivity:(NSString *)host
                                port:(int)port
                             timeout:(NSTimeInterval)timeout
                           completion:(void(^)(BOOL success, NSTimeInterval latency, NSString *errorMessage))completion {
    if (!host || host.length == 0 || port <= 0) {
        if (completion) {
            completion(NO, 0, @"无效的服务器参数");
        }
        return;
    }
    
    dispatch_async(self.monitorQueue, ^{
        NSTimeInterval latency = [self getTCPConnectionLatency:host port:port timeout:timeout];
        BOOL success = latency > 0;
        NSString *errorMessage = success ? nil : @"ECDH探测失败";
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(success, latency, errorMessage);
            }
        });
    });
}

#pragma mark - 网络质量检测

/// 清理旧数据并停止上一次的网络质量检测
- (void)clearPreviousDetection {
    NSLog(@"[网络检测] 清理旧数据并停止上一次检测");
    
    // 清理质量结果缓存
    @synchronized(self.qualityResultsCache) {
        [self.qualityResultsCache removeAllObjects];
    }
    
    // 清理连续失败计数
    @synchronized(self.consecutiveFailureCount) {
        [self.consecutiveFailureCount removeAllObjects];
    }
    
    // 清理连续高延迟计数
    @synchronized(self.consecutiveHighLatencyCount) {
        [self.consecutiveHighLatencyCount removeAllObjects];
    }
    
    NSLog(@"[网络检测] 旧数据清理完成");
}

/// 网络质量检测
- (void)performNetworkQualityProbe {
    NSLog(@"[网络检测] 开始执行网络质量检测");
    
    // 检查是否有服务器列表
    if (self.tcpServers.count == 0) {
        NSLog(@"[网络检测] 没有可检测的服务器列表，调用检测失败回调");
        
        NSError *error = [NSError networkQualityErrorWithCode:ZNetworkQualityErrorCodeNoServerList
                                                  description:@"没有可检测的服务器列表"
                                                failureReason:@"服务器列表为空，无法进行网络质量检测"
                                                      userInfo:nil];
        
        if ([self.delegate respondsToSelector:@selector(networkQualityDetector:didFailWithError:)]) {
            [self.delegate networkQualityDetector:self didFailWithError:error];
        }
        return;
    }
    
    // 创建检测组
    dispatch_group_t probeGroup = dispatch_group_create();
    NSMutableArray<NoaNetworkQualityResult *> *allResults = [NSMutableArray array];
    
    // TCP服务器检测
    for (IMServerEndpoint *tcpServer in self.tcpServers) {
        dispatch_group_enter(probeGroup);
        dispatch_async(self.monitorQueue, ^{
            NoaNetworkQualityResult *result = [self probeTCPServer:tcpServer];
            @synchronized(allResults) {
                if (result) {
                    [allResults addObject:result];
                } else {
                    NSLog(@"[网络检测] 服务器检测失败，跳过: %@:%d", tcpServer.ip, tcpServer.port);
                }
            }
            dispatch_group_leave(probeGroup);
        });
    }
    
    
    // 等待所有检测完成
    dispatch_group_notify(probeGroup, dispatch_get_main_queue(), ^{
        [self handleProbeResults:allResults];
    });
}

/// 检测TCP地址、端口号质量（带重试机制）
/// - Parameter server: 平台返回接口数据
- (NoaNetworkQualityResult *)probeTCPServer:(IMServerEndpoint *)server {
    return [self probeTCPServer:server retryCount:self.config.maxRetryCount];
}

/// 检测TCP地址、端口号质量（内部方法，支持重试）
/// - Parameter server: 平台返回接口数据
/// - Parameter retryCount: 重试次数
- (NoaNetworkQualityResult *)probeTCPServer:(IMServerEndpoint *)server retryCount:(NSInteger)retryCount {
    // 输入参数验证
    if (!server || !server.ip || server.port <= 0) {
        NSLog(@"[网络检测] 无效的服务器参数");
        return nil;
    }
    
    if (retryCount <= 0) {
        retryCount = 1; // 至少重试1次
    }
    
    NoaNetworkQualityResult *result = [[NoaNetworkQualityResult alloc] init];
    result.endpoint = server;
    result.probeType = @"TCP";
    result.probeTimestamp = [[NSDate date] timeIntervalSince1970];
    
    NSString *serverKey = [NSString stringWithFormat:@"%@:%d", server.ip, server.port];
    
    BOOL success = NO;
    NSTimeInterval bestLatency = 0;
    NSError *lastError = nil;
    
    // 重试逻辑
    for (NSInteger attempt = 1; attempt <= retryCount; attempt++) {
        NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
        BOOL attemptSuccess = NO;
        NSTimeInterval attemptLatency = 0;
        NSError *attemptError = nil;
        
        // 直接使用ECDH探测方法进行网络质量检测
        attemptLatency = [self getTCPConnectionLatency:server.ip port:server.port timeout:self.config.tcpTimeout];
        attemptSuccess = (attemptLatency > 0);
        
        if (attemptSuccess) {
            NSLog(@"[网络检测] ECDH探测成功 - %@:%d, 延迟: %.1fms (尝试 %ld/%ld)", server.ip, server.port, attemptLatency, (long)attempt, (long)retryCount);
        } else {
            attemptError = [NSError networkQualityErrorWithCode:ZNetworkQualityErrorCodeConnectionTestFailed
                                                     description:@"ECDH探测失败"
                                                   failureReason:@"网络连接测试失败"
                                                         userInfo:nil];
            NSLog(@"[网络检测] ECDH探测失败 - %@:%d (尝试 %ld/%ld)", server.ip, server.port, (long)attempt, (long)retryCount);
        }
        
        // 如果成功，记录最佳结果
        if (attemptSuccess) {
            success = YES;
            if (bestLatency == 0 || attemptLatency < bestLatency) {
                bestLatency = attemptLatency;
            }
            // 成功一次就退出重试循环
            break;
        } else {
            lastError = attemptError;
            // 如果不是最后一次尝试，等待一小段时间再重试
            if (attempt < retryCount) {
                usleep(100000); // 等待100ms，可配置化
            }
        }
    }
    
    result.isAvailable = success;
    result.latency = bestLatency;
    
    if (!success) {
        result.errorMessage = lastError.localizedDescription;
        NSLog(@"[网络检测] ECDH探测失败 - %@:%d, 重试 %ld 次后仍然失败: %@", server.ip, server.port, (long)retryCount, lastError.localizedDescription);
    }
    
    // 计算质量评分
    result.qualityScore = [self calculateQualityScore:serverKey latency:result.latency success:success];
    
    // 检查异常条件
    [self checkExceptionConditions:result];
    
    NSLog(@"[网络检测] ECDH探测完成 - %@:%d, 延迟: %.1fms, 可用: %@, 评分: %ld",
          server.ip, server.port, result.latency, result.isAvailable ? @"是" : @"否", (long)result.qualityScore);
    
    return result;
}


#pragma mark - 异常条件检查

- (void)checkExceptionConditions:(NoaNetworkQualityResult *)result {
    // 空指针检查
    if (!result || !result.endpoint) {
        NSLog(@"[网络检测] 检查异常条件失败：result或endpoint为空");
        return;
    }
    
    NSString *serverKey = [NSString stringWithFormat:@"%@:%d", result.endpoint.ip, result.endpoint.port];
    
    // 检查高延迟
    if (result.latency > self.config.maxAcceptableLatency) {
        NoaNetworkQualityException *exception = [[NoaNetworkQualityException alloc] init];
        exception.exceptionType = ZNetworkQualityExceptionTypeHighLatency;
        exception.exceptionDescription = [NSString stringWithFormat:@"延迟过高: %.1fms", result.latency];
        exception.exceptionTimestamp = result.probeTimestamp;
        exception.relatedEndpoint = result.endpoint;
        exception.shouldTriggerRerace = NO;
        exception.isImmediateTrigger = NO;
        exception.triggerLevel = 1; // 当前连接级别
        exception.exceptionData = @{@"latency": @(result.latency)};
        
        if ([self.delegate respondsToSelector:@selector(networkQualityDetector:didDetectException:)]) {
            [self.delegate networkQualityDetector:self didDetectException:exception];
        }
        
        // 更新连续高延迟计数
        NSNumber *newCount;
        @synchronized(self.consecutiveHighLatencyCount) {
            NSNumber *currentCount = self.consecutiveHighLatencyCount[serverKey] ?: @0;
            newCount = @(currentCount.integerValue + 1);
            self.consecutiveHighLatencyCount[serverKey] = newCount;
        }
        result.consecutiveHighLatency = newCount.integerValue;
        
        // 检查连续高延迟
        if (newCount.integerValue >= self.config.maxConsecutiveHighLatency) {
            NoaNetworkQualityException *consecutiveException = [[NoaNetworkQualityException alloc] init];
            consecutiveException.exceptionType = ZNetworkQualityExceptionTypeConsecutiveHighLatency;
            consecutiveException.exceptionDescription = [NSString stringWithFormat:@"连续高延迟: %ld次", (long)newCount.integerValue];
            consecutiveException.exceptionTimestamp = result.probeTimestamp;
            consecutiveException.relatedEndpoint = result.endpoint;
            consecutiveException.shouldTriggerRerace = YES;
            consecutiveException.isImmediateTrigger = NO;
            consecutiveException.triggerLevel = 1; // 当前连接级别
            consecutiveException.exceptionData = @{@"consecutiveCount": newCount};
            
            // 连续高延迟异常记录，但不立即触发重新竞速
            NSLog(@"[网络检测] 连续高延迟异常: %@", consecutiveException.exceptionDescription);
        }
    } else {
        // 重置连续高延迟计数
        @synchronized(self.consecutiveHighLatencyCount) {
            self.consecutiveHighLatencyCount[serverKey] = @0;
        }
        result.consecutiveHighLatency = 0;
    }
    
    // 检查连接失败
    if (!result.isAvailable) {
        // 更新连续失败计数
        NSNumber *newCount;
        @synchronized(self.consecutiveFailureCount) {
            NSNumber *currentCount = self.consecutiveFailureCount[serverKey] ?: @0;
            newCount = @(currentCount.integerValue + 1);
            self.consecutiveFailureCount[serverKey] = newCount;
        }
        result.consecutiveFailures = newCount.integerValue;
        
        // 检查连续失败
        if (newCount.integerValue >= self.config.maxConsecutiveFailures) {
            NoaNetworkQualityException *exception = [[NoaNetworkQualityException alloc] init];
            exception.exceptionType = ZNetworkQualityExceptionTypeConsecutiveFailures;
            exception.exceptionDescription = [NSString stringWithFormat:@"连续失败: %ld次", (long)newCount.integerValue];
            exception.exceptionTimestamp = result.probeTimestamp;
            exception.relatedEndpoint = result.endpoint;
            exception.shouldTriggerRerace = YES;
            exception.isImmediateTrigger = NO;
            exception.triggerLevel = 1; // 当前连接级别
            exception.exceptionData = @{@"consecutiveCount": newCount};
            
            // 连续失败异常记录，但不立即触发重新竞速
            NSLog(@"[网络检测] 连续失败异常: %@", exception.exceptionDescription);
        }
    } else {
        // 重置连续失败计数
        @synchronized(self.consecutiveFailureCount) {
            self.consecutiveFailureCount[serverKey] = @0;
        }
        result.consecutiveFailures = 0;
    }
}

#pragma mark - 结果处理

- (void)handleProbeResults:(NSArray<NoaNetworkQualityResult *> *)results {
    NSLog(@"[网络检测] 处理检测结果，共 %lu 个结果", (unsigned long)results.count);
    
    // 对结果进行排序，最优的网络在前
    NSArray<NoaNetworkQualityResult *> *sortedResults = [self sortResultsByQuality:results];
    
    // 更新缓存
    @synchronized(self.qualityResultsCache) {
        for (NoaNetworkQualityResult *result in sortedResults) {
            NSString *key = [NSString stringWithFormat:@"%@:%d_%@", result.endpoint.ip, result.endpoint.port, result.probeType];
            self.qualityResultsCache[key] = result;
        }
    }
    
    // 检查所有服务器不可达并通知代理
    [self notifyDelegateWithResults];
}

/// 通知代理检测结果，并检查所有服务器不可达的情况
- (void)notifyDelegateWithResults {
    // 使用统一的数据源获取排序后的结果
    NSArray<NoaNetworkQualityResult *> *sortedResults = [self getSortedQualityResults];
    
    // 检查所有服务器不可达
    BOOL allServersUnreachable = YES;
    for (NoaNetworkQualityResult *result in sortedResults) {
        if (result.isAvailable) {
            allServersUnreachable = NO;
            break;
        }
    }
    
    if (allServersUnreachable && sortedResults.count > 0) {
        NSLog(@"[网络检测] 所有服务器不可达，调用检测失败回调");
        
        // 创建失败错误
        NSError *error = [NSError networkQualityErrorWithCode:ZNetworkQualityErrorCodeAllServersUnreachable
                                                  description:@"所有服务器不可达"
                                                failureReason:@"网络质量检测发现所有服务器都无法连接"
                                                      userInfo:@{@"serverCount": @(sortedResults.count)}];
        
        // 通知代理检测失败
        if ([self.delegate respondsToSelector:@selector(networkQualityDetector:didFailWithError:)]) {
            [self.delegate networkQualityDetector:self didFailWithError:error];
        }
        return; // 所有服务器不可达时，不调用检测完成回调
    }
    
    // 通知代理检测完成，传递排序后的结果（最优的在前面）
    if ([self.delegate respondsToSelector:@selector(networkQualityDetector:didCompleteProbeWithResults:)]) {
        [self.delegate networkQualityDetector:self didCompleteProbeWithResults:sortedResults];
    }
}

#pragma mark - 辅助方法

// Ping相关方法已移除，现在直接使用ECDH探测进行网络质量检测

/// 执行ECDH探测测试（包含TCP连接和密钥交换的网络质量检测）
- (BOOL)performTCPConnectionTest:(NSString *)hostname port:(int)port timeout:(NSTimeInterval)timeout {
    NSTimeInterval latency = [self getTCPConnectionLatency:hostname port:port timeout:timeout];
    return latency > 0;
}

/// 获取ECDH探测延迟（包含TCP连接和密钥交换的完整时间）
- (NSTimeInterval)getTCPConnectionLatency:(NSString *)hostname port:(int)port timeout:(NSTimeInterval)timeout {
    NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
    
    // 使用SDKCore提供的探测API，包含密钥交换检测
    uint16_t portValue = (uint16_t)port;
    
    // 创建信号量用于同步等待
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL testResult = NO;
    
    [[NoaIMSDKManager sharedTool] probeECDHConnectivityWithHost:hostname port:portValue timeout:timeout type:1 completion:^(BOOL success, LingIMSDKManagerProbeECDHConnectStatus status) {
        testResult = success;
        dispatch_semaphore_signal(semaphore);
    }];
    
    // 等待检测完成，最多等待timeout + 1秒
    dispatch_time_t waitTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)((timeout + 1.0) * NSEC_PER_SEC));
    dispatch_semaphore_wait(semaphore, waitTime);
    
    if (testResult) {
        NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval totalLatency = (endTime - startTime) * 1000; // 转换为毫秒
        NSLog(@"[网络检测] ECDH探测成功，延迟: %.1fms - %@:%d", totalLatency, hostname, port);
        return totalLatency;
    } else {
        NSLog(@"[网络检测] ECDH探测失败 - %@:%d", hostname, port);
        return 0;
    }
}

/// 对检测结果按质量进行排序，最优的网络在前，移除不可用的服务器
- (NSArray<NoaNetworkQualityResult *> *)sortResultsByQuality:(NSArray<NoaNetworkQualityResult *> *)results {
    // 首先过滤出可用的服务器
    NSArray<NoaNetworkQualityResult *> *availableResults = [results filteredArrayUsingPredicate:
        [NSPredicate predicateWithFormat:@"isAvailable == YES"]];
    
    if (availableResults.count == 0) {
        NSLog(@"[网络检测] 没有可用的服务器，返回空数组");
        return @[];
    }
    
    // 对可用的服务器按质量进行排序
    NSArray<NoaNetworkQualityResult *> *sortedResults = [availableResults sortedArrayUsingComparator:^NSComparisonResult(NoaNetworkQualityResult *obj1, NoaNetworkQualityResult *obj2) {
        
        // 第一优先级：质量评分（评分高的排在前面）
        if (obj1.qualityScore > obj2.qualityScore) {
            return NSOrderedAscending; // obj1 排在前面
        } else if (obj1.qualityScore < obj2.qualityScore) {
            return NSOrderedDescending; // obj2 排在前面
        }
        
        // 第二优先级：延迟（延迟低的排在前面）
        if (obj1.latency < obj2.latency) {
            return NSOrderedAscending; // obj1 排在前面
        } else if (obj1.latency > obj2.latency) {
            return NSOrderedDescending; // obj2 排在前面
        }
        
        // 第三优先级：连续失败次数（失败次数少的排在前面）
        if (obj1.consecutiveFailures < obj2.consecutiveFailures) {
            return NSOrderedAscending; // obj1 排在前面
        } else if (obj1.consecutiveFailures > obj2.consecutiveFailures) {
            return NSOrderedDescending; // obj2 排在前面
        }
        
        // 第四优先级：连续高延迟次数（高延迟次数少的排在前面）
        if (obj1.consecutiveHighLatency < obj2.consecutiveHighLatency) {
            return NSOrderedAscending; // obj1 排在前面
        } else if (obj1.consecutiveHighLatency > obj2.consecutiveHighLatency) {
            return NSOrderedDescending; // obj2 排在前面
        }
        
        
        return NSOrderedSame; // 相等
    }];
    
    // 输出排序后的结果
    NSLog(@"[网络检测] 网络质量排序结果 (仅显示可用服务器):");
    for (NSInteger i = 0; i < sortedResults.count; i++) {
        NoaNetworkQualityResult *result = sortedResults[i];
        NSLog(@"[网络检测] %ld. %@:%d (%@) - 评分:%ld, 延迟:%.1fms, 可用:%@, 连续失败:%ld, 连续高延迟:%ld",
              (long)(i + 1), result.endpoint.ip, result.endpoint.port, result.probeType,
              (long)result.qualityScore, result.latency, result.isAvailable ? @"是" : @"否",
              (long)result.consecutiveFailures, (long)result.consecutiveHighLatency);
    }
    
    return sortedResults;
}

- (NSInteger)calculateQualityScore:(NSString *)serverKey latency:(NSTimeInterval)latency success:(BOOL)success {
    // 实时模式：直接使用当前检测数据
    double avgLatency = latency;
    double successRate = success ? 1.0 : 0.0;
    double stability = 1.0; // 实时模式无法计算稳定性，设为最高值
    
    // 计算质量评分 (0-100)
    double latencyScore = MAX(0, 1.0 - avgLatency / self.config.maxAcceptableLatency);
    double successScore = successRate;
    double stabilityScore = stability;
    
    double totalScore = (latencyScore * self.config.latencyWeight +
                        successScore * self.config.successRateWeight +
                        stabilityScore * self.config.stabilityWeight) * 100;
    
    return (NSInteger)MIN(100, MAX(0, totalScore));
}

- (BOOL)isMonitoring {
    return self.monitorTimer != nil;
}

#pragma mark - 内存管理

- (void)dealloc {
    [self stopNetworkQualityDetection];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

#pragma mark - NoaNetworkQualityConfig Implementation

@implementation NoaNetworkQualityConfig

+ (instancetype)defaultConfig {
    NoaNetworkQualityConfig *config = [[NoaNetworkQualityConfig alloc] init];
    config.probeInterval = 30.0;                    // 30秒检测间隔
    config.tcpTimeout = kDefaultRaceTimeOut;        // TCP连接超时(使用tcp探测默认)
    config.maxRetryCount = 3;                      // 最大重试3次
    config.enableNetworkDetection = YES;           // 启用网络检测
    
    // 质量评分权重
    config.latencyWeight = 0.4;                    // 延迟权重40%
    config.successRateWeight = 0.4;                // 成功率权重40%
    config.stabilityWeight = 0.2;                  // 稳定性权重20%
    
    // 质量阈值
    config.maxAcceptableLatency = 600.0;           // 最大可接受延迟600ms
    config.minAcceptableSuccessRate = 0.8;         // 最小可接受成功率80%
    
    // 跳出条件配置
    config.maxConsecutiveHighLatency = 5;          // 最大连续高延迟次数
    config.maxConsecutiveFailures = 3;             // 最大连续失败次数
    config.latencySpikeThreshold = 1000.0;         // 延迟突增阈值1000ms
    config.maxPacketLossRate = 0.05;               // 最大丢包率5%
    
    return config;
}

@end

#pragma mark - NoaNetworkQualityResult Implementation

@implementation NoaNetworkQualityResult

- (NSString *)description {
    return [NSString stringWithFormat:@"<NoaNetworkQualityResult: %@:%d, 类型: %@, 延迟: %.1fms, 可用: %@, 评分: %ld, 连续失败: %ld, 连续高延迟: %ld>",
            self.endpoint.ip, self.endpoint.port, self.probeType, self.latency,
            self.isAvailable ? @"是" : @"否", (long)self.qualityScore, (long)self.consecutiveFailures, (long)self.consecutiveHighLatency];
}

@end

#pragma mark - NoaNetworkQualityException Implementation

@implementation NoaNetworkQualityException

- (NSString *)description {
    return [NSString stringWithFormat:@"<NoaNetworkQualityException: 类型: %ld, 描述: %@, 时间: %.0f, 触发重新竞速: %@, 立即触发: %@, 触发级别: %ld>",
            (long)self.exceptionType, self.exceptionDescription, self.exceptionTimestamp,
            self.shouldTriggerRerace ? @"是" : @"否", self.isImmediateTrigger ? @"是" : @"否", (long)self.triggerLevel];
}

@end

#pragma mark - NSError (NoaNetworkQualityDetector) Implementation

@implementation NSError (NoaNetworkQualityDetector)

+ (instancetype)networkQualityErrorWithCode:(ZNetworkQualityErrorCode)code
                               description:(NSString *)description
                               failureReason:(NSString *)failureReason
                               userInfo:(NSDictionary *)userInfo {
    NSMutableDictionary *errorUserInfo = [NSMutableDictionary dictionary];
    
    if (description) {
        errorUserInfo[NSLocalizedDescriptionKey] = description;
    }
    
    if (failureReason) {
        errorUserInfo[NSLocalizedFailureReasonErrorKey] = failureReason;
    }
    
    if (userInfo) {
        [errorUserInfo addEntriesFromDictionary:userInfo];
    }
    
    return [NSError errorWithDomain:@"NoaNetworkQualityDetector"
                               code:code
                           userInfo:errorUserInfo];
}

- (BOOL)isNetworkQualityError {
    return [self.domain isEqualToString:@"NoaNetworkQualityDetector"];
}

- (ZNetworkQualityErrorCode)networkQualityErrorCode {
    if (![self isNetworkQualityError]) {
        return -1; // 不是网络质量检测错误
    }
    
    return (ZNetworkQualityErrorCode)self.code;
}

@end
