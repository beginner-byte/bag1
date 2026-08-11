//
//  NoaToolManager.m
//  NoaKit
//
//  Created by Candy on 2026/9/13.
//

#import "NoaToolManager.h"
#import <AFNetworking/AFNetworking.h>
#import "AppDelegate.h"
#import "CandyTabBarController.h"
#import "NoaNavigationController.h"
#import "NoaChatKit-Swift.h"
#import "NoaAppStartErrorDefaultViewController.h"
#import "NoaBaseWebViewController.h"
#import "NoaKnownTipView.h"
#import "CandyTabBarController.h"
#import "NoaChatViewController.h"
#import "CandyTalkHomeViewController.h"
#import "NoaMessageModel.h"
#import "NoaAuthBannedAlertView.h"
#import <Photos/Photos.h>

#import "AppDelegate+GestureLock.h"

static dispatch_once_t onceToken;

@implementation NoaToolManager
#pragma mark - Sentry DSN 管理


static NSString *const kLoganPublishURLKey = @"ZIM_Logan_PublishURL";
static NSString *const kLoganDefaultPublishURL = publishUrlOriginal; // 默认取宏定义
static NSString *g_CurrentLoganPublishURL = nil; // 内存记录当前 Logan publish URL


#pragma mark - Lazy
- (NSDictionary *)pushUserInfo {
    if (!_pushUserInfo) {
        _pushUserInfo = [[NSDictionary alloc] init];
    }
    return _pushUserInfo;
}

#pragma mark - 单例的实现
+ (instancetype)shareManager{
    static NoaToolManager *_manager = nil;
    dispatch_once(&onceToken, ^{
        //不能再使用alloc方法
        //因为已经重写了allocWithZone方法，所以这里要调用父类的分配空间的方法
        _manager = [[super allocWithZone:NULL] init];
        _manager.publicIP = [NSString getDevicePublicNetworkIP];
    });
    return _manager;
}
// 防止外部调用alloc 或者 new
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [NoaToolManager shareManager];
}

// 防止外部调用copy
- (id)copyWithZone:(nullable NSZone *)zone {
    return [NoaToolManager shareManager];
}

// 防止外部调用mutableCopy
- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [NoaToolManager shareManager];
}
#pragma mark - 单例一般不需要清空，但是在执行某些功能的时候，防止数据清空不及时可以清空一下
- (void)clearManager{
    onceToken = 0;
}

- (NSString *)appName {
    // 品牌名称跟随 App 内语言设置，从对应的 Localizable.strings 获取。
    return LanguageToolMatch(@"Cohere");
}

#pragma mark - 获取当前App名称
- (NSString *)getAppName {
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [infoDic objectForKey:@"CFBundleDisplayName"];
    return LanguageToolMatch(appName);
}

#pragma mark - 获取当前App版本号
- (NSString *)getCurretnVersion {
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersionNum = [infoDic objectForKey:@"CFBundleShortVersionString"];
    return appVersionNum;
}

#pragma mark - 获取当前App Build号
- (NSString *)getBuildVersion {
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *buildNum = [infoDic objectForKey:@"CFBundleVersion"];
    return buildNum;
}

#pragma mark - 获取当前App版本号和Build号拼接到一块 1.0.3 20230517
- (NSString *)getCurretnVersionAndBuild {
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersionNum = [infoDic objectForKey:@"CFBundleShortVersionString"];
    NSString *buildNum = [infoDic objectForKey:@"CFBundleVersion"];
     
    NSString *versionBuildStr = [NSString stringWithFormat:@"%@ %@", appVersionNum, buildNum];
    return versionBuildStr;
}

#pragma mark - 获取当前屏幕显示的UIViewController
- (UIViewController *)getCurrentVC {
    UIWindow *window = [self getCurrentWindow];
    if (!window || !window.rootViewController) {
        return nil;
    }
    
    UIViewController *resultVC = [self _topViewController:window.rootViewController vcArr:nil];
    while (resultVC && resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController vcArr:nil];
    }
    return resultVC;
}
//获取栈里所有的vc
- (NSMutableArray *)getStackAllVC {
    NSMutableArray *allVC = [NSMutableArray array];
    UIWindow *window = [self getCurrentWindow];
    if (!window || !window.rootViewController) {
        return allVC;
    }
    
    UIViewController *resultVC = [self _topViewController:window.rootViewController vcArr:allVC];
    while (resultVC && resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController vcArr:allVC];
    }
    return allVC;
}

//刷新聊天和会话列表页面
//- (void)reloadChatAndSessionVC{
//    //如果当前存在ZChatViewController ，则刷新
//    for (UIViewController * ctrl in [self getCurrentVC].navigationController.viewControllers) {
//        if([ctrl isKindOfClass:[ZChatViewController class]]){
//            ZChatViewController *chatCtrl = (ZChatViewController *)ctrl;
//            [chatCtrl.baseTableView reloadData];
//            break;
//        }
//    }
//
//    //ZSessionVC必存在，刷新
//    ZTabBarController * tabCtr = (ZTabBarController *)CurrentWindow.rootViewController;
//    UINavigationController * firstNav = (UINavigationController *)[tabCtr.viewControllers firstObject];
//    for (UIViewController * ctrl in firstNav.viewControllers) {
//        if([ctrl isKindOfClass:[ZSessionVC class]]){
//            ZSessionVC *sessionVC = (ZSessionVC *)ctrl;
//            [sessionVC.baseTableView reloadData];
//            break;
//        }
//    }
//}

