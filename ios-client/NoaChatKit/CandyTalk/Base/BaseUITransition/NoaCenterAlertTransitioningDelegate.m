//
//  NoaCenterAlertTransitioningDelegate.m
//  NoaChatKit
//
//  Created by AI on 2025/11/14.
//

#import "NoaCenterAlertTransitioningDelegate.h"
#import "NoaCenterAlertPresentationController.h"
#import "NoaCenterAlertAnimator.h"

@implementation NoaCenterAlertTransitioningDelegate

- (instancetype)init {
    self = [super init];
    if (self) {
        _duration = 0.25;
        _dimmingColor = [UIColor colorWithWhite:0 alpha:0.5];
    }
    return self;
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    NoaCenterAlertPresentationController *pc = [[NoaCenterAlertPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    pc.preferredDuration = self.duration;
    pc.dimmingColor = self.dimmingColor;
    return pc;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[NoaCenterAlertAnimator alloc] initWithType:ZCenterAlertTransitionTypePresent duration:self.duration];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[NoaCenterAlertAnimator alloc] initWithType:ZCenterAlertTransitionTypeDismiss duration:self.duration];
}

@end

