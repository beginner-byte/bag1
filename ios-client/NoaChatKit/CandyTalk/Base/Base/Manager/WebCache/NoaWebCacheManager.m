//
//  NoaWebCacheManager.m
//  NoaKit
//
//  Created by Candy on 2024/7/1.
//

#import "NoaWebCacheManager.h"
#import "LRUCache.h"

static dispatch_once_t onceToken;

@implementation NoaWebCacheManager

#pragma mark - 单例的实现
+ (instancetype)shareManager{
    static NoaWebCacheManager *_manager = nil;
    dispatch_once(&onceToken, ^{
        //不能再使用alloc方法
        //因为已经重写了allocWithZone方法，所以这里要调用父类的分配空间的方法
        _manager = [[super allocWithZone:NULL] init];
        //初始化单例时加载本地敏感词库
        [_manager setupLocalCaches];
    });
    return _manager;
}

// 防止外部调用alloc 或者 new
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [NoaWebCacheManager shareManager];
}

// 防止外部调用copy
- (id)copyWithZone:(nullable NSZone *)zone {
    return [NoaWebCacheManager shareManager];
}

// 防止外部调用mutableCopy
- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [NoaWebCacheManager shareManager];
}
#pragma mark - 单例一般不需要清空，但是在执行某些功能的时候，防止数据清空不及时可以清空一下
- (void)clearManager{
    onceToken = 0;
}

- (void)setupLocalCaches {
    _caches = [[LRUCache alloc] initWithCapacity:20];
}

@end