- (UIViewController *)_topViewController:(UIViewController *)vc vcArr:(NSMutableArray *)vcArr {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UIViewController *tempVC = [self _topViewController:[(UINavigationController *)vc topViewController] vcArr:vcArr];
        if (vcArr && ![vcArr containsObject:tempVC]) {
            [vcArr addObject:tempVC];
        }
        return tempVC;
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        UIViewController *tempVC = [self _topViewController:[(UITabBarController *)vc selectedViewController] vcArr:vcArr];
        if (vcArr && ![vcArr containsObject:tempVC]) {
            [vcArr addObject:tempVC];
        }
        return tempVC;
    } else {
        if (vcArr && ![vcArr containsObject:vc]) {
            [vcArr addObject:vc];
        }
        return vc;
    }
    return nil;
}

#pragma mark - 获取当前的Window
- (UIWindow *)getCurrentWindow{
    if ([[[UIApplication sharedApplication] delegate] window]) {
        return [[[UIApplication sharedApplication] delegate] window];
    }else{
        if (@available(iOS 13.0, *)) {
            NSArray *array = [[[UIApplication sharedApplication] connectedScenes] allObjects];
            UIWindowScene *windowScene = (UIWindowScene *)array.firstObject;
            //由于在sdk开发中，引入不了SceneDelegate的头文件，所以需要用kvc获取宿主app的window.
            UIWindow* mainWindow = [windowScene valueForKeyPath:@"delegate.window"];
            if (mainWindow) {
                return mainWindow;
            } else{
                return [[UIApplication sharedApplication].windows lastObject];
            }
        } else{
            return [UIApplication sharedApplication].keyWindow;
        }
    }
}

#pragma mark - 设置tabBar
/// 将完整 Worker MainScreen 包装在原生导航控制器中，保留 CandyTalk 推页能力。
- (void)setupWorkerUI {
    [self doInMain:^{
        [ZLanguageTOOL initLanguageSetting];
        UIViewController *workerViewController = [CoHereWorkModuleManager.shared makeRootViewController];
        NoaNavigationController *navigationController = [[NoaNavigationController alloc] initWithRootViewController:workerViewController];
        navigationController.navigationBarHidden = YES;
        AppDelegate *appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
        appDelegate.window.rootViewController = navigationController;

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [appDelegate checkUserGestureLock];
        });
    }];
}

/// 已废弃：旧 CandyTalk TabBar 仅供回滚和未迁移调用保留，新的登录成功入口使用 setupWorkerUI。
/// 当前仍有兼容调用，不能安全添加编译期 deprecated 标记；标记日期：2026-08-10。
- (void)setupTabBarUI {
    //多语言设置初始化
    
    [ZTOOL doInMain:^{
        [ZLanguageTOOL initLanguageSetting];
        CandyTabBarController * tabbarVC = [[CandyTabBarController alloc] init];
        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appdelegate.window.rootViewController = tabbarVC;
        //通讯录红点先取本地展示
        NSInteger friendInviteCount = [IMSDKManager toolFriendApplyCount];
        [tabbarVC setBadgeValue:2 number:friendInviteCount];
        //会话列表红点先取本地展示
        __block NSInteger sessionUnreadCount;
        [ZTOOL doAsync:^{
            sessionUnreadCount = [IMSDKManager toolGetAllSessionUnreadCount];
        } completion:^{
            [tabbarVC setBadgeValue:1 number:sessionUnreadCount];
        }];
        
        // 设置完 tabBar 后，立即检查手势锁，避免闪烁
        // 使用很短的延迟，确保 tabBar 视图层级已经准备好
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [appdelegate checkUserGestureLock];
        });
    }];
}

#pragma mark - 设置登录界面
- (void)setupLoginUI {
    UIViewController *currentVC = CurrentVC;
    if ([currentVC isKindOfClass:[CoHereLoginViewController class]]) {
        // 如果当前已经是登录页面了，就没必要再次设置了(避免重复操作)
        return;
    }
    
    if (currentVC.navigationController && currentVC.navigationController.viewControllers > 0) {
        __block UIViewController *loginVC = nil;
        [currentVC.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[CoHereLoginViewController class]]) {
                // 如果当前是登录页面push了，就没必要再次设置了(避免重复操作)，直接pop返回即可
                loginVC = obj;
                *stop = YES;
            }
        }];
        
        if (loginVC) {
            [CurrentVC.navigationController popToViewController:loginVC animated:YES];
            return;
        }
    }
    
    //小程序浮窗
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MyMiniAppFloatRemove" object:nil];
    
    //多语言设置初始化
    [ZLanguageTOOL initLanguageSetting];
    //临时记录一下当前登录用户的uid
    NSString *tempUserId = ![NSString isNil:UserManager.userInfo.userUID] ? [NSString stringWithFormat:@"%@", UserManager.userInfo.userUID] : @"";
    //清除本地用户信息
    [NoaUserModel clearUserInfo];
    [UserManager clearUserInfo];
    //断开SDK的连接
    // TODO: 退出登录
    [IMSDKManager toolLogoutAccount];
    // TODO: 主动断开socket连接，然后重连，避免收到上一个账号(同一个socket的消息)
    [IMSDKManager toolDisconnectCanReconnect];
    //设置主界面未登录界面
    CoHereLoginViewController *loginVC = [CoHereLoginViewController new];
    NoaNavigationController *nav = [[NoaNavigationController alloc] initWithRootViewController:loginVC];
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegate.window.rootViewController = nav;
    //设置App的Badge数量为0
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    if ([NSString isNil:tempUserId]) {
        return;
    }
    //退出账号之前调用一下 删除设备推送信息接口，对接口返回不做任何处理
    NSString *token = [[MMKV defaultMMKV] getStringForKey:L_DevicePushToken];
    if (token.length < 5) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObjectSafe:[NSNumber numberWithInteger:1] forKey:@"osType"];
    [params setObjectSafe:@"apns" forKey:@"pushServer"];
    [params setObjectSafe:token?token:@"1" forKey:@"pushToken"];
    [params setObjectSafe:tempUserId forKey:@"userUid"];
    [IMSDKManager imSdkdeleteDeviceTokenWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {} onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {}];
}

