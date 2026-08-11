//
//  NoaSafeCodeCloseViewController.h
//  NoaKit
//
//  Created by Candy on 2025/1/2.
//

#import "CandyBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

//手势密码验证类型
typedef NS_ENUM(NSUInteger, SafeCodeOperatorType) {
    SafeCodeOperatorTypeClose = 1,       //关闭验证（验证原安全码）
    SafeCodeOperatorTypePassword = 2,    //关闭验证（验证登录密码）
};

@interface NoaSafeCodeCloseViewController : CandyBaseViewController

@property (nonatomic, assign) SafeCodeOperatorType operatorType;


@end

NS_ASSUME_NONNULL_END
