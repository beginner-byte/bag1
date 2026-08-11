//
//  NoaChatHistoryFileVC.h
//  NoaKit
//
//  Created by Candy on 2023/2/2.
//

#import "CandyBaseViewController.h"
#import "LingIMGroup.h"
NS_ASSUME_NONNULL_BEGIN

@interface NoaChatHistoryFileVC : CandyBaseViewController

@property (nonatomic, assign) CIMChatType chatType;//会话类型
@property (nonatomic, copy) NSString *sessionID;//会话ID(单聊userUid 群聊groupID)
////群聊(群聊信息) 此值不传代表的就是单聊 反之群聊
@property (nonatomic, strong) LingIMGroup *groupInfo;

@end

NS_ASSUME_NONNULL_END
