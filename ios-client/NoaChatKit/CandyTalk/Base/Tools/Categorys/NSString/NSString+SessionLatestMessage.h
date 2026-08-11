//
//  NSString+SessionLatestMessage.h
//  NoaKit
//
//  Created by Candy on 2026/11/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (SessionLatestMessage)

/// 根据聊天消息内容确定会话列表展示内容
/// @param sessionModel 会话消息
+ (NSMutableAttributedString *)getSessionLatestMessageAttributedStringWith:(LingIMSessionModel * _Nullable)sessionModel;


/// 根据群发助手消息内容，确定回话列表展示内容
/// @param sessionModel 会话消息
+ (NSMutableAttributedString *)getSessionLatestMassMessageAttributedStringWith:(LingIMSessionModel * _Nullable)sessionModel;

/// 根据聊天消息内容确定消息记录里展示内容
/// @param imChatMessage 消息记录里的消息
+ (NSMutableAttributedString *)getMessageRecordAttributedStringWith:(IMChatMessage * _Nullable)imChatMessage;

/// 展示会话的草稿内容
/// @param sessionModel 会话消息
+ (NSMutableAttributedString *)getSessionDraftContentAttributedStringWith:(LingIMSessionModel * _Nullable)sessionModel;

/// 展示会话的最新消息或提醒的默认样式
/// @param sessionLastContent 会话展示的最新消息内容
+ (NSMutableAttributedString *)getSessionDefaultLastMsgContentAttributedStringWith:(NSString * _Nullable)sessionLastContent;

@end

NS_ASSUME_NONNULL_END
