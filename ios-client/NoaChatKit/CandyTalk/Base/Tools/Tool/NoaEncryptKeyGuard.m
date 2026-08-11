//
//  NoaEncryptKeyGuard.m
//  NoaChatKit
//

#import "NoaEncryptKeyGuard.h"

@interface NoaEncryptKeyGuard ()
@property (nonatomic, copy, nullable) NSString *key;
@property (nonatomic, assign) BOOL consumed;
@end

@implementation NoaEncryptKeyGuard

+ (instancetype)guardWithKey:(NSString *)key {
    NoaEncryptKeyGuard *g = [NoaEncryptKeyGuard new];
    g.key = key.length > 0 ? [key copy] : nil;
    g.consumed = NO;
    return g;
}

- (nullable NSString *)consume {
    @synchronized (self) {
        if (self.consumed || self.key.length == 0) {
            return nil;
        }
        self.consumed = YES;
        NSString *k = self.key;
        self.key = nil; // redact immediately
        return k;
    }
}

@end


