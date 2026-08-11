//
//  NoaTranslateChannelLanguageModel.m
//  NoaKit
//
//  Created by Candy on 2024/8/7.
//

#import "NoaTranslateChannelLanguageModel.h"

@implementation NoaTranslateLanguageModel

@end

@implementation NoaTranslateChannelLanguageModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    //更换参数名称
    return @{
        @"channelId" : @"id"
    };
}

+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"lang_table":@"NoaTranslateLanguageModel"};
}


@end
