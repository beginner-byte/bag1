//
//  NoaUrlHostManager.m
//  NoaKit
//
//  Created by Candy on 2023/2/8.
//

#import "NoaUrlHostManager.h"
#import "NoaToolManager.h"
#import "NoaCallManager.h"
#import "NoaRoleConfigModel.h"
#import "NoaRaceCheckErrorModel.h"
#import "LXChatEncrypt.h"
#import "AliyCloundDNSDecoder.h"
#import <pdns-sdk-ios/DNSResolver.h>
#import "NoaNodePreferTools.h"
#import "NoaProxySettings.h"
#import "ErrorCodeBuilder.h"
#import "NoaUrlHostModel.h"
#import "NoaFallbackEndpointStore.h"
#import "NoaNetworkQualityDetector.h"
#import <arpa/inet.h>
#import <fcntl.h>
#import <sys/socket.h>
#import <unistd.h>
#import <netdb.h>
#import "AesEncryptUtils.h"
#import <CommonCrypto/CommonDigest.h>

// GaOnchain
#import <GaOnchainLib/GaOnchainLib-Swift.h>

#define OSS_ERROR_MAX_NUM               5
#define OSS_INFO_FILE_NAME              @"edge.rtf"


static dispatch_once_t onceToken;

@interface NoaUrlHostManager() <ZNetworkQualityDetectorDelegate>

@property (nonatomic, strong) dispatch_source_t refreshSystemConfigTimer;   //刷新SystemConfig Time
@property (nonatomic, assign) NSInteger ossErrorNum;    //oss竞速失败次数
@property (nonatomic, assign) BOOL isUserPrimaryDomain;
@property (nonatomic, strong)NoaNodePreferTools *nodePreferTools;  //节点定时择优
@property (nonatomic, strong) ErrorCodeBuilder *codeBuilder; //错误码
@property (nonatomic, assign) BOOL isConnectCache;//是否有缓存链接
@property (nonatomic, copy) NSString *subModulesDNSCode;

/// HTTP域名管理
@property (nonatomic, strong) NSMutableArray <IMServerEndpoint *>*httpDomainList;

/// TCP域名管理
@property (nonatomic, strong) NSMutableArray <IMServerEndpoint *>*tcpDomainList;

/// 兜底导航存储
@property (nonatomic, strong) NoaFallbackEndpointStore *fallbackStore;

/// 网络质量检测器
@property (nonatomic, strong) NoaNetworkQualityDetector *networkQualityDetector;

/// 当前连接的服务器
@property (nonatomic, strong) IMServerEndpoint *currentConnectedServer;

/// 是否需要重新竞速（tcp网络质量检测失败，重新开始竞速时无外网）
@property (nonatomic, assign) BOOL isNeedReNode;

/// 后台计时器(用于记录进入后台多少秒后，再次进入前台时，重新开始竞速)
@property (nonatomic, strong) dispatch_source_t backgroundTimer;

/// 当前是否在后台
@property (nonatomic, assign) BOOL isInBackground;

/// 竞速会话管理
@property (nonatomic, assign) NSInteger currentRaceSessionId;
@property (nonatomic, assign) BOOL isRacing;
@property (nonatomic, strong) NSMutableArray<NSURLSessionDataTask *> *raceTasks;
/// 多源并发控制
@property (atomic, assign) BOOL ossFirstSuccessGlobal;
@property (atomic, assign) NSInteger multiSourceFinishedCount;
@property (atomic, assign) NSInteger multiSourceDirectFailCount;
@property (atomic, assign) NSInteger multiSourceTotalCount;
@property (atomic, assign) BOOL multiSourceActive;
/// 内置 OSS HTTP 对象兜底是否已尝试（避免失败回路重复进入）
@property (atomic, assign) BOOL builtInOssHttpFallbackTried;

/// 通知状态管理(通过此标记来确认是否需要移除通知，防止重复注册或重复移除)
@property (nonatomic, assign) BOOL isEcdhNotificationRegistered;

/// GaOnchain 请求
@property (nonatomic, strong) NoaGaOnchainManager *gaOnchainManager;

@end

@implementation NoaUrlHostManager

// MARK: - DNS 二进制编解码（A 记录）
static NSData *ZBuildDNSQueryA(NSString *domain, uint16_t txid) {
    // Header: 12 bytes
    uint8_t header[12] = {0};
    header[0] = (txid >> 8) & 0xFF; header[1] = txid & 0xFF; // ID
    header[2] = 0x01; header[3] = 0x00; // RD=1
    header[4] = 0x00; header[5] = 0x01; // QDCOUNT=1
    header[6] = 0; header[7] = 0;      // ANCOUNT=0
    header[8] = 0; header[9] = 0;      // NSCOUNT=0
    header[10] = 0; header[11] = 0;    // ARCOUNT=0
    
    NSMutableData *data = [NSMutableData dataWithBytes:header length:12];
    // QNAME
    NSArray<NSString *> *labels = [domain componentsSeparatedByString:@"."];
    for (NSString *label in labels) {
        if (label.length == 0) continue;
        uint8_t len = (uint8_t)MIN(label.length, 63);
        [data appendBytes:&len length:1];
        NSData *ld = [label substringToIndex:len].lowercaseString.UTF8String ? [NSData dataWithBytes:label.lowercaseString.UTF8String length:len] : [label.lowercaseString dataUsingEncoding:NSUTF8StringEncoding];
        if (ld) {
            // 直接写入 UTF8 的前 len 字节
            [data appendData:[[label.lowercaseString substringToIndex:len] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    uint8_t zero = 0; [data appendBytes:&zero length:1]; // end of QNAME
    // QTYPE=A(1), QCLASS=IN(1)
    uint8_t tail[4] = {0x00, 0x01, 0x00, 0x01};
    [data appendBytes:tail length:4];
    return data;
}

static NSArray<NSString *> *ZParseDNSResponseA(const uint8_t *buf, ssize_t len, uint16_t txid) {
    if (len < 12) return @[];
    uint16_t rid = (buf[0] << 8) | buf[1];
    if (rid != txid) return @[];
    uint8_t rcode = buf[3] & 0x0F; if (rcode != 0) return @[];
    uint16_t qd = (buf[4] << 8) | buf[5];
    uint16_t an = (buf[6] << 8) | buf[7];
    // skip question(s)
    ssize_t idx = 12;
    for (int i = 0; i < qd; i++) {
        // skip QNAME
        while (idx < len && buf[idx] != 0) {
            uint8_t l = buf[idx]; idx += 1 + l;
        }
        idx++; // zero
        idx += 4; // QTYPE+QCLASS
        if (idx > len) return @[];
    }
    NSMutableArray<NSString *> *ips = [NSMutableArray array];
    // answers
    for (int i = 0; i < an; i++) {
        if (idx + 12 > len) break;
        // skip NAME (could be pointer)
        if ((buf[idx] & 0xC0) == 0xC0) {
            idx += 2;
        } else {
            while (idx < len && buf[idx] != 0) { uint8_t l = buf[idx]; idx += 1 + l; }
            idx++;
        }
        if (idx + 10 > len) break;
        uint16_t type = (buf[idx] << 8) | buf[idx+1]; idx += 2;
        uint16_t _class = (buf[idx] << 8) | buf[idx+1]; idx += 2; (void)_class;
        idx += 4; // TTL
        uint16_t rdlen = (buf[idx] << 8) | buf[idx+1]; idx += 2;
        if (idx + rdlen > len) break;
        if (type == 1 && rdlen == 4) {
            char ip[INET_ADDRSTRLEN];
            struct in_addr a; memcpy(&a, buf + idx, 4);
            const char *s = inet_ntop(AF_INET, &a, ip, sizeof(ip));
            if (s) {
                [ips addObject:[NSString stringWithUTF8String:s]];
            }
        }
        idx += rdlen;
    }
    return ips;
}

- (NSArray<NSString *> *)aliyTXTChunksFromData:(NSString *)data {
    if (data.length <= 0) return @[];
    NSMutableArray<NSString *> *chunks = [NSMutableArray array];
    NSUInteger len = data.length;
    BOOL inQuote = NO;
    NSMutableString *current = [NSMutableString string];
    for (NSUInteger i = 0; i < len; i++) {
        unichar c = [data characterAtIndex:i];
        if (c == '"') {
            if (inQuote) {
                // 结束一个片段
                [chunks addObject:[current copy]];
                [current setString:@""];
                inQuote = NO;
            } else {
                inQuote = YES;
            }
        } else {
            if (inQuote) {
                [current appendFormat:@"%C", c];
            }
        }
    }
    if (chunks.count == 0) {
        NSString *trim = [data stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (trim.length > 0) {
            if ([trim hasPrefix:@"\""] && [trim hasSuffix:@"\""] && trim.length >= 2) {
                trim = [trim substringWithRange:NSMakeRange(1, trim.length - 2)];
            }
            return @[trim];
        }
    }
    return chunks;
}

- (NSMutableArray<IMServerEndpoint *> *)httpDomainList {
    if (!_httpDomainList) {
        _httpDomainList = [NSMutableArray new];
    }
    return _httpDomainList;
}

- (NSMutableArray<IMServerEndpoint *> *)tcpDomainList {
    if (!_tcpDomainList) {
        _tcpDomainList = [NSMutableArray new];
    }
    return _tcpDomainList;
}

- (NoaNetworkQualityDetector *)networkQualityDetector {
    if (!_networkQualityDetector) {
        _networkQualityDetector = [NoaNetworkQualityDetector sharedDetector];
        _networkQualityDetector.delegate = self;
    }
    return _networkQualityDetector;
}

- (NSMutableArray<NSURLSessionDataTask *> *)raceTasks {
    if (!_raceTasks) {
        _raceTasks = [NSMutableArray new];
    }
    return _raceTasks;
}

- (void)setApiHost:(NSString *)apiHost {
    if (!apiHost) {
        return;
    }
    _apiHost = apiHost;
    
    WeakSelf
    // 3秒后立即执行一次(原因:tcp连接大概在1s后，减少失败概率)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf requestTimedRefreshSystemConfigInfo];
    });
}

#pragma mark - 单例的实现
+ (instancetype)shareManager{
    static NoaUrlHostManager *_manager = nil;
    dispatch_once(&onceToken, ^{
        //不能再使用alloc方法
        //因为已经重写了allocWithZone方法，所以这里要调用父类的分配空间的方法
        _manager = [[super allocWithZone:NULL] init];
        //默认的 域名、端口号
        _manager.apiHost = @"";
        _manager.getFileHost = @"";
        _manager.uploadfileHost = @"";
        //启动定时器每5分钟刷新一次systemConfig
        [_manager refreshSystemConfig];
        
        _manager.ossErrorNum = 0;
        
        _manager.isNeedReNode = NO;
        
        // 初始化兜底存储
        _manager.fallbackStore = [NoaFallbackEndpointStore shared];
        
        // 配置前后台通知监听
        [_manager configureNotification];
        
    });
    return _manager;
}
// 防止外部调用alloc 或者 new
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [NoaUrlHostManager shareManager];
}

// 防止外部调用copy
- (id)copyWithZone:(nullable NSZone *)zone {
    return [NoaUrlHostManager shareManager];
}

// 防止外部调用mutableCopy
- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [NoaUrlHostManager shareManager];
}
#pragma mark - 单例一般不需要清空，但是在执行某些功能的时候，防止数据清空不及时可以清空一下
- (void)clearManager{
    // 移除通知观察者
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // 取消后台计时器
    if (self.backgroundTimer) {
        dispatch_source_cancel(self.backgroundTimer);
        self.backgroundTimer = nil;
    }
    
    onceToken = 0;
}

#pragma mark - 监听
- (void)configureNotification {
    // 监听应用进入后台
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    // 监听应用进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkChange:)
                                                 name:NetWorkStatusManager.NetworkStatusChangedNotification
                                               object:nil];
    
    
    SOCKETMANAGER.hasOptimalServerAvailableBlock = ^BOOL{
        IMServerEndpoint *optimalServer = [self.networkQualityDetector getOptimalServer];
        return (optimalServer && optimalServer.ip && optimalServer.ip.length > 0 && optimalServer.port > 0);
    };
    
    SOCKETMANAGER.getOptimalServerInfoBlock = ^NSDictionary * _Nullable{
        IMServerEndpoint *optimalServer = [self.networkQualityDetector getOptimalServer];
        if (!optimalServer || !optimalServer.ip || optimalServer.ip.length == 0 || optimalServer.port <= 0) {
            return nil;
        }
        
        return @{
            @"ip": optimalServer.ip,
            @"port": @(optimalServer.port)
        };
    };
}

#pragma mark - ECDH 通知管理
/// 注册通知-ecdh交换成功通知
- (void)addEcdhNotification {
    // 使用标志位防止重复注册，如果未注册，则执行注册，如果已注册，则跳过
    if (self.isEcdhNotificationRegistered) {
        CIMLog(@"[ECDH通知] 通知已注册，跳过重复注册");
        return;
    }
    
    CIMLog(@"[ECDH通知] 注册 ECDH 通知监听");
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestSystemConfigInfo)
                                                 name:@"socketECDHDidConnectSuccese"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(systemConfigFailure)
                                                 name:@"socketECDHDidConnectFailure"
                                               object:nil];
    
    // 标记已注册
    self.isEcdhNotificationRegistered = YES;
}

/**
 * 移除 ECDH 通知
 * 使用标志位防止重复移除，只有已注册时才执行移除
 */
- (void)removeEcdhNotification {
    // 使用标志位防止重复移除
    if (!self.isEcdhNotificationRegistered) {
        CIMLog(@"[ECDH通知] 通知未注册，跳过移除");
        return;
    }
    
    CIMLog(@"[ECDH通知] 移除 ECDH 通知监听");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"socketECDHDidConnectSuccese" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"socketECDHDidConnectFailure" object:nil];
    
    // 标记已移除
    self.isEcdhNotificationRegistered = NO;
}

#pragma mark - 对oss、http、tcp进行择优或者检查IP/Domain是否可用
- (void)startHostNodeRace {
    [self.codeBuilder clearInitializationErrorType];
    self.subModulesDNSCode = @"0";
    self.builtInOssHttpFallbackTried = NO;
    [self clearCerData];
    NoaSsoInfoModel *ssoModel = [NoaSsoInfoModel getSSOInfo];
    if (ssoModel == nil || (ssoModel.liceseId.length <= 0 && ssoModel.ipDomainPortStr.length <= 0)) {
        self.racingType = ZReacingTypeNone;
        [ZTOOL setupSsoSetVcUI];
        return;
    }
    if ([ZTOOL isNetworkAvailable]) {
        // 添加监听
        [self addEcdhNotification];
        
        [self hostNodeRace];
    } else {
        [self.codeBuilder withInitializationSubModule:@"00"];
        [self.codeBuilder withInitializationErrorType:[InitializationErrorTypes OSS_FAILURE]];
        [self packageRacingResultWithStep:ZNetRacingStepOss result:NO racingCode:10000 isNetworkQualityTrigger:NO];
    }
}

- (void)QRcodeSacnNav:(IMServerListResponseBody *)serverResponse {
    [HUD showActivityMessage:@""];
    if ([ZTOOL isNetworkAvailable]) {
        // 添加监听
        [self addEcdhNotification];
        
        // 同步服务器兜底导航到本地缓存
        if (serverResponse.hasFallbackEndpoints && serverResponse.fallbackEndpoints) {
            FallbackEndpoints *fb = serverResponse.fallbackEndpoints;
            NSArray<NSString *> *srvDomestic = fb.domesticArray ? [fb.domesticArray copy] : @[];
            NSArray<NSString *> *srvOverseas = fb.overseasArray ? [fb.overseasArray copy] : @[];
            BOOL needUpdateDomestic = (srvDomestic.count > 0) && ![srvDomestic isEqualToArray:self.fallbackStore.domesticUrls];
            BOOL needUpdateOverseas = (srvOverseas.count > 0) && ![srvOverseas isEqualToArray:self.fallbackStore.overseasUrls];
            if (needUpdateDomestic || needUpdateOverseas) {
                [self.fallbackStore updateIfDifferentDomestic:srvDomestic overseas:srvOverseas];
            }
        }
        
        // 同步服务器下发的 Sentry DSN
        if (serverResponse.meta && serverResponse.meta.config.sentryUrlsArray.firstObject.length > 0) {
            NSString *newDSN = serverResponse.meta.config.sentryUrlsArray.firstObject;
        }
        
        // 同步服务器下发的 Logan
        if (serverResponse.meta && serverResponse.meta.config.loganUrlsArray.firstObject.length > 0) {
            NSString *newLoganURL = serverResponse.meta.config.loganUrlsArray.firstObject;
            [ZTOOL reloadLoganIfNeededWithPublishURL:newLoganURL];
        }
        
        
        NSMutableArray <IMServerEndpoint *>* tcpEndPointArray = [NSMutableArray new];
        NSMutableArray <IMServerEndpoint *>* httpEndPointArray = [NSMutableArray new];
        
        [serverResponse.imEndpointsArray enumerateObjectsUsingBlock:^(IMServerEndpoint * _Nonnull endpoint, NSUInteger idx, BOOL * _Nonnull stop) {
            // 因为存在tcp、http同时存在的类，所以不能用if...else...去判断
            
            if ([endpoint.status isEqualToString:@"INACTIVE"]) {
                // 不可用的不保存
                return;
            }
            
            // 过滤出支持tcp的
            if ([endpoint.protocolsArray containsObject:@"tcp"]) {
                [tcpEndPointArray addObject:endpoint];
            }
            
            // 过滤出支持http的
            if ([endpoint.protocolsArray containsObject:@"http"]) {
                [httpEndPointArray addObject:endpoint];
            }
        }];
        
        self.tcpDomainList = [tcpEndPointArray mutableCopy];
        self.httpDomainList = [httpEndPointArray mutableCopy];
        NoaSsoInfoModel *ssoModel = [NoaSsoInfoModel getSSOInfo];
        // 启动网络质量检测
        if (serverResponse.meta.config.enableNetworkDetect) {
            // 配置已开启网络质量检测
            [self.networkQualityDetector setEnableDetection:YES];
            [self startNetworkQualityDetection:ssoModel.liceseId];
        }else {
            // 配置未开启网络质量检测
            [self.networkQualityDetector setEnableDetection:NO];
            [self stopNetworkQualityDetection];
        }
        
        NSMutableArray <NoaNetRacingItemModel *>* tcpArray = [NSMutableArray new];
        NSMutableArray <NoaNetRacingItemModel *>* httpArray = [NSMutableArray new];
        [tcpEndPointArray enumerateObjectsUsingBlock:^(IMServerEndpoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NoaNetRacingItemModel *model = [NoaNetRacingItemModel new];
            model.ip = obj.ip;
            model.sort = obj.port;
            [tcpArray addObject:model];
        }];
        
        [httpEndPointArray enumerateObjectsUsingBlock:^(IMServerEndpoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NoaNetRacingItemModel *model = [NoaNetRacingItemModel new];
            model.ip = [NSString stringWithFormat:@"%@:%d",obj.ip,obj.port];
            model.sort = obj.port;
            [httpArray addObject:model];
        }];
        
        if (tcpArray.count == 0 || httpArray.count == 0) {
            [self.codeBuilder withInitializationErrorType:[InitializationErrorTypes OSS_FAILURE]];
            [self packageRacingResultWithStep:ZNetRacingStepOss result:NO racingCode:10000 isNetworkQualityTrigger:NO];
            return;
        }
        NoaNetRacingModel *racingModel = [[NoaNetRacingModel alloc] init];
        
        racingModel.httpArr = httpArray;
        racingModel.tcpArr = tcpArray;
        ssoModel.ossRacingModel = racingModel;
        [ssoModel saveSSOInfo];
        [ssoModel saveSSOInfoWithLiceseId:ssoModel.liceseId];
        //存储证书data
        self.cerData = racingModel.cerData;
        self.p12Data = racingModel.p12Data;
        self.p12pwd = [NSString getHttpsCerPassword];
        
        //core层
        IMSDKHTTPTOOL.cerData = racingModel.cerData;
        IMSDKHTTPTOOL.p12Data = racingModel.p12Data;
        IMSDKHTTPTOOL.p12pwd = [NSString getHttpsCerPassword];
        [self.codeBuilder withInitializationSubModule:[NSString stringWithFormat:@"%@0",self.subModulesDNSCode]];
        //对http进行竞速
        [self netWorkFiltrateBestHttpRacingWithList:racingModel isNetworkQualityTrigger:NO];
    } else {
        [self.codeBuilder withInitializationSubModule:@"00"];
        [self.codeBuilder withInitializationErrorType:[InitializationErrorTypes OSS_FAILURE]];
        [self packageRacingResultWithStep:ZNetRacingStepOss result:NO racingCode:10000 isNetworkQualityTrigger:NO];
    }
}

- (void)clearCerData {
    self.cerData = nil;
    self.p12Data = nil;
    self.p12pwd = @"";
    self.ossInfoAppKey = @"";
    IMSDKHTTPTOOL.cerData = nil;
    IMSDKHTTPTOOL.p12Data = nil;
    IMSDKHTTPTOOL.p12pwd = @"";
}

- (void)hostNodeRace {
    [self hostNodeRaceWithNetworkQualityTrigger:NO];
}

- (void)hostNodeRaceWithNetworkQuality {
    [self hostNodeRaceWithNetworkQualityTrigger:YES];
}

/// 开启竞速；启动或手动竞速优先于网络质量检测，避免首屏导航流程被重复竞速抢占。
/// - Parameter isNetworkQualityTrigger: 是否是网络质量检测处理(网络监测失败不提示、不跳转)
- (void)hostNodeRaceWithNetworkQualityTrigger:(BOOL)isNetworkQualityTrigger {
    // 主竞速仍在进行时忽略质量检测触发，防止负责首屏跳转的竞速被取消后永远停在启动页。
    if (isNetworkQualityTrigger && self.isRacing) {
        CIMLog(@"[竞速会话] 主竞速进行中，忽略网络质量重复竞速");
        return;
    }
    // 启动新一轮前，停止上一轮：取消HTTP任务，重置标记（不调用网络质量检测停止）
    self.currentRaceSessionId += 1;
    self.isRacing = YES;
    if (self.raceTasks.count > 0) {
        CIMLog(@"[竞速会话] 取消上轮HTTP任务数量: %lu", (unsigned long)self.raceTasks.count);
        for (NSURLSessionDataTask *task in self.raceTasks) {
            if (task && task.state == NSURLSessionTaskStateRunning) {
                [task cancel];
            }
        }
        [self.raceTasks removeAllObjects];
    }
    //拿到本地保存的LecseID或者ip、domain、port
    NoaSsoInfoModel *ssoModel = [NoaSsoInfoModel getSSOInfo];
    if (ssoModel == nil || (ssoModel.liceseId.length <= 0 && ssoModel.ipDomainPortStr.length <= 0)) {
        self.racingType = ZReacingTypeNone;
        // 移除通知，避免通知泄漏
        [self removeEcdhNotification];
        if (isNetworkQualityTrigger) {
            return;
        }
        [ZTOOL setupSsoSetVcUI];
        return;
    }
    
    if (![NSString isNil:ssoModel.liceseId]) {
        return [self startCompanyIdRaceWithLicenseId:ssoModel.liceseId networkQualityTrigger:isNetworkQualityTrigger];
    }else {
        
        // 非邀请码，不走竞速，需要将线路择优移除，否则会出现ip地址连接不上
        [self stopNetworkQualityDetection];
    }
    
    if (![NSString isNil:ssoModel.ipDomainPortStr]) {
        // IP/Doamin 对http、tcp的连通性进行检查
        self.racingType = ZReacingTypeIpDomain;
        [self ipDomainPortConnectCheckWithIpDomainPort:ssoModel.ipDomainPortStr isNetworkQualityTrigger:isNetworkQualityTrigger];
        return;
    }
    
    // 移除通知，避免通知泄漏
    [self removeEcdhNotification];
}

