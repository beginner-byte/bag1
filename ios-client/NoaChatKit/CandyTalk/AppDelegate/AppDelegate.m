//
//  AppDelegate.m
//  NoaKit
//
//  Created by Apple on 2026/8/9.
// 

#import "AppDelegate.h"
#import "NoaToolManager.h"
#import "AppDelegate+Tabbar.h"
#import "AppDelegate+DB.h"
#import "AppDelegate+ThirdSDK.h"
#import "AppDelegate+Push.h"
#import "AppDelegate+GestureLock.h"
#import "AppDelegate+MediaCall.h"//视频
#import "AppDelegate+MiniApp.h"//小程序
#import "CandyLaunchViewController.h"
#import "NoaPushNavTools.h"   //推送消息点击后跳转处理
#import <SDWebImageSVGCoder/SDWebImageSVGCoder.h>
#import <SDWebImageWebPCoder/SDWebImageWebPCoder.h>
#import "BAWebImageDownloaderDecryptor.h"

// iOS10 注册 APNs 所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

// 是否记录本地日志 0-不记录、1-记录
#define kIsSaveLocalLog 0

#import <AvoidCrash.h>
#import "NoaImageLoader.h"

static NSString * const kLastAppVersionKey = @"LastAppVersion";

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, assign) BOOL appInited;//app是否是杀死进程后首次执行

@end

@implementation AppDelegate
- (void)dealwithCrashMessage:(NSNotification *)note {
    //注意:所有的信息都在userInfo中
    //你可以在这里收集相应的崩溃信息进行相应的处理(比如传到自己服务器)
    DLog(@"dealwithCrashMessage>>>>%@",note.userInfo);
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    // 配置文件加解密方式
    if ([kEncryptType isEqualToString:@"1"]) {
        // xor加解密
        [EncryptManager shareEncryManager].encryptType = EncryptDataTypeXOR;
    }else if ([kEncryptType isEqualToString:@"2"]) {
        // aes加解密
        [EncryptManager shareEncryManager].encryptType = EncryptDataTypeAES;
    }else {
        // 不处理加解密
        [EncryptManager shareEncryManager].encryptType = EncryptDataTypeNOT;
    }
    
    // 配置本地日志记录
    [self configureLocalLog];
    
    
    // 使用持久化或默认 DSN 初始化 Sentry
    
    [SDImageCache sharedImageCache].config.maxDiskAge = 7 * 24 * 3600;
    [SDImageCache sharedImageCache].config.maxMemoryCost = 1024 * 1024 * 900;
    [SDImageCache sharedImageCache].config.maxMemoryCount = 1500;
    
    // 开始监听网络连接
    [[NetWorkStatusManager shared] startMonitoring];
    
    // 自定义解码器
    SDWebImageDownloader.sharedDownloader.decryptor = [BAWebImageDownloaderDecryptor decodeDecryptor];
    [self clearAllSandboxCache];
    [self checkAndClearCacheIfNeeded];
    
    // 全局图片策略（缩略解码/首帧/缓存上限/并发限制）
    [NoaImageLoader configureGlobalImagePolicies];
    
    CandyLaunchViewController * launchViewController = [[CandyLaunchViewController alloc] init];
    ((AppDelegate *)[UIApplication sharedApplication].delegate).window.rootViewController = launchViewController;
    
    //防止崩溃
    [AvoidCrash becomeEffective];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealwithCrashMessage:) name:AvoidCrashNotification object:nil];
    // 竞速之前配置日志模块(App启动即配置日志模块)：使用持久化或默认 publishUrlOriginal
    NSString *loganURL = [ZTOOL loganEffectivePublishURL];
    [ZTOOL reloadLoganIfNeededWithPublishURL:loganURL];
    
    
    //SDWebImage配置
    [self imageConfigure];
    
    //第三方SDK初始化、配置
    [self configThirdSDK];
    
    //节点竞速/IP、Domain直连
    [self startNodeRacing];
    
    //多语言设置初始化
    [ZLanguageTOOL initLanguageSetting];
    
    //更新我的信息
    [self requestMineInfo];
    
    //配置键盘等
    [self setupConfig];
    
    [self globalAdaptationScrollView];
    
    //数据库，用户相关配置(SDK配置)
    [self configDB];
    //音视频相关配置
    [self configMediaCall];
    
    //推送
    [self notification:application];
    
    [self.window makeKeyAndVisible];
    self.window.backgroundColor = UIColor.whiteColor;
    //[[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
    
    
    // 同步全局翻译开关到SDK（默认开启，按用户权限开关覆盖）
    [IMSDKManager toolSetGlobalTranslateEnabled:[UserManager isTranslateEnabled]];
    // 监听翻译开关变化，实时更新SDK持久化值
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTranslateFlagChanged) name:UserRoleAuthorityTranslateFlagDidChange object:nil];
    
    return YES;
}

