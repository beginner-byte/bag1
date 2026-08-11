//
//  NoaMiniAppManager.m
//  NoaKit
//
//  Created by Candy on 2023/7/21.
//

#import "NoaMiniAppManager.h"

//单例
static dispatch_once_t onceToken;

@interface NoaMiniAppManager ()

@end

@implementation NoaMiniAppManager

#pragma mark - 单例
+ (instancetype)sharedManager {
    static NoaMiniAppManager *_manager = nil;
    dispatch_once(&onceToken, ^{
        //不再使用alloc方法，因为已经重写了allocWithZone方法，所以这里要调用父类的方法
        _manager = [[super allocWithZone:NULL] init];
    });
    return _manager;
}
// 防止外部调用alloc 或者 new
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [NoaMiniAppManager sharedManager];
}
// 防止外部调用copy
- (id)copyWithZone:(nullable NSZone *)zone {
    return [NoaMiniAppManager sharedManager];
}
// 防止外部调用mutableCopy
- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [NoaMiniAppManager sharedManager];
}
// 单例一般不需要清空，但是在执行某些功能的时候，防止数据清空不及时可以清空一下
- (void)clearManager{
    onceToken = 0;
}

#pragma mark - 业务

@end
