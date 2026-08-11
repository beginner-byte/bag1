//
//  NoaChatViewController.h
//  NoaKit
//
//  Created by Candy on 2026/9/23.
//

#import "CandyBaseViewController.h"
#import "LingIMGroup.h"

#import "SyncMutableArray.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaChatViewController : CandyBaseViewController
@property (nonatomic, assign) CIMChatType chatType;//会话类型
//单聊
@property (nonatomic, copy) NSString *chatName;
@property (nonatomic, copy) NSString *sessionID;//会话ID(单聊userUid 群聊groupID)
/// 草稿变化回调（点对点刷新会话cell，不使用通知）
@property (nonatomic, copy, nullable) void (^draftDidChange)(NSString *sessionId, NSDictionary *draft);
//群聊(群聊信息)
@property (nonatomic, strong) LingIMGroup *groupInfo;
//消息显示数据
@property (nonatomic, strong) SyncMutableArray *messageModels;

@property (nonatomic, assign) BOOL isFromQRCode;
/// 文件助手专属模式；仅由 Swift 文件助手入口开启，避免执行普通单聊资料和标签逻辑。
@property (nonatomic, assign) BOOL isFileHelperMode;

//通过点击全局搜索结果进入聊天界面
- (void)clickSearchResultInChatRoomWithMessage:(NoaIMChatMessageModel *)messageModel;


@end

NS_ASSUME_NONNULL_END
