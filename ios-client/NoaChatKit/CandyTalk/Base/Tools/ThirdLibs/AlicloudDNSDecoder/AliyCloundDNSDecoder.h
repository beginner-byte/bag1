//
//  AliyCloundDNSDecoder.h
//  NoaKit
//
//  Created by Candy on 2024/9/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AliyCloundDNSDecoder : NSObject

+ (NSString *)v6ToString:(NSArray<NSString *> *)ipv6List;

@end

NS_ASSUME_NONNULL_END
