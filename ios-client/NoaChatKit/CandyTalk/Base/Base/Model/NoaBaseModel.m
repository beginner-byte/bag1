//
//  NoaBaseModel.m
//  NoaKit
//
//  Created by Candy on 2026/9/15.
//

#import "NoaBaseModel.h"

@implementation NoaBaseModel

MJCodingImplementation

#pragma mark - 非空处理
- (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property{
    //|| [oldValue isKindOfClass:[NSNull class]] || oldValue == nil
    if (oldValue == [NSNull null]) {
        if ([oldValue isKindOfClass:[NSArray class]]) {
            return @[];
        }else if([oldValue isKindOfClass:[NSDictionary class]]){
            return @{};
        }else{
            return @"";
        }
    }
    
    return oldValue;
    
}

@end
