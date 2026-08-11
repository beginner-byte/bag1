//
//  NoaDrawerTransitioningDelegate.h
//  NoaKit
//
//  Created by AI on 2025/11/05.
//

#import <UIKit/UIKit.h>

@interface NoaDrawerTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate>

@property (nonatomic, assign) CGFloat contentWidthRatio; // 默认 0.8
@property (nonatomic, assign) NSTimeInterval duration;   // 默认 0.28
@property (nonatomic, strong) UIColor *dimmingColor;     // 默认 黑 0.4

@end


