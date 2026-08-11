//
//  NoaWebCacheManager.h
//  NoaKit
//
//  Created by Candy on 2024/7/1.
//

#define ZWebCachesTOOL                 [NoaWebCacheManager shareManager]

#import <Foundation/Foundation.h>
#import "LRUCache.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaWebCacheManager : NSObject

@property (nonatomic, strong) LRUCache *caches;

#pragma mark - 单例的实现
+ (instancetype)shareManager;
// 单例一般不需要清空，但是在执行某些功能的时候，防止数据清空不及时可以清空一下
- (void)clearManager;



@end

NS_ASSUME_NONNULL_END
