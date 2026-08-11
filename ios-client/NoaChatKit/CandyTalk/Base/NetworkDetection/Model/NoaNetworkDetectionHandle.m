//
//  NoaNetworkDetectionHandle.m
//  NoaChatKit
//
//  Created by phl on 2025/10/15.
//  TODO: 网络检测工具类

#import "NoaNetworkDetectionHandle.h"
#import "NoaNetworkDetectionMessageModel.h"
#import "AliyCloundDNSDecoder.h"
#import <pdns-sdk-ios/DNSResolver.h>
#import "NoaNetworkQualityDetector.h"
#import "NoaFallbackEndpointStore.h"

@interface NoaNetworkDetectionHandle ()

/// 当前邀请码(未登录时可为空)
@property (nonatomic, copy, readwrite, nullable) NSString *currentSsoNumber;

/// 检测状态
@property (nonatomic, assign, readwrite) ZNetworkDetectionStatus networkDetectionStatus;

/// oss直连获取到的url列表
@property (nonatomic, strong) NSMutableArray <NoaUrlHostModel *> *ossUrlList;

/// 导航tcp节点结果
@property (nonatomic, strong) NSMutableArray <NoaNetRacingItemModel *> *tcpRacingResultArr;

/// startDetectionCommand 的订阅者，用于在检测完成时发送完成信号
@property (nonatomic, strong) id<RACSubscriber> detectionCommandSubscriber;

/// 公网IP获取任务数组，用于取消旧任务
@property (nonatomic, strong) NSMutableArray<NSURLSessionDataTask *> *publicIPTasks;

/// 公网IP获取的版本号，用于区分不同批次的请求
@property (nonatomic, assign) NSInteger publicIPRequestVersion;

// MARK: 网络检测相关
/// 开始网络检测信号
@property (nonatomic, strong) RACSubject *startNetworkStatusDetectionSubject;

/// 开始域名解析检测信号
@property (nonatomic, strong) RACSubject *startDomainNameResolutionDetectionSubject;

/// 开始导航解析检测信号
@property (nonatomic, strong) RACSubject *startNavConnectDetectionSubject;

/// 开始服务器连接解析检测信号
@property (nonatomic, strong) RACSubject *startServerConnectDetectionSubject;

/// 导航检测结果事件信号(检测结果通知上层处理数据)
@property (nonatomic, strong) RACSubject *navDetectionEventSubject;

/// 服务器链接检测结果事件信号(检测结果通知上层处理数据)
@property (nonatomic, strong) RACSubject *serverDetectionEventSubject;

// MARK: 取消和清理相关
/// 用于管理所有订阅，页面销毁时统一取消
/// RACCompoundDisposable 可以添加多个 RACDisposable，统一管理
@property (nonatomic, strong) RACCompoundDisposable *allSubscriptionsDisposable;

@property (nonatomic, strong) NSMutableArray<dispatch_block_t> *tasks;

@end

@implementation NoaNetworkDetectionHandle

// MARK: set/get
- (RACCommand *)startDetectionCommand {
    if (!_startDetectionCommand) {
        @weakify(self)
        _startDetectionCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                @strongify(self)
                
                // 清理上次数据
                [self cancelAllDetections];
                
                // 保存订阅者，在检测完成时发送完成信号(切记在清理之前调用，因为清理的时候会把这个对象置为nil)
                self.detectionCommandSubscriber = subscriber;
                
                // 触发网络检测
                [self startNetworkDetection];
                
                return [RACDisposable disposableWithBlock:^{
                    @strongify(self)
                    // 清理订阅者引用
                    self.detectionCommandSubscriber = nil;
                }];
            }];
        }];
    }
    return _startDetectionCommand;
}

- (RACSubject *)startNetworkStatusDetectionSubject {
    if (!_startNetworkStatusDetectionSubject) {
        _startNetworkStatusDetectionSubject = [RACSubject subject];
    }
    return _startNetworkStatusDetectionSubject;
}

- (RACSubject *)startDomainNameResolutionDetectionSubject {
    if (!_startDomainNameResolutionDetectionSubject) {
        _startDomainNameResolutionDetectionSubject = [RACSubject subject];
    }
    return _startDomainNameResolutionDetectionSubject;
}

- (RACSubject *)startNavConnectDetectionSubject {
    if (!_startNavConnectDetectionSubject) {
        _startNavConnectDetectionSubject = [RACSubject subject];
    }
    return _startNavConnectDetectionSubject;
}

- (RACSubject *)startServerConnectDetectionSubject {
    if (!_startServerConnectDetectionSubject) {
        _startServerConnectDetectionSubject = [RACSubject subject];
    }
    return _startServerConnectDetectionSubject;
}

- (RACSubject *)navDetectionEventSubject {
    if (!_navDetectionEventSubject) {
        _navDetectionEventSubject = [RACSubject subject];
    }
    return _navDetectionEventSubject;
}

- (RACSubject *)serverDetectionEventSubject {
    if (!_serverDetectionEventSubject) {
        _serverDetectionEventSubject = [RACSubject subject];
    }
    return _serverDetectionEventSubject;
}

- (RACSubject *)headerViewReloadDataSubject {
    if (!_headerViewReloadDataSubject) {
        _headerViewReloadDataSubject = [RACSubject subject];
    }
    return _headerViewReloadDataSubject;
}

- (RACSubject *)tableViewReloadDataSubject {
    if (!_tableViewReloadDataSubject) {
        _tableViewReloadDataSubject = [RACSubject subject];
    }
    return _tableViewReloadDataSubject;
}

- (NSMutableArray *)tableDataSource {
    if (!_tableDataSource) {
        _tableDataSource = [NSMutableArray new];
    }
    return _tableDataSource;
}

- (NSMutableArray<NoaUrlHostModel *> *)ossUrlList {
    if (!_ossUrlList) {
        _ossUrlList = [NSMutableArray new];
    }
    return _ossUrlList;
}

- (NSMutableArray<NoaNetRacingItemModel *> *)tcpRacingResultArr {
    if (!_tcpRacingResultArr) {
        _tcpRacingResultArr = [NSMutableArray new];
    }
    return _tcpRacingResultArr;
}

- (RACCompoundDisposable *)allSubscriptionsDisposable {
    if (!_allSubscriptionsDisposable) {
        _allSubscriptionsDisposable = [RACCompoundDisposable compoundDisposable];
    }
    return _allSubscriptionsDisposable;
}

- (NSMutableArray<dispatch_block_t> *)tasks {
    if (!_tasks) {
        _tasks = [NSMutableArray new];
    }
    return _tasks;
}

/// 初始化网络检测数据。
/// @param ssoNumber 当前邀请码，未登录且未填写时可为空。
/// @return 配置好可见检测栏目和邀请码的检测对象。
- (instancetype)initWithCurrentSsoNumber:(NSString *)ssoNumber {
    self = [super init];
    if (self) {
        self.currentSsoNumber = ssoNumber;
        
        NoaNetworkDetectionMessageModel *networkConnectStatusMessageModel = [self createMessageModelWithTitle:LanguageToolMatch(@"网络连接情况") sectionType:ZNetworkDetectionNetworkConnectSectionType];
        NoaNetworkDetectionMessageModel *domainNameResolutionMessageModel = [self createMessageModelWithTitle:LanguageToolMatch(@"域名解析检测") sectionType:ZNetworkDetectionDomainNameResolutionSectionType];
        NoaNetworkDetectionMessageModel *navConnectDetectionMessageModel = [self createMessageModelWithTitle:LanguageToolMatch(@"导航连接检测") sectionType:ZNetworkDetectionNavConnectDetectionSectionType];
        NoaNetworkDetectionMessageModel *serverConnectDetectionMessageModel = [self createMessageModelWithTitle:LanguageToolMatch(@"服务器连接检测") sectionType:ZNetworkDetectionServerConnectDetectionSectionType];
        
        if (UserManager.isLogined) {
            // 登录后只进行网络状态检测、服务器链接检测(ECDH秘钥交换)
            self.tableDataSource = [@[
                networkConnectStatusMessageModel,
                serverConnectDetectionMessageModel
            ] mutableCopy];
        }else {
            // 非登录状态进行网络状态检测、域名检测、导航检测
            self.tableDataSource = [@[
                networkConnectStatusMessageModel,
                domainNameResolutionMessageModel,
                navConnectDetectionMessageModel,
            ] mutableCopy];
            
            if (self.currentSsoNumber && self.currentSsoNumber.length > 0) {
                // 如果当前用户设置了邀请码，增加服务器检测
                [self.tableDataSource addObject:serverConnectDetectionMessageModel];
            }
        }
    }
    return self;
}