#pragma mark - 设置竞速失败界面
- (void)setupRacingErroUIWithResutl:(NSDictionary *)dic {
    if (dic) {
        ZNetRacingStep step = [[dic objectForKey:@"step"] integerValue];
        NSInteger code = [[dic objectForKey:@"code"] integerValue];
        
        //需要在主线程中执行
        [ZTOOL doInMain:^{
            NoaAppStartErrorDefaultViewController *racingFailVC = [[NoaAppStartErrorDefaultViewController alloc] init];
            racingFailVC.step = step;
            racingFailVC.code = code;
            NoaNavigationController *nav = [[NoaNavigationController alloc] initWithRootViewController:racingFailVC];
            AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            appdelegate.window.rootViewController = nav;
        }];
    }
}

#pragma mark - 设置邀请码填写界面
- (void)setupSsoSetVcUI {
    [ZTOOL doInMain:^{
        //多语言设置初始化
        [ZLanguageTOOL initLanguageSetting];
        CoHereSsoSetViewController *ssoSetVC = [CoHereSsoSetViewController new];
        ssoSetVC.isRoot = YES;
        ssoSetVC.isReset = NO;
        NoaNavigationController *nav = [[NoaNavigationController alloc] initWithRootViewController:ssoSetVC];
        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appdelegate.window.rootViewController = nav;
    }];

}

#pragma mark - 弹窗-跳转登录界面
- (void)setupAlertToLoginUI {
    
    [ZTOOL doInMain:^{
        //多语言设置初始化
        [ZLanguageTOOL initLanguageSetting];
        
        NoaKnownTipView *viewTip = [NoaKnownTipView new];
        viewTip.lblTip.text = LanguageToolMatch(@"身份信息已过期，请重新登录");
        [viewTip.btnKnown setTitle:LanguageToolMatch(@"去登录") forState:UIControlStateNormal];
        [viewTip knownTipViewSHow];
        [viewTip setBtnKnownBlock:^{
            //清除本地用户信息
            [NoaUserModel clearUserInfo];
            [UserManager clearUserInfo];
            // TODO: 退出登录
            [IMSDKManager toolLogoutAccount];
            // TODO: 主动断开socket连接，然后重连，避免收到上一个账号(同一个socket的消息)
            [IMSDKManager toolDisconnectCanReconnect];
            //跳转到登录页面
            CoHereLoginViewController *loginVC = [CoHereLoginViewController new];
            NoaNavigationController *nav = [[NoaNavigationController alloc] initWithRootViewController:loginVC];
            AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            appdelegate.window.rootViewController = nav;
            
            //设置App的Badge数量为0
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        }];
    }];

    return;
    
}

#pragma mark - 跳转 服务协议
- (void)setupServeAgreement {
    /**
     showType=1 隐私政策
     showType=2 服务协议
     lan=1  简体中文
     lan=2  繁体中文
     lan=3  英文
     */
    [ZTOOL doInMain:^{
        NSString *urlStr = servicePolicyUrl;
        NoaBaseWebViewController *webVC = [[NoaBaseWebViewController alloc] init];
        webVC.webViewTitle = LanguageToolMatch(@"服务协议");
        webVC.webViewUrl = urlStr;
        [self.getCurrentVC.navigationController pushViewController:webVC animated:YES];
    }];
    

}

#pragma mark - 跳转 隐私政策
- (void)setupPrivePolicy {
    /**
     showType=1 隐私政策
     showType=2 服务协议
     lan=1  简体中文
     lan=2  繁体中文
     lan=3  英文
     */
    
    [ZTOOL doInMain:^{
        NSString *urlStr = privacyPolicyUrl;
        NoaBaseWebViewController *webVC = [[NoaBaseWebViewController alloc] init];
        webVC.webViewTitle = LanguageToolMatch(@"用户隐私协议");
        webVC.webViewUrl = urlStr;
        [self.getCurrentVC.navigationController pushViewController:webVC animated:YES];
    }];
    
}

#pragma mark - 账号信息发生变化，请重新登录
- (void)setupUserInfoChangeAlert {
    NoaAuthBannedAlertView *bannedAlertView = [[NoaAuthBannedAlertView alloc] initWithAlertType:ZAuthBannedAlertTypeSinglBtn];
    bannedAlertView.lblTitle.text = LanguageToolMatch(@"提示");
    bannedAlertView.lblContent.text = LanguageToolMatch(@"账号信息发生变化，请重新登录");
    [bannedAlertView.btnCancel setTitle:LanguageToolMatch(@"重新登录") forState:UIControlStateNormal];
    [bannedAlertView.btnCancel setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateNormal];
    [bannedAlertView alertTipViewSHow];
    WeakSelf
    bannedAlertView.cancelBtnBlock = ^{
        //退出登录
        [weakSelf setupLoginUI];
    };
}

