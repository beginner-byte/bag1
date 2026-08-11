//
//  NoaMiniAppFloatView.h
//  NoaKit
//
//  Created by Candy on 2023/7/19.
//

#import <UIKit/UIKit.h>

@class NoaMiniAppFloatView;

//拖拽方向
typedef NS_ENUM(NSUInteger, ZFloatDragDirection) {
    ZFloatDragDirectionAny,           //任意方向
    ZFloatDragDirectionHorizontal,    //水平方向
    ZFloatDragDirectionVertical,      //垂直方向
};

typedef NS_ENUM(NSUInteger, ZFloatKeepBoundsType) {
    ZFloatKeepBoundsTypeLeft,           //左侧
    ZFloatKeepBoundsTypeRight,          //右侧
    ZFloatKeepBoundsTypeTop,            //顶部
    ZFloatKeepBoundsTypeBottom,         //底部
    ZFloatKeepBoundsTypeOther,          //其他
};

//拖拽代理
@protocol ZMiniAppFloatViewDelegate <NSObject>
@optional

/// 开始拖动
- (void)beganDragMiniAppFloatView:(NoaMiniAppFloatView * _Nullable)floatView;
/// 拖动中...
- (void)duringDragMiniAppFloatView:(NoaMiniAppFloatView * _Nullable)floatView;
/// 结束拖动
- (void)endDragMiniAppFloatView:(NoaMiniAppFloatView * _Nullable)floatView;
/// 点击事件
- (void)clickMiniAppFloatView:(NoaMiniAppFloatView * _Nullable)floatView;

@end

NS_ASSUME_NONNULL_BEGIN

@interface NoaMiniAppFloatView : UIView

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
@property (nonatomic, assign) ZFloatDragDirection dragDirection;

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

@property (nonatomic, assign) ZFloatKeepBoundsType keepBoundsType;//边界类型

@property (nonatomic, weak) id <ZMiniAppFloatViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END