// 腾讯 DoH AAAA（JSON API）
- (void)getDirectOssUrlListFromTencentDoHAAAAComplete:(void(^)(NSArray<NoaUrlHostModel *> *ossUrlList))complete {
    __block BOOL finished = NO;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSMutableSet *contentTypes = [NSMutableSet setWithSet:manager.responseSerializer.acceptableContentTypes];
    [contentTypes addObject:@"application/dns-json"];
    manager.responseSerializer.acceptableContentTypes = contentTypes;
    [manager.requestSerializer setValue:@"application/dns-json" forHTTPHeaderField:@"accept"];
    manager.requestSerializer.timeoutInterval = 5.0;
    
    // 超时保护
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!finished) { finished = YES; if (complete) complete(@[]); }
    });
    
    NSArray<NSString *> *bases = @[@"https://doh.pub/dns-query", @"https://dns.pub/dns-query"];
    NSString *domain = TENCENT_HTTPDNS_TEST_DOMAIN;
    __block NSInteger idx = 0;
    __weak typeof(self) weakSelf = self;
    __block void (^requestNext)(void);
    __weak typeof(requestNext) weakRequestNext = nil;
    requestNext = ^{
        if (finished || idx >= bases.count) { if (!finished) { finished = YES; if (complete) complete(@[]); } return; }
        NSString *base = bases[idx++];
        NSString *url = [NSString stringWithFormat:@"%@?name=%@&type=AAAA", base, domain];
        NSURLSessionDataTask *task = [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSMutableArray<NoaUrlHostModel *> *list = [NSMutableArray array];
            NSMutableArray *dataList = [NSMutableArray array];
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSArray *answers = ((NSDictionary *)responseObject)[@"Answer"];
                if ([answers isKindOfClass:[NSArray class]]) {
                    for (NSDictionary *ans in answers) {
                        if (![ans isKindOfClass:[NSDictionary class]]) continue;
                        NSString *data = ans[@"data"]; if (![data isKindOfClass:[NSString class]] || data.length <= 0) continue;
                        [dataList addObject:data];
                    }
                }
            }
            NSString *analysisDomain = [AliyCloundDNSDecoder v6ToString:dataList];
            NSData *jdata = [analysisDomain dataUsingEncoding:NSUTF8StringEncoding];
            NSError *jerr = nil;
            id jobj = [NSJSONSerialization JSONObjectWithData:jdata options:0 error:&jerr];
            if (!jerr && [jobj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = (NSDictionary *)jobj;
                id portsVal = dict[@"1"]; // 端口数组
                id hostsVal = dict[@"2"]; // IP/域名数组
                if ([hostsVal isKindOfClass:[NSArray class]]) {
                    NSArray *hosts = (NSArray *)hostsVal;
                    BOOL hasPorts = [portsVal isKindOfClass:[NSArray class]] && [(NSArray *)portsVal count] > 0;
                    NSArray *ports = hasPorts ? (NSArray *)portsVal : @[];
                    for (id hostObj in hosts) {
                        if (![hostObj isKindOfClass:[NSString class]]) continue;
                        NSString *host = [(NSString *)hostObj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        if (host.length <= 0) continue;
                        if (!hasPorts) {
                            // 没有端口数组，直接加入 host
                            NSString *typeStr = list.count == 0 ? @"1" : @"2";
                            [list addObject:[weakSelf getUrlHostModelWithUrl:host type:typeStr]];
                            continue;
                        }
                        for (id portObj in ports) {
                            NSString *portStr = nil;
                            if ([portObj isKindOfClass:[NSString class]]) {
                                portStr = (NSString *)portObj;
                            } else if ([portObj respondsToSelector:@selector(stringValue)]) {
                                portStr = [portObj stringValue];
                            }
                            if (portStr.length <= 0) continue;
                            NSInteger pnum = [portStr integerValue];
                            if (pnum <= 0 || pnum > 65535) continue;
                            NSString *combo = [NSString stringWithFormat:@"%@:%@", host, portStr];
                            NSString *typeStr = list.count == 0 ? @"1" : @"2";
                            [list addObject:[weakSelf getUrlHostModelWithUrl:combo type:typeStr]];
                        }
                    }
                }
            } else {
                CIMLog(@"[ALIDNS] JSON解析失败: %@", jerr.localizedDescription);
            }
            if (list.count > 0) {
                if (!finished) { finished = YES; if (complete) complete(list); }
            } else {
                if (weakRequestNext) weakRequestNext();
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (weakRequestNext) weakRequestNext();
        }];
        if (task) { [weakSelf.raceTasks addObject:task]; }
    };
    weakRequestNext = requestNext;
    requestNext();
}

// Cloudflare DoH TXT 解析
- (void)getDirectOssUrlListFromCloudflareTXTComplete:(void(^)(NSArray<NoaUrlHostModel *> *ossUrlList))complete {
    __block BOOL finished = NO;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSMutableSet *contentTypes = [NSMutableSet setWithSet:manager.responseSerializer.acceptableContentTypes];
    [contentTypes addObject:@"application/dns-json"];
    manager.responseSerializer.acceptableContentTypes = contentTypes;
    [manager.requestSerializer setValue:@"application/dns-json" forHTTPHeaderField:@"accept"];
    manager.requestSerializer.timeoutInterval = 5.0;
    
    // 超时保护
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!finished) { finished = YES; if (complete) complete(@[]); }
    });
    
    NSString *txtUrl = [NSString stringWithFormat:@"%@?name=%@&type=TXT", CF_DOH_BASE_URL, cf_test_domain];
    NSURLSessionDataTask *taskTXT = [manager GET:txtUrl parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableArray<NoaUrlHostModel *> *list = [NSMutableArray array];
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSArray *answers = ((NSDictionary *)responseObject)[@"Answer"];
            if ([answers isKindOfClass:[NSArray class]]) {
                for (NSDictionary *ans in answers) {
                    if (![ans isKindOfClass:[NSDictionary class]]) continue;
                    NSString *data = ans[@"data"];
                    if (![data isKindOfClass:[NSString class]] || data.length <= 0) continue;
                    // TXT 可能由多个引号片段组成，需拼接为完整 base64 再解密
                    NSArray<NSString *> *chunks = [self aliyTXTChunksFromData:data];
                    NSString *cipher = (chunks.count > 0) ? [chunks componentsJoinedByString:@""] : @"";
                    if (cipher.length <= 0) continue;
                    // 解密 JSON {"1":[ports],"2":[hosts]}
                    NSString *dec = [AesEncryptUtils decrypt:cipher secret:txt_decrypt_key];
                    if (dec.length <= 0) continue;
                    NSData *jdata = [dec dataUsingEncoding:NSUTF8StringEncoding];
                    NSError *jerr = nil;
                    id jobj = [NSJSONSerialization JSONObjectWithData:jdata options:0 error:&jerr];
                    if (jerr || ![jobj isKindOfClass:[NSDictionary class]]) { continue; }
                    NSDictionary *dict = (NSDictionary *)jobj;
                    id portsVal = dict[@"1"]; id hostsVal = dict[@"2"];
                    if (![hostsVal isKindOfClass:[NSArray class]]) continue;
                    NSArray *hosts = (NSArray *)hostsVal;
                    BOOL hasPorts = [portsVal isKindOfClass:[NSArray class]] && [(NSArray *)portsVal count] > 0;
                    NSArray *ports = hasPorts ? (NSArray *)portsVal : @[];
                    for (id hostObj in hosts) {
                        if (![hostObj isKindOfClass:[NSString class]]) continue;
                        NSString *host = [(NSString *)hostObj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        if (host.length <= 0) continue;
                        if (!hasPorts) {
                            NSString *typeStr = list.count == 0 ? @"1" : @"2";
                            [list addObject:[self getUrlHostModelWithUrl:host type:typeStr]]; continue;
                        }
                        for (id portObj in ports) {
                            NSString *portStr = nil;
                            if ([portObj isKindOfClass:[NSString class]]) portStr = (NSString *)portObj; else if ([portObj respondsToSelector:@selector(stringValue)]) portStr = [portObj stringValue];
                            if (portStr.length <= 0) continue; NSInteger pnum = [portStr integerValue]; if (pnum <= 0 || pnum > 65535) continue;
                            NSString *combo = [NSString stringWithFormat:@"%@:%@", host, portStr];
                            NSString *typeStr = list.count == 0 ? @"1" : @"2";
                            [list addObject:[self getUrlHostModelWithUrl:combo type:typeStr]];
                        }
                    }
                }
            }
        }
        if (!finished) { finished = YES; if (complete) complete(list); }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (!finished) { finished = YES; if (complete) complete(@[]); }
    }];
    if (taskTXT) { [self.raceTasks addObject:taskTXT]; }
}

// Cloudflare DoH AAAA 解析
- (void)getDirectOssUrlListFromCloudflareAAAAComplete:(void(^)(NSArray<NoaUrlHostModel *> *ossUrlList))complete {
    __block BOOL finished = NO;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSMutableSet *contentTypes = [NSMutableSet setWithSet:manager.responseSerializer.acceptableContentTypes];
    [contentTypes addObject:@"application/dns-json"];
    manager.responseSerializer.acceptableContentTypes = contentTypes;
    [manager.requestSerializer setValue:@"application/dns-json" forHTTPHeaderField:@"accept"];
    manager.requestSerializer.timeoutInterval = 5.0;
    
    // 超时保护
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!finished) { finished = YES; if (complete) complete(@[]); }
    });
    __weak typeof(self) weakSelf = self;
    NSString *aaaaUrl = [NSString stringWithFormat:@"%@?name=%@&type=AAAA", CF_DOH_BASE_URL, cf_test_domain];
    NSURLSessionDataTask *taskAAAA = [manager GET:aaaaUrl parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableArray<NoaUrlHostModel *> *list = [NSMutableArray array];
        NSMutableArray *dataList = [NSMutableArray array];
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSArray *answers = ((NSDictionary *)responseObject)[@"Answer"];
            if ([answers isKindOfClass:[NSArray class]]) {
                for (NSDictionary *ans in answers) {
                    if (![ans isKindOfClass:[NSDictionary class]]) continue;
                    NSString *data = ans[@"data"]; if (![data isKindOfClass:[NSString class]] || data.length <= 0) continue;
                    [dataList addObject:data];
                }
            }
        }
        NSString *analysisDomain = [AliyCloundDNSDecoder v6ToString:dataList];
        NSData *jdata = [analysisDomain dataUsingEncoding:NSUTF8StringEncoding];
        NSError *jerr = nil;
        id jobj = [NSJSONSerialization JSONObjectWithData:jdata options:0 error:&jerr];
        if (!jerr && [jobj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)jobj;
            id portsVal = dict[@"1"]; // 端口数组
            id hostsVal = dict[@"2"]; // IP/域名数组
            if ([hostsVal isKindOfClass:[NSArray class]]) {
                NSArray *hosts = (NSArray *)hostsVal;
                BOOL hasPorts = [portsVal isKindOfClass:[NSArray class]] && [(NSArray *)portsVal count] > 0;
                NSArray *ports = hasPorts ? (NSArray *)portsVal : @[];
                for (id hostObj in hosts) {
                    if (![hostObj isKindOfClass:[NSString class]]) continue;
                    NSString *host = [(NSString *)hostObj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if (host.length <= 0) continue;
                    if (!hasPorts) {
                        // 没有端口数组，直接加入 host
                        NSString *typeStr = list.count == 0 ? @"1" : @"2";
                        [list addObject:[weakSelf getUrlHostModelWithUrl:host type:typeStr]];
                        continue;
                    }
                    for (id portObj in ports) {
                        NSString *portStr = nil;
                        if ([portObj isKindOfClass:[NSString class]]) {
                            portStr = (NSString *)portObj;
                        } else if ([portObj respondsToSelector:@selector(stringValue)]) {
                            portStr = [portObj stringValue];
                        }
                        if (portStr.length <= 0) continue;
                        NSInteger pnum = [portStr integerValue];
                        if (pnum <= 0 || pnum > 65535) continue;
                        NSString *combo = [NSString stringWithFormat:@"%@:%@", host, portStr];
                        NSString *typeStr = list.count == 0 ? @"1" : @"2";
                        [list addObject:[weakSelf getUrlHostModelWithUrl:combo type:typeStr]];
                    }
                }
            }
        } else {
            CIMLog(@"[ALIDNS] JSON解析失败: %@", jerr.localizedDescription);
        }
        if (!finished) { finished = YES; if (complete) complete(list); }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (!finished) { finished = YES; if (complete) complete(@[]); }
    }];
    if (taskAAAA) { [self.raceTasks addObject:taskAAAA]; }
}

// 计算 SHA256 十六进制字符串
static inline NSString *Z_SHA256Hex(NSString *input) {
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
    NSMutableString *hex = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [hex appendFormat:@"%02x", digest[i]];
    }
    return hex;
}

// 阿里 DoH TXT（JSON API）
- (void)getDirectOssUrlListFromAliDoHTXTComplete:(void(^)(NSArray<NoaUrlHostModel *> *ossUrlList))complete {
    __block BOOL finished = NO;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSMutableSet *contentTypes = [NSMutableSet setWithSet:manager.responseSerializer.acceptableContentTypes];
    [contentTypes addObject:@"application/dns-json"];
    manager.responseSerializer.acceptableContentTypes = contentTypes;
    [manager.requestSerializer setValue:@"application/dns-json" forHTTPHeaderField:@"accept"];
    manager.requestSerializer.timeoutInterval = 5.0;
    
    // 超时保护
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!finished) { finished = YES; if (complete) complete(@[]); }
    });
    
    // 组装签名参数（使用 NoaMacroHeader.h 中统一的阿里 HttpDNS 配置）
    NSString *uid = ali_account_id;
    NSString *ak  = ali_key_id;
    NSString *secret = ali_key_secret;
    NSString *qname = ali_test_domain;
    NSString *ts = [NSString stringWithFormat:@"%lld", (long long)[[NSDate date] timeIntervalSince1970]];
    NSString *sigSrc = [NSString stringWithFormat:@"%@%@%@%@%@", uid, secret, ts, qname, ak];
    NSString *keyHex = Z_SHA256Hex(sigSrc);
    
    NSArray<NSString *> *bases = @[@"https://223.5.5.5/resolve", @"https://223.6.6.6/resolve"];
    __block NSInteger idx = 0;
    __weak typeof(self) weakSelf2 = self;
    __block void (^requestNext)(void);
    __weak typeof(requestNext) weakRequestNext = nil;
    requestNext = ^{
        if (finished || idx >= bases.count) { if (!finished) { finished = YES; if (complete) complete(@[]); } return; }
        NSString *base = bases[idx++];
        NSString *url = [NSString stringWithFormat:@"%@?name=%@&type=TXT&uid=%@&ak=%@&ts=%@&key=%@", base, qname, uid, ak, ts, keyHex];
        NSURLSessionDataTask *task = [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSMutableArray<NoaUrlHostModel *> *list = [NSMutableArray array];
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSArray *answers = ((NSDictionary *)responseObject)[@"Answer"];
                if ([answers isKindOfClass:[NSArray class]]) {
                    for (NSDictionary *ans in answers) {
                        if (![ans isKindOfClass:[NSDictionary class]]) continue;
                        NSString *data = ans[@"data"]; if (![data isKindOfClass:[NSString class]] || data.length <= 0) continue;
                        // TXT 可能被分段为多个引号包裹的片段，需要提取每段并拼接为一个base64串
                        NSArray<NSString *> *chunks = [self aliyTXTChunksFromData:data];
                        NSString *cipher = (chunks.count > 0) ? [chunks componentsJoinedByString:@""] : @"";
                        if (cipher.length <= 0) continue;
                        NSString *dec = [AesEncryptUtils decrypt:cipher secret:txt_decrypt_key];
                        if (dec.length <= 0) continue;
                        NSData *jdata = [dec dataUsingEncoding:NSUTF8StringEncoding];
                        NSError *jerr = nil; id jobj = [NSJSONSerialization JSONObjectWithData:jdata options:0 error:&jerr];
                        if (jerr || ![jobj isKindOfClass:[NSDictionary class]]) continue;
                        NSDictionary *dict = (NSDictionary *)jobj;
                        id portsVal = dict[@"1"]; id hostsVal = dict[@"2"];
                        if (![hostsVal isKindOfClass:[NSArray class]]) continue;
                        NSArray *hosts = (NSArray *)hostsVal;
                        BOOL hasPorts = [portsVal isKindOfClass:[NSArray class]] && [(NSArray *)portsVal count] > 0;
                        NSArray *ports = hasPorts ? (NSArray *)portsVal : @[];
                        for (id hostObj in hosts) {
                            if (![hostObj isKindOfClass:[NSString class]]) continue;
                            NSString *host = [(NSString *)hostObj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            if (host.length <= 0) continue;
                            if (!hasPorts) {
                                NSString *typeStr = list.count == 0 ? @"1" : @"2";
                                [list addObject:[weakSelf2 getUrlHostModelWithUrl:host type:typeStr]]; continue;
                            }
                            for (id portObj in ports) {
                                NSString *portStr = nil;
                                if ([portObj isKindOfClass:[NSString class]]) portStr = (NSString *)portObj; else if ([portObj respondsToSelector:@selector(stringValue)]) portStr = [portObj stringValue];
                                if (portStr.length <= 0) continue; NSInteger pnum = [portStr integerValue]; if (pnum <= 0 || pnum > 65535) continue;
                                NSString *combo = [NSString stringWithFormat:@"%@:%@", host, portStr];
                                NSString *typeStr = list.count == 0 ? @"1" : @"2";
                                [list addObject:[weakSelf2 getUrlHostModelWithUrl:combo type:typeStr]];
                            }
                        }
                    }
                }
            }
            if (list.count > 0) {
                if (!finished) { finished = YES; if (complete) complete(list); }
            } else {
                // 尝试下一个基地址
                if (weakRequestNext) weakRequestNext();
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // 尝试下一个基地址
            if (weakRequestNext) weakRequestNext();
        }];
        if (task) { [weakSelf2.raceTasks addObject:task]; }
    };
    weakRequestNext = requestNext;
    requestNext();
}

// 阿里resolver dns
- (void)getDirectOssUrlListFromALIDNSComplete:(void(^)(NSArray<NoaUrlHostModel *> *ossUrlList))complete {
    DNSResolver *resolver = [DNSResolver share];
    [resolver setAccountId:ali_account_id andAccessKeyId:ali_key_id andAccesskeySecret:ali_key_secret];
    resolver.cacheEnable = NO;
    resolver.scheme = DNSResolverSchemeHttp;
    [[DNSResolver share] clearHostCache:nil];
    [[DNSResolver share] clearHostCache:nil];
    __block NSMutableArray<NoaUrlHostModel *> *ossUrlList = [NSMutableArray array];
    WeakSelf
    [[DNSResolver share] getIpv6DataWithDomain:ali_test_domain complete:^(NSArray<NSString *> *dataArray) {
        BOOL analysisResult = NO;
        NSString *analysisDomain = @"";
        NSMutableArray *ipV6List = [NSMutableArray array];
        if (dataArray != nil && dataArray.count > 0) {
            for (NSString *domainInfoStr in dataArray) {
                [ipV6List addObject:domainInfoStr];
            }
            analysisDomain = [AliyCloundDNSDecoder v6ToString:ipV6List];
            if (![NSString isNil:analysisDomain]) {
                analysisResult = YES;
                NSData *jdata = [analysisDomain dataUsingEncoding:NSUTF8StringEncoding];
                NSError *jerr = nil;
                id jobj = [NSJSONSerialization JSONObjectWithData:jdata options:0 error:&jerr];
                if (!jerr && [jobj isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dict = (NSDictionary *)jobj;
                    id portsVal = dict[@"1"]; id hostsVal = dict[@"2"];
                    if ([hostsVal isKindOfClass:[NSArray class]]) {
                        NSArray *hosts = (NSArray *)hostsVal;
                        BOOL hasPorts = [portsVal isKindOfClass:[NSArray class]] && [(NSArray *)portsVal count] > 0;
                        NSArray *ports = hasPorts ? (NSArray *)portsVal : @[];
                        for (id hostObj in hosts) {
                            if (![hostObj isKindOfClass:[NSString class]]) continue;
                            NSString *host = [(NSString *)hostObj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            if (host.length <= 0) continue;
                            if (!hasPorts) {
                                NSString *typeStr = ossUrlList.count == 0 ? @"1" : @"2";
                                [ossUrlList addObject:[weakSelf getUrlHostModelWithUrl:host type:typeStr]];
                                continue;
                            }
                            for (id portObj in ports) {
                                NSString *portStr = nil;
                                if ([portObj isKindOfClass:[NSString class]]) portStr = (NSString *)portObj; else if ([portObj respondsToSelector:@selector(stringValue)]) portStr = [portObj stringValue];
                                if (portStr.length <= 0) continue; NSInteger pnum = [portStr integerValue]; if (pnum <= 0 || pnum > 65535) continue;
                                NSString *combo = [NSString stringWithFormat:@"%@:%@", host, portStr];
                                NSString *typeStr = ossUrlList.count == 0 ? @"1" : @"2";
                                [ossUrlList addObject:[weakSelf getUrlHostModelWithUrl:combo type:typeStr]];
                            }
                        }
                    }
                }
            }
        }
        // 子线程回调，切主线程返回结果
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(ossUrlList);
        });
    }];
}