#pragma mark - 弹窗-强制下线(登录、注册、刷新token接口返回对应错误，提示：账号封禁、IP封禁、设备封禁)
- (void)setupAlertUserBannedUIWithErrorCode:(NSInteger)errorCode withContent:(NSString *)content loginType:(NSInteger)loginType {
    NSInteger banType = 0;//封禁类型（1: 账户；2：IP; 3: 设备)
    NSString *banCode = @"";
    NSString *bannedContentStr = @"";
    NoaAuthBannedAlertView *bannedAlertView;
    switch (errorCode) {
        case Auth_User_Account_Banned:
            banType = 1;
            if (UserManager.isLogined) {
                banCode = UserManager.userInfo.userName;
                //bannedContentStr = [NSString stringWithFormat:LanguageToolMatch(@"当前账号 %@ 已被封禁"), UserManager.userInfo.userName];
                bannedContentStr = LanguageToolMatch(@"该账号被禁用");
                bannedAlertView = [[NoaAuthBannedAlertView alloc] initWithAlertType:ZAuthBannedAlertTypeTwoBtn];
            } else {
                if (loginType == UserAuthTypeAccount) {
                    banCode = content;
                    //bannedContentStr = [NSString stringWithFormat:LanguageToolMatch(@"当前账号 %@ 已被封禁"), content];
                    bannedContentStr = LanguageToolMatch(@"该账号被禁用");
                    bannedAlertView = [[NoaAuthBannedAlertView alloc] initWithAlertType:ZAuthBannedAlertTypeTwoBtn];
                } else {
                    if ([content isEqualToString:@"账号已被禁止登录"]) {
                        banCode = content;
                        bannedContentStr = LanguageToolMatch(@"该账号被禁用");
                        bannedAlertView = [[NoaAuthBannedAlertView alloc] initWithAlertType:ZAuthBannedAlertTypeTwoBtn];
                    } else {
                        banCode = content;
                        bannedContentStr = LanguageToolMatch(@"该账号被禁用");//@"当前账号 %@ 已被封禁"
                        bannedAlertView = [[NoaAuthBannedAlertView alloc] initWithAlertType:ZAuthBannedAlertTypeTwoBtn];
                    }
                }
            }
            break;
        case Auth_User_Device_Banned:
            banType = 3;
            banCode = content;
            bannedContentStr = [NSString stringWithFormat:LanguageToolMatch(@"当前设备 %@ 已被封禁"), content];
            bannedAlertView = [[NoaAuthBannedAlertView alloc] initWithAlertType:ZAuthBannedAlertTypeTwoBtn];
            break;
        case Auth_User_IPAddress_Banned:
            banType = 2;
            banCode = content;
            bannedContentStr = [NSString stringWithFormat:LanguageToolMatch(@"当前IP %@ 已被封禁"), content];
            bannedAlertView = [[NoaAuthBannedAlertView alloc] initWithAlertType:ZAuthBannedAlertTypeTwoBtn];
            break;
        default:
            bannedAlertView = [[NoaAuthBannedAlertView alloc] initWithAlertType:ZAuthBannedAlertTypeTwoBtn];
            break;
    }
    
    bannedAlertView.lblTitle.text = LanguageToolMatch(@"提示");
    bannedAlertView.lblContent.text = bannedContentStr;
    [bannedAlertView alertTipViewSHow];
    WeakSelf
    bannedAlertView.cancelBtnBlock = ^{
        //退出登录
        [weakSelf setupLoginUI];
    };
    bannedAlertView.sureBtnBlock = ^{
       //申请解封
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObjectSafe:@(banType) forKey:@"banType"];
        [dict setObjectSafe:banCode forKey:@"code"];
        [IMSDKManager authApplyUnBandWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        }];
        //退出登录
        [weakSelf setupLoginUI];
    };
}

#pragma mark - 线程操作
- (void)doInBackground:(void(^)(void))block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if (block) {
            block();
        }
    });
}

- (void)doInMain:(void(^)(void))block {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block) {
            block();
        }
    });
}

- (void)doAsync:(void(^)(void))block completion:(void(^)(void))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (block) {
            block();
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
        
    });
}

#pragma mark - 检测相册权限
- (void)checkAlbumAuthStatus:(void (^)(BOOL))completion {
    /*
     //权限枚举
     PHAuthorizationStatusNotDetermined 用户未作出选择
     PHAuthorizationStatusRestricted 此App无权限访问照片数据
     PHAuthorizationStatusDenied 用户已明确拒绝此应用程序访问照片数据
     PHAuthorizationStatusAuthorized 用户已授权此应用程序访问照片数据
     PHAuthorizationStatusLimited 用户已授权此应用程序进行有限照片库访问（iOS14新增）仅在PHAccessLevelReadWrite时生效
     */
    /*
     权限等级枚举
     PHAccessLevelAddOnly 仅允许添加
     PHAccessLevelReadWrite 读写
     */
    
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    
    if (authStatus == PHAuthorizationStatusNotDetermined) {
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                //权限正常
                if (completion) {
                    completion(YES);
                }
            }else {
                //此处要在主线程操作UI
                //相册权限未设置,请开启相册权限
                if (completion) {
                    completion(NO);
                }
            }
        }];
        
    }else if (authStatus == PHAuthorizationStatusDenied || authStatus == PHAuthorizationStatusRestricted) {
        //没有权限
        if (completion) {
            completion(NO);
        }
    }else{
        //权限正常
        if (completion) {
            completion(YES);
        }
    }
}
#pragma mark - 图片保存到相册
- (void)saveImageToAlbumWith:(NSString *)imageUrl Cusotm:(NSString *)customPath {
    
    [self checkAlbumAuthStatus:^(BOOL authOk) {
        if (authOk) {
            __block NSData *saveImageData;
            if ([imageUrl hasPrefix:@"http"]) {
                // 网络图片
                [[SDImageCache sharedImageCache] diskImageExistsWithKey:imageUrl completion:^(BOOL isInCache) {
                    if (isInCache) {
                        // 已有缓存
                        saveImageData = [[SDImageCache sharedImageCache] diskImageDataForKey:imageUrl];
                    } else {
                        // 直接尝试取缓存数据（防止 isInCache 判断失误）
                        saveImageData = [[SDImageCache sharedImageCache] diskImageDataForKey:imageUrl];
                        if (!saveImageData) {
                            // 如果缓存没有，走网络 + 解密
                            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl] options:NSDataReadingMappedIfSafe error:nil];
//                            saveImageData = [[ZEncryptManager shareEncryManager] decrypt:data];
                            saveImageData = [[EncryptManager shareEncryManager] decrypt:data];
                        }
                    }
                    
                    // 保存图片到相册中
                    if ([[[NSString getImageFileFormat:saveImageData] lowercaseString] isEqualToString:@"gif"]) {
                        // GIF 图片
                        __block NSString *assetId = nil;
                        [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                            PHAssetCreationRequest *creationRequest = [PHAssetCreationRequest creationRequestForAsset];
                            [creationRequest addResourceWithType:PHAssetResourceTypePhoto data:saveImageData options:nil];
                            assetId = creationRequest.placeholderForCreatedAsset.localIdentifier;
                        } error:nil];

                        PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
                        if (asset) {
                            [HUD showMessage:LanguageToolMatch(@"图片保存成功") inView:CurrentVC.view];
                        } else {
                            [HUD showMessage:LanguageToolMatch(@"图片保存失败") inView:CurrentVC.view];
                        }
                    } else {
                        // 静态图片
                        UIImage *saveImage = [UIImage imageWithData:saveImageData];
                        UIImageWriteToSavedPhotosAlbum(saveImage, self, @selector(image:didFinishSaveWithError:contextInfo:), nil );
                    }
                }];
            }
        } else {
            [HUD showMessage:LanguageToolMatch(@"无法保存，请检查相册权限") inView:CurrentVC.view];
        }
    }];
}

