//
//  NoaDrawerTransitioningDelegate.m
//  NoaKit
//
//  Created by AI on 2025/11/05.
//

#import "NoaDrawerTransitioningDelegate.h"
#import "NoaDrawerPresentationController.h"
#import "NoaDrawerAnimator.h"

@implementation NoaDrawerTransitioningDelegate

- (instancetype)init {
    self = [super init];
    if (self) {
        _contentWidthRatio = 0.8;
        _duration = 0.28;
        _dimmingColor = [UIColor colorWithWhite:0 alpha:0.4];
    }
    return self;
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    NoaDrawerPresentationController *pc = [[NoaDrawerPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    pc.contentWidthRatio = self.contentWidthRatio;
    pc.preferredDuration = self.duration;
    pc.dimmingColor = self.dimmingColor;
    return pc;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[NoaDrawerAnimator alloc] initWithType:ZDrawerTransitionTypePresent duration:self.duration];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[NoaDrawerAnimator alloc] initWithType:ZDrawerTransitionTypeDismiss duration:self.duration];
}

@end


