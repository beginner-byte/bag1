//
//  LRUCache.h
//  ZeroChat
//
//  Created by zk on 2024/4/1.
//


#import <Foundation/Foundation.h>

@interface LRUCache : NSObject <NSCoding>

@property (nonatomic, readonly, assign) NSUInteger capacity;

- (instancetype)initWithCapacity:(NSUInteger)capacity;

- (void)setObject:(id)object forKey:(id<NSCopying>)key;

- (id)objectForKey:(id<NSCopying>)key;

- (void)removeObjectForKey:(id<NSCopying>)key;

- (void)removeAllObject;

@end
