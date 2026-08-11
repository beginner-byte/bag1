//
//  NoaEncryptKeyGuard.h
//  NoaChatKit
//
//  Ensures an encrypt key can be consumed only once.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaEncryptKeyGuard : NSObject

// Create a guard with a non-empty key
+ (instancetype)guardWithKey:(NSString *)key;

// Returns the key at first call and marks it consumed; returns nil afterwards
- (nullable NSString *)consume;

@end

NS_ASSUME_NONNULL_END