//保存图片完成之后的回调
- (void)image:(UIImage *)image didFinishSaveWithError:(NSError *)error contextInfo:(void *)contextInfo {

    if (error) {
        [HUD showMessage:LanguageToolMatch(@"图片保存失败") inView:CurrentVC.view];
    }else {
        [HUD showMessage:LanguageToolMatch(@"图片保存成功") inView:CurrentVC.view];
    }
}

#pragma mark - 视频下载缓存到本地
- (void)downloadVideoWith:(NSString *)videoUrl completion:(void (^)(BOOL, NSString * _Nonnull))completion {
    //文件路径Library/Caches/VideoCache/video.mp4
    
    NSString *cachePath = [self getVideoCachePath];
    NSString *fullCachePath = [NSString stringWithFormat:@"%@/%@",cachePath,[NSString stringWithFormat:@"%@.mp4",[videoUrl MD5Encryption]]];
    
    NSFileManager *fileManager  = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:fullCachePath];
    
    if (existed) {
        
        //视频已有缓存
        if (completion) {
            completion(YES, fullCachePath);
        }
        
    }else {
        
        //下载视频
        NSURL *url = [NSURL URLWithString:videoUrl];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.connectionProxyDictionary = @{}; // 关闭系统代理
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://www.baidu.com"] sessionConfiguration:config];

        @try {
            [ZHostTool confighttpSessionManagerCerAndP12Cer:manager isIPAddress:[videoUrl checkUrlIsIPAddress]];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception);
        }


        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            //开始下载
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [NSURL fileURLWithPath:fullCachePath];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            if (completion && !error) {
                NSData *resultData = [NSData dataWithContentsOfFile:fullCachePath];
//                NSData * encryptfileData = [[ZEncryptManager shareEncryManager] decrypt:resultData];
                NSData * encryptfileData = [[EncryptManager shareEncryManager] decrypt:resultData];
                [encryptfileData writeToFile:fullCachePath options:0 error:&error];
                completion(YES, fullCachePath);
            }
        }];
        [task resume];
    }
}

#pragma mark - 视频保存到相册
- (void)saveVideoToAlbumWith:(NSString *)videoPath {
    if (videoPath) {
        [self checkAlbumAuthStatus:^(BOOL authOk) {
            if (authOk) {
                BOOL compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoPath);
                if (compatible) {
                    //保存相册核心代码
                    UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, @selector(video:didFinishSaveWithError:contextInfo:), nil);
                }else {
                    [HUD showMessage:LanguageToolMatch(@"保存失败")];
                }
            }else{
                [HUD showMessage:LanguageToolMatch(@"无法保存，请检查相册配置")];
            }
        }];
    }else {
        [HUD showMessage:LanguageToolMatch(@"无视频地址")];
    }
}
//保存图片完成之后的回调
- (void)video:(UIImage *)image didFinishSaveWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        [HUD showMessage:LanguageToolMatch(@"视频保存失败")];
    }else {
        [HUD showMessage:LanguageToolMatch(@"视频保存成功")];
    }
}

#pragma mark - 视频缓存地址
- (NSString *)getVideoCachePath {
    NSString *videoCachePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"VideoCache"]];
    NSFileManager *fileManager  = [NSFileManager defaultManager];
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory 判断是否一个目录
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:videoCachePath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES)) {
        //在Document目录下创建一个drafts目录
        [fileManager createDirectoryAtPath:videoCachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return videoCachePath;
}
#pragma mark - 视频是否缓存在本地
- (NSString *)videoExistsWith:(NSString *)videoUrl {
    NSString *cachePath = [self getVideoCachePath];
    NSString *fullCachePath = [NSString stringWithFormat:@"%@/%@",cachePath,[NSString stringWithFormat:@"%@.mp4",[videoUrl MD5Encryption]]];
    NSFileManager *fileManager  = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:fullCachePath];
    if (existed) {
        return fullCachePath;
    }
    return nil;
}

