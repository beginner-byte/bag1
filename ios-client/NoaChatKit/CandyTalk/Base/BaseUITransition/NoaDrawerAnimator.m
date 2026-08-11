//
//  NoaDrawerAnimator.m
//  NoaKit
//
//  Created by AI on 2025/11/05.
//

#import "NoaDrawerAnimator.h"

@implementation NoaDrawerAnimator

- (instancetype)initWithType:(ZDrawerTransitionType)type duration:(NSTimeInterval)duration {
    self = [super init];
    if (self) {
        _type = type;
        _duration = duration > 0 ? duration : 0.28;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *container = [transitionContext containerView];
    if (self.type == ZDrawerTransitionTypePresent) {
        UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
        CGRect finalFrame = [transitionContext finalFrameForViewController:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]];
        CGRect startFrame = finalFrame; startFrame.origin.x = -finalFrame.size.width;
        toView.frame = startFrame;
        [container addSubview:toView];
        [UIView animateWithDuration:self.duration delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            toView.frame = finalFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    } else {
        UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        CGRect endFrame = fromView.frame; endFrame.origin.x = -fromView.frame.size.width;
        [UIView animateWithDuration:self.duration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            fromView.frame = endFrame;
        } completion:^(BOOL finished) {
            BOOL cancelled = [transitionContext transitionWasCancelled];
            [transitionContext completeTransition:!cancelled];
        }];
    }
}

@end


