//
//  MImageBrowserVC.h
//  MiMaoApp
//
//  Created by Candy on 2020/10/13.
//  Copyright © 2020 MiMao. All rights reserved.
//

// 图片浏览--VC

#import <UIKit/UIKit.h>
#import "MImageBrowserModel.h"

@class MImageBrowserVC;

typedef void(^MBCustomUIBlock)(MImageBrowserVC * _Nullable vc);

@protocol MImageBrowserVCDelegate <NSObject>
@optional
//动画消失的目标frame
- (UIImageView *_Nullable)sourceImageViewForIndex:(NSInteger)index;
//获取图片展示占位图
- (UIImage *_Nullable)imageBrowserPlaceholderImage;
//更多按钮点击事件
- (void)imageBrowserMoreForIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_BEGIN

@interface MImageBrowserVC : UIViewController
//在viewDidLoad的最后调用，方便用户自定义UI
@property (nonatomic, copy) MBCustomUIBlock customUIBlock;

//代理
@property (nonatomic, weak) id <MImageBrowserVCDelegate> delegate;

@property (nonatomic, strong, readonly) UIScrollView  *scrollView;
@property (nonatomic, strong, readonly) UILabel  *lblPage;

//当前显示的图片位置索引，默认是0
@property (nonatomic, assign) NSInteger currentImageIndex;

//浏览的图片数量，大于0
@property (nonatomic, assign) NSInteger imageCount;

//图片数组，内部可以是MImageBrowserModel, UIImage, NSString, NSData
@property (nonatomic, strong) NSArray *imageArr;

//是否显示更多按钮
@property (nonatomic, assign) BOOL showMoreBtn;

/// 初始化的方法
/// @param imageArr 图片数组
/// @param currentImageIndex 当前显示图片下标
+ (instancetype)showImageBrowserWithImages:(NSArray *)imageArr currentImageIndex:(NSInteger)currentImageIndex;


/// 初始化的方法 -- 如需实现动画，必须实现代理方法
/// @param imageArr 图片数组
/// @param currentImageIndex 当前显示图片下标
/// @param delegate 代理
+ (instancetype)showImageBrowserWithImages:(NSArray *)imageArr currentImageIndex:(NSInteger)currentImageIndex delegate:(id <MImageBrowserVCDelegate> _Nullable)delegate;

/// 移除方法
/// @param animation 是否动画
- (void)dismissAnimation:(BOOL)animation;

@end

NS_ASSUME_NONNULL_END
