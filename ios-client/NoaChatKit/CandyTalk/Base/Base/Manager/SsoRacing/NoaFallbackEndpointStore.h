//
//  NoaFallbackEndpointStore.h
//  NoaChatKit
//
//  兜底导航地址存储与管理（国内/海外）
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaFallbackEndpointStore : NSObject

/// 单例
+ (instancetype)shared;

/// 国内兜底 URL 列表
@property (nonatomic, copy) NSArray<NSString *> *domesticUrls;

/// 海外兜底 URL 列表
@property (nonatomic, copy) NSArray<NSString *> *overseasUrls;

/// 从本地缓存读取
- (void)loadFromDefaults;

/// 将当前内存内容写入本地缓存
- (void)saveToDefaults;

/// 若与当前不同则更新并持久化
- (void)updateIfDifferentDomestic:(NSArray<NSString *> *)domestic
                         overseas:(NSArray<NSString *> *)overseas;

@end

NS_ASSUME_NONNULL_END


