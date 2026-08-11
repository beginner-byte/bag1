//
//  NoaUserRoleAuthorityModel.h
//  NoaKit
//
//  Created by Candy on 2023/11/9.
//

#import "NoaBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaUsereAuthModel : NoaBaseModel

@property (nonatomic, copy) NSString *authorityKey; //权限key
@property (nonatomic, copy) NSString *configData;   //权限配置数据
@property (nonatomic, copy) NSString *configValue;  //权限配置内容

@end


@interface NoaUserRoleAuthorityModel : NoaBaseModel

@property (nonatomic, strong) NoaUsereAuthModel *allowAddFriend;          //允许添加好友
@property (nonatomic, strong) NoaUsereAuthModel *createGroup;             //创建群组
@property (nonatomic, strong) NoaUsereAuthModel *deleteMessage;           //删除消息
@property (nonatomic, strong) NoaUsereAuthModel *remoteDeleteMessage;     //远程销毁
@property (nonatomic, strong) NoaUsereAuthModel *groupHairAssistant;      //群发助手
@property (nonatomic, strong) NoaUsereAuthModel *groupSecurity;           //群私密
@property (nonatomic, strong) NoaUsereAuthModel *showGroupPersonNum;      //查看群人数
@property (nonatomic, strong) NoaUsereAuthModel *showHeadLogo;            //显示头像标识
@property (nonatomic, strong) NoaUsereAuthModel *showRoleName;            //角色名称
@property (nonatomic, strong) NoaUsereAuthModel *upFile;                  //是否可传输文件及传输最大值
@property (nonatomic, strong) NoaUsereAuthModel *showTeam;                //是否显示 团队管理 和 分享邀请
@property (nonatomic, strong) NoaUsereAuthModel *upImageVideoFile;        //是否可传输图片/视频及传输最大值
@property (nonatomic, strong) NoaUsereAuthModel *showUserRead;            //聊天消息页面中 是否显示消息旁边的已读状态
@property (nonatomic, strong) NoaUsereAuthModel *isShowFileAssistant;     //是否显示文件助手(会话列表、通讯录顶部)

/// 翻译设置总开关（后端字段：translation_switch）
@property (nonatomic, strong) NoaUsereAuthModel *translationSwitch;
/// 群消息置顶开关（后端字段：group_msg_pinning）
@property (nonatomic, strong) NoaUsereAuthModel *groupMsgPinning;
/// 个人消息置顶开关（后端字段：user_dialog_msg_pinning）
@property (nonatomic, strong) NoaUsereAuthModel *userMsgPinning;
/// 消息编辑时限（后端字段：edited_message_sent），单位为分钟，0 表示关闭。
@property (nonatomic, strong) NoaUsereAuthModel *editMsgSwitch;

@end

NS_ASSUME_NONNULL_END
