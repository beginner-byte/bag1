//
//  NoaGestureLockCheckAccountPasswordView.h
//  NoaKit
//
//  Created by Candy on 2023/4/24.
//

// 手势密码，验证账号密码View

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZGestureLockCheckAccountPasswordDelegate <NSObject>
- (void)gestureLockCheckAccountPasswordSuccess;//验证用户密码成功
- (void)gestureLockCheckAccountPasswordFail;//验证用户密码失败，跳转到登录界面
@end

@interface NoaGestureLockCheckAccountPasswordView : UIView
@property (nonatomic, weak) id <ZGestureLockCheckAccountPasswordDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
