//
//  NoaMassMessageErrorUserModel.m
//  NoaKit
//
//  Created by Candy on 2023/4/21.
//

#import "NoaMassMessageErrorUserModel.h"

@implementation NoaMassMessageErrorUserModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    //更换参数名称
    return @{
        @"ID" : @"id"
    };
}

@end
