//
//  NoaCommonProgressView.m
//  NoaKit
//
//  Created by Candy on 2026/9/26.
//

#define ZResponseWH 40

#import "NoaCommonProgressView.h"

@interface NoaCommonProgressView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIButton *progressIconButton;
@property (nonatomic, strong) UIView *leftBarView;
@property (nonatomic, strong) UIView *rightBarView;
@property (nonatomic, strong) NSNumber *valueNum;
@property (nonatomic, assign) CGFloat progressBarHeight;
@property (nonatomic, strong) UIColor *inProgressColor;
@property (nonatomic, strong) UIColor *dragColor;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, strong) UIPanGestureRecognizer *panGes;
@property (nonatomic, assign) int lastTime; //秒，非浮点数
@property (nonatomic, assign) CGFloat lastX;

@end

@implementation NoaCommonProgressView

- (instancetype)initWithFrame:(CGRect)frame viewHeight:(CGFloat)progressH dotHeight:(CGFloat)dotHeight color:(UIColor *)defaultColor progressColor:(UIColor *)progressColor dragColor:(UIColor *)dragColor cornerRadius:(CGFloat)cornerRadius progressDotImage:(UIImage * _Nullable)dotImage enablePanProgress:(BOOL)enablePan {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *rightView = [[UIView alloc] init];
        rightView.size = CGSizeMake(self.width, progressH);
        rightView.backgroundColor = defaultColor;
        rightView.centerY = 0.5 * frame.size.height;
        [self addSubview:rightView];
        self.rightBarView = rightView;
        
        UIView *leftView = [[UIView alloc] init];
        leftView.size = CGSizeMake(0, progressH);
        leftView.backgroundColor = progressColor;
        leftView.centerY = 0.5 * frame.size.height;
        [self addSubview:leftView];
        self.leftBarView = leftView;
        
        UIButton *progressIconButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (dotImage) {
            [progressIconButton setImage:dotImage forState:UIControlStateNormal];
            progressIconButton.size = CGSizeMake(dotHeight, dotHeight);
        } else {
            CGFloat buttonWid = progressH * 5;
            progressIconButton.size = CGSizeMake(buttonWid, buttonWid);
            progressIconButton.layer.cornerRadius = progressIconButton.height / 2;
            progressIconButton.layer.masksToBounds = YES;
            progressIconButton.backgroundColor = progressColor;
        }
        progressIconButton.contentMode = UIViewContentModeScaleAspectFill;
        progressIconButton.center = CGPointMake(0, 0.5 * frame.size.height);
        progressIconButton.hidden = YES;
        [self addSubview:progressIconButton];
        self.progressIconButton = progressIconButton;
        
        self.progressBarHeight = progressH;
        self.cornerRadius = cornerRadius;
        self.inProgressColor = progressColor;
        self.dragColor = dragColor;
        
        if (self.cornerRadius > 0) {
            self.rightBarView.layer.cornerRadius = cornerRadius;
            self.rightBarView.layer.masksToBounds = YES;
            
            self.leftBarView.layer.cornerRadius = cornerRadius;
            self.leftBarView.layer.masksToBounds = YES;
        }
        
        if (enablePan) {
            [self addGestureRecognizer:self.panGes];
        }
        
    }
    return self;
}


- (UIPanGestureRecognizer *)panGes {
    if (!_panGes) {
        UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanProgressIcon:)];
        panGes.delegate = self;
        panGes.maximumNumberOfTouches = 1;
        _panGes = panGes;
    }
    return _panGes;
}

