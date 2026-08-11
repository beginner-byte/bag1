//
//  NoaGroupActivityInfoModel.h
//  NoaKit
//
//  Created by Candy on 2025/2/24.
//

#import "NoaBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaGroupActivityActionModel : NoaBaseModel

@property (nonatomic, copy) NSString *actionType;
@property (nonatomic, copy) NSString *actionTypeDesc;
@property (nonatomic, assign) NSInteger score;

@end


@interface NoaGroupActivityLevelModel : NoaBaseModel

@property (nonatomic, copy) NSString *alias;//别名
@property (nonatomic, copy) NSString *level;//级别
@property (nonatomic, assign) NSInteger minScore;//最低分数

@end


@interface NoaGroupActivityInfoModel : NoaBaseModel

@property (nonatomic, strong) NSArray <NoaGroupActivityActionModel *> *actions;
@property (nonatomic, assign) NSInteger dailyLimit;
@property (nonatomic, assign) NSInteger gid;
@property (nonatomic, assign) NSInteger activityId;
@property (nonatomic, strong) NSArray <NoaGroupActivityLevelModel *> *levels;
@property (nonatomic, strong) NSArray <NoaGroupActivityLevelModel *> *sortLevels;
@property (nonatomic, copy) NSString *updatedTime;

@end

NS_ASSUME_NONNULL_END
