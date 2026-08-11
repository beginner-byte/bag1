//
//  NoaSensitiveManager.h
//  NoaKit
//
//  Created by Candy on 2023/7/6.
//

#define ZSensitiveTOOL                 [NoaSensitiveManager shareManager]
#define ZSensitiveFilter(str)          [[NoaSensitiveManager shareManager] sensitiveFilter:str]

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface NoaSensitiveManager : NSObject

#pragma mark - 单例的实现
+ (instancetype)shareManager;
// 单例一般不需要清空，但是在执行某些功能的时候，防止数据清空不及时可以清空一下
- (void)clearManager;

/** 加载本地缓存的敏感词库 */
- (void)setupLocalSensitiveFilter;

/** 将文本中含有的敏感词进行过滤替换 */
- (NSString *)sensitiveFilter:(NSString *)content;





@end

NS_ASSUME_NONNULL_END
