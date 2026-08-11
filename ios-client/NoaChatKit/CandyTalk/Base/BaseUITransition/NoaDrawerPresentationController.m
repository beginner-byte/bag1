//
//  NoaDrawerPresentationController.m
//  NoaKit
//
//  Created by AI on 2025/11/05.
//

#import "NoaDrawerPresentationController.h"

@interface NoaDrawerPresentationController ()
@property (nonatomic, strong) UIView *dimmingView;
@end

@implementation NoaDrawerPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        _contentWidthRatio = 0.8;
        _preferredDuration = 0.28;
        _dimmingColor = [UIColor colorWithWhite:0 alpha:0.4];
        _dimmingView = [[UIView alloc] initWithFrame:CGRectZero];
        _dimmingView.backgroundColor = _dimmingColor;
        _dimmingView.alpha = 0.0;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapDimming:)];
        [_dimmingView addGestureRecognizer:tap];
    }
    return self;
}

#pragma mark - Public
- (void)updateContentWidthRatio:(CGFloat)ratio animated:(BOOL)animated {
    CGFloat clamped = ratio;
    if (clamped < 0.0) clamped = 0.0;
    if (clamped > 1.0) clamped = 1.0;
    self.contentWidthRatio = clamped;
    if (!self.containerView) { return; }
    void (^layoutBlock)(void) = ^{
        CGSize size = self.containerView.bounds.size;
        CGFloat width = floor(size.width * clamped);
        CGRect presentedFrame = CGRectMake(0, 0, width, size.height);
        self.presentedView.frame = presentedFrame;
        CGFloat dimmWidth = size.width - width;
        self.dimmingView.frame = CGRectMake(width, 0, dimmWidth, size.height);
        self.dimmingView.alpha = dimmWidth > 0 ? 1.0 : 0.0;
    };
    if (animated) {
        [UIView animateWithDuration:self.preferredDuration animations:layoutBlock];
    } else {
        layoutBlock();
    }
}

- (void)updateContentWidthRatio:(CGFloat)ratio animated:(BOOL)animated completion:(void (^ __nullable)(void))completion {
    CGFloat clamped = ratio;
    if (clamped < 0.0) clamped = 0.0;
    if (clamped > 1.0) clamped = 1.0;
    self.contentWidthRatio = clamped;
    if (!self.containerView) { if (completion) completion(); return; }
    void (^layoutBlock)(void) = ^{
        CGSize size = self.containerView.bounds.size;
        CGFloat width = floor(size.width * clamped);
        CGRect presentedFrame = CGRectMake(0, 0, width, size.height);
        self.presentedView.frame = presentedFrame;
        CGFloat dimmWidth = size.width - width;
        self.dimmingView.frame = CGRectMake(width, 0, dimmWidth, size.height);
        self.dimmingView.alpha = dimmWidth > 0 ? 1.0 : 0.0;
    };
    if (animated) {
        [UIView animateWithDuration:self.preferredDuration animations:layoutBlock completion:^(BOOL finished) {
            if (completion) completion();
        }];
    } else {
        layoutBlock();
        if (completion) completion();
    }
}

- (CGRect)frameOfPresentedViewInContainerView {
    if (!self.containerView) { return CGRectZero; }
    CGSize size = self.containerView.bounds.size;
    CGFloat width = floor(size.width * (self.contentWidthRatio > 0 && self.contentWidthRatio < 1 ? self.contentWidthRatio : 0.8));
    // 左侧抽屉，占据左侧 80%
    return CGRectMake(0, 0, width, size.height);
}

- (void)presentationTransitionWillBegin {
    if (!self.containerView) { return; }
    // 遮罩只覆盖剩余 20% 宽度区域（左侧）
    CGSize size = self.containerView.bounds.size;
    CGFloat dimmWidth = size.width - self.frameOfPresentedViewInContainerView.size.width;
    // 遮罩放在右侧 20%
    self.dimmingView.frame = CGRectMake(self.frameOfPresentedViewInContainerView.size.width, 0, dimmWidth, size.height);
    self.dimmingView.backgroundColor = self.dimmingColor ?: [UIColor colorWithWhite:0 alpha:0.4];
    [self.containerView addSubview:self.dimmingView];
    [self.containerView addSubview:self.presentedViewController.view];
    id<UIViewControllerTransitionCoordinator> coordinator = self.presentedViewController.transitionCoordinator;
    self.dimmingView.alpha = 0.0;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.dimmingView.alpha = 1.0;
    } completion:nil];
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    if (!completed) {
        [self.dimmingView removeFromSuperview];
    }
}

- (void)dismissalTransitionWillBegin {
    id<UIViewControllerTransitionCoordinator> coordinator = self.presentedViewController.transitionCoordinator;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.dimmingView.alpha = 0.0;
    } completion:nil];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    if (completed) {
        [self.dimmingView removeFromSuperview];
    }
}

- (void)containerViewWillLayoutSubviews {
    [super containerViewWillLayoutSubviews];
    if (!self.containerView) { return; }
    CGSize size = self.containerView.bounds.size;
    CGRect presentedFrame = [self frameOfPresentedViewInContainerView];
    self.presentedView.frame = presentedFrame;
    CGFloat dimmWidth = size.width - presentedFrame.size.width;
    self.dimmingView.frame = CGRectMake(presentedFrame.size.width, 0, dimmWidth, size.height);
}

#pragma mark - Actions
- (void)handleTapDimming:(UITapGestureRecognizer *)tap {
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

@end


