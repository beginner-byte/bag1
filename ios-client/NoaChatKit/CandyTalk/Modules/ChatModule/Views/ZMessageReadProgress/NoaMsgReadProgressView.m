//
//  NoaMsgReadProgressView.m
//  NoaKit
//
//  Created by Candy on 2026/11/22.
//

#import "NoaMsgReadProgressView.h"

@interface NoaMsgReadProgressView()

/// 半径
@property (nonatomic, assign) CGFloat radius;
/// 填充色
@property (nonatomic, strong) UIColor *fillColor;
/// 边框颜色
@property (nonatomic, strong) UIColor *borderColor;
/// 边框粗细
@property (nonatomic, assign) CGFloat borderWidth;
/// 未读和已读img
@property (nonatomic, strong) UIImageView *statusImgView;

@end

@implementation NoaMsgReadProgressView

- (instancetype)initWithRadius:(CGFloat)radius fillColor:(UIColor *)fillColor{
    if (self = [super init]) {
        self.backgroundColor = COLOR_CLEAR;
        
        _radius = radius ?: 16;
        _fillColor = fillColor ?: [UIColor cyanColor];
        
        _statusImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, DWScale(15), DWScale(15))];
        _statusImgView.image = ImgNamed(@"img_msg_not_readed");
        _statusImgView.hidden = YES;
        [self addSubview:_statusImgView];
    }
    return self;
}

- (void)configBorderWithColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth {
    _borderColor = borderColor;
    _borderWidth = borderWidth;
}

#pragma mark - 更新进度
- (void)setProgress:(float)progress{
    _progress = progress;
    if (_progress <= 0) {
        _statusImgView.hidden = NO;
        _statusImgView.image = ImgNamed(@"img_msg_not_readed");
        _borderColor = COLOR_CLEAR;
        _borderWidth = 0;
        _fillColor = COLOR_CLEAR;
    } else if (_progress >= 1) {
        _statusImgView.hidden = NO;
        _statusImgView.image = ImgNamed(@"img_msg_all_readed");
        _borderColor = COLOR_CLEAR;
        _borderWidth = 0;
        _fillColor = COLOR_CLEAR;
    } else {
        _statusImgView.hidden = YES;
        _borderColor = COLOR_5966F2;
        _borderWidth = 1.5;
        _fillColor = COLOR_5966F2;
    }
    [self setNeedsDisplay];
}


#pragma mark - 绘制图形
- (void)drawRect:(CGRect)rect {
    [self drawLine];
    [self drawProgress];
}

// 绘制外圈线条
- (void)drawLine {
    CGPoint origin = CGPointMake(_radius/2, _radius/2);
    CGFloat radius = _radius/2 - _borderWidth/2;
    CGFloat startAngle = 0;
    CGFloat endAngle = 2*M_PI;
    UIBezierPath *sectorPath = [UIBezierPath bezierPathWithArcCenter:origin radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    sectorPath.lineWidth = _borderWidth;
    [_borderColor set];
    [sectorPath strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
}

// 绘制进度条
- (void)drawProgress {
    // 中心点
    CGPoint origin = CGPointMake(_radius/2, _radius/2);
    // 半径
    CGFloat radius = _radius/2 - 2.5;
    // 起始角度，默认top
    CGFloat startAngle = - M_PI_2;
    // 结束角度
    CGFloat endAngle = [self fetchEndAngle];
    // 开始绘制
    UIBezierPath *sectorPath = [UIBezierPath bezierPathWithArcCenter:origin radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [sectorPath addLineToPoint:origin];
    [_fillColor set];
    [sectorPath fill];
}

#pragma mark - Tools 根据进度计算结束位置
- (CGFloat)fetchEndAngle {
    CGFloat angle =- M_PI_2 + self.progress * M_PI * 2;
    return angle;
}

@end
