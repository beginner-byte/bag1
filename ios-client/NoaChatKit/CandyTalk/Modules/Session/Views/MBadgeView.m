//
//  MBadgeView.m
//  MUIKit
//
//  Created by 郑开 on 2024/4/1.
//

#import "MBadgeView.h"
@interface MBadgeView ()

//当前视图的快照 真正拖动的视图
@property (nonatomic, strong) UIImageView * snapshot;

//锚点圆点 半径与拖动距离成反比
@property (nonatomic, strong) UIView * anchorPoint;

//快照 与 锚点 之前拉伸的layer
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

//爆炸层
@property (strong, nonatomic) CAEmitterLayer *emitterLayer;

//起点位置 相对于window 的center
@property (nonatomic) CGPoint starPoint;

//小圆尺寸
@property (nonatomic, assign) CGFloat anchorPointWidth;

@end

@implementation MBadgeView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initUI];
}

- (void)initUI {
    self.clipsToBounds = NO;
    self.needDisappearEffects = YES;
    self.badgeCorlor = [UIColor redColor];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = self.badgeCorlor;
    self.maxDistance = 100;

    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_greaterThanOrEqualTo(20);
        make.height.mas_greaterThanOrEqualTo(20);
    }];
    [self addSubview:self.textLb];
    [self.textLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading);
        make.trailing.equalTo(self.mas_trailing);
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
    }];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.cancelsTouchesInView = YES;
    [self addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:tap];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    float radius = MIN(self.frame.size.height,self.frame.size.width);
    self.layer.cornerRadius = radius / 2.0f;
    self.anchorPointWidth = radius;

}

#pragma mark - setter

- (void)setBadgeCorlor:(UIColor *)badgeCorlor {
    _badgeCorlor = badgeCorlor;
    self.backgroundColor = badgeCorlor;
    self.anchorPoint.backgroundColor = badgeCorlor;
}

-(void)setBadge:(NSInteger)badge{
    if(badge <= 0){
        self.textLb.text = nil;
        self.hidden = YES;
    }else if(badge <= 99){
        self.textLb.text = [NSString stringWithFormat:@"%li",badge];
        self.hidden = NO;
    }else{
        self.textLb.text = @"99+";
        self.hidden = NO;
    }
}

-(void)setBadgeText:(NSString *)badge{
    if([badge isEqualToString:@"0"] || [NSString isNil:badge]){
        self.textLb.text = nil;
        self.hidden = YES;
    }else{
        self.textLb.text = badge;
        self.hidden = NO;
    }
}

//当前视图相对于window的中心坐标
-(CGPoint)starPoint{
    return [self.superview convertPoint:self.center toView:nil];
}

#pragma mark - 点击相关
- (void)tap:(UITapGestureRecognizer *)tap {
    if (self.tapBlock) {
        self.tapBlock();
    }
}

#pragma mark - 拖动相关
- (void)pan:(UIPanGestureRecognizer *)pan {
    if (!self.clearBlock) {
        return;
    }
    CGPoint panPoint = [pan locationInView:CurrentWindow];
    CGFloat dist = sqrtf(powf((panPoint.x - self.starPoint.x), 2) + powf((panPoint.y - self.starPoint.y), 2));
    if (pan.state == UIGestureRecognizerStateBegan) {
        [CurrentWindow addSubview:self.anchorPoint];
        [CurrentWindow addSubview:self.snapshot];
        self.alpha = 0;
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        CGFloat minScale = 0.3;
        CGFloat widht = self.anchorPointWidth * minScale + self.anchorPointWidth * (1 - minScale) * (1 - (dist / self.maxDistance)) ;
        self.anchorPoint.frame = CGRectMake(0, 0, widht, widht);
        self.anchorPoint.center = self.starPoint;
        self.anchorPoint.layer.cornerRadius = widht / 2;
        self.snapshot.center = panPoint;
        if (dist < self.maxDistance) {
            self.anchorPoint.hidden = NO;
            self.shapeLayer.path = [self path].CGPath;
        }else{
            self.anchorPoint.hidden = YES;
            [self.shapeLayer removeFromSuperlayer];
            self.shapeLayer = nil;
        }
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        [self.shapeLayer removeFromSuperlayer];
        self.shapeLayer = nil;
        [self.anchorPoint removeFromSuperview];
        self.anchorPoint = nil;
        if (dist > self.maxDistance) {
            [self startAnimate];
            [self.snapshot removeFromSuperview];
            self.snapshot = nil;
            self.hidden = YES;
            self.alpha = 1;
            self.clearBlock();
        }else{
            [UIView animateWithDuration:0.25
                                  delay:0
                 usingSpringWithDamping:1 - dist/self.maxDistance
                  initialSpringVelocity:1 - dist/self.maxDistance
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                self.snapshot.center = self.starPoint;
            } completion:^(BOOL finished) {
                self.alpha = 1;
                [self.snapshot removeFromSuperview];
                self.snapshot = nil;
            }];
        }
        
    }
}