/// 创建带标题的消息模型
- (NoaNetworkDetectionMessageModel *)createMessageModelWithTitle:(NSString *)title
                                                   sectionType:(ZNetworkDetectionSectionType)sectionType {
    NoaNetworkDetectionMessageModel *model = [NoaNetworkDetectionMessageModel new];
    model.sectionTitle = title;
    model.sectionType = sectionType;
    return model;
}

/// 修改检测状态
/// - Parameter status: 最新状态
- (void)changeNetworkDetectionStatus:(ZNetworkDetectionStatus)status {
    if (status == self.networkDetectionStatus) {
        return;
    }
    self.networkDetectionStatus = status;
    
    // 当检测完成时，通知 RACCommand 订阅者
    if (status == ZNetworkDetectFinish && self.detectionCommandSubscriber) {
        [self.detectionCommandSubscriber sendNext:@(YES)];
        [self.detectionCommandSubscriber sendCompleted];
        self.detectionCommandSubscriber = nil;
    }
}

- (NoaNetworkDetectionMessageModel *)getSectionModelWithIndex:(NSInteger)section {
    if (section < 0 || section >= self.tableDataSource.count) {
        return nil;
    }
    return self.tableDataSource[section];
}

- (NoaNetworkDetectionSubResultModel *)getCellModelWithIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    // 第一行展示主要信息，所以子任务结果展示从第2个开始
    NSInteger row = indexPath.row - 1;
    NoaNetworkDetectionMessageModel *sectionModel = [self getSectionModelWithIndex:section];
    if (!sectionModel) {
        return nil;
    }
    
    if (sectionModel.subFunctionResultArr.count <= row) {
        return nil;
    }
    return sectionModel.subFunctionResultArr[row];
}

- (NSInteger)getAllUnPassSubResultCount {
    NSInteger count = 0;
    for (NoaNetworkDetectionMessageModel *messageModel in self.tableDataSource) {
        if ([messageModel isAllSubFunctionPass]) {
            continue;
        }else {
            count ++;
        }
    }
    return count;
}

