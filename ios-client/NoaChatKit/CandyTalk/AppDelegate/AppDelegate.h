//
//  AppDelegate.h
//  NoaKit
//
//  Created by Apple on 2026/8/9.
//

#import <UIKit/UIKit.h> 
#import "NoaWindowFloatView.h"
#import "NoaMiniAppFloatView.h"
#import "NoaMessageAlertView.h" 

@interface AppDelegate : UIResponder <UIApplicationDelegate,ZWindowFloatViewDelegate, ZMiniAppFloatViewDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) NoaWindowFloatView *viewFloatWindow;//音视频通话 浮窗
@property (nonatomic, strong) NoaMiniAppFloatView *viewFloatMiniApp;//小程序 浮窗
@property (nonatomic, strong) NoaMessageAlertView *translateAlertView;//翻译失败弹窗

- (void)showLocalPush:(NSString *)title body:(NSString *)body userInfo:(NSDictionary *)userInfo withIdentifier:(NSString *)ident playSoud:(BOOL)sound soundName:(NSString *)soundName;

#pragma mark - 登录成功处理
- (void)loginSuccess;
#pragma mark - 注册成功处理
- (void)registerSuccess;

@end
