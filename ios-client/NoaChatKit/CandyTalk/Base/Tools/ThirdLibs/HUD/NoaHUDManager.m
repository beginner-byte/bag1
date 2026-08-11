//
//  NoaHUDManager.m
//  NoaIMChatService
//
//  Created by Candy on 2026/7/8.
//

/// 使用UIActivityIndicatorView来显示进度，这是默认值
//MBProgressHUDModeIndeterminate

/// 使用一个圆形饼图来作为进度视图
//MBProgressHUDModeDeterminate

/// 使用一个水平进度条
//MBProgressHUDModeDeterminateHorizontalBar

/// 使用圆环作为进度条
//MBProgressHUDModeAnnularDeterminate

/// 显示一个自定义视图，通过这种方式，可以显示一个正确或错误的提示图
//MBProgressHUDModeCustomView

/// 只显示文本
//MBProgressHUDModeText

//统一显示时长
#define kHudShowTime 1.5

#import "NoaHUDManager.h"
#import "NoaToolManager.h"

@implementation NoaHUDManager

+ (instancetype)shareManager{
    static NoaHUDManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NoaHUDManager alloc] init];
    });
    
    return manager;
}

#pragma mark - 显示一条消息提示
- (void)showMessage:(NSString *)message{
    [self showMessage:message inView:nil];
}
- (void)showMessage:(NSString *)message inView:(UIView *)view{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self show:message imageName:nil view:view];
    });
}

#pragma mark - 通过后台返回的errorCode去匹配到本地翻译后的文字内容
- (void)showMessageWithCode:(NSInteger)msgCode errorMsg:(NSString *)msg {
    [self showMessage:LanguageToolCodeMatch(msgCode, msg) inView:nil];
}
- (void)showMessageWithCode:(NSInteger)msgCode errorMsg:(NSString *)msg inView:(UIView * _Nullable)view {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self show:LanguageToolCodeMatch(msgCode, msg) imageName:nil view:view];
    });
}

#pragma mark - 显示成功提示
- (void)showSuccessMessage:(NSString *)message{
    [self showSuccessMessage:message inView:nil];
}
- (void)showSuccessMessage:(NSString *)message inView:(UIView *)view{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self show:message imageName:@"success.png" view:view];
    });
}
#pragma mark - 显示错误提示
- (void)showErrorMessage:(NSString *)message{
    [self showErrorMessage:message inView:nil];
}
- (void)showErrorMessage:(NSString *)message inView:(UIView *)view{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self show:message imageName:@"error.png" view:view];
    });
}
#pragma mark - 显示警告提示
- (void)showWarningMessage:(NSString *)message{
    [self showWarningMessage:message inView:nil];
}
- (void)showWarningMessage:(NSString *)message inView:(UIView *)view{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self show:message imageName:@"warning.png" view:view];
    });
}

#pragma mark - 显示加载提示
- (MBProgressHUD *)showActivityMessage:(NSString *)message{
    if (self.hud) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.hud = [self showActivityMessage:message inView:nil];
        });
    }else {
        __block MBProgressHUD *hud;
        dispatch_async(dispatch_get_main_queue(), ^{
            hud = [self showActivityMessage:message inView:nil];
        });
        self.hud = hud;
    }
    return self.hud;
}
- (MBProgressHUD *)showActivityMessage:(NSString *)message inView:(UIView *)view{
    if (view == nil) view = CurrentWindow;
    self.viewShow = view;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    //文本
    hud.label.text = message;
    //模式
    hud.mode = MBProgressHUDModeIndeterminate;
    //深色背景
    hud.bezelView.blurEffectStyle = UIBlurEffectStyleDark;
    //浅色内容
    hud.contentColor = UIColor.whiteColor;
    
    hud.removeFromSuperViewOnHide = YES;
    
    self.hud = hud;
    
    return hud;
}

#pragma mark - 移除HUD
- (void)hideHUD{
    //if (self.viewShow == nil) self.viewShow = [[UIApplication sharedApplication].windows lastObject];
    
    
    if ([NSThread isMainThread]) {
        // 是主线程，直接刷新页面
        if (self.viewShow == nil) self.viewShow = CurrentWindow;
        [MBProgressHUD hideHUDForView:self.viewShow animated:YES];
        
        if (self.hud == nil) self.hud = [MBProgressHUD new];
        [self.hud hideAnimated:YES];
    } else {
        // 不是主线程，回到主线程刷新页面
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.viewShow == nil) self.viewShow = CurrentWindow;
            [MBProgressHUD hideHUDForView:self.viewShow animated:YES];
            
            if (self.hud == nil) self.hud = [MBProgressHUD new];
            [self.hud hideAnimated:YES];
        });
    }
}



#pragma mark - 显示带有图片或者不带图片的信息
- (void)show:(NSString *)textStr imageName:(NSString * _Nullable)imageStr view:(UIView * _Nullable)view{
    
    [self hideHUD];
    
    if (view == nil) view = CurrentWindow;
    
    self.viewShow = view;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    //文本
    //hud.label.text = textStr;
    hud.detailsLabel.text = textStr;
    hud.detailsLabel.font = [UIFont boldSystemFontOfSize:16];
    hud.margin = 16;
    
    //图片
    if (imageStr.length > 0) {
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@",imageStr]];
        hud.customView = [[UIImageView alloc] initWithImage:img];
        hud.mode = MBProgressHUDModeCustomView;
    }else {
        //模式
        hud.mode = MBProgressHUDModeText;
    }
    
    //隐藏时从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    //深色背景
    hud.bezelView.blurEffectStyle = UIBlurEffectStyleDark;
    //浅色内容
    hud.contentColor = UIColor.whiteColor;
    
    self.hud = hud;
    
    [hud hideAnimated:YES afterDelay:kHudShowTime];
    
}

@end