#pragma mark - 检查url的host是否为ip 返回YES位Ip，返回NO位域名
- (BOOL)checkUrlStrIsIP:(NSString *)urlStr {
    //转成NSURL，拿到Host
    NSURL *url = [NSURL URLWithString:urlStr];
    NSString *urlHost = url.host;
    
    //是否为ip
    NSString *ipRegex = @"((2[0-4]\\d|25[0-5]|[01]?\\d\\d?)\\.){3}(2[0-4]\\d|25[0-5]|[01]?\\d\\d?)";
    NSPredicate *ipPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", ipRegex];
    if ([ipPredicate evaluateWithObject:urlHost] == NO) {
        return NO;
    }
    return YES;
}

#pragma mark - 系统权限检测
//检测是否有麦克风权限
- (BOOL)checkMicrophoneState {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined:
        {
            //没有询问是否开启麦克风
            return NO;
        }
            break;
        case AVAuthorizationStatusRestricted:
        {
            //未授权，家长限制
            return NO;
        }
            
            break;
            
        case AVAuthorizationStatusDenied:
        {
            //未授权
            return NO;
        }
            
            break;
        case AVAuthorizationStatusAuthorized:
        {
            //授权
            return YES;
        }
            break;
        default:{
            return NO;
        }
            break;
            
    }
}
//获取麦克风权限
- (void)getMicrophoneAuth:(void (^)(BOOL))complete {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        if (complete) {
            complete(granted);
        }
        //granted == YES 允许
    }];
}
//检测是否有相机权限
- (BOOL)checkCameraState {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined:
        {
            //没有询问是否开启相机
            return NO;
        }
            break;
        case AVAuthorizationStatusRestricted:
        {
            //未授权，家长限制
            return  NO;
        }
            break;
            
        case AVAuthorizationStatusDenied:
        {
            //未授权
            return NO;
        }
            break;
            
        case AVAuthorizationStatusAuthorized:
        {
            //授权
            return YES;
        }
            break;
            
        default:
        {
            return NO;
        }
            break;
            
    }
}
//获取相机权限-弹出弹框
- (void)getCameraAuth:(void (^)(BOOL))complete {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (complete) {
            complete(granted);
        }
        //granted == YES 允许
    }];
}
//检测是否有相册权限
- (BOOL)checkPhotoLibraryState {
    PHAuthorizationStatus photoAuthorStatus = [PHPhotoLibrary authorizationStatus];
    switch (photoAuthorStatus) {
        case PHAuthorizationStatusAuthorized:
        {
            //授权
            return YES;
        }
            break;
        case PHAuthorizationStatusDenied:
        {
            //未授权
            return NO;
        }
            break;
        case PHAuthorizationStatusNotDetermined:
        {
            //没有询问是否开启相机
            return NO;
        }
            break;
        case PHAuthorizationStatusRestricted:
        {
            //未授权，家长限制
            return  NO;
        }
            break;
            
        default:
        {
            return NO;
        }
            break;
    }
}

//获取相册权限
- (void)getPhotoLibraryAuth:(void (^)(BOOL granted))complete {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        
        if (status == PHAuthorizationStatusAuthorized) {
            //权限正常
            if (complete) {
                complete(YES);
            }
        }else {
            //此处要在主线程操作UI
            //相册权限未设置,请开启相册权限
            if (complete) {
                complete(NO);
            }
        }
    }];
}

#pragma mark - 跳转到AppStore
- (void)goAppStore {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_IN_APPLE_STORE_URL] options:@{} completionHandler:nil];
}

#pragma mark - 会话列表-文件助手-本地化语言更新
- (void)sessionFileHelperLanguageUpdate {
    NSString *sessionID = @"100002";
    LingIMSessionModel *sessionModel = [IMSDKManager toolCheckMySessionWith:sessionID];
    if (sessionModel) {
        if (![sessionModel.sessionName isEqualToString:LanguageToolMatch(@"文件助手")]) {
            sessionModel.sessionName = LanguageToolMatch(@"文件助手");
            [IMSDKManager toolUpdateSessionWith:sessionModel];
        }
    }
}

#pragma mark - 会话列表-签到助手-本地化语言更新
- (void)sessionSignInRemainderLanguageUpdate {
    NSString *sessionID = @"100003";
    LingIMSessionModel *sessionModel = [IMSDKManager toolCheckMySessionWith:sessionID];
    if (sessionModel) {
        if (![sessionModel.sessionName isEqualToString:LanguageToolMatch(@"签到助手")]) {
            sessionModel.sessionName = LanguageToolMatch(@"签到助手");
            [IMSDKManager toolUpdateSessionWith:sessionModel];
        }
    }
    
}

#pragma mark - 通讯录-文件助手-本地化语言更新
- (void)connectFileHelperLanguageUpdate {
    NSString *friendID = @"100002";
    LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:friendID];
    if (friendModel) {
        if (![friendModel.nickname isEqualToString:LanguageToolMatch(@"文件助手")]) {
            friendModel.nickname = LanguageToolMatch(@"文件助手");
            friendModel.showName = LanguageToolMatch(@"文件助手");
            [IMSDKManager toolUpdateMyFriendWith:friendModel];
        }
    }
}

