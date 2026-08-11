//
//  NSArray+Addition.m
//  NoaIMChatService
//
//  Created by Candy on 2026/7/8.
//

#import "NSArray+Addition.h"
#import "FMDB.h"
#import "NoaMessageModel.h"

@implementation NSArray (Addition)
- (id)objectAtIndexSafe:(NSUInteger)index{
    if (index < self.count){
        return self[index];
    }
    
    return nil;
}
@end


@implementation NSMutableArray (Addition)
    
-(void)addObjectIfNotNil:(id)anObject
    {
        if (anObject)
        {
            [self addObject:anObject];
        }
    }
    
-(NSArray *)objectsTop:(NSUInteger)aTopNumber {
    NSUInteger number = MIN(aTopNumber, self.count);
    
    if (number > 0) {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:number];
        for (int i = 0; i < number; i++) {
            [arr addObject:self[i]];
        }
        return arr;
    }
    
    return nil;
}
    
- (NSArray *)reverse {
    if ([self count] == 0)
    return self;
    
    NSUInteger i = 0;
    NSUInteger j = [self count] - 1;
    while (i < j) {
        [self exchangeObjectAtIndex:i
                  withObjectAtIndex:j];
        
        i++;
        j--;
    }
    
    return self;
}
    
-(void)insertObjectIfNotNil:(id)anObject atIndex:(NSInteger)index{
    if (anObject) {
        [self insertObject:anObject atIndex:index];
    }
}

- (void)removeObjectAtIndexSafe:(NSUInteger)index{
    if (index < self.count) {
        [self removeObjectAtIndex:index];
    }
}

+ (NSMutableArray *)searchCountryArea:(NSString *)name {
    NSMutableArray *resultArr = [NSMutableArray array];
    NSString *sql= [NSString stringWithFormat:@"select * from SMS_country where (zh like '%%%@%%' or en like '%%%@%%' or es like '%%%@%%' or prefix like '%%%@%%' or emojiLogo like '%%%@%%') order by countryPinyin asc",name,name,name,name,name];
    NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"noa_constant" ofType:@"db"];
    FMDatabase *db = [[FMDatabase alloc] initWithPath:dbPath];
    if ([db open]) {
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObjectSafe:[rs objectForColumn:@"id"] forKey:@"id"];
            [dict setObjectSafe:[rs objectForColumn:@"zh"] forKey:@"zh-Hans"];
            [dict setObjectSafe:[rs objectForColumn:@"big5"] forKey:@"zh-Hant"];
            [dict setObjectSafe:[rs objectForColumn:@"en"] forKey:@"en"];
            [dict setObjectSafe:[rs objectForColumn:@"es"] forKey:@"es"];
            [dict setObjectSafe:[rs objectForColumn:@"ar"] forKey:@"ar"];
            [dict setObjectSafe:[rs objectForColumn:@"bn"] forKey:@"bn"];
            [dict setObjectSafe:[rs objectForColumn:@"fa"] forKey:@"fa"];
            [dict setObjectSafe:[rs objectForColumn:@"fr"] forKey:@"fr"];
            [dict setObjectSafe:[rs objectForColumn:@"hi"] forKey:@"hi"];
            [dict setObjectSafe:[rs objectForColumn:@"ky"] forKey:@"ky"];
            [dict setObjectSafe:[rs objectForColumn:@"ru"] forKey:@"ru"];
            [dict setObjectSafe:[rs objectForColumn:@"tr"] forKey:@"tr"];
            [dict setObjectSafe:[rs objectForColumn:@"uz"] forKey:@"uz"];
            [dict setObjectSafe:[rs objectForColumn:@"pt_BR"] forKey:@"pt-BR"];
            [dict setObjectSafe:[rs objectForColumn:@"in_id"] forKey:@"in_id"];
            [dict setObjectSafe:[rs objectForColumn:@"vi"] forKey:@"vi"];
            [dict setObjectSafe:[rs objectForColumn:@"ko"] forKey:@"ko"];
            [dict setObjectSafe:[rs objectForColumn:@"prefix"] forKey:@"prefix"];
            [dict setObjectSafe:[rs objectForColumn:@"price"] forKey:@"price"];
            [dict setObjectSafe:[rs objectForColumn:@"emojiLogo"] forKey:@"emojiLogo"];
            [resultArr addObject:dict];
        }
        [db close];
    }
    
    return resultArr;
}

//多选/会话列表：稳定排序。优先 serviceMsgID（服务端序），其次 sendTime，再 msgID
+ (NSArray *)sortMultiSelectedMessageArr:(NSMutableArray *)array {
    if (array.count <= 1) {
        return [array copy] ?: @[];
    }
    return [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *sidA = [obj1 valueForKeyPath:@"message.serviceMsgID"] ?: @"";
        NSString *sidB = [obj2 valueForKeyPath:@"message.serviceMsgID"] ?: @"";
        BOOL hasSidA = sidA.length > 0;
        BOOL hasSidB = sidB.length > 0;
        // 双方都有服务端 ID 时，以服务端序为准，避免 sendTime 回写导致跳动
        if (hasSidA && hasSidB) {
            NSComparisonResult sidResult = [sidA compare:sidB options:NSLiteralSearch];
            if (sidResult != NSOrderedSame) {
                return sidResult;
            }
        }
        long long t1 = [[obj1 valueForKeyPath:@"message.sendTime"] longLongValue];
        long long t2 = [[obj2 valueForKeyPath:@"message.sendTime"] longLongValue];
        if (t1 < t2) {
            return NSOrderedAscending;
        }
        if (t1 > t2) {
            return NSOrderedDescending;
        }
        // 仅一方有 serviceMsgID：有 ID 的视为已确认，排在发送中消息前（同时间时）
        if (hasSidA != hasSidB) {
            return hasSidA ? NSOrderedAscending : NSOrderedDescending;
        }
        NSString *midA = [obj1 valueForKeyPath:@"message.msgID"] ?: @"";
        NSString *midB = [obj2 valueForKeyPath:@"message.msgID"] ?: @"";
        return [midA compare:midB options:NSLiteralSearch];
    }];
}
@end