- (void)configureLocalLog {
    BOOL res = [NoaLocalLogger setUp];
    if (kIsSaveLocalLog && res) {
        [NoaLocalLogger setLoggingEnabled:YES];
    }else {
        [NoaLocalLogger setLoggingEnabled:NO];
    }
}

-(void)imageConfigure{
    //图片支持SVG
    SDImageSVGCoder *svgCoder = [SDImageSVGCoder sharedCoder];
    [[SDImageCodersManager sharedManager] addCoder:svgCoder];
    //图片支持WebP
    SDImageWebPCoder *webPCoder = [SDImageWebPCoder sharedCoder];
    [[SDImageCodersManager sharedManager] addCoder:webPCoder];
    //图片支持GIF
    Class gifCoderCls = NSClassFromString(@"SDImageGIFCoder");
    if (gifCoderCls && [[gifCoderCls class] respondsToSelector:@selector(sharedCoder)]) {
        id gifCoder = [gifCoderCls performSelector:@selector(sharedCoder)];
        if (gifCoder) {
            [[SDImageCodersManager sharedManager] addCoder:gifCoder];
        }
    }
}

#pragma mark - 登录成功处理
- (void)loginSuccess {
    [HUD showSuccessMessage:@"configDB"];
    [self configDB];
    [self configMediaCall];
//    [HUD showSuccessMessage:@"loganEffectivePublishURL"];
    //日志模块(登录后更新日志模块用户信息)
    NSString *loganURL = [ZTOOL loganEffectivePublishURL];
    [ZTOOL reloadLoganIfNeededWithPublishURL:loganURL];
//    [HUD showSuccessMessage:@"setupTabBarUI"];
    //小程序(在创建tabbar之后)
    @weakify(self)
    [ZTOOL doInMain:^{
        @strongify(self)
        [ZTOOL setupWorkerUI];
        [self checkMiniAppFloatShow];
    }];
}

#pragma mark - 注册成功处理
- (void)registerSuccess {
    [self loginSuccess];
    //用户注册成功后调用
    [self openInstallReportRegister];
}

#pragma mark - Translate Flag Bridge
- (void)onTranslateFlagChanged {
    [IMSDKManager toolSetGlobalTranslateEnabled:[UserManager isTranslateEnabled]];
}

//是否采用节点择优策略
- (void)startNodeRacing {
    dispatch_async(dispatch_queue_create("com.nodeRacing", DISPATCH_QUEUE_CONCURRENT), ^{
        ZHostTool.isReloadRacing = YES;
        NoaSsoInfoModel *ssoModel = [NoaSsoInfoModel getSSOInfo];
        ssoModel.liceseId = ssoModel.lastLiceseId;
        ssoModel.ipDomainPortStr = ssoModel.lastIPDomainPortStr;
        [ssoModel saveSSOInfo];
        [ZHostTool startHostNodeRace];
    });
}

