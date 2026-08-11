//
//  NSArray+Addition.h
//  NoaIMChatService
//
//  Created by Candy on 2026/7/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (Addition)
- (id)objectAtIndexSafe:(NSUInteger)index;
@end


@interface NSMutableArray (Addition)
- (void)addObjectIfNotNil:(id)anObject;
- (void)insertObjectIfNotNil:(id)anObject atIndex:(NSInteger)index;
- (NSArray *)objectsTop:(NSUInteger)aTopNumber;
    
- (NSArray *)reverse;

- (void)removeObjectAtIndexSafe:(NSUInteger)index;

+ (NSMutableArray *)searchCountryArea:(NSString *)name;

// 会话/多选消息稳定排序：优先 serviceMsgID，其次 sendTime，再 msgID
+ (NSArray *)sortMultiSelectedMessageArr:(NSMutableArray *)array;

@end
NS_ASSUME_NONNULL_END