/// 建立网络、导航和服务器检测的事件订阅，并维护可见阶段的进度。
- (void)processData {
    // 设置所有订阅，并添加到统一管理器中
    @weakify(self)
    // 订阅1: 网络状态检测
    RACDisposable *d1 = [self.startNetworkStatusDetectionSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        
        if (self.currentSsoNumber && self.currentSsoNumber.length > 0) {
            // 更新头部状态
            [self.headerViewReloadDataSubject sendNext:@{
                @"status" : @(ZNetworkDetecting),
                @"process" : @25
            }];
        }else {
            // 更新头部状态
            [self.headerViewReloadDataSubject sendNext:@{
                @"status" : @(ZNetworkDetecting),
                @"process" : @33
            }];
        }
        
        // 检测网络权限
        [self checkNetworkPermission];
    }];
    [self.allSubscriptionsDisposable addDisposable:d1];
    
    // 订阅2: 域名解析检测
    RACDisposable *d2 = [self.startDomainNameResolutionDetectionSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (self.currentSsoNumber && self.currentSsoNumber.length > 0) {
            [self.headerViewReloadDataSubject sendNext:@{
                @"status" : @(ZNetworkDetecting),
                @"process" : @50
            }];
        }else {
            [self.headerViewReloadDataSubject sendNext:@{
                @"status" : @(ZNetworkDetecting),
                @"process" : @60
            }];
        }

        [self checkDomainNameResolution];
    }];
    [self.allSubscriptionsDisposable addDisposable:d2];

    // 订阅3: 导航检测
    RACDisposable *d3 = [self.startNavConnectDetectionSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (!self.currentSsoNumber || self.currentSsoNumber.length == 0) {
            [self.headerViewReloadDataSubject sendNext:@{
                @"status" : @(ZNetworkDetecting),
                @"process" : @70
            }];
        }
        [self navConnectDetectionWithOssList:self.ossUrlList];
    }];
    [self.allSubscriptionsDisposable addDisposable:d3];
    
    // 订阅4: 服务器检测
    RACDisposable *d4 = [self.startServerConnectDetectionSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        
        // 更新头部状态
        [self.headerViewReloadDataSubject sendNext:@{
            @"status" : @(ZNetworkDetecting),
            @"process" : @75
        }];
        
        // 服务器链接检测
        [self serverConnectDetection];
    }];
    [self.allSubscriptionsDisposable addDisposable:d4];
    
    // 订阅5: 导航事件处理
    RACDisposable *d5 = [self.navDetectionEventSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        
        // 为了避免阻塞调用线程（可能是主线程或后台线程），这里立即将处理转移到后台线程
        // 这样 sendNext 调用可以立即返回，不会阻塞调用线程
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @strongify(self)
            
            // 导航事件（后台线程处理）
            if ([x isKindOfClass:[NSDictionary class]]) {
                if (self.tableDataSource.count < 3) {
                    return;
                }
                
                NoaNetworkDetectionMessageModel *navConnectDetectionMessageModel = self.tableDataSource[2];
                NSDictionary *eventDic = x;
                NSString *event = [eventDic objectForKey:@"event"];
                if ([event isEqualToString:@"navDetectionCompleted"]) {
                    [self scheduleTaskAfter:1.0 block:^{
                        @strongify(self)
                        // 标记为导航检测完成，通知更新UI
                        navConnectDetectionMessageModel.isFinish = YES;
                        navConnectDetectionMessageModel.messageStatus = ZNetworkDetectionMessageEndStatus;
                        [navConnectDetectionMessageModel.changeStatusSubject sendNext:@(ZNetworkDetectionMessageEndStatus)];
                        
                        CIMLog(@"[网络链路检测] 导航解析完成");
                        
                        // 通知开始服务器连接检测
                        if (self.currentSsoNumber && self.currentSsoNumber.length > 0) {
                            [self.startServerConnectDetectionSubject sendNext:@1];
                        }else {
                            // 用户未输入邀请码，完成测试
                            // 所有检测全部完成
                            [self changeNetworkDetectionStatus:ZNetworkDetectFinish];
                            
                            // 更新头部状态
                            [self.headerViewReloadDataSubject sendNext:@{
                                @"status" : @(ZNetworkDetectFinish),
                                @"process" : @100
                            }];
                        }
                    }];
                }else if ([event isEqualToString:@"navDetectionResult"]) {
                    // 导航链接解析结果
                    NoaNetworkDetectionSubResultModel *navDetectionResultModel = [NoaNetworkDetectionSubResultModel new];
                    NoaUrlHostModel *urlHostModel = [eventDic objectForKey:@"urlModel"];
                    BOOL isSuccess = [[eventDic objectForKey:@"isSuccess"] boolValue];
                    double duration = [[eventDic objectForKey:@"duration"] doubleValue];
                    NSString *code = [eventDic objectForKey:@"code"];
                    
                    navDetectionResultModel.isPass = isSuccess;
                    
                    NSString *urlStr = urlHostModel.urlString;
                    NSMutableArray *urlArr = [NSMutableArray arrayWithArray:[urlStr componentsSeparatedByString:@":"]];
                    // 移除端口号
                    if (urlArr.count > 1) {
                        [urlArr removeLastObject];
                    }
                    NSString *encryptUrlStr = [urlArr componentsJoinedByString:@"."];
                    // 根据脱敏规则，前三个、后三个展示，其余使用***展示
                    if (encryptUrlStr.length > 6) {
                        // 长字符串（>6）：前3后3
                        NSString *prefix = [encryptUrlStr substringToIndex:3];
                        NSString *suffix = [encryptUrlStr substringFromIndex:encryptUrlStr.length - 3];
                        encryptUrlStr = [NSString stringWithFormat:@"%@***%@", prefix, suffix];
                    } else if (encryptUrlStr.length == 6) {
                        // 6字符：前2后2 (例如 "abcdef" -> "ab***ef")
                        NSString *prefix = [encryptUrlStr substringToIndex:2];
                        NSString *suffix = [encryptUrlStr substringFromIndex:4];
                        encryptUrlStr = [NSString stringWithFormat:@"%@***%@", prefix, suffix];
                    } else {
                        // 不处理
                    }
                    
                    NSString *resultTitleStr = @"";
                    if (([[NoaFallbackEndpointStore shared].domesticUrls containsObject:urlStr] ||
                         [[NoaFallbackEndpointStore shared].overseasUrls containsObject:urlStr]) && [urlHostModel.type isEqualToString:@"5"]) {
                        if (isSuccess) {
                            resultTitleStr = [NSString stringWithFormat:LanguageToolMatch(@"导航%@请求成功，耗时%.0f毫秒"), encryptUrlStr, duration];
                        }else {
                            if ([code isEqualToString:@"-999999"]) {
                                resultTitleStr = [NSString stringWithFormat:LanguageToolMatch(@"导航%@请求失败，请求超时"), encryptUrlStr];
                                CIMLog(@"[网络链路检测] 域名解析返回事件:%@", [NSString stringWithFormat:LanguageToolMatch(@"导航%@请求失败，请求超时"), encryptUrlStr]);
                            }else if ([code isEqualToString:@"-888888"]) {
                                resultTitleStr = [NSString stringWithFormat:LanguageToolMatch(@"导航%@请求失败，无法连接至服务器"), encryptUrlStr];
                                CIMLog(@"[网络链路检测] 域名解析返回事件:%@", [NSString stringWithFormat:LanguageToolMatch(@"导航%@请求失败，请求超时"), encryptUrlStr]);
                            }else {
                                resultTitleStr = [NSString stringWithFormat:LanguageToolMatch(@"导航%@请求失败，返回错误信息%@"), encryptUrlStr, code];
                                CIMLog(@"[网络链路检测] 域名解析返回事件:%@", [NSString stringWithFormat:LanguageToolMatch(@"导航%@请求失败，返回错误信息%@"), encryptUrlStr, code]);
                            }
                        }
                    }else {
                        if (isSuccess) {
                            resultTitleStr = [NSString stringWithFormat:LanguageToolMatch(@"%@请求成功，耗时%.0f毫秒"), encryptUrlStr, duration];
                        }else {
                            if ([code isEqualToString:@"-999999"]) {
                                resultTitleStr = [NSString stringWithFormat:LanguageToolMatch(@"%@请求失败，请求超时"), encryptUrlStr];
                                CIMLog(@"[网络链路检测] 域名解析返回事件:%@", [NSString stringWithFormat:LanguageToolMatch(@"%@请求失败，请求超时"), encryptUrlStr]);
                            }else if ([code isEqualToString:@"-888888"]) {
                                resultTitleStr = [NSString stringWithFormat:LanguageToolMatch(@"%@请求失败，请求超时"), encryptUrlStr];
                                CIMLog(@"[网络链路检测] 域名解析返回事件:%@", [NSString stringWithFormat:LanguageToolMatch(@"%@请求失败，无法连接至服务器"), encryptUrlStr]);
                            }else {
                                resultTitleStr = [NSString stringWithFormat:LanguageToolMatch(@"%@请求失败，返回错误信息%@"), encryptUrlStr, code];
                                CIMLog(@"[网络链路检测] 域名解析返回事件:%@", [NSString stringWithFormat:LanguageToolMatch(@"%@请求失败，返回错误信息%@"), encryptUrlStr, code]);
                            }
                        }
                    }
                    navDetectionResultModel.resultTitleStr = resultTitleStr;
                    [navConnectDetectionMessageModel.subFunctionResultArr addObject:navDetectionResultModel];
                }else if ([event isEqualToString:@"emptyNavDetectionResult"]) {
                    // 导航链接解析失败-节点为空
                    NoaNetworkDetectionSubResultModel *navDetectionResultModel = [NoaNetworkDetectionSubResultModel new];
                    double duration = [[eventDic objectForKey:@"duration"] doubleValue];
                    navDetectionResultModel.isPass = NO;
                    navDetectionResultModel.resultTitleStr = [NSString stringWithFormat:LanguageToolMatch(@"导航请求失败，无可用地址，耗时%.0f毫秒"), duration];
                    
                    // 数组操作需要在主线程，确保线程安全
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [navConnectDetectionMessageModel.subFunctionResultArr addObject:navDetectionResultModel];
                    });
                    
                    CIMLog(@"[网络链路检测] 域名解析返回的节点为空，故导航解析失败");
                }
            }
            
            // ✅ 刷新UI（回到主线程执行）
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self)
                [self.tableViewReloadDataSubject sendNext:@1];
            });
        });
    }];
    [self.allSubscriptionsDisposable addDisposable:d5];
    
    // 订阅6: 服务器链接检测事件处理
    // ✅ 关键修复：同订阅5，立即将处理转移到后台线程，避免阻塞调用线程
    RACDisposable *d6 = [self.serverDetectionEventSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        
        // 立即将处理转移到后台线程，避免阻塞调用 sendNext 的线程
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @strongify(self)
            
            // 服务器链接检测事件（后台线程处理）
            if ([x isKindOfClass:[NSDictionary class]]) {
                NSInteger index = UserManager.isLogined ? 1 : 3;
                if (self.tableDataSource.count <= index) {
                    return;
                }
                
                NoaNetworkDetectionMessageModel *serverConnectDetectionMessageModel = self.tableDataSource[index];
                
                NSDictionary *eventDic = x;
                NSString *event = [eventDic objectForKey:@"event"];
                if ([event isEqualToString:@"serverDetectionCompleted"]) {
                [self scheduleTaskAfter:1.0 block:^{
                    @strongify(self)
                    // 标记为检测完成，通知更新UI
                    serverConnectDetectionMessageModel.isFinish = YES;
                    serverConnectDetectionMessageModel.messageStatus = ZNetworkDetectionMessageEndStatus;
                    [serverConnectDetectionMessageModel.changeStatusSubject sendNext:@(ZNetworkDetectionMessageEndStatus)];
                    
                    CIMLog(@"[网络链路检测] 服务器检测完成");
                    
                    // 所有检测全部完成
                    [self changeNetworkDetectionStatus:ZNetworkDetectFinish];
                    
                    // 更新头部状态
                    [self.headerViewReloadDataSubject sendNext:@{
                        @"status" : @(ZNetworkDetectFinish),
                        @"process" : @100
                    }];
                }];
            }else if ([event isEqualToString:@"serverDetectionResult"]) {
                // TCP服务器链接事件
                NoaNetworkDetectionSubResultModel *serverDetectionResultModel = [NoaNetworkDetectionSubResultModel new];
                BOOL isSuccess = [[eventDic objectForKey:@"isSuccess"] boolValue];
                double duration = [[eventDic objectForKey:@"duration"] doubleValue];
                NSString *host = [eventDic objectForKey:@"host"];
                NSString *port = [eventDic objectForKey:@"port"];
                LingIMSDKManagerProbeECDHConnectStatus status = [[eventDic objectForKey:@"status"] intValue];
                
                NSString *encryptHostStr = @"";
                // 根据脱敏规则，前三个、后三个展示，其余使用***展示
                if (host.length > 6) {
                    // 长字符串（>6）：前3后3
                    NSString *prefix = [host substringToIndex:3];
                    NSString *suffix = [host substringFromIndex:host.length - 3];
                    encryptHostStr = [NSString stringWithFormat:@"%@***%@", prefix, suffix];
                } else if (host.length == 6) {
                    // 6字符：前2后2 (例如 "abcdef" -> "ab***ef")
                    NSString *prefix = [host substringToIndex:2];
                    NSString *suffix = [host substringFromIndex:4];
                    encryptHostStr = [NSString stringWithFormat:@"%@***%@", prefix, suffix];
                } else {
                    // 不处理
                    encryptHostStr = host;
                }
                
                serverDetectionResultModel.isPass = isSuccess;
                
                NSString *resultTitleStr = @"";
                if (isSuccess) {
                    resultTitleStr = [NSString stringWithFormat:LanguageToolMatch(@"TCP节点%@请求成功，耗时%.0f毫秒"), encryptHostStr, duration];
                    CIMLog(@"[网络链路检测] 收到服务器检测事件，%@", [NSString stringWithFormat:LanguageToolMatch(@"TCP节点%@请求成功，耗时%.0f毫秒"), [NSString stringWithFormat:@"%@:%@", host, port], duration]);
                }else {
                    if (status == LingIMSDKManagerProbeECDHExChangeKeyFail) {
                        // 秘钥交换失败
                        resultTitleStr = [NSString stringWithFormat:LanguageToolMatch(@"TCP节点%@请求失败，密钥交换失败"), encryptHostStr];
                        CIMLog(@"[网络链路检测] 收到服务器检测事件，%@", [NSString stringWithFormat:LanguageToolMatch(@"TCP节点%@请求失败，密钥交换失败"), [NSString stringWithFormat:@"%@:%@", host, port]]);
                    }else {
                        // 无法连接服务器
                        resultTitleStr = [NSString stringWithFormat:LanguageToolMatch(@"TCP节点%@请求失败，无法连接至服务器"), encryptHostStr];
                        CIMLog(@"[网络链路检测] 收到服务器检测事件，%@", [NSString stringWithFormat:LanguageToolMatch(@"TCP节点%@请求失败，无法连接至服务器"), [NSString stringWithFormat:@"%@:%@", host, port]]);
                    }
                }
                serverDetectionResultModel.resultTitleStr = resultTitleStr;
                [serverConnectDetectionMessageModel.subFunctionResultArr addObject:serverDetectionResultModel];
            }else if ([event isEqualToString:@"emptyServerDetectionResult"]) {
                // 导航链接解析失败-节点为空
                NoaNetworkDetectionSubResultModel *serverDetectionResultModel = [NoaNetworkDetectionSubResultModel new];
                double duration = [[eventDic objectForKey:@"duration"] doubleValue];
                serverDetectionResultModel.isPass = NO;
                serverDetectionResultModel.resultTitleStr = [NSString stringWithFormat:LanguageToolMatch(@"TCP节点请求失败，无法连接至服务器"), duration];
                
                [serverConnectDetectionMessageModel.subFunctionResultArr addObject:serverDetectionResultModel];

                CIMLog(@"[网络链路检测] 可用TCP节点为空，故导航解析失败");
                }else {
                    // 未知，不处理
                }
                
            }
            
            // ✅ 刷新UI（回到主线程执行）
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self)
                [self.tableViewReloadDataSubject sendNext:@1];
            });
        });
    }];
    [self.allSubscriptionsDisposable addDisposable:d6];
}

