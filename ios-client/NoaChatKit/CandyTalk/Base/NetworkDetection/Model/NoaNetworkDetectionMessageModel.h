//
//  NoaNetworkDetectionMessageModel.h
//  NoaChatKit
//
//  Created by phl on 2025/10/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZNetworkDetectionMessageStatus) {
    ZNetworkDetectionMessageWaitStatus,
    ZNetworkDetectionMessageDetectingStatus,
    ZNetworkDetectionMessageEndStatus,
};

typedef NS_ENUM(NSUInteger, ZNetworkDetectionSectionType) {
    /// 网络连接情况
    ZNetworkDetectionNetworkConnectSectionType,
    /// 已停用的域名解析检测类型；保留枚举值以维持后续类型编号兼容
    ZNetworkDetectionDomainNameResolutionSectionType,
    /// 导航链接检测
    ZNetworkDetectionNavConnectDetectionSectionType,
    /// 服务器链接检测(仅限输入邀请码)
    ZNetworkDetectionServerConnectDetectionSectionType
};

/// 子功能检测结果数据模型
@interface NoaNetworkDetectionSubResultModel : NSObject

/// 结果标题
@property (nonatomic, copy) NSString *resultTitleStr;

/// 结果码
@property (nonatomic, copy) NSString *resultStatusCodeStr;

/// 是否通过检测
@property (nonatomic, assign) BOOL isPass;

@end

/// 检测消息结果模型
@interface NoaNetworkDetectionMessageModel : NSObject

/// 每个区间的标题
@property (nonatomic, copy) NSString *sectionTitle;

/// 通知检测状态变化
@property (nonatomic, strong) RACSubject *changeStatusSubject;

/// 是否检测完成
@property (nonatomic, assign) BOOL isFinish;

/// 是否折叠
@property (nonatomic, assign) BOOL isFold;

@property (nonatomic, assign) ZNetworkDetectionSectionType sectionType;

/// 子模块检测状态
@property (nonatomic, assign) ZNetworkDetectionMessageStatus messageStatus;

/// 子功能检测结果
@property (nonatomic, strong) NSMutableArray <NoaNetworkDetectionSubResultModel *>*subFunctionResultArr;

/// 子任务是否全部成功
- (BOOL)isAllSubFunctionPass;

@end

NS_ASSUME_NONNULL_END
