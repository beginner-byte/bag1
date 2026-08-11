//
//  ModuleProtocol.h
//  MUIKIt
//
//  Created by Candy on 2023/11/6.
//

#import <UIKit/UIKit.h>



#define  SharedInstance(Class) \
+ (instancetype)sharedInstance{\
    static Class *_manager = nil;\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        _manager = [[super allocWithZone:NULL] init];\
    });\
    return _manager;\
}\
+ (instancetype)allocWithZone:(struct _NSZone *)zone {\
    return [Class sharedInstance];\
}\
- (id)copyWithZone:(nullable NSZone *)zone {\
    return [Class sharedInstance];\
}\
- (id)mutableCopyWithZone:(nullable NSZone *)zone {\
    return [Class sharedInstance];\
}\

@protocol ModuleProtocol <UIApplicationDelegate>

@required
#pragma mark- --------<必须实现>--------
//由于UIApplicationDelegate 中均为实例方法
//实现模块协议的类均需要 <完整实现单例>
//单例实现
+ (instancetype)sharedInstance;
// 防止外部调用alloc 或者 new
+ (instancetype)allocWithZone:(struct _NSZone *)zone;
// 防止外部调用copy
- (id)copyWithZone:(NSZone *)zone;
// 防止外部调用mutableCopy
- (id)mutableCopyWithZone:(NSZone *)zone;

@optional
#pragma mark- --------<业务扩展接口>--------
//在此扩展业务相关模块化接口 例如:主题切换，环境配置等


@end

