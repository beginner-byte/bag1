//
//  NoaAudioPlayAnimationView.m
//  NoaKit
//
//  Created by Candy on 2023/1/14.
//

#import "NoaAudioPlayAnimationView.h"

/*间隙*/
#define kDrawMargin         4
/*蓝条宽度*/
#define kDrawLineWidth      2.5

@interface NoaAudioPlayAnimationView ()<CAAnimationDelegate>

/*条条 灰色路径*/
@property (nonatomic, strong)CAShapeLayer *shapeLayer;
/*背景蓝色*/
@property (nonatomic, strong)CAShapeLayer *backColorLayer;
@property (nonatomic, strong)CAShapeLayer *maskLayer;

/** 本地先设定好每个小圆柱的高度幅度 */
@property (nonatomic, strong)NSArray *localHeightArr;

@end

@implementation NoaAudioPlayAnimationView
{
    dispatch_source_t _animationTimer;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = COLOR_CLEAR;
        [self.layer addSublayer:self.shapeLayer];
        [self.layer addSublayer:self.backColorLayer];
        self.persentage = 0.0;
        
        float drawHeight = DWScale(22) - 6;
        _localHeightArr = [[NSArray alloc] initWithObjects:
                           @(drawHeight*0.25), @(drawHeight), @(drawHeight*0.5), @(drawHeight*0.7), @(drawHeight*0.66), @(drawHeight*0.58), @(drawHeight*0.85), @(drawHeight*0.77), @(drawHeight*0.45), @(drawHeight*0.45), @(drawHeight*0.45), @(drawHeight*0.45), @(drawHeight*0.45), @(drawHeight*0.45), @(drawHeight*0.45), @(drawHeight*0.9), @(drawHeight*0.8), @(drawHeight*0.85), @(drawHeight*0.75), @(drawHeight*0.82), @(drawHeight*0.82), @(drawHeight*0.82), @(drawHeight*0.3), @(drawHeight*0.4), @(drawHeight*0.55), @(drawHeight*0.2), @(drawHeight*0.25), @(drawHeight), @(drawHeight*0.5), @(drawHeight*0.7), @(drawHeight*0.66), @(drawHeight*0.58), @(drawHeight*0.85), @(drawHeight*0.77), @(drawHeight*0.45), @(drawHeight*0.45), @(drawHeight*0.45), @(drawHeight*0.45), @(drawHeight*0.45), @(drawHeight*0.45), @(drawHeight*0.45), @(drawHeight*0.9), @(drawHeight*0.8), @(drawHeight*0.85), @(drawHeight*0.75), @(drawHeight*0.45), @(drawHeight*0.3), @(drawHeight*0.24), @(drawHeight*0.15), @(drawHeight*0.1), nil];
    }
    return self;
}

#pragma mark ---Layers
//初始化layer 在完成frame赋值后调用一下
-(void)initLayers{
    [self initStrokeLayer];
    [self setBackColorLayer];
}

/*灰色路径*/
-(void)initStrokeLayer{
    CGFloat maxWidth = self.frame.size.width;
    CGFloat drawHeight = self.frame.size.height - 3;
    int dataNum = ceil(maxWidth / (kDrawMargin + kDrawLineWidth));
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat x = 5;
    for (int i = 0; i < dataNum; i++) {
        if (x+kDrawLineWidth <= maxWidth)
        {
            CGFloat h =  [[_localHeightArr objectAtIndex:i] floatValue];
            [path moveToPoint:CGPointMake(x-kDrawLineWidth/2, drawHeight)];
            [path addLineToPoint:CGPointMake(x-kDrawLineWidth/2, drawHeight - h)];
            x += kDrawLineWidth;
            x += kDrawMargin;
        }
    }
    self.shapeLayer.path = path.CGPath;
    self.backColorLayer.path = path.CGPath;
}

/*设置背景layer*/
-(void)setBackColorLayer{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, self.frame.size.height/2)];
    [path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height/2)];
    self.maskLayer.frame = self.bounds;
    self.maskLayer.lineWidth = self.frame.size.width;
    self.maskLayer.path= path.CGPath;
    self.backColorLayer.mask = self.maskLayer;
}

