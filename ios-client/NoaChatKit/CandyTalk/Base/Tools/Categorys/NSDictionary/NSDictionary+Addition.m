//
//  NSDictionary+Addition.m
//  NoaIMChatService
//
//  Created by Candy on 2026/7/8.
//

#import "NSDictionary+Addition.h"

@implementation NSDictionary (Addition)

- (id)objectForKeySafe:(id)aKey{
    if ([[self allKeys] containsObject:aKey]) {
        if ([[self objectForKey:aKey] isKindOfClass:[NSNull class]]) {
            return nil;
        }else{
            return [self objectForKey:aKey];
        }
    }
    return nil;
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err){
        DLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+ (NSDictionary *)dictionaryForJsonData:(NSData *)jsonData {
    if (![jsonData isKindOfClass:[NSData class]] || jsonData.length < 1) {
        return nil;
    }
    id jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    if (![jsonObj isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    return [NSDictionary dictionaryWithDictionary:(NSDictionary *)jsonObj];
}

@end


@implementation NSMutableDictionary (Addition)
- (void)setObjectSafe:(id)anObject forKey:(id<NSCopying>)aKey{
    if (anObject){
        [self setObject:anObject forKey:aKey];
    }
}
- (void)setObjectsFromDictionary:(NSDictionary *)aDictionary{
    if (aDictionary == nil)  return;
    
    NSArray *allkeys = aDictionary.allKeys;
    for (id key in allkeys) {
        id value = [aDictionary objectForKey:key];
        [self setObject:value forKey:key];
    }
}
@end