// MARK: 网络质量检测

/// 网络质量检测
/// - Parameter completion: 回调
- (void)startNetworkDetection {
    // 清理数据
    [self cleanLastDetectionData];
    
    // 处理回调数据
    [self processData];
   
    // 将当前状态修改为检测中
    [self changeNetworkDetectionStatus:ZNetworkDetecting];
    
    // 更新头部状态
    [self.headerViewReloadDataSubject sendNext:@{
        @"status" : @(ZNetworkDetecting),
        @"process" : @0
    }];
  
    [self.startNetworkStatusDetectionSubject sendNext:@1];
}

/// 检测设备网络连接情况；未登录时完成后直接使用本地兜底 IP 开始导航检测。
- (void)checkNetworkPermission {
    if (self.tableDataSource.count < 1) {
        return;
    }
    
    CIMLog(@"[网络链路检测] 当前开始进行网络权限、网络畅通检测");
    
    // 检测网络权限
    NoaNetworkDetectionMessageModel *networkConnectStatusMessageModel = self.tableDataSource[0];
    // 将网络权限置为检测中
    networkConnectStatusMessageModel.messageStatus = ZNetworkDetectionMessageDetectingStatus;
    [networkConnectStatusMessageModel.changeStatusSubject sendNext:@(ZNetworkDetectionMessageDetectingStatus)];

    // 设备已联网、设备未联网
    NoaNetworkDetectionSubResultModel *networkConnectResultModel = [NoaNetworkDetectionSubResultModel new];
    // 设备网络状态正常、异常
    NoaNetworkDetectionSubResultModel *networkDeviceNetStatusResultModel = [NoaNetworkDetectionSubResultModel new];
    
    networkConnectStatusMessageModel.subFunctionResultArr = [NSMutableArray arrayWithObjects:networkConnectResultModel, networkDeviceNetStatusResultModel, nil];
    
    // 子任务读取
    // 检测网络权限(连接)
    BOOL isConnect = [[NetWorkStatusManager shared] getConnectStatus];
    if (isConnect) {
        CIMLog(@"[网络链路检测] 当前能联网，网络权限检测通过");
        networkConnectResultModel.isPass = YES;
        networkConnectResultModel.resultTitleStr = LanguageToolMatch(@"设备已联网");
        
        networkDeviceNetStatusResultModel.isPass = YES;
        networkDeviceNetStatusResultModel.resultTitleStr = LanguageToolMatch(@"网络连接状态正常");
    }else {
        CIMLog(@"[网络链路检测] 当前不能联网，网络权限检测未通过");
        networkConnectResultModel.isPass = NO;
        networkConnectResultModel.resultTitleStr = LanguageToolMatch(@"设备未联网");
        
        networkDeviceNetStatusResultModel.isPass = NO;
        networkDeviceNetStatusResultModel.resultTitleStr = LanguageToolMatch(@"网络连接状态异常");
    }
    @weakify(self)
    [self scheduleTaskAfter:1.0 block:^{
        @strongify(self)
        // 标记为检测完成，通知更新UI
        networkConnectStatusMessageModel.isFinish = YES;
        networkConnectStatusMessageModel.messageStatus = ZNetworkDetectionMessageEndStatus;
        [networkConnectStatusMessageModel.changeStatusSubject sendNext:@(ZNetworkDetectionMessageEndStatus)];
        
        CIMLog(@"[网络链路检测] 网络权限、网络畅通检测完成");
        
        // 刷新UI
        [self.tableViewReloadDataSubject sendNext:@1];
        
        if (UserManager.isLogined) {
            // 服务器链接检测
            [self.startServerConnectDetectionSubject sendNext:@1];
        }else {
            // 域名解析检测
            [self.startDomainNameResolutionDetectionSubject sendNext:@1];
        }
    }];
}

// MARK: 域名解析
/// 执行主、备域名解析，整理导航候选节点，并在完成后进入导航连接检测。
- (void)checkDomainNameResolution {
    if (self.tableDataSource.count < 2) {
        return;
    }
    
    CIMLog(@"[网络链路检测] 当前开始进行域名解析");
    
    // 域名解析
    NoaNetworkDetectionMessageModel *domainNameResolutionMessageModel = self.tableDataSource[1];
    // 将网络权限置为检测中
    domainNameResolutionMessageModel.messageStatus = ZNetworkDetectionMessageDetectingStatus;
    [domainNameResolutionMessageModel.changeStatusSubject sendNext:@(ZNetworkDetectionMessageDetectingStatus)];
    
    // 子任务
    // 主域名解析结果
    NoaNetworkDetectionSubResultModel *mainDomainNameResultModel = [NoaNetworkDetectionSubResultModel new];
    // 副域名解析结果
    NoaNetworkDetectionSubResultModel *spareDomainNameResultModel = [NoaNetworkDetectionSubResultModel new];
    
    domainNameResolutionMessageModel.subFunctionResultArr = [NSMutableArray arrayWithObjects:mainDomainNameResultModel, spareDomainNameResultModel, nil];
    
    
    @weakify(self)
    [self domainNameResolutionWithMainDomainComplete:^(BOOL isSuccess) {
        // 主域名结果
        mainDomainNameResultModel.isPass = isSuccess;
        mainDomainNameResultModel.resultTitleStr = isSuccess ? LanguageToolMatch(@"主域名DNS解析正常") : LanguageToolMatch(@"主域名DNS解析失败");
        
        CIMLog(@"[网络链路检测] %@", isSuccess ? @"主域名DNS解析正常" : @"主域名DNS解析失败");
    } SpareDomainComplete:^(BOOL isSuccess) {
        // 副域名结果
        spareDomainNameResultModel.isPass = isSuccess;
        spareDomainNameResultModel.resultTitleStr = isSuccess ? LanguageToolMatch(@"备域名DNS解析正常") : LanguageToolMatch(@"备域名DNS解析失败");
        
        CIMLog(@"[网络链路检测] %@", isSuccess ? @"副域名DNS解析正常" : @"副域名DNS解析失败");
    } FinishComplete:^(NSArray<NoaUrlHostModel *> *ossUrlList) {
        @strongify(self)
        [self scheduleTaskAfter:1.0 block:^{
            @strongify(self)
            // 主副域名全部结果
            // 标记为检测完成，通知更新UI
            domainNameResolutionMessageModel.isFinish = YES;
            domainNameResolutionMessageModel.messageStatus = ZNetworkDetectionMessageEndStatus;
            [domainNameResolutionMessageModel.changeStatusSubject sendNext:@(ZNetworkDetectionMessageEndStatus)];
            
            NSMutableArray<NoaUrlHostModel *> *uniqueOssUrlList = [NSMutableArray array];
            // 去重：过滤掉 IP 和端口号相同的数据（不包含兜底）
            NSMutableSet<NSString *> *tempUrls = [NSMutableSet set];
            // 去重：过滤掉 IP 和端口号相同的数据（只包含兜底）
            NSMutableSet<NSString *> *tempFailBackUrls = [NSMutableSet set];
            
            for (NoaUrlHostModel *urlModel in ossUrlList) {
                if ([urlModel.type isEqualToString:@"5"]) {
                    // 使用 urlString 作为唯一标识（格式: ip:port）
                    if (![tempFailBackUrls containsObject:urlModel.urlString]) {
                        [tempFailBackUrls addObject:urlModel.urlString];
                        [uniqueOssUrlList addObject:urlModel];
                    } else {
                        continue;
                    }
                }else {
                    // 使用 urlString 作为唯一标识（格式: ip:port）
                    if (![tempUrls containsObject:urlModel.urlString]) {
                        [tempUrls addObject:urlModel.urlString];
                        [uniqueOssUrlList addObject:urlModel];
                    } else {
                        continue;
                    }
                }
            }
            
            self.ossUrlList = uniqueOssUrlList;
            
            // 刷新UI
            [self.tableViewReloadDataSubject sendNext:@1];
            
            // 开启导航检测
            [self.startNavConnectDetectionSubject sendNext:@1];
        }];
    }];
}