- (void)onPanProgressIcon:(UIPanGestureRecognizer *)recognizer {
    CGFloat positionX = [recognizer locationInView:self].x;
    [self resetAnimation];
    self.leftBarView.left = 0;
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            self.progressIconButton.selected = YES;
        } break;
        case UIGestureRecognizerStateChanged:
            self.progressIconButton.selected = YES;
            break;
        case UIGestureRecognizerStateEnded: {
            self.progressIconButton.selected = NO;
        } break;
        default:
            break;
    }
    if (positionX < 0) {
        // 拖动到最左边
        self.progressIconButton.centerX = 0;
        self.leftBarView.width = self.progressIconButton.centerX;
        self.valueNum = @(0);
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(progressViewCurrentPlayPrecent:dragState:)]) {
            [self.delegate progressViewCurrentPlayPrecent:[self.valueNum floatValue] dragState:ZCommonGestureStateEnd];
        }
        
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
        
        return;
    }
    
    if (positionX > self.width) {
        // 拖动到最右边
        self.progressIconButton.centerX = self.width;
        self.leftBarView.width = self.progressIconButton.centerX;
        self.valueNum = @(1);
        if (self.delegate && [self.delegate respondsToSelector:@selector(progressViewCurrentPlayPrecent:dragState:)]) {
            [self.delegate progressViewCurrentPlayPrecent:[self.valueNum floatValue] dragState:ZCommonGestureStateEnd];
        }
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
        return;
    }
    
    self.progressIconButton.centerX = positionX;
    self.leftBarView.width = self.progressIconButton.centerX;
    [recognizer setTranslation:CGPointZero inView:recognizer.view];
    ZCommonGestureState dragState = ZCommonGestureStateUnKnown;
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            dragState = ZCommonGestureStateBegin;
        } break;
        case UIGestureRecognizerStateChanged:
            dragState = ZCommonGestureStateMove;
            break;
        case UIGestureRecognizerStateEnded: {
            dragState = ZCommonGestureStateEnd;
        } break;
        default:
            break;
    }
    CGFloat value = MIN(MAX(0, self.progressIconButton.centerX / self.width), 1);
    self.valueNum = @(value);
    if (self.delegate && [self.delegate respondsToSelector:@selector(progressViewCurrentPlayPrecent:dragState:)]) {
        [self.delegate progressViewCurrentPlayPrecent:[self.valueNum floatValue] dragState:dragState];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.rightBarView.width = self.width;
    if (self.progressIconButton.centerX > self.width) {
        self.progressIconButton.centerX = self.width;
        self.leftBarView.width = self.progressIconButton.centerX;
    }
    [self updateUIWithValue:self.value];
}

#pragma mark - Public
- (CGFloat)value {
    return self.valueNum.floatValue;
}

- (void)setValue:(CGFloat)value {
    if (![self checkProgressValueValid:value]) {
        return;
    }
    value = MIN(MAX(0, value), 1);
    self.valueNum = @(value);
    [self updateUIWithValue:value];
}

- (void)updateUIWithValue:(CGFloat)value {
    if (![self checkProgressValueValid:value]) {
        return;
    }
    
    _valueNum = @(value);
    CGFloat positionX = self.width * value;
    if (self.lastX && fabs(positionX - self.lastX) < 0.1 / 3) {
        //间距过小，视觉上无法看出任何差异，无需触发UI更新.
        return;
    }
    self.lastX = positionX;
    self.progressIconButton.centerX = positionX;
    self.leftBarView.width = positionX;
}

- (void)setValue:(CGFloat)value animateWithDuration:(NSTimeInterval)duration time:(NSTimeInterval)time {
    [self setValue:value animateWithDuration:duration completion:nil];
}

- (BOOL)shoudAnimateToProgress:(CGFloat)value duration:(NSTimeInterval)duration time:(NSTimeInterval)time {
    if (duration == 1.0) {
        //如果进度是1秒1次动画，那么time增量小于1秒不动画.
        //如果value和lastValue近似相等，则也无需动画.
        CGFloat lastValue = self.value;
        if (fabs(value - lastValue) <= 0.001) {
            //不足千分之一.减少重复动画.
            return NO;
        }
        
        int t = (int)time;
        if (t > 0 && (t == self.lastTime)) {
            return NO;
        }
    }
    self.lastTime = (int)time;
    
    if (!self.superview || self.superview.hidden || self.hidden) {
        //不在屏幕上显示，则也无需动画.
        return NO;
    }
    
    return YES;
}

- (void)setValue:(CGFloat)value animateWithDuration:(NSTimeInterval)duration completion:(void (^__nullable)(BOOL finished))completion {
    [self setValue:value animateWithDuration:duration time:0 completion:completion];
}

