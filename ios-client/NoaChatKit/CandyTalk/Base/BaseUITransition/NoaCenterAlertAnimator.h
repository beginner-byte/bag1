//
//  NoaCenterAlertAnimator.h
//  NoaChatKit
//
//  Created by AI on 2025/11/14.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZCenterAlertTransitionType) {
    ZCenterAlertTransitionTypePresent,
    ZCenterAlertTransitionTypeDismiss
};

@interface NoaCenterAlertAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) ZCenterAlertTransitionType type;
@property (nonatomic, assign) NSTimeInterval duration;

- (instancetype)initWithType:(ZCenterAlertTransitionType)type duration:(NSTimeInterval)duration;

@end

