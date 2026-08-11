//
//  NoaSignInRuleModel.h
//  NoaKit
//
//  Created by Candy on 2024/12/26.
//

#import "NoaBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaSignInRuleModel : NoaBaseModel

@property (nonatomic, copy) NSString *signContinueReward;//连续签到奖励规则（{天:金额}）
@property (nonatomic, copy) NSString *signContinueRule;//签到连签模式规则描述
@property (nonatomic, assign) long long signDayMoney;//连续签到-签到每日金额
@property (nonatomic, assign) long long signInSwitch;//签到开关 0：关闭 1：开启
@property (nonatomic, assign) long long signMaxMoney;//随机签到-签到最大金额
@property (nonatomic, assign) long long signMinMoney;//随机签到-签到最小金额
@property (nonatomic, assign) long long signMode;//签到模式（1：签到随机 2：连签模式）
@property (nonatomic, copy) NSString *signRandomRule;//签到随机规则描述

@end

NS_ASSUME_NONNULL_END
