//
//  NoaChatHistoryVC.h
//  NoaKit
//
//  Created by Candy on 2026/11/11.
//

// 聊天记录VC

#import "CandyBaseViewController.h"
#import "LingIMGroup.h"
NS_ASSUME_NONNULL_BEGIN

@interface NoaChatHistoryVC : CandyBaseViewController

@property (nonatomic, assign) CIMChatType chatType;//会话类型
@property (nonatomic, copy) NSString *sessionID;//会话ID(单聊userUid 群聊groupID)
@property (nonatomic, strong) LingIMGroup *groupInfoModel;

@end

NS_ASSUME_NONNULL_END
