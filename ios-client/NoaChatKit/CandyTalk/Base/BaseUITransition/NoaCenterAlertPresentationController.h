//
//  NoaCenterAlertPresentationController.h
//  NoaChatKit
//
//  Created by AI on 2025/11/14.
//

#import <UIKit/UIKit.h>

@interface NoaCenterAlertPresentationController : UIPresentationController

@property (nonatomic, assign) NSTimeInterval preferredDuration;
@property (nonatomic, strong) UIColor *dimmingColor;

@end