/// 调用SDK封装方法进行域名解析
/// - Parameters:
///   - mainDomainComplete: 主域名解析成功\失败结果
///   - spareDomainComplete: 副域名解析成功\失败结果
///   - complete: 最终全部解析的节点
- (void)domainNameResolutionWithMainDomainComplete:(void(^)(BOOL isSuccess))mainDomainComplete
                               SpareDomainComplete:(void(^)(BOOL isSuccess))spareDomainComplete
                                    FinishComplete:(void(^)(NSArray<NoaUrlHostModel *> *ossUrlList))complete {
    // 1. 配置 DNS 解析器
    [self configureDNSResolver];
    
    // 2. 准备并发任务
    NSMutableArray<NoaUrlHostModel *> *ossUrlList = [NSMutableArray new];
    
    dispatch_group_t group = dispatch_group_create();
    
    // 3. 解析主域名（完成后立即回调主域名回调）
    dispatch_group_enter(group);
    [self resolveDomain:main_domain
          withMainTypes:@[@"1", @"2"]
             completion:^(NSArray<NoaUrlHostModel *> *mainUrlList) {
        
        // 主域名解析完成，添加到总列表（要求只用先返回的）
        if (mainUrlList.count > 0 && ossUrlList.count == 0) {
            [ossUrlList addObjectsFromArray:mainUrlList];
        }
        
        // 立即回调主域名完成
        if (mainDomainComplete) {
            mainDomainComplete(mainUrlList.count > 0 ? YES : NO);
        }
        
        dispatch_group_leave(group);
    }];
    
    // 4. 解析副域名（完成后立即回调副域名回调）
    dispatch_group_enter(group);
    [self resolveDomain:back_domain
          withMainTypes:@[@"3", @"4"]
             completion:^(NSArray<NoaUrlHostModel *> *spareUrlList) {

        // 副域名解析完成，添加到总列表（要求只用先返回的）
        if (spareUrlList.count > 0 && ossUrlList.count == 0) {
            [ossUrlList addObjectsFromArray:spareUrlList];
        }
        
        // 立即回调副域名完成
        if (spareDomainComplete) {
            spareDomainComplete(spareUrlList.count > 0 ? YES : NO);
        }
        
        dispatch_group_leave(group);
    }];
    
    // 5. 等待所有域名都解析完成后，统一回调最终结果
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 添加内置的两个兜底地址
        // 国内兜底地址
        for (NSString *domesticUrlStr in [NoaFallbackEndpointStore shared].domesticUrls) {
            if([domesticUrlStr hasSuffix:@"8088"]) {
                continue;
            }
            NoaUrlHostModel *fallbackDomesticUrlmodel = [self getUrlHostModelWithUrl:domesticUrlStr type:@"5"];
            [ossUrlList addObject:fallbackDomesticUrlmodel];
        }
        // 国外兜底地址
        for (NSString *overseasUrlStr in [NoaFallbackEndpointStore shared].overseasUrls) {
            if([overseasUrlStr hasSuffix:@"8088"]) {
                continue;
            }
            NoaUrlHostModel *fallbackOverseasUrlmodel = [self getUrlHostModelWithUrl:overseasUrlStr type:@"5"];
            [ossUrlList addObject:fallbackOverseasUrlmodel];
        }
        
        if (complete) {
            complete([ossUrlList copy]);
        }
    });
}

/// 配置 DNS 解析器
- (void)configureDNSResolver {
    DNSResolver *resolver = [DNSResolver share];
    [resolver setAccountId:ali_account_id
            andAccessKeyId:ali_key_id
      andAccesskeySecret:ali_key_secret];
    resolver.cacheEnable = NO;
    resolver.scheme = DNSResolverSchemeHttp;
    [resolver clearHostCache:nil];
}

/// 解析指定域名并返回 URL 列表
/// @param domain 要解析的域名
/// @param types URL 类型数组 [首选类型, 备选类型]
/// @param completion 完成回调，返回解析出的 URL 列表
- (void)resolveDomain:(NSString *)domain
        withMainTypes:(NSArray<NSString *> *)types
           completion:(void(^)(NSArray<NoaUrlHostModel *> *urlList))completion {
    WeakSelf
    
    [[DNSResolver share] getIpv6DataWithDomain:domain complete:^(NSArray<NSString *> *dataArray) {
        // 解析 IPv6 数据
        NSString *analysisDomain = [weakSelf parseIPv6Data:dataArray];
        
        NSArray<NoaUrlHostModel *> *urlList = @[];
        if (analysisDomain) {
            // 解析成功，处理 URL 列表
            NSMutableArray<NoaUrlHostModel *> *tempList = [NSMutableArray array];
            [weakSelf processOssUrls:analysisDomain
                          withTypes:types
                         ossUrlList:tempList];
            urlList = [tempList copy];
        }
        
        // 回调返回结果
        if (completion) {
            completion(urlList);
        }
    }];
}

/// 解析 IPv6 数据为域名字符串
/// @param dataArray IPv6 数据数组
/// @return 解析后的域名字符串，失败返回 nil
- (NSString *)parseIPv6Data:(NSArray<NSString *> *)dataArray {
    if (!dataArray || dataArray.count == 0) {
        return nil;
    }
    
    // 收集 IPv6 数据
    NSMutableArray *ipV6List = [NSMutableArray arrayWithArray:dataArray];
    
    // 转换为域名字符串
    NSString *analysisDomain = [AliyCloundDNSDecoder v6ToString:ipV6List];
    
    return [NSString isNil:analysisDomain] ? nil : analysisDomain;
}

/// 处理 OSS URL 列表
/// @param analysisDomain 解析后的域名字符串（逗号分隔）
/// @param types URL 类型数组 [首选类型, 备选类型]
/// @param ossUrlList OSS URL 列表（传引用）
- (void)processOssUrls:(NSString *)analysisDomain
             withTypes:(NSArray<NSString *> *)types
            ossUrlList:(NSMutableArray<NoaUrlHostModel *> *)ossUrlList {
    WeakSelf
    
    // 按逗号分割域名字符串
    NSArray<NSString *> *ossBucketArr = [analysisDomain componentsSeparatedByString:@","];
    
    if (!ossBucketArr || ossBucketArr.count == 0) {
        return;
    }
    
    [ossBucketArr enumerateObjectsUsingBlock:^(NSString *urlString, NSUInteger idx, BOOL *stop) {
        // 过滤端口为 8088 的地址
        if ([urlString hasSuffix:@"8088"]) {
            return;
        }
        
        // 根据索引选择类型：0-首选，其他-备选
        NSString *type = (idx == 0) ? types[0] : types[1];
        
        // 创建并添加 URL 模型
        NoaUrlHostModel *model = [weakSelf getUrlHostModelWithUrl:urlString type:type];
        [ossUrlList addObject:model];
    }];
}

- (NoaUrlHostModel *)getUrlHostModelWithUrl:(NSString *)urlString type:(NSString *)type {
    NoaUrlHostModel *model = [[NoaUrlHostModel alloc] init];
    model.urlString = urlString;
    model.type = type;
    return model;
}

