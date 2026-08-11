//
//  NoaSampleUserInfoView.h
//  NoaKit
//
//  Created by Candy on 2026/9/13.
//

// 简单的用户信息View
// 头像 (备注) 昵称 账号

#import <UIKit/UIKit.h>
#import "NoaBaseImageView.h"
#import "NoaUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaSampleUserInfoView : UIView

@property (nonatomic, copy) void(^setRemarkBtnBlock)(void);   //设置备注按钮Block
@property (nonatomic, copy) void(^setDesBtnBlock)(void);   //修改描述按钮Block
@property (nonatomic, strong) UIView *viewOnline;//用户在线

//优先本地展示好友或群成员信息
- (void)configUserInfoWith:(NSString * _Nullable)userUid groupId:(NSString * _Nullable)groupId;
//接口返回新数据信息更新
- (void)updateUIWithUserModel:(NoaUserModel *)userModel isMyFriend:(BOOL)isMyFriend inGroupUserName:(NSString *)inGroupUserName;

@end

NS_ASSUME_NONNULL_END