-(void)setAnimationPersentage:(CGFloat)persentage{
    CGFloat startPersentage = self.persentage;
    [self setPersentage:persentage];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 1;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnimation.fromValue = [NSNumber numberWithFloat:startPersentage];
    pathAnimation.toValue = [NSNumber numberWithFloat:persentage];
    pathAnimation.autoreverses = NO;
    pathAnimation.delegate = self;
    [self.maskLayer addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
}
//在修改百分比的时候，修改彩色遮罩的大小
//@param persentage 百分比
- (void)setPersentage:(CGFloat)persentage {
    _persentage = persentage;
    self.maskLayer.strokeEnd = persentage;
}

#pragma mark - Action
- (void)startAnimation {
    __block int timeout = 0; //计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _animationTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    
    __weak typeof(self) weakSelf = self;
    //开始的时间
    dispatch_time_t startTime = dispatch_walltime(NULL, 1 * NSEC_PER_SEC);
    //间隔的时间
    uint64_t interval = 1 * NSEC_PER_SEC;
    dispatch_source_set_timer(_animationTimer,startTime,interval, 0); //每1秒执行
    dispatch_source_set_event_handler(_animationTimer, ^{
        if(timeout > weakSelf.duringTime){ //倒计时结束，关闭
            dispatch_source_cancel(self->_animationTimer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                weakSelf.persentage = 1.0;
            });
        }else{
            int seconds = timeout % 60;
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                //NSLog(@"____%@",strTime);
                [weakSelf setAnimationPersentage:seconds / (weakSelf.duringTime * 1.0)];
                //NSLog(@"____%0.2f",weakSelf.persentage);
            });
            timeout++;
        }
    });
    //启动定时器
    dispatch_resume(_animationTimer);
}

- (void)stopAnimation {
    [self setPersentage:0.0];
    if (_animationTimer) {
        dispatch_source_cancel(_animationTimer);
    }
}

- (void)setIsSelfMsg:(BOOL)isSelfMsg {
    _isSelfMsg = isSelfMsg;
    if (_isSelfMsg) {
        _shapeLayer.strokeColor = [COLORWHITE colorWithAlphaComponent:0.35].CGColor; // 路径颜色颜色
        _backColorLayer.strokeColor = COLORWHITE.CGColor; // 路径颜色颜色
        _maskLayer.strokeColor = COLORWHITE.CGColor;
    } else {
        _shapeLayer.strokeColor = COLOR_CCCCCC.CGColor; // 路径颜色颜色
        _backColorLayer.strokeColor = COLOR_5966F2.CGColor; // 路径颜色颜色
        _maskLayer.strokeColor = COLOR_5966F2.CGColor;
    }
}

#pragma mark --- Lazy
-(CAShapeLayer*)shapeLayer{
    if(!_shapeLayer){
        _shapeLayer = [[CAShapeLayer alloc] init];
        _shapeLayer.lineWidth = kDrawLineWidth;
        _shapeLayer.fillColor = [UIColor clearColor].CGColor; // 填充色为透明（不设置为黑色）
        _shapeLayer.lineCap = kCALineCapRound; // 设置线为圆角
        _shapeLayer.strokeColor = COLOR_CCCCCC.CGColor; // 路径颜色颜色
    }
    return _shapeLayer;
}

-(CAShapeLayer*)backColorLayer{
    if(!_backColorLayer){
        _backColorLayer = [[CAShapeLayer alloc] init];
        _backColorLayer.lineWidth = kDrawLineWidth;
        _backColorLayer.fillColor = [UIColor clearColor].CGColor; // 填充色为透明（不设置为黑色）
        _backColorLayer.lineCap = kCALineCapRound; // 设置线为圆角
        _backColorLayer.strokeColor = COLOR_5966F2.CGColor; // 路径颜色颜色
    }
    return _backColorLayer;
}

-(CAShapeLayer *)maskLayer{
    if(!_maskLayer){
        _maskLayer = [[CAShapeLayer alloc] init];
        //路径颜色颜色
        _maskLayer.strokeColor = COLOR_5966F2.CGColor;
    }
    return _maskLayer;
}

@end
