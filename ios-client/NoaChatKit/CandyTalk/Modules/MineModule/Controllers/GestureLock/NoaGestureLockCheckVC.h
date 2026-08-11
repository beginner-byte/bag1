//
//  NoaGestureLockCheckVC.h
//  NoaKit
//
//  Created by Candy on 2023/4/24.
//

// 手势密码验证VC

#import "CandyBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

//手势密码验证结果
typedef NS_ENUM(NSUInteger, GestureLockCheckResultType) {
    GestureLockCheckResultTypeRight = 0,   //手势密码验证成功
    GestureLockCheckResultTypeError = 1,   //手势密码验证错误
    GestureLockCheckResultTypeLock = 2,    //手势密码验证锁定
};

//手势密码验证类型
typedef NS_ENUM(NSUInteger, GestureLockCheckType) {
    GestureLockCheckTypeNormal = 0,      //普通验证
    GestureLockCheckTypeChange = 1,      //修改验证
    GestureLockCheckTypeClose = 2,       //关闭验证
};

@protocol ZGestureLockCheckVCDelegate <NSObject>
- (void)gestureLockCheckResultType:(GestureLockCheckResultType)checkResultType checkType:(GestureLockCheckType)checkType;
@end

@interface NoaGestureLockCheckVC : CandyBaseViewController
@property (nonatomic, weak) id <ZGestureLockCheckVCDelegate> delegate;
@property (nonatomic, assign) GestureLockCheckType checkType;
@end

NS_ASSUME_NONNULL_END
