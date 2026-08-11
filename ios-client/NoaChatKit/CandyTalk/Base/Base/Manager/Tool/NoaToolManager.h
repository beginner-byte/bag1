//
//  NoaToolManager.h
//  NoaKit
//
//  Created by Candy on 2026/9/13.
//

// 工具类单例
#define ZTOOL [NoaToolManager shareManager]

#pragma mark - 当前VC
#define CurrentVC [[NoaToolManager shareManager] getCurrentVC]

#pragma mark - 当前Window
#define CurrentWindow [[NoaToolManager shareManager] getCurrentWindow]

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaToolManager : NSObject

@property (nonatomic, strong) NSDictionary *pushUserInfo;

@property (nonatomic, copy) NSString *publicIP;

#pragma mark - 单例的实现
+ (instancetype)shareManager;
// 单例一般不需要清空，但是在执行某些功能的时候，防止数据清空不及时可以清空一下
- (void)clearManager;


#pragma mark - >>>>>>工具类方法<<<<<<
// 获取当前屏幕显示的UIViewController
- (UIViewController *)getCurrentVC;

/// 获取App 名称 不进行转义
- (NSString *)appName;

// 获取当前的Window
- (UIWindow *)getCurrentWindow;

// 获取当前App名称
- (NSString *)getAppName;

// 获取当前App版本号
- (NSString *)getCurretnVersion;

// 获取当前App Build号
- (NSString *)getBuildVersion;

// 获取当前App版本号和Build号拼接到一块 1.0.3 20230517
- (NSString *)getCurretnVersionAndBuild;

//刷新聊天和会话列表也没
//- (void)reloadChatAndSessionVC;

#pragma mark - 设置tabBar
- (void)setupTabBarUI;

/// 将完整 Worker Flutter 主界面设置为登录后的根控制器。
- (void)setupWorkerUI;

#pragma mark - 设置登录界面
- (void)setupLoginUI;

#pragma mark - 设置竞速失败界面
- (void)setupRacingErroUIWithResutl:(NSDictionary *)dic;

#pragma mark - 设置邀请码填写界面
- (void)setupSsoSetVcUI;

#pragma mark - 弹窗-跳转登录界面
- (void)setupAlertToLoginUI;

#pragma mark - 跳转 服务协议
- (void)setupServeAgreement;

#pragma mark - 跳转 隐私政策
- (void)setupPrivePolicy;

#pragma mark - 账号信息发生变化，请重新登录
- (void)setupUserInfoChangeAlert;

#pragma mark - 弹窗-强制下线(登录、注册、刷新token接口返回对应错误，提示：账号封禁、IP封禁、设备封禁)
- (void)setupAlertUserBannedUIWithErrorCode:(NSInteger)errorCode withContent:(NSString *)content loginType:(NSInteger)loginType;

#pragma mark - 线程操作
- (void)doInBackground:(void(^)(void))block;
- (void)doInMain:(void(^)(void))block;
- (void)doAsync:(void(^)(void))block completion:(void(^)(void))completion;

#pragma mark - 检测相册权限
- (void)checkAlbumAuthStatus:(void(^)(BOOL authOk))completion;

#pragma mark - 图片保存到相册
- (void)saveImageToAlbumWith:(NSString *)imageUrl Cusotm:(NSString *)customPath;

#pragma mark - 视频下载缓存到本地
- (void)downloadVideoWith:(NSString *)videoUrl completion:(void(^)(BOOL success, NSString * _Nonnull videoPath))completion;

#pragma mark - 视频保存到相册
- (void)saveVideoToAlbumWith:(NSString *)videoPath;

#pragma mark - 视频缓存地址
- (NSString *)getVideoCachePath;

#pragma mark - 视频是否缓存在本地
/// 视频是否缓存在本地(返回视频的本地地址)
/// @param videoUrl 视频网络地址
- (NSString *)videoExistsWith:(NSString *)videoUrl;
#pragma mark - 异步缓存视频

#pragma mark - 检查url的host是否为ip 返回YES位Ip，返回NO位域名
- (BOOL)checkUrlStrIsIP:(NSString *)urlStr;

#pragma mark - 系统权限检测与获取
//检测是否有麦克风权限
- (BOOL)checkMicrophoneState;
//获取麦克风权限
- (void)getMicrophoneAuth:(void (^)(BOOL granted))complete;
//检测是否有相机权限
- (BOOL)checkCameraState;
//获取相机权限
- (void)getCameraAuth:(void (^)(BOOL granted))complete;
//检测是否有相册权限
- (BOOL)checkPhotoLibraryState;
//获取相册权限
- (void)getPhotoLibraryAuth:(void (^)(BOOL granted))complete;

//跳转到AppStore
- (void)goAppStore;

//会话列表-文件助手-本地化语言更新
- (void)sessionFileHelperLanguageUpdate;

//会话列表-签到提醒-本地化语言更新
- (void)sessionSignInRemainderLanguageUpdate;

//通讯录-文件助手-本地化语言更新
- (void)connectFileHelperLanguageUpdate;

//RTL 布局 设置
-(void)RTLConfig;
//获取RTP布局的NSTextAlignment
-(NSTextAlignment)RTLTextAlignment:(NSTextAlignment)textAlignment;

//获取当前代理类型
- (ProxyType)getCurrentProxyType;

#pragma mark - 是否有网络
- (BOOL)isNetworkAvailable;

- (void)sentryUploadWithDictionary:(NSDictionary *)dictionary sentryUploadType:(ZSentryUploadType)sentryUploadType errorCode:(NSString *)errorCode;
- (void)sentryUploadWithString:(NSString *)string sentryUploadType:(ZSentryUploadType)sentryUploadType errorCode:(NSString *)errorCode;
//获取当前公网IP地址
- (void)getDevicePublicNetworkIPWithCompletion:(void(^)(NSString *ip))completion;
// 公网IP区域判断（简易版）
- (BOOL)isDomestic;



#pragma mark - Logan publish URL 管理
/// 读取当前生效的 publishUrlOriginal（优先持久化，其次默认值）
- (NSString *)loganEffectivePublishURL;
/// 设置并持久化 publishUrlOriginal
- (void)setPersistedLoganPublishURL:(NSString *)urlString;
/// 获取已持久化的 publishUrlOriginal（可能为空）
- (NSString *)getPersistedLoganPublishURL;
/// 若新URL与当前不同，则更新持久化并重载 Logan；记录切换事件
- (void)reloadLoganIfNeededWithPublishURL:(NSString *)newURL;
//Rtl 字符串处理
BOOL isRTLString(NSString *string);

NSAttributedString *RTLAttributeString(NSAttributedString *attributeString );



@end

NS_ASSUME_NONNULL_END
