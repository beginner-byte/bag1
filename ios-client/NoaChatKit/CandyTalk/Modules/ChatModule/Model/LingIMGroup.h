//
//  ZGroupInfoModel.h
//  NoaKit
//
//  Created by Candy on 2026/11/4.
//

#import "NoaBaseModel.h"
#import <NoaChatCore/LingIMGroupMemberModel.h>
#import "NoaGroupNoteModel.h"

NS_ASSUME_NONNULL_BEGIN

/** 群信息 管理群组.*/
@interface LingIMGroup : NoaBaseModel

/**
 * 群ID
 */
@property (nonatomic, copy) NSString *groupId;

/**
 * 群头像
 */
@property (nonatomic, copy) NSString *groupAvatar;

/**
 * 群名称
 */
@property (nonatomic, copy) NSString *groupName;

/**
 * 群成员总个数
 */
@property (nonatomic, assign) NSInteger memberCount;

/**
 * 群成员列表
 */
@property (nonatomic, strong) NSArray <LingIMGroupMemberModel *> *groupMemberList;

/**
 * 最新群公告
 */
@property (nonatomic, strong, nullable) NoaGroupNoteModel *groupNotice;

/**
 * 我在本群的昵称
 */

@property (nonatomic, copy) NSString *nicknameInGroup;

/**
 * 我在本群的角色(0普通成员;1管理员;2群主)
 */

@property (nonatomic, assign) NSInteger userGroupRole;

/**
 * 消息免打扰
 */

@property (nonatomic, assign) BOOL msgNoPromt;

/**
 * 置顶
 */
@property (nonatomic, assign) BOOL msgTop;

/**
 * 当前用户是否在此群里
 */
@property (nonatomic, assign) BOOL userInGroup;

/**
 * 是否开启群内禁止私聊
 */
@property (nonatomic, assign) BOOL isPrivateChat;

/**
 * 是否开启入群验证
 */
@property (nonatomic, assign) BOOL isNeedVerify;

/**
 * 是否开启全群禁言
 */
@property (nonatomic, assign) BOOL isGroupChat;
/**
 * 群状态 0：封禁 1：正常 2：删除
 */
@property (nonatomic, assign) NSInteger groupStatus;
/**
 * 是否允许音视频通话
 */
@property (nonatomic, assign) BOOL isNetCall;
/**
 * 群机器人数量
 */
@property (nonatomic, assign) NSInteger robotCount;

/**
 * 是否显示群提示消息（入群、踢人） ，0关闭，1开启
 */
@property (nonatomic, assign)NSInteger isMessageInform;

/**
 * 开启/关闭群通知：0:关闭群通知 1:开启群通知 (默认为1 开启) 优先级高于isMessageInform
 */
@property (nonatomic, assign)NSInteger groupInformStatus;

/**
 * 是否开启新人查看聊天记录 0关闭, 1开启
 */
@property (nonatomic, assign) BOOL isShowHistory;

//是否显示群二维码(0:不展示; 1:展示)
@property (nonatomic, assign) BOOL isShowQrCode;

//关闭搜索用户0:否1:是
@property (nonatomic, assign) BOOL closeSearchUser;

//删除该时间戳之前的本地消息
@property (nonatomic, assign) long long canMsgTime;

//是否启用群活跃功能（0：关闭，1：开启）
@property (nonatomic, assign) NSInteger isActiveEnabled;


@end

NS_ASSUME_NONNULL_END
