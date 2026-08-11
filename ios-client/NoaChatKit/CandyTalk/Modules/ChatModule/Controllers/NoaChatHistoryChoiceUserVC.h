//
//  NoaChatHistoryChoiceUserVC.h
//  NoaKit
//
//  Created by Candy on 2024/8/12.
//

#import "CandyBaseViewController.h"
#import "NoaBaseUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZChatHistoryChoiceUserDelegate <NSObject>

- (void)chatHistoryChoicedUserList:(NSArray<NoaBaseUserModel *> *)selectedUserList;

@end

@interface NoaChatHistoryChoiceUserVC : CandyBaseViewController

@property (nonatomic, assign) CIMChatType chatType;//会话类型
@property (nonatomic, copy) NSString *sessionID;//会话ID(单聊userUid 群聊groupID)
@property (nonatomic, weak) id <ZChatHistoryChoiceUserDelegate> delegate;
@property (nonatomic, strong) NSMutableArray<NoaBaseUserModel *> *choicedList;//选中的

@end

NS_ASSUME_NONNULL_END