#pragma mark - RTL 布局 设置
-(void)RTLConfig{
    if(ZLanguageTOOL.isRTL){
        [UIView appearance].semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
        [UISearchBar appearance].semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
        [[UINavigationBar appearance] setSemanticContentAttribute:UISemanticContentAttributeForceRightToLeft];
    }else{
        [UIView appearance].semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
        [UISearchBar appearance].semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
        [[UINavigationBar appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
    }
    
}
//获取RTP布局的NSTextAlignment
-(NSTextAlignment)RTLTextAlignment:(NSTextAlignment)textAlignment{
    if(ZLanguageTOOL.isRTL){
        if(textAlignment == NSTextAlignmentLeft){
            return NSTextAlignmentRight;
        }else if(textAlignment == NSTextAlignmentRight){
            return NSTextAlignmentLeft;
        }else{
            return textAlignment;
        }
    }else{
        return textAlignment;
    }
    
}

- (void)sentryUploadWithDictionary:(NSDictionary *)dictionary sentryUploadType:(ZSentryUploadType)sentryUploadType errorCode:(NSString *)errorCode{
    NSError *error;
    // 转换为 JSON 字符串
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
//    错误码，筛选条件：user.email
//    设备ID，筛选条件：geo.region
//    事件时间，筛选条件：geo.city
//    邀请码（已进入邀请码），筛选条件：geo.country_code
//    用户ID（已登录），筛选条件：user.id
//    用户名（已登录），筛选条件：user.username
    
    if (jsonData) {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NoaSsoInfoModel *infoModel = [NoaSsoInfoModel getSSOInfo];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:errorCode forKey:@"errorCode"];
        if (UserManager.isLogined) {
            [dict setValue:UserManager.userInfo.userUID forKey:@"userId"];
            [dict setValue:UserManager.userInfo.userName forKey:@"userName"];
        }
        [dict setValue:infoModel.liceseId forKey:@"liceseId"];
        [dict setValue:infoModel.lastLiceseId ?: @"" forKey:@"lastLiceseId"];
        [dict setValue:[FCUUID uuidForDevice] forKey:@"deviceId"];
        [dict setValue:[NSDate transSecondToTimeMethod1:[NSDate currentTimeIntervalWithSecond]] forKey:@"errorTime"];

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
        //socket连接
        //event_socketConnect
        //GaOnChain获取数据成功
        //event_ga_onchain_success
        //socket连接
        //GaOnChain获取数据失败
        NSString *transaction = @"";
        switch (sentryUploadType) {
            case ZSentryUploadTypeMessage:
                transaction = @"event_message";
                break;
            case ZSentryUploadTypeHttp:
                transaction = @"event_http";
                break;
            case ZSentryUploadTypeEnterprise:
                transaction = @"event_enterprise";
                break;
            case ZSentryUploadTypeImage:
                transaction = @"event_image";
                break;
            case ZSentryUploadTypeUpload:
                transaction = @"event_message_upload";
                break;
            case ZSentryUploadTypeSocketConnect:
                transaction = @"event_socketConnect";
                break;
            case ZSentryUploadTypeEnterpriseSuccess:
                transaction = @"event_enterprise_success";
                break;
            case ZSentryGaOnChainSuccess:
                transaction = @"event_ga_onchain_success";
                break;
            case ZSentryGaOnChainFailed:
                transaction = @"event_ga_onchain_failed";
                break;
            default:
                break;
        }
    } else {
        NSLog(@"Error: %@", error.localizedDescription);
    }
}
- (void)sentryUploadWithString:(NSString *)string sentryUploadType:(ZSentryUploadType)sentryUploadType errorCode:(NSString *)errorCode{

    NoaSsoInfoModel *infoModel = [NoaSsoInfoModel getSSOInfo];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:errorCode forKey:@"errorCode"];
    if (UserManager.isLogined) {
        [dict setValue:UserManager.userInfo.userUID forKey:@"userId"];
        [dict setValue:UserManager.userInfo.userName forKey:@"userName"];
    }
    [dict setValue:infoModel.liceseId forKey:@"liceseId"];
    [dict setValue:infoModel.lastLiceseId ?: @"" forKey:@"lastLiceseId"];
    [dict setValue:[FCUUID uuidForDevice] forKey:@"deviceId"];
    [dict setValue:[NSDate transSecondToTimeMethod1:[NSDate currentTimeIntervalWithMillisecond]] forKey:@"errorTime"];
    [dict setValue:[NSString isNil:self.publicIP] ? @"" : self.publicIP forKey:@"publicIpAddress"];

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
    NSString *transaction = @"";
    switch (sentryUploadType) {
        case ZSentryUploadTypeMessage:
            transaction = @"event_message";
            break;
        case ZSentryUploadTypeHttp:
            transaction = @"event_http";
            break;
        case ZSentryUploadTypeEnterprise:
            transaction = @"event_enterprise";
            break;
        case ZSentryUploadTypeImage:
            transaction = @"event_image";
            break;
        case ZSentryUploadTypeUpload:
            transaction = @"event_message_upload";
            break;
        case ZSentryUploadTypeEnterpriseSuccess:
            transaction = @"event_enterprise_success";
            break;
        default:
            break;
    }
}


BOOL isRTLString(NSString *string) {
    if ([string hasPrefix:@"\u202B"] || [string hasPrefix:@"\u202A"]) {
        return YES;
    }
    return NO;
}


NSAttributedString *RTLAttributeString(NSAttributedString *attributeString ){
    if (attributeString.length == 0) {
        return attributeString;
    }
    NSRange range;
    NSDictionary *originAttributes = [attributeString attributesAtIndex:0 effectiveRange:&range];
    NSParagraphStyle *style = [originAttributes objectForKey:NSParagraphStyleAttributeName];
    
    if (style && isRTLString(attributeString.string)) {
        return attributeString;
    }
    
    NSMutableDictionary *attributes = originAttributes ? [originAttributes mutableCopy] : [NSMutableDictionary new];
    if (!style) {
        NSMutableParagraphStyle *mutableParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        mutableParagraphStyle.alignment = NSTextAlignmentRight;
        style = mutableParagraphStyle;
        [attributes setValue:mutableParagraphStyle forKey:NSParagraphStyleAttributeName];
    }
    
    NSMutableAttributedString * mutableAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attributeString];
    
    [mutableAttributedString setAttributes:attributes range: range];
    
    return mutableAttributedString;
}

