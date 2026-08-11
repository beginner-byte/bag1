//
//  NoaCenterAlertPresentationController.m
//  NoaChatKit
//
//  Created by AI on 2025/11/14.
//

#import "NoaCenterAlertPresentationController.h"

@interface NoaCenterAlertPresentationController ()
@property (nonatomic, strong) UIView *dimmingView;
@end

@implementation NoaCenterAlertPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        _preferredDuration = 0.25;
        _dimmingColor = [UIColor colorWithWhite:0 alpha:0.5];
        _dimmingView = [[UIView alloc] initWithFrame:CGRectZero];
        _dimmingView.backgroundColor = _dimmingColor;
        _dimmingView.alpha = 0.0;
    }
    return self;
}

- (void)presentationTransitionWillBegin {
    [super presentationTransitionWillBegin];
    
    if (self.containerView) {
        self.dimmingView.frame = self.containerView.bounds;
        [self.containerView insertSubview:self.dimmingView atIndex:0];
        
        id<UIViewControllerTransitionCoordinator> coordinator = [self.presentedViewController transitionCoordinator];
        if (coordinator) {
            [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                self.dimmingView.alpha = 1.0;
            } completion:nil];
        } else {
            self.dimmingView.alpha = 1.0;
        }
    }
}

- (void)dismissalTransitionWillBegin {
    [super dismissalTransitionWillBegin];
    
    id<UIViewControllerTransitionCoordinator> coordinator = [self.presentedViewController transitionCoordinator];
    if (coordinator) {
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            self.dimmingView.alpha = 0.0;
        } completion:nil];
    } else {
        self.dimmingView.alpha = 0.0;
    }
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    [super dismissalTransitionDidEnd:completed];
    if (completed) {
        [self.dimmingView removeFromSuperview];
    }
}

- (CGRect)frameOfPresentedViewInContainerView {
    if (!self.containerView) {
        return CGRectZero;
    }
    
    CGSize containerSize = self.containerView.bounds.size;
    CGSize presentedSize = self.presentedViewController.preferredContentSize;
    
    // 如果 preferredContentSize 没有设置，使用默认大小
    if (CGSizeEqualToSize(presentedSize, CGSizeZero)) {
        presentedSize = CGSizeMake(335, 264); // 默认大小，可以根据需要调整
    }
    
    // 计算居中位置
    CGFloat x = (containerSize.width - presentedSize.width) / 2.0;
    CGFloat y = (containerSize.height - presentedSize.height) / 2.0;
    
    return CGRectMake(x, y, presentedSize.width, presentedSize.height);
}

@end

