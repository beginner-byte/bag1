//
//  NoaUrlHostManager.h
//  NoaKit
//
//  Created by Candy on 2023/2/8.
//


/** 默认的 apiUrl、Port，socketHost、Port */

#define ZHostTool [NoaUrlHostManager shareManager]

//获取App系统设置接口
#define App_Get_System_Setting_Url      @"/biz/system/v2/getSystemConfig"
//ip/域名直连时获取Tcp的域名或者ip
#define App_Get_Tcp_Connect_List_Url    @"/biz/sso/connect"

#import <Foundation/Foundation.h>
#import "NoaSystemSettingModel.h"
#import <AFNetworking/AFNetworking.h>
#import "NoaNetRacingModel.h"
#import <NoaChatCore/NoaIMSocketManager.h>
#import "IOSTcpRaceManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface NoaUrlHostManager : NSObject

@property (nonatomic, copy)NSString *apiHost;       //短连接域名+端口号
@property (nonatomic, copy)NSString *getFileHost;     //视频文件域名+端口号
@property (nonatomic, copy)NSString *uploadfileHost;      //文件、图片域名+端口号
//@property (nonatomic, copy)NSString *socketHost;    //socket域名
//@property (nonatomic, copy)NSString *socketPort;    //socket端口号
@property (nonatomic, assign)BOOL isReloadRacing;   //是否为竞速失败点击了失败页的重新加载
@property (nonatomic, strong)NoaSystemSettingModel *appSysSetModel;   //项目基本配置信息
@property (nonatomic, assign)ZReacingType racingType;   //当前是采用那种方式竞速(邀请码或者 ip/域名直连)
@property (nonatomic, copy)NSString *ossInfoAppKey;    //邀请码AppKey
@property (nonatomic, strong, nullable)NSData * cerData;
@property (nonatomic, strong, nullable)NSData * p12Data;
@property (nonatomic, copy)NSString * p12pwd;

#pragma mark - 单例的实现
+ (instancetype)shareManager;
// 单例一般不需要清空，但是在执行某些功能的时候，防止数据清空不及时可以清空一下
- (void)clearManager;

#pragma mark - 对oss、http、tcp进行择优或者检查IP/Domain是否可用
- (void)startHostNodeRace;
#pragma mark - 单独对tcp竞速
- (void)tcpNodePickOver;

/// 停止网络质量检测
- (void)stopNetworkQualityDetection;

//配置confighttpSessionManagerSecurityPolicy的安全策略和p12证书
- (void)confighttpSessionManagerCerAndP12Cer:(AFHTTPSessionManager *)manager isIPAddress:(BOOL)isIPAddress;

- (void)QRcodeSacnNav:(IMServerListResponseBody *)serverResponse;

@end

NS_ASSUME_NONNULL_END
