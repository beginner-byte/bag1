//
//  NoaDraftStore.m
//  NoaKit
//

#import "NoaDraftStore.h"
#import <MMKV/MMKV.h>

@implementation NoaDraftStore

static inline NSString *ZDraftKey(NSString *sessionId) {
    return [NSString stringWithFormat:@"Z_Draft_%@", sessionId ?: @""];
}

+ (NSDictionary * _Nullable)loadDraftForSession:(NSString *)sessionId {
    if (sessionId.length == 0) { return nil; }
    NSDictionary *dict = [[MMKV defaultMMKV] getObjectOfClass:[NSDictionary class] forKey:ZDraftKey(sessionId)];
    return dict;
}

+ (void)saveDraft:(NSDictionary *)draft forSession:(NSString *)sessionId {
    if (sessionId.length == 0 || draft == nil) { return; }
    [[MMKV defaultMMKV] setObject:draft forKey:ZDraftKey(sessionId)];
}

+ (void)deleteDraftForSession:(NSString *)sessionId {
    if (sessionId.length == 0) { return; }
    [[MMKV defaultMMKV] removeValueForKey:ZDraftKey(sessionId)];
}

@end


