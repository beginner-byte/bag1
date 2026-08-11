//
//  NoaTeamListDataHandle.h
//  NoaKit
//
//  Created by phl on 2025/7/21.
//

#import <Foundation/Foundation.h>
#import "NoaBaseModel.h"
#import "NoaTeamModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaTeamListDataHandle : NoaBaseModel

/// 团队顶部详情
@property (nonatomic, strong) NoaTeamModel *defaultTeamModel;

/// 团队列表
@property (nonatomic, strong) NSMutableArray <NoaTeamModel *>*teamListModelArr;

/// 请求团队首页上方数据
@property (nonatomic, strong) RACCommand *requestTeamHomeDataCommand;

/// 请求团队列表数据
@property (nonatomic, strong) RACCommand *requestTeamListCommand;

/// 下拉刷新数据
- (void)resumeDefaultConfigure;

/// 上拉加载数据
- (void)requestMoreDataConfigure;

/// 根据indexPath获取团队模型
/// - Parameter indexPath: indexPath
- (NoaTeamModel *)obtainTeamModelWithIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
