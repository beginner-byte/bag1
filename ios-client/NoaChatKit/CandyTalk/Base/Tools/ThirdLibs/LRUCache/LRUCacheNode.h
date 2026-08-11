//
//  LRUCacheNode.h
//  ZeroChat
//
//  Created by zk on 2024/4/1.
//


#import <Foundation/Foundation.h>

@interface LRUCacheNode : NSObject<NSCoding>

@property (nonatomic, strong) id value;
@property (nonatomic, strong) id<NSCopying> key;
@property (nonatomic, strong) LRUCacheNode *next;
@property (nonatomic, strong) LRUCacheNode *prev;

+ (instancetype)nodeWithValue:(id)value key:(id<NSCopying>)key;
- (instancetype)initWithValue:(id)value key:(id<NSCopying>)key;

@end