-(void)setupConfig{
    //键盘处理
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    //设置主题(YES:跟随系统，NO：自定义主题颜色或图标)
    [self changeThemeConfigFollowSystem:YES];
}
#pragma mark - 程序加载完毕，在其他组件含有UI元素前，优先设置，主题作用全局的UI
- (void)changeThemeConfigFollowSystem:(BOOL)followSystem {
    if (followSystem) {
        //设置为YES，themeIndex便失去作用，跟随系统变更(浅色模式、暗黑模式)
        [TKThemeManager config].followSystemTheme = YES;
    } else {
        //设置为NO，themeIndex起作用，themeIndex表示主题的编号，每一套主题应该都有一套独立的颜色或者图标
        [TKThemeManager config].followSystemTheme = NO;
        [TKThemeManager config].themeIndex = 0;
    }
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleThemeChanged:) name:@"TKThemeOnTraitChanged" object: nil];
}

//- (void)handleThemeChanged: (NSNotification *)noti {
//    NSDictionary *userinfo = noti.userInfo;
//    if (userinfo) {
//        NSString *source = [userinfo objectForKeySafe:@"source"];
//        NSString *currentIsDark = [[userinfo objectForKeySafe:@"previousIsDark"] intValue] == 0 ? @"YES" : @"NO";
//        DDLog(@"Theme changed: source-%@, isDark-%@", source, currentIsDark);
//    }
//}

- (AVAudioPlayer *)player {
    
    if (!_player) {
        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"4500_f066d289ecbedfb2c8b75b6d094fa1b6" withExtension:@"amr"];
        AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        audioPlayer.numberOfLoops = NSUIntegerMax;
        _player = audioPlayer;
    }
    return _player;
}
#pragma mark - 全局适配iOS11的滑动界面
- (void)globalAdaptationScrollView{
    // 适配iOS11以上UITableview 、UICollectionView、UIScrollview 列表/页面偏移
    if (@available(iOS 11.0, *)){
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        [[UITableView appearance] setEstimatedRowHeight:0];
        [[UITableView appearance] setEstimatedSectionFooterHeight:0];
        [[UITableView appearance] setEstimatedSectionHeaderHeight:0];
    }
}
#pragma mark - 程序将要进入非活跃状态，即将进入后台
- (void)applicationWillResignActive:(UIApplication *)application {
    //系统权限弹窗会触发此方法
    //不会触发applicationDidEnterBackground
}

#pragma mark - 程序已经进入后台(如果支持后台运行，则已经进入后台运行)
- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"backTask" expirationHandler:^{
        [self.player play];
       
       if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
           [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
           self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
       }
    }];
    
}
#pragma mark - 程序将要进入活跃状态，即将进入前台
- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self.player pause];
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
    
    //设置SDK需要的 token、userID、api地址、socket地址
    //[[LingIMSDKManager sharedTool] login:UserManager.userInfo.userUID userToken:UserManager.userInfo.token];
    NoaIMSDKUserOptions *userOption = [NoaIMSDKUserOptions new];
    userOption.userID = UserManager.userInfo.userUID;
    userOption.userToken = UserManager.userInfo.token;
    userOption.userNickname = UserManager.userInfo.nickname;
    userOption.userAvatar = UserManager.userInfo.avatar;
    [IMSDKManager configSDKUserWith:userOption];
    
    
    //手势锁
    [self checkUserGestureLock];
}
#pragma mark - 程序进入前台，处于活跃状态
- (void)applicationDidBecomeActive:(UIApplication *)application {
    //系统权限弹窗会触发此方法
    //系统权限弹窗不会触发applicationWillEnterForeground方法
    
    //程序杀死后启动会触发此方法，不会触发applicationWillEnterForeground方法
    /**
     * 注释原因:启动先出现解锁页面，然后setTabbar展示正常UI，然后又会出现解锁画面，造成现象就是解锁页面闪烁，影像体验，故注释
     if (!_appInited) {
     //手势锁
     [self checkUserGestureLock];
     }
     */
    _appInited = YES;
}

