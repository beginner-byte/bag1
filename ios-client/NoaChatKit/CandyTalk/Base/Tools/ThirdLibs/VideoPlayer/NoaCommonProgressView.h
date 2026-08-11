//
//  NoaCommonProgressView.h
//  NoaKit
//
//  Created by Candy on 2026/9/26.
//

// 自定义 通用进度条

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZCommonGestureState) {
    ZCommonGestureStateUnKnown,
    ZCommonGestureStateBegin,
    ZCommonGestureStateMove,
    ZCommonGestureStateEnd,
};

@protocol ZCommonProgressViewDelegate <NSObject>
- (void)progressViewCurrentPlayPrecent:(CGFloat)precent dragState:(ZCommonGestureState)dragState;
@end

@interface NoaCommonProgressView : UIView
@property (nonatomic, weak) id <ZCommonProgressViewDelegate> delegate;
//YES:进度条高度4，NO:进度条高度2
@property (nonatomic, assign, getter=isShowBigProgress) BOOL showBigProgress;
//YES:展示圆点，NO:隐藏圆点
@property (nonatomic, assign, getter=isShowDot) BOOL showDot;
//YES:可拖拽，NO:不可拖拽
@property (nonatomic, assign, getter=isEnablePan) BOOL enablePan;


- (instancetype)initWithFrame:(CGRect)frame viewHeight:(CGFloat)progressH dotHeight:(CGFloat)dotHeight color:(UIColor *)defaultColor progressColor:(UIColor *)progressColor dragColor:(UIColor *)dragColor cornerRadius:(CGFloat)cornerRadius progressDotImage:(UIImage * _Nullable)dotImage enablePanProgress:(BOOL)enablePan;

+ (CGFloat)progressViewVisibleHeight;
- (CGFloat)value;

// 变更进度，animateWithDuration是传入动画时间
- (void)setValue:(CGFloat)value;
- (void)setValue:(CGFloat)value animateWithDuration:(NSTimeInterval)duration time:(NSTimeInterval)time;
- (void)setValue:(CGFloat)value animateWithDuration:(NSTimeInterval)duration completion:(void (^__nullable)(BOOL finished))completion;
// 重置所有状态，会将进度重置到0
- (void)reset;
// 暂停动画
- (void)pauseAnimation;
// 恢复动画
- (void)resumeAnimation;
// 清理动画状态，手动拖拽时先清理动画状态
- (void)removeProgressAnimation;
@end

NS_ASSUME_NONNULL_END
