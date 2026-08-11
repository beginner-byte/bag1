//
//  SyncMutableArray.m
//  NoaKit
//
//  Created by Candy on 2026/10/25.
//

#import "SyncMutableArray.h"

@interface SyncMutableArray ()

@property (nonatomic, strong) dispatch_queue_t syncQueue;
@property (nonatomic, strong) NSMutableArray* array;

@end


@implementation SyncMutableArray

#pragma mark - init 方法
- (instancetype)initCommon
{
    self = [super init];
    if (self) {
        //%p 以16进制的形式输出内存地址，附加前缀0x
        NSString* uuid = [NSString stringWithFormat:@"com.huofar.array_%p", self];
        //注意：_syncQueue是并行队列
        _syncQueue = dispatch_queue_create([uuid UTF8String], DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (instancetype)init
{
    self = [self initCommon];
    if (self) {
        _array = [NSMutableArray array];
    }
    return self;
}

//其他init方法略

#pragma mark - 数据操作方法 (凡涉及更改数组中元素的操作，使用异步派发+栅栏块；读取数据使用 同步派发+并行队列)

- (NSArray *)safeArray
{
    __block NSArray *safeArray;
    WeakSelf
    dispatch_sync(_syncQueue, ^{
        safeArray = [weakSelf.array copy];
    });
    return safeArray;
}

- (BOOL)containsObject:(id)anObject
{
    __block BOOL isExist = NO;
    WeakSelf
    dispatch_sync(_syncQueue, ^{
        isExist = [weakSelf.array containsObject:anObject];
    });
    return isExist;
}

- (NSUInteger)count
{
    __block NSUInteger count;
    WeakSelf
    dispatch_sync(_syncQueue, ^{
        count = weakSelf.array.count;
    });
    return count;
}

- (id)objectAtIndex:(NSUInteger)index
{
    __block id obj;
    WeakSelf
    dispatch_sync(_syncQueue, ^{
        if (index < [weakSelf.array count]) {
            obj = weakSelf.array[index];
        }
    });
    return obj;
}

- (id)lastObject
{
    __block id obj;
    WeakSelf
    dispatch_sync(_syncQueue, ^{
        if ([weakSelf.array count] > 0) {
            obj = [weakSelf.array lastObject];
        }
    });
    return obj;
}

//获取第一个元素
- (id)firstObject {
    __block id obj;
    WeakSelf
    dispatch_sync(_syncQueue, ^{
        if ([weakSelf.array count] > 0) {
            obj = [weakSelf.array firstObject];
        }
    });
    return obj;
}

- (NSEnumerator *)objectEnumerator
{
    __block NSArray *snapshot;
    WeakSelf
    dispatch_sync(_syncQueue, ^{
        snapshot = [weakSelf.array copy];
    });
    return [snapshot objectEnumerator];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    WeakSelf
    dispatch_barrier_async(_syncQueue, ^{
        if (anObject && index <= [weakSelf.array count]) {
            [weakSelf.array insertObject:anObject atIndex:index];
        }
    });
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes {
    WeakSelf
    dispatch_barrier_async(_syncQueue, ^{
        if (objects && indexes) {
            [weakSelf.array insertObjects:objects atIndexes:indexes];
        }
        
    });
}
- (void)addObject:(id)anObject
{
    WeakSelf
    dispatch_barrier_async(_syncQueue, ^{
        if(anObject){
            [weakSelf.array addObject:anObject];
        }
    });
}
- (void)addObjectsFromArray:(NSArray *)objects {
    WeakSelf
    dispatch_barrier_async(_syncQueue, ^{
        if(objects != nil && objects.count > 0){
            [weakSelf.array addObjectsFromArray:objects];
        }
    });
}
- (void)removeObjectAtIndex:(NSUInteger)index
{
    WeakSelf
    dispatch_barrier_async(_syncQueue, ^{
        if (index < [weakSelf.array count]) {
            [weakSelf.array removeObjectAtIndex:index];
        }
    });
}

- (void)removeObject:(id)anObject
{
    WeakSelf
    dispatch_barrier_async(_syncQueue, ^{
        [weakSelf.array removeObject:anObject];//外边自己判断合法性
    });
}

- (void)filterUsingPredicate:(nonnull NSPredicate*)keepPredicate {
    WeakSelf
    dispatch_barrier_async(_syncQueue, ^{
        [weakSelf.array filterUsingPredicate:keepPredicate];//外边自己判断合法性
    });
}

- (void)removeLastObject
{
    WeakSelf
    dispatch_barrier_async(_syncQueue, ^{
        [weakSelf.array removeLastObject];
    });
}

//移除全部
- (void)removeAllObjects {
    WeakSelf
    dispatch_barrier_async(_syncQueue, ^{
        [weakSelf.array removeAllObjects];
    });
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    WeakSelf
    dispatch_barrier_async(_syncQueue, ^{
        if (anObject && index < [weakSelf.array count]) {
            [weakSelf.array replaceObjectAtIndex:index withObject:anObject];
        }
    });
}

- (NSUInteger)indexOfObject:(id)anObject
{
    __block NSUInteger index = NSNotFound;
    WeakSelf
    dispatch_sync(_syncQueue, ^{
        index = [weakSelf.array indexOfObject:anObject];
    });
    return index;
}
//枚举
- (void)enumerateObjectsUsingBlock:(void (^)(id _Nonnull, NSUInteger, BOOL * _Nonnull))block {
    __block NSArray *snapshot;
    WeakSelf
    dispatch_sync(_syncQueue, ^{
        snapshot = [weakSelf.array copy];
    });
    [snapshot enumerateObjectsUsingBlock:block];
}

#pragma mark - 批量接口
- (void)performBatchWrite:(void (^)(NSMutableArray *inner))block {
    if (!block) return;
    WeakSelf
    dispatch_barrier_async(_syncQueue, ^{
        block(weakSelf.array);
    });
}

- (void)replaceAllObjectsWithArray:(NSArray *)array {
    WeakSelf
    dispatch_barrier_async(_syncQueue, ^{
        [weakSelf.array removeAllObjects];
        if (array.count > 0) {
            [weakSelf.array addObjectsFromArray:array];
        }
    });
}


- (void)dealloc
{
    if (_syncQueue) {
        _syncQueue = NULL;
    }
}

@end
