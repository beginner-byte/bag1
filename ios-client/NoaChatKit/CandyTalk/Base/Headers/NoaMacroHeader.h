//
//  NoaMacroHeader.h
//  NoaKit
//
//  Created by Candy on 2026/8/30.
//

/** 宏定义 */

#ifndef ZMacroHeader_h
#define ZMacroHeader_h
#import <pthread.h>
#import <Foundation/Foundation.h>
static inline void dispatch_async_main_queue(void (^ _Nullable block)(void)) {
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}
#pragma mark - 打印
#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DLog(...)
#endif

#pragma mark - 单例
#undef    AS_SINGLETON
#define AS_SINGLETON( __class ) \
+ (__class *)sharedInstance;

#undef    DEF_SINGLETON
#define DEF_SINGLETON( __class ) \
+ (__class *)sharedInstance \
{ \
static dispatch_once_t once; \
static __class * __singleton__; \
dispatch_once( &once, ^{ __singleton__ = [[__class alloc] init]; } ); \
return __singleton__; \
}

#pragma mark - 屏幕尺寸(物理尺寸)
//屏幕宽 高
#define DScreenWidth                ([[UIScreen mainScreen] bounds].size.width)
#define DScreenHeight                ([[UIScreen mainScreen] bounds].size.height)
//竖屏(相对于iphoneX标准屏的比例)
//基准比例
#define DStandard_Scale       (DScreenWidth / 375.0)
#define DLStandard_Scale       (DScreenWidth / 812.0)
//竖屏
#define DWScale(W) (W) * DStandard_Scale
//横屏
#define DLWScale(W) (W) * DLStandard_Scale

//状态栏高度
//#define DStatusBarH ([ZDeviceTool isPhone_X] ? 44 : 20) //该方法是已经不适用(iOS14后，刘海屏或者灵动岛状态栏高度不再是44)
#define DStatusBarH ([NoaDeviceTool statusBarHeight])
//导航栏高度
#define DNavBarH 44
//状态栏+导航栏高度
#define DNavStatusBarH (DStatusBarH + DNavBarH)
//TabBar高度
#define DTabBarH ([NoaDeviceTool isPhone_X_New] ? 83 : 49)
//底部刘海高度
#define DHomeBarH ([NoaDeviceTool isPhone_X_New] ? [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom : 0)
//获取系统版本
#define iOS_VERSION ([[[UIDevice currentDevice] systemVersion] floatValue])

#pragma mark - weakSelf
#define WS(weakSelf) __weak __typeof(self) weakSelf = self;

#define Weakify(o) __weak __typeof__((__typeof__(o))o)
#define WeakifySelf(o) Weakify(self) o = self;

#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

#define WeakSelf __weak typeof(self) weakSelf = self;
#define StrongSelf __strong typeof(weakSelf) strongSelf = weakSelf;

#pragma mark - 图片
#define ImgNamed(_pointer) [UIImage imageNamed:_pointer]
#define DefaultAvatar ImgNamed(@"c_avatar_icon") //默认用户头像
#define DefaultImage ImgNamed(@"c_img_bg")  //默认图片
#define DefaultNoImage ImgNamed(@"chat_message_noimage")  //默认裂图片
#define DefaultGroup ImgNamed(@"c_group_icon")  //默认群图片
#define DefaultAccountDelete ImgNamed(@"user_accout_delete_avatar")  //默认注销用户的头像


#pragma mark ----------- 自动化打包 配置项 ----------------
//平台投诉
#define complainBaseurl     @"https://im.net" 
//Logan 日志
#define publishUrlOriginal  @""
//sentry
#define sentryDSNOriginal  @"http://54a47c25e99ef4f30846d810655cc8e7@mysentry.zfawhx.cn/7"
//oss地址后缀(历史打包宏，当前业务不再拼接使用)
#define ossSuffixUrl  @"/lx/%@/navpoint"
// 内置 OSS HTTP 对象完整 URL（企业号占位 %@），对齐 Android basePath / awsUrl
#define ossInnerUrl  @"https://prnav1.oss-accelerate.aliyuncs.com/%@/nvp"
//aws / 海外 OSS 对象完整 URL（企业号占位 %@）
#define awsUrl  @"https://cmnav1.oss-accelerate.aliyuncs.com/%@/nvp"
//主域名
#define normarlHttpDNSDomain    @"ana.pinned.cn"
//副域名
#define spareHttpDNSDomain      @"anas.pinned.cn"
//内置域名(历史打包宏，当前业务不再拼接使用)
#define builtInBucketName       @"lxpoint.oss-cn-hangzhou.aliyuncs.com"
//服务协议地址
#define servicePolicyUrl  @"https://web.cohereweb.xyz/legal/terms.html"
// 隐私协议地址
#define privacyPolicyUrl @"https://web.cohereweb.xyz/legal/privacy.html"

