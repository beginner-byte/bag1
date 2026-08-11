//
//  NoaNodePreferTools.m
//  NoaKit
//
//  Created by Candy on 2024/10/24.
//

#import "NoaNodePreferTools.h"
#import "NoaNetRacingModel.h"
#import "SyncMutableArray.h"
@interface NoaNodePreferTools()
{
    NSCache *_totalTimeCache;//接口耗时统计 NSCache是线程安全的
}

@property (nonatomic, strong)dispatch_source_t refreshNodePreferTimer;   //刷新httpNode

@end

@implementation NoaNodePreferTools

- (instancetype)init {
    if (self = [super init]) {
        _totalTimeCache = [NSCache new];
    }
    return self;
}

- (void)startNodePrefer {
    if (self.httpArr.count > 0) {
        if (self.preferDuring <= 0) {
            self.preferDuring = 300;
        }
        [self refreshHttpNodePrefer];
    }
}

#pragma mark <每5分钟获取一次最新的SystemConfig>
- (void)refreshHttpNodePrefer {
    WeakSelf
    NSString *key = [NSString stringWithFormat:@"nodePreferResult_%@", self.liceseId];
    NSMutableArray *nodeResultList = [[MMKV defaultMMKV] getObjectOfClass:[NSMutableArray class] forKey:key];
    
    //定时器开始执行的延时时间
    NSTimeInterval delayTime = 1;
    //定时器间隔时间
    NSTimeInterval timeInterval = self.preferDuring;
    //创建子线程队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //使用之前创建的队列来创建计时器
    _refreshNodePreferTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //设置延时执行时间，delayTime为要延时的秒数
    dispatch_time_t startDelayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC));
    dispatch_source_set_timer(_refreshNodePreferTimer, startDelayTime, timeInterval * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_refreshNodePreferTimer, ^{
        StrongSelf
        NSMutableArray *tempNodeResultList = [NSMutableArray arrayWithArray:nodeResultList];
        __block NSInteger nodeNum = 0;
        for (int i = 0; i < strongSelf.httpArr.count; i++) {
            NSString *requestHost;
            NSString *httpHost = (NSString *)[strongSelf.httpArr objectAtIndexSafe:i];
            if (![httpHost containsString:@"http"]) {
                requestHost = [NSString stringWithFormat:@"https://%@", httpHost];
            } else {
                requestHost = [httpHost stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
            }
            //挂载证书
            @try {
                [IMSDKHTTPTOOL confighttpSessionManagerCerAndP12CerIsIPAddress:[requestHost checkUrlIsIPAddress]];
            }
            @catch (NSException *exception) {
                NSLog(@"try-catch : %@",exception);
            }

            CFTimeInterval start = CACurrentMediaTime();
            [strongSelf->_totalTimeCache setObject:[NSNumber numberWithDouble:start] forKey:httpHost];
            
            NSString *requestUrl = [NSString stringWithFormat:@"%@%@", httpHost, App_Http_Node_Prefer_Url];
            [weakSelf httpNodeRequestMedthWithUrlStr:requestUrl success:^{
                CFTimeInterval start = [[strongSelf->_totalTimeCache objectForKey:httpHost] longLongValue];
                CFTimeInterval total = CACurrentMediaTime() - start;
                for (int j = 0; j < nodeResultList.count; j++) {
                    NSMutableDictionary *nodeInfoDic = [[nodeResultList objectAtIndexSafe:j] mutableCopy];
                    if (nodeInfoDic != nil && [nodeInfoDic.allKeys containsObject:@"node"]) {
                        NSString *node = (NSString *)[nodeInfoDic objectForKeySafe:@"node"];
                        if ([node isEqualToString:httpHost]) {
                            NSInteger successNum = [[nodeInfoDic objectForKeySafe:@"successNum"] integerValue];
                            double successTotlaTime = [[nodeInfoDic objectForKeySafe:@"successTotlaTime"] doubleValue];
                            successNum += 1;
                            successTotlaTime += total;
                            [nodeInfoDic setObjectSafe:@(successNum) forKey:@"successNum"];
                            [nodeInfoDic setObjectSafe:@(successTotlaTime) forKey:@"successTotlaTime"];
                            [nodeInfoDic setObjectSafe:@(YES) forKey:@"lastState"];
                            
                            [tempNodeResultList replaceObjectAtIndex:j withObject:[nodeInfoDic copy]];
                        }
                    }
                }
                nodeNum++;
                if (nodeNum == nodeResultList.count) {
                    [strongSelf nodePreferResultSortWithArr:[tempNodeResultList copy]];
                }
            } fail:^{
                for (int j = 0; j < nodeResultList.count; j++) {
                    NSMutableDictionary *nodeInfoDic = [[nodeResultList objectAtIndexSafe:j] mutableCopy];
                    if (nodeInfoDic != nil && [nodeInfoDic.allKeys containsObject:@"node"]) {
                        NSString *node = (NSString *)[nodeInfoDic objectForKeySafe:@"node"];
                        if ([node isEqualToString:httpHost]) {
                            [nodeInfoDic setObjectSafe:@(NO) forKey:@"lastState"];
                            [tempNodeResultList replaceObjectAtIndex:j withObject:[nodeInfoDic copy]];
                        }
                    }
                }
                nodeNum++;
                if (nodeNum == nodeResultList.count) {
                    [strongSelf nodePreferResultSortWithArr:[tempNodeResultList copy]];
                }
            }];
        }
    });
    // 启动计时器
    dispatch_resume(_refreshNodePreferTimer);
}

