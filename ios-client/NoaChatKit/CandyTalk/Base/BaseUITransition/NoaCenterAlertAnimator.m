//
//  NoaCenterAlertAnimator.m
//  NoaChatKit
//
//  Created by AI on 2025/11/14.
//

#import "NoaCenterAlertAnimator.h"

@implementation NoaCenterAlertAnimator

- (instancetype)initWithType:(ZCenterAlertTransitionType)type duration:(NSTimeInterval)duration {
    self = [super init];
    if (self) {
        _type = type;
        _duration = duration > 0 ? duration : 0.25;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *container = [transitionContext containerView];
    
    if (self.type == ZCenterAlertTransitionTypePresent) {
        // 弹出动画：从中心缩放 + 淡入
        UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
        UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        CGRect finalFrame = [transitionContext finalFrameForViewController:toVC];
        
        toView.frame = finalFrame;
        toView.alpha = 0.0;
        toView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        [container addSubview:toView];
        
        [UIView animateWithDuration:self.duration
                              delay:0
             usingSpringWithDamping:0.8
              initialSpringVelocity:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            toView.alpha = 1.0;
            toView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    } else {
        // 消失动画：缩小 + 淡出
        UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        
        [UIView animateWithDuration:self.duration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
            fromView.alpha = 0.0;
            fromView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        } completion:^(BOOL finished) {
            BOOL cancelled = [transitionContext transitionWasCancelled];
            [transitionContext completeTransition:!cancelled];
        }];
    }
}

@end