/// 通过阿里 Resolver 获取主、副域名解析结果，并补充本地内置导航桶。
/// @param complete 返回可参与导航竞速的地址列表；内置地址未配置端口时使用默认端口 8087。
- (void)getDirectOssUrlListFromDNSComplete:(void(^)(NSArray<NoaUrlHostModel *> *ossUrlList))complete {
    DNSResolver *resolver = [DNSResolver share];
    [resolver setAccountId:ali_account_id andAccessKeyId:ali_key_id andAccesskeySecret:ali_key_secret];
    resolver.cacheEnable = NO;
    resolver.scheme = DNSResolverSchemeHttp;
    [[DNSResolver share] clearHostCache:nil];
    [[DNSResolver share] clearHostCache:nil];
    __block BOOL mainDNS = NO;
    __block BOOL bucketDNS = NO;
    __block NSMutableArray<NoaUrlHostModel *> *ossUrlList = [NSMutableArray array];
    WeakSelf
    dispatch_group_t group = dispatch_group_create();
    //tcp主域名
    dispatch_group_enter(group);
    // 主域名
    [[DNSResolver share] getIpv6DataWithDomain:DirectNormarDomain complete:^(NSArray<NSString *> *dataArray) {
        BOOL analysisResult = NO;
        NSString *analysisDomain = @"";
        NSMutableArray *ipV6List = [NSMutableArray array];
        if (dataArray != nil && dataArray.count > 0) {
            for (NSString *domainInfoStr in dataArray) {
                [ipV6List addObject:domainInfoStr];
            }
            analysisDomain = [AliyCloundDNSDecoder v6ToString:ipV6List];
            if ([NSString isNil:analysisDomain]) {
                analysisResult = NO;
            } else {
                analysisResult = YES;
            }
        } else {
            //主域名解析失败，未返回结果
            analysisResult = NO;
        }
        if (analysisResult) {
            //处理数据
            mainDNS = YES;
            NSArray<NSString *> *ossBucketArr = [analysisDomain componentsSeparatedByString:@","];
            if (ossBucketArr != nil && ossBucketArr.count > 0) {
                for (int i = 0; i < ossBucketArr.count; i++) {
                    if ([ossBucketArr[i] hasSuffix:@"8088"]) {
                        continue;;
                    }
                    if (i == 0) {
                        [ossUrlList addObject:[weakSelf getUrlHostModelWithUrl:[NSString stringWithFormat:@"%@",ossBucketArr[i]] type:@"1"]];
                    } else {
                        [ossUrlList addObject:[weakSelf getUrlHostModelWithUrl:[NSString stringWithFormat:@"%@",ossBucketArr[i]] type:@"2"]];
                    }
                    
                }
            }
        }
        dispatch_group_leave(group);
    }];
    
    //tcp副域名
    dispatch_group_enter(group);
    // 副域名
    [[DNSResolver share] getIpv6DataWithDomain:DirectSpareDomain complete:^(NSArray<NSString *> *dataArray) {
        BOOL analysisResult = NO;
        NSString *analysisDomain = @"";
        NSMutableArray *ipV6List = [NSMutableArray array];
        if (dataArray != nil && dataArray.count > 0) {
            for (NSString *domainInfoStr in dataArray) {
                [ipV6List addObject:domainInfoStr];
            }
            analysisDomain = [AliyCloundDNSDecoder v6ToString:ipV6List];
            if ([NSString isNil:analysisDomain]) {
                analysisResult = NO;
            } else {
                analysisResult = YES;
            }
        } else {
            //主域名解析失败，未返回结果
            analysisResult = NO;
        }
        if (analysisResult) {
            //处理数据
            bucketDNS = YES;
            NSArray<NSString *> *ossBucketArr = [analysisDomain componentsSeparatedByString:@","];
            if (ossBucketArr != nil && ossBucketArr.count > 0) {
                for (int i = 0; i < ossBucketArr.count; i++) {
                    if ([ossBucketArr[i] hasSuffix:@"8088"]) {
                        continue;;
                    }
                    if (i == 0) {
                        [ossUrlList addObject:[weakSelf getUrlHostModelWithUrl:[NSString stringWithFormat:@"%@",ossBucketArr[i]] type:@"3"]];
                    } else {
                        [ossUrlList addObject:[weakSelf getUrlHostModelWithUrl:[NSString stringWithFormat:@"%@",ossBucketArr[i]] type:@"4"]];
                    }
                    
                }
            }
        }
        dispatch_group_leave(group);
    }];
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (mainDNS && bucketDNS) {
            self.subModulesDNSCode = @"4";
        } else {
            if (mainDNS) {
                self.subModulesDNSCode = @"5";
            } else if (bucketDNS) {
                self.subModulesDNSCode = @"6";
            } else {
                self.subModulesDNSCode = @"0";
            }
        }
        // 内置桶作为固定兜底候选加入现有竞速列表；首个为主桶(type 5)，其余为备桶(type 6)。
        NSArray<NSString *> *builtInBuckets = [builtInBucketName componentsSeparatedByString:@","];
        NSMutableSet<NSString *> *existingUrls = [NSMutableSet set];
        for (NoaUrlHostModel *urlModel in ossUrlList) {
            if (urlModel.urlString.length > 0) {
                [existingUrls addObject:urlModel.urlString];
            }
        }
        [builtInBuckets enumerateObjectsUsingBlock:^(NSString *bucket, NSUInteger idx, BOOL *stop) {
            NSString *trimmedBucket = [bucket stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (trimmedBucket.length == 0) {
                return;
            }

            // TCP 竞速地址必须包含端口；内置桶未指定端口时沿用现有默认端口 8087。
            NSString *racingUrl = [trimmedBucket containsString:@":"] ? trimmedBucket : [trimmedBucket stringByAppendingString:@":8087"];
            if ([existingUrls containsObject:racingUrl]) {
                return;
            }

            NSString *type = (idx == 0) ? @"5" : @"6";
            [ossUrlList addObject:[weakSelf getUrlHostModelWithUrl:racingUrl type:type]];
            [existingUrls addObject:racingUrl];
        }];
        //处理数据
        complete(ossUrlList);
    });
}

- (NoaUrlHostModel *)getUrlHostModelWithUrl:(NSString *)urlString type:(NSString *)type {
    NoaUrlHostModel *model = [[NoaUrlHostModel alloc] init];
    model.urlString = urlString;
    model.type = type;
    return model;
}

/// 将域名归一为 IP（若已为 IP 则原样返回）。失败则保留原域名（按需求先日志代替上报）
- (NSArray<NoaUrlHostModel *> *)normalizeDomainToIP:(NSArray<NoaUrlHostModel *> *)list {
    if (list.count <= 0) return list;
    NSMutableArray<NoaUrlHostModel *> *result = [NSMutableArray arrayWithCapacity:list.count];
    // 使用 ip[:port] 组合去重键（IPv6在有端口时使用 [ip]:port 表示）
    NSMutableSet<NSString *> *comboSet = [NSMutableSet set];
    for (NoaUrlHostModel *item in list) {
        NSString *startHost = item.urlString ?: @"";
        if (startHost.length <= 0) continue;
        // 解析 host 和可选 port
        NSString *host = startHost;
        NSString *port = nil;
        // 处理 [IPv6]:port 形式
        if ([host hasPrefix:@"["]) {
            NSRange rb = [host rangeOfString:@"]:"]; // 形如 "]:port"
            if (rb.location != NSNotFound) {
                NSString *inside = [host substringWithRange:NSMakeRange(1, rb.location - 1)];
                NSString *portStr = [host substringFromIndex:(rb.location + rb.length)];
                host = inside;
                port = portStr.length > 0 ? portStr : nil;
            }
        } else {
            // 若只有一个冒号，视为 host:port；多冒号则多半是IPv6无端口
            NSUInteger colonCount = 0; for (NSUInteger i=0;i<host.length;i++){ if ([host characterAtIndex:i] == ':') colonCount++; }
            if (colonCount == 1) {
                NSArray<NSString *> *parts = [host componentsSeparatedByString:@":"];
                if (parts.count == 2) {
                    host = parts[0];
                    port = parts[1].length > 0 ? parts[1] : nil;
                }
            }
        }
        // 端口合法性校验（仅 1..65535 的十进制）
        BOOL hasValidPort = NO;
        NSString *validPort = nil;
        if (port.length > 0) {
            NSScanner *scanner = [NSScanner scannerWithString:port];
            NSInteger pvalue = 0;
            BOOL numeric = [scanner scanInteger:&pvalue] && scanner.isAtEnd;
            if (numeric && pvalue > 0 && pvalue <= 65535) {
                hasValidPort = YES;
                validPort = [NSString stringWithFormat:@"%ld", (long)pvalue];
            }
        }
        
        // 已是 IP 则直接加入（保留端口；去重）
        struct in_addr ipv4addr; struct in6_addr ipv6addr;
        if (inet_pton(AF_INET, host.UTF8String, &ipv4addr) == 1 ||
            inet_pton(AF_INET6, host.UTF8String, &ipv6addr) == 1) {
            BOOL isV6 = (inet_pton(AF_INET6, host.UTF8String, &ipv6addr) == 1);
            NSString *out = nil;
            if (hasValidPort) {
                out = isV6 ? [NSString stringWithFormat:@"[%@]:%@", host, validPort] : [NSString stringWithFormat:@"%@:%@", host, validPort];
            } else {
                out = host;
            }
            if (![comboSet containsObject:out]) {
                [comboSet addObject:out];
                NSString *typeStr = result.count == 0 ? item.type : @"2";
                [result addObject:[self getUrlHostModelWithUrl:out type:typeStr]];
            }
            continue;
        }
        
        // 并发解析：Ali DoH A + CF DoH A + 系统DNS(119/114 UDP)
        __block NSArray<NSString *> *winnerIPs = nil;
        __block BOOL published = NO;
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        NSTimeInterval timeout = 0.5; // 500ms
        void (^publishIfFirst)(NSArray<NSString *> *) = ^(NSArray<NSString *> *ips){
            if (ips.count <= 0) return;
            @synchronized (comboSet) {
                if (!published) { published = YES; winnerIPs = ips; dispatch_semaphore_signal(sem); }
            }
        };
        // 1) Ali DoH A（直连 223.5.5.5 / 223.6.6.6 JSON）
        [self resolveAFromAliDoHForDomain:host timeout:timeout completion:^(NSArray<NSString *> *ips) {
            publishIfFirst(ips);
        }];
        // 2) Cloudflare DoH A
        [self resolveAFromCloudflareForDomain:host timeout:timeout completion:^(NSArray<NSString *> *ips) {
            publishIfFirst(ips);
        }];
        // 3) 系统 DNS（119.29.29.29 / 114.114.114.114 UDP）
        [self resolveAFromSystemDNSForDomain:host timeout:timeout completion:^(NSArray<NSString *> *ips) {
            publishIfFirst(ips);
        }];
        
        // 等待 500ms 或首个成功结果
        dispatch_time_t waitT = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC));
        dispatch_semaphore_wait(sem, waitT);
        
        if (winnerIPs.count > 0) {
            for (NSString *ip in winnerIPs) {
                if (ip.length <= 0) continue;
                NSString *out = hasValidPort ? [NSString stringWithFormat:@"%@:%@", ip, validPort] : ip;
                if (![comboSet containsObject:out]) {
                    [comboSet addObject:out];
                    NSString *typeStr = result.count == 0 ? item.type : @"2";
                    [result addObject:[self getUrlHostModelWithUrl:out type:typeStr]];
                }
            }
        } else {
            // 三源都失败，保留原域名
            NSString *fallbackOut = hasValidPort ? [NSString stringWithFormat:@"%@:%@", host, validPort] : host;
            if (![comboSet containsObject:fallbackOut]) {
                [comboSet addObject:fallbackOut];
                NSString *typeStr = result.count == 0 ? item.type : @"2";
                [result addObject:[self getUrlHostModelWithUrl:fallbackOut type:typeStr]];
            }
        }
    }
    return result;
}

#pragma mark - A记录解析实现

// Ali DoH JSON: https://223.5.5.5/resolve?name=example.com&type=A
- (void)resolveAFromAliDoHForDomain:(NSString *)domain
                            timeout:(NSTimeInterval)timeout
                         completion:(void(^)(NSArray<NSString *> *ips))completion {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSMutableSet *contentTypes = [NSMutableSet setWithSet:manager.responseSerializer.acceptableContentTypes];
    [contentTypes addObject:@"application/dns-json"]; manager.responseSerializer.acceptableContentTypes = contentTypes;
    [manager.requestSerializer setValue:@"application/dns-json" forHTTPHeaderField:@"accept"];
    manager.requestSerializer.timeoutInterval = timeout;
    __block BOOL finished = NO;
    void (^finish)(NSArray<NSString *> *) = ^(NSArray<NSString *> *ips){ if (!finished){ finished = YES; if (completion) completion(ips ?: @[]);} };
    NSArray<NSString *> *bases = @[@"https://223.5.5.5/resolve", @"https://223.6.6.6/resolve", @"https://dns.alidns.com/resolve"];
    __block NSInteger idx = 0;
    __weak typeof(self) weakSelf = self;
    __block void (^requestNext)(void) = nil;
    __weak typeof(requestNext) weakReq = nil;
    requestNext = ^{
        if (finished || idx >= bases.count) { finish(@[]); return; }
        NSString *base = bases[idx++];
        NSString *url = [NSString stringWithFormat:@"%@?name=%@&type=A", base, domain];
        [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSArray *ips = [weakSelf parseDoHJsonAResponse:responseObject];
            if (ips.count > 0) { finish(ips); } else { if (weakReq) weakReq(); }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (weakReq) weakReq();
        }];
    }; weakReq = requestNext; requestNext();
}

// Cloudflare DoH JSON: https://cloudflare-dns.com/dns-query?name=example.com&type=A
- (void)resolveAFromCloudflareForDomain:(NSString *)domain
                                timeout:(NSTimeInterval)timeout
                             completion:(void(^)(NSArray<NSString *> *ips))completion {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSMutableSet *contentTypes = [NSMutableSet setWithSet:manager.responseSerializer.acceptableContentTypes];
    [contentTypes addObject:@"application/dns-json"]; manager.responseSerializer.acceptableContentTypes = contentTypes;
    [manager.requestSerializer setValue:@"application/dns-json" forHTTPHeaderField:@"accept"];
    manager.requestSerializer.timeoutInterval = timeout;
    NSString *url = [NSString stringWithFormat:@"%@?name=%@&type=A", CF_DOH_BASE_URL, domain];
    [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *ips = [self parseDoHJsonAResponse:responseObject];
        if (completion) completion(ips);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) completion(@[]);
    }];
}

// 解析 DoH JSON（Google/CF/Ali 兼容）
- (NSArray<NSString *> *)parseDoHJsonAResponse:(id)json {
    if (![json isKindOfClass:[NSDictionary class]]) return @[];
    NSMutableArray<NSString *> *ips = [NSMutableArray array];
    NSArray *answers = ((NSDictionary *)json)[@"Answer"];
    if (![answers isKindOfClass:[NSArray class]]) return @[];
    for (NSDictionary *ans in answers) {
        if (![ans isKindOfClass:[NSDictionary class]]) continue;
        NSNumber *typeNum = ans[@"type"]; NSString *data = ans[@"data"];
        if ([typeNum integerValue] == 1 && [data isKindOfClass:[NSString class]] && data.length > 0) {
            // 仅 A 记录
            struct in_addr a; if (inet_pton(AF_INET, data.UTF8String, &a) == 1) {
                [ips addObject:data];
            }
        }
    }
    return ips;
}

// 系统 DNS（指定服务器）UDP 查询 A 记录，谁先返回即用
- (void)resolveAFromSystemDNSForDomain:(NSString *)domain
                               timeout:(NSTimeInterval)timeout
                            completion:(void(^)(NSArray<NSString *> *ips))completion {
    NSArray<NSString *> *servers = @[@"119.29.29.29", @"114.114.114.114"]; // 腾讯、114
    __block BOOL finished = NO;
    void (^finish)(NSArray<NSString *> *) = ^(NSArray<NSString *> *ips){ @synchronized (self){ if (!finished){ finished = YES; if (completion) completion(ips ?: @[]); }} };
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (NSString *ip in servers) {
        dispatch_async(q, ^{
            uint16_t txid = (uint16_t)arc4random_uniform(0xFFFF);
            NSData *query = ZBuildDNSQueryA(domain, txid);
            int sockfd = socket(AF_INET, SOCK_DGRAM, 0);
            if (sockfd < 0) { return; }
            struct timeval tv; tv.tv_sec = 0; tv.tv_usec = (suseconds_t)(timeout * 1000000.0);
            setsockopt(sockfd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));
            struct sockaddr_in addr; memset(&addr, 0, sizeof(addr)); addr.sin_family = AF_INET; addr.sin_port = htons(53); inet_pton(AF_INET, ip.UTF8String, &addr.sin_addr);
            ssize_t sent = sendto(sockfd, query.bytes, query.length, 0, (struct sockaddr *)&addr, sizeof(addr));
            if (sent < 0) { close(sockfd); return; }
            uint8_t buf[512]; struct sockaddr_in from; socklen_t fromlen = sizeof(from);
            ssize_t r = recvfrom(sockfd, buf, sizeof(buf), 0, (struct sockaddr *)&from, &fromlen);
            close(sockfd);
            if (r > 0) {
                NSArray<NSString *> *ips = ZParseDNSResponseA(buf, r, txid);
                if (ips.count > 0) { finish(ips); }
            }
        });
    }
    // 超时保护
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        finish(@[]);
    });
}

//oss 直连 竞速
- (void)netWorkDirectWithFiltrateBestOssRacingWithOssList:(NSArray<NoaUrlHostModel *> *)ossList
                                               iscontinue:(BOOL)iscontinue
                                       allowFallbackRetry:(BOOL)allowFallbackRetry
                                                sourceTag:(NSString *)sourceTag
                                  isNetworkQualityTrigger:(BOOL)isNetworkQualityTrigger {
    __block BOOL hasResult = NO;
    __block NSInteger ossNum = 0;
    // 旧五源和 Resolver 兜底都可能返回空列表：允许兜底时改走内置 OSS HTTP；否则结束竞速。
    if (ossList.count <= 0) {
        CIMLog(@"[DNS并发] %@ 没有可用 OSS 地址", sourceTag ?: @"UNKNOWN");
        if (allowFallbackRetry) {
            [self raceBuiltInOssHttpFallbackWithSourceTag:sourceTag ?: @"EMPTY_LIST"
                                  isNetworkQualityTrigger:isNetworkQualityTrigger];
        } else {
            [self.codeBuilder withInitializationSubModule:[NSString stringWithFormat:@"%@0", self.subModulesDNSCode]];
            [self.codeBuilder withInitializationErrorType:[InitializationErrorTypes OSS_FAILURE]];
            [self packageRacingResultWithStep:ZNetRacingStepOss result:NO racingCode:10000 isNetworkQualityTrigger:isNetworkQualityTrigger];
            if (!isNetworkQualityTrigger) {
                [self startGaOnchain];
            }
        }
        return;
    }
    //拿到本地保存的LecseID
    NoaSsoInfoModel *ssoModel = [NoaSsoInfoModel getSSOInfo];
    if (ssoModel == nil || ssoModel.liceseId == nil) {
        // 移除通知，避免通知泄漏
        [self removeEcdhNotification];
        
        if (isNetworkQualityTrigger) {
            return;
        }
        [ZTOOL setupSsoSetVcUI];
        return;
    }
    //ssoInfo
    [IMSDKManager configSDKSsoInfo:[NoaSsoInfoModel getSSOInfoDetailInfo]];
    
    @weakify(self)
    [ZTOOL getDevicePublicNetworkIPWithCompletion:^(NSString * _Nonnull ip) {
        for (NoaUrlHostModel *ossUrlModel in ossList) {
            if (hasResult) {
                break;
            }
            
            IOSTcpRaceManager *manager = [[IOSTcpRaceManager alloc]
                                          initWithAppId:ssoModel.liceseId
                                          appType:DefaultAppType
                                          bucket:ossUrlModel
                                          useProxy:!iscontinue
                                          publicIp:ip];
            CIMLog(@"\n\noss竞速======%@ ------🔥🔥🔥🔥🔥🔥🔥🔥-------\nliceseId:%@\nurlString:%@\nip:%@\n-------------------",[NSDate now], ssoModel.liceseId,ossUrlModel.urlString, ip);
            [manager executeWithSuccess:^(IMServerListResponseBody * _Nonnull serverResponse) {
                @strongify(self)
                
                NSArray *imArr = serverResponse.imEndpointsArray;
                CIMLog(@"✅ 单个TCP竞速成功: %@, 当前成功的地址: %@", imArr, ossUrlModel.urlString);
                // 上报 Sentry 成功
                NSMutableDictionary *succDict = [NSMutableDictionary dictionary];
                [succDict setValue:sourceTag ?: @"unknown" forKey:@"source"];
                [succDict setValue:ossUrlModel.urlString ?: @"" forKey:@"address"];
                [succDict setValue:@"0" forKey:@"errorCode"];
                [ZTOOL sentryUploadWithDictionary:succDict sentryUploadType:ZSentryUploadTypeEnterpriseSuccess errorCode:@"0"];
                CIMLog(@"当前成功的地址: %@",ossUrlModel.urlString);
                // 短路其余源
                self.ossFirstSuccessGlobal = YES;
                self.multiSourceActive = NO;
                if (self.raceTasks.count > 0) {
                    for (NSURLSessionDataTask *t in self.raceTasks) { if (t.state == NSURLSessionTaskStateRunning) [t cancel]; }
                }
                
                // 同步服务器兜底导航到本地缓存
                if (serverResponse.hasFallbackEndpoints && serverResponse.fallbackEndpoints) {
                    FallbackEndpoints *fb = serverResponse.fallbackEndpoints;
                    NSArray<NSString *> *srvDomestic = fb.domesticArray ? [fb.domesticArray copy] : @[];
                    NSArray<NSString *> *srvOverseas = fb.overseasArray ? [fb.overseasArray copy] : @[];
                    BOOL needUpdateDomestic = (srvDomestic.count > 0) && ![srvDomestic isEqualToArray:self.fallbackStore.domesticUrls];
                    BOOL needUpdateOverseas = (srvOverseas.count > 0) && ![srvOverseas isEqualToArray:self.fallbackStore.overseasUrls];
                    if (needUpdateDomestic || needUpdateOverseas) {
                        [self.fallbackStore updateIfDifferentDomestic:srvDomestic overseas:srvOverseas];
                    }
                }
                
              
                
                // 同步服务器下发的 Logan
                if (serverResponse.meta && serverResponse.meta.config.loganUrlsArray.firstObject.length > 0) {
                    NSString *newLoganURL = serverResponse.meta.config.loganUrlsArray.firstObject;
                    [ZTOOL reloadLoganIfNeededWithPublishURL:newLoganURL];
                }
                
                
                NSMutableArray <IMServerEndpoint *>* tcpEndPointArray = [NSMutableArray new];
                NSMutableArray <IMServerEndpoint *>* httpEndPointArray = [NSMutableArray new];
                
                [serverResponse.imEndpointsArray enumerateObjectsUsingBlock:^(IMServerEndpoint * _Nonnull endpoint, NSUInteger idx, BOOL * _Nonnull stop) {
                    // 因为存在tcp、http同时存在的类，所以不能用if...else...去判断
                    
                    if ([endpoint.status isEqualToString:@"INACTIVE"]) {
                        // 不可用的不保存
                        return;
                    }
                    
                    // 过滤出支持tcp的
                    if ([endpoint.protocolsArray containsObject:@"tcp"]) {
                        [tcpEndPointArray addObject:endpoint];
                    }
                    
                    // 过滤出支持http的
                    if ([endpoint.protocolsArray containsObject:@"http"]) {
                        [httpEndPointArray addObject:endpoint];
                    }
                }];
                
                self.tcpDomainList = [tcpEndPointArray mutableCopy];
                self.httpDomainList = [httpEndPointArray mutableCopy];
                
                // 启动网络质量检测
                if (serverResponse.meta.config.enableNetworkDetect) {
                    // 配置已开启网络质量检测
                    [self.networkQualityDetector setEnableDetection:YES];
                    [self startNetworkQualityDetection:ssoModel.liceseId];
                }else {
                    // 配置未开启网络质量检测
                    [self.networkQualityDetector setEnableDetection:NO];
                    [self stopNetworkQualityDetection];
                }
                
                NSMutableArray <NoaNetRacingItemModel *>* tcpArray = [NSMutableArray new];
                NSMutableArray <NoaNetRacingItemModel *>* httpArray = [NSMutableArray new];
                [tcpEndPointArray enumerateObjectsUsingBlock:^(IMServerEndpoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NoaNetRacingItemModel *model = [NoaNetRacingItemModel new];
                    model.ip = obj.ip;
                    model.sort = obj.port;
                    [tcpArray addObject:model];
                }];
                
                [httpEndPointArray enumerateObjectsUsingBlock:^(IMServerEndpoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NoaNetRacingItemModel *model = [NoaNetRacingItemModel new];
                    model.ip = [NSString stringWithFormat:@"%@:%d",obj.ip,obj.port];
                    model.sort = obj.port;
                    [httpArray addObject:model];
                }];
                
                if (tcpArray.count == 0 || httpArray.count == 0) {
                    [self.codeBuilder withInitializationErrorType:[InitializationErrorTypes OSS_FAILURE]];
                    ossNum += 1;
                    [self ossRacingDirectFailResultHandle:ossNum totalNum:ossList.count iscontinue:iscontinue allowFallbackRetry:allowFallbackRetry sourceTag:sourceTag ossList:ossList isNetworkQualityTrigger:isNetworkQualityTrigger];
                }
                if (!hasResult) {
                    // 五源直连路径成功：标记全局成功并取消其余请求
                    self.ossFirstSuccessGlobal = YES;
                    self.multiSourceActive = NO;
                    if (self.raceTasks.count > 0) {
                        for (NSURLSessionDataTask *t in self.raceTasks) {
                            if (t.state == NSURLSessionTaskStateRunning) { [t cancel]; }
                        }
                    }
                    hasResult = YES;
                    NoaNetRacingModel *racingModel = [[NoaNetRacingModel alloc] init];
                    
                    racingModel.httpArr = httpArray;
                    racingModel.tcpArr = tcpArray;
                    ssoModel.ossRacingModel = racingModel;
                    [ssoModel saveSSOInfo];
                    [ssoModel saveSSOInfoWithLiceseId:ssoModel.liceseId];
                    //存储证书data
                    self.cerData = racingModel.cerData;
                    self.p12Data = racingModel.p12Data;
                    self.p12pwd = [NSString getHttpsCerPassword];
                    
                    //core层
                    IMSDKHTTPTOOL.cerData = racingModel.cerData;
                    IMSDKHTTPTOOL.p12Data = racingModel.p12Data;
                    IMSDKHTTPTOOL.p12pwd = [NSString getHttpsCerPassword];
                    [self.codeBuilder withInitializationSubModule:[NSString stringWithFormat:@"%@%@",self.subModulesDNSCode,ossUrlModel.type]];
                    //对http进行竞速
                    [self netWorkFiltrateBestHttpRacingWithList:racingModel isNetworkQualityTrigger:isNetworkQualityTrigger];
                }
            } failure:^(NSError * _Nonnull error) {
                @strongify(self)
                CIMLog(@"❌ 单个TCP竞速失败: %@, 错误: %@", ossUrlModel.urlString, error.localizedDescription);
                CIMLog(@"oss竞速失败 %@ ********************** %@\n",[NSDate now], ossUrlModel.urlString);
                if (error.code == 1) {
                    [self.codeBuilder withInitializationErrorType:[InitializationErrorTypes OSS_NONEXISTENT_FAILURE]];
                } else {
                    [self.codeBuilder withInitializationErrorType:[InitializationErrorTypes OSS_FAILURE]];
                }
                [self.codeBuilder withInitializationSubModule:[NSString stringWithFormat:@"%@0",self.subModulesDNSCode]];
                //日志上传 oss竞速失败
                NSMutableDictionary *loganDict = [NSMutableDictionary dictionary];
                [loganDict setObjectSafe:ossUrlModel.urlString forKey:@"oss"];
                [loganDict setObjectSafe:@(10000) forKey:@"ossCode"];
                [loganDict setObjectSafe:ZTOOL.publicIP forKey:@"publicIp"];
                [loganDict setObjectSafe:[NSString getCurrentNetWorkType] forKey:@"netWorkType"];
                [IMSDKManager imSdkWriteLoganWith:LingIMLoganTypeApi loganContent:[[NoaIMLoganManager sharedManager] configLoganContent:loganDict]];
                ossNum += 1;
                [self ossRacingDirectFailResultHandle:ossNum totalNum:ossList.count iscontinue:iscontinue allowFallbackRetry:allowFallbackRetry sourceTag:sourceTag ossList:ossList isNetworkQualityTrigger:isNetworkQualityTrigger];
                // 五源路径统计收敛（当该源地址都失败时，计一次完成+失败）
                if (!allowFallbackRetry && ossNum >= ossList.count && ![sourceTag isEqualToString:@"OLDRESOLVER"]) {
                    @synchronized (self) {
                        self.multiSourceFinishedCount++;
                        self.multiSourceDirectFailCount++;
                        if (!self.ossFirstSuccessGlobal && self.multiSourceFinishedCount >= self.multiSourceTotalCount) {
                            CIMLog(@"[DNS并发] 五源均失败或直连竞速全部失败，走 Resolver 兜底");
                            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                            [loganDict setValue:@"014099" forKey:@"failReason"];//失败原因
                            [ZTOOL sentryUploadWithDictionary:dict sentryUploadType:ZSentryUploadTypeEnterprise errorCode:@"014099"];
                            BOOL isProxyFB = ([ZTOOL getCurrentProxyType] == ProxyTypeSOCKS5);
                            [self getDirectOssUrlListFromDNSComplete:^(NSArray<NoaUrlHostModel *> *ossUrlList) {
                                @strongify(self)
                                NSArray<NoaUrlHostModel *> *normalizedFB = [self normalizeDomainToIP:ossUrlList];
                                [self netWorkDirectWithFiltrateBestOssRacingWithOssList:normalizedFB iscontinue:!isProxyFB allowFallbackRetry:YES sourceTag:@"OLDRESOLVER" isNetworkQualityTrigger:isNetworkQualityTrigger];
                            }];
                        }
                    }
                }
            }];
        }
    }];
    
}

