//
//  MImageBrowserGestureHandle.m
//  MiMaoApp
//
//  Created by Candy on 2020/10/13.
//  Copyright © 2020 MiMao. All rights reserved.
//

#import "MImageBrowserGestureHandle.h"
#import "MImageBrowserZoomView.h"

@interface MImageBrowserGestureHandle () <UIGestureRecognizerDelegate>
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIView *coverView;
@property (nonatomic, assign) BOOL isPull;
@property (nonatomic, assign) CGFloat normalScale;
@property (nonatomic, assign) CGPoint transitionImgViewCenter;

@end

@implementation MImageBrowserGestureHandle
- (instancetype)initWithScrollView:(UIScrollView *)scrollView coverView:(UIView *)coverView{
    self = [super init];
    if (self) {
        _scrollView = scrollView;
        _coverView = coverView;
        [self addGesture];
    }
    return self;
}
#pragma mark - 添加手势
- (void)addGesture{
    UIPanGestureRecognizer *interactiveTransitionRecognizer = nil;
    interactiveTransitionRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(interactiveTransitionRecognizerAction:)];
    interactiveTransitionRecognizer.delegate = self;
    [_scrollView addGestureRecognizer:interactiveTransitionRecognizer];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        UIPanGestureRecognizer * recognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        if (![self.delegate respondsToSelector:@selector(currentDetailImageViewInImagePreview:)]) {
            return YES;
        }
        MImageBrowserZoomView *zoomView = [self.delegate currentDetailImageViewInImagePreview:self];
        
        CGPoint velocity = [recognizer velocityInView:recognizer.view];
        CGFloat translation_x = [recognizer translationInView:_coverView.superview].x;
        CGFloat translation_y = [recognizer translationInView:_coverView.superview].y;
        CGPoint contentOffset = zoomView.contentOffset;
        
        if (contentOffset.y > 0) {
            // 图片放大没有滑到顶部时，不响应此手势
            return NO;
        }
        if (velocity.y <= 0) {
            // 向上滑动，不响应此手势
            return NO;
        }
        if(fabs(translation_x) >= fabs(translation_y)) {
            _isPull = NO;
        } else {
            _isPull = YES;
        }
        return YES;
    }
    return YES;
}

#pragma mark - 交互事件
- (void)interactiveTransitionRecognizerAction:(UIPanGestureRecognizer *)gestureRecognizer{
    if (![_delegate respondsToSelector:@selector(currentDetailImageViewInImagePreview:)]) return;
    
    MImageBrowserZoomView *viewZoom = [_delegate currentDetailImageViewInImagePreview:self];
    UIImageView *imageView = viewZoom.imageView;
    
    if (!_isPull) {
        //横向拖动
        return;
    }else{
        _scrollView.scrollEnabled = NO;
        gestureRecognizer.enabled = YES;
    }
    
    CGFloat scrH = [UIScreen mainScreen].bounds.size.height;
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    CGFloat scale = 1 - fabs(translation.y / scrH);
    scale = scale < 0 ? 0 : scale;
    UIView *window = _coverView;
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStatePossible:
            break;
            
        case UIGestureRecognizerStateBegan:
        {
            self.normalScale = viewZoom.zoomScale;
            CGPoint touchPoint = [gestureRecognizer locationInView:imageView];
            touchPoint = CGPointMake(touchPoint.x + viewZoom.contentOffset.x, touchPoint.y + viewZoom.contentOffset.y);
            //改变锚点
            [[self class] setupViewAnchorPoint:imageView anchorPoint:touchPoint];
            self.transitionImgViewCenter = imageView.center;
            if (_delegate && [_delegate respondsToSelector:@selector(imagePreviewComponmentHidden:)]) {
                [_delegate imagePreviewComponmentHidden:YES];
            }
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            if (translation.y < 0) {
                scale = self.normalScale;
                imageView.center = CGPointMake(self.transitionImgViewCenter.x + translation.x, self.transitionImgViewCenter.y + translation.y);
                imageView.transform = CGAffineTransformMakeScale(scale, scale);
                window.alpha = 1;
                return;
            }
            
            imageView.center = CGPointMake(self.transitionImgViewCenter.x + translation.x, self.transitionImgViewCenter.y + translation.y + viewZoom.contentOffset.y);
            window.alpha = scale * scale;
            
            CGFloat imageScale = scale * self.normalScale;
            imageView.transform = CGAffineTransformMakeScale(imageScale, imageScale);
        }
            break;
        
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
            _scrollView.scrollEnabled = YES;
            _isPull = NO;
            //图片顶部距离屏幕底部的距离
            CGPoint velocity = [gestureRecognizer velocityInView:gestureRecognizer.view];
            if ((scale < 0.80 && translation.y > 0) || velocity.y > 800) {
                //比例大于0.80，或者下拉速度大于800，退出界面
                [[self class] setupViewAnchorPoint:imageView anchorPoint:CGPointMake(0.5, 0.5)];
                CGRect frame = imageView.frame;
                frame.origin.x -= viewZoom.contentOffset.x;
                frame.origin.y -= viewZoom.contentOffset.y;
                [viewZoom resetScale];
                imageView.frame = frame;
                if (_delegate && [_delegate respondsToSelector:@selector(detailImageViewDismiss)]) {
                    [_delegate detailImageViewDismiss];
                }
                
            }else{
                [UIView animateWithDuration:0.2 animations:^{
                    imageView.center = self.transitionImgViewCenter;
                    [viewZoom resetScale];
                    imageView.transform = CGAffineTransformMakeScale(1, 1);
                    window.alpha = 1;
                } completion:^(BOOL finished) {
                    [[self class] setupViewAnchorPoint:imageView anchorPoint:CGPointMake(0.5, 0.5)];
                    imageView.transform = CGAffineTransformIdentity;
                    if (self->_delegate && [self->_delegate respondsToSelector:@selector(imagePreviewComponmentHidden:)]) {
                        [self->_delegate imagePreviewComponmentHidden:NO];
                    }
                }];
                
            }
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - 修改锚点
+ (void)setupViewAnchorPoint:(UIView *)view anchorPoint:(CGPoint)anchorPoint {
    CGPoint oldOrigin = view.frame.origin;
    CGFloat anchorPointX = isinf(anchorPoint.x/view.frame.size.width)?:anchorPoint.x/view.frame.size.width;
    CGFloat anchorPointY = isinf(anchorPoint.y/view.frame.size.height)?:anchorPoint.y/view.frame.size.height;
    view.layer.anchorPoint = CGPointMake(anchorPointX, anchorPointY);
    CGPoint newOrigin = view.frame.origin;
    
    CGPoint transition;
    transition.x = newOrigin.x - oldOrigin.x;
    transition.y = newOrigin.y - oldOrigin.y;
    view.center = CGPointMake(view.center.x-transition.x, view.center.y-transition.y);
    
}


@end
