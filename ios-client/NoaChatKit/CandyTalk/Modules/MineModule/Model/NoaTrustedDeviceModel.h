//
//  NoaTrustedDeviceModel.h
//  CandyTalk
//
//  Created by Codex on 2026/8/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 信任设备列表项，对应 /trustedDevice/list 返回的单个设备。
@interface NoaTrustedDeviceModel : NSObject

/// 服务端设备唯一标识，允许接口缺失时为空。
@property (nonatomic, copy, nullable) NSString *deviceUuid;
/// 设备平台类型，例如 ANDROID、IOS。
@property (nonatomic, copy, nullable) NSString *deviceType;
/// 用户可识别的设备名称。
@property (nonatomic, copy, nullable) NSString *deviceName;
/// 最近一次访问 IP。
@property (nonatomic, copy, nullable) NSString *lastIp;
/// 上一次访问 IP。
@property (nonatomic, copy, nullable) NSString *previousIp;
/// 是否存在服务端判定的 IP 异常。
@property (nonatomic, assign) BOOL anomalyFlag;
/// 累计异常次数，默认值为 0。
@property (nonatomic, assign) NSInteger anomalyCount;
/// 最近一次 IP 变化时间，格式由服务端返回。
@property (nonatomic, copy, nullable) NSString *ipChangedAt;
/// 设备被设为信任设备的时间，格式由服务端返回。
@property (nonatomic, copy, nullable) NSString *trustedAt;
/// 最近活跃时间，格式由服务端返回。
@property (nonatomic, copy, nullable) NSString *lastSeenAt;
/// 是否为当前登录设备。
@property (nonatomic, assign, getter=isCurrent) BOOL current;

@end

NS_ASSUME_NONNULL_END
