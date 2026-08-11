//
//  SyncMutableArray.h
//  NoaKit
//
//  Created by Candy on 2026/10/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SyncMutableArray : NSObject

//只读（不可变快照）
- (NSArray *)safeArray;
//判断是否包含对象
- (BOOL)containsObject:(id)anObject;
//集合元素数量
- (NSUInteger)count;
//获取元素
- (id)objectAtIndex:(NSUInteger)index;
//获取最后一个元素
- (id)lastObject;
//获取第一个元素
- (id)firstObject;
//枚举元素
- (NSEnumerator *)objectEnumerator;
//插入
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
//插入多个数据
- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes;
//加入
- (void)addObject:(id)anObject;
- (void)addObjectsFromArray:(NSArray *)objects;
//移除
- (void)removeObjectAtIndex:(NSUInteger)index;
//移除
- (void)removeObject:(id)anObject;
//移除
- (void)removeLastObject;
//移除全部
- (void)removeAllObjects;
//替换
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
//获取索引
- (NSUInteger)indexOfObject:(id)anObject;
//枚举
- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;

// 批量写：将多次变更合并在一次 barrier 中执行
- (void)performBatchWrite:(void (^)(NSMutableArray *inner))block;
// 一次性替换为新数组
- (void)replaceAllObjectsWithArray:(NSArray *)array;

/// 过滤用户消息(用户消息删除后过滤)
/// - Parameter keepPredicate: 过滤条件
- (void)filterUsingPredicate:(nonnull NSPredicate*)keepPredicate;

@end

NS_ASSUME_NONNULL_END
