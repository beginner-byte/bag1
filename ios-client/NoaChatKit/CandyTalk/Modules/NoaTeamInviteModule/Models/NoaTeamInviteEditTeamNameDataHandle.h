//
//  NoaTeamInviteEditTeamNameDataHandle.h
//  NoaKit
//
//  Created by phl on 2025/7/25.
//

#import <Foundation/Foundation.h>
#import "NoaTeamModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface NoaTeamInviteEditTeamNameDataHandle : NSObject

/// 从上个页面传入的团队信息
@property (nonatomic, strong, readonly) NoaTeamModel *currentTeamModel;

/// 编辑团队详情
@property (nonatomic, strong) RACCommand *editTeamDetailInfoCommand;

/// 返回上一级页面
@property (nonatomic, strong) RACSubject *backSubject;

- (instancetype)initWithTeamModel:(NoaTeamModel *)teamModel;

@end

NS_ASSUME_NONNULL_END
