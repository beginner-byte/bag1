//
//  MImageBrowserManager.m
//  MiMaoApp
//
//  Created by Candy on 2020/10/13.
//  Copyright © 2020 MiMao. All rights reserved.
//

#import "MImageBrowserManager.h"
#import "MImageBrowserMacro.h"

static NSTimer *_userInteractionEnableTimer = nil;

@interface MImageBrowserManager ()

@end

@implementation MImageBrowserManager

+ (instancetype)sharedManager{
    static MImageBrowserManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MImageBrowserManager alloc] init];
    });
    return manager;
}

- (void)presentWindowWithController:(UIViewController *)controller{
    [[self class] disableUserInteractionDuration:MImageBrowserDismissImageAnimationDuration];
    
    UIWindow *imageWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _imageWindow = imageWindow;
    _imageWindow.windowLevel = UIWindowLevelStatusBar + 0.1;
    _imageWindow.rootViewController = controller;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.imageWindow setHidden:NO];
    });
}

- (void)dismissWindow:(BOOL)animation{
    if (!animation) {
        [self _dismissWindow];
        return;
    }
    
    [[self class] disableUserInteractionDuration:MImageBrowserDismissImageAnimationDuration];
    [UIView animateWithDuration:MImageBrowserDismissImageAnimationDuration delay:0 options:0 animations:^{
        self->_imageWindow.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self _dismissWindow];
    }];
    
}

- (void)_dismissWindow{
    _imageWindow.hidden = YES;
    _imageWindow.rootViewController = nil;
    _imageWindow = nil;
}
#pragma mark - 禁止屏幕点击响应
+ (void)disableUserInteractionDuration:(NSTimeInterval)timeInterval{
    
    if (_userInteractionEnableTimer != nil) {
        if ([_userInteractionEnableTimer isValid]) {
            [_userInteractionEnableTimer invalidate];
            if ([UIApplication sharedApplication].isIgnoringInteractionEvents) {
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            }
        }
        _userInteractionEnableTimer = nil;
    }
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    _userInteractionEnableTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:timeInterval] interval:0 target:self selector:@selector(userInteractionEnable) userInfo:nil repeats:false];
    [[NSRunLoop mainRunLoop] addTimer:_userInteractionEnableTimer forMode:NSRunLoopCommonModes];
    
}
+ (void)userInteractionEnable{
    [_userInteractionEnableTimer invalidate];
    _userInteractionEnableTimer = nil;
    if ([UIApplication sharedApplication].isIgnoringInteractionEvents) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
}
@end
