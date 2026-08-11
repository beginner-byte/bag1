//
//  NoaTeamInviteDetailDataHandle.h
//  NoaKit
//
//  Created by phl on 2025/7/24.
//

#import <Foundation/Foundation.h>
#import "NoaTeamModel.h"
#import "NoaTeamDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaTeamInviteDetailDataHandle : NSObject

/// 从上个页面传入的团队信息
@property (nonatomic, strong, readonly) NoaTeamModel *currentTeamModel;

/// 获取到的团队详情信息
@property (nonatomic, strong, readonly) NoaTeamDetailModel *teamDetailModel;

/// 请求团队详情上方数据
@property (nonatomic, strong) RACCommand *requestTeamDetailDataCommand;

/// 编辑团队详情
@property (nonatomic, strong) RACCommand *editTeamDetailInfoCommand;

/// 修改新名称
@property (nonatomic, strong) RACSubject *changeNewTeamSubject;

/// 跳转到团队总人数
@property (nonatomic, strong) RACSubject *jumpAllGroupPeoplePageSubject;

/// 是否进行了操作，如果进行了操作，需要刷新
@property (nonatomic, assign) BOOL isOperation;

- (instancetype)initWithTeamModel:(NoaTeamModel *)teamModel;

- (void)changeNewTeamName:(NSString *)newTeamName;

@end

NS_ASSUME_NONNULL_END
