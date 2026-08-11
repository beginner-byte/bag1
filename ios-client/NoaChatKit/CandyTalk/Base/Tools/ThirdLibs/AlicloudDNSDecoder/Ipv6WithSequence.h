//
//  Ipv6WithSequence.h
//  NoaKit
//
//  Created by Candy on 2024/9/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Ipv6WithSequence : NSObject

@property (nonatomic, assign) int sequence;
@property (nonatomic, strong) NSString *ipv6WithoutSeq;

- (instancetype)initWithSequence:(int)sequence ipv6WithoutSeq:(NSString *)ipv6WithoutSeq;

@end

NS_ASSUME_NONNULL_END