//画两圆的外切线
- (UIBezierPath *)path{
    CGPoint bigCenter = self.snapshot.center;
    CGFloat x2 = bigCenter.x;
    CGFloat y2 = bigCenter.y;
    CGFloat r2 = MIN(self.bounds.size.height, self.bounds.size.width)/2;
    
    CGPoint smallCenter = self.starPoint;
    CGFloat x1 = smallCenter.x;
    CGFloat y1 = smallCenter.y;
    CGFloat r1 = self.anchorPoint.bounds.size.width / 2;
    
    // 获取圆心距离
    CGFloat dist = sqrtf(powf((bigCenter.x - smallCenter.x), 2) + powf((bigCenter.y - smallCenter.y), 2));
    CGFloat sinθ = (x2 - x1) / dist;
    CGFloat cosθ = (y2 - y1) / dist;
    
    // 坐标系基于父控件
    CGPoint pointA = CGPointMake(x1 - r1 * cosθ , y1 + r1 * sinθ);
    CGPoint pointB = CGPointMake(x1 + r1 * cosθ , y1 - r1 * sinθ);
    CGPoint pointC = CGPointMake(x2 + r2 * cosθ , y2 - r2 * sinθ);
    CGPoint pointD = CGPointMake(x2 - r2 * cosθ , y2 + r2 * sinθ);
    
    CGFloat BC_dist = sqrtf(powf((pointB.x - pointC.x), 2) + powf((pointB.y - pointC.y), 2));
    CGFloat sinBC = (pointC.x - pointB.x) / BC_dist;
    CGFloat cosBC = (pointC.y - pointB.y) / BC_dist;

    CGFloat AD_dist = sqrtf(powf((pointA.x - pointD.x), 2) + powf((pointA.y - pointD.y), 2));
    CGFloat sinAD = (pointD.x - pointA.x) / AD_dist;
    CGFloat cosAD = (pointD.y - pointA.y) / AD_dist;
    
    
    //AD,BC 的中点 E,F 离锚点稍微近一点
    CGFloat centerScale = 0.4;
    CGPoint pointE = CGPointMake(pointA.x + AD_dist * centerScale * sinAD , pointA.y + AD_dist * centerScale * cosAD);
    CGPoint pointF = CGPointMake(pointB.x + BC_dist * centerScale * sinBC , pointB.y + BC_dist * centerScale * cosBC);
    
    //EF 距离
    CGFloat EF_dist = sqrtf(powf((pointE.x - pointF.x), 2) + powf((pointE.y - pointF.y), 2));
    CGFloat sinEF = (pointF.x - pointE.x) / EF_dist;
    CGFloat cosEF = (pointF.y - pointE.y) / EF_dist;
    
    //逐渐收拢 不能完全落在E,F上
    CGFloat minScale = 0.3;
    CGFloat scale1 = MIN(MAX(dist / self.maxDistance,minScale),1 - minScale);
    CGFloat scale2 = 1 - scale1;
    CGPoint center1 = CGPointMake(pointE.x + EF_dist * scale1 * sinEF , pointE.y + EF_dist * scale1 * cosEF);
    CGPoint center2 = CGPointMake(pointE.x + EF_dist * scale2 * sinEF , pointE.y + EF_dist * scale2 * cosEF);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    // A
    [path moveToPoint:pointA];
    // AB
    [path addLineToPoint:pointB];
    // 绘制BC曲线
    [path addQuadCurveToPoint:pointC controlPoint:center2];
    // CD
    [path addLineToPoint:pointD];
    // 绘制DA曲线
    [path addQuadCurveToPoint:pointA controlPoint:center1];
    
    return path;
}