#define httpId       @"161860"
//内置域名
#define httpKeyId       @"161860_28647118757828608"
//服务协议隐私政策地址
#define httpKeySecret  @"509671ca1c05455bb627312e6ae6f740"

//主域名（对齐 Android tcpDnsMainDomain）
#define main_domain    @"nav.ziyouyi.com"
//副域名（对齐 Android tcpDnsBackDomain）
#define back_domain     @"bar.ziyouyi.com"
// 导航主、副域名的竞速流程兼容别名，保留旧宏供网络检测模块使用
#define DirectNormarDomain      main_domain
#define DirectSpareDomain       back_domain
#define DirectInBucketDomain  @""

// 对齐 Android httpAccountId / tcpAccountId（main-kefu）
//#define ali_account_id       @"818331"
//#define ali_key_id       @"818331_32052725523087360"
//#define ali_key_secret  @"d3010412aada424a88f41a77ee771c96"
#define ali_account_id       @"813811"
#define ali_key_id       @"813811_31981838573315072"
#define ali_key_secret  @"a13ac20f9a234344b892edd8dc92ee14"

//对图片视频等文件加解密方式  1.xor加解密 2.aes加解密 3.不加密
#define kEncryptType @"1"

// ✅需要替换
#define DirectDecodeKeyId @"671581_30185023923412521"
// ✅需要替换
#define DirectDecodeKeySecret @"0fc2f1c074fd24b3b13f23243297dc86"
//默认appType app类型 0:公共打包 1:独立打包
#define DefaultAppType  0

// 国内导航保底地址（对齐 Android domesticBakEndpoints，含 GA）
#define kFallbackDomesticUrl @"nav.cgxagz.cn:18087,ga-bp1ejvtbm2atv7ih5glwg.aliyunga0018.com:18087"

// 海外导航保底地址（对齐 Android overseasBakEndpoints，当前为空）
#define kFallbackOverseasUrl @""

#pragma mark - DNS/DoH 常量
// Cloudflare DoH 常量
#define CF_DOH_BASE_URL                 @"https://cloudflare-dns.com/dns-query"
#define cf_test_domain                  @"jndnav.jiguanged.com"
//813811_31981838573315072
//a13ac20f9a234344b892edd8dc92ee14
//262262.facaifacai999.xzy
// 阿里/腾讯 HttpDNS 测试域名常量（可按需替换） ✅需要替换
#define ali_test_domain                 @"262262.facaifacai999.xzy"
//#define ali_test_domain                 @"nav.ziyouyi.com"
#define TENCENT_HTTPDNS_TEST_DOMAIN     @"nav.ziyouyi.com"

// TXT 解密密钥（Ali/CF TXT解密用）
#define txt_decrypt_key            @"aslkdhiwuhdliqsjdh"
// DNS TXT 解密密钥的竞速流程兼容别名
#define Z_DNS_TXT_AES_SECRET        txt_decrypt_key

// 是否允许兜底重试（五源路径禁用，兜底路径启用）的默认宏
#define Z_ALLOW_FALLBACK_RETRY_DEFAULT   NO

#pragma mark - 第三方相关

#pragma mark - APP本身
//设备唯一标识
#define APP_SERVICE      [NSBundle mainBundle].bundleIdentifier
#define APP_ACCOUNT      @""
//渠道
#define APP_CHANNEL      @"App Store"

//App在App Store的地址
#define APP_IN_APPLE_STORE_URL  @"itms-apps://itunes.apple.com/app/id6450179044"

#define L_DevicePushToken       @"DevicePushTokenKey"       //推送token


#define FriendSyncReqList @"FriendSyncReqList"
#define FriendSyncReqTime @"FriendSyncReqTime"
 
//注册/登录方式
#define UserAuthTypeAccount     1       //账号
#define UserAuthTypeEmail       2       //邮箱
#define UserAuthTypePhone       3       //手机号

//异或加密开关 0：不加密 1:加密
//#define EncryptSwitch      1

//群组成员最大值宏定义
#define GroupMemberMaxValue  500
//群组成员最小值值宏定义
#define GroupMemberMinValue  0

