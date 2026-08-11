//
//  NoaGroupNoticeListDataHandle.h
//  NoaKit
//
//  Created by phl on 2025/8/11.
//

#import <Foundation/Foundation.h>
#import "LingIMGroup.h"
NS_ASSUME_NONNULL_BEGIN
@class NoaGroupNoteLocalUserNameModel;
@interface NoaGroupNoticeListDataHandle : NSObject

/// 当前群信息
@property (nonatomic, strong, readonly) LingIMGroup *groupInfoModel;

/// 初始化
/// - Parameter groupInfoModel: 当前群消息
- (instancetype)initWithGroupInfo:(LingIMGroup *)groupInfoModel;

/// 获取群公告列表
@property (nonatomic, strong) RACCommand *requestListDataCommand;

/// 获取群公告详情(判断是否已经被删除)
@property (nonatomic, strong) RACCommand *requestNoticeDetailCommand;

/// 删除群公告列表
@property (nonatomic, strong) RACCommand *deleteDataCommand;

/// 进入群公告详情页面
@property (nonatomic, strong) RACSubject *jumpGroupInfoDetailSubject;

/// 进入群公告编辑页面
@property (nonatomic, strong) RACSubject *jumpEditSubject;

/// 置顶公告列表
@property (nonatomic, strong) NSMutableArray <NoaGroupNoteLocalUserNameModel *>*topGroupNoteModelList;

/// 普通公告列表
@property (nonatomic, strong) NSMutableArray <NoaGroupNoteLocalUserNameModel *>*normalGroupNoteModelList;

/// 下拉刷新数据
- (void)resumeDefaultConfigure;

/// 上拉加载数据
- (void)requestMoreDataConfigure;

/// 根据indexPath获取群公告信息模型
/// - Parameter indexPath: indexPath
- (NoaGroupNoteLocalUserNameModel *)obtainGroupModelWithIndexPath:(NSIndexPath *)indexPath;



@end

NS_ASSUME_NONNULL_END
