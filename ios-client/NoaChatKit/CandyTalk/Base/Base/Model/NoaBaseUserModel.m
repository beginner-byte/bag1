//
//  NoaBaseUserModel.m
//  NoaKit
//
//  Created by Candy on 2024/1/11.
//

#import "NoaBaseUserModel.h"

@implementation NoaBaseUserModel

- (BOOL)isEqual:(NoaBaseUserModel *)object{
    if ([object isKindOfClass:self.class]) {
        return [self.userId isEqual:object.userId];
    }else{
        return [super isEqual:object];
    }
}

@end