/** NSUserDefaults的key */
//多语言设置-当前选择的语言
#define Z_LANGUAGE_SELECTES_TYPE        @"Z_LANGUAGE_SELECTES_TYPE_1.0.11"
//多租户标志
#define Z_OrgName                       @"1595975575091130369"


//tabarItem双击
#define Z_DoubleClickTabItemNotification        @"Z_DoubleClickTabItemNotification"
//接收到消息自动翻译时翻译失败弹窗弹出的时间戳-增加字符
#define Z_CHAT_MESSAGE_AUTO_TRANSLATE_FAIL_TIMESTAMP_ADD   @"Z_CHAT_MESSAGE_AUTO_TRANSLATE_FAIL_TIMESTAMP_ADD"
//接收到消息自动翻译时翻译失败弹窗弹出的时间戳-未绑定
#define Z_CHAT_MESSAGE_AUTO_TRANSLATE_FAIL_TIMESTAMP_UNBIND   @"Z_CHAT_MESSAGE_AUTO_TRANSLATE_FAIL_TIMESTAMP_UNBIND"


//https请求证书密码：IP/域名直连
#define Z_HTTPS_IP_CER_PASSWORD         @"aleim.cc"
//https请求证书密码：邀请码
#define Z_COMPANY_ID_IP_CER_PASSWORD    @"test_app_"    //"test_app_" + ossInfo.getAppKey()


/**文件存储-桶名称 */
/** minio */
//用户头像上传目录(结尾需要斜线)
#define UPLAOD_ZIM_AVATAR           @"/zim/avatar/"
//群组头像保存目录(结尾需要斜线)
#define UPLAOD_ZIM_AVATAR_GROUP     @"/zim/avatar_group/"
//用户背景墙上传目录(结尾需要斜线)
#define UPLAOD_ZIM_BACKGROUP        @"/zim/background/"
/** %@ 代表今天日期，格式：20221022 */
//用户要发送的图片上传目录(结尾需要斜线)
#define UPLAOD_ZIM_MSG_IMAGE        @"/zim/%@/image/"
//用户要发送的语音留言文件转码mp3后的保存目录
#define UPLAOD_ZIM_VOICE_MP3        @"/zim/%@/voice/mp3/"
//短视频文件的上传目录
#define UPLAOD_ZIM_SHORT_VIDEO      @"/zim/%@/shortvideo/"
//第三方文件上传目录
#define UPLAOD_ZIM_THIRDPART_FILE   @"/zim/%@/thirdpart/file/"
//大文件的上传目录(结尾不需要斜线)
#define UPLAOD_ZIM_BIG_FILE         @"/zim/%@/file/"
//表情存放路径
#define UPLAOD_ZIM_STICKERS         @"/zim/%@/stickers/"
//通用文件保存路径
#define UPLAOD_ZIM_UNIVERSAL        @"/zim/universal/"
//小程序保存路径
#define UPLAOD_ZIM_MINIAPP          @"/zim/tag/"

/** aliyun objectKey path */
//用户头像上传目录(结尾需要斜线)
#define UPLAOD_ALIYUN_AVATAR            @"avatar/"
//群组头像保存目录(结尾需要斜线)
#define UPLAOD_ALIYUN_AVATAR_GROUP      @"avatar_group/"
//用户背景墙上传目录(结尾需要斜线)
#define UPLAOD_ALIYUN_BACKGROUP         @"background/"
/** %@ 代表今天日期，格式：20221022 */
//用户要发送的图片上传目录(结尾需要斜线)
#define UPLAOD_ALIYUN_MSG_IMAGE         @"chat/%@/image/"
//用户要发送的语音留言文件转码mp3后的保存目录
#define UPLAOD_ALIYUN_VOICE_MP3         @"chat/%@/voice/mp3/"
//短视频文件的上传目录
#define UPLAOD_ALIYUN_SHORT_VIDEO       @"chat/%@/shortvideo/"
//第三方文件上传目录
#define UPLAOD_ALIYUN_THIRDPART_FILE    @"chat/%@/thirdpart/file/"
//大文件的上传目录(结尾不需要斜线)
#define UPLAOD_ALIYUN_BIG_FILE          @"chat/%@/file/"
//表情存放路径
#define UPLAOD_ALIYUN_STICKERS          @"chat/%@/stickers/"
//通用文件保存路径
#define UPLAOD_ALIYUN_UNIVERSAL         @"universal/"
//小程序保存路径
#define UPLAOD_ALIYUN_MINIAPP           @"tag/"

