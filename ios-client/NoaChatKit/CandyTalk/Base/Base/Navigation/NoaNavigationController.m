//
//  NoaNavigationController.m
//  NoaIMChatService
//
//  Created by Candy on 2026/7/8.
//

#import "NoaNavigationController.h"

@interface NoaNavigationController () <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@end

@implementation NoaNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delegate = self;
    //解决滑动返回手势失效问题
    self.interactivePopGestureRecognizer.delegate = (id)self;
}


#pragma mark - UINavigationControllerDelegate
/// 页面即将显示时隐藏宿主系统导航栏，保留业务页的自绘导航。
/// @param navigationController 当前承载页面的导航控制器。
/// @param viewController 即将显示的页面控制器。
/// @param animated 是否跟随本次页面切换动画。
-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    //全局隐藏导航栏
    [navigationController setNavigationBarHidden:YES animated:animated];
}

/// 页面显示完成后再次确保宿主系统导航栏处于隐藏状态。
/// @param navigationController 当前承载页面的导航控制器。
/// @param viewController 已经显示的页面控制器。
/// @param animated 是否跟随本次页面切换动画。
-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    //全局隐藏导航栏
    [navigationController setNavigationBarHidden:YES animated:animated];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    //左滑如果上一级是根视图，有时会界面卡死的处理
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        if (self.viewControllers.count < 2) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - 跳转处理
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (self.viewControllers.count) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

#pragma mark - 状态栏处理
// 状态栏模式交给topViewController控制
- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

// 状态栏显示、隐藏交给topViewController控制
- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
