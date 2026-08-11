//
//  NoaSystemSettingModel.h
//  NoaKit
//
//  Created by Candy on 2023/5/17.
//

#import "NoaBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/// App系统配置项
@interface NoaSystemSettingModel : NoaBaseModel

@property (nonatomic, copy)NSString *allowAddFriends;
@property (nonatomic, copy)NSString *allowBeCreateGroup;
@property (nonatomic, copy)NSString *contactsCount;
@property (nonatomic, copy)NSString *defaultCreateGroup;
@property (nonatomic, copy)NSString *defaultFriendIds;
//{"1":"账号", "2":"邮箱","3":"手机号","4":"手机号+邮箱","5":"手机号+账号",6":"邮箱+账号","7":"手机号+邮箱+账号"}
@property (nonatomic, copy)NSString *loginMethod;
@property (nonatomic, copy)NSString *maxGroupCount;
@property (nonatomic, copy)NSString *projectLogo;
@property (nonatomic, copy)NSString *projectName;
//聊天消息页面中 是否显示消息旁边的已读状态："true"=开启  "false"=关闭
//@property (nonatomic, assign)BOOL showUserRead;
//音视频SDK平台
@property (nonatomic, copy)NSString *video_source_config;//0:LiveKit 1:即构
//即构SDK相关信息
@property (nonatomic, copy)NSString *video_source_config_zg_appId;//app唯一标识
@property (nonatomic, copy)NSString *video_source_config_zg_appSign;//app的鉴权秘钥
@property (nonatomic, copy)NSString *video_source_config_zg_server_secret;//后台服务请求接口的鉴权校验
@property (nonatomic, copy)NSString *video_source_config_zg_callback_secret;//后台服务回调接口的鉴权校验
@property (nonatomic, copy)NSString *video_source_config_zg_server_address;//服务器的 WebSocket 通信地址
@property (nonatomic, copy)NSString *video_source_config_zg_websocket_server_address_backup;//服务器的WebSocket通信地址(备用)

//文件存储
@property (nonatomic, copy)NSString *oss_config_type;//文件存储类型(0:minio,1:aliyun，2:aws，3:腾讯云，4:华为云)

@property (nonatomic, copy)NSString *oss_config_bucket_name;//文件存储-桶名称
@property (nonatomic, copy)NSString *oss_config_end_point;//文件存储-endPoint
@property (nonatomic, copy)NSString *oss_config_region_id;//文件存储-region

@property (nonatomic, copy)NSString *oss_obs_bucket_name; //华为云OBS 桶名称
@property (nonatomic, copy)NSString *oss_obs_end_point; //华为云OBS 默认节点
@property (nonatomic, copy)NSString *oss_obs_custom_domain_put; //华为云OBS 自定义加速域名节点 上传域名
@property (nonatomic, copy)NSString *oss_obs_custom_domain_get; //华为云OBS 自定义加速域名节点 下载域名

//群组消息发送最小时间间隔 单位:毫秒
@property (nonatomic, assign)long long groupMessageInterval;

//注册时，是否需要输入邀请码，来觉得调用注册接口时是否对邀请码输入框输入的内容做非空判断(0:否，1是)
//isMustInviteCode 来控制是否显示邀请码输入框 (0:隐藏，1:显示)
@property (nonatomic, copy)NSString *isMustInviteCode;

@property (nonatomic,assign)BOOL registerInviteCode;

//群聊中是否允许 群主/管理员 撤回群内其他人发生的消息（是否开启群管理消息撤回： 0关闭，1开启）
@property (nonatomic, copy)NSString *groupMangerMessageRecallTime;
//聊天消息发送后最小允许撤回时间间隔 0关闭，>0 具体时间，单位:分钟
@property (nonatomic, copy)NSString *messageRecallTime;
//全局配置项中增加“仅允许群管理查看群人数”配置项,仅允许群管理查看群人数（1=是，0=否）,默认=1
@property (nonatomic, copy)NSString *onlyAllowAdminViewGroupPersonCount;
//全局配置项中增加“是否开启音视频通话”配置项,是否开启音视频通话（1=是，0=否）,默认=1
@property (nonatomic, copy)NSString *enableAudioAndVideoCalls;

//profilesActive:  dev:开发环境，test:测试环境，pro:生产环境（根据不同环境值取本地对应的投诉url）
@property (nonatomic, copy)NSString *profilesActive;

//是否校验app版本,默认true,当verifyAppVersion 为false时。不请求getLatestVersion 拉取最新版本接口
@property (nonatomic, assign)BOOL verifyAppVersion;

//用于接口验签
@property (nonatomic, copy)NSString *tenantCode;

//创建/修改密码时 checkEnglishSymbol如果为true时校验英文符号,反之不校验（对应的提示语和校验正则都需要改变）
@property (nonatomic, assign)BOOL checkEnglishSymbol;

//captchaChannel:2:图形验证码 3:腾讯验证码(无感验证) 4:阿里云验证码(无痕验证) 1:关闭验证码
@property (nonatomic, assign)NSInteger captchaChannel;

//1":"账号", "2":"邮箱","3":"手机号","4":"手机号+邮箱","5":"手机号+账号",6":"邮箱+账号","7":"手机号+邮箱+账号
@property (nonatomic, copy)NSString *registerMethod;

//http dns解析域名
@property (nonatomic, copy)NSString *http_dns_domain;

//日志上报域名
@property (nonatomic, copy)NSString *sys_uploadlog_domain;
//群成员活跃积分查询间隔 单位秒
@property (nonatomic, copy)NSString *member_active_points_interval;

@end

NS_ASSUME_NONNULL_END
