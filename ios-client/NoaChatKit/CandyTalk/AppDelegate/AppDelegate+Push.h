//
//  AppDelegate+Push.h
//  NoaKit
//
//  Created by Apple on 2023/1/14.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (Push)
//后台收到消息
- (void)receivePushMessageWithEnterBackground:(NoaIMChatMessageModel *)message;
//后台收到好友申请
- (void)receivePushInviteWithEnterBackground:(FriendInviteMessage *)message;
//对方已同意好友请求
//- (void)receivePushAgreenWithEnterBackground:(FriendConfirmMessage *)message;
@end

NS_ASSUME_NONNULL_END