/** AWS S3 objectKey path */
//用户头像上传目录(结尾需要斜线)
#define UPLAOD_AWS_AVATAR               @"avatar/"
//群组头像保存目录(结尾需要斜线)
#define UPLAOD_AWS_AVATAR_GROUP         @"avatar_group/"
//用户背景墙上传目录(结尾需要斜线)
#define UPLAOD_AWS_BACKGROUP            @"background/"
/** %@ 代表今天日期，格式：20221022 */
//用户要发送的图片上传目录(结尾需要斜线)
#define UPLAOD_AWS_MSG_IMAGE            @"chat/%@/image/"
//用户要发送的语音留言文件转码mp3后的保存目录
#define UPLAOD_AWS_VOICE_MP3            @"chat/%@/voice/mp3/"
//短视频文件的上传目录
#define UPLAOD_AWS_SHORT_VIDEO          @"chat/%@/shortvideo/"
//第三方文件上传目录
#define UPLAOD_AWS_THIRDPART_FILE       @"chat/%@/thirdpart/file/"
//大文件的上传目录(结尾不需要斜线)
#define UPLAOD_AWS_BIG_FILE             @"chat/%@/file/"
//表情存放路径
#define UPLAOD_AWS_STICKERS             @"chat/%@/stickers/"
//通用文件保存路径
#define UPLAOD_AWS_UNIVERSAL            @"universal/"
//小程序保存路径
#define UPLAOD_AWS_MINIAPP              @"tag/"


//腾讯云存储COS的AppID
#define TENCENT_COS_APP_ID              @"1328550387"
/** 腾讯云 objectKey path */
//用户头像上传目录(结尾需要斜线)
#define UPLAOD_TENCENT_AVATAR           @"avatar/"
//群组头像保存目录(结尾需要斜线)
#define UPLAOD_TENCENT_AVATAR_GROUP     @"avatar_group/"
//用户背景墙上传目录(结尾需要斜线)
#define UPLAOD_TENCENT_BACKGROUP        @"background/"
/** %@ 代表今天日期，格式：20221022 */
//用户要发送的图片上传目录(结尾需要斜线)
#define UPLAOD_TENCENT_MSG_IMAGE        @"chat/%@/image/"
//用户要发送的语音留言文件转码mp3后的保存目录
#define UPLAOD_TENCENT_VOICE_MP3        @"chat/%@/voice/mp3/"
//短视频文件的上传目录
#define UPLAOD_TENCENT_SHORT_VIDEO      @"chat/%@/shortvideo/"
//第三方文件上传目录
#define UPLAOD_TENCENT_THIRDPART_FILE   @"chat/%@/thirdpart/file/"
//大文件的上传目录(结尾不需要斜线)
#define UPLAOD_TENCENT_BIG_FILE         @"chat/%@/file/"
//表情存放路径
#define UPLAOD_TENCENT_STICKERS         @"chat/%@/stickers/"
//通用文件保存路径
#define UPLAOD_TENCENT_UNIVERSAL        @"universal/"
//小程序保存路径
#define UPLAOD_TENCENT_MINIAPP          @"tag/"

/** 华为云 objectKey path */
//用户头像上传目录(结尾需要斜线)
#define UPLAOD_HUAWEIOBS_AVATAR           @"avatar/"
//群组头像保存目录(结尾需要斜线)
#define UPLAOD_HUAWEIOBS_AVATAR_GROUP     @"avatar_group/"
//用户背景墙上传目录(结尾需要斜线)
#define UPLAOD_HUAWEIOBS_BACKGROUP        @"background/"
/** %@ 代表今天日期，格式：20221022 */
//用户要发送的图片上传目录(结尾需要斜线)
#define UPLAOD_HUAWEIOBS_MSG_IMAGE        @"chat/%@/image/"
//用户要发送的语音留言文件转码mp3后的保存目录
#define UPLAOD_HUAWEIOBS_VOICE_MP3        @"chat/%@/voice/mp3/"
//短视频文件的上传目录
#define UPLAOD_HUAWEIOBS_SHORT_VIDEO      @"chat/%@/shortvideo/"
//第三方文件上传目录
#define UPLAOD_HUAWEIOBS_THIRDPART_FILE   @"chat/%@/thirdpart/file/"
//大文件的上传目录(结尾不需要斜线)
#define UPLAOD_HUAWEIOBS_BIG_FILE         @"chat/%@/file/"
//表情存放路径
#define UPLAOD_HUAWEIOBS_STICKERS         @"chat/%@/stickers/"
//通用文件保存路径
#define UPLAOD_HUAWEIOBS_UNIVERSAL        @"universal/"
//小程序保存路径
#define UPLAOD_HUAWEIOBS_MINIAPP          @"tag/"

