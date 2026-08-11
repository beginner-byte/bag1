//
//  NoaChatMultiSelectSendHander.h
//  NoaKit
//
//  Created by Candy on 2023/4/18.
//

#import <Foundation/Foundation.h>
#import "NoaMessageModel.h"
#import "NoaMyCollectionItemModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaChatMultiSelectSendHander : NSObject

@property (nonatomic, copy)NSString *fromSessionId;

//导航栏返回上一级回调
@property (nonatomic, copy) void(^navBackActionBlock)(BOOL isSuccess, NSInteger errorCode, NSString *errorMsg);

//消息转发结果block回调
@property (nonatomic, copy) void(^forwardComleteBlock)(NSArray<NoaIMChatMessageModel *> * _Nullable sendForwardMsgList);
//分享二维码图片(群二维码/个人二维码)结果block回调
@property (nonatomic, copy) void(^shareQRcodeComleteBlock)(NoaIMChatMessageModel * _Nullable sendShareQRMsg);
//收藏消息发送block回调
@property (nonatomic, copy) void(^collectionSendCompleteBlock)(BOOL isSuccess, NoaIMChatMessageModel * _Nullable sendCollectionMsg);


- (instancetype)init;

//多选对象-转发消息
- (void)chatMultiSelectSendForwardMessageList:(NSArray *)forwardMsgList imMessage:(IMChatMessageList *)imMessage;

//多选对象-推荐名片给好友
- (void)chatMultiSelectRecommendFriendCard:(NSString *)friendUid receiverList:(NSArray *)receiverList;

//多选对象-分享二维码图片(群二维码/个人二维码)，当成转发普通图片类型消息处理
- (void)chatMultiSelectShareQRcodeMessage:(UIImage *)qrImage selectObjectList:(NSArray *)selectObjectList;

//单条收藏消息发送给会话(走单条消息转发单个会话逻辑)
- (void)chatCollectionMessagSendWith:(NoaMyCollectionItemModel *)collectionMsg chatType:(CIMChatType)chatType sessionId:(NSString *)sessionId;
@end

NS_ASSUME_NONNULL_END
