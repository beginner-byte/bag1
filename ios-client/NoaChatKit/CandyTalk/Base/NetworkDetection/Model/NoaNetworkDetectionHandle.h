//
//  NoaNetworkDetectionHandle.h
//  NoaChatKit
//
//  Created by phl on 2025/10/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NoaNetworkDetectionMessageModel;
@class NoaNetworkDetectionSubResultModel;

typedef NS_ENUM(NSUInteger, ZNetworkDetectionStatus) {
    /// 检测准备
    ZNetworkDetectionAlready,
    /// 检测中
    ZNetworkDetecting,
    /// 检测完成
    ZNetworkDetectFinish,
};

@interface NoaNetworkDetectionHandle : NSObject

/// 开始进行网络检测
@property (nonatomic, strong) RACCommand *startDetectionCommand;

/// 头部视图刷新UI
@property (nonatomic, strong) RACSubject *headerViewReloadDataSubject;

/// 刷新UI
@property (nonatomic, strong) RACSubject *tableViewReloadDataSubject;

/// 当前邀请码(未登录时可为空)
@property (nonatomic, copy, readonly, nullable) NSString *currentSsoNumber;

/// 检测状态
@property (nonatomic, assign, readonly) ZNetworkDetectionStatus networkDetectionStatus;

/// 修改网络检测状态
- (void)changeNetworkDetectionStatus:(ZNetworkDetectionStatus)status;

/// 初始化方法
/// - Parameter ssoNumber: 邀请码
- (instancetype)initWithCurrentSsoNumber:(NSString *)ssoNumber;

// MARK: tableview 相关

/// tableview数据源
@property (nonatomic, strong) NSMutableArray *tableDataSource;

/// 根据区获取对应的数据模型
/// - Parameter section: 当前section
- (NoaNetworkDetectionMessageModel *)getSectionModelWithIndex:(NSInteger)section;

/// 根据区与行获取子信息模型
/// - Parameter indexPath: 当前cell所处的indexPath
- (NoaNetworkDetectionSubResultModel *)getCellModelWithIndexPath:(NSIndexPath *)indexPath;

/// 获取全部未通过的子任务数量（页面头部展示异常）
- (NSInteger)getAllUnPassSubResultCount;

/// 开始网络检测
- (void)startNetworkDetection;

/// 取消所有正在进行的网络检测
- (void)cancelAllDetections;

/// 清理上一次网络检测的数据
- (void)cleanLastDetectionData;

@end

NS_ASSUME_NONNULL_END
