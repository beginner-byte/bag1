//
//  MImageBrowserManager.h
//  MiMaoApp
//
//  Created by Candy on 2020/10/13.
//  Copyright © 2020 MiMao. All rights reserved.
//

// 图片浏览--管理类

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MImageBrowserManager : NSObject
+ (instancetype)sharedManager;

- (void)presentWindowWithController:(UIViewController *)controller;
- (void)dismissWindow:(BOOL)animation;

@property (nonatomic, strong) UIWindow *imageWindow;

@end

#define ImageBrowserManager [MImageBrowserManager sharedManager]

NS_ASSUME_NONNULL_END