- (void)ossRacingDirectFailResultHandle:(NSInteger)ossNum
                               totalNum:(NSInteger)totalNum
                             iscontinue:(BOOL)iscontinue
                     allowFallbackRetry:(BOOL)allowFallbackRetry
                              sourceTag:(NSString *)sourceTag
                                ossList:(NSArray<NoaUrlHostModel *> *)ossList
                isNetworkQualityTrigger:(BOOL)isNetworkQualityTrigger {
    if (ossNum >= totalNum) {
        // 若当前已是兜底列表（type=="5"），全部失败后走内置 OSS HTTP 对象兜底
        __block BOOL isFallbackList = YES;
        [ossList enumerateObjectsUsingBlock:^(NoaUrlHostModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj.type isEqualToString:@"5"]) {
                isFallbackList = NO;
                *stop = YES;
            }
        }];
        if (isFallbackList) {
            [self raceBuiltInOssHttpFallbackWithSourceTag:sourceTag ?: @"FALLBACK"
                                  isNetworkQualityTrigger:isNetworkQualityTrigger];
            return;
        }
        // oss 直连 竞速全部失败
        if (iscontinue) {
            [self netWorkDirectWithFiltrateBestOssRacingWithOssList:ossList iscontinue:NO allowFallbackRetry:allowFallbackRetry sourceTag:sourceTag isNetworkQualityTrigger:isNetworkQualityTrigger];
        } else {
            if (!allowFallbackRetry) {
                // 五源路径：不使用兜底地址重试，仅统计为失败
                return;
            }
            // 使用兜底地址重试一次
            BOOL isDomestic = [ZTOOL isDomestic];
            NSArray<NSString *> *fallbacks = isDomestic ? self.fallbackStore.domesticUrls : self.fallbackStore.overseasUrls;
            NSMutableArray<NoaUrlHostModel *> *fallbackOss = [NSMutableArray array];
            
            for (NSString *u in fallbacks) {
                [fallbackOss addObject:[self getUrlHostModelWithUrl:u type:@"5"]];
                CIMLog(@"当前的兜底地址: %@",u);
            }
            if (fallbackOss.count > 0) {
                [self netWorkDirectWithFiltrateBestOssRacingWithOssList:fallbackOss iscontinue:NO allowFallbackRetry:NO sourceTag:sourceTag isNetworkQualityTrigger:isNetworkQualityTrigger];
            } else {
                // FallbackStore 为空：直接走内置 OSS HTTP 对象兜底
                [self raceBuiltInOssHttpFallbackWithSourceTag:sourceTag ?: @"OLDRESOLVER"
                                      isNetworkQualityTrigger:isNetworkQualityTrigger];
            }
        }
    }
}

#pragma mark - 内置 OSS HTTP 对象兜底（对齐 Android RaceOssTask）

- (NSArray<NSString *> *)builtInOssHttpUrlsForLicenseId:(NSString *)licenseId {
    if (licenseId.length <= 0) {
        return @[];
    }
    NSMutableArray<NSString *> *urls = [NSMutableArray array];
    NSString *inner = [NSString stringWithFormat:ossInnerUrl, licenseId];
    NSString *aws = [NSString stringWithFormat:awsUrl, licenseId];
    if (inner.length > 0) {
        [urls addObject:inner];
    }
    if (aws.length > 0 && ![aws isEqualToString:inner]) {
        [urls addObject:aws];
    }
    if (![ZTOOL isDomestic] && urls.count > 1) {
        // 海外优先 aws
        return @[urls[1], urls[0]];
    }
    return [urls copy];
}

- (BOOL)prepareRacingModelFromOssHttpPayload:(NoaNetRacingModel *)racingModel {
    if (racingModel == nil || racingModel.endpoints == nil) {
        return NO;
    }
    NSMutableArray<NoaNetRacingItemModel *> *httpArray = [NSMutableArray array];
    NSMutableArray<NoaNetRacingItemModel *> *tcpArray = [NSMutableArray array];
    
    void (^appendItems)(NSArray<NoaNetRacingItemModel *> *, NSMutableArray<NoaNetRacingItemModel *> *) =
    ^(NSArray<NoaNetRacingItemModel *> *src, NSMutableArray<NoaNetRacingItemModel *> *dst) {
        for (NoaNetRacingItemModel *item in src) {
            if (![item isKindOfClass:[NoaNetRacingItemModel class]]) {
                continue;
            }
            if (item.ip.length <= 0) {
                continue;
            }
            [dst addObject:item];
        }
    };
    
    appendItems(racingModel.endpoints.http.ipList ?: @[], httpArray);
    appendItems(racingModel.endpoints.http.dnsList ?: @[], httpArray);
    appendItems(racingModel.endpoints.tcp.ipList ?: @[], tcpArray);
    appendItems(racingModel.endpoints.tcp.dnsList ?: @[], tcpArray);
    
    if (httpArray.count == 0 || tcpArray.count == 0) {
        return NO;
    }
    
    // 与 TCP 竞速成功路径一致：写入扁平 httpArr/tcpArr，供后续 HTTP/TCP 竞速直接使用
    racingModel.httpArr = httpArray;
    racingModel.tcpArr = tcpArray;
    
    if (racingModel.clientCer.length > 0) {
        NSData *cerData = [[NSData alloc] initWithBase64EncodedString:racingModel.clientCer
                                                              options:NSDataBase64DecodingIgnoreUnknownCharacters];
        if (cerData.length > 0) {
            racingModel.cerData = cerData;
        }
    }
    if (racingModel.clientP12.length > 0) {
        NSData *p12Data = [[NSData alloc] initWithBase64EncodedString:racingModel.clientP12
                                                              options:NSDataBase64DecodingIgnoreUnknownCharacters];
        if (p12Data.length > 0) {
            racingModel.p12Data = p12Data;
        }
    }
    return YES;
}

- (void)finishBuiltInOssHttpFallbackFailure:(BOOL)isNetworkQualityTrigger {
    [self.codeBuilder withInitializationSubModule:[NSString stringWithFormat:@"%@0", self.subModulesDNSCode]];
    [self.codeBuilder withInitializationErrorType:[InitializationErrorTypes OSS_FAILURE]];
    [self packageRacingResultWithStep:ZNetRacingStepOss result:NO racingCode:10000 isNetworkQualityTrigger:isNetworkQualityTrigger];
    if (!isNetworkQualityTrigger) {
        [self startGaOnchain];
    }
}

- (void)applyBuiltInOssHttpSuccessWithRacingModel:(NoaNetRacingModel *)racingModel
                                        sourceTag:(NSString *)sourceTag
                          isNetworkQualityTrigger:(BOOL)isNetworkQualityTrigger {
    NoaSsoInfoModel *ssoModel = [NoaSsoInfoModel getSSOInfo];
    if (ssoModel == nil) {
        [self finishBuiltInOssHttpFallbackFailure:isNetworkQualityTrigger];
        return;
    }
    
    self.ossFirstSuccessGlobal = YES;
    self.multiSourceActive = NO;
    if (self.raceTasks.count > 0) {
        for (NSURLSessionDataTask *t in self.raceTasks) {
            if (t.state == NSURLSessionTaskStateRunning) {
                [t cancel];
            }
        }
    }
    
    ssoModel.ossRacingModel = racingModel;
    [ssoModel saveSSOInfo];
    [ssoModel saveSSOInfoWithLiceseId:ssoModel.liceseId];
    
    self.cerData = racingModel.cerData;
    self.p12Data = racingModel.p12Data;
    self.p12pwd = [NSString getHttpsCerPassword];
    
    IMSDKHTTPTOOL.cerData = racingModel.cerData;
    IMSDKHTTPTOOL.p12Data = racingModel.p12Data;
    IMSDKHTTPTOOL.p12pwd = [NSString getHttpsCerPassword];
    
    // submodule type "6" = 内置 OSS HTTP 对象
    [self.codeBuilder withInitializationSubModule:[NSString stringWithFormat:@"%@6", self.subModulesDNSCode]];
    CIMLog(@"[OSS_HTTP] 内置 OSS 文件兜底成功 source=%@ http=%lu tcp=%lu",
           sourceTag ?: @"OSS_HTTP",
           (unsigned long)racingModel.httpArr.count,
           (unsigned long)racingModel.tcpArr.count);
    
    NSMutableDictionary *succDict = [NSMutableDictionary dictionary];
    [succDict setValue:sourceTag ?: @"OSS_HTTP" forKey:@"source"];
    [succDict setValue:@"OSS_HTTP" forKey:@"address"];
    [succDict setValue:@"0" forKey:@"errorCode"];
    [ZTOOL sentryUploadWithDictionary:succDict sentryUploadType:ZSentryUploadTypeEnterpriseSuccess errorCode:@"0"];
    
    [self netWorkFiltrateBestHttpRacingWithList:racingModel isNetworkQualityTrigger:isNetworkQualityTrigger];
}

- (void)raceBuiltInOssHttpFallbackWithSourceTag:(NSString *)sourceTag
                        isNetworkQualityTrigger:(BOOL)isNetworkQualityTrigger {
    if (self.ossFirstSuccessGlobal) {
        return;
    }
    if (self.builtInOssHttpFallbackTried) {
        CIMLog(@"[OSS_HTTP] 内置 OSS 文件兜底已尝试过，结束竞速");
        [self finishBuiltInOssHttpFallbackFailure:isNetworkQualityTrigger];
        return;
    }
    self.builtInOssHttpFallbackTried = YES;
    
    NoaSsoInfoModel *ssoModel = [NoaSsoInfoModel getSSOInfo];
    if (ssoModel == nil || ssoModel.liceseId.length <= 0) {
        CIMLog(@"[OSS_HTTP] 无企业号，跳过内置 OSS 文件兜底");
        [self finishBuiltInOssHttpFallbackFailure:isNetworkQualityTrigger];
        return;
    }
    
    NSArray<NSString *> *urls = [self builtInOssHttpUrlsForLicenseId:ssoModel.liceseId];
    if (urls.count <= 0) {
        CIMLog(@"[OSS_HTTP] 未配置 ossInnerUrl/awsUrl，结束竞速");
        [self finishBuiltInOssHttpFallbackFailure:isNetworkQualityTrigger];
        return;
    }
    
    CIMLog(@"[OSS_HTTP] 开始内置 OSS 文件兜底 source=%@ urls=%@", sourceTag ?: @"OSS_HTTP", urls);
    
    __block BOOL hasResult = NO;
    __block NSInteger finishedCount = 0;
    NSInteger totalCount = urls.count;
    NSString *licenseId = [ssoModel.liceseId copy];
    @weakify(self)
    
    for (NSString *url in urls) {
        if (hasResult || self.ossFirstSuccessGlobal) {
            break;
        }
        NSURLSessionDataTask *task = [self filtrateNetWorkWithUrl:url compelete:^(NSInteger code, NSString *msg, NSData *data, NSString *traceId) {
            @strongify(self)
            if (!self) {
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (hasResult || self.ossFirstSuccessGlobal) {
                    return;
                }
                
                void (^markFailAndMaybeFinish)(NSString *) = ^(NSString *reason) {
                    finishedCount += 1;
                    CIMLog(@"[OSS_HTTP] 拉取失败 url=%@ code=%ld reason=%@ msg=%@", url, (long)code, reason ?: @"-", msg ?: @"-");
                    NSMutableDictionary *loganDict = [NSMutableDictionary dictionary];
                    [loganDict setObjectSafe:url forKey:@"oss"];
                    [loganDict setObjectSafe:@(code) forKey:@"ossCode"];
                    [loganDict setObjectSafe:@"OSS_HTTP" forKey:@"source"];
                    [loganDict setObjectSafe:reason ?: @"-" forKey:@"failReason"];
                    [loganDict setObjectSafe:ZTOOL.publicIP forKey:@"publicIp"];
                    [loganDict setObjectSafe:[NSString getCurrentNetWorkType] forKey:@"netWorkType"];
                    [IMSDKManager imSdkWriteLoganWith:LingIMLoganTypeApi loganContent:[[NoaIMLoganManager sharedManager] configLoganContent:loganDict]];
                    if (finishedCount >= totalCount && !hasResult && !self.ossFirstSuccessGlobal) {
                        [self finishBuiltInOssHttpFallbackFailure:isNetworkQualityTrigger];
                    }
                };
                
                if (code == 404 || code == 403) {
                    [self.codeBuilder withInitializationErrorType:[InitializationErrorTypes OSS_NONEXISTENT_FAILURE]];
                    markFailAndMaybeFinish(@"nonexistent");
                    return;
                }
                if (code != 200 || data.length <= 0) {
                    [self.codeBuilder withInitializationErrorType:[InitializationErrorTypes OSS_FAILURE]];
                    markFailAndMaybeFinish(data.length <= 0 ? @"empty" : @"http_fail");
                    return;
                }
                
                NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                body = [body stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if (body.length <= 0 || [body hasPrefix:@"<!DOCTYPE"] || [body hasPrefix:@"<!doctype"]) {
                    [self.codeBuilder withInitializationErrorType:[InitializationErrorTypes OSS_FAILURE]];
                    markFailAndMaybeFinish(@"body_invalid");
                    return;
                }
                
                NSString *clearText = [AesEncryptUtils decrypt:body secret:[licenseId MD5Encryption]];
                if (clearText.length <= 0) {
                    [self.codeBuilder withInitializationErrorType:[InitializationErrorTypes OSS_DECODE_FAILURE]];
                    markFailAndMaybeFinish(@"decode_fail");
                    return;
                }
                
                NSData *jsonData = [clearText dataUsingEncoding:NSUTF8StringEncoding];
                NSError *jsonErr = nil;
                id jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonErr];
                if (![jsonObj isKindOfClass:[NSDictionary class]]) {
                    [self.codeBuilder withInitializationErrorType:[InitializationErrorTypes OSS_DECODE_FAILURE]];
                    markFailAndMaybeFinish(jsonErr.localizedDescription ?: @"json_fail");
                    return;
                }
                
                NoaNetRacingModel *racingModel = [NoaNetRacingModel mj_objectWithKeyValues:jsonObj];
                if (![self prepareRacingModelFromOssHttpPayload:racingModel]) {
                    [self.codeBuilder withInitializationErrorType:[InitializationErrorTypes OSS_DECODE_FAILURE]];
                    markFailAndMaybeFinish(@"payload_invalid");
                    return;
                }
                
                hasResult = YES;
                finishedCount += 1;
                CIMLog(@"[OSS_HTTP] 拉取成功 url=%@", url);
                [self applyBuiltInOssHttpSuccessWithRacingModel:racingModel
                                                      sourceTag:sourceTag ?: @"OSS_HTTP"
                                        isNetworkQualityTrigger:isNetworkQualityTrigger];
            });
        }];
        if (task) {
            [self.raceTasks addObject:task];
        }
    }
}

