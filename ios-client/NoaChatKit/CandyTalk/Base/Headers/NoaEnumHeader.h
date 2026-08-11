//
//  NoaEnumHeader.h
//  NoaKit
//
//  Created by Candy on 2026/9/5.
//

#ifndef ZEnumHeader_h
#define ZEnumHeader_h

//用户性别
typedef NS_ENUM(NSUInteger, UserGenderType) {
    UserGenderTypeSecurity = 0, //保密
    UserGenderTypeMan = 1,      //男
    UserGenderTypeWoman = 2,    //女
    UserGenderTypeUnknow,       //未知(未选择)
};

//网络请求 数据请求状态
typedef NS_ENUM(NSInteger, ZHttpRequestCodeType) {
    ZHttpRequestCodeTypeSuccess = 10000,      //数据请求成功
    ZHttpRequestCodeTokenOutTime = 40035,     // 40035,身份信息已过期，请重新登录
    ZHttpRequestTokenError = 40038,           //40038,身份信息验证失败
    ZHttpRequestCodeNotNetWork = -1009,       //没有网络
};

//网络请求 数据请求方法
typedef NS_ENUM(NSUInteger, ZHttpRequestMedth) {
    requestPOST = 1,        //POST请求
    requestGET = 2,         //GET请求
};

//网络请求 上传图片、视频类型 表单提交
typedef NS_ENUM(NSUInteger, ZHttpUploadType) {
    ZHttpUploadTypeImage = 1,        //图片
    ZHttpUploadTypeVideo = 2,        //视频
    ZHttpUploadTypeGroupAvatar = 3,  //群组头像
    ZHttpUploadTypeUserAvatar = 4,   //修改个人头像
    ZHttpUploadTypeVoice = 5,        //语音
    ZHttpUploadTypeFile = 6,         //文件
    ZHttpUploadTypeUniversal = 7,    //通用文件保存路径
    ZHttpUploadTypeMiniApp = 8,      //小程序图标
    ZHttpUploadTypeStickers = 9,     //表情
    ZHttpUploadTypeImageThumbnail = 10,  //图片消息缩略图
};

//消息删除操作类型
typedef NS_ENUM(NSUInteger, ZMsgDeleteType) {
    ZMsgDeleteTypeOneWay = 1,      //消息删除-单向
    ZMsgDeleteTypeBothWay = 2,     //消息删除-双向
};

//消息长按 菜单弹窗 类型
typedef NS_ENUM(NSUInteger, MessageMenuItemActionType) {
    MessageMenuItemActionTypeUnknown = 0,     //占位 未知
    
    MessageMenuItemActionTypeCopy = 1,        //复制
    MessageMenuItemActionTypeForward = 2,     //转发
    MessageMenuItemActionTypeDelete = 3,      //删除
    MessageMenuItemActionTypeRevoke = 4,      //撤回
    MessageMenuItemActionTypeReference = 5,   //引用
    MessageMenuItemActionTypeCollection = 6,  //收藏
    MessageMenuItemActionTypeMultiSelect = 7, //多选
    MessageMenuItemActionTypeAddTag = 8,      //url存为标签
    MessageMenuItemActionTypeCopyContent = 9,        //复制原文
    MessageMenuItemActionTypeCopyTranslate = 10,     //复制译文
    MessageMenuItemActionTypeShowTranslate = 11,     //翻译
    MessageMenuItemActionTypeHiddenTranslate = 12,   //隐藏译文
    MessageMenuItemActionTypeStickersAdd = 13,      //表情添加
    MessageMenuItemActionTypeStickersPackage = 14,   //表情包
    MessageMenuItemActionTypeMutePlayback = 15,   //静音播放
    MessageMenuItemActionTypeGroupTop = 16,   //置顶
    MessageMenuItemActionTypeGroupTopCancel = 17, //取消置顶
    MessageMenuItemActionTypeSingleTop = 18,   //单聊置顶
    MessageMenuItemActionTypeSingleTopCancel = 19, //单聊取消置顶
    MessageMenuItemActionTypeEdit = 20,       //编辑已发送消息
};

