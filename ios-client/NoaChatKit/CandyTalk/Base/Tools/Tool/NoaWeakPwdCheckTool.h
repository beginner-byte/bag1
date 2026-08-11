//
//  NoaWeakPwdCheckTool.h
//  NoaChatKit
//
//  Created by blackcat on 2025/10/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaWeakPwdCheckTool : NSObject

// 单例方法
+ (instancetype)sharedInstance;

// 用户密码
@property (nonatomic, copy, nullable) NSString *userPwd;

// 获取当前的导航控制器
@property (nonatomic, weak, nullable) UINavigationController *currentNavigationController;


// 检测用户是否是弱密码
- (void)checkPwdStrengthWithCompletion: (void(^)(BOOL doNext))completion;

// 弹出修改密码提示框
- (void)alertChangePwdTipView;

@end

NS_ASSUME_NONNULL_END
