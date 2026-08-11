//
//  LRUCache.m
//  ZeroChat
//
//  Created by zk on 2024/4/1.
//


#import "LRUCache.h"
#import "LRUCacheNode.h"

static const char *kLRUCacheQueue = "kLRUCacheQueue";

@interface LRUCache ()
@property (nonatomic, strong) NSMutableDictionary * cache;
@property (nonatomic, strong) LRUCacheNode *headNode;
@property (nonatomic, strong) LRUCacheNode *tailNode;
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation LRUCache

- (instancetype)initWithCapacity:(NSUInteger)capacity {
    self = [super init];
    if (self) {
        _capacity = capacity;
        _headNode = [[LRUCacheNode alloc] initWithValue:nil key:nil];
        _tailNode = [[LRUCacheNode alloc] initWithValue:nil key:nil];
        _headNode.next = _tailNode;
        _tailNode.prev = _headNode;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _capacity = [aDecoder decodeIntegerForKey:@"kLRUCacheCapacityCoderKey"];
        _headNode = [aDecoder decodeObjectForKey:@"kLRUCacheheadNodeCoderKey"];
        _tailNode = [aDecoder decodeObjectForKey:@"kLRUCacheTailNodeCoderKey"];
        _cache = [aDecoder decodeObjectForKey:@"kLRUCacheDictionaryCoderKey"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.capacity forKey:@"kLRUCacheCapacityCoderKey"];
    [aCoder encodeObject:self.headNode forKey:@"kLRUCacheheadNodeCoderKey"];
    [aCoder encodeObject:self.headNode forKey:@"kLRUCacheTailNodeCoderKey"];
    [aCoder encodeObject:self.cache forKey:@"kLRUCacheDictionaryCoderKey"];
}

-(NSMutableDictionary *)cache{
    if (_cache == nil) {
        _cache = [[NSMutableDictionary alloc] init];
    }
    return _cache;
}

-(dispatch_queue_t)queue{
    if (_queue == nil) {
        _queue = dispatch_queue_create(kLRUCacheQueue, 0);
    }
    return _queue;
}

#pragma mark - set object / get object methods

- (void)setObject:(id)object forKey:(id<NSCopying>)key {
    if(object == nil || key == nil){
        return;
    }
    dispatch_barrier_async(self.queue, ^{
        LRUCacheNode *node = self.cache[key];
        if (node) {
            node.value = object;
            [self moveNodeToHead:node];
        }else{
            LRUCacheNode *newNode = [[LRUCacheNode alloc] initWithValue:object key:key];
            [self addNode:newNode];
            if (self.cache.count > self.capacity) {
                [self popTail];
            }
        }
    });
}

- (id)objectForKey:(id<NSCopying>)key {
    __block LRUCacheNode *node = nil;
    dispatch_sync(self.queue, ^{
        node = self.cache[key];
        if (node) {
            [self moveNodeToHead:node];
        }
    });
    return node.value;
}

- (void)removeObjectForKey:(id<NSCopying>)key {
    dispatch_barrier_async(self.queue, ^{
        LRUCacheNode *node = self.cache[key];
        if (node) {
            [self removeNode:node];
        }
    });
}

- (void)removeAllObject {
    dispatch_barrier_async(self.queue, ^{
        [self.cache removeAllObjects];
        self.headNode = [[LRUCacheNode alloc] initWithValue:nil key:nil];
        self.tailNode = [[LRUCacheNode alloc] initWithValue:nil key:nil];
        self.headNode.next = self.tailNode;
        self.tailNode.prev = self.headNode;
    });
}

#pragma mark - helper methods
- (void)addNode:(LRUCacheNode *)node {
    if(node){
        node.prev = self.headNode;
        node.next = self.headNode.next;
        self.headNode.next.prev = node;
        self.headNode.next = node;
        [self.cache setObject:node forKey:node.key];
    }
    
}

- (void)removeNode:(LRUCacheNode *)node {
    if(node){
        LRUCacheNode *prev = node.prev;
        LRUCacheNode *next = node.next;
        prev.next = next;
        next.prev = prev;
        [self.cache removeObjectForKey:node.key];
    }
}

- (void)moveNodeToHead:(LRUCacheNode *)node {
    [self removeNode:node];
    [self addNode:node];
}

- (LRUCacheNode *)popTail {
    LRUCacheNode * res = self.tailNode.prev;
    [self removeNode:res];
    return res;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"%@", self.headNode.description];
}

@end