- (void)setValue:(CGFloat)value
animateWithDuration:(NSTimeInterval)duration
            time:(NSTimeInterval)time
      completion:(void (^__nullable)(BOOL finished))completion {
    if (![self checkProgressValueValid:value]) {
        return;
    }
    
    BOOL animated = [self shoudAnimateToProgress:value duration:duration time:time];
    
    if (animated) {
        __typeof(self) __weak weakSelf = self;
        [UIView animateWithDuration:duration
                         animations:^{
            [weakSelf updateUIWithValue:value];
        }
                         completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    } else {
        [self updateUIWithValue:value];
    }
}

- (void)removeProgressAnimation {
    [self.progressIconButton.layer removeAllAnimations];
    [self.leftBarView.layer removeAllAnimations];
}

- (BOOL)checkProgressValueValid:(CGFloat)value {
    if (self.progressIconButton.selected) {
        // 正在被拖动时，不动态更新icon位置
        [self removeProgressAnimation];
        return NO;
    }
    
    if (value < 0 || value > 1) {
        [self removeProgressAnimation];
        return NO;
    }
    return YES;
}

- (void)reset {
    [self setValue:0];
    self.showBigProgress = NO;
    self.showDot = NO;
}

- (void)pauseAnimation {
    [self pauseLayer:self.progressIconButton.layer];
    [self pauseLayer:self.leftBarView.layer];
}

- (void)resumeAnimation {
    [self resumeLayer:self.progressIconButton.layer];
    [self resumeLayer:self.leftBarView.layer];
}

- (void)resetAnimation {
    [self resetLayer:self.progressIconButton.layer];
    [self resetLayer:self.leftBarView.layer];
}

#pragma mark 暂停和恢复CALayer的动画
- (void)pauseLayer:(CALayer *)layer {
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    
    // 让CALayer的时间停止走动
    layer.speed = 0.0;
    // 让CALayer的时间停留在pausedTime这个时刻
    layer.timeOffset = pausedTime;
}

- (void)resumeLayer:(CALayer *)layer {
    CFTimeInterval pausedTime = layer.timeOffset;
    // 1. 让CALayer的时间继续行走
    layer.speed = 1.0;
    // 2. 取消上次记录的停留时刻
    layer.timeOffset = 0.0;
    // 3. 取消上次设置的时间
    layer.beginTime = 0.0;
    // 4. 计算暂停的时间(这里也可以用CACurrentMediaTime()-pausedTime)
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    // 5. 设置相对于父坐标系的开始时间(往后退timeSincePause)
    layer.beginTime = timeSincePause;
}

- (void)resetLayer:(CALayer *)layer {
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
}

+ (CGFloat)progressViewVisibleHeight {
    CGFloat margin = 2.0f;
    return margin;
}

#pragma mark - Setter
- (void)setShowBigProgress:(BOOL)showBigProgress {
    if (_showBigProgress == showBigProgress) {
        return;
    }
    _showBigProgress = showBigProgress;
    CGFloat margin = 2.0f;
    if (self.progressBarHeight > 0) {
        margin = self.progressBarHeight;
    }
    margin = self.showBigProgress ? 2 * margin : margin;
    CGFloat centerY = self.rightBarView.centerY;
    self.rightBarView.height = margin;
    self.rightBarView.centerY = centerY;
    self.leftBarView.height = margin;
    self.leftBarView.centerY = centerY;
    self.leftBarView.backgroundColor = self.showBigProgress ? self.dragColor : self.inProgressColor;
    if (self.cornerRadius > 0) {
        self.rightBarView.layer.cornerRadius = margin / 2.0;
        self.rightBarView.layer.masksToBounds = YES;
        
        self.leftBarView.layer.cornerRadius = margin / 2.0;
        self.leftBarView.layer.masksToBounds = YES;
    }
    
}

- (void)setShowDot:(BOOL)showDot {
    if (_showDot == showDot) {
        return;
    }
    _showDot = showDot;
    self.progressIconButton.hidden = !showDot;
}
- (void)setEnablePan:(BOOL)enablePan {
    _enablePan = enablePan;
    self.panGes.enabled = enablePan;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect respRect = CGRectMake(- ZResponseWH / 2, - ZResponseWH / 2, self.width + ZResponseWH, self.height + ZResponseWH);
    if (CGRectContainsPoint(respRect, point)) {
        return self;
    }
    return [super hitTest:point withEvent:event];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