#define HTTP_PROXY_KEY     @"httpProxyKey"
#define SOCKS_PROXY_KEY     @"socksProxyKey"
#define PROXY_CURRENT_TYPE @"proxyCurrentType"


#define LOCAL_OSS_ALIYUN_DOMAIN_KEY     @"localAliyunOssDomainKey"
#define PROXY_LICESEID  @""

#define OSS_LOCAL_CACHE @"ssoModelCacheLocal"
#define CONNECT_LOCAL_CACHE @"connectCache"


#ifdef DEBUG
#define DDLog(fmt, ...) LLog([NSString stringWithFormat: fmt, ##__VA_ARGS__]);
#else
#define DDLog(fmt, ...)
#endif



#endif /* ZMacroHeader_h */



//# 导航 / HttpDNS / TCP / 内置企业号 — 单一配置源（开发维护）
//# 打包时由 scripts/lib/inject_nav_config.py 注入：
//#   - Android：merge 进 gradle.properties
//#   - iOS：merge 进 ZMacroHeader.h；企业号改 BuiltIn 资源 / 是否允许手输
//# 无需改 Android / iOS 业务代码。
//
//customer: shanhaixin
//
//enterprise:
//  # false（默认）= 不打内置企业号：
//  #   Android → openSSO=true（手输）+ 清空列表（避免空选择框）
//  #   iOS → 清空 Domestic/Overseas 列表 + 允许手输
//  # true = 按下方字段打内置企业号
//  enabled: false
//  # 仅 enabled=true 时生效。Android：true=手输节点；false=用下方内置列表
//  open_sso: false
//  # 仅 enabled=true 时生效。iOS：0=禁止手输；1=允许
//  allow_input: 0
//  # 仅 enabled=true：国内 / 海外内置企业号，逗号分隔，例: "1001,1002"
//  domestic: ""
//  overseas: ""
//  # 仅 enabled=true。Android：内部单企业号（有值可直接拉导航）
//  inner: ""
//
//oss:
//  # iOS/Android 内置 OSS HTTP 对象模板（企业号占位）
//  # Android: basePath / awsUrl ；iOS: ossInnerUrl / awsUrl
//  # 例: "https://prnav1.oss-accelerate.aliyuncs.com/%s/nvp"
//  inner_url: "https://prnav1.oss-accelerate.aliyuncs.com/%s/nvp"
//  aws_url: "https://cmnav1.oss-accelerate.aliyuncs.com/%s/nvp"
//  # 历史字段（桶名+suffix 拼接）已废弃，保留仅兼容旧打包脚本
//  suffix_url: "/lx/%@/navpoint"
//  buckets: "lxpoint.oss-cn-hangzhou.aliyuncs.com"
//
//httpdns:  # 对齐 Android main-kefu
//  ali_test_domain: "nav.ziyouyi.com"
//  cf_test_domain: "jndnav.jiguanged.com"
//  tencent_test_domain: "nav.ziyouyi.com"
//  ali_account_id: "818331"
//  ali_key_id: "818331_32052725523087360"
//  ali_key_secret: "d3010412aada424a88f41a77ee771c96"
//  txt_decrypt_key: "aslkdhiwuhdliqsjdh"
//
//tcp:  # 对齐 Android tcpDns* / tcpAccount*
//  account_id: "818331"
//  key_id: "818331_32052725523087360"
//  key_secret: "d3010412aada424a88f41a77ee771c96"
//  main_domain: "nav.ziyouyi.com"
//  back_domain: "bar.ziyouyi.com"
//  inner_url: ""
//  # 对应 Android tcpNavEncryptKeyPrefix/Suffix、iOS DirectDecodeKey*
//  encrypt_key_prefix: "671581_30185023923412521"
//  encrypt_key_suffix: "0fc2f1c074fd24b3b13f23243297dc86"
//
//fallback:  # 对齐 Android domesticBakEndpoints / overseasBakEndpoints
//  domestic: "nav.cgxagz.cn:18087,ga-bp1ejvtbm2atv7ih5glwg.aliyunga0018.com:18087"
//  overseas: ""
