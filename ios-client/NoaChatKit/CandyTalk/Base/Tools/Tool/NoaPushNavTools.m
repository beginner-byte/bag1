//
//  NoaPushNavTools.m
//  NoaKit
//
//  Created by Candy on 2023/2/7.
//

#import "NoaPushNavTools.h"
#import "NoaChatViewController.h" //聊天详情页
#import "NoaChatKit-Swift.h"    //Swift 新朋友
#import "NoaToolManager.h"        //工具类

@implementation NoaPushNavTools

+ (void)pushMessageClickToNavWithInfo:(NSDictionary *)userInfo {
    if (UserManager.isLogined) {
        NSString *navType = (NSString *)[userInfo objectForKeySafe:@"jumpType"];
        if ([navType isEqualToString:@"chat"]) {
            
            NSInteger chatType = [[userInfo objectForKeySafe:@"chatType"] integerValue];
            NSString *sessionId = (NSString *)[userInfo objectForKeySafe:@"sessionId"];
            NSString *chatName = (NSString *)[userInfo objectForKeySafe:@"chatName"];
            
            //当用户上次刚好停留在了该会话的聊天界面就不进行跳转
            if ([ZTOOL.getCurrentVC isKindOfClass:[NoaChatViewController class]]) {
                NoaChatViewController *currentVC = (NoaChatViewController *)ZTOOL.getCurrentVC;
                if ([currentVC.sessionID isEqualToString:sessionId]) {
                    return;
                }
            }
            
            //跳转到聊天详情
            //聊天详情VC
            NoaChatViewController *chatVC = [[NoaChatViewController alloc] init];
            chatVC.chatName = chatName;
            chatVC.sessionID = sessionId;
            chatVC.chatType = chatType;
            [ZTOOL.getCurrentVC.navigationController pushViewController:chatVC animated:YES];
        }
        if ([navType isEqualToString:@"friend"]) {
            //跳转到新朋友
            CoHereNewFriendListViewController *newFriendVC = [[CoHereNewFriendListViewController alloc] init];
            [ZTOOL.getCurrentVC.navigationController pushViewController:newFriendVC animated:YES];
        }
    }
}

@end
