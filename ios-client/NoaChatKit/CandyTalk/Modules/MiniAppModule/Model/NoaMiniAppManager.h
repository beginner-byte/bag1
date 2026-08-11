//
//  NoaMiniAppManager.h
//  NoaKit
//
//  Created by Candy on 2023/7/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaMiniAppManager : NSObject
//单例
+ (instancetype)sharedManager;

//单例一般不用清空，但在某些情况下可以一键清空一下
- (void)clearManager;

@end

NS_ASSUME_NONNULL_END
