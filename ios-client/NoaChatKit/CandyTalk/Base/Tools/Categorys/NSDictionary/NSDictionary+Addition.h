//
//  NSDictionary+Addition.h
//  NoaIMChatService
//
//  Created by Candy on 2026/7/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (Addition)
- (id)objectForKeySafe:(id)aKey;

//Json转字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
//data转字典
+ (NSDictionary *)dictionaryForJsonData:(NSData *)jsonData;

@end



@interface NSMutableDictionary (Addition)
- (void)setObjectSafe:(id)anObject forKey:(id<NSCopying>)aKey;
- (void)setObjectsFromDictionary:(NSDictionary *)aDictionary;
@end
NS_ASSUME_NONNULL_END
