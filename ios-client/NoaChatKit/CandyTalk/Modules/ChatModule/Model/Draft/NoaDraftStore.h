//
//  NoaDraftStore.h
//  NoaKit
//
//  本地会话草稿存储（MMKV），key: Z_Draft_<sessionId>
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaDraftStore : NSObject

/// 读取草稿（{ draftContent: NSString, atUser: NSArray }）
+ (NSDictionary * _Nullable)loadDraftForSession:(NSString *)sessionId;

/// 保存草稿
+ (void)saveDraft:(NSDictionary *)draft forSession:(NSString *)sessionId;

/// 删除草稿
+ (void)deleteDraftForSession:(NSString *)sessionId;

@end

NS_ASSUME_NONNULL_END

