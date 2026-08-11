//
//  NoaUserHomePageVC.h
//  NoaKit
//
//  Created by Candy on 2026/10/20.
//

// 用户主页VC

#import "CandyBaseViewController.h"


//typedef NS_ENUM(NSUInteger, UserHomePageVCType) {
//    UserHomePageSingleChatType = 1,        //单聊、通讯录查看好友信息
//    UserHomePageGroupChatType = 2,        //群聊查看好友信息
//};


NS_ASSUME_NONNULL_BEGIN

@interface NoaUserHomePageVC : CandyBaseViewController

/// 用户id
@property (nonatomic, copy) NSString *userUID;

/// 群组id
@property (nonatomic, copy) NSString *groupID;

/// 是否是从二维码扫码进入
@property (nonatomic, assign) BOOL isFromQRCode;

@end

NS_ASSUME_NONNULL_END