//销毁动画
- (void)startAnimate {
    self.emitterLayer.beginTime = CACurrentMediaTime();
    //粒子动画
    [self.emitterLayer setValue:@500 forKeyPath:@"emitterCells.explosion.birthRate"];
    //若干秒后停止粒子动画
    [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
}

//停止动画
- (void)stop {
    [_emitterLayer setValue:@0 forKeyPath:@"emitterCells.explosion.birthRate"];
}

- (CAShapeLayer *)shapeLayer {
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.fillColor = self.badgeCorlor.CGColor;
        [CurrentWindow.layer insertSublayer:_shapeLayer below:self.snapshot.layer];

    }
    return _shapeLayer;
}

//爆炸Layer
- (CAEmitterLayer *)emitterLayer {
    if (!_emitterLayer) {
        //粒子单元
        CAEmitterCell *explosionCell = [CAEmitterCell emitterCell];
        explosionCell.name = @"explosion";
        explosionCell.alphaRange = 1;
        explosionCell.alphaSpeed = 1.0;
        //粒子存活的时间范围
        explosionCell.lifetime = 0.1;
        explosionCell.lifetimeRange = 0.2;
        //每秒生成多少个粒子
        explosionCell.birthRate = 500;
        //粒子平均初始速度范围
        explosionCell.velocity = 50.00;
        explosionCell.velocityRange = 80.00;
        //粒子缩放范围
        explosionCell.scale = 0.5;
        explosionCell.scaleRange = 2;
        explosionCell.contents = (id)[self getExplosionImage].CGImage;//用图片效果更佳
        
        _emitterLayer = [CAEmitterLayer layer];
        _emitterLayer.name = @"emitterLayer";
        _emitterLayer.emitterShape = kCAEmitterLayerCircle;
        _emitterLayer.emitterMode = kCAEmitterLayerOutline;//发射源的发射模式，以一个圆的方式向外扩散开
        _emitterLayer.emitterSize = CGSizeMake(25, 25);
        _emitterLayer.emitterCells = @[explosionCell];
        _emitterLayer.renderMode = kCAEmitterLayerOldestFirst;
        _emitterLayer.masksToBounds = NO;
        [CurrentWindow.layer addSublayer:_emitterLayer];
        
    }
    //在当前中心执行 这个动画
    _emitterLayer.emitterPosition = self.snapshot.center;
    return _emitterLayer;
}

//固定锚点 小圆
- (UIView *)anchorPoint {
    if (!_anchorPoint) {
        _anchorPoint = [[UIView alloc] init];
        _anchorPoint.frame = CGRectMake(0, 0, self.anchorPointWidth, self.anchorPointWidth);
        _anchorPoint.backgroundColor = self.badgeCorlor;
        _anchorPoint.center = self.starPoint;
        _anchorPoint.layer.cornerRadius = self.anchorPoint.frame.size.width / 2;
    }
    return _anchorPoint;
}

//获取需要爆炸的背景图
- (UIImage *)getExplosionImage {
    // 定义圆形的直径
    CGFloat diameter = 2;
    // 开始图形上下文
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), NO, 0.0);
    // 获取当前上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // 设置圆形填充颜色
    [[self.badgeCorlor colorWithAlphaComponent:0.5] setFill];
    // 绘制圆形
    CGContextAddEllipseInRect(ctx, CGRectMake(0, 0, diameter, diameter));
    CGContextFillPath(ctx);
    // 从上下文中获取图片
    UIImage *circleImage = UIGraphicsGetImageFromCurrentImageContext();
    // 结束图形上下文
    UIGraphicsEndImageContext();
    return circleImage;
}

//文字
- (UILabel *)textLb{
    if (_textLb == nil) {
        _textLb = [[UILabel alloc] init];
        _textLb.textColor = [UIColor whiteColor];
        _textLb.font = [UIFont systemFontOfSize:14];
        _textLb.textAlignment = NSTextAlignmentCenter;
        _textLb.backgroundColor = [UIColor clearColor];
        _textLb.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _textLb;
}

//当前视图的 快照图片
- (UIImageView *)snapshot{
    if (_snapshot == nil) {
        _snapshot = [[UIImageView alloc] init];
        _snapshot.backgroundColor = [UIColor clearColor];
        _snapshot.image = [self snapshotImage];
        _snapshot.frame = self.frame;
        _snapshot.center = self.starPoint;
        _snapshot.layer.cornerRadius = self.layer.cornerRadius;
        _snapshot.layer.masksToBounds = YES;

    }
    return _snapshot;
}

@end