#pragma mark - 获取权限并申请device token
- (void)notification:(UIApplication *)application{
    if (@available(iOS 10.0, *)) {
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            switch ([settings authorizationStatus]) {
                case UNAuthorizationStatusAuthorized:
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[UIApplication sharedApplication] registerForRemoteNotifications];
                    });
                    break;
                case UNAuthorizationStatusNotDetermined:
                    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                        if (granted) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[UIApplication sharedApplication] registerForRemoteNotifications];
                            });
                        }
                    }];
                    break;
                default:
                    break;
            }
        }];
        // 注册获得device Token
    }
}

#pragma mark - 远程推送注册成功！
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    if (![deviceToken isKindOfClass:[NSData class]]) return;
    
    NSString *hexToken = @"";
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 13) {
        const unsigned *tokenBytes = (const unsigned *)[deviceToken bytes];
        hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                              ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                              ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                              ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    } else {
        hexToken = [NSString stringWithFormat:@"%@",deviceToken];
        hexToken = [hexToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
        hexToken = [hexToken stringByReplacingOccurrencesOfString:@">" withString:@""];
        hexToken = [hexToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    DLog(@"deviceToken1:%@", hexToken);
    [[MMKV defaultMMKV] setString:hexToken forKey:L_DevicePushToken];
}
#pragma mark -注册失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    DLog(@"注册失败 ---- %@",error);
}
#pragma mark -收到推送
//ios8 - ios10
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    //App未启动时-点击推送消息
    NSString *userInfoStr = [NSString stringWithFormat:@"前台台活跃-点击推送:%@", userInfo];
    DLog(@"收到推送：%@", userInfoStr);
    if (UserManager.isLogined) {
        ZTOOL.pushUserInfo = userInfo;
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark -点击推送
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    if (@available(iOS 10.0, *)) {
        NSDictionary *userInfo = response.notification.request.content.userInfo;
        //App-后台活跃-点击推送消息
        [NoaPushNavTools pushMessageClickToNavWithInfo:userInfo];
    }
    
    completionHandler();
}

#pragma mark - 发送本地Push通知的方法
// 推关一条本地Push通知（作用相当于Android系统里的Notification）。
- (void)showLocalPush:(NSString *)title body:(NSString *)body userInfo:(NSDictionary *)userInfo withIdentifier:(NSString *)ident playSoud:(BOOL)sound soundName:(NSString *)soundName
{
    
    if([NSString isNil:body]){
        return;
    }
    if([NSString isNil:title]){
        return;
    }
    //--------------------------------- ios10及以上系统的本地通知实现代码
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;

    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = title;
    content.body = [NSString stringWithFormat:@"%@", body];
    content.userInfo = userInfo;
    // 只有在声音模式打开时才会真正的给个系统提示（否则会有系统震动、声音等），否则无法实现真正的静音哦！
    if(sound) {
        if ([soundName isKindOfClass:[NSString class]] && soundName.length > 0) {
            content.sound = [UNNotificationSound soundNamed:soundName];
        } else {
            content.sound = [UNNotificationSound defaultSound];
        }
    }
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:ident content:content trigger:nil];
    // 发出通知
    [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
        DLog(@"【PUSH - ios>=10】已成功发出《本地》通知(title=%@,body=%@,ident=%@)。", title, body, ident);
    }];
    /*
    //获取当前App的BdgeNumber
    NSInteger appBdgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber;
    appBdgeNumber += 1;
    //重新设置App的BdgeNumber
    [UIApplication sharedApplication].applicationIconBadgeNumber = appBdgeNumber;
    */
    #endif
    
    #if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_10_0
    // 1.创建通知
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    // 设置通知显示的内容
    localNotification.alertBody = [NSString stringWithFormat:@"%@", body];
    localNotification.userInfo = userInfo;
    // 设置通知的发送时间,单位秒
    // localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:10];
    //解锁滑动时的事件
    localNotification.alertAction = [K_LanguageManager matchLocalLanguage:@"滑动打开应用"];
    // 收到通知时App icon的未读数角标
    localNotification.applicationIconBadgeNumber = 1;

    // 只有在声音模式打开时才会真正的给个系统提示（否则会有系统震动、声音等），否则无法实现真正的静音哦！
    if(sound && [UserDefaultsToolKits isAPPMsgToneOpen])
    {
        //推送是带的声音提醒，设置默认的字段为UILocalNotificationDefaultSoundName
        if ([soundName isKindOfClass:[NSString class]] && soundName.length > 0) {
            localNotification.soundName = soundName;
        } else {
            localNotification.soundName = UILocalNotificationDefaultSoundName;
        }
        
    }
    // 3.发送通知(? : 根据项目需要使用)
    // 方式一: 根据通知的发送时间(fireDate)发送通知
    // [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    // 方式二: 立即发送通知
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    #endif
}