// MARK: 导航解析
/// 导航链接检测
/// @param ossList OSS URL列表
- (void)navConnectDetectionWithOssList:(NSArray<NoaUrlHostModel *> *)ossList {
    if (self.tableDataSource.count < 3) {
        return;
    }
    
    CIMLog(@"[网络链路检测] 开始进行导航解析");
    
    NoaNetworkDetectionMessageModel *navConnectDetectionMessageModel = self.tableDataSource[2];
    // 将网络权限置为检测中
    navConnectDetectionMessageModel.messageStatus = ZNetworkDetectionMessageDetectingStatus;
    [navConnectDetectionMessageModel.changeStatusSubject sendNext:@(ZNetworkDetectionMessageDetectingStatus)];
    
    if (!ossList || ossList.count == 0) {
        // 上层展示报错
        // 通知上层：当前 OSS URL 检测失败
        NSDictionary *emptyResultInfo = @{
            @"event": @"emptyNavDetectionResult",
            @"isSuccess": @(NO),
            @"duration": @1   // 耗时（毫秒）
        };
        
        // 通过信号发送给上层
        [self.navDetectionEventSubject sendNext:emptyResultInfo];
        
        NSDictionary *finishResultInfo = @{
            @"event": @"navDetectionCompleted"
        };
        
        // 通过信号发送给上层
        [self.navDetectionEventSubject sendNext:finishResultInfo];
        return;
    }
    
    // 优先使用当前邀请码
    NSString *ssoNumber = self.currentSsoNumber;
    if (!ssoNumber || ssoNumber.length == 0) {
        // 如果在邀请码配置页面，并且用户没有输入邀请码，则生成两位随机字符串为邀请码
        ssoNumber = [self generateRandomTwoCharactersWithEqualProbability];
    }
    
    @weakify(self)
    
    // ⚠️ 在开始新的 IP 获取之前，先取消上一次的 IP 获取任务
    [self cancelPublicIPTasks];
    
    // 获取公网ip,安卓端使用的是接口查询，跟iOS不一样
    [self getDevicePublicNetworkIPWithCompletion:^(NSString * _Nonnull ip) {
        @strongify(self)
        
        // ✅ 关键修复：将 for 循环和对象创建移到后台线程，避免阻塞主线程
        // ✅ 进一步优化：将每次方法调用也异步化，避免在同一个线程中同步执行所有网络请求
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 创建并发组，用于追踪所有请求是否完成
            dispatch_group_t group = dispatch_group_create();
            
            // 遍历所有 OSS URL 进行导航检测（后台线程执行）
            for (NoaUrlHostModel *ossUrlModel in ossList) {
                dispatch_group_enter(group);
                
                // 将每次检测调用放到独立的后台线程中执行
                // 原因：executeNavDetectionWithUrlModel 内部的网络请求是同步阻塞的
                // 如果在同一个线程中循环调用10次，会导致该线程长时间阻塞
                // 虽然不是主线程，但可能影响系统调度，间接影响主线程响应
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    // 将检测逻辑封装到独立方法中，确保每个请求的时间戳独立
                    [self executeNavDetectionWithUrlModel:ossUrlModel
                                                ssoNumber:ssoNumber
                                                 publicIp:ip
                                                    group:group];
                });
            }
            
            // 等待所有请求完成后，通知上层全部结束
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                @strongify(self)
               
                NSDictionary *resultInfo = @{
                    @"event": @"navDetectionCompleted"
                };
                
                // 通过信号发送给上层
                [self.navDetectionEventSubject sendNext:resultInfo];
            });
        });
    }];
}

/// 执行单个导航检测（确保时间戳独立）
/// @param urlModel OSS URL 模型
/// @param ssoNumber 邀请码
/// @param publicIp 公网 IP
/// @param group 并发组
- (void)executeNavDetectionWithUrlModel:(NoaUrlHostModel *)urlModel
                              ssoNumber:(NSString *)ssoNumber
                               publicIp:(NSString *)publicIp
                                  group:(dispatch_group_t)group {
    // 记录开始时间（每个请求独立的时间戳）
    NSDate *startTime = [NSDate date];
    
    @weakify(self)
    IOSTcpRaceManager *manager = [[IOSTcpRaceManager alloc]
                                  initWithAppId:ssoNumber
                                  appType:DefaultAppType
                                  bucket:urlModel
                                  useProxy:NO // 不使用代理
                                  publicIp:publicIp];
    
    [manager executeWithSuccess:^(IMServerListResponseBody * _Nonnull serverResponse) {
        @strongify(self)
        
        CIMLog(@"[网络链路检测] 使用URL:%@进行TCP直连，当前返回的结果为成功:%@", urlModel.urlString, serverResponse.imEndpointsArray);
        
        // 计算耗时（使用当前闭包捕获的 startTime）
        NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:startTime];
        
        // 过滤出有效的 TCP 端点
        NSMutableArray <IMServerEndpoint *>* tcpEndPointArray = [NSMutableArray new];
        
        [serverResponse.imEndpointsArray enumerateObjectsUsingBlock:^(IMServerEndpoint * _Nonnull endpoint, NSUInteger idx, BOOL * _Nonnull stop) {
            
            
            if ([endpoint.status isEqualToString:@"INACTIVE"]) {
                // 不可用的不保存
                return;
            }
            
            // 过滤出支持http的
            if ([endpoint.protocolsArray containsObject:@"http"]) {
                // 检测只检测tcp的
                return;
            }
            
            // 获取到所有的支持tcp的节点
            if ([endpoint.protocolsArray containsObject:@"tcp"]) {
                CIMLog(@"[网络链路检测] TCP直连，检测到tcp ip地址:%@, 端口号:%d", endpoint.ip, endpoint.port);
                [tcpEndPointArray addObject:endpoint];
            }
        }];
        
        // 去重：过滤掉 IP 和端口号相同的 TCP 节点
        NSMutableSet<NSString *> *existingTcpKeys = [NSMutableSet set];
        for (NoaNetRacingItemModel *existingItem in self.tcpRacingResultArr) {
            NSString *key = [NSString stringWithFormat:@"%@:%ld", existingItem.ip, existingItem.sort];
            [existingTcpKeys addObject:key];
        }
        
        // 转换为 ZNetRacingItemModel
        NSMutableArray <NoaNetRacingItemModel *>* tcpArray = [NSMutableArray new];
        [tcpEndPointArray enumerateObjectsUsingBlock:^(IMServerEndpoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *key = [NSString stringWithFormat:@"%@:%d", obj.ip, obj.port];
            if ([existingTcpKeys containsObject:key]) {
                return;
            }
            NoaNetRacingItemModel *model = [NoaNetRacingItemModel new];
            model.ip = obj.ip;
            model.sort = obj.port;
            [tcpArray addObject:model];
        }];
        
        // 通知上层：当前 OSS URL 检测成功
        NSDictionary *resultInfo = @{
            @"event": @"navDetectionResult",
            @"urlModel": urlModel,
            @"isSuccess": @(YES),
            @"duration": @(duration * 1000)   // 耗时（毫秒）
        };
        
        [self.tcpRacingResultArr addObjectsFromArray:tcpArray];
        
        // ✅ 关键修复：确保 sendNext 在后台线程执行，避免阻塞主线程
        // 问题：IOSTcpRaceManager 的回调可能在主线程，sendNext 会在主线程触发订阅处理
        // 订阅处理包含字符串处理、国际化查询等耗时操作，会阻塞主线程
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 通过信号发送给上层（后台线程）
            [self.navDetectionEventSubject sendNext:resultInfo];
        });
        
        dispatch_group_leave(group);
        
    } failure:^(NSError * _Nonnull error) {
        @strongify(self)
      
        CIMLog(@"[网络链路检测] 使用URL:%@进行TCP直连，当前返回的结果为失败:%@", urlModel.urlString, error);
        
        // 计算耗时（使用当前闭包捕获的 startTime）
        NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:startTime];
        
        NSDictionary *resultInfo;
        NSString *code = [error.userInfo objectForKey:NSUnderlyingErrorKey];
        // 使用随机邀请码进行检测导航，则节点返回状态码【200000/400002】均可认为连接正常
        // 使用用户输入的邀请码进行检测导航，则节点返回状态码【200000】可认为连接正常
        if (!self.currentSsoNumber || self.currentSsoNumber.length == 0) {
            // 当前使用的是随机邀请码
            if ([code isEqualToString:[NSString stringWithFormat:@"%ld", NavDataTypeSuccess]] ||
                [code isEqualToString:[NSString stringWithFormat:@"%ld", NavDataTypeAppIdInvalid]]) {
                resultInfo = @{
                    @"event": @"navDetectionResult",
                    @"urlModel": urlModel,
                    @"isSuccess": @(YES),
                    @"code": code,
                    @"duration": @(duration * 1000)   // 耗时（毫秒）
                };
            }else {
                resultInfo = @{
                    @"event": @"navDetectionResult",
                    @"urlModel": urlModel,
                    @"isSuccess": @(NO),
                    @"code": code,
                    @"duration": @(duration * 1000)   // 耗时（毫秒）
                };
            }
        }else {
            if ([code isEqualToString:[NSString stringWithFormat:@"%ld", NavDataTypeSuccess]]) {
                resultInfo = @{
                    @"event": @"navDetectionResult",
                    @"urlModel": urlModel,
                    @"isSuccess": @(YES),
                    @"code": code,
                    @"duration": @(duration * 1000)   // 耗时（毫秒）
                };
            }else {
                resultInfo = @{
                    @"event": @"navDetectionResult",
                    @"urlModel": urlModel,
                    @"isSuccess": @(NO),
                    @"code": code,
                    @"duration": @(duration * 1000)   // 耗时（毫秒）
                };
            }
        }
        
        // ✅ 关键修复：确保 sendNext 在后台线程执行，避免阻塞主线程
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 通过信号发送给上层（后台线程）
            [self.navDetectionEventSubject sendNext:resultInfo];
        });
        
        dispatch_group_leave(group);
    }];
}

