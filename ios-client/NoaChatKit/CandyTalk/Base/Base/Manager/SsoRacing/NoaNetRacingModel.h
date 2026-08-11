//
//  NoaNetRacingModel.h
//  NoaKit
//
//  Created by Candy on 2023/5/16.
//

#import "NoaBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaNetRacingItemModel : NoaBaseModel

@property (nonatomic, copy)NSString *ip;
@property (nonatomic, assign)NSInteger sort;

@end

//Http
@interface NoaNetRacingHttpModel : NoaBaseModel

@property (nonatomic, strong)NSArray<NoaNetRacingItemModel *> *dnsList;
@property (nonatomic, strong)NSArray<NoaNetRacingItemModel *> *ipList;

@end

//Tcp
@interface NoaNetRacingTcpModel : NoaBaseModel

@property (nonatomic, strong)NSArray<NoaNetRacingItemModel *> *dnsList;
@property (nonatomic, strong)NSArray<NoaNetRacingItemModel *> *ipList;

@end

//Endpoints
@interface NoaNetRacingEndpointsModel : NoaBaseModel

@property (nonatomic, strong)NoaNetRacingHttpModel *http;
@property (nonatomic, strong)NoaNetRacingTcpModel *tcp;

@end

//oss返回的数据model
@interface NoaNetRacingModel : NoaBaseModel

@property (nonatomic, copy)NSString *version;   //版本
@property (nonatomic, copy)NSString *appKey;    //邀请码id
@property (nonatomic, copy)NSString *clientCer;
@property (nonatomic, copy)NSString *clientP12;
@property (nonatomic, copy)NSString *clientKey;
@property (nonatomic, strong)NoaNetRacingEndpointsModel *endpoints;
@property (nonatomic, assign)BOOL is_merge_version;
@property (nonatomic, assign)NSInteger ping_interval_second;
@property (nonatomic, strong)NSArray *oldHttpNodeArr;
@property (nonatomic, strong)NSArray *httpNodeArr;

//组装后的数据
@property (nonatomic, strong)NSArray *httpArr;
@property (nonatomic, strong)NSArray *tcpArr;

//获取数据存储到本地的时间戳
@property (nonatomic, strong)NSData *cerData;
@property (nonatomic, strong)NSData *p12Data;

@end



//httpDNS解析本地缓存数据model
@interface NoaHttpDNSLocalModel : NoaBaseModel

@property (nonatomic, strong)NSString *httpDoamin;
@property (nonatomic, strong)NSString *ossBucket;
@property (nonatomic, assign)ZDNSLocalModelType localModelType;

@end

NS_ASSUME_NONNULL_END