//对nodeResultDict进行一定规则排序，并缓存本地
- (void)nodePreferResultSortWithArr:(NSArray *)nodePreferResult {
    //优先按照成功次数进行排序，其次根据总耗时进行排序
    /**成功次数越多，耗时越短则认为节点越优，成功次数相同时总耗时越短节点越优。**/
    NSArray *sortedArray = [nodePreferResult sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDictionary *dict1 = (NSDictionary *)obj1;
        NSDictionary *dict2 = (NSDictionary *)obj2;

        NSNumber *num1 = dict1[@"successNum"];
        NSNumber *num2 = dict2[@"successNum"];

        if (num1.integerValue > num2.integerValue) {
            return NSOrderedAscending;
        } else if (num1.integerValue < num2.integerValue) {
            return NSOrderedDescending;
        } else {
            NSNumber *time1 = dict1[@"successTotlaTime"];
            NSNumber *time2 = dict2[@"successTotlaTime"];

            if (time1.doubleValue > time2.doubleValue) {
                return NSOrderedDescending;
            } else if (time1.integerValue < time2.integerValue) {
                return NSOrderedAscending;
            } else {
                return NSOrderedSame;
            }
        }
    }];
    NSString *key = [NSString stringWithFormat:@"nodePreferResult_%@", self.liceseId];
    [[MMKV defaultMMKV] setObject:sortedArray forKey:key];
}

- (void)httpNodeRequestMedthWithUrlStr:(NSString *)urlStr success:(void(^)(void))success fail:(void(^)(void))fail {
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:2.0];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    config.URLCache = nil;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
   
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            success();
        } else {
            if (error.code == NSURLErrorNotConnectedToInternet ||   //设备没有连接到互联网
                error.code == NSURLErrorTimedOut ||                 //网络请求超时
                error.code == NSURLErrorCannotConnectToHost||       //无法连接到目标主机
                error.code == NSURLErrorInternationalRoamingOff||   //国际漫游功能关闭
                error.code == NSURLErrorDataNotAllowed ||           //数据访问不被允许
                error.code == NSURLErrorNetworkConnectionLost) {    //链接被重置
                fail();
            } else {
                success();

            }
        }
    }];
    [dataTask resume];
}


@end