- (ProxyType)getCurrentProxyType {
    return [[MMKV defaultMMKV] getInt32ForKey:PROXY_CURRENT_TYPE];
}

- (BOOL)isNetworkAvailable {
    return [[NetWorkStatusManager shared] getConnectStatus];
}

- (void)getDevicePublicNetworkIPWithCompletion:(void(^)(NSString *ip))completion {
    NSArray *ipAPIs = @[
        @"https://ipinfo.io/ip",
        @"https://checkip.amazonaws.com",
        @"http://checkip.amazonaws.com"
    ];

    if (!completion) return;

    __block BOOL ipFound = NO;
    dispatch_group_t group = dispatch_group_create();
    // 记录所有任务，便于在首个成功后取消剩余请求
    __block NSMutableArray<NSURLSessionDataTask *> *tasks = [NSMutableArray arrayWithCapacity:ipAPIs.count];

    for (NSString *apiUrlString in ipAPIs) {
        dispatch_group_enter(group);
        NSURL *url = [NSURL URLWithString:apiUrlString];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url
                                                                 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error && data && !ipFound) {
                NSString *ipString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                ipString = [ipString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if (ipString.length > 0) {
                    ipFound = YES;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(ipString);
                    });
                    // 取消剩余仍在运行的任务
                    @synchronized (tasks) {
                        for (NSURLSessionDataTask *t in tasks) {
                            if (t != task && t.state == NSURLSessionTaskStateRunning) {
                                [t cancel];
                            }
                        }
                    }
                }
            }
            dispatch_group_leave(group);
        }];
        @synchronized (tasks) { [tasks addObject:task]; }
        [task resume];
    }

    // 所有任务完成仍未获取到 IP，立即返回空字符串（不再额外等待）
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (!ipFound) {
            completion(@"");
        }
    });
}

#pragma mark - 公网IP区域判断
- (BOOL)isDomestic{
    // 基于系统区域码判断（CN 视为国内，其余视为海外）
    NSString *regionCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    return [regionCode isEqualToString:@"CN"];
}

- (void)sentryOpenEventWithDSNKey:(NSString *)DSNkey {
    // Override point for customization after application launch.
    // SentrySDK
    
}

#pragma mark - Logan publish URL 管理

- (NSString *)getPersistedLoganPublishURL {
    NSString *url = [[NSUserDefaults standardUserDefaults] stringForKey:kLoganPublishURLKey];
    return url;
}

- (void)setPersistedLoganPublishURL:(NSString *)urlString {
    if (!urlString || urlString.length == 0) return;
    [[NSUserDefaults standardUserDefaults] setObject:urlString forKey:kLoganPublishURLKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)loganEffectivePublishURL {
    NSString *persisted = [self getPersistedLoganPublishURL];
    if (persisted.length > 0) {
        return persisted;
    }
    // 第一次无值，写入默认
    [self setPersistedLoganPublishURL:kLoganDefaultPublishURL];
    return kLoganDefaultPublishURL;
}

- (void)reloadLoganIfNeededWithPublishURL:(NSString *)newURL {
    if (!newURL || newURL.length == 0) return;
    NSString *current = g_CurrentLoganPublishURL ?: [self getPersistedLoganPublishURL];
    if ([current isEqualToString:newURL]) {
        return; // 无变化
    }
    // 持久化
    [self setPersistedLoganPublishURL:newURL];
    // 重载 Logan：沿用原 configLogan 行为构建 NoaIMLoganOption（publishUrlOriginal 替换为 newURL）
    dispatch_async(dispatch_get_main_queue(), ^{
        NoaIMLoganOption *loganOption = [NoaIMLoganOption new];
        loganOption.loganKey = @"0123456789012345";
        loganOption.loganIV = @"0123456789012345";
        loganOption.loganFileMax = 10 * 1024.0 * 1024;
        loganOption.loganUploadUrl = [NSString stringWithFormat:@"%@/logan-web/logan/upload.json", newURL];
        loganOption.loganUserUnionId = [FCUUID uuidForDevice];
        loganOption.loganUserName = [NSString isNil:UserManager.userInfo.userName] ? @"" : UserManager.userInfo.userName;
        NoaSsoInfoModel *model = [NoaSsoInfoModel getSSOInfo];
        if (![NSString isNil:model.liceseId]) {
            loganOption.loganLiceseId = model.liceseId;
        } else if (![NSString isNil:model.ipDomainPortStr]) {
            loganOption.loganLiceseId = model.ipDomainPortStr;
        } else {
            loganOption.loganLiceseId = @"NONE COMPANY / IP";
        }
        if (ZHostTool.appSysSetModel != nil) {
            if (![NSString isNil:ZHostTool.appSysSetModel.sys_uploadlog_domain] && ![ZHostTool.appSysSetModel.sys_uploadlog_domain isEqualToString:newURL]) {
                loganOption.loganUploadUrl = [NSString stringWithFormat:@"%@/logan-web/logan/upload.json", ZHostTool.appSysSetModel.sys_uploadlog_domain];
            }
        }
        [IMSDKManager imSdkOpenLoganWith:loganOption];
        g_CurrentLoganPublishURL = [newURL copy];
        NSLog(@"[Logan] Reloaded with Publish URL: %@", newURL);
        // 记录配置切换事件（Sentry）
        NSString *msg = [NSString stringWithFormat:@"Logan publishUrl switched: old=%@, new=%@", current ?: @"<nil>", newURL];
        [self sentryUploadWithString:msg sentryUploadType:ZSentryUploadTypeEnterprise errorCode:@"logan_publishurl_switch"];
    });
}
@end
