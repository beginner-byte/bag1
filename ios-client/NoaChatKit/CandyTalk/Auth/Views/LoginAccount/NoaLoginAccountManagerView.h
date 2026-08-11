//
//  NoaLoginAccountManagerView.h
//  NoaChatKit
//
//  Created by phl on 2025/11/6.
//

#import "NoaLoginBaseBlurView.h"

NS_ASSUME_NONNULL_BEGIN

@class NoaLoginAccountDataHandle;

/// Figma 登录页点击邀请码入口后的无参回调。
typedef void(^NoaLoginInviteCodeBlock)(void);

@interface NoaLoginAccountManagerView : NoaLoginBaseBlurView

/// 点击邀请码入口后由登录控制器执行原有页面跳转。
@property (nonatomic, copy, nullable) NoaLoginInviteCodeBlock clickInviteCodeBlock;

/// 使用既有登录数据处理对象创建 Swift 登录页业务协调视图。
/// @param frame 初始区域，最终由控制器约束为全屏。
/// @param manager 既有登录数据处理对象。
/// @return 完成页面与业务绑定的协调视图。
- (instancetype)initWithFrame:(CGRect)frame
                   DataHandle:(NoaLoginAccountDataHandle *)manager;

/// 刷新 Swift 页面显示的手机区号。
- (void)refreshShowAreaCode;

/// 刷新后端配置支持的登录方式并回到首个页签。
- (void)reloadSupportLoginType;

@end

NS_ASSUME_NONNULL_END
