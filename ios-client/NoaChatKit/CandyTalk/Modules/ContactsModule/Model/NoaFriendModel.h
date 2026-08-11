//
//  NoaFriendModel.h
//  NoaKit
//
//  Created by Candy on 2023/5/21.
//

#import "NoaBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaFriendModel : NoaBaseModel

//好友id
@property (nonatomic, copy) NSString *friendUserUID;
//好友账号
@property (nonatomic, copy) NSString *userName;
//好友昵称
@property (nonatomic, copy) NSString *nickname;
//好友头像
@property (nonatomic, copy) NSString *avatar;
//会话置顶
@property (nonatomic, assign) BOOL msgTop;
//消息免打扰
@property (nonatomic, assign) BOOL msgNoPromt;
//好有在线状态
@property (nonatomic, assign) BOOL onlineStatus;
//好友备注
@property (nonatomic, copy) NSString *remarks;
//好友描述
@property (nonatomic, copy) NSString *descRemark;
//账号状态(0正常，1封禁，3注销中，4已注销)
@property (nonatomic, assign) NSInteger disableStatus;
//好友的用户类型 0好友为普通用户 1好友为系统用户
@property (nonatomic, assign) NSInteger userType;
//在视图上显示的名称（有备注的话，此字段和备注一样，没有的备注的话，此字段和nickname一样）
@property (nonatomic, copy) NSString * showName;

//通讯录排序参数，showName+userName 转成拼音
@property (nonatomic, copy) NSString * sortName;
//好友 所在好友分组标识
@property (nonatomic, copy) NSString *ugUuid;
//好友 角色名称 id
@property (nonatomic, assign) NSInteger roleId;

@end

NS_ASSUME_NONNULL_END
