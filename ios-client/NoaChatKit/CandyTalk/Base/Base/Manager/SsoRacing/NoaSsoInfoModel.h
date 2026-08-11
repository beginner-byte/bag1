//
//  NoaSsoInfoModel.h
//  NoaKit
//
//  Created by Candy on 2026/9/15.
//

#import "NoaBaseModel.h"
#import "NoaNetRacingModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaSsoInfoModel : NoaBaseModel

//SSO LiceseID
@property (nonatomic, copy) NSString *liceseId;
//SSO 上一个可用的LiceseID
@property (nonatomic, copy) NSString *lastLiceseId;
//OSS返回内容
@property (nonatomic, strong) NoaNetRacingModel *ossRacingModel;
//IP或者域名+端口号
@property (nonatomic, copy) NSString *ipDomainPortStr;
//SSO 上一个可用的IP或者域名+端口号
@property (nonatomic, copy) NSString *lastIPDomainPortStr;

#pragma mark - 是否设置SSO
+ (BOOL)isConfigSSO;

//获取liceseId
- (NSString *)liceseId;

//获取IP或者域名
- (NSString *)ipDomainPortStr;

#pragma mark - 保存SSO信息
- (void)saveSSOInfo;

#pragma mark - 保存对应邀请码SSO信息
- (void)saveSSOInfoWithLiceseId:(NSString *)liceseId;

#pragma mark - 获取SSO信息整体model
+ (NoaSsoInfoModel *)getSSOInfo;

#pragma mark - 获取对应邀请码SSO信息整体model
+ (NoaSsoInfoModel *)getSSOInfoWithLiceseId:(NSString *)liceseId;

#pragma mark - 获取SSO信息里的邀请码或者直连的ip/域名+端口号
+ (NSString *)getSSOInfoDetailInfo;

#pragma mark - 清除SSO信息
+ (void)clearSSOInfo;


#pragma mark - 清除对应邀请码SSO信息
+ (void)clearSSOInfoWithLiceseId:(NSString *)liceseId;

@end

NS_ASSUME_NONNULL_END
