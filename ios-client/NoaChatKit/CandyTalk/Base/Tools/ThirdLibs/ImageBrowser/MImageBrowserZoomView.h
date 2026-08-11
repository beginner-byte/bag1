//
//  MImageBrowserZoomView.h
//  MiMaoApp
//
//  Created by Candy on 2020/10/13.
//  Copyright © 2020 MiMao. All rights reserved.
//

// 图片浏览--缩放View

#import <UIKit/UIKit.h>
#import "MImageBrowserModel.h"

#if __has_include(<UIImageView+WebCache.h>)
#import <UIImageView+WebCache.h>
#else
#import "UIImageView+WebCache.h"
#endif

#if __has_include(<SDImageCache.h>)
#import <SDImageCache.h>
#else
#import "SDImageCache.h"
#endif


@class MImageBrowserZoomView;

//图片展示状态
typedef NS_ENUM(NSUInteger, ShowImageState) {
    ShowImageStateSmall,      //初始化 默认是小图
    ShowImageStateBig,          //全屏的正常图片
    ShowImageStateOrigin,     //原图
};

//代理
@protocol MImageBrowserZoomViewDelegate <NSObject>
- (CGRect)dismissRect;
- (UIImage *_Nullable)zoomViewPlaceholderImage;

@end

NS_ASSUME_NONNULL_BEGIN

@interface MImageBrowserZoomView : UIScrollView <UIScrollViewDelegate>
@property (nonatomic, weak) id <MImageBrowserZoomViewDelegate> zoomDelegate;
@property (nonatomic, assign, readonly) ShowImageState imageState;
@property (nonatomic, strong, readonly) UIImageView  *imageView;
@property (nonatomic, assign) CGFloat process;

- (void)resetScale;
- (void)showImageWithModel:(MImageBrowserModel *)model;
- (void)dismissAnimation:(BOOL)animation;

@end

NS_ASSUME_NONNULL_END
