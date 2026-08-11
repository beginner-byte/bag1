//
//  NoaCenterAlertTransitioningDelegate.h
//  NoaChatKit
//
//  Created by AI on 2025/11/14.
//

#import <UIKit/UIKit.h>

@interface NoaCenterAlertTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate>

@property (nonatomic, assign) NSTimeInterval duration;   // 默认 0.25
@property (nonatomic, strong) UIColor *dimmingColor;     // 默认 黑 0.5

@end

