//
//  NoaHUDManager.h
//  NoaIMChatService
//
//  Created by Candy on 2026/7/8.
//

#define HUD [NoaHUDManager shareManager]

#import <Foundation/Foundation.h>
#import <MBProgressHUD/MBProgressHUD.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaHUDManager : NSObject
@property (nonatomic, strong) UIView  *viewShow;
@property (nonatomic, strong) MBProgressHUD  *hud;

//单例
+ (instancetype)shareManager;

#pragma mark - 显示一条消息提示
- (void)showMessage:(NSString *)message;
- (void)showMessage:(NSString *)message inView:(UIView * _Nullable)view;

#pragma mark - 显示成功提示
- (void)showSuccessMessage:(NSString *)message;
- (void)showSuccessMessage:(NSString *)message inView:(UIView * _Nullable)view;

#pragma mark - 显示错误提示
- (void)showErrorMessage:(NSString *)message;
- (void)showErrorMessage:(NSString *)message inView:(UIView * _Nullable)view;

#pragma mark - 显示警告提示
- (void)showWarningMessage:(NSString *)message;
- (void)showWarningMessage:(NSString *)message inView:(UIView * _Nullable)view;

#pragma mark - 显示加载提示
- (MBProgressHUD *)showActivityMessage:(NSString *)message;
- (MBProgressHUD *)showActivityMessage:(NSString *)message inView:(UIView * _Nullable)view;

#pragma mark - 通过后台返回的errorCode去匹配到本地翻译后的文字内容
- (void)showMessageWithCode:(NSInteger)msgCode errorMsg:(NSString *)msg;
- (void)showMessageWithCode:(NSInteger)msgCode errorMsg:(NSString *)msg inView:(UIView * _Nullable)view;

#pragma mark - 移除HUD
- (void)hideHUD;
@end

NS_ASSUME_NONNULL_END
