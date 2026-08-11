//
//  NoaMiniAppFloatView.m
//  NoaKit
//
//  Created by Candy on 2023/7/19.
//

#import "NoaMiniAppFloatView.h"

@interface NoaMiniAppFloatView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *viewContentDrag;//内容view
@property (nonatomic, assign) CGPoint startPoint;//开始位置点
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;//拖拽收拾

@end

@implementation NoaMiniAppFloatView

- (instancetype)initWithFrame:(CGRect)frame {
    self= [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.viewContentDrag];
        [self setupUI];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self addSubview:self.viewContentDrag];
        [self setupUI];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.freeRect.origin.x != 0 || self.freeRect.origin.y != 0 || self.freeRect.size.height != 0 || self.freeRect.size.width != 0) {
        //设置了freeRect--活动范围
    }else{
        //没有设置freeRect--活动范围，则设置默认的活动范围为父视图的frame
        self.freeRect = (CGRect){CGPointZero,self.superview.bounds.size};
    }
    
    _imageView.frame = (CGRect){CGPointMake(7, 7), CGSizeMake(36, 36)};
    
    _button.frame = (CGRect){CGPointZero,self.bounds.size};
    self.viewContentDrag.frame =  (CGRect){CGPointZero,self.bounds.size};
    
}
#pragma mark - 界面布局
- (void)setupUI {
    self.dragEnable = YES;//默认可拖拽
    self.clipsToBounds = YES;
    self.isKeepBounds = NO;
    self.backgroundColor = UIColor.clearColor;
    
    //添加点击收拾
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickDragViewTap)];
    [self addGestureRecognizer:singleTap];
    
    //添加拖动手势
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragViewPan:)];
    self.panGestureRecognizer.minimumNumberOfTouches = 1;
    self.panGestureRecognizer.maximumNumberOfTouches = 1;
    self.panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.panGestureRecognizer];
}
#pragma mark - 数据赋值
- (void)setIsKeepBounds:(BOOL)isKeepBounds {
    _isKeepBounds = isKeepBounds;
    if (isKeepBounds) {
        [self keepBounds];
    }
}
- (void)setFreeRect:(CGRect)freeRect {
    _freeRect = freeRect;
    [self keepBounds];
}

#pragma mark - 黏贴边界效果
- (void)keepBounds {
    //中心点判断
    CGFloat centerX = self.freeRect.origin.x + (self.freeRect.size.width - self.frame.size.width) / 2.0;
    CGRect rect = self.frame;
    
    if (self.isKeepBounds == NO) {
        //没有设置黏贴边界效果
        if (self.frame.origin.x < self.freeRect.origin.x) {
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"leftMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x = self.freeRect.origin.x;
            self.frame = rect;
            [UIView commitAnimations];
            
            self.keepBoundsType = ZFloatKeepBoundsTypeLeft;
            
        } else if (self.freeRect.origin.x+self.freeRect.size.width < self.frame.origin.x+self.frame.size.width){
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"rightMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x = self.freeRect.origin.x+self.freeRect.size.width-self.frame.size.width;
            self.frame = rect;
            [UIView commitAnimations];
            
            self.keepBoundsType = ZFloatKeepBoundsTypeRight;
        }
    } else if (self.isKeepBounds == YES) {
        //设置了自动黏贴边界效果
        if (self.frame.origin.x < centerX) {
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"leftMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x = self.freeRect.origin.x;
            self.frame = rect;
            [UIView commitAnimations];
            
            self.keepBoundsType = ZFloatKeepBoundsTypeLeft;
        } else {
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"rightMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x =self.freeRect.origin.x+self.freeRect.size.width - self.frame.size.width;
            self.frame = rect;
            [UIView commitAnimations];
            
            self.keepBoundsType = ZFloatKeepBoundsTypeRight;
        }
    }
    
    if (self.frame.origin.y < self.freeRect.origin.y) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:@"topMove" context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.5];
        rect.origin.y = self.freeRect.origin.y;
        self.frame = rect;
        [UIView commitAnimations];
        
        //self.keepBoundsType = ZFloatKeepBoundsTypeTop;
    } else if(self.freeRect.origin.y + self.freeRect.size.height < self.frame.origin.y + self.frame.size.height){
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:@"bottomMove" context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.5];
        rect.origin.y = self.freeRect.origin.y+self.freeRect.size.height-self.frame.size.height;
        self.frame = rect;
        [UIView commitAnimations];
        
        //self.keepBoundsType = ZFloatKeepBoundsTypeBottom;
    }
    
}
#pragma mark - 交互事件
//点击手势
- (void)clickDragViewTap {
    if (_delegate && [_delegate respondsToSelector:@selector(clickMiniAppFloatView:)]) {
        [_delegate clickMiniAppFloatView:self];
    }
}
//拖拽手势
- (void)dragViewPan:(UIPanGestureRecognizer *)pan {
    if (self.dragEnable == NO) return;
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan://开始拖动
            {
                if (_delegate && [_delegate respondsToSelector:@selector(beganDragMiniAppFloatView:)]) {
                    [_delegate beganDragMiniAppFloatView:self];
                }
                //注意完成拖拽后，将translation重置为0十分重要。否则translation每次都会叠加
                [pan setTranslation:CGPointZero inView:self];
                //保存起始点位置
                self.startPoint = [pan translationInView:self];
            }
            break;
        case UIGestureRecognizerStateChanged://拖动中...
        {
            if (_delegate && [_delegate respondsToSelector:@selector(duringDragMiniAppFloatView:)]) {
                [_delegate duringDragMiniAppFloatView:self];
            }
            
            //计算位移 = 当前位置 - 起始位置
            CGPoint point = [pan translationInView:self];
            float dx;
            float dy;
            switch (self.dragDirection) {
                case ZFloatDragDirectionAny:
                    dx = point.x - self.startPoint.x;
                    dy = point.y - self.startPoint.y;
                    break;
                case ZFloatDragDirectionHorizontal:
                    dx = point.x - self.startPoint.x;
                    dy = 0;
                    break;
                case ZFloatDragDirectionVertical:
                    dx = 0;
                    dy = point.y - self.startPoint.y;
                    break;
                default:
                    dx = point.x - self.startPoint.x;
                    dy = point.y - self.startPoint.y;
                    break;
            }
            
            //计算移动后的view中心点
            CGPoint newCenter = CGPointMake(self.center.x + dx, self.center.y + dy);
            //移动view
            self.center = newCenter;
            //注意完成上述移动后，将translation重置为0十分重要。否则translation每次都会叠加
            [pan setTranslation:CGPointZero inView:self];
        }
            break;
        case UIGestureRecognizerStateEnded://拖动结束
        {
            [self keepBounds];
            if (_delegate && [_delegate respondsToSelector:@selector(endDragMiniAppFloatView:)]) {
                [_delegate endDragMiniAppFloatView:self];
            }
            //确定边界
        }
            break;
            
        default:
            break;
    }
}
#pragma mark - 懒加载
- (UIView *)viewContentDrag{
    if (!_viewContentDrag) {
        _viewContentDrag = [[UIView alloc] init];
        _viewContentDrag.clipsToBounds = YES;
    }
    return _viewContentDrag;
}
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.userInteractionEnabled = YES;
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.viewContentDrag addSubview:_imageView];
    }
    return _imageView;
}
- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.clipsToBounds = YES;
        _button.userInteractionEnabled = NO;
        [self.viewContentDrag addSubview:_button];
    }
    return _button;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

