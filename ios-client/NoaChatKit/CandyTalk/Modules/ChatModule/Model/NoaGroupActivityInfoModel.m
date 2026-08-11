//
//  NoaGroupActivityInfoModel.m
//  NoaKit
//
//  Created by Candy on 2025/2/24.
//

#import "NoaGroupActivityInfoModel.h"

@implementation NoaGroupActivityActionModel

@end

@implementation NoaGroupActivityLevelModel

@end

@implementation NoaGroupActivityInfoModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"actions":@"NoaGroupActivityActionModel",
        @"levels":@"NoaGroupActivityLevelModel"
    };
}

@end