//对比之前本地缓存的httpNode和本次oss信息里的httpNode使用完全一样
- (BOOL)compareOssHttpNodeContent:(NSArray *)HttpNodeArr new:(NSArray *)newHttpNodeArr {
    if (HttpNodeArr == nil || newHttpNodeArr == nil) {
        return NO;
    } else {
        if (HttpNodeArr.count != newHttpNodeArr.count) {
            return NO;
        } else {
            NSMutableSet *set1 = [NSMutableSet setWithArray:HttpNodeArr];
            NSMutableSet *set2 = [NSMutableSet setWithArray:newHttpNodeArr];
            
            return [set1 isEqualToSet:set2];
        }
    }
}
// Http竞速
- (void)netWorkQRScanFiltrateBestHttpRacingWithList:(NoaNetRacingModel *)racingModel index:(NSInteger)index{
    WeakSelf
    if (index < racingModel.httpArr.count) {
        NSArray *subArr = [racingModel.httpArr objectAtIndexSafe:index];
        if (subArr.count == 0) {
            [self netWorkQRScanFiltrateBestHttpRacingWithList:racingModel index:index + 1];
            return;
        }
        __block BOOL hasResult = NO;
        __block NSInteger httpNum = 0;
        NSMutableArray<NSURLSessionDataTask *> *tasks = [NSMutableArray array];
        for (NoaNetRacingItemModel *httpItem in subArr) {
            if (hasResult) {
                break;
            }
            NSString *requestHost;
            if (![httpItem.ip containsString:@"http"]) {
                requestHost = [NSString stringWithFormat:@"https://%@", httpItem.ip];
            } else {
                requestHost = [httpItem.ip stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
            }
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
            config.connectionProxyDictionary = @{}; // 关闭系统代理
            config.timeoutIntervalForRequest = 3.0; // 单请求超时
            config.timeoutIntervalForResource = 4.0; // 资源超时
            AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://www.baidu.com"] sessionConfiguration:config];
            manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];;
            manager.requestSerializer.timeoutInterval = 3.0;
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            manager.requestSerializer.timeoutInterval = 10;
            NSString *httpUrl = [NSString stringWithFormat:@"%@%@", requestHost, App_Get_System_Setting_Url];
            /// Header
            [manager.requestSerializer setValue:@"IOS" forHTTPHeaderField:@"deviceType"];
            NSString *deviceID = [FCUUID uuidForDevice];
            [manager.requestSerializer setValue:deviceID forHTTPHeaderField:@"deviceUuid"];//deviceUuid多租户
            [manager.requestSerializer setValue:Z_OrgName forHTTPHeaderField:@"orgName"];//租户信息
            [manager.requestSerializer setValue:@"1.0.0" forHTTPHeaderField:@"version"];//版本号
            [manager.requestSerializer setValue:@"" forHTTPHeaderField:@"token"];  //UID
            /** 接口验签 */
            long long timeStamp = [NSDate getCurrentTimeIntervalWithSecond];
            //timestamp
            [manager.requestSerializer setValue:[NSString stringWithFormat:@"%lld", timeStamp] forHTTPHeaderField:@"timestamp"];
            //signature
            NSString *signature = [LXChatEncrypt method5:@"getSystemConfig" uri:@"system/v2/getSystemConfig" timestamp:timeStamp];
            [manager.requestSerializer setValue:signature forHTTPHeaderField:@"signature"];
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:@"" forKey:@"projectId"];
            __block NSURLSessionDataTask *task = [manager dataTaskWithHTTPMethod:@"POST" URLString:httpUrl parameters:params headers:nil uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
                
            } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                NoaHttpResponse *resp = [NoaHttpResponse mj_objectWithKeyValues:responseObject];
                
                if (resp.isHttpSuccess && resp.data != nil) {
                    id descryptData = [resp responseDataDescryptWithDataString:resp.data url:httpUrl];
                    if (descryptData != nil) {
                        if (hasResult) {
                            return;
                        }
                        if(![descryptData isKindOfClass:[NSDictionary class]]){
                            httpNum += 1;
                            if (httpNum >= subArr.count) {
                                [strongSelf.codeBuilder withInitializationErrorType:[InitializationErrorTypes HTTP_DECODE_FAILURE]];
                                //重新请求下一组
                                [strongSelf netWorkQRScanFiltrateBestHttpRacingWithList:racingModel index:index + 1];
                            }
                        } else {
                            @synchronized (strongSelf) {
                                if (hasResult == NO) {
                                    CIMLog(@"=======最优http: %@", httpUrl);
                                    hasResult = YES;
                                    // 取消其他请求
                                    [tasks enumerateObjectsUsingBlock:^(NSURLSessionDataTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                        if (obj.state == NSURLSessionTaskStateRunning) {
                                            [obj cancel];
                                        }
                                    }];
                                    //保存SystemConfig信息
                                    NoaSystemSettingModel *sysSettingModel = [NoaSystemSettingModel mj_objectWithKeyValues:descryptData];
                                    strongSelf.appSysSetModel = sysSettingModel;
                                    [IMSDKManager configSDKTenantCode:sysSettingModel.tenantCode];
                                    
                                    //Kit层
                                    strongSelf.apiHost = requestHost;
                                    strongSelf.getFileHost = requestHost;
                                    strongSelf.uploadfileHost = [NSString stringWithFormat:@"%@/oss", requestHost];
                                    //SDK层
                                    NoaIMSDKApiOptions *option = [NoaIMSDKApiOptions new];
                                    option.imApi = requestHost;
                                    option.imOrgName = Z_OrgName;
                                    [IMSDKManager configSDKApiWith:option];
                                    NoaSsoInfoModel *infoModel = [NoaSsoInfoModel getSSOInfo];
                                    NSString *requestHostKey = infoModel.liceseId;
                                    [[MMKV defaultMMKV] setObject:requestHost forKey:[NSString stringWithFormat:@"%@%@",CONNECT_LOCAL_CACHE,requestHostKey]];
                                    //音视频相关处理
                                    [strongSelf callSDKConfig];
                                    //对Tcp进行竞速
                                    [strongSelf netWorkFiltrateBestTcpRacingWithList:racingModel isNetworkQualityTrigger:NO];
                                }
                            }
                            
                        }
                    } else {
                        httpNum += 1;
                        if (httpNum >= subArr.count) {
                            [strongSelf.codeBuilder withInitializationErrorType:[InitializationErrorTypes HTTP_DECODE_FAILURE]];
                            //重新请求下一组
                            [strongSelf netWorkQRScanFiltrateBestHttpRacingWithList:racingModel index:index + 1];
                        }
                    }
                } else {
                    httpNum += 1;
                    if (httpNum >= subArr.count) {
                        [strongSelf.codeBuilder withInitializationErrorType:[InitializationErrorTypes HTTP_DECODE_FAILURE]];
                        //重新请求下一组
                        [strongSelf netWorkQRScanFiltrateBestHttpRacingWithList:racingModel index:index + 1];
                    }
                }
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                CIMLog(@"http竞速结果 url: %@ code: %ld", requestHost, (long)error.code);
                //日志上传 http竞速失败
                NSMutableDictionary *loganDict = [NSMutableDictionary dictionary];
                [loganDict setObjectSafe:httpUrl forKey:@"http"];
                [loganDict setObjectSafe:@(error.code) forKey:@"httpCode"];
                [loganDict setObjectSafe:ZTOOL.publicIP forKey:@"publicIp"];
                [loganDict setObjectSafe:[NSString getCurrentNetWorkType] forKey:@"netWorkType"];
                [IMSDKManager imSdkWriteLoganWith:LingIMLoganTypeApi loganContent:[[NoaIMLoganManager sharedManager] configLoganContent:loganDict]];
                httpNum += 1;
                if (httpNum >= subArr.count) {
                    IMSDKHTTPTOOL.requestSerializer.timeoutInterval = 20.0;
                    //重新请求下一组
                    [weakSelf netWorkQRScanFiltrateBestHttpRacingWithList:racingModel index:index + 1];
                }
                
            }];
            [task resume];
            
            if (task) {
                [tasks addObject:task];
            }
        }
    } else {
        CIMLog(@"全部失败，停止Http择优");
        [self.codeBuilder withInitializationErrorType:[InitializationErrorTypes HTTP_FAILURE]];
        //节点竞速失败回调Block
        [weakSelf packageRacingResultWithStep:ZNetRacingStepHttp result:NO racingCode:0 isNetworkQualityTrigger:NO];
        return;
    }
}
// Http竞速
- (void)netWorkFiltrateBestHttpRacingWithList:(NoaNetRacingModel *)racingModel
                      isNetworkQualityTrigger:(BOOL)isNetworkQualityTrigger {
    
    NSArray<NoaNetRacingItemModel *> *subArr = racingModel.httpArr;
    NoaNetRacingItemModel *httpItem = subArr.firstObject;
    NSString *requestHost;
    if (![httpItem.ip containsString:@"http"]) {
        requestHost = [NSString stringWithFormat:@"https://%@", httpItem.ip];
    } else {
        requestHost = [httpItem.ip stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
    }
    //Kit层
    self.apiHost = requestHost;
    self.getFileHost = requestHost;
    self.uploadfileHost = [NSString stringWithFormat:@"%@/oss", requestHost];
    //SDK层
    NoaIMSDKApiOptions *option = [NoaIMSDKApiOptions new];
    option.imApi = requestHost;
    option.imOrgName = Z_OrgName;
    [IMSDKManager configSDKApiWith:option];
    NoaSsoInfoModel *infoModel = [NoaSsoInfoModel getSSOInfo];
    NSString *requestHostKey = infoModel.liceseId;
    [[MMKV defaultMMKV] setObject:requestHost forKey:[NSString stringWithFormat:@"%@%@",CONNECT_LOCAL_CACHE,requestHostKey]];
    //音视频相关处理
    [self callSDKConfig];
    //对Tcp进行竞速
    [self netWorkFiltrateBestTcpRacingWithList:racingModel isNetworkQualityTrigger:isNetworkQualityTrigger];
}

// Tcp竞速
- (void)netWorkFiltrateBestTcpRacingWithList:(NoaNetRacingModel *)racingModel
                     isNetworkQualityTrigger:(BOOL)isNetworkQualityTrigger {
    IMServerEndpoint *optimalServerPoint = [self.networkQualityDetector getOptimalServer];
    if (optimalServerPoint.ip && optimalServerPoint.ip.length > 0 && optimalServerPoint.port > 0) {
        // 当前有最优的服务器节点
        // 恢复 HTTP 全局超时
        IMSDKHTTPTOOL.requestSerializer.timeoutInterval = 60.0;
        
        // 配置 SDK Host & Port
        NoaIMSocketHostOptions *opt = [NoaIMSocketHostOptions new];
        opt.socketHost = optimalServerPoint.ip;
        opt.socketPort = optimalServerPoint.port;
        opt.socketOrgName = Z_OrgName;
        [NoaLocalLogger verbose:[NSString stringWithFormat:@"调用netWorkFiltrateBestTcpRacingWithList:(NoaNetRacingModel *)racingModel isNetworkQualityTrigger:(BOOL)isNetworkQualityTrigger,发现有最优节点，使用最优节点, ip = %@, port = %ld", opt.socketHost, opt.socketPort]];
        cim_function_configSocketHost(opt);
        
        // 配置用户信息
        NoaIMSDKUserOptions *uOpt = [NoaIMSDKUserOptions new];
        uOpt.userToken    = UserManager.userInfo.token;
        uOpt.userID       = UserManager.userInfo.userUID;
        uOpt.userNickname = UserManager.userInfo.nickname;
        uOpt.userAvatar   = UserManager.userInfo.avatar;
        [IMSDKManager configSDKUserWith:uOpt];
        
        // 配置邀请码 & 验证渠道
        NoaSsoInfoModel *sso = [NoaSsoInfoModel getSSOInfo];
        [IMSDKManager configSDKLiceseId:sso.liceseId];
        [IMSDKManager configSDKCaptchaChannel:self.appSysSetModel.captchaChannel];
        
        if (isNetworkQualityTrigger) {
            // 移除通知，避免通知泄漏
            [self removeEcdhNotification];
        }
        return;
    }
    
    WeakSelf
    NSArray<NoaNetRacingItemModel *> *subArr = racingModel.tcpArr;
    if (subArr.count == 0) {
        // 全部组都没连通，恢复超时并回调失败
        CIMLog(@"全部失败，停止 Tcp 择优");
        IMSDKHTTPTOOL.requestSerializer.timeoutInterval = 60.0;
        [weakSelf.codeBuilder withInitializationErrorType:[InitializationErrorTypes TCP_FAILURE]];
        [weakSelf packageRacingResultWithStep:ZNetRacingStepTcp result:NO racingCode:0 isNetworkQualityTrigger:isNetworkQualityTrigger];
        return;
    }
    
    __block BOOL hasResult     = NO;
    __block NSInteger tryCount  = 0;
    NSMutableArray<NSValue *> *pendingStreams = [NSMutableArray array];
    
    for (NoaNetRacingItemModel *tcpItem in subArr) {
        if (hasResult) break;
        
        NSString *host = @"";
        NSString *port = @"";
        if ([tcpItem.ip containsString:@":"]) {
            NSArray *tcoPortArr = [tcpItem.ip componentsSeparatedByString:@":"];
            if (tcoPortArr.count == 2) {
                host = (NSString *)[tcoPortArr objectAtIndex:0];
                port = (NSString *)[tcoPortArr objectAtIndex:1];
            }
        } else {
            host = tcpItem.ip;
            port = [NSString stringWithFormat:@"%ld",(long)tcpItem.sort];
            //weakSelf.socketHost = realTcpPort;
        }
        
        [self checkTcpConnectivityWithHost:host port:port completion:^(BOOL success, CFWriteStreamRef writeStream) {
            // 无论成功与否，先把刚打开的流收集起来，后面统一清理
            if (writeStream) {
                @synchronized (pendingStreams) {
                    [pendingStreams addObject:[NSValue valueWithPointer:writeStream]];
                }
            }
            
            if (success && !hasResult) {
                @synchronized (weakSelf) {
                    hasResult = YES;
                    CIMLog(@"=======最优Tcp: %@ 端口号:%@", host, port);
                    
                    // 统一关闭并释放所有流
                    [weakSelf _cleanupPendingStreams:pendingStreams];
                    
                    // 恢复 HTTP 全局超时
                    IMSDKHTTPTOOL.requestSerializer.timeoutInterval = 60.0;
                    
                    // 配置 SDK Host & Port
                    NoaIMSocketHostOptions *opt = [NoaIMSocketHostOptions new];
                    opt.socketHost = host;
                    opt.socketPort = [port integerValue];
                    opt.socketOrgName = Z_OrgName;
                    [NoaLocalLogger verbose:[NSString stringWithFormat:@"调用- checkTcpConnectivityWithHost回调(TCP竞速)，无最优节点，使用竞速, ip = %@, port = %ld", opt.socketHost, opt.socketPort]];
                    cim_function_configSocketHost(opt);
                    
                    // 配置用户信息
                    NoaIMSDKUserOptions *uOpt = [NoaIMSDKUserOptions new];
                    uOpt.userToken    = UserManager.userInfo.token;
                    uOpt.userID       = UserManager.userInfo.userUID;
                    uOpt.userNickname = UserManager.userInfo.nickname;
                    uOpt.userAvatar   = UserManager.userInfo.avatar;
                    [IMSDKManager configSDKUserWith:uOpt];
                    
                    // 配置邀请码 & 验证渠道
                    NoaSsoInfoModel *sso = [NoaSsoInfoModel getSSOInfo];
                    [IMSDKManager configSDKLiceseId:sso.liceseId];
                    [IMSDKManager configSDKCaptchaChannel:weakSelf.appSysSetModel.captchaChannel];
                    
                    //                    [weakSelf packageRacingResultWithStep:ZNetRacingStepTcp result:YES racingCode:0 isNetworkQualityTrigger:isNetworkQualityTrigger];
                }
            } else if (!success) {
                // 本次失败，累加计数；全部失败后递归下一组
                tryCount++;
                if (tryCount >= subArr.count && !hasResult) {
                    CIMLog(@"全部失败，停止 Tcp 择优");
                    [weakSelf _cleanupPendingStreams:pendingStreams];
                    IMSDKHTTPTOOL.requestSerializer.timeoutInterval = 60.0;
                    
                    [weakSelf.codeBuilder withInitializationErrorType:[InitializationErrorTypes TCP_FAILURE]];
                    [weakSelf packageRacingResultWithStep:ZNetRacingStepTcp result:NO racingCode:0 isNetworkQualityTrigger:isNetworkQualityTrigger];
                }
            }
        }];
    }
}

#pragma mark - —— 私有：统一关闭并释放所有未清理的 streams ——
- (void)_cleanupPendingStreams:(NSMutableArray<NSValue *> *)pendingStreams {
    @synchronized (pendingStreams) {
        for (NSValue *val in pendingStreams) {
            CFWriteStreamRef s = (CFWriteStreamRef)val.pointerValue;
            if (CFWriteStreamGetStatus(s) != kCFStreamStatusClosed) {
                CFWriteStreamClose(s);
            }
            CFRelease(s);
        }
        [pendingStreams removeAllObjects];
    }
}

- (void)clearConnectLocalStartHostNodeRaceWithIsNetworkQualityTrigger:(BOOL)isNetworkQualityTrigger {
    if (isNetworkQualityTrigger) {
        return;
    }
    NoaSsoInfoModel *ssoInfoModel = [NoaSsoInfoModel getSSOInfo];
    [[MMKV defaultMMKV] removeValueForKey:[NSString stringWithFormat:@"%@%@",CONNECT_LOCAL_CACHE,ssoInfoModel.liceseId]];
    [NoaSsoInfoModel clearSSOInfoWithLiceseId:ssoInfoModel.liceseId];
}

#pragma mark - IP/域名 检查
//对 IP/域名 进行连通性检查
- (void)ipDomainPortConnectCheckWithIpDomainPort:(NSString *)ipDoaminPort
                         isNetworkQualityTrigger:(BOOL)isNetworkQualityTrigger {
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"client" ofType:@"cer"];//cer证书的路径
    NSString *p12Path = [[NSBundle mainBundle] pathForResource:@"client" ofType:@"p12"];//p12证书的路径
    //kit层
    self.cerData = [NSData dataWithContentsOfFile:cerPath];
    self.p12Data = [NSData dataWithContentsOfFile:p12Path];
    self.p12pwd = [NSString getHttpsCerPassword];
    //core层
    IMSDKHTTPTOOL.cerData = [NSData dataWithContentsOfFile:cerPath];
    IMSDKHTTPTOOL.p12Data = [NSData dataWithContentsOfFile:p12Path];
    IMSDKHTTPTOOL.p12pwd = [NSString getHttpsCerPassword];
    
    //ssoInfo
    [IMSDKManager configSDKSsoInfo:[NoaSsoInfoModel getSSOInfoDetailInfo]];
    [IMSDKManager configSDKLiceseId:@""];
    
    
    //http检查
    NSMutableString *httpsUrl = [NSMutableString stringWithFormat:@"https://%@", ipDoaminPort];
    [self checkIpDoaminWithHttpHost:httpsUrl isNetworkQualityTrigger:isNetworkQualityTrigger];
}

//检查http并请求SystemSetting接口
- (void)checkIpDoaminWithHttpHost:(NSString *)httpHost
          isNetworkQualityTrigger:(BOOL)isNetworkQualityTrigger {
    WeakSelf
    IMSDKHTTPTOOL.requestSerializer.timeoutInterval = 20.0;
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.connectionProxyDictionary = @{}; // 关闭系统代理
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://www.baidu.com"] sessionConfiguration:config];
    
    // 如果confighttpSessionManagerCerAndP12Cer没有设置允许无效证书，重新设置
    AFSecurityPolicy *currentPolicy = manager.securityPolicy;
    if (!currentPolicy.allowInvalidCertificates) {
        AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        policy.allowInvalidCertificates = YES; // 允许无效证书（包括自签名证书）
        policy.validatesDomainName = NO;       // 不校验证书中的域名
        [manager setSecurityPolicy:policy];
    }
    
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10;
    NSString *httpUrl = [NSString stringWithFormat:@"%@%@", httpHost, App_Get_System_Setting_Url];
    
    /// Header
    [manager.requestSerializer setValue:@"IOS" forHTTPHeaderField:@"deviceType"];
    NSString *deviceID = [FCUUID uuidForDevice];
    [manager.requestSerializer setValue:deviceID forHTTPHeaderField:@"deviceUuid"];//deviceUuid多租户
    [manager.requestSerializer setValue:Z_OrgName forHTTPHeaderField:@"orgName"];//租户信息
    /** 接口验签 */
    long long timeStamp = [NSDate getCurrentTimeIntervalWithSecond];
    //timestamp
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%lld", timeStamp] forHTTPHeaderField:@"timestamp"];
    //signature
    NSString *signature = [LXChatEncrypt method5:@"getSystemConfig" uri:@"system/v2/getSystemConfig" timestamp:timeStamp];
    [manager.requestSerializer setValue:signature forHTTPHeaderField:@"signature"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"" forKey:@"projectId"];
    __block NSURLSessionDataTask *task = [manager dataTaskWithHTTPMethod:@"POST" URLString:httpUrl parameters:params headers:nil uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NoaHttpResponse *resp = [NoaHttpResponse mj_objectWithKeyValues:responseObject];
        
        if (resp.isHttpSuccess && resp.data != nil) {
            id descryptData = [resp responseDataDescryptWithDataString:resp.data url:httpUrl];
            if (descryptData != nil) {
                if(![descryptData isKindOfClass:[NSDictionary class]]){
                    [strongSelf.codeBuilder withInitializationSubModule:[NSString stringWithFormat:@"%@0",self.subModulesDNSCode]];
                    [strongSelf.codeBuilder withInitializationErrorType:[InitializationErrorTypes HTTP_DECODE_FAILURE]];
                    [strongSelf packageRacingResultWithStep:ZNetRacingStepHttp result:NO racingCode:0 isNetworkQualityTrigger:isNetworkQualityTrigger];
                    return;
                } else {
                    //Kit层
                    strongSelf.apiHost = httpHost;
                    strongSelf.getFileHost = httpHost;
                    strongSelf.uploadfileHost = [NSString stringWithFormat:@"%@/oss", httpHost];
                    //SDK层
                    NoaIMSDKApiOptions *option = [NoaIMSDKApiOptions new];
                    option.imApi = httpHost;
                    option.imOrgName = Z_OrgName;
                    [IMSDKManager configSDKApiWith:option];
                    //获取并保存SystemSetting信息
                    NoaSystemSettingModel *sysSettingModel = [NoaSystemSettingModel mj_objectWithKeyValues:descryptData];
                    strongSelf.appSysSetModel = sysSettingModel;
                    //音视频相关处理
                    [strongSelf callSDKConfig];
                    
                    [IMSDKManager configSDKTenantCode:sysSettingModel.tenantCode];
                    
                    //获取Tcp域名+端口号的List
                    [strongSelf ipDomainGetTcpHostHandleWithHttp:httpHost isNetworkQualityTrigger:isNetworkQualityTrigger];
                    
                }
            } else {
                [strongSelf.codeBuilder withInitializationSubModule:[NSString stringWithFormat:@"%@0",strongSelf.subModulesDNSCode]];
                [strongSelf.codeBuilder withInitializationErrorType:[InitializationErrorTypes HTTP_DECODE_FAILURE]];
                [strongSelf packageRacingResultWithStep:ZNetRacingStepHttp result:NO racingCode:0 isNetworkQualityTrigger:isNetworkQualityTrigger];
                return;
            }
        } else {
            [strongSelf.codeBuilder withInitializationSubModule:[NSString stringWithFormat:@"%@0",strongSelf.subModulesDNSCode]];
            [strongSelf.codeBuilder withInitializationErrorType:[InitializationErrorTypes HTTP_DECODE_FAILURE]];
            [strongSelf packageRacingResultWithStep:ZNetRacingStepHttp result:NO racingCode:0 isNetworkQualityTrigger:isNetworkQualityTrigger];
            return;
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        //日志上传 http竞速失败
        NSMutableDictionary *loganDict = [NSMutableDictionary dictionary];
        [loganDict setObjectSafe:httpHost forKey:@"http"];
        [loganDict setObjectSafe:@(10000) forKey:@"httpCode"];
        [loganDict setObjectSafe:ZTOOL.publicIP forKey:@"publicIp"];
        [loganDict setObjectSafe:[NSString getCurrentNetWorkType] forKey:@"netWorkType"];
        [IMSDKManager imSdkWriteLoganWith:LingIMLoganTypeApi loganContent:[[NoaIMLoganManager sharedManager] configLoganContent:loganDict]];
        IMSDKHTTPTOOL.requestSerializer.timeoutInterval = 60.0;
        CIMLog(@"IP/域名连通性检测全部失败");
        //节点竞速失败回调Block
        [strongSelf.codeBuilder withInitializationSubModule:[NSString stringWithFormat:@"%@0",strongSelf.subModulesDNSCode]];
        [strongSelf.codeBuilder withInitializationErrorType:[InitializationErrorTypes HTTP_FAILURE]];
        [strongSelf packageRacingResultWithStep:ZNetIpDomainStepHttp result:NO racingCode:10000 isNetworkQualityTrigger:isNetworkQualityTrigger];
    }];
    [task resume];
}

//通过http接口获取tcp连接地址和端口号的list
- (void)ipDomainGetTcpHostHandleWithHttp:(NSString *)httpHost
                 isNetworkQualityTrigger:(BOOL)isNetworkQualityTrigger {
    WeakSelf
    [IMSDKManager appNetworkGetConnectListWithBaseUrl:httpHost Path:App_Get_Tcp_Connect_List_Url onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        StrongSelf
        if(![data isKindOfClass:[NSArray class]]){
            // 移除通知，避免通知泄漏
            [strongSelf removeEcdhNotification];
            return;
        }
        NSArray *tcpList = (NSArray *)data;
        if (tcpList.count > 0) {
            //对Tcp进行竞速
            [strongSelf checkIpDoaminWithTcpList:tcpList isNetworkQualityTrigger:isNetworkQualityTrigger];
        } else {
            //TcpList获取失败
            IMSDKHTTPTOOL.requestSerializer.timeoutInterval = 60.0;
            //首次启动
            [strongSelf packageRacingResultWithStep:ZNetIpDomainStepTcp result:NO racingCode:ZHttpRequestCodeTypeSuccess isNetworkQualityTrigger:isNetworkQualityTrigger];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        StrongSelf
        //TcpList获取失败
        //首次启动
        [strongSelf.codeBuilder withInitializationSubModule:@"00"];
        [strongSelf.codeBuilder withInitializationErrorType:[InitializationErrorTypes HTTP_FAILURE]];
        [strongSelf packageRacingResultWithStep:ZNetIpDomainStepTcp result:NO racingCode:code isNetworkQualityTrigger:isNetworkQualityTrigger];
    }];
}