// MARK: 服务器解析
/// 服务器链接检测
- (void)serverConnectDetection {
    NSInteger index = UserManager.isLogined ? 1 : 3;
    if (self.tableDataSource.count <= index) {
        return;
    }
    
    CIMLog(@"[网络链路检测] 服务器检测开始");
    
    NoaNetworkDetectionMessageModel *serverConnectDetectionMessageModel = self.tableDataSource[index];
    // 将服务器检测置为检测中
    serverConnectDetectionMessageModel.messageStatus = ZNetworkDetectionMessageDetectingStatus;
    [serverConnectDetectionMessageModel.changeStatusSubject sendNext:@(ZNetworkDetectionMessageDetectingStatus)];
    
    NSArray *tcpRacingResultArr;
    if (UserManager.isLogined) {
        // 已经登录的账号，使用网络质量检测类的缓存
        NSArray *tcpServers = [[NoaNetworkQualityDetector sharedDetector].tcpServers copy];
        
        // 用于去重
        NSMutableSet<NSString *> *existingTcpKeys = [NSMutableSet set];
        
        // 转换为 ZNetRacingItemModel
        NSMutableArray <NoaNetRacingItemModel *>* tempTcpServer = [NSMutableArray new];
        [tcpServers enumerateObjectsUsingBlock:^(IMServerEndpoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *key = [NSString stringWithFormat:@"%@:%d", obj.ip, obj.port];
            if ([existingTcpKeys containsObject:key]) {
                // 去重：过滤掉 IP 和端口号相同的 TCP 节点
                return;
            }
            
            [existingTcpKeys addObject:key];
            
            NoaNetRacingItemModel *model = [NoaNetRacingItemModel new];
            model.ip = obj.ip;
            model.sort = obj.port;
            [tempTcpServer addObject:model];
        }];
        
        tcpRacingResultArr = [tempTcpServer copy];
    }else {
        tcpRacingResultArr = [self.tcpRacingResultArr copy];
    }
    
    if (tcpRacingResultArr.count == 0) {
        // 没有可检测的TCP节点，标记为完成
        // 封装结果数据
        NSDictionary *emptyResultInfo = @{
            @"event": @"emptyServerDetectionResult",
            @"isSuccess": @(NO),
            @"duration": @1
        };
        
        // 通过信号发送给上层
        [self.serverDetectionEventSubject sendNext:emptyResultInfo];
        
        // 发送完成信号
        NSDictionary *completionInfo = @{
            @"event": @"serverDetectionCompleted",
        };
        
        [self.serverDetectionEventSubject sendNext:completionInfo];
        
        return;
    }
   
    // 创建并发组，用于追踪所有请求是否完成
    dispatch_group_t group = dispatch_group_create();
    
    @weakify(self)
    for (NoaNetRacingItemModel *tcpItem in tcpRacingResultArr) {
        dispatch_group_enter(group);
        
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
        }
        
        // 将检测逻辑封装到独立方法中，确保每个请求的时间戳独立
        [self executeServerConnectivityCheckWithHost:host
                                                port:port
                                            tcpItem:tcpItem
                                              group:group];  // ✅ 传递版本号
    }
    
    // 等待所有请求完成后，通知上层全部结束
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        @strongify(self)
        
        // 发送完成信号
        NSDictionary *completionInfo = @{
            @"event": @"serverDetectionCompleted",
        };
        
        
        
        [self.serverDetectionEventSubject sendNext:completionInfo];
    });
}

/// 执行单个服务器连通性检测（确保时间戳独立）
/// @param host 主机地址
/// @param port 端口
/// @param tcpItem TCP节点模型
/// @param group 并发组
- (void)executeServerConnectivityCheckWithHost:(NSString *)host
                                          port:(NSString *)port
                                       tcpItem:(NoaNetRacingItemModel *)tcpItem
                                         group:(dispatch_group_t)group {
    // 记录开始时间（每个请求独立的时间戳）
    NSDate *startTime = [NSDate date];
    
    @weakify(self)
    [self checkTcpConnectivityWithHost:host port:port completion:^(BOOL success, LingIMSDKManagerProbeECDHConnectStatus status) {
        @strongify(self)
        
        // 计算耗时（使用当前闭包捕获的 startTime）
        NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:startTime];
        
        // 封装结果数据
        NSDictionary *resultInfo = @{
            @"event": @"serverDetectionResult",
            @"host": host ?: @"",
            @"port": port ?: @"",
            @"isSuccess": @(success),
            @"status": @(status),
            @"duration": @(duration * 1000)
        };
        
        // 通过信号发送给上层
        [self.serverDetectionEventSubject sendNext:resultInfo];
        
        dispatch_group_leave(group);
    }];
}

/// TCP 连通性检测
/// @param host 域名或 IP
/// @param port 端口号
/// @param completion 回调 success 标示连通与否
- (void)checkTcpConnectivityWithHost:(NSString *)host
                                port:(NSString *)port
                          completion:(void(^)(BOOL success, LingIMSDKManagerProbeECDHConnectStatus status))completion {
    // 使用 SDKCore 提供的探测API，避免直接依赖私有头
    uint16_t portValue = (uint16_t)[port integerValue];
    [[NoaIMSDKManager sharedTool] probeECDHConnectivityWithHost:host 
                                                            port:portValue 
                                                         timeout:-1 
                                                            type:0 
                                                      completion:^(BOOL success, LingIMSDKManagerProbeECDHConnectStatus status) {
        if (completion) {
            completion(success, status);
        }
    }];
}

// MARK: 工具方法
/// 随机生成2位数字/字母组合（数字和字母各50%概率）
/// @return 返回2位随机字符串，数字和字母出现概率均等
- (NSString *)generateRandomTwoCharactersWithEqualProbability {
    // 数字字符集 0-9
    NSString *numbers = @"0123456789";
    // 字母字符集 a-z A-Z
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    
    NSMutableString *result = [NSMutableString string];
    
    // 生成2位随机字符
    for (int i = 0; i < 2; i++) {
        // 50% 概率选择数字或字母
        BOOL isNumber = arc4random_uniform(2) == 0;
        
        if (isNumber) {
            // 从数字字符集中随机选择
            uint32_t randomIndex = arc4random_uniform((uint32_t)numbers.length);
            unichar randomChar = [numbers characterAtIndex:randomIndex];
            [result appendFormat:@"%C", randomChar];
        } else {
            // 从字母字符集中随机选择
            uint32_t randomIndex = arc4random_uniform((uint32_t)letters.length);
            unichar randomChar = [letters characterAtIndex:randomIndex];
            [result appendFormat:@"%C", randomChar];
        }
    }
    
    return result;
}

// MARK: 公网IP获取管理
/// 取消公网IP获取任务
- (void)cancelPublicIPTasks {
    if (self.publicIPTasks && self.publicIPTasks.count > 0) {
        CIMLog(@"[网络链路检测] 取消上一次的公网IP获取任务，共 %lu 个，当前版本: %ld", 
              (unsigned long)self.publicIPTasks.count, (long)self.publicIPRequestVersion);
        
        // ✅ 递增版本号，使旧任务的回调失效（即使任务取消失败，回调也会被版本号检查拦截）
        self.publicIPRequestVersion++;
        
        for (NSURLSessionDataTask *task in self.publicIPTasks) {
            if (task.state == NSURLSessionTaskStateRunning) {
                [task cancel];
            }
        }
        [self.publicIPTasks removeAllObjects];
    }
}

