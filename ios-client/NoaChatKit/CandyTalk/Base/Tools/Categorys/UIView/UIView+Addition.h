//
//  UIView+Addition.h
//  NoaKit
//
//  Created by Candy on 2026/8/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Addition)

@property (nonatomic, assign) CGFloat x;
/**  起点y坐标  */
@property (nonatomic, assign) CGFloat y;
/**  中心点x坐标  */
@property (nonatomic, assign) CGFloat centerX;
/**  中心点y坐标  */
@property (nonatomic, assign) CGFloat centerY;
/**  宽度  */
@property (nonatomic, assign) CGFloat width;
/**  高度  */
@property (nonatomic, assign) CGFloat height;
/**  顶部  */
@property (nonatomic, assign) CGFloat top;
/**  底部  */
@property (nonatomic, assign) CGFloat bottom;
/**  左边  */
@property (nonatomic, assign) CGFloat left;
/**  右边  */
@property (nonatomic, assign) CGFloat right;
/**  size  */
@property (nonatomic, assign) CGSize size;
/**  origin */
@property (nonatomic, assign) CGPoint origin;


/**  设置圆角  */
- (void)rounded:(CGFloat)cornerRadius;

/**  设置圆角和边框  */
- (void)rounded:(CGFloat)cornerRadius width:(CGFloat)borderWidth color:(UIColor *)borderColor;

/**  设置圆角和虚线边框  */
- (void)rounded:(CGFloat)cornerRadius width:(CGFloat)borderWidth lineLength:(NSInteger)lineLength color:(UIColor *)borderColor;

/**  设置边框  */
- (void)border:(CGFloat)borderWidth color:(UIColor *)borderColor;

/**   给哪几个角设置圆角  */
-(void)round:(CGFloat)cornerRadius RectCorners:(UIRectCorner)rectCorner;

/**  设置阴影  */
-(void)shadow:(UIColor *)shadowColor opacity:(CGFloat)opacity radius:(CGFloat)radius offset:(CGSize)offset;

/**  获取当前的控制器  */
- (UIViewController *)currentViewController;

/**  获取当前的导航控制器  */
- (UINavigationController *)currentNavigationViewController;

/**  获取当前的TabBar控制器  */
- (UITabBarController *)currentTabBarViewController;

-(CAShapeLayer *)round:(CGRect)bounds TopLeft:(CGFloat)topLeft TopRight:(CGFloat)topRight BottomLeft:(CGFloat)bottomLeft BottomRight:(CGFloat)bottomRight;

- (UIImage *)snapshotImage;
@end

NS_ASSUME_NONNULL_END