//检查Tcp并请求
- (void)checkIpDoaminWithTcpList:(NSArray *)TcpList
         isNetworkQualityTrigger:(BOOL)isNetworkQualityTrigger  {
    IMSDKHTTPTOOL.requestSerializer.timeoutInterval = 20.0;
    __block BOOL hasResult = NO;
    __block NSInteger tryCount  = 0;
    NSMutableArray<NSValue *> *pendingStreams = [NSMutableArray array];
    for (NSString *tcpHostStr in TcpList) {
        if (hasResult) break;
        
        NSString *host = @"";
        NSString *port = @"";
        NSString *realTcpPort = [tcpHostStr stringByReplacingOccurrencesOfString:@"http://" withString:@""];
        realTcpPort = [realTcpPort stringByReplacingOccurrencesOfString:@"https://" withString:@""];
        if ([realTcpPort containsString:@":"]) {
            NSArray *tcoPortArr = [realTcpPort componentsSeparatedByString:@":"];
            if (tcoPortArr.count == 2) {
                host = (NSString *)[tcoPortArr objectAtIndex:0];
                port = (NSString *)[tcoPortArr objectAtIndex:1];
            }
        } else {
            host = realTcpPort;
            //weakSelf.socketHost = realTcpPort;
        }
        
        WeakSelf
        [self checkTcpConnectivityWithHost:host port:port completion:^(BOOL success, CFWriteStreamRef writeStream) {
            // 无论成功与否，先把刚打开的流收集起来，后面统一清理
            if (writeStream) {
                @synchronized (pendingStreams) {
                    [pendingStreams addObject:[NSValue valueWithPointer:writeStream]];
                }
            }
            
            if (success && !hasResult) {
                @synchronized (weakSelf) {
                    hasResult = YES;
                    CIMLog(@"=======最优Tcp: %@ 端口号:%@", host, port);
                    
                    // 统一关闭并释放所有流
                    [weakSelf _cleanupPendingStreams:pendingStreams];
                    
                    // 恢复 HTTP 全局超时
                    IMSDKHTTPTOOL.requestSerializer.timeoutInterval = 60.0;
                    
                    /// App启动时，节点竞速成功回调Block
                    // 配置 SDK Host & Port
                    NoaIMSocketHostOptions *opt = [NoaIMSocketHostOptions new];
                    opt.socketHost = host;
                    opt.socketPort = [port integerValue];
                    opt.socketOrgName = Z_OrgName;
                    [NoaLocalLogger verbose:[NSString stringWithFormat:@"调用checkIpDoaminWithTcpList:(NSArray *)TcpList isNetworkQualityTrigger:(BOOL)isNetworkQualityTrigger 回调, ip = %@, port = %ld", opt.socketHost, opt.socketPort]];
                    cim_function_configSocketHost(opt);
                    
                    //SDK层用户信息
                    NoaIMSDKUserOptions *userOption = [NoaIMSDKUserOptions new];
                    userOption.userToken = UserManager.userInfo.token;
                    userOption.userID = UserManager.userInfo.userUID;
                    userOption.userNickname = UserManager.userInfo.nickname;
                    userOption.userAvatar = UserManager.userInfo.avatar;
                    [IMSDKManager configSDKUserWith:userOption];
                    [NoaLocalLogger verbose:[NSString stringWithFormat:@"调用IMSDKManager configSDKUserWith - (void)checkIpDoaminWithTcpList:(NSArray *)TcpList isNetworkQualityTrigger:(BOOL)isNetworkQualityTrigger, ip = %@, port = %@", host, port]];
                    [weakSelf packageRacingResultWithStep:ZNetIpDomainStepTcp result:YES racingCode:0 isNetworkQualityTrigger:isNetworkQualityTrigger];
                    [ZTOOL doInMain:^{
                        [HUD hideHUD];
                    }];
                }
            } else if (!success) {
                // 本次失败，累加计数；全部失败后递归下一组
                tryCount++;
                if (tryCount >= TcpList.count && !hasResult) {
                    CIMLog(@"全部失败，停止 Tcp 择优");
                    [weakSelf _cleanupPendingStreams:pendingStreams];
                    IMSDKHTTPTOOL.requestSerializer.timeoutInterval = 60.0;
                    //首次启动
                    [weakSelf packageRacingResultWithStep:ZNetIpDomainStepTcp result:NO racingCode:10000 isNetworkQualityTrigger:isNetworkQualityTrigger];
                    
                    //日志上传 tcp竞速失败
                    NSMutableDictionary *loganDict = [NSMutableDictionary dictionary];
                    [loganDict setObjectSafe:tcpHostStr forKey:@"tcp"];
                    [loganDict setObjectSafe:@(10000) forKey:@"tcpCode"];
                    [loganDict setObjectSafe:ZTOOL.publicIP forKey:@"publicIp"];
                    [loganDict setObjectSafe:[NSString getCurrentNetWorkType] forKey:@"netWorkType"];
                    [IMSDKManager imSdkWriteLoganWith:LingIMLoganTypeHost loganContent:[[NoaIMLoganManager sharedManager] configLoganContent:loganDict]];
                }
            }
        }];
    }
}

#pragma mark - /////////////分割线////////////
//单独进行TCP竞速时，不需要使用信号量来阻塞主线程，避免UI界面出现卡住的现象
#pragma mark - 单独竞速TCP socket需要进行重连
- (void)tcpNodePickOver {
    CIMLog(@"单独竞速TCP socket需要进行重连");
    NoaSsoInfoModel *ssoModel = [NoaSsoInfoModel getSSOInfo];
    if (![NSString isNil:ssoModel.liceseId]) {
        //对Tcp进行竞速(单独竞速TCP不再使用该方法)
        [self tcpNodePickCompanyIdWithSsoModel:ssoModel.ossRacingModel index:0];
        return;
    }else {
        // 非邀请码，不走竞速，需要将线路择优移除，否则会出现ip地址连接不上
        [self stopNetworkQualityDetection];
    }
    
    if (![NSString isNil:ssoModel.ipDomainPortStr]) {
        //单独竞速TCP，不阻塞主线程
        [self tcpNodePickDomainOrIpWithHttp:self.apiHost];
        return;
    }
}

#pragma mark - 单独竞速TCP 邀请码
- (void)tcpNodePickCompanyIdWithSsoModel:(NoaNetRacingModel *)racingModel index:(NSInteger)index  {
    WeakSelf
    if (index < racingModel.tcpArr.count) {
        NSArray *subArr = racingModel.tcpArr;
        __block BOOL hasResult = NO;
        __block NSInteger tryCount  = 0;
        NSMutableArray<NSValue *> *pendingStreams = [NSMutableArray array];
        for (NoaNetRacingItemModel *tcpItem in subArr) {
            if (hasResult) break;
            
            NSString *host = @"";
            NSString *port = @"";
            NSString *realTcpPort = [tcpItem.ip stringByReplacingOccurrencesOfString:@"http://" withString:@""];
            realTcpPort = [realTcpPort stringByReplacingOccurrencesOfString:@"https://" withString:@""];
            if ([realTcpPort containsString:@":"]) {
                NSArray *tcoPortArr = [realTcpPort componentsSeparatedByString:@":"];
                if (tcoPortArr.count == 2) {
                    host = (NSString *)[tcoPortArr objectAtIndex:0];
                    port = (NSString *)[tcoPortArr objectAtIndex:1];
                }
            } else {
                host = tcpItem.ip;
                port = [NSString stringWithFormat:@"%ld",(long)tcpItem.sort];
                //weakSelf.socketHost = realTcpPort;
            }
            
            [self checkTcpConnectivityWithHost:host port:port completion:^(BOOL success, CFWriteStreamRef writeStream) {
                StrongSelf
                // 无论成功与否，先把刚打开的流收集起来，后面统一清理
                if (writeStream) {
                    @synchronized (pendingStreams) {
                        [pendingStreams addObject:[NSValue valueWithPointer:writeStream]];
                    }
                }
                
                if (success && !hasResult) {
                    @synchronized (weakSelf) {
                        hasResult = YES;
                        CIMLog(@"=======最优Tcp: %@ 端口号:%@", host, port);
                        
                        // 统一关闭并释放所有流
                        [weakSelf _cleanupPendingStreams:pendingStreams];
                        
                        // 恢复 HTTP 全局超时
                        IMSDKHTTPTOOL.requestSerializer.timeoutInterval = 60.0;
                        
                        // 配置 SDK Host & Port
                        NoaIMSocketHostOptions *opt = [NoaIMSocketHostOptions new];
                        opt.socketHost = host;
                        opt.socketPort = [port integerValue];
                        opt.socketOrgName = Z_OrgName;
                        [NoaLocalLogger verbose:[NSString stringWithFormat:@"调用tcpNodePickCompanyIdWithSsoModel:(NoaNetRacingModel *)racingModel index:(NSInteger)index回调, ip = %@, port = %ld", opt.socketHost, opt.socketPort]];
                        cim_function_configSocketHost(opt);
                        
                        //设置SDK层用户信息
                        NoaIMSDKUserOptions *userOption = [NoaIMSDKUserOptions new];
                        userOption.userToken = UserManager.userInfo.token;
                        userOption.userID = UserManager.userInfo.userUID;
                        userOption.userNickname = UserManager.userInfo.nickname;
                        userOption.userAvatar = UserManager.userInfo.avatar;
                        [IMSDKManager configSDKUserWith:userOption];
                        [NoaLocalLogger verbose:[NSString stringWithFormat:@"调用IMSDKManager configSDKUserWith - (void)tcpNodePickCompanyIdWithSsoModel:(NoaNetRacingModel *)racingModel index:(NSInteger)index, ip = %@, port = %@", host, port]];
                        [ZTOOL doInMain:^{
                            [HUD hideHUD];
                        }];
                    }
                } else if (!success) {
                    //日志上传 http竞速失败
                    NSMutableDictionary *loganDict = [NSMutableDictionary dictionary];
                    [loganDict setObjectSafe:[NSString stringWithFormat:@"%@%@",host,port] forKey:@"tcp"];
                    [loganDict setObjectSafe:@(0) forKey:@"tcpCode"];
                    [loganDict setObjectSafe:ZTOOL.publicIP forKey:@"publicIp"];
                    [loganDict setObjectSafe:[NSString getCurrentNetWorkType] forKey:@"netWorkType"];
                    [IMSDKManager imSdkWriteLoganWith:LingIMLoganTypeApi loganContent:[[NoaIMLoganManager sharedManager] configLoganContent:loganDict]];
                    // 本次失败，累加计数；全部失败后递归下一组
                    tryCount++;
                    if (tryCount == subArr.count && !hasResult) {
                        //重新请求下一组
                        [strongSelf tcpNodePickCompanyIdWithSsoModel:racingModel index:index + 1];
                    }
                }
            }];
        }
    } else {
        //停止节点择优
        CIMLog(@"全部失败，停止Tcp单独竞速");
        [ZTOOL doInMain:^{
            [HUD hideHUD];
        }];
        //非首次启动
        [IMSDKManager reconnectedSDK];
    }
}

#pragma mark - 单独竞速TCP IP/域名 直连
//先获取Tcp域名+端口号的List
- (void)tcpNodePickDomainOrIpWithHttp:(NSString *)httpHost {
    WeakSelf
    [IMSDKManager appNetworkGetConnectListWithBaseUrl:httpHost Path:App_Get_Tcp_Connect_List_Url onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if(![data isKindOfClass:[NSArray class]]){
            return;
        }
        NSArray *tcpList = (NSArray *)data;
        if (tcpList.count > 0) {
            //对Tcp进行竞速
            [weakSelf tcpNodePickOverTCPListWithList:tcpList];
        } else {
            //非首次启动
            [IMSDKManager reconnectedSDK];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        //非首次启动
        [IMSDKManager reconnectedSDK];
    }];
}

//对获取到的tcpList进行竞速
- (void)tcpNodePickOverTCPListWithList:(NSArray *)tcpList {
    WeakSelf
    if (tcpList.count > 0) {
        __block BOOL hasResult = NO;
        __block NSInteger tryCount  = 0;
        NSMutableArray<NSValue *> *pendingStreams = [NSMutableArray array];
        for (NSString *tcpHostStr in tcpList) {
            if (hasResult) break;
            
            NSString *host = @"";
            NSString *port = @"";
            
            //去掉 http:// 和 https://
            NSString *realTcpPort = [tcpHostStr stringByReplacingOccurrencesOfString:@"http://" withString:@""];
            realTcpPort = [realTcpPort stringByReplacingOccurrencesOfString:@"https://" withString:@""];
            if ([realTcpPort containsString:@":"]) {
                NSArray *tcoPortArr = [realTcpPort componentsSeparatedByString:@":"];
                if (tcoPortArr.count == 2) {
                    host = (NSString *)[tcoPortArr objectAtIndex:0];
                    port = (NSString *)[tcoPortArr objectAtIndex:1];
                }
            } else {
                host = realTcpPort;
            }
            
            [self checkTcpConnectivityWithHost:host port:port completion:^(BOOL success, CFWriteStreamRef writeStream) {
                // 无论成功与否，先把刚打开的流收集起来，后面统一清理
                if (writeStream) {
                    @synchronized (pendingStreams) {
                        [pendingStreams addObject:[NSValue valueWithPointer:writeStream]];
                    }
                }
                
                if (success && !hasResult) {
                    @synchronized (weakSelf) {
                        hasResult = YES;
                        CIMLog(@"=======最优Tcp: %@ 端口号:%@", host, port);
                        
                        // 统一关闭并释放所有流
                        [weakSelf _cleanupPendingStreams:pendingStreams];
                        
                        // 恢复 HTTP 全局超时
                        IMSDKHTTPTOOL.requestSerializer.timeoutInterval = 60.0;
                        
                        // 配置 SDK Host & Port
                        NoaIMSocketHostOptions *opt = [NoaIMSocketHostOptions new];
                        opt.socketHost = host;
                        opt.socketPort = [port integerValue];
                        opt.socketOrgName = Z_OrgName;
                        [NoaLocalLogger verbose:[NSString stringWithFormat:@"调用tcpNodePickCompanyIdWithSsoModel:(NoaNetRacingModel *)racingModel index:(NSInteger)index回调, ip = %@, port = %ld", opt.socketHost, opt.socketPort]];
                        cim_function_configSocketHost(opt);
                        
                        //SDK层用户信息
                        NoaIMSDKUserOptions *userOption = [NoaIMSDKUserOptions new];
                        userOption.userToken = UserManager.userInfo.token;
                        userOption.userID = UserManager.userInfo.userUID;
                        userOption.userNickname = UserManager.userInfo.nickname;
                        userOption.userAvatar = UserManager.userInfo.avatar;
                        [IMSDKManager configSDKUserWith:userOption];
                        [NoaLocalLogger verbose:[NSString stringWithFormat:@"调用IMSDKManager configSDKUserWith - (void)tcpNodePickOverTCPListWithList:(NSArray *)tcpList, ip = %@, port = %@", host, port]];
                        
                    }
                } else if (!success) {
                    // 本次失败，累加计数；全部失败后递归下一组
                    tryCount++;
                    if (tryCount >= tcpList.count && !hasResult) {
                        CIMLog(@"全部失败，停止 Tcp 择优");
                        [weakSelf _cleanupPendingStreams:pendingStreams];
                        IMSDKHTTPTOOL.requestSerializer.timeoutInterval = 60.0;
                        [IMSDKManager reconnectedSDK];
                    }
                }
            }];
        }
    }
}

#pragma mark <每5分钟获取一次最新的SystemConfig>
- (void)refreshSystemConfig {
    WeakSelf
    
    // 生成 3~8 分钟之间的随机数（秒数）
    uint32_t minDelay = 3 * 60;   // 3分钟
    uint32_t maxDelay = 8 * 60;   // 8分钟
    NSTimeInterval delayTime = (NSTimeInterval)(minDelay + arc4random_uniform(maxDelay - minDelay + 1));
    
    // 定时器间隔时间，这里也用 3~8 分钟随机（如果你只想第一次随机，后面固定，就写固定值）
    NSTimeInterval timeInterval = (NSTimeInterval)(minDelay + arc4random_uniform(maxDelay - minDelay + 1));
    
    
    if (UserManager.isLogined) {
        [weakSelf requestTimedRefreshUserRoleAuthority];
    }
    
    // 创建子线程队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _refreshSystemConfigTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    // 设置延时执行时间
    dispatch_time_t startDelayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC));
    dispatch_source_set_timer(_refreshSystemConfigTimer, startDelayTime, timeInterval * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
    
    dispatch_source_set_event_handler(_refreshSystemConfigTimer, ^{
        // 刷新 systemConfig
        [weakSelf requestTimedRefreshSystemConfigInfo];
        if (UserManager.isLogined) {
            //刷新用户角色权限
            [weakSelf requestTimedRefreshUserRoleAuthority];
            //刷新群会员等级配置信息
            [weakSelf requestTimedRefreshGroupActivityConfigInfo];
            //刷新敏感词
            [weakSelf refreshAppSensitive];
        }
    });
    
    // 启动计时器
    dispatch_resume(_refreshSystemConfigTimer);
}



//刷新敏感词syncAppSensitiveFromServer
- (void)refreshAppSensitive {
    [IMSDKManager syncAppSensitiveFromServer];
}

#pragma mark - 竞速成功后请求systemConfig接口
- (void)requestSystemConfigInfo {
    CIMLog(@"[Socket-ECDH] 🎯 收到 socketECDHDidConnectSuccese 通知，开始请求 systemConfig");
    
    WeakSelf
    [IMSDKManager appGetSystemConfigInfoWithBaseUrl:self.apiHost
                                               Path:App_Get_System_Setting_Url
                                            IsLogin:UserManager.isLogined
                                          onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        CIMLog(@"[Socket-ECDH] ✅ systemConfig 请求成功");
        if(![data isKindOfClass:[NSDictionary class]]){
            return;
        }
        // 解析并保存 SystemSetting 信息
        BOOL oldAV = weakSelf.appSysSetModel ? [weakSelf.appSysSetModel.enableAudioAndVideoCalls isEqualToString:@"1"] || [weakSelf.appSysSetModel.enableAudioAndVideoCalls isEqualToString:@"true"] : YES;
        
        NoaSystemSettingModel *newModel = [NoaSystemSettingModel mj_objectWithKeyValues:data];
        weakSelf.appSysSetModel = newModel;
        
        // 音视频通话开关变更通知（保持原有逻辑）
        BOOL newAV = [newModel.enableAudioAndVideoCalls isEqualToString:@"1"] || [newModel.enableAudioAndVideoCalls isEqualToString:@"true"];
        if (oldAV != newAV) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AppSystemConfigEnableAudioAndVideoCalls" object:nil];
        }
        [weakSelf callSDKConfig];
        [IMSDKManager configSDKCaptchaChannel:newModel.captchaChannel];
        [IMSDKManager configSDKTenantCode:newModel.tenantCode];
        [weakSelf packageRacingResultWithStep:ZNetRacingStepTcp result:YES racingCode:0 isNetworkQualityTrigger:NO];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [self.codeBuilder withInitializationErrorType:[InitializationErrorTypes systemConfig_failure]];
        [weakSelf packageRacingResultWithStep:ZNetRacingStepTcp result:NO racingCode:0 isNetworkQualityTrigger:NO];
    }];
}
// system接口失败
- (void)systemConfigFailure {
    CIMLog(@"[Socket-ECDH] ❌ 收到 socketECDHDidConnectFailure 通知，连接失败");
    [self.codeBuilder withInitializationErrorType:[InitializationErrorTypes TCP_FAILURE]];
    [self packageRacingResultWithStep:ZNetRacingStepTcp result:NO racingCode:0 isNetworkQualityTrigger:NO];
}

//刷新systemConfig
- (void)requestTimedRefreshSystemConfigInfo {
    WeakSelf
    [IMSDKManager appGetSystemConfigInfoWithBaseUrl:self.apiHost
                                               Path:App_Get_System_Setting_Url
                                            IsLogin:UserManager.isLogined
                                          onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if(![data isKindOfClass:[NSDictionary class]]){
            return;
        }
        // 解析并保存 SystemSetting 信息
        BOOL oldAV = weakSelf.appSysSetModel ? [weakSelf.appSysSetModel.enableAudioAndVideoCalls isEqualToString:@"1"] || [weakSelf.appSysSetModel.enableAudioAndVideoCalls isEqualToString:@"true"] : YES;
        
        NoaSystemSettingModel *newModel = [NoaSystemSettingModel mj_objectWithKeyValues:data];
        weakSelf.appSysSetModel = newModel;
        
        // 音视频通话开关变更通知（保持原有逻辑）
        BOOL newAV = [newModel.enableAudioAndVideoCalls isEqualToString:@"1"] || [newModel.enableAudioAndVideoCalls isEqualToString:@"true"];
        if (oldAV != newAV) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AppSystemConfigEnableAudioAndVideoCalls" object:nil];
        }
        
        [IMSDKManager configSDKCaptchaChannel:newModel.captchaChannel];
        [IMSDKManager configSDKTenantCode:newModel.tenantCode];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
    }];
}

//刷新用户角色权限
- (void)requestTimedRefreshUserRoleAuthority {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    [IMSDKManager userGetRoleAuthorityListWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDic = (NSDictionary *)data;
            NoaUserRoleAuthorityModel *userRoleAuthInfo = [NoaUserRoleAuthorityModel mj_objectWithKeyValues:dataDic];
            NSString *oldUpFileValue = UserManager.userRoleAuthInfo.upFile.configValue;
            NSString *oldDeleteMessageVaule = UserManager.userRoleAuthInfo.deleteMessage.configValue;
            NSString *oldShowTeamVaule = UserManager.userRoleAuthInfo.showTeam.configValue;
            NSString *oldUpImageVideoValue = UserManager.userRoleAuthInfo.upImageVideoFile.configValue;
            NSString *oldFileHelperValue = UserManager.userRoleAuthInfo.isShowFileAssistant.configValue;
            NSString *oldTranslateSwitch = UserManager.userRoleAuthInfo.translationSwitch.configValue;
            
            // 默认开启：后端缺失时置为 true
            if (!userRoleAuthInfo.translationSwitch || [NSString isNil:userRoleAuthInfo.translationSwitch.configValue]) {
                NoaUsereAuthModel *model = [NoaUsereAuthModel new];
                model.configValue = @"true";
                userRoleAuthInfo.translationSwitch = model;
            }
            UserManager.userRoleAuthInfo = userRoleAuthInfo;
            if (![oldUpFileValue isEqualToString:UserManager.userRoleAuthInfo.upFile.configValue]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UserRoleAuthorityUploadFileChangeNotification" object:nil];
            }
            if (![oldDeleteMessageVaule isEqualToString:UserManager.userRoleAuthInfo.deleteMessage.configValue]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UserRoleAuthorityDeleteMessageChangeNotification" object:nil];
            }
            if (![oldShowTeamVaule isEqualToString:UserManager.userRoleAuthInfo.showTeam.configValue]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UserRoleAuthorityShowTeamChangeNotification" object:nil];
            }
            if (![oldUpImageVideoValue isEqualToString:UserManager.userRoleAuthInfo.upImageVideoFile.configValue]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UserRoleAuthorityUpImageVideoFileChangeNotification" object:nil];
            }
            if (![oldFileHelperValue isEqualToString:UserManager.userRoleAuthInfo.isShowFileAssistant.configValue]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UserRoleAuthorityFileHelperChangeNotification" object:nil];
            }
            if (![oldTranslateSwitch isEqualToString:UserManager.userRoleAuthInfo.translationSwitch.configValue]) {
                BOOL enabled = [UserManager.userRoleAuthInfo.translationSwitch.configValue isEqualToString:@"true"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UserRoleAuthorityTranslateFlagDidChange" object:nil userInfo:@{ @"enabled": @(enabled) }];
            }
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
    }];
}

//刷新群会员等级配置信息
- (void)requestTimedRefreshGroupActivityConfigInfo {
    [[NoaIMSDKManager sharedTool] groupGetActivityLevelConfigWith:nil onSuccess:^(id  _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)data;
            NoaGroupActivityInfoModel *activityConfinModel = [NoaGroupActivityInfoModel mj_objectWithKeyValues:dict];
            NSArray *levelnfoArr = [activityConfinModel.levels copy];
            activityConfinModel.sortLevels = [levelnfoArr sortedArrayUsingComparator:^NSComparisonResult(NoaGroupActivityLevelModel *obj1, NoaGroupActivityLevelModel *obj2) {
                if (obj1.minScore < obj2.minScore) {
                    return NSOrderedAscending;
                } else if (obj1.minScore > obj2.minScore) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedSame;
                }
            }];
            UserManager.activityConfigInfo = activityConfinModel;
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
    }];
}

#pragma mark - /////////////分割线/////////////

