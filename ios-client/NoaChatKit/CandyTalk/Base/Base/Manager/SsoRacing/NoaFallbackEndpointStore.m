//
//  NoaFallbackEndpointStore.m
//  NoaChatKit
//

#import "NoaFallbackEndpointStore.h"

static NSString *const kFallbackDomesticUrlsKey = @"ZIM_Fallback_Domestic_URLs";
static NSString *const kFallbackOverseasUrlsKey = @"ZIM_Fallback_Overseas_URLs";

@implementation NoaFallbackEndpointStore

+ (instancetype)shared {
    static NoaFallbackEndpointStore *s;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s = [[self alloc] init];
        [s loadFromDefaults];
    });
    return s;
}

/// 将逗号分隔配置拆成非空 URL 列表
+ (NSArray<NSString *> *)urlsFromCSV:(NSString *)csv {
    if (csv.length <= 0) {
        return @[];
    }
    NSMutableArray<NSString *> *result = [NSMutableArray array];
    for (NSString *part in [csv componentsSeparatedByString:@","]) {
        NSString *trim = [part stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (trim.length > 0) {
            [result addObject:trim];
        }
    }
    return [result copy];
}

/// 旧占位兜底（10.10.x / 11.11.x）需要被宏配置覆盖
+ (BOOL)isPlaceholderUrls:(NSArray *)urls {
    if (![urls isKindOfClass:[NSArray class]] || urls.count == 0) {
        return YES;
    }
    for (id obj in urls) {
        if (![obj isKindOfClass:[NSString class]]) {
            continue;
        }
        NSString *u = (NSString *)obj;
        if ([u containsString:@"10.10.10."] || [u containsString:@"11.11.11."]) {
            return YES;
        }
    }
    return NO;
}

- (void)loadFromDefaults {
    NSArray *dom = [[NSUserDefaults standardUserDefaults] objectForKey:kFallbackDomesticUrlsKey];
    NSArray *over = [[NSUserDefaults standardUserDefaults] objectForKey:kFallbackOverseasUrlsKey];
    
    if (![dom isKindOfClass:[NSArray class]] ||
        ((NSArray *)dom).count == 0 ||
        [NoaFallbackEndpointStore isPlaceholderUrls:dom]) {
        dom = [NoaFallbackEndpointStore urlsFromCSV:kFallbackDomesticUrl];
        [[NSUserDefaults standardUserDefaults] setObject:dom forKey:kFallbackDomesticUrlsKey];
    }
    
    if (![over isKindOfClass:[NSArray class]] ||
        [NoaFallbackEndpointStore isPlaceholderUrls:over]) {
        // overseas 允许为空（对齐 Android overseasBakEndpoints）
        over = [NoaFallbackEndpointStore urlsFromCSV:kFallbackOverseasUrl];
        [[NSUserDefaults standardUserDefaults] setObject:over forKey:kFallbackOverseasUrlsKey];
    }
    
    self.domesticUrls = [dom copy];
    self.overseasUrls = [over copy];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveToDefaults {
    [[NSUserDefaults standardUserDefaults] setObject:self.domesticUrls ?: @[] forKey:kFallbackDomesticUrlsKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.overseasUrls ?: @[] forKey:kFallbackOverseasUrlsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateIfDifferentDomestic:(NSArray<NSString *> *)domestic
                         overseas:(NSArray<NSString *> *)overseas {
    BOOL changed = NO;
    if (domestic.count > 0 && ![domestic isEqualToArray:self.domesticUrls]) {
        self.domesticUrls = [domestic copy];
        changed = YES;
    }
    if (overseas.count > 0 && ![overseas isEqualToArray:self.overseasUrls]) {
        self.overseasUrls = [overseas copy];
        changed = YES;
    }
    if (changed) {
        [self saveToDefaults];
    }
}

@end
