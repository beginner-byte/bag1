//
//  UIView+Addition.m
//  NoaKit
//
//  Created by Candy on 2026/8/30.
//

#import "UIView+Addition.h"

@implementation UIView (Addition)

#pragma mark - frame
- (void)setX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)x {
    return self.frame.origin.x;
}

- (CGFloat)y {
    return self.frame.origin.y;
}

- (void)setCenterX:(CGFloat)centerX {
    
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
    
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGPoint)origin {
    return self.frame.origin;
}
- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)top {
    CGRect frame = self.frame;
    frame.origin.y = top;
    self.frame = frame;
}

- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)left {
    CGRect frame = self.frame;
    frame.origin.x = left;
    self.frame = frame;
}


- (CGFloat)bottom {
    return self.frame.size.height + self.frame.origin.y;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)right {
    return self.frame.size.width + self.frame.origin.x;
}

- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

#pragma mark - layer
- (void)rounded:(CGFloat)cornerRadius {
    [self rounded:cornerRadius width:0 color:nil];
}

- (void)border:(CGFloat)borderWidth color:(UIColor *)borderColor {
    [self rounded:0 width:borderWidth color:borderColor];
}

- (void)rounded:(CGFloat)cornerRadius width:(CGFloat)borderWidth color:(UIColor *)borderColor {
    self.layer.cornerRadius = cornerRadius;
    self.layer.borderWidth = borderWidth;
    self.layer.borderColor = [borderColor CGColor];
    self.layer.masksToBounds = YES;
}

/**  设置圆角和虚线边框  */
- (void)rounded:(CGFloat)cornerRadius width:(CGFloat)borderWidth lineLength:(NSInteger)lineLength color:(UIColor *)borderColor
{
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.frame = CGRectMake(0, 0, self.width, self.height);
    layer.backgroundColor = [UIColor clearColor].CGColor;

    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:layer.frame cornerRadius:4.0f];
    layer.path = path.CGPath;
    layer.lineWidth = 1.0f;
    layer.lineDashPattern = @[@(lineLength), @(lineLength)];
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = borderColor.CGColor;

    [self.layer addSublayer:layer];
}


-(void)round:(CGFloat)cornerRadius RectCorners:(UIRectCorner)rectCorner {
    if (cornerRadius == 0) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:nil cornerRadii:CGSizeZero];
        CAShapeLayer *layer1 = [[CAShapeLayer alloc]init];
        layer1.frame = self.bounds;
        layer1.path = path.CGPath;
        self.layer.mask = layer1;
    }else{
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:rectCorner cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        self.layer.mask = maskLayer;
    }
}


-(void)shadow:(UIColor *)shadowColor opacity:(CGFloat)opacity radius:(CGFloat)radius offset:(CGSize)offset {
    //给Cell设置阴影效果
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = shadowColor.CGColor;
    self.layer.shadowOpacity = opacity;
    self.layer.shadowRadius = radius;
    self.layer.shadowOffset = offset;
}



#pragma mark - base
- (UIViewController *)currentViewController {
    
    id nextResponder = [self nextResponder];
    while (nextResponder != nil) {
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            UIViewController *vc = (UIViewController *)nextResponder;
            return vc;
        }
        nextResponder = [nextResponder nextResponder];
    }
    return nil;
}

#pragma mark - 当前导航栏
- (UINavigationController *)currentNavigationViewController {
    
    id nextResponder = [self nextResponder];
    while (nextResponder != nil) {
        if ([nextResponder isKindOfClass:[UINavigationController class]]) {
            UINavigationController *vc = (UINavigationController *)nextResponder;
            return vc;
        }
        nextResponder = [nextResponder nextResponder];
    }
    return nil;
}

#pragma mark - 当前导航栏
- (UITabBarController *)currentTabBarViewController {
    
    id nextResponder = [self nextResponder];
    while (nextResponder != nil) {
        if ([nextResponder isKindOfClass:[UITabBarController class]]) {
            UITabBarController *vc = (UITabBarController *)nextResponder;
            return vc;
        }
        nextResponder = [nextResponder nextResponder];
    }
    return nil;
}
-(CAShapeLayer *)round:(CGRect)bounds TopLeft:(CGFloat)topLeft TopRight:(CGFloat)topRight BottomLeft:(CGFloat)bottomLeft BottomRight:(CGFloat)bottomRight
{
    CGFloat minX = bounds.origin.x;

    CGFloat minY = bounds.origin.y;

    CGFloat maxX = bounds.origin.x + bounds.size.width;

    CGFloat maxY = bounds.origin.y + bounds.size.height;

 

    //获取四个圆心

    CGFloat topLeftCenterX = minX +  topLeft;

    CGFloat topLeftCenterY = minY + topLeft;

     

    CGFloat topRightCenterX = maxX - topRight;

    CGFloat topRightCenterY = minY + topRight;

    

    CGFloat bottomLeftCenterX = minX +  bottomLeft;

    CGFloat bottomLeftCenterY = maxY - bottomLeft;

     

    CGFloat bottomRightCenterX = maxX -  bottomRight;

    CGFloat bottomRightCenterY = maxY - bottomRight;

    

    

    

    //虽然顺时针参数是YES，在iOS中的UIView中，这里实际是逆时针

    CGMutablePathRef path = CGPathCreateMutable();

    

    CGPathAddArc(path, NULL, topLeftCenterX, topLeftCenterY, topLeft, M_PI, M_PI*3/2, false);

    CGPathAddArc(path, NULL, topRightCenterX, topRightCenterY, topRight, M_PI*3/2, 0, false);

    CGPathAddArc(path, NULL, bottomRightCenterX, bottomRightCenterY, bottomRight, 0, M_PI/2, false);

    CGPathAddArc(path, NULL, bottomLeftCenterX, bottomLeftCenterY, bottomLeft, M_PI/2, M_PI, false);

    CGPathCloseSubpath(path);

    

    CAShapeLayer *shapLayer = [CAShapeLayer layer];

    shapLayer.frame = bounds;

    shapLayer.path = path;

    return shapLayer;

}

- (UIImage *)snapshotImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}
@end