#pragma mark - 网络请求(单独一个网络请求，不受封装AFNetWorking影响)
- (NSURLSessionDataTask *)filtrateNetWorkWithUrl:(NSString *)urlStr compelete:(void(^)(NSInteger code, NSString *msg, NSData *data, NSString *traceId))compelete {
    NSString *traceId = [[NoaIMManagerTool sharedManager] getMessageID];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    [request setValue:traceId forHTTPHeaderField:@"ZTID"];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    config.URLCache = nil;
    config.connectionProxyDictionary = @{}; // 关闭系统代理
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        if (error == nil && (long)httpResponse.statusCode == 200) {
            compelete(httpResponse.statusCode, @"-", data, traceId);
        } else {
            if (error == nil) {
                compelete(httpResponse.statusCode, @"", nil, traceId);
            } else {
                NSString *errorDescription = [NSString isNil:[error localizedDescription]] ? @"-" : [error localizedDescription];
                compelete(error.code, errorDescription, nil, traceId);
            }
            
        }
    }];
    [dataTask resume];
    return dataTask;
}

- (void)checkNetWorkWithUrl:(ProxyType)currentType compelete:(void(^)(NSInteger code, NSString *msg, NSData *data, NSString *traceId))compelete {
    
    NSString *traceId = [[NoaIMManagerTool sharedManager] getMessageID];
    
    NSURL *url = [NSURL URLWithString:@"http://example.com"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    config.URLCache = nil;
    if (currentType == ProxyTypeHTTP) {
        NoaProxySettings *setting = [[MMKV defaultMMKV] getObjectOfClass:[NoaProxySettings class] forKey:HTTP_PROXY_KEY];
        config.connectionProxyDictionary = @{
            // 开启 HTTP 代理
            (__bridge id)kCFNetworkProxiesHTTPEnable: @YES,
            // 代理服务器地址和端口
            (__bridge id)kCFNetworkProxiesHTTPProxy: setting.address,
            (__bridge id)kCFNetworkProxiesHTTPPort: @([setting.port intValue]),
            
            // 代理认证（可选）
            (__bridge id)kCFProxyUsernameKey: setting.username,
            (__bridge id)kCFProxyPasswordKey: setting.password
        };
    } else if (currentType == ProxyTypeSOCKS5) {
        NoaProxySettings *setting = [[MMKV defaultMMKV] getObjectOfClass:[NoaProxySettings class] forKey:SOCKS_PROXY_KEY];
        config.connectionProxyDictionary = @{
            (__bridge NSString *)kCFStreamPropertySOCKSProxyHost: setting.address,
            (__bridge NSString *)kCFStreamPropertySOCKSProxyPort: @([setting.port intValue]),
            (__bridge NSString *)kCFStreamPropertySOCKSUser: setting.username,        // 如果需要
            (__bridge NSString *)kCFStreamPropertySOCKSPassword: setting.password      // 如果需要
        };
    }
    
    
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        if (error == nil && (long)httpResponse.statusCode == 200) {
            compelete(httpResponse.statusCode, @"-", data, traceId);
        } else {
            if (error == nil) {
                compelete(httpResponse.statusCode, @"", nil, traceId);
            } else {
                NSString *errorDescription = [NSString isNil:[error localizedDescription]] ? @"-" : [error localizedDescription];
                compelete(error.code, errorDescription, nil, traceId);
            }
            
        }
    }];
    [dataTask resume];
    
    
}

#pragma mark - —— TCP 直连检测方法 ——
/// host: 域名或 IP，port: 端口号，
/// completion 回调 success 标示连通与否，writeStream 用于后续统一关闭
- (void)checkTcpConnectivityWithHost:(NSString *)host
                                port:(NSString *)port
                          completion:(void(^)(BOOL success, CFWriteStreamRef writeStream))completion
{
    // 使用 SDKCore 提供的探测API，避免直接依赖私有头
    uint16_t portValue = (uint16_t)[port integerValue];
    [[NoaIMSDKManager sharedTool] probeECDHConnectivityWithHost:host port:portValue timeout:-1 type:0 completion:^(BOOL success, LingIMSDKManagerProbeECDHConnectStatus status) {
        if (completion) {
            completion(success, NULL);
        }
    }];
}



#pragma mark - 竞速结果出来后，发送通知，通知相应页面进行相关UI展示
- (void)packageRacingResultWithStep:(ZNetRacingStep)step
                             result:(BOOL)result
                         racingCode:(NSInteger)racingCode
            isNetworkQualityTrigger:(BOOL)isNetworkQualityTrigger {
    // 移除通知，避免通知泄漏
    [self removeEcdhNotification];
    
    if (isNetworkQualityTrigger) {
        return;
    }
    
    if (self.isReloadRacing) {
        //跳转到竞速失败View，重新加载
        if (result) {
            [ZTOOL doInMain:^{
                if (UserManager.isLogined) {
                    // 已登录用户在线路恢复后统一回到 Worker Flutter 主页面。
                    [ZTOOL setupWorkerUI];
                } else {
                    //Login & Register
                    [ZTOOL setupLoginUI];
                }
            }];
        } else {
            [self racingErrorInfoHandleWithStep:step result:result racingCode:racingCode];
            [self clearConnectLocalStartHostNodeRaceWithIsNetworkQualityTrigger:isNetworkQualityTrigger];
        }
    } else {
        [self racingErrorInfoHandleWithStep:step result:result racingCode:racingCode];
        [self clearConnectLocalStartHostNodeRaceWithIsNetworkQualityTrigger:isNetworkQualityTrigger];
    }
    if (result) {
        [ZTOOL doInMain:^{
            // 竞速成功后更新日志模块（使用持久化或默认 publishUrlOriginal）
            NSString *loganURL = [ZTOOL loganEffectivePublishURL];
            [ZTOOL reloadLoganIfNeededWithPublishURL:loganURL];
            
        }];
        //获取角色配置
        [self requestGetRoleConfigInfo];
        //在后台定时对节点进行择优排序
        [self scheduledNodePreferAction];
    }
}

- (void)racingErrorInfoHandleWithStep:(ZNetRacingStep)step result:(BOOL)result racingCode:(NSInteger)racingCode {
    NSString *codeString = [self.codeBuilder build];
    if (self.isReloadRacing) {
        if (step == ZNetRacingStepOss) {
            NSInteger tempRacingCode = racingCode;
            self.ossErrorNum++;
            if (self.ossErrorNum > OSS_ERROR_MAX_NUM && (racingCode == 404 || racingCode == 403)) {
                //节点竞速失败回调Block
                tempRacingCode = 100000;
            }
            //日志上报
            [self uploadErrorlogan];
            //跳转到竞速失败页
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObjectSafe:[NSNumber numberWithInteger:step] forKey:@"step"];
            [dict setObjectSafe:[NSNumber numberWithInteger:tempRacingCode] forKey:@"code"];
            [ZTOOL setupRacingErroUIWithResutl:dict];
        } else {
            //日志上报
            [self uploadErrorlogan];
            //跳转到竞速失败页
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObjectSafe:[NSNumber numberWithInteger:step] forKey:@"step"];
            [dict setObjectSafe:[NSNumber numberWithInteger:racingCode] forKey:@"code"];
            [ZTOOL setupRacingErroUIWithResutl:dict];
        }
    } else {
        if (step == ZNetRacingStepOss) {
            NSInteger tempRacingCode = racingCode;
            self.ossErrorNum++;
            if (self.ossErrorNum > OSS_ERROR_MAX_NUM && (racingCode == 404 || racingCode == 403)) {
                //节点竞速失败回调Block
                tempRacingCode = 100000;
            }
            //日志上报
            [self uploadErrorlogan];
            //在sso输入界面提示错误信息
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObjectSafe:[NSNumber numberWithInteger:step] forKey:@"step"];
            [dict setObjectSafe:[NSNumber numberWithBool:result] forKey:@"result"];
            [dict setObjectSafe:[NSNumber numberWithInteger:tempRacingCode] forKey:@"code"];
            [dict setObjectSafe:codeString forKey:@"errorCode"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AppSsoRacingAndIpDomainConectResultNotification" object:nil userInfo:dict];
            
        } else {
            //日志上报
            [self uploadErrorlogan];
            //在sso输入界面提示错误信息
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObjectSafe:[NSNumber numberWithInteger:step] forKey:@"step"];
            [dict setObjectSafe:[NSNumber numberWithBool:result] forKey:@"result"];
            [dict setObjectSafe:[NSNumber numberWithInteger:racingCode] forKey:@"code"];
            [dict setObjectSafe:codeString forKey:@"errorCode"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AppSsoRacingAndIpDomainConectResultNotification" object:nil userInfo:dict];
        }
    }
    
}

/// 使用邀请码启动五路 DNS/DoH 并发解析及后续直连竞速。
/// - Parameters:
///   - licenseId: 当前用户输入并保存的邀请码，不能为空。
///   - isNetworkQualityTrigger: 是否由网络质量检测触发；该值会继续传递给直连竞速，用于控制失败提示和页面跳转。
- (void)startCompanyIdRaceWithLicenseId:(NSString *)licenseId networkQualityTrigger:(BOOL)isNetworkQualityTrigger {
    WeakSelf
    [IMSDKManager configLoganLiceseId:licenseId];
    //邀请码，走oss、http、tcp 竞速择优
    self.racingType = ZReacingTypeCompanyId;
    // 初始化五源并发控制
    self.ossFirstSuccessGlobal = NO;
    self.builtInOssHttpFallbackTried = NO;
    self.multiSourceActive = YES;
    self.multiSourceFinishedCount = 0;
    self.multiSourceDirectFailCount = 0;
    self.multiSourceTotalCount = 5; // ALIDNS + AliDoH TXT + CF TXT + CF AAAA + Tencent DoH AAAA
    NSInteger raceSession = self.currentRaceSessionId; // 捕获本轮会话ID
    dispatch_group_t group = dispatch_group_create();

    void (^consumeList)(NSArray<NoaUrlHostModel *> *, NSString *sourceTag) = ^(NSArray<NoaUrlHostModel *> *list, NSString *sourceTag){
        if (!weakSelf.multiSourceActive) return;
        if (raceSession != weakSelf.currentRaceSessionId) return;
        if (list.count <= 0) {
            @synchronized (weakSelf) {
                weakSelf.multiSourceFinishedCount++;
                weakSelf.multiSourceDirectFailCount++;
            }

            // 五源全部为空时触发 Resolver 兜底
            @synchronized (weakSelf) {
                if (!weakSelf.ossFirstSuccessGlobal && weakSelf.multiSourceFinishedCount >= weakSelf.multiSourceTotalCount) {
                    CIMLog(@"[DNS并发] 五源均无结果，触发 Resolver 旧逻辑兜底");
                    BOOL isProxyFB = ([ZTOOL getCurrentProxyType] == ProxyTypeSOCKS5);
                    [weakSelf getDirectOssUrlListFromDNSComplete:^(NSArray<NoaUrlHostModel *> *ossUrlList) {
                        NSArray<NoaUrlHostModel *> *normalizedFB = [weakSelf normalizeDomainToIP:ossUrlList];
                        [weakSelf netWorkDirectWithFiltrateBestOssRacingWithOssList:normalizedFB iscontinue:!isProxyFB allowFallbackRetry:YES sourceTag:@"OLDRESOLVER" isNetworkQualityTrigger:isNetworkQualityTrigger];
                    }];
                }
            }
            return;
        }
        NSArray<NoaUrlHostModel *> *normalized = [weakSelf normalizeDomainToIP:list];
        if (normalized.count <= 0) {
            @synchronized (weakSelf) {
                weakSelf.multiSourceFinishedCount++;
                weakSelf.multiSourceDirectFailCount++;
            }
            // 五源全部 normalize 为空时触发 Resolver 兜底
            @synchronized (weakSelf) {
                if (!weakSelf.ossFirstSuccessGlobal && weakSelf.multiSourceFinishedCount >= weakSelf.multiSourceTotalCount) {
                    CIMLog(@"[DNS并发] 五源均无可用 normalize 结果，触发 Resolver 旧逻辑兜底");
                    BOOL isProxyFB = ([ZTOOL getCurrentProxyType] == ProxyTypeSOCKS5);
                    [weakSelf getDirectOssUrlListFromDNSComplete:^(NSArray<NoaUrlHostModel *> *ossUrlList) {
                        NSArray<NoaUrlHostModel *> *normalizedFB = [weakSelf normalizeDomainToIP:ossUrlList];
                        [weakSelf netWorkDirectWithFiltrateBestOssRacingWithOssList:normalizedFB iscontinue:!isProxyFB allowFallbackRetry:YES sourceTag:@"OLDRESOLVER" isNetworkQualityTrigger:isNetworkQualityTrigger];
                    }];
                }
            }
            return;
        }
        @synchronized (weakSelf) {
            if (raceSession != weakSelf.currentRaceSessionId) return;
            if (weakSelf.ossFirstSuccessGlobal) return;
            BOOL isProxy = ([ZTOOL getCurrentProxyType] == ProxyTypeSOCKS5);
            CIMLog(@"[DNS并发] 源%@ 返回可用 %lu 条，开始直连竞速", sourceTag, (unsigned long)normalized.count);
            [weakSelf netWorkDirectWithFiltrateBestOssRacingWithOssList:normalized iscontinue:!isProxy allowFallbackRetry:NO sourceTag:sourceTag isNetworkQualityTrigger:isNetworkQualityTrigger];
        }
    };

    void (^recordError)(NSString *) = ^(NSString *msg){
        CIMLog(@"[DNS并发] 源失败: %@", msg);
    };

    // Resolver DNS（阿里解析器）
    dispatch_group_enter(group);
    [self getDirectOssUrlListFromALIDNSComplete:^(NSArray<NoaUrlHostModel *> *ossUrlList) {
        CIMLog(@"DNS结果 阿里AAAA:%@",ossUrlList);
        consumeList(ossUrlList, @"ALIDNS");
        dispatch_group_leave(group);
    }];

    // 腾讯 DoH AAAA
    dispatch_group_enter(group);
    [self getDirectOssUrlListFromTencentDoHAAAAComplete:^(NSArray<NoaUrlHostModel *> *ossUrlList) {
        CIMLog(@"DNS结果 腾讯AAAA:%@",ossUrlList);
        consumeList(ossUrlList, @"TENCENT_AAAA");
        dispatch_group_leave(group);
    }];

    // Cloudflare DoH TXT
    dispatch_group_enter(group);
    [self getDirectOssUrlListFromCloudflareTXTComplete:^(NSArray<NoaUrlHostModel *> *ossUrlList) {
        CIMLog(@"DNS结果 CloudflareTXT:%@",ossUrlList);
        consumeList(ossUrlList, @"CF_TXT");
        dispatch_group_leave(group);
    }];

    // Cloudflare DoH AAAA
    dispatch_group_enter(group);
    [self getDirectOssUrlListFromCloudflareAAAAComplete:^(NSArray<NoaUrlHostModel *> *ossUrlList) {
        CIMLog(@"DNS结果 CloudflareAAAA:%@",ossUrlList);
        consumeList(ossUrlList, @"CF_AAAA");
        dispatch_group_leave(group);
    }];

    // Ali DoH TXT
    dispatch_group_enter(group);
    [self getDirectOssUrlListFromAliDoHTXTComplete:^(NSArray<NoaUrlHostModel *> *ossUrlList) {
        CIMLog(@"DNS结果 阿里TXT:%@",ossUrlList);
        consumeList(ossUrlList, @"ALI_DOH_TXT");
        dispatch_group_leave(group);
    }];

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (raceSession != weakSelf.currentRaceSessionId) {
            CIMLog(@"[竞速会话] 分组完成但已过期，忽略");
            return;
        }
        // 仅结束分组，不在此触发兜底，兜底在源级失败收敛中触发
        weakSelf.isRacing = NO;
    });
}

//主动上报日志
- (void)uploadErrorlogan {

    //上传前一天的日志
    NSDate *todayDate = [NSDate date];
    NSDate *lastDayDate = [NSDate dateWithTimeInterval:-24 * 60 * 60 sinceDate:todayDate];
    NSString *lastDayDateStr = [lastDayDate dateForStringWith:@"yyyy-MM-dd"];
    [IMSDKManager imSdkUploadLoganWith:lastDayDateStr complete:^(NSError * _Nullable error) {
    }];
    
}

//在后台定时对节点进行择优排序
- (void)scheduledNodePreferAction {
    NoaSsoInfoModel *ssoModel = [NoaSsoInfoModel getSSOInfo];
    if (ssoModel.ossRacingModel.is_merge_version) {
        if (![self compareOssHttpNodeContent:ssoModel.ossRacingModel.oldHttpNodeArr new:ssoModel.ossRacingModel.httpNodeArr]) {
            NSMutableArray *nodeResultList = [NSMutableArray array];
            for (int i = 0; i < ssoModel.ossRacingModel.httpNodeArr.count; i++) {
                NSString *httpHost = (NSString *)[ssoModel.ossRacingModel.httpNodeArr objectAtIndexSafe:i];
                NSMutableDictionary *nodeInfoDic = [NSMutableDictionary dictionary];
                [nodeInfoDic setObjectSafe:httpHost forKey:@"node"];
                [nodeInfoDic setObjectSafe:@(0) forKey:@"successNum"];
                [nodeInfoDic setObjectSafe:@(0.0) forKey:@"successTotlaTime"];
                [nodeInfoDic setObjectSafe:@(NO) forKey:@"lastState"];
                [nodeResultList addObject:nodeInfoDic];
            }
            NSString *key = [NSString stringWithFormat:@"nodePreferResult_%@", ssoModel.liceseId];
            [[MMKV defaultMMKV] setObject:nodeResultList forKey:key];
            
            ssoModel.ossRacingModel.oldHttpNodeArr = ssoModel.ossRacingModel.httpNodeArr;
            [ssoModel saveSSOInfo];
        } else {
            NSString *key = [NSString stringWithFormat:@"nodePreferResult_%@", ssoModel.liceseId];
            NSMutableArray *nodeResultList = [[MMKV defaultMMKV] getObjectOfClass:[NSMutableArray class] forKey:key];
            if (nodeResultList == nil) {
                NSMutableArray *nodeResultList = [NSMutableArray array];
                for (int i = 0; i < ssoModel.ossRacingModel.httpNodeArr.count; i++) {
                    NSString *httpHost = (NSString *)[ssoModel.ossRacingModel.httpNodeArr objectAtIndexSafe:i];
                    NSMutableDictionary *nodeInfoDic = [NSMutableDictionary dictionary];
                    [nodeInfoDic setObjectSafe:httpHost forKey:@"node"];
                    [nodeInfoDic setObjectSafe:@(0) forKey:@"successNum"];
                    [nodeInfoDic setObjectSafe:@(0.0) forKey:@"successTotlaTime"];
                    [nodeInfoDic setObjectSafe:@(NO) forKey:@"lastState"];
                    [nodeResultList addObject:nodeInfoDic];
                }
                NSString *key = [NSString stringWithFormat:@"nodePreferResult_%@", ssoModel.liceseId];
                [[MMKV defaultMMKV] setObject:nodeResultList forKey:key];
                
                ssoModel.ossRacingModel.oldHttpNodeArr = ssoModel.ossRacingModel.httpNodeArr;
                [ssoModel saveSSOInfo];
            }
        }
        //需要定时节点择优
        if (self.nodePreferTools == nil) {
            self.nodePreferTools = [[NoaNodePreferTools alloc] init];
        }
        self.nodePreferTools.liceseId = ssoModel.liceseId;
        self.nodePreferTools.preferDuring = ssoModel.ossRacingModel.ping_interval_second;
        self.nodePreferTools.httpArr = ssoModel.ossRacingModel.httpNodeArr;
        [self.nodePreferTools startNodePrefer];
    }
}

#pragma mark - 音视频SDK相关的处理
- (void)callSDKConfig {
    if (_appSysSetModel) {
        if ([_appSysSetModel.video_source_config isEqualToString:@"0"]) {
            //LiveKit SDK
        } else if ([_appSysSetModel.video_source_config isEqualToString:@"1"]) {
            //即构 SDK
            NoaIMZGCallConfig *config = [NoaIMZGCallConfig new];
            config.configAppId = (unsigned)[_appSysSetModel.video_source_config_zg_appId longLongValue];
            config.configAppSign = _appSysSetModel.video_source_config_zg_appSign;
            config.configServerSecret = _appSysSetModel.video_source_config_zg_server_secret;
            config.configCallbackSecret = _appSysSetModel.video_source_config_zg_callback_secret;
            config.configServerAddress = _appSysSetModel.video_source_config_zg_server_address;
            config.configServerAddressBackup = _appSysSetModel.video_source_config_zg_websocket_server_address_backup;
            [NoaCallManager sharedManager].callSDKType = LingIMCallSDKTypeZego;
            [[NoaCallManager sharedManager] callSdkConfigWith:config];
        }
    }
}

//#pragma mark - 配置网络请求库实现双向认证证书配置
//配置confighttpSessionManagerSecurityPolicy的安全策略
- (void)confighttpSessionManagerCerAndP12Cer:(AFHTTPSessionManager *)manager isIPAddress:(BOOL)isIPAddress {
    if (isIPAddress == NO) {
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        [manager setSecurityPolicy:securityPolicy];
    } else {
        if(self.cerData && self.p12Data && self.p12pwd){
            //安全模式设置：AFSSLPinningModeNone：完全信任服务器证书
            AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
            
            // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
            // 如果是需要验证自建证书，需要设置为YES
            securityPolicy.allowInvalidCertificates = YES;
            
            //validatesDomainName 是否需要验证域名，默认为YES；
            //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
            //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
            //如置为NO，建议自己添加对应域名的校验逻辑。
            securityPolicy.validatesDomainName = NO;
            NSData * cerWithData = [NSData dataWithData:self.cerData];
            securityPolicy.pinnedCertificates = [NSSet setWithArray:@[cerWithData]];
            
            [manager setSecurityPolicy:securityPolicy];
            
            
            //配置p12证书
            [manager setSessionDidBecomeInvalidBlock:^(NSURLSession * _Nonnull session, NSError * _Nonnull error) {
                
            }];
            [manager setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession*session, NSURLAuthenticationChallenge *challenge, NSURLCredential *__autoreleasing*_credential) {
                NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
                __autoreleasing NSURLCredential *credential =nil;
                // CIMLog(@"authenticationMethod=%@",challenge.protectionSpace.authenticationMethod);
                SecIdentityRef identity = NULL;
                SecTrustRef trust = NULL;
                
                if(!self.p12Data)
                {
                    CIMLog(@"p12data:not exist");
                }else
                {
                    NSData *PKCS12Data = [NSData dataWithData:self.p12Data];//self.p12Data;
                    
                    if ([self extractIdentity:&identity andTrust:&trust fromPKCS12Data:PKCS12Data])
                    {
                        SecCertificateRef certificate = NULL;
                        SecIdentityCopyCertificate(identity, &certificate);
                        const void*certs[] = {certificate};
                        CFArrayRef certArray =CFArrayCreate(kCFAllocatorDefault, certs,1,NULL);
                        credential =[NSURLCredential credentialWithIdentity:identity certificates:(__bridge  NSArray*)certArray persistence:NSURLCredentialPersistencePermanent];
                        disposition =NSURLSessionAuthChallengeUseCredential;
                    }
                }
                //      }
                *_credential = credential;
                return disposition;
            }];
        }
    }
    [self configSDWebImageHttpsVertifyisIPAddress:isIPAddress];
}

#pragma mark - 配置SDWebImage实现https双向认证
- (void)configSDWebImageHttpsVertifyisIPAddress:(BOOL)isIPAddress {
    if (isIPAddress) {
        [SDWebImageDownloaderConfig defaultDownloaderConfig].urlCredential = [self myURLCredential];
    }
}

