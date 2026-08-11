//
//  MImageBrowserGestureHandle.h
//  MiMaoApp
//
//  Created by Candy on 2020/10/13.
//  Copyright © 2020 MiMao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MImageBrowserZoomView,MImageBrowserGestureHandle;

@protocol MImageBrowserGestureHandleDelegate <NSObject>
//获取当前展示的图片对象
- (MImageBrowserZoomView *_Nullable)currentDetailImageViewInImagePreview:(MImageBrowserGestureHandle *_Nullable)handle;
//图片对象移除
- (void)detailImageViewDismiss;
//控制图片控制器中，照片墙，更多 等小组件的隐藏/显示
- (void)imagePreviewComponmentHidden:(BOOL)hidden;

@end

NS_ASSUME_NONNULL_BEGIN

@interface MImageBrowserGestureHandle : NSObject
//代理
@property (nonatomic, weak) id <MImageBrowserGestureHandleDelegate> delegate;
//初始化
- (instancetype)initWithScrollView:(UIScrollView *)scrollView coverView:(UIView *)coverView;
@end

NS_ASSUME_NONNULL_END