/// 获取公网IP（包装 ZTOOL 的方法，并管理任务生命周期）
- (void)getDevicePublicNetworkIPWithCompletion:(void(^)(NSString *ip))completion {
    if (!self.publicIPTasks) {
        self.publicIPTasks = [NSMutableArray array];
    }
    
    // 每次调用递增版本号，用于区分不同批次的请求
    self.publicIPRequestVersion++;
    NSInteger currentVersion = self.publicIPRequestVersion;
    
    CIMLog(@"[公网IP获取] ========== 开始获取公网IP，版本: %ld ==========", (long)currentVersion);
    
    NSArray *ipAPIs = @[
        @"https://ipinfo.io/ip",
        @"https://checkip.amazonaws.com",
        @"http://checkip.amazonaws.com"
    ];

    if (!completion) return;

    __block BOOL ipFound = NO;
    __block NSInteger callbackCount = 0;  // 📊 统计回调次数
    dispatch_group_t group = dispatch_group_create();
    
    @weakify(self)
    for (NSInteger i = 0; i < ipAPIs.count; i++) {
        NSString *apiUrlString = ipAPIs[i];
        dispatch_group_enter(group);
        NSURL *url = [NSURL URLWithString:apiUrlString];
        
        CIMLog(@"[公网IP获取] 任务%ld 创建: %@, 版本: %ld", (long)(i+1), apiUrlString, (long)currentVersion);
        
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url
                                                                 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            @strongify(self)
            
            CIMLog(@"[公网IP获取] 任务%ld 回调开始, 版本: %ld, self.version: %ld, error: %@", 
                  (long)(i+1), (long)currentVersion, (long)self.publicIPRequestVersion, error);
            
            // ✅ 检查版本号，如果不匹配则忽略此次回调
            if (self.publicIPRequestVersion != currentVersion) {
                CIMLog(@"[公网IP获取] ⚠️ 任务%ld 版本号不匹配，忽略回调。当前版本: %ld, 请求版本: %ld", 
                      (long)(i+1), (long)self.publicIPRequestVersion, (long)currentVersion);
                dispatch_group_leave(group);
                return;
            }
            
            if (!error && data) {
                NSString *ipString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                ipString = [ipString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                CIMLog(@"[公网IP获取] 任务%ld 获取到数据: %@, ipFound: %d", (long)(i+1), ipString, ipFound);
                
                if (ipString.length > 0) {
                    // ⚠️ 使用 @synchronized 保护 ipFound 的检查和设置，防止竞态条件
                    @synchronized (self) {
                        if (!ipFound) {
                            ipFound = YES;
                            callbackCount++;
                            
                            CIMLog(@"[公网IP获取] ✅ 任务%ld 触发回调, IP: %@, 版本: %ld, 回调次数: %ld", 
                                  (long)(i+1), ipString, (long)currentVersion, (long)callbackCount);
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                CIMLog(@"[公网IP获取] 📞 执行 completion 回调, IP: %@, 版本: %ld", ipString, (long)currentVersion);
                                completion(ipString);
                            });
                            
                            // 取消剩余仍在运行的任务
                            @synchronized (self.publicIPTasks) {
                                for (NSURLSessionDataTask *t in self.publicIPTasks) {
                                    if (t != task && t.state == NSURLSessionTaskStateRunning) {
                                        CIMLog(@"[公网IP获取] 取消剩余任务: %@", t.originalRequest.URL);
                                        [t cancel];
                                    }
                                }
                            }
                        } else {
                            CIMLog(@"[公网IP获取] ⚠️ 任务%ld ipFound已为YES，跳过回调, IP: %@", (long)(i+1), ipString);
                        }
                    }
                }
            } else {
                CIMLog(@"[公网IP获取] 任务%ld 失败或无数据", (long)(i+1));
            }
            dispatch_group_leave(group);
        }];
        
        @synchronized (self.publicIPTasks) {
            [self.publicIPTasks addObject:task];
        }
        [task resume];
    }

    // 所有任务完成仍未获取到 IP，立即返回空字符串
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        @strongify(self)
        
        CIMLog(@"[公网IP获取] dispatch_group_notify 触发, 版本: %ld, self.version: %ld, ipFound: %d", 
              (long)currentVersion, (long)self.publicIPRequestVersion, ipFound);
        
        // ✅ 检查版本号
        if (self.publicIPRequestVersion != currentVersion) {
            CIMLog(@"[公网IP获取] ⚠️ 版本号不匹配，忽略完成回调。当前版本: %ld, 请求版本: %ld", 
                  (long)self.publicIPRequestVersion, (long)currentVersion);
            return;
        }
        
        if (!ipFound) {
            callbackCount++;
            CIMLog(@"[公网IP获取] ⚠️ 未能获取公网IP，返回空字符串, 版本: %ld, 回调次数: %ld", 
                  (long)currentVersion, (long)callbackCount);
            completion(@"");
        } else {
            CIMLog(@"[公网IP获取] 已获取到IP，不执行空字符串回调");
        }
        
        // 清理任务数组
        @synchronized (self.publicIPTasks) {
            [self.publicIPTasks removeAllObjects];
        }
        
        CIMLog(@"[公网IP获取] ========== 结束，版本: %ld，总回调次数: %ld ==========", (long)currentVersion, (long)callbackCount);
    });
}

// MARK: 取消和清理
/// 取消所有正在进行的网络检测
- (void)cancelAllDetections {
    // 取消公网 IP 获取任务
    [self cancelPublicIPTasks];
    
    // 取消延迟执行任务
    [self cancelAllTasks];
    
    // 取消所有 RAC 订阅
    if (self.allSubscriptionsDisposable) {
        [self.allSubscriptionsDisposable dispose];
        self.allSubscriptionsDisposable = nil;
    }
    
    // 发送取消信号给所有Subject
    if (self.startNetworkStatusDetectionSubject) {
        [self.startNetworkStatusDetectionSubject sendCompleted];
        self.startNetworkStatusDetectionSubject = nil;
    }
    
    if (self.startNavConnectDetectionSubject) {
        [self.startNavConnectDetectionSubject sendCompleted];
        self.startNavConnectDetectionSubject = nil;
    }
    
    if (self.startServerConnectDetectionSubject) {
        [self.startServerConnectDetectionSubject sendCompleted];
        self.startServerConnectDetectionSubject = nil;
    }
    
    if (self.navDetectionEventSubject) {
        [self.navDetectionEventSubject sendCompleted];
        self.navDetectionEventSubject = nil;
    }
    
    if (self.serverDetectionEventSubject) {
        [self.serverDetectionEventSubject sendCompleted];
        self.serverDetectionEventSubject = nil;
    }
    
    // 当检测取消时，通知 RACCommand 订阅者
    if (self.detectionCommandSubscriber) {
//        [self.detectionCommandSubscriber sendNext:@(YES)];
        [self.detectionCommandSubscriber sendCompleted];
        self.detectionCommandSubscriber = nil;
    }
    
    // 清空 DNS 缓存（可选）
    [[DNSResolver share] clearHostCache:nil];
    
    // 重置状态
    [self changeNetworkDetectionStatus:ZNetworkDetectionAlready];
}

/// 清理上一次网络检测的数据
- (void)cleanLastDetectionData {
    // 取消上一次的公网 IP 获取任务
    [self cancelPublicIPTasks];
    
    // 将当前状态改为准备中
    [self changeNetworkDetectionStatus:ZNetworkDetectionAlready];
    
    // 更新头部状态
    [self.headerViewReloadDataSubject sendNext:@{
        @"status" : @(ZNetworkDetectionAlready),
        @"process" : @0
    }];

    // 清楚上一次导航返回的tcp节点数据
    [self.tcpRacingResultArr removeAllObjects];
    [self.ossUrlList removeAllObjects];
    
    // 恢复每个条目的状态
    for (NoaNetworkDetectionMessageModel *messageModel in self.tableDataSource) {
        [messageModel.subFunctionResultArr removeAllObjects];
        messageModel.isFold = YES;
        messageModel.isFinish = NO;
        messageModel.messageStatus = ZNetworkDetectionMessageWaitStatus;
        [messageModel.changeStatusSubject sendNext:@(ZNetworkDetectionMessageWaitStatus)];
    }
    
    // 通知页面刷新UI
    [self.tableViewReloadDataSubject sendNext:@1];
}

// MARK: 延迟执行任务
/// 延迟执行一个任务
- (void)scheduleTaskAfter:(NSTimeInterval)delay block:(dispatch_block_t)block {
    // 创建可取消block
    dispatch_block_t dispatchBlock = dispatch_block_create(0, block);
    [self.tasks addObject:dispatchBlock];
    
    // 延迟执行
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), dispatchBlock);
}

/// 取消所有任务
- (void)cancelAllTasks {
    for (dispatch_block_t block in self.tasks) {
        dispatch_block_cancel(block);
    }
    [self.tasks removeAllObjects];
}

/// dealloc 时自动取消所有任务
- (void)dealloc {
    CIMLog(@"%@ dealloc", self.class);
    
    // 取消所有检测任务
    [self cancelAllDetections];
}




@end
