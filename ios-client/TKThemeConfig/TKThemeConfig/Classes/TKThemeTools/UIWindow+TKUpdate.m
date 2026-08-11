//
//  UIWindow+TKUpdate.m
//  Pods
//
//  Created by Tkoul on 2020/6/2.
//

#import "UIWindow+TKUpdate.h"
#import "TKThemeConfig.h"
#import "TKThemeObject.h"
#import <objc/runtime.h>
#import "TKThemeManager.h"
@implementation UIWindow (TKUpdate)
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
- (UIUserInterfaceStyle)overrideUserInterfaceStyle{
    UIUserInterfaceStyle style = (UIUserInterfaceStyle)[objc_getAssociatedObject(self, _cmd) integerValue];
    return style;
}
- (void)setOverrideUserInterfaceStyle:(UIUserInterfaceStyle)overrideUserInterfaceStyle{
    if (@available(iOS 13.0, *)) {
        if ([TKThemeManager config].followSystemTheme) {
            objc_setAssociatedObject(self, @selector(overrideUserInterfaceStyle), @(UIUserInterfaceStyleUnspecified), OBJC_ASSOCIATION_ASSIGN);
        }else{
            objc_setAssociatedObject(self, @selector(overrideUserInterfaceStyle), @(overrideUserInterfaceStyle), OBJC_ASSOCIATION_ASSIGN);
        }
    }
}

- (void)handleTraitCollectionChangedWithWindow: (UIWindow *)window previousTraitCollection: (UITraitCollection *)previousTraitCollection{
    [self customTraitCollectionDidChange:previousTraitCollection source:@"ios17+"];
}

// 重写UIView+TKUpdate.h中的方法
- (void)tkThemeInItBlockConfig{
    if (@available(iOS 17.0, *)) {
        [self registerForTraitChanges:@[[UITraitUserInterfaceStyle class]] withTarget:self action:@selector(handleTraitCollectionChangedWithWindow:previousTraitCollection:)];
    }
}

-(void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];
    
    if (@available(iOS 17.0, *)) {}
    else {
        [self customTraitCollectionDidChange:previousTraitCollection source: @"iOS17-"];
    }
}
#endif

- (void)customTraitCollectionDidChange:(UITraitCollection *)previousTraitCollection source: (NSString *)source {
    [[NSNotificationCenter defaultCenter] postNotificationName:TKTHEMEONTRAITCHANGEDNOTI object:nil userInfo:@{
        @"source": source,
        @"previousIsDark": @(previousTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
    }];
    if (![self isMemberOfClass:[UIWindow class]]) {
        return;
    }
    if (![TKThemeManager config].followSystemTheme) {
        return;
    }
    if (@available(iOS 13.0, *)) {
        UIApplicationState state = [UIApplication sharedApplication].applicationState;
        if (state == UIApplicationStateBackground) {
            //暗黑模式 z获取的是上次的模式  故而 设置需要写相反的模式
            if (previousTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                [[TKThemeManager config] setValue:@([TKThemeManager config].systemThemeDefaultIndex) forKey:tkThemenCofigIndex];
            }else{
                [[TKThemeManager config] setValue:@([TKThemeManager config].systemThemeDarkIndex) forKey:tkThemenCofigIndex];
            }
        }else{
            if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
                //暗黑模式 z获取的是上次的模式  故而 设置需要写相反的模式
                if (previousTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                    [[TKThemeManager config] setValue:@([TKThemeManager config].systemThemeDefaultIndex) forKey:tkThemenCofigIndex];
                }else{
                    [[TKThemeManager config] setValue:@([TKThemeManager config].systemThemeDarkIndex) forKey:tkThemenCofigIndex];
                }
            }
        }
    }else{
        // Fallback on earlier versions
    }
}
@end