//发送文件消息时，所选文件的来源
typedef NS_ENUM(NSUInteger, ZMsgFileSourceType) {
    ZMsgFileSourceTypePhone = 1,            //手机中的文件
    ZMsgFileSourceTypeAlbumVideo = 2,       //相册视频
    ZMsgFileSourceTypeLingxin = 3,          //App中的文件
};

//扫码结果跳转区分
typedef NS_ENUM(NSUInteger, ZQrCodeResult) {
    ZQrCodeResultUser = 1,          //结果为用户二维码
    ZQrCodeResultGroup = 2,         //结果为群二维码
    ZQrCodeResultPCAuth = 3,        //结果为授权PC登录
    ZQrCodeResultAuth = 5,          //邀请码导航
    ZQrCodeResultTxt = 100,         //结果为纯文本
    ZQrCodeResultUrl = 101,         //结果为Url
    
};

//跳转到多选用户、群组、会话列表界面 (转发消息、推荐好友名片)
typedef NS_ENUM(NSUInteger, ZMultiSelectType) {
    ZMultiSelectTypeSingleForward = 1,  //消息转发(单条转发、逐条转发)
    ZMultiSelectTypeMergeForward = 2,   //消息转发(合并转发)
    ZMultiSelectTypeRecommentCard = 3,  //推荐好友名片
    ZMultiSelectTypeShareQRImg = 4,     //分享二维码图片
};

//跳转到群助手的来源
typedef NS_ENUM(NSUInteger, ZGroupHelperFormType) {
    ZGroupHelperFormTypeGroupManager = 1,  //跳转到群助手的来源-群管理
    ZGroupHelperFormTypeSessionList = 2,   //跳转到群助手的来源-会话列表
};

//入群申请处理状态
typedef NS_ENUM(NSUInteger, ZGroupApplyHandleStatus) {
    ZGroupApplyHandleStatusAgree = 1,   //通过
    ZGroupApplyHandleStatusRefuse = 2,  //拒绝
};

//节点竞速步骤Step
typedef NS_ENUM(NSUInteger, ZNetRacingStep) {
    ZNetRacingStepOss = 1,   //oss竞速
    ZNetRacingStepHttp = 2,  //http竞速
    ZNetRacingStepTcp = 3,  //tcp竞速
    ZNetIpDomainStepHttp = 4,  //IP/Domain http获取系统配置
    ZNetIpDomainStepTcp = 5,  //IP/Domain Tcp连通性检查
};

// 节点竞速输入框方式
typedef NS_ENUM(NSUInteger, ZSsoTypeMenu) {
    ZSsoTypeMenuCompanyId = 1,   //邀请码
    ZSsoTypeMenuIPAndDomain = 2,   //IP/域名
};

// 登录方式选择
typedef NS_ENUM(NSUInteger, ZLoginAndRegisterTypeMenu) {
    ZLoginTypeMenuPhoneNumber,
    ZLoginTypeMenuEmail,
    ZLoginTypeMenuAccountPassword,
};

//音视频通话 用户 通话状态
typedef NS_ENUM(NSUInteger, ZCallUserState) {
    ZCallUserStateCalling = 0,   //用户 正在呼叫中
    ZCallUserStateAccept = 1,    //用户 已接听
    ZCallUserStateTimeOut = 2,   //用户 呼叫超时
    ZCallUserStateRefuse = 3,    //用户 拒绝通话
    ZCallUserStateHangup = 4,    //用户 结束通话(挂断)
    ZCallUserStateCancel = 5,    //用户 取消通话
};

//投诉与支持 类型
typedef NS_ENUM(NSUInteger, ZComplainType) {
    ZComplainTypeSystem = 1,   //系统投诉
    ZComplainTypeDomain = 2,   //邀请码、域名
};

//聊天接收、发送消息翻译选择通道或语种 类型
typedef NS_ENUM(NSUInteger, ZMsgTranslateType) {
    ZReceiveMsgTranslateTypeChannel = 1,   //通道-收到消息
    ZReceiveMsgTranslateTypeLanguage = 2,  //语种-收到消息
    ZSendMsgTranslateTypeChannel = 3,   //通道-发送消息
    ZSendMsgTranslateTypeLanguage = 4,  //语种-发送消息
};

//app启动时，使用哪种方式进行竞速
typedef NS_ENUM(NSUInteger, ZReacingType) {
    ZReacingTypeNone = 1,       //无，默认占位
    ZReacingTypeCompanyId = 2,  //邀请码竞速方式
    ZReacingTypeIpDomain = 3,   //ip/域名 直连竞速
};

