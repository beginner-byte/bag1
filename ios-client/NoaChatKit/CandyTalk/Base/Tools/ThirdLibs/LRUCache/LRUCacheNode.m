//
//  LRUCacheNode.m
//  ZeroChat
//
//  Created by zk on 2024/4/1.
//


#import "LRUCacheNode.h"

@interface LRUCacheNode ()


@end

@implementation LRUCacheNode

- (instancetype)initWithValue:(id)value key:(id<NSCopying>)key {
    self = [super init];
    if (self) {
        _value = value;
        _key = key;
    }
    return self;
}

+ (instancetype)nodeWithValue:(id)value key:(id<NSCopying>)key {
    return [[LRUCacheNode alloc] initWithValue:value key:key];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _value = [aDecoder decodeObjectForKey:@"kLRUCacheNodeValueKey"];
        _key = [aDecoder decodeObjectForKey:@"kLRUCacheNodeKey"];
        _next = [aDecoder decodeObjectForKey:@"kLRUCacheNodeNext"];
        _prev = [aDecoder decodeObjectForKey:@"kLRUCacheNodePrev"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.value forKey:@"kLRUCacheNodeValueKey"];
    [aCoder encodeObject:self.key forKey:@"kLRUCacheNodeKey"];
    [aCoder encodeObject:self.next forKey:@"kLRUCacheNodeNext"];
    [aCoder encodeObject:self.prev forKey:@"kLRUCacheNodePrev"];
}

- (NSString *)description {
    if(self.next){
        return [NSString stringWithFormat:@"key - %@ vaulu - %@ next:\n %@", self.key, self.value, [self.next description]];
    }else{
        return [NSString stringWithFormat:@"key - %@ vaulu - %@", self.key, self.value];
    }
}


@end
