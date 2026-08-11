//
//  NoaTrustedDeviceModel.m
//  CandyTalk
//
//  Created by Codex on 2026/8/9.
//

#import "NoaTrustedDeviceModel.h"

@implementation NoaTrustedDeviceModel

/// 将服务端空值转换为 nil，并将 LocalDateTime 字典转换为 yyyy-MM-dd HH:mm:ss 字符串。
/// @param oldValue 服务端返回的原始字段值
/// @param property 当前正在映射的模型属性
/// @return 可安全赋值给模型属性的标准化值
- (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property {
    if (oldValue == nil || oldValue == [NSNull null]) {
        return nil;
    }

    BOOL isDateTimeProperty = [property.name isEqualToString:@"ipChangedAt"] ||
                              [property.name isEqualToString:@"lastSeenAt"] ||
                              [property.name isEqualToString:@"trustedAt"];
    if (isDateTimeProperty && [oldValue isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dateTime = (NSDictionary *)oldValue;
        return [NSString stringWithFormat:@"%04ld-%02ld-%02ld %02ld:%02ld:%02ld",
                (long)[dateTime[@"year"] integerValue],
                (long)[dateTime[@"monthValue"] integerValue],
                (long)[dateTime[@"dayOfMonth"] integerValue],
                (long)[dateTime[@"hour"] integerValue],
                (long)[dateTime[@"minute"] integerValue],
                (long)[dateTime[@"second"] integerValue]];
    }

    return oldValue;
}

@end
