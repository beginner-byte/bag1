//
//  NoaDrawerAnimator.h
//  NoaKit
//
//  Created by AI on 2025/11/05.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZDrawerTransitionType) {
    ZDrawerTransitionTypePresent,
    ZDrawerTransitionTypeDismiss
};

@interface NoaDrawerAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) ZDrawerTransitionType type;
@property (nonatomic, assign) NSTimeInterval duration;

- (instancetype)initWithType:(ZDrawerTransitionType)type duration:(NSTimeInterval)duration;

@end