//由p12文件转出NSURLCredential
- (NSURLCredential *)myURLCredential {
    if(!self.p12Data){
        return nil;
    }
    SecIdentityRef identity = NULL;
    SecTrustRef trust = NULL;
    NSData * p12WithData = [NSData dataWithData:self.p12Data];
    [self extractIdentity:&identity andTrust:&trust fromPKCS12Data:p12WithData];
    SecCertificateRef certificate = NULL;
    if (identity == nil) {
        return nil;
    }
    SecIdentityCopyCertificate(identity, &certificate);
    const void *certs[] = {certificate};
    CFArrayRef cerArray = CFArrayCreate(kCFAllocatorMalloc, certs, 1, NULL);
    return [NSURLCredential credentialWithIdentity:identity certificates:(__bridge NSArray *)cerArray persistence:NSURLCredentialPersistencePermanent];
}

//读取p12文件中的密码
- (BOOL)extractIdentity:(SecIdentityRef*)outIdentity andTrust:(SecTrustRef *)outTrust fromPKCS12Data:(NSData *)inPKCS12Data {
    OSStatus securityError = errSecSuccess;
    //client certificate password
    NSDictionary *optionsDictionary = [NSDictionary dictionaryWithObject:self.p12pwd
                                                                  forKey:(__bridge id)kSecImportExportPassphrase];
    
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    securityError = SecPKCS12Import((__bridge CFDataRef)inPKCS12Data,(__bridge CFDictionaryRef)optionsDictionary,&items);
    
    if(securityError == 0) {
        CFDictionaryRef myIdentityAndTrust =CFArrayGetValueAtIndex(items,0);
        const void*tempIdentity =NULL;
        tempIdentity= CFDictionaryGetValue (myIdentityAndTrust,kSecImportItemIdentity);
        *outIdentity = (SecIdentityRef)tempIdentity;
        const void*tempTrust =NULL;
        tempTrust = CFDictionaryGetValue(myIdentityAndTrust,kSecImportItemTrust);
        *outTrust = (SecTrustRef)tempTrust;
    } else {
        CIMLog(@"Failedwith error code %d",(int)securityError);
        return NO;
    }
    return YES;
}

#pragma mark - 获取用户角色配置信息
- (void)requestGetRoleConfigInfo {
    [IMSDKManager imGetRoleConfigInfoWith:nil onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        CIMLog(@"[权限请求]获取权限接口成功");
        if ([data isKindOfClass:[NSArray class]]) {
            NSArray *dataArr = (NSArray *)data;
            NSArray *roleConfigArr = [NoaRoleConfigModel mj_objectArrayWithKeyValuesArray:dataArr];
            if (roleConfigArr != nil && roleConfigArr.count > 0) {
                NSMutableDictionary *roleConfigDict = [NSMutableDictionary dictionary];
                for (NoaRoleConfigModel *roleModel in roleConfigArr) {
                    [roleConfigDict setObjectSafe:roleModel forKey:[NSNumber numberWithInteger:roleModel.roleId]];
                }
                [UserManager setRoleConfigDict:roleConfigDict];
            }
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        // 目前来看此接口容易报错，故增加重试机制
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CIMLog(@"[权限请求]获取权限接口失败，8秒开始重试");
            [self requestGetRoleConfigInfo];
        });
    }];
}

- (ErrorCodeBuilder *)codeBuilder {
    if (!_codeBuilder) {
        _codeBuilder = [ErrorCodeBuilder create];
        [_codeBuilder withModule:[ErrorModules INITIALIZATION]];
    }
    return _codeBuilder;
}


#pragma mark - 强化的SSL错误处理

/**
 * 配置强化的SSL错误处理
 * 专门解决SSL握手失败(-9816)和证书验证失败(-1200/-1202)问题
 */
- (void)configureEnhancedSSLHandling:(AFHTTPSessionManager *)manager requestHost:(NSString *)requestHost {
    @try {
        // 1. 配置最宽松的安全策略
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        securityPolicy.allowInvalidCertificates = YES;  // 允许无效证书
        securityPolicy.validatesDomainName = NO;        // 不验证域名
        [manager setSecurityPolicy:securityPolicy];
        
        // 2. 配置SSL会话回调处理
        [manager setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(
                                                                                                        NSURLSession *session,
                                                                                                        NSURLAuthenticationChallenge *challenge,
                                                                                                        NSURLCredential **credential) {
                                                                                                            
                                                                                                            NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
                                                                                                            
                                                                                                            if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
                                                                                                                CIMLog(@"🔍 处理SSL服务器信任挑战: %@", challenge.protectionSpace.host);
                                                                                                                
                                                                                                                // 获取服务器信任对象
                                                                                                                SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
                                                                                                                if (serverTrust) {
                                                                                                                    // 创建凭据，直接信任服务器
                                                                                                                    NSURLCredential *serverCredential = [NSURLCredential credentialForTrust:serverTrust];
                                                                                                                    if (serverCredential) {
                                                                                                                        *credential = serverCredential;
                                                                                                                        disposition = NSURLSessionAuthChallengeUseCredential;
                                                                                                                        CIMLog(@"✅ 接受服务器SSL证书: %@", challenge.protectionSpace.host);
                                                                                                                    } else {
                                                                                                                        CIMLog(@"❌ 无法创建服务器SSL凭据");
                                                                                                                        disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
                                                                                                                    }
                                                                                                                } else {
                                                                                                                    CIMLog(@"❌ 服务器信任对象为空");
                                                                                                                    disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
                                                                                                                }
                                                                                                            } else if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate]) {
                                                                                                                CIMLog(@"🔐 处理客户端证书认证挑战");
                                                                                                                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
                                                                                                            }
                                                                                                            
                                                                                                            return disposition;
                                                                                                        }];
        
        // 3. 配置SSL错误处理
        [manager setSessionDidBecomeInvalidBlock:^(NSURLSession *session, NSError *error) {
            if (error) {
                CIMLog(@"❌ SSL会话无效: %@", error.localizedDescription);
                CIMLog(@"   错误码: %ld", (long)error.code);
                CIMLog(@"   错误域: %@", error.domain);
            }
        }];
        
        // 4. 配置请求序列化器
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.requestSerializer.timeoutInterval = 10.0; // 增加超时时间
        
        // 5. 配置响应序列化器
        AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
        responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                     @"application/json",
                                                     @"text/json",
                                                     @"text/javascript",
                                                     @"text/html",
                                                     @"text/plain",
                                                     nil];
        manager.responseSerializer = responseSerializer;
        
        CIMLog(@"✅ 强化SSL配置完成: %@", requestHost);
        
    } @catch (NSException *exception) {
        CIMLog(@"❌ SSL配置异常: %@", exception.reason);
        
        // 降级到最基本的配置
        AFSecurityPolicy *fallbackPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        fallbackPolicy.allowInvalidCertificates = YES;
        fallbackPolicy.validatesDomainName = NO;
        [manager setSecurityPolicy:fallbackPolicy];
        
        CIMLog(@"⚠️ 使用降级SSL配置");
    }
}

/**
 * 配置SSL重试机制
 * 当SSL连接失败时自动重试
 */
- (void)configureSSLRetryMechanism:(AFHTTPSessionManager *)manager {
    // 设置重试策略
    [manager setTaskDidCompleteBlock:^(NSURLSession *session, NSURLSessionTask *task, NSError *error) {
        if (error && (error.code == -1200 || error.code == -1202 || error.code == -9816)) {
            CIMLog(@"🔄 检测到SSL错误，准备重试: %@", error.localizedDescription);
            
            // 这里可以添加重试逻辑
            // 注意：重试应该在调用方处理，这里只是记录日志
        }
    }];
}

/**
 * 创建支持SSL错误处理的HTTP管理器
 * @param requestHost 请求主机地址
 * @return 配置好的AFHTTPSessionManager实例
 */
- (AFHTTPSessionManager *)createSSLCompatibleHTTPManager:(NSString *)requestHost {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.connectionProxyDictionary = @{}; // 关闭系统代理
    
    // 配置SSL相关的会话设置
    config.TLSMinimumSupportedProtocol = kTLSProtocol1; // 支持TLS 1.0及以上版本
    config.TLSMaximumSupportedProtocol = kTLSProtocol13; // 支持到TLS 1.3
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]
                                     initWithBaseURL:[NSURL URLWithString:@"https://www.baidu.com"]
                                     sessionConfiguration:config];
    
    // 应用强化的SSL配置
    [self configureEnhancedSSLHandling:manager requestHost:requestHost];
    
    return manager;
}

/**
 * 测试SSL连接是否正常
 * @param urlString 要测试的URL
 * @param completion 完成回调
 */
- (void)testSSLConnection:(NSString *)urlString completion:(void(^)(BOOL success, NSError *error))completion {
    if (!urlString || urlString.length == 0) {
        if (completion) completion(NO, [NSError errorWithDomain:@"SSLTest" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"URL不能为空"}]);
        return;
    }
    
    CIMLog(@"🧪 开始测试SSL连接: %@", urlString);
    
    AFHTTPSessionManager *manager = [self createSSLCompatibleHTTPManager:urlString];
    
    // 创建一个简单的GET请求来测试连接
    NSURLSessionDataTask *task = [manager GET:urlString parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        CIMLog(@"✅ SSL连接测试成功: %@", urlString);
        if (completion) completion(YES, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        CIMLog(@"❌ SSL连接测试失败: %@", urlString);
        CIMLog(@"   错误: %@", error.localizedDescription);
        CIMLog(@"   错误码: %ld", (long)error.code);
        if (completion) completion(NO, error);
    }];
    
    if (!task) {
        CIMLog(@"❌ 无法创建SSL测试任务");
        if (completion) completion(NO, [NSError errorWithDomain:@"SSLTest" code:-2 userInfo:@{NSLocalizedDescriptionKey: @"无法创建测试任务"}]);
    }
}

#pragma mark - 网络质量检测集成

/// 启动网络质量检测
- (void)startNetworkQualityDetection:(NSString *)liceseId {
    [NoaLocalLogger info:@"[网络检测启动] 启动网络质量检测"];
    
    // 检查邀请码是否有变化
    BOOL isLicenseIdChanged = ![liceseId isEqualToString:self.networkQualityDetector.currentLiceseId] && self.networkQualityDetector.currentLiceseId.length > 0;
    
    // 检查服务器列表是否有差异
    BOOL isServerListChanged = [self hasServerListChanged];
    
    // 根据检查结果决定是否停止检测
    if (isLicenseIdChanged) {
        [NoaLocalLogger info:@"[网络检测启动] 邀请码发生变化，停止当前检测"];
        [self stopNetworkQualityDetection];
    }
    
    if (isServerListChanged) {
        [NoaLocalLogger info:@"[网络检测启动] 服务器列表发生变化，停止当前检测"];
        [self stopNetworkQualityDetection];
    }
    
    // 修改当前正在网络环境质量检测的邀请码值
    self.networkQualityDetector.currentLiceseId = liceseId;
    
    // 更新服务器列表
    [self.networkQualityDetector updateServerLists:self.tcpDomainList];
    
    // 启动检测
    [self.networkQualityDetector startNetworkQualityDetection];
}

/// 停止网络质量检测
- (void)stopNetworkQualityDetection {
    CIMLog(@"[网络检测] 停止网络质量检测");
    [self.networkQualityDetector stopNetworkQualityDetection];
}

#pragma mark - ZNetworkQualityDetectorDelegate

/// 网络质量检测完成回调
- (void)networkQualityDetector:(NoaNetworkQualityDetector *)detector didCompleteProbeWithResults:(NSArray<NoaNetworkQualityResult *> *)results {
    CIMLog(@"[网络检测] 检测完成，共 %lu 个结果", (unsigned long)results.count);
    
    NSMutableString *logString = [NSMutableString stringWithString:@"[网络检测] 质量统计 (已按质量排序):\n"];
    
    // 直接输出排序后的结果
    for (NSInteger i = 0; i < results.count; i++) {
        NoaNetworkQualityResult *result = results[i];
        [logString appendFormat:@"  %ld. %@:%d (%@) - 延迟: %.1fms, 可用: %@, 评分: %ld, 连续失败: %ld, 连续高延迟: %ld\n",
         (long)(i + 1), result.endpoint.ip, result.endpoint.port, result.probeType,
         result.latency, result.isAvailable ? @"是" : @"否", (long)result.qualityScore,
         (long)result.consecutiveFailures, (long)result.consecutiveHighLatency];
    }
    
    CIMLog(@"%@", logString);
}

/// 网络质量异常回调
- (void)networkQualityDetector:(NoaNetworkQualityDetector *)detector didDetectException:(NoaNetworkQualityException *)exception {
    CIMLog(@"[网络检测] 检测到异常: %@", exception.exceptionDescription);
    
    // 根据异常类型进行相应处理
    switch (exception.exceptionType) {
        case ZNetworkQualityExceptionTypeHighLatency:
            CIMLog(@"[网络检测] 高延迟异常，延迟: %.1fms", [exception.exceptionData[@"latency"] doubleValue]);
            break;
            
        case ZNetworkQualityExceptionTypeConsecutiveHighLatency:
            CIMLog(@"[网络检测] 连续高延迟异常，连续次数: %ld", (long)[exception.exceptionData[@"consecutiveCount"] integerValue]);
            break;
            
        case ZNetworkQualityExceptionTypeConsecutiveFailures:
            CIMLog(@"[网络检测] 连续失败异常，连续次数: %ld", (long)[exception.exceptionData[@"consecutiveCount"] integerValue]);
            break;
            
        case ZNetworkQualityExceptionTypeNetworkTypeChanged:
            CIMLog(@"[网络检测] 网络类型变化异常: %@ -> %@",
                  exception.exceptionData[@"oldNetworkType"], exception.exceptionData[@"newNetworkType"]);
            break;
            
        case ZNetworkQualityExceptionTypeIPAddressChanged:
            CIMLog(@"[网络检测] IP地址变化异常: %@ -> %@",
                  exception.exceptionData[@"oldIPAddress"], exception.exceptionData[@"newIPAddress"]);
            break;
            
        case ZNetworkQualityExceptionTypeAllServersUnreachable:
            CIMLog(@"[网络检测] 所有服务器不可达异常");
            break;
            
            // 时间相关异常处理已移除 - 由外部组件处理
            
        default:
            CIMLog(@"[网络检测] 其他异常类型: %ld", (long)exception.exceptionType);
            break;
    }
}

/// 网络质量检测所有接口失败回调
- (void)networkQualityDetector:(NoaNetworkQualityDetector *)detector didFailWithError:(NSError *)error {
    if (!UserManager.isLogined) {
        [NoaLocalLogger info:@"[网络变化] 用户未登录，不处理网络变化(不执行竞速)"];
        return;
    };
    
    NSInteger errorCode = error.code;
    [NoaLocalLogger error:[NSString stringWithFormat:@"[网络检测] 当前网络质量检测所有接口都失败了，errorCode: %ld, error说明: %@", errorCode, error.localizedDescription]];
    BOOL isConnectNet = [[NetWorkStatusManager shared] getConnectStatus];
    if (isConnectNet) {
        // 重新开始竞速
        self.isNeedReNode = NO;
        [self hostNodeRaceWithNetworkQuality];
    }else {
        self.isNeedReNode = YES;
    }
}

#pragma mark - 前后台监听处理
- (void)applicationDidEnterBackground:(NSNotification *)notification {
    
    if (!UserManager.isLogined) {
        [NoaLocalLogger info:@"[APP前台进入后台] 用户未登录，不处理进入后台逻辑(不执行计时器，不标记竞速)"];
        return;
    };
    
    // 标记程序进入前台
    self.isInBackground = YES;
    // 创建后台计时器，5秒后输出日志
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.backgroundTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(self.backgroundTimer, dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 0);
    
    WeakSelf
    dispatch_source_set_event_handler(self.backgroundTimer, ^{
        // 取消计时器
        self.isNeedReNode = YES;
        dispatch_source_cancel(weakSelf.backgroundTimer);
        weakSelf.backgroundTimer = nil;
    });
    
    dispatch_resume(self.backgroundTimer);
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    
    if (!UserManager.isLogined) {
        [NoaLocalLogger info:@"[APP后台进入前台] 用户未登录，不处理进入前台逻辑(不执行竞速)"];
        return;
    };
    
    // 标记程序进入前台
    self.isInBackground = NO;
    // 取消后台计时器
    if (self.backgroundTimer) {
        dispatch_source_cancel(self.backgroundTimer);
        self.backgroundTimer = nil;
    }
    
    // 判断是否需要重新竞速
    if (!self.isNeedReNode) {
        return;
    }
    
    BOOL isConnectNet = [[NetWorkStatusManager shared] getConnectStatus];
    if (isConnectNet) {
        // 重新开始竞速
        [NoaLocalLogger info:@"[APP后台进入前台] 检测到有网，开始竞速"];
        self.isNeedReNode = NO;
        [self hostNodeRaceWithNetworkQuality];
    }else {
        [NoaLocalLogger info:@"[APP后台进入前台] 检测到无网络，标记等待竞速"];
        self.isNeedReNode = YES;
    }
}

#pragma mark - 监听网络状态是否可用
- (void)networkChange:(NSNotification *)notification {
    
    if (!UserManager.isLogined) {
        [NoaLocalLogger info:@"[网络变化] 用户未登录，不处理网络变化(不执行竞速)"];
        return;
    };
    
    BOOL isConnectNet = [[NetWorkStatusManager shared] getConnectStatus];
    if (isConnectNet) {
        // 重新开始竞速
        [NoaLocalLogger info:@"[网络变化] 网络由无网变为有网，开始竞速"];
        self.isNeedReNode = NO;
        [self hostNodeRaceWithNetworkQuality];
    }else {
        [NoaLocalLogger error:@"[网络变化] 网络由有网变为无网，标记等待竞速"];
        self.isNeedReNode = YES;
    }
}

#pragma mark - 服务器列表比较

/// 检查服务器列表是否有变化
- (BOOL)hasServerListChanged {
    // 如果networkQualityDetector的tcpServers为空，认为有变化
    if (!self.networkQualityDetector.tcpServers || self.networkQualityDetector.tcpServers.count == 0) {
        return YES;
    }
    
    // 如果当前tcpDomainList为空，认为有变化
    if (!self.tcpDomainList || self.tcpDomainList.count == 0) {
        return YES;
    }
    
    // 比较数量
    if (self.tcpDomainList.count != self.networkQualityDetector.tcpServers.count) {
        return YES;
    }
    
    // 比较每个服务器的IP和端口
    for (NSInteger i = 0; i < self.tcpDomainList.count; i++) {
        IMServerEndpoint *currentServer = self.tcpDomainList[i];
        IMServerEndpoint *detectorServer = self.networkQualityDetector.tcpServers[i];
        
        // 比较IP地址
        if (![currentServer.ip isEqualToString:detectorServer.ip]) {
            return YES;
        }
        
        // 比较端口号
        if (currentServer.port != detectorServer.port) {
            return YES;
        }
    }
    
    // 完全一致
    return NO;
}

#pragma mark - GaOnchain
- (void)startGaOnchain {
    CIMLog(@"[GaOnchain] 开始执行GaOnchain方法");
    self.gaOnchainManager = [NoaGaOnchainManager new];
    
    NSError *error = nil;
    OCConfig *ocConfig = [self.gaOnchainManager loadConfigAndReturnError:&error];
    if (error) {
        CIMLog(@"[GaOnchain] 读取ocConfig失败，error = %@", error);
        return;
    }
    
    // 保存所有请求任务的数组
    NSMutableArray <NSURLSessionDataTask *>*tasks = [NSMutableArray new];
    
    // 用于标记是否已经有成功的请求
    __block BOOL hasSuccess = NO;
    
    // 用于跟踪失败的请求数量
    __block NSInteger failureCount = 0;
    
    // 使用锁来保证线程安全
    NSLock *lock = [NSLock new];
    
    // 总请求数量
    NSInteger totalCount = ocConfig.rpcNodes.count;
    
    // 并发请求所有 RPC 节点
    for (NSString *rpcUrl in ocConfig.rpcNodes) {
        CIMLog(@"[GaOnchain] 发起请求到: %@", rpcUrl);
        __block NSURLSessionDataTask *currentTask = nil;
        
        currentTask = [self.gaOnchainManager getValueWithTaskWithRpcUrl:rpcUrl completion:^(NSString * _Nullable responseStr, NSError * _Nullable error) {
            // 检查是否已经有成功的请求
            [lock lock];
            BOOL shouldProcess = !hasSuccess;
            NSArray<NSURLSessionDataTask *> *allTasks = [tasks copy];  // 保存当前所有任务的副本
            NSInteger taskId = currentTask ? currentTask.taskIdentifier : -1;  // 获取当前任务的 ID
            [lock unlock];
            
            // 如果已经有成功的请求，不再处理这个回调
            if (!shouldProcess) {
                CIMLog(@"[GaOnchain] 已经有成功的请求，不再处理");
                return;
            }
            
            if ([NSString isNil:responseStr]) {
                CIMLog(@"[GaOnchain] 解密后的字符串为空，认为失败");
                return;
            }
            
            if (error) {
                // 请求失败
                [lock lock];
                failureCount++;
                NSInteger currentFailureCount = failureCount;
                [lock unlock];
                
                if (currentFailureCount >= totalCount) {
                    CIMLog(@"[GaOnchain] GaOnchain方法全部失败");
                    
                    // 上报 Sentry GaOnchain 失败
                    NSMutableDictionary *failureDict = [NSMutableDictionary dictionary];
                    [failureDict setValue:rpcUrl forKey:@"rpcUrl"];
                    [ZTOOL sentryUploadWithDictionary:failureDict sentryUploadType:ZSentryGaOnChainFailed errorCode:@"999999"];
                    
                    return;
                }
            }
            
            [lock lock];
            if (!hasSuccess) {
                hasSuccess = YES;
            }
            [lock unlock];
            
            // 非空校验
            responseStr = [NSString isNil:responseStr] ? @"" : responseStr;
            CIMLog(@"[GaOnchain] 请求成功，rpcUrl = %@, responseStr = %@", rpcUrl, responseStr);
            
            // 上报 Sentry GaOnchain 成功
            NSMutableDictionary *successDict = [NSMutableDictionary dictionary];
            [successDict setValue:rpcUrl forKey:@"rpcUrl"];
            [successDict setValue:responseStr forKey:@"response"];
            [ZTOOL sentryUploadWithDictionary:successDict sentryUploadType:ZSentryGaOnChainSuccess errorCode:@"0"];
            
            // 取消所有其他任务
            for (NSURLSessionDataTask *otherTask in allTasks) {
                // 通过比较 taskIdentifier 来区分不同的任务
                if (otherTask.taskIdentifier != taskId &&
                    otherTask.state != NSURLSessionTaskStateCanceling &&
                    otherTask.state != NSURLSessionTaskStateCompleted) {
                    [otherTask cancel];
                    CIMLog(@"[GaOnchain] 已取消任务: %lu", (unsigned long)otherTask.taskIdentifier);
                }
            }
        }];
        
        if (!currentTask) {
            // 因为方法中，如果个别参数异常，不会创建NSURLSessionDataTask，会直接返回nil
            CIMLog(@"[GaOnchain] 创建请求任务失败,rpcUrl = %@", rpcUrl);
            [lock lock];
            failureCount++;
            NSInteger currentFailureCount = failureCount;
            [lock unlock];
            
            if (currentFailureCount >= totalCount) {
                CIMLog(@"[GaOnchain] GaOnchain方法全部失败");
                
                // 上报 Sentry GaOnchain 失败
                NSMutableDictionary *failureDict = [NSMutableDictionary dictionary];
                [failureDict setValue:rpcUrl forKey:@"rpcUrl"];
                [ZTOOL sentryUploadWithDictionary:failureDict sentryUploadType:ZSentryGaOnChainFailed errorCode:@"999999"];
                
                return;
            }
        }
        
        // 将task添加到数组中
        [lock lock];
        [tasks addObject:currentTask];
        [lock unlock];
    }
}

@end
