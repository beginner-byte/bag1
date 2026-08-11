//
//  NoaBaseUserModel.h
//  NoaKit
//
//  Created by Candy on 2024/1/11.
//

#import "NoaBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaBaseUserModel : NoaBaseModel

@property (nonatomic, copy) NSString *userId;//id
@property (nonatomic, copy) NSString *avatar;//头像
@property (nonatomic, copy) NSString *name;  //昵称
@property (nonatomic, assign) NSInteger roleId;//角色Id
@property (nonatomic, assign) BOOL showRole;//显示角色名称
//账号状态(0正常，1封禁，3注销中，4已注销)
@property (nonatomic, assign) NSInteger disableStatus;

@property (nonatomic, assign) BOOL isGroup;//是否群聊

@property (nonatomic, assign) BOOL isExistGroup;//是否存在当前群聊

@property (nonatomic, assign) long long lastSendMsgTime;//上次发送消息的时间戳

@property (nonatomic, assign) BOOL isOwerOrManager;//是否是群主或管理员

@end

NS_ASSUME_NONNULL_END
