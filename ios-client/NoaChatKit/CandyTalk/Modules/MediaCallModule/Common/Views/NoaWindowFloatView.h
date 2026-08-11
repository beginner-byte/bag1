//
//  NoaWindowFloatView.h
//  NoaKit
//
//  Created by Candy on 2023/1/9.
//

// 可全局拖拽的View

#import <UIKit/UIKit.h>
@class NoaWindowFloatView;

//拖拽方向
typedef NS_ENUM(NSUInteger, ZWDragDirection) {
    ZWDragDirectionAny,           //任意方向
    ZWDragDirectionHorizontal,    //水平方向
    ZWDragDirectionVertical,      //垂直方向
};

//拖拽代理
@protocol ZWindowFloatViewDelegate <NSObject>
@optional

/// 开始拖动
- (void)beganDragFloatView:(NoaWindowFloatView * _Nullable)floatView;
/// 拖动中...
- (void)duringDragFloatView:(NoaWindowFloatView * _Nullable)floatView;
/// 结束拖动
- (void)endDragFloatView:(NoaWindowFloatView * _Nullable)floatView;
/// 点击事件
- (void)clickFloatView:(NoaWindowFloatView * _Nullable)floatView;

@end

NS_ASSUME_NONNULL_BEGIN

@interface NoaWindowFloatView : UIView

/// 是否可以拖拽，默认是YES可拖拽
@property (nonatomic, assign) BOOL dragEnable;

/// view的拖拽活动范围，默认为父视图的frame范围内
/// 如果设置了，则会在给定的活动范围内活动
/// 如果没设置，则会在父视图范围内活动
/// 注意：设置的frame不要大于父视图范围
/// 注意：设置的frame为(0,0,0,0)表示活动的范围为默认的父视图frame
/// 如果想要不能活动，请设置dragEnable这个属性为NO
@property (nonatomic, assign) CGRect freeRect;

/// 拖拽的方向，默认为any任意方向
@property (nonatomic, assign) ZWDragDirection dragDirection;

/**
 contentView内部懒加载的一个UIImageView
 开发者也可以自定义控件添加到本view中
 注意：最好不要同时使用内部的imageView和button
 */
@property (nonatomic,strong) UIImageView *imageView;
/**
 contentView内部懒加载的一个UIButton
 开发者也可以自定义控件添加到本view中
 注意：最好不要同时使用内部的imageView和button
 */
@property (nonatomic,strong) UIButton *button;
/**
 是不是总保持在父视图边界，默认为NO,没有黏贴边界效果
 isKeepBounds = YES，它将自动黏贴边界，而且是最近的边界
 isKeepBounds = NO， 它将不会黏贴在边界，它是free(自由)状态，跟随手指到任意位置，但是也不可以拖出给定的范围frame
 */
@property (nonatomic,assign) BOOL isKeepBounds;

@property (nonatomic, weak) id <ZWindowFloatViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
