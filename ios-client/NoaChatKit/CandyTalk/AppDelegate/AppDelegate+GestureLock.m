//
//  AppDelegate+GestureLock.m
//  NoaKit
//
//  Created by Candy on 2023/4/24.
//

#import "AppDelegate+GestureLock.h"
#import "NoaToolManager.h"

@implementation AppDelegate (GestureLock)

#pragma mark - 检查用户的手势锁配置情况
- (void)checkUserGestureLock {
    
    if (!UserManager.isLogined) return;
    
    UIViewController *currentVC = CurrentVC;
    if (!currentVC) return;
    
    // 如果当前已经是手势锁控制器，直接返回
    if ([currentVC isKindOfClass:[NoaGestureLockCheckVC class]]) return;
    
    // 如果当前控制器已经有 presentedViewController，说明已经有其他控制器被 present 了，不重复 present
    if (currentVC.presentedViewController) return;
    
    WeakSelf
    NSString *userKey = [NSString stringWithFormat:@"%@-GesturePassword", UserManager.userInfo.userUID];
    NSString *gesturePasswordJson = [[MMKV defaultMMKV] getStringForKey:userKey];
    if (![NSString isNil:gesturePasswordJson]) {
        //设置了手势验证
        // 使用很短的延迟，确保视图层级已经完全准备好，避免闪烁
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            // 再次检查，防止在延迟期间状态发生变化
            UIViewController *checkVC = CurrentVC;
            if (!checkVC) return;
            
            // 如果当前已经是手势锁控制器，直接返回
            if ([checkVC isKindOfClass:[NoaGestureLockCheckVC class]]) return;
            
            // 如果当前控制器已经有 presentedViewController，说明已经有其他控制器被 present 了，不重复 present
            if (checkVC.presentedViewController) return;
            
            NoaGestureLockCheckVC *vc = [NoaGestureLockCheckVC new];
            vc.delegate = weakSelf;
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            vc.checkType = GestureLockCheckTypeNormal;
            // 使用无动画的 present，避免闪烁
            [checkVC presentViewController:vc animated:NO completion:nil];
        });
    }
}

#pragma mark - ZGestureLockCheckVCDelegate
- (void)gestureLockCheckResultType:(GestureLockCheckResultType)checkResultType checkType:(GestureLockCheckType)checkType {
    if (checkResultType == GestureLockCheckResultTypeRight) {
        if (checkType == GestureLockCheckTypeClose) {
            //关闭手势密码
        }else if (checkType == GestureLockCheckTypeChange) {
            //修改手势密码
        }else {
            //普通手势密码验证
        }
    }
}

@end
