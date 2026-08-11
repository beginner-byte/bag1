//
//  Ipv6WithSequence.m
//  NoaKit
//
//  Created by Candy on 2024/9/20.
//

#import "Ipv6WithSequence.h"

@implementation Ipv6WithSequence

- (instancetype)initWithSequence:(int)sequence ipv6WithoutSeq:(NSString *)ipv6WithoutSeq {
    self = [super init];
    if (self) {
        _sequence = sequence;
        _ipv6WithoutSeq = ipv6WithoutSeq;
    }
    return self;
}


@end