//聊天界面 输入框 控件类型
typedef NS_ENUM(NSUInteger, ZChatInputViewType) {
    ZChatInputViewTypeChat = 1,            //聊天
    ZChatInputViewTypeFileHelper = 2,      //文件助手
};

//聊天界面 输入框 功能类型
typedef NS_ENUM(NSUInteger, ZChatInputActionType) {
    ZChatInputActionTypeAudioCall = 1,      //音频通话
    ZChatInputActionTypeVideoCall = 2,      //视频通话
    ZChatInputActionTypePhotoAlbum = 3,     //相册
    ZChatInputActionTypeFile = 4,           //文件
    ZChatInputActionTypeLocation = 5,       //位置
    ZChatInputActionTypeCollection = 6,     //收藏
    ZChatInputActionTypeTranslate = 7,      //翻译
};

//会话列表-右上角更多按钮
typedef NS_ENUM(NSUInteger, ZSessionMoreActionType) {
    ZSessionMoreActionTypeAddFriend = 1,     //添加好友
    ZSessionMoreActionTypeCreateGroup = 2,     //创建群聊
    ZSessionMoreActionTypeSacnQRcode = 3,     //扫一扫
    ZSessionMoreActionTypeMassMessage = 4,     //群发助手
};

//聊天界面 输入框 游戏表情
typedef NS_ENUM(NSUInteger, ZChatGameStickerType) {
    ZChatGameStickerTypeFingerGuessing  = 1,    //猜拳：石头剪刀布
    ZChatGameStickerTypePlayDice = 2,           //摇骰子
};

//封禁弹窗UI样式
typedef NS_ENUM(NSUInteger, ZAuthBannedAlertType) {
    ZAuthBannedAlertTypeSinglBtn,      //只有一个按钮（退出登录）
    ZAuthBannedAlertTypeTwoBtn,        //两个按钮(退出登录、申请解封)
};

//封禁弹窗UI样式
typedef NS_ENUM(NSUInteger, ZDNSLocalModelType) {
    ZDNSLocalModelTypeMain,      //主桶
    ZDNSLocalModelTypeSpare,     //副桶
    ZDNSLocalModelTypeLocal,     //内置
};
//消息发送失败
//event_message
//接口调用失败
//event_http
//邀请码加入失败
//event_enterprise
//图片加载失败
//event_image
//媒体消息上传失败
//event_message_upload

typedef NS_ENUM(NSUInteger, ZSentryUploadType) {
    ZSentryUploadTypeMessage = 1,       //消息发送失败
    ZSentryUploadTypeHttp = 2,          //接口调用失败
    ZSentryUploadTypeEnterprise = 3,    //邀请码加入失败
    ZSentryUploadTypeImage = 4,         //图片加载失败
    ZSentryUploadTypeUpload = 5,        //媒体消息上传失败
    ZSentryUploadTypeSocketConnect = 6, //socket连接
    ZSentryUploadTypeEnterpriseSuccess = 7, //导航获取成功
    ZSentryGaOnChainSuccess = 8, // GaOnChain获取数据成功
    ZSentryGaOnChainFailed = 9 // GaOnChain获取数据失败
};

typedef NS_ENUM(NSInteger, ProxyType) {
    ProxyTypeSystem = 0,
    ProxyTypeHTTP = 1,
    ProxyTypeSOCKS5 = 2
};

typedef NS_ENUM(NSInteger, EncryptType) {
    EncryptTypeAES = 0,
    EncryptTypeXOR = 1,
    EncryptTypeNOT = 2
};

typedef NS_ENUM(NSInteger, NavDataType) {
    NavDataTypeSuccess = 200000,
    NavDataTypeMissing = 400001,
    NavDataTypeAppIdInvalid = 400002,
    NavDataTypeRegionInvalid = 400003,
    NavDataTypeClientVersionInvalid = 400004,
    NavDataTypeServerError = 500001,
    NavDataTypeNavDataFormatError = 500002,
    NavDataTypeJsonParseError = 500003,
    NavDataTypeEndpointParseError = 500004
};

#endif /* ZEnumHeader_h */
