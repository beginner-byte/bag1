//
//  NoaSessionReadTool.m
//  NoaKit
//
//  Created by Candy on 2024/12/30.
//

#import "NoaSessionReadTool.h"

@implementation NoaSessionReadTool

+ (void)updateSessionReadNumSMsgIdWithSessionId:(NSString *)sessionId lastSMsgId:(NSString *)lastSMsgId {
    NSMutableDictionary *clearReadNumSMsgIdDict = [[[MMKV defaultMMKV] getObjectOfClass:[NSDictionary class] forKey:@"clearReadNumSMsgIdDictKey"] mutableCopy];
    if (clearReadNumSMsgIdDict == nil) {
        clearReadNumSMsgIdDict = [[NSMutableDictionary alloc] init];
    }
    [clearReadNumSMsgIdDict setObjectSafe:lastSMsgId forKey:sessionId];
    [[MMKV defaultMMKV] setObject:[clearReadNumSMsgIdDict copy] forKey:@"clearReadNumSMsgIdDictKey"];
}

+ (void)updateAllSessionReadNumSMsgIdLastSMsgId:(NSString *)lastSMsgId {
    NSMutableDictionary *clearReadNumSMsgIdDict = [[[MMKV defaultMMKV] getObjectOfClass:[NSDictionary class] forKey:@"clearReadNumSMsgIdDictKey"] mutableCopy];
    if (clearReadNumSMsgIdDict == nil) {
        clearReadNumSMsgIdDict = [[NSMutableDictionary alloc] init];
    }
    NSArray *allKeys = [clearReadNumSMsgIdDict allKeys];
    for (int i = 0; i < allKeys.count; i++) {
        NSString *tempSessionIdKey = (NSString *)[allKeys objectAtIndexSafe:i];
        [clearReadNumSMsgIdDict setObjectSafe:lastSMsgId forKey:tempSessionIdKey];
    }
    [[MMKV defaultMMKV] setObject:[clearReadNumSMsgIdDict copy] forKey:@"clearReadNumSMsgIdDictKey"];
}

+ (NSString *)getLastSMsgIdWithSessionId:(NSString *)sessionId {
    NSDictionary *clearReadNumSMsgIdDict = [[MMKV defaultMMKV] getObjectOfClass:[NSDictionary class] forKey:@"clearReadNumSMsgIdDictKey"];
    if (clearReadNumSMsgIdDict == nil) {
        return @"";
    } else {
        NSString *lastSMsgId = (NSString *)[clearReadNumSMsgIdDict objectForKeySafe:@"sessionId"];
        if ([NSString isNil:lastSMsgId]) {
            return @"";
        } else {
            return lastSMsgId;
        }
    }
}

@end