#pragma mark - 更新用户信息
//获取用户信息
- (void)requestMineInfo {
    if (UserManager.isLogined) {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
        [IMSDKManager getUserInfoWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *userDict = (NSDictionary *)data;
                NoaUserModel *tempMineModel = [NoaUserModel mj_objectWithKeyValues:userDict];
                UserManager.userInfo.avatar = tempMineModel.avatar;
                UserManager.userInfo.nickname = tempMineModel.nickname;
                UserManager.userInfo.userName = tempMineModel.userName;
                UserManager.userInfo.userSex = tempMineModel.userSex;
                [UserManager setUserInfo:UserManager.userInfo];
                //告知UI用户的信息更新了
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MineUserInfoUpdate" object:nil];
                
            }
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            DLog(@"获取用户信息失败");
        }];
        
    }
}

-(void)clearAllSandboxCache{
    NSString * version = [[MMKV defaultMMKV] getStringForKey:@"ClearAllScanboxCache"];
    if(version == nil || version.length == 0){
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        // 获取 Documents 目录中的所有文件和文件夹
        NSError *error;
        NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentPath error:&error];
        if (error) {
            NSLog(@"Failed to list contents of Documents directory: %@", [error localizedDescription]);
        }
        // 遍历并删除 Documents 目录中的所有文件和文件夹
        for (NSString *item in contents) {
            if([item isEqualToString:@"mmkv"]){
                break;
            }
            NSString *fullPath = [documentPath stringByAppendingPathComponent:item];
            BOOL success = [fileManager removeItemAtPath:fullPath error:&error];
            if (!success) {
                NSLog(@"Failed to delete item at path %@: %@", fullPath, [error localizedDescription]);
            }
        }

        //清空 NSUserDefaults
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        [[MMKV defaultMMKV] setString:@"1.4.0" forKey:@"ClearAllScanboxCache"];;

    }
}

- (void)checkAndClearCacheIfNeeded {
    // 1. 读取当前版本号
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    // 2. 读取上次存储的版本号
    NSString *lastVersion = [[NSUserDefaults standardUserDefaults] stringForKey:kLastAppVersionKey];

    if (!lastVersion || ![lastVersion isEqualToString:currentVersion]) {
        // 确认是“首次安装”或“新版本升级”
        [self clearAppCache];
        // 更新存储的版本号
        [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:kLastAppVersionKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)clearAppCache {
    NoaSsoInfoModel *ssoInfoModel = [NoaSsoInfoModel getSSOInfo];
    [[MMKV defaultMMKV] removeValueForKey:[NSString stringWithFormat:@"%@%@",CONNECT_LOCAL_CACHE,ssoInfoModel.liceseId]];
    [NoaSsoInfoModel clearSSOInfoWithLiceseId:ssoInfoModel.liceseId];
}

@end
