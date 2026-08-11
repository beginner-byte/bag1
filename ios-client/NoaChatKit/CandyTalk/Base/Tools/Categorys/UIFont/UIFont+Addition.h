//
//  UIFont+Addition.h
//  NoaKit
//
//  Created by Candy on 2026/8/30.
//

#import <UIKit/UIKit.h>

#define FONTR(a) [UIFont fontWithName:@"PingFangSC-Regular" size:([NoaDeviceTool isSmallScreen] ? a - 1 : a)]

#define FONTSB(a) [UIFont fontWithName:@"PingFangSC-Semibold" size:([NoaDeviceTool isSmallScreen] ? a - 1 : a)]

#define FONTM(a) [UIFont fontWithName:@"PingFangSC-Medium" size:([NoaDeviceTool isSmallScreen] ? a - 1 : a)]

#define FONTB(a) [UIFont boldSystemFontOfSize:([NoaDeviceTool isSmallScreen] ? a - 1 : a)]

#define FONTN(a) [UIFont systemFontOfSize:([NoaDeviceTool isSmallScreen] ? a - 1 : a)]


NS_ASSUME_NONNULL_BEGIN

@interface UIFont (Addition)

@end

NS_ASSUME_NONNULL_END
