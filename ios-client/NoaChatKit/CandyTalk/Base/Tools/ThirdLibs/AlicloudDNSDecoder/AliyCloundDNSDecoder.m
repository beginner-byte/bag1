#import <Foundation/Foundation.h>

@interface AliyCloundDNSDecoder : NSObject
+ (NSString *)v6ToString:(NSArray<NSString *> *)ipv6List;
@end

@implementation AliyCloundDNSDecoder

+ (NSString *)v6ToString:(NSArray<NSString *> *)ipv6List {
    if (ipv6List.count == 0) {
        return @"";
    }
    NSMutableArray<NSDictionary *> *entries = [NSMutableArray arrayWithCapacity:ipv6List.count];

    for (NSString *ipv6 in ipv6List) {
        if (![ipv6 isKindOfClass:[NSString class]] || ipv6.length == 0) {
            continue;
        }
        // 提取序号（前两个字符，去掉可能的冒号），按16进制解析
        NSString *seqHexPart = (ipv6.length >= 2) ? [ipv6 substringToIndex:2] : ipv6;
        seqHexPart = [seqHexPart stringByReplacingOccurrencesOfString:@":" withString:@""];
        unsigned long long seq = 0;
        NSScanner *scanner = [NSScanner scannerWithString:seqHexPart];
        [scanner scanHexLongLong:&seq];

        // 去掉序号部分并删掉所有冒号，得到纯16进制字符串片段
        NSString *withoutSeq = (ipv6.length >= 2) ? [ipv6 substringFromIndex:2] : @"";
        withoutSeq = [withoutSeq stringByReplacingOccurrencesOfString:@":" withString:@""];

        [entries addObject:@{
            @"seq": @(seq),
            @"hex": withoutSeq ?: @""
        }];
    }

    // 按序号升序排序
    [entries sortUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) {
        NSNumber *sa = a[@"seq"];
        NSNumber *sb = b[@"seq"];
        return [sa compare:sb];
    }];

    // 拼接排序后的16进制字符串
    NSMutableString *hexString = [NSMutableString string];
    for (NSDictionary *d in entries) {
        NSString *h = d[@"hex"];
        if ([h isKindOfClass:[NSString class]] && h.length > 0) {
            [hexString appendString:h];
        }
    }

    // 转 ASCII，遇到 0 终止
    return [self hexToAscii:hexString];
}

+ (NSString *)hexToAscii:(NSString *)hexStr {
    if (hexStr.length == 0) {
        return @"";
    }
    NSMutableString *asciiStr = [NSMutableString string];
    NSUInteger len = hexStr.length;

    for (NSUInteger i = 0; i < len; i += 2) {
        NSString *hex = nil;
        if (i + 1 < len) {
            hex = [hexStr substringWithRange:NSMakeRange(i, 2)];
        } else {
            // 奇数长度：最后一位补0
            unichar c = [hexStr characterAtIndex:i];
            hex = [NSString stringWithFormat:@"%C0", c];
        }

        unsigned int decimal = 0;
        NSScanner *scanner = [NSScanner scannerWithString:hex];
        [scanner scanHexInt:&decimal];

        if (decimal == 0) {
            break;
        }
        [asciiStr appendFormat:@"%C", (unichar)decimal];
    }
    return [asciiStr copy];
}

@end
