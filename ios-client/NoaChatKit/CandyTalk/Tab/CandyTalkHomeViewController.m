//
//  CandyTalkHomeViewController.m
//  NoaKit
//
//  Created by Apple on 2026/9/2.
//

#import "CandyTalkHomeViewController.h"


#import "NoaSessionTopView.h"
#import "NoaSearchView.h"
#import "NoaSessionCell.h"
#import "NoaSessionHeaderView.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "AppDelegate+MiniApp.h"
//跳转
#import "NoaGlobalSearchVC.h"//全局搜索
#import "NoaChatKit-Swift.h"//Swift 添加好友、创建群聊及文件助手页面
#import "NoaChatViewController.h"//聊天
#import "CandyTabBarController.h"//tabbar
#import "NoaPushNavTools.h"   //推送消息点击跳转
#import "NoaToolManager.h"    //工具类
#import "NoaQRcodeScanViewController.h"//扫描二维码
#import "NoaMassMessageVC.h"  //群发助手
#import "NoaSystemMessageVC.h"//系统消息(群助手)
#import "NoaAppUpdateTools.h" //检查App版本信息
#import "NoaWeakPwdCheckTool.h" //检查密码强度
#import "NoaSignInMessageViewController.h"//签到提醒
#import "NoaUserRoleAuthorityModel.h"
#import "NoaSessionNetStateView.h"
#import "NoaMessageSendHander.h"
#import "NoaMessageTools.h"
#import "NoaSessionReadTool.h"

@interface CandyTalkHomeViewController () <NoaToolSessionDelegate,UITableViewDelegate,UITableViewDataSource,MGSwipeTableCellDelegate, DZNEmptyDataSetSource,DZNEmptyDataSetDelegate,ZSessionCellDelegate>
@property (nonatomic, strong) NoaSessionTopView *viewTop;
@property (nonatomic, strong) UIButton *btnTop;
@property (nonatomic, strong) SyncMutableArray *sessionList;//会话列表
@property (nonatomic, strong) SyncMutableArray *currentSessionList;//当前会话列表
@property (nonatomic, assign) NSInteger currentIndex;//当前位置
@property (nonatomic, assign) CGFloat lastContentOffset;
@property (nonatomic, strong) SyncMutableArray *sessionTopList;//置顶会话
@property (nonatomic, strong) NoaSessionNetStateView *netStateView;
@property (nonatomic, strong) NSIndexPath *currentCellIndex;
@property (nonatomic, assign) BOOL isClicked;

//会话更新队列
@property (nonatomic, strong) dispatch_queue_t sessionListUpdateQueue;
// 列表刷新防抖
@property (nonatomic, copy) dispatch_block_t pendingReloadBlock;
@end

@implementation CandyTalkHomeViewController

/// 判断当前会话列表是否由其他页面压栈打开；压栈模式需要展示返回导航。
/// @return 当前控制器不是导航栈根控制器时返回 YES，否则返回 NO。
- (BOOL)isDisplayedAsPushedMessagePage {
    UINavigationController *navigationController = self.navigationController;
    return navigationController != nil
        && navigationController.viewControllers.firstObject != self;
}

/// 判断会话是否属于新版会话页不展示的系统助手。
/// @param session SDK 或本地数据库返回的会话模型。
/// @return 群发助手、文件助手或每日签到返回 YES；其他会话返回 NO。
- (BOOL)coHereShouldHideSession:(LingIMSessionModel *)session {
    if (session == nil) {
        return NO;
    }
    return session.sessionType == CIMSessionTypeMassMessage
        || session.sessionType == CIMSessionTypeSignInReminder
        || [session.sessionID isEqualToString:@"100002"]
        || [session.sessionID isEqualToString:@"100003"];
}

/// 从会话快照中移除仅需隐藏的系统助手，不删除 SDK 数据库记录。
/// @param sessions 待过滤的普通或置顶会话快照。
/// @return 保持原顺序的可见会话数组。
- (NSArray<LingIMSessionModel *> *)coHereVisibleSessionsFromArray:(NSArray<LingIMSessionModel *> *)sessions {
    if (sessions.count == 0) {
        return @[];
    }
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(LingIMSessionModel *session, NSDictionary *bindings) {
        return ![self coHereShouldHideSession:session];
    }];
    return [sessions filteredArrayUsingPredicate:predicate];
}

- (void)refreshRowForSessionId:(NSString *)sessionId {
    if (sessionId.length == 0) return;

    dispatch_async(dispatch_get_main_queue(), ^{
        // 使用 safeArray 确保线程安全
        NSArray *snapshot = [self.currentSessionList safeArray];
        __block NSInteger row = NSNotFound;
        [snapshot enumerateObjectsUsingBlock:^(LingIMSessionModel *obj, NSUInteger idx, BOOL *stop) {
            if (obj && [obj.sessionID isEqualToString:sessionId]) {
                row = idx; *stop = YES;
            }
        }];

        if (row != NSNotFound && row < snapshot.count) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            // 检查 tableView 是否还有效，避免在视图销毁后调用
            if (self.baseTableView && self.baseTableView.window) {
                @try {
                    [self.baseTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                } @catch (NSException *exception) {
                    NSLog(@"❌ [CandyTalkHomeViewController] reloadRowsAtIndexPaths 异常: %@", exception.reason);
                    // 如果局部刷新失败，回退到全量刷新
                    [self.baseTableView reloadData];
                }
            }
        }
    });
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_viewTop viewAppearUpdateUI];
}
- (void)viewDidLoad {
    [super viewDidLoad];

    BOOL isPushedMessagePage = [self isDisplayedAsPushedMessagePage];
    self.navView.hidden = !isPushedMessagePage;
    if (isPushedMessagePage) {
        self.navTitleStr = LanguageToolMatch(@"消息");
    }
    self.view.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    self.currentCellIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    self.lastContentOffset = 0;
    self.isClicked = NO;
    //默认本地数据库信息
    [self getSessionListFromDB];
    
    [IMSDKManager addSessionDelegate:self];
    
    [self setupUI];
    
    //获取当前用户的角色权限
    [self requestGetUserRoleAuthorityInfo];
    //获取当前登录用户的userInfo
    [self requestGetCurrentLoginUserInfo];
    //获取本群活跃状态等级配置信息
    [self requestGetGroupActivityLevelInfo];
    
    //刷新空数据界面?
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadNodataView)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
    //好友在线状态更新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myFriendOnlineStatusChange:) name:@"MyFriendOnlineStatusChange" object:nil];
    //群发助手最新消息更新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(latestMassMessageChange) name:@"LatestMassMessageChange" object:nil];
    //会话置顶状态发生改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSessionListFromDB) name:@"SessionTopStateChange" object:nil];
    //聊天和会话列表的刷新
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatAndSessionReload:) name:@"ReloadChatAndSessionVC" object:nil];
    //双击tabbar触发tableView自动滚动到未读小时的session
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadScrollToUnReadSession)
                                                     name:Z_DoubleClickTabItemNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectStateChange:) name:@"IMConnectStateChange" object:nil];
    //用户角色权限发生变化(是否线上文件助手)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userRoleAuthorityFileHelperChange) name:@"UserRoleAuthorityFileHelperChangeNotification" object:nil];
    //是否是通过点击推送消息打开的App
    if (ZTOOL.pushUserInfo.count > 0) {
        [NoaPushNavTools pushMessageClickToNavWithInfo:ZTOOL.pushUserInfo];
        ZTOOL.pushUserInfo = @{};
    }
    
    [NoaWeakPwdCheckTool sharedInstance].currentNavigationController = self.navigationController;
    [self updateAndCheckPwdStrength];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate checkMiniAppFloatShow];
//    [self startMonitoringNetwork];
}

- (void)updateAndCheckPwdStrength {
    __block BOOL isUpdate = NO;
    __block BOOL doNext = NO;
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    // 获取App的更新信息(通过接口返回的数据来决定是否要显示更新弹窗)
    [NoaAppUpdateTools getAppUpdateInfoWithShowDefaultTips:NO completion:^(BOOL updateResult) {
        isUpdate = updateResult;
        dispatch_group_leave(group);
    }];

    dispatch_group_enter(group);
    [[NoaWeakPwdCheckTool sharedInstance] checkPwdStrengthWithCompletion:^(BOOL shouldShowPwdTip) {
        doNext = shouldShowPwdTip;
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 如果有App更新，优先显示更新弹窗，不显示密码提醒
        if (isUpdate) {
            return;
        }
        // 如果密码强度检查通过且需要提醒用户修改密码，则显示密码修改提示
        if (doNext) {
            [[NoaWeakPwdCheckTool sharedInstance] alertChangePwdTipView];
        }
    });
}

- (void)reloadNodataView{
    [self.baseTableView reloadEmptyDataSet];
}

#pragma mark - 界面布局
/// 创建会话列表布局；从 Worker 压栈进入时隐藏旧首页头部，让列表紧贴原生导航栏。
- (void)setupUI {
    __weak typeof(self) weakSelf = self;
    BOOL isPushedMessagePage = [self isDisplayedAsPushedMessagePage];
    _viewTop = [[NoaSessionTopView alloc] initWithHome:YES];
    _viewTop.hidden = isPushedMessagePage;
    _viewTop.avatarTapBlock = ^{
//        [NoaMineVC presentMineDrawerFromTop];
    };
    _viewTop.searchBlock = ^{
        NoaGlobalSearchVC *vc = [NoaGlobalSearchVC new];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
    _viewTop.addBlock = ^(ZSessionMoreActionType actionType) {
        if (actionType == ZSessionMoreActionTypeAddFriend) {
            //添加好友
            CoHereAddFriendViewController *vc = [CoHereAddFriendViewController new];
            [weakSelf.navigationController pushViewController:vc animated:YES];
        } else if (actionType == ZSessionMoreActionTypeCreateGroup) {
            //创建群聊
            CoHereInviteFriendViewController *vc = [CoHereInviteFriendViewController new];
            vc.maxNum = 200;
            vc.minNum = 2;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        } else if (actionType == ZSessionMoreActionTypeSacnQRcode) {
            //二维码
            NoaQRcodeScanViewController *vc = [[NoaQRcodeScanViewController alloc] init];
            vc.isRacing = NO;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        } else if (actionType == ZSessionMoreActionTypeMassMessage) {
            //群发助手
            NoaMassMessageVC *vc = [[NoaMassMessageVC alloc] init];
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }
    };
    [self.view addSubview:_viewTop];
    [_viewTop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        if (isPushedMessagePage) {
            // Worker 消息入口已使用原生导航栏，旧首页头部隐藏且不保留布局高度。
            make.top.equalTo(self.navView.mas_bottom);
            make.height.mas_equalTo(0);
        } else {
            make.top.equalTo(self.view);
            make.height.mas_equalTo([NoaSessionTopView preferredHeightForHome:NO]);
        }
    }];
    _viewTop.layoutHeightDidChangeBlock = ^(CGFloat height) {
        [weakSelf.viewTop mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(height);
        }];
    };
    
    self.baseTableViewStyle = UITableViewStyleGrouped;
    [self.view addSubview:self.baseTableView];
    [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(_viewTop.mas_bottom);
        make.bottom.equalTo(self.view).offset(-DTabBarH);
    }];
    
    self.baseTableView.delegate = self;
    self.baseTableView.dataSource = self;
    self.baseTableView.emptyDataSetSource = self;
    self.baseTableView.emptyDataSetDelegate = self;
    self.baseTableView.estimatedRowHeight = 0;
    self.baseTableView.estimatedSectionHeaderHeight = 0;
    self.baseTableView.estimatedSectionFooterHeight = 0;
    self.baseTableView.delaysContentTouches = NO;
    
    [self.baseTableView registerClass:[NoaSessionCell class] forCellReuseIdentifier:NSStringFromClass([NoaSessionCell class])];
    [self.baseTableView registerClass:[NoaSessionHeaderView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([NoaSessionHeaderView class])];
    
    
    [self.view addSubview:self.btnTop];
    [self.btnTop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-DTabBarH - DWScale(25));
        make.trailing.equalTo(self.view).offset(-DWScale(20));
        make.size.mas_equalTo(CGSizeMake(DWScale(36), DWScale(36)));
    }];
    
    [self.view addSubview:self.netStateView];
    self.netStateView.hidden = YES;
    [self.netStateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.top.equalTo(_viewTop.mas_bottom);
        make.height.mas_equalTo(DWScale(30));
    }];
}

#pragma mark - 从数据库获取信息
- (void)getSessionListFromDB {
    //    __weak typeof(self) weakSelf = self;
    //    //先从本地数据库加载之前缓存过的数据
    //    dispatch_async(self.sessionListUpdateQueue, ^{
    [self.sessionList replaceAllObjectsWithArray:@[]];
    [self.sessionTopList replaceAllObjectsWithArray:@[]];
    if ([UserManager.userRoleAuthInfo.isShowFileAssistant.configValue isEqualToString:@"true"]) {
        [self.sessionTopList addObjectsFromArray:[IMSDKManager toolGetMyTopSessionListExcept:@""].copy];
        [self.sessionList addObjectsFromArray:[IMSDKManager toolGetMySessionListExcept:@""].copy];
    } else {
        [self.sessionTopList addObjectsFromArray:[IMSDKManager toolGetMyTopSessionListExcept:@"100002"].copy];
        [self.sessionList addObjectsFromArray:[IMSDKManager toolGetMySessionListExcept:@"100002"].copy];
    }
    // 合并重复：签到助手会话（若存在多个，合并为一条）
    [self mergeDuplicateSignInSessionIfNeeded];
    self.currentIndex = 1;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.baseTableView reloadData];
    });
    //    });
}

#pragma mark - 合并重复的签到助手会话
- (void)mergeDuplicateSignInSessionIfNeeded {
    // 使用 safeArray 获取快照，确保线程安全
    // 在当前内存列表中合并
    NSArray *sessionListSnapshot = [self.sessionList safeArray];
    NSMutableArray<LingIMSessionModel *> *signInSessions = [NSMutableArray array];
    [sessionListSnapshot enumerateObjectsUsingBlock:^(LingIMSessionModel *obj, NSUInteger idx, BOOL *stop) {
        if (obj && obj.sessionType == CIMSessionTypeSignInReminder) {
            [signInSessions addObject:obj];
        }
    }];
    if (signInSessions.count <= 1) { return; }
    // 选择最近活跃为主
    [signInSessions sortUsingComparator:^NSComparisonResult(LingIMSessionModel * _Nonnull a, LingIMSessionModel * _Nonnull b) {
        return a.sessionLatestTime < b.sessionLatestTime ? NSOrderedDescending : NSOrderedAscending;
    }];
    LingIMSessionModel *primary = signInSessions.firstObject;
    NSInteger mergedUnread = primary.sessionUnreadCount + primary.readTag;
    for (NSUInteger i = 1; i < signInSessions.count; i++) {
        LingIMSessionModel *dup = signInSessions[i];
        mergedUnread += (dup.sessionUnreadCount + dup.readTag);
        [self.sessionList removeObject:dup];
        // 不直接删库，避免误删；如需彻底清理可在后续提供DB工具
    }
    // 将合并后的未读回填到主会话
    if (mergedUnread > 0) {
        primary.readTag = 0;
        primary.sessionUnreadCount = mergedUnread;
        [IMSDKManager toolUpdateSessionWith:primary];
    }
}

#pragma mark - Request
//获取用户权限
- (void)requestGetUserRoleAuthorityInfo {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    
    [IMSDKManager userGetRoleAuthorityListWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDic = (NSDictionary *)data;
            NoaUserRoleAuthorityModel *userRoleAuthInfo = [NoaUserRoleAuthorityModel mj_objectWithKeyValues:dataDic];
            NSString *oldUpFileValue = UserManager.userRoleAuthInfo.upFile.configValue;
            NSString *oldDeleteMessageVaule = UserManager.userRoleAuthInfo.deleteMessage.configValue;
            NSString *oldShowTeamVaule = UserManager.userRoleAuthInfo.showTeam.configValue;
            NSString *oldUpImageVideoValue = UserManager.userRoleAuthInfo.upImageVideoFile.configValue;
            NSString *oldFileHelperValue = UserManager.userRoleAuthInfo.isShowFileAssistant.configValue;
            NSString *oldTranslateSwitch = UserManager.userRoleAuthInfo.translationSwitch.configValue;

            // 默认开启：后端缺失时置为 true
            if (!userRoleAuthInfo.translationSwitch || [NSString isNil:userRoleAuthInfo.translationSwitch.configValue]) {
                NoaUsereAuthModel *model = [NoaUsereAuthModel new];
                model.configValue = @"true";
                userRoleAuthInfo.translationSwitch = model;
            }
            UserManager.userRoleAuthInfo = userRoleAuthInfo;
            if (![oldUpFileValue isEqualToString:UserManager.userRoleAuthInfo.upFile.configValue]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UserRoleAuthorityUploadFileChangeNotification" object:nil];
            }
            if (![oldDeleteMessageVaule isEqualToString:UserManager.userRoleAuthInfo.deleteMessage.configValue]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UserRoleAuthorityDeleteMessageChangeNotification" object:nil];
            }
            if (![oldShowTeamVaule isEqualToString:UserManager.userRoleAuthInfo.showTeam.configValue]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UserRoleAuthorityShowTeamChangeNotification" object:nil];
            }
            if (![oldUpImageVideoValue isEqualToString:UserManager.userRoleAuthInfo.upImageVideoFile.configValue]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UserRoleAuthorityUpImageVideoFileChangeNotification" object:nil];
            }
            if (![oldFileHelperValue isEqualToString:UserManager.userRoleAuthInfo.isShowFileAssistant.configValue]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UserRoleAuthorityFileHelperChangeNotification" object:nil];
            }
            if (![oldTranslateSwitch isEqualToString:UserManager.userRoleAuthInfo.translationSwitch.configValue]) {
                BOOL enabled = [UserManager.userRoleAuthInfo.translationSwitch.configValue isEqualToString:@"true"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UserRoleAuthorityTranslateFlagDidChange" object:nil userInfo:@{ @"enabled": @(enabled) }];
            }
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
    }];
}

//获取用户角色配置信息
- (void)requestGetRoleConfigInfo {
    [IMSDKManager imGetRoleConfigInfoWith:nil onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSArray class]]) {
            NSArray *dataArr = (NSArray *)data;
            NSArray *roleConfigArr = [NoaRoleConfigModel mj_objectArrayWithKeyValuesArray:dataArr];
            if (roleConfigArr != nil && roleConfigArr.count > 0) {
                NSMutableDictionary *roleConfigDict = [NSMutableDictionary dictionary];
                [roleConfigArr enumerateObjectsUsingBlock:^(NoaRoleConfigModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [roleConfigDict setObjectSafe:obj forKey:[NSNumber numberWithInteger:obj.roleId]];
                }];
                [UserManager setRoleConfigDict:roleConfigDict];
            }
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
    }];
}

//获取群聊活跃等级配置信息
- (void)requestGetGroupActivityLevelInfo {
    [[NoaIMSDKManager sharedTool] groupGetActivityLevelConfigWith:nil onSuccess:^(id  _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)data;
            NoaGroupActivityInfoModel *activityConfinModel = [NoaGroupActivityInfoModel mj_objectWithKeyValues:dict];
            NSArray *levelnfoArr = [activityConfinModel.levels copy];
            activityConfinModel.sortLevels = [levelnfoArr sortedArrayUsingComparator:^NSComparisonResult(NoaGroupActivityLevelModel *obj1, NoaGroupActivityLevelModel *obj2) {
                if (obj1.minScore < obj2.minScore) {
                    return NSOrderedAscending;
                } else if (obj1.minScore > obj2.minScore) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedSame;
                }
            }];
            UserManager.activityConfigInfo = activityConfinModel;
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
    }];
}

//获取当前登录用户信息
- (void)requestGetCurrentLoginUserInfo {
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    [IMSDKManager getUserInfoWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *userDict = (NSDictionary *)data;
            NoaUserModel *tempUserModel = [NoaUserModel mj_objectWithKeyValues:userDict];
            NoaUserModel *currentUserModel = [NoaUserModel getUserInfo];
            tempUserModel.token = currentUserModel.token;
            tempUserModel.userUID = currentUserModel.userUID;
            tempUserModel.descRemark = currentUserModel.descRemark;
            tempUserModel.remarks = currentUserModel.remarks;
            tempUserModel.showName = currentUserModel.showName;
            tempUserModel.yuueeAccount = currentUserModel.yuueeAccount;
            [UserManager setUserInfo:tempUserModel];
            [weakSelf.viewTop viewAppearUpdateUI];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if (offsetY > DWScale(68) * 5 + DWScale(50)) {
        self.btnTop.hidden = NO;
    }else {
        self.btnTop.hidden = YES;
    }
    
    if (offsetY > self.lastContentOffset) {
        //向下滑动
        
        NSInteger row = self.sessionTopList.count / 5;
        NSInteger yu = self.sessionTopList.count % 5;
        CGFloat height = yu > 0 ? (row + 1) * DWScale(73) : row * DWScale(73);
        CGFloat topHeight = height + DWScale(10);
        
        if (self.lastContentOffset - topHeight - (self.currentIndex - 1) * 6800 > 3400) {
            self.currentIndex = self.currentIndex + 1;
        }
    } else if (offsetY < self.lastContentOffset) {
        //向上滑动
    }
    self.lastContentOffset = offsetY;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentSessionList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaSessionCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NoaSessionCell class]) forIndexPath:indexPath];
    cell.cellIndexPath = indexPath;
    cell.cellDelegate = self;
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    __block LingIMSessionModel *model;
    if (self.currentSessionList != nil && indexPath.row < self.currentSessionList.count) {
        model = [self.currentSessionList objectAtIndex:indexPath.row];
    }
    cell.model = model;
    WeakSelf
    [cell setClearSessionBlock:^{
        if (model.sessionType == CIMSessionTypeSignInReminder) {
            return;
        }
        /*
        LingIMChatMessageModel *lastMessageModel = [IMSDKManager toolGetOneChatMessageWithMessageID:model.sessionLatestMessage.msgID sessionID:model.sessionID];
        lastMessageModel.chatMessageReaded = YES;
        [IMSDKManager toolInsertOrUpdateChatMessageWith:lastMessageModel];
        
        CIMChatType chatType;
        SyncMutableArray *unReadSmsgidList = [[SyncMutableArray alloc] init];
        if (model.sessionType == CIMSessionTypeSingle) {
            chatType = CIMChatType_SingleChat;
        } else {
            chatType = CIMChatType_GroupChat;
        }
        NSString *sMsgIdAndSendUid = [NSString stringWithFormat:@"%@_%@_%@", model.sessionLatestMessage.serviceMsgID, model.sessionLatestMessage.fromID, model.sessionLatestMessage.msgID];
        [unReadSmsgidList addObject:sMsgIdAndSendUid];
        LingIMChatMessageModel *uploadReadedMesage = [NoaMessageSendHander ZMessageReadedWithMsgSidList:[unReadSmsgidList safeArray] withToUserId:model.sessionID withChatType:chatType];
         [IMSDKManager toolSendChatMessageWith:uploadReadedMesage];
        */
        
        [weakSelf sessionUpdateReadedStatusWith:model isClear:YES];
        
        //本地以 key -value方式，记录一个属性 clearReadNumSMsgId
        [NoaSessionReadTool updateSessionReadNumSMsgIdWithSessionId:model.sessionID lastSMsgId:model.sessionLatestMessage.serviceMsgID];
    }];
    return cell;
}

#pragma mark - ZSessionCellDelegate cell点击事件
- (void)cellDidSelectRow {
    self.isClicked = NO;
}

- (void)cellClickAction:(NSIndexPath *)indexPath {
    if (self.isClicked == NO) {
        self.isClicked = YES;
        [self performSelector:@selector(cellDidSelectRow) withObject:nil afterDelay:0.5];
        
        LingIMSessionModel *model = [self.currentSessionList objectAtIndex:indexPath.row];
        
        if (model.sessionType == CIMSessionTypeSingle) {
            //单聊
            if ([model.sessionID isEqualToString:@"100002"]) {
                //单聊 文件助手
                CoHereFileHelperViewController *vc = [CoHereFileHelperViewController new];
                vc.sessionID = model.sessionID;
                [self.navigationController pushViewController:vc animated:YES];
            }else {
                //单聊 好友聊天
                NoaChatViewController *vc = [NoaChatViewController new];
                vc.chatName = model.sessionName;
                vc.sessionID = model.sessionID;
                vc.chatType = CIMChatType_SingleChat;
                __weak typeof(self) weakSelf = self;
                vc.draftDidChange = ^(NSString * _Nonnull sessionId, NSDictionary * _Nonnull draft) {
                    // 点对点刷新对应行
                    [weakSelf refreshRowForSessionId:sessionId];
                };
                [self.navigationController pushViewController:vc animated:YES];
                
                //更新一下数据
                if (model.sessionUnreadCount > 0) {
                    model.sessionUnreadCount = 0;
                    [IMSDKManager toolUpdateSessionWith:model];
                }
                [self sessionUpdateReadedStatusWith:model isClear:YES];
                
                //本地以 key -value方式，记录一个属性 clearReadNumSMsgId
                [NoaSessionReadTool updateSessionReadNumSMsgIdWithSessionId:model.sessionID lastSMsgId:model.sessionLatestMessage.serviceMsgID];
            }
        }
        
        if (model.sessionType == CIMSessionTypeGroup) {
            //群聊
            LingIMGroupModel *localGroupModel = [IMSDKManager toolCheckMyGroupWith:model.sessionID];
            LingIMGroup *groupInfo = [NoaMessageTools DBGroupModelToNetWorkGroupModel:localGroupModel];
            NoaChatViewController *vc = [NoaChatViewController new];
            vc.groupInfo = groupInfo;
            vc.chatName = model.sessionName;
            vc.sessionID = model.sessionID;
            vc.chatType = CIMChatType_GroupChat;
            __weak typeof(self) weakSelf = self;
            vc.draftDidChange = ^(NSString * _Nonnull sessionId, NSDictionary * _Nonnull draft) {
                [weakSelf refreshRowForSessionId:sessionId];
            };
            [self.navigationController pushViewController:vc animated:YES];
            
            //更新一下数据
            if (model.sessionUnreadCount > 0) {
                model.sessionUnreadCount = 0;
                [IMSDKManager toolUpdateSessionWith:model];
            }
            [self sessionUpdateReadedStatusWith:model isClear:YES];
            
            //本地以 key -value方式，记录一个属性 clearReadNumSMsgId
            [NoaSessionReadTool updateSessionReadNumSMsgIdWithSessionId:model.sessionID lastSMsgId:model.sessionLatestMessage.serviceMsgID];
        }
        
        if (model.sessionType == CIMSessionTypeMassMessage) {
            //群发助手
            NoaMassMessageVC *vc = [NoaMassMessageVC new];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
        if (model.sessionType == CIMSessionTypeSystemMessage) {
            //系统消息(群助手)
            NoaSystemMessageVC *vc = [NoaSystemMessageVC new];
            vc.groupHelperType = ZGroupHelperFormTypeSessionList;
            vc.groupId = @"";
            vc.sessionModel = model;
            [self.navigationController pushViewController:vc animated:YES];
            
            //更新一下数据
            if (model.sessionUnreadCount > 0) {
                model.sessionUnreadCount = 0;
                [IMSDKManager toolUpdateSessionWith:model];
            }
        }
        
        if (model.sessionType == CIMSessionTypeSignInReminder) {
            //签到提醒
            NoaSignInMessageViewController *signInVC = [NoaSignInMessageViewController new];
            signInVC.sessionID = model.sessionID;
            [self.navigationController pushViewController:signInVC animated:YES];
            
            //更新一下数据
            if (model.sessionUnreadCount > 0) {
                model.sessionUnreadCount = 0;
                [IMSDKManager toolUpdateSessionWith:model];
            }
        }
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DWScale(68);
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.sessionTopList.count > 0) {
        NoaSessionHeaderView *viewHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([NoaSessionHeaderView class])];
        viewHeader.sessionTopList = self.sessionTopList.safeArray;
        return viewHeader;
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.sessionTopList.count > 0) {
        NSInteger row = self.sessionTopList.count / 5;
        NSInteger yu = self.sessionTopList.count % 5;
        CGFloat height = yu > 0 ? (row + 1) * DWScale(73) : row * DWScale(73);
        return height + DWScale(10);
    }
    
    return CGFLOAT_MIN;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self cellClickAction:indexPath];
}


#pragma mark - MGSwipeTableCellDelegate
- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell canSwipe:(MGSwipeDirection)direction fromPoint:(CGPoint)point {
    return YES;
}
- (NSArray<UIView *> *)swipeTableCell:(MGSwipeTableCell *)cell swipeButtonsForDirection:(MGSwipeDirection)direction swipeSettings:(MGSwipeSettings *)swipeSettings expansionSettings:(MGSwipeExpansionSettings *)expansionSettings {
    
    NSIndexPath *cellIndex = [self.baseTableView indexPathForCell:cell];
    LingIMSessionModel *model = [self.currentSessionList objectAtIndex:cellIndex.row];
    
    //群发助手 不能删除，置顶，消息免打扰
    if (model.sessionType == CIMSessionTypeMassMessage) return nil;
    //系统消息(群助手) 不能删除，置顶，消息免打扰
    if (model.sessionType == CIMSessionTypeSystemMessage) return nil;
    //系统消息(签到提醒) 不能删除，置顶，消息免打扰
    if (model.sessionType == CIMSessionTypeSignInReminder) return nil;
    
    swipeSettings.transition = MGSwipeTransitionBorder;//动画效果
    swipeSettings.enableSwipeBounces = NO;
    swipeSettings.allowsButtonsWithDifferentWidth = YES;
    expansionSettings.buttonIndex = -1;//可展开按钮索引，即滑动自动触发按钮下标
    expansionSettings.fillOnTrigger = NO;//是否填充
    expansionSettings.threshold = 1.0;//触发阈值
    
    WeakSelf
    if (ZLanguageTOOL.isRTL) {
        if (direction == MGSwipeDirectionRightToLeft) {
            //从右到左滑动
            MGSwipeButton *btnTop;
            if (model.sessionTop) {
                //取消置顶
                btnTop = [MGSwipeButton buttonWithTitle:LanguageToolMatch(@"取消置顶") icon:ImgNamed(@"s_top_no") backgroundColor:COLOR_737780 callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
                    [weakSelf sessionTopWith:model];
                    return NO;
                }];
            }else {
                //置顶
                btnTop = [MGSwipeButton buttonWithTitle:LanguageToolMatch(@"置顶") icon:ImgNamed(@"s_top_yes") backgroundColor:COLOR_5966F2 callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
                    [weakSelf sessionTopWith:model];
                    return NO;
                }];
            }
            if ([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"阿拉伯语"]) {
                btnTop.titleLabel.font = FONTR(8);
            } else {
                btnTop.titleLabel.font = FONTR(10);
            };
            btnTop.buttonWidth = DWScale(86);
            [btnTop setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:5];
            
            MGSwipeButton *btnDisturb;
            if (model.sessionNoDisturb) {
                //关闭消息免打扰
                btnDisturb = [MGSwipeButton buttonWithTitle:LanguageToolMatch(@"取消免打扰") icon:ImgNamed(@"s_notice_close") backgroundColor:COLOR_737780 callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
                    [weakSelf sessionPromtWith:model];
                    return NO;
                }];
            }else {
                //开启消息免打扰
                btnDisturb = [MGSwipeButton buttonWithTitle:LanguageToolMatch(@"免打扰") icon:ImgNamed(@"s_notice_open") backgroundColor:COLOR_0ABF83 callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
                    [weakSelf sessionPromtWith:model];
                    return NO;
                }];
            }
            if ([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"阿拉伯语"]) {
                btnDisturb.titleLabel.font = FONTR(8);
            } else {
                btnDisturb.titleLabel.font = FONTR(10);
            };
            btnDisturb.buttonWidth = DWScale(86);
            [btnDisturb setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:5];

            if (model.sessionType == CIMSessionTypeSingle) {
                if ([model.sessionID isEqualToString:@"100002"]) {
                    //单聊 文件助手只有置顶
                    return @[btnTop];
                }else {
                    return @[btnTop,btnDisturb];
                }
                
            }else {
                //群聊
                return @[btnTop,btnDisturb];
            }
        } else {
            //从右到左滑动
            NSString *btnReadedTtitle = @"";
            UIImage *btnReadedImage;
            UIColor *btnReadedBackgroundColor;
            BOOL clearReaded; //操作项的状态，YES:点击时清除未读   NO:点击时标记未读
            if (model.sessionUnreadCount > 0) {
                btnReadedTtitle = LanguageToolMatch(@"清除未读");
                btnReadedImage = ImgNamed(@"s_clear_readed");
                btnReadedBackgroundColor = COLOR_737780;
                clearReaded = YES;
            } else {
                if (model.readTag == 0) {
                    //readTag == 0，代表当前会话是清除未读的状态，未读数为0，右滑菜单显示标记未读
                    btnReadedTtitle = LanguageToolMatch(@"标记未读");
                    btnReadedImage = ImgNamed(@"s_sign_unread");
                    btnReadedBackgroundColor = COLOR_0AC3CF;
                    clearReaded = NO;
                } else {
                    //readTag == 1，代表当前会话是标记未读的状态，未读数为1，右滑菜单显示清除未读
                    btnReadedTtitle = LanguageToolMatch(@"清除未读");
                    btnReadedImage = ImgNamed(@"s_clear_readed");
                    btnReadedBackgroundColor = COLOR_737780;
                    clearReaded = YES;
                }
            }
            MGSwipeButton *btnReaded = [MGSwipeButton buttonWithTitle:btnReadedTtitle icon:btnReadedImage backgroundColor:btnReadedBackgroundColor callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
                //处理 标记未读 / 清除未读
                [weakSelf sessionUpdateReadedStatusWith:model isClear:NO];
                return NO;
            }];
            if ([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"阿拉伯语"]) {
                btnReaded.titleLabel.font = FONTR(8);
            } else {
                btnReaded.titleLabel.font = FONTR(10);
            };
            btnReaded.buttonWidth = DWScale(86);
            [btnReaded setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:5];
            
            MGSwipeButton *btnDelete = [MGSwipeButton buttonWithTitle:LanguageToolMatch(@"删除") icon:ImgNamed(@"s_session_delete") backgroundColor:COLOR_F93A2F callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
                [weakSelf sessionDeleteWith:model];
                return NO;
            }];
            if ([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"阿拉伯语"]) {
                btnDelete.titleLabel.font = FONTR(8);
            } else {
                btnDelete.titleLabel.font = FONTR(10);
            }
            btnDelete.buttonWidth = DWScale(86);
            [btnDelete setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:5];
            
            if (model.sessionType == CIMSessionTypeSingle) {
                if ([model.sessionID isEqualToString:@"100002"]) {
                    //单聊 文件助手只有删除
                    return @[btnDelete];
                }else {
                    return @[btnDelete,btnReaded];
                }
            } else {
                //群聊
                return @[btnDelete,btnReaded];
            }
        }
    } else {
        if (direction == MGSwipeDirectionLeftToRight) {
            //从左到右滑动
            MGSwipeButton *btnTop;
            if (model.sessionTop) {
                //取消置顶
                btnTop = [MGSwipeButton buttonWithTitle:LanguageToolMatch(@"取消置顶") icon:ImgNamed(@"s_top_no") backgroundColor:COLOR_737780 callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
                    [weakSelf sessionTopWith:model];
                    return NO;
                }];
            }else {
                //置顶
                btnTop = [MGSwipeButton buttonWithTitle:LanguageToolMatch(@"置顶") icon:ImgNamed(@"s_top_yes") backgroundColor:COLOR_5966F2 callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
                    [weakSelf sessionTopWith:model];
                    return NO;
                }];
            }
            if ([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"阿拉伯语"]) {
                btnTop.titleLabel.font = FONTR(8);
            } else {
                btnTop.titleLabel.font = FONTR(10);
            };
            btnTop.buttonWidth = DWScale(86);
            [btnTop setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:5];
            
            MGSwipeButton *btnDisturb;
            if (model.sessionNoDisturb) {
                //关闭消息免打扰
                btnDisturb = [MGSwipeButton buttonWithTitle:LanguageToolMatch(@"取消免打扰") icon:ImgNamed(@"s_notice_close") backgroundColor:COLOR_737780 callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
                    [weakSelf sessionPromtWith:model];
                    return NO;
                }];
            }else {
                //开启消息免打扰
                btnDisturb = [MGSwipeButton buttonWithTitle:LanguageToolMatch(@"免打扰") icon:ImgNamed(@"s_notice_open") backgroundColor:COLOR_0ABF83 callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
                    [weakSelf sessionPromtWith:model];
                    return NO;
                }];
            }
            if ([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"阿拉伯语"]) {
                btnDisturb.titleLabel.font = FONTR(8);
            } else {
                btnDisturb.titleLabel.font = FONTR(10);
            };
            btnDisturb.buttonWidth = DWScale(86);
            [btnDisturb setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:5];
            
            if (model.sessionType == CIMSessionTypeSingle) {
                if ([model.sessionID isEqualToString:@"100002"]) {
                    //单聊 文件助手只有置顶
                    return @[btnTop];
                } else {
                    return @[btnTop,btnDisturb];
                }
            }else {
                //群聊
                return @[btnTop,btnDisturb];
            }
            
        }else {
            //从右到左滑动
            NSString *btnReadedTtitle = @"";
            UIImage *btnReadedImage;
            UIColor *btnReadedBackgroundColor;
            BOOL clearReaded;  //操作项的状态，YES:点击时清除未读   NO:点击时标记未读
            if (model.sessionUnreadCount > 0) {
                btnReadedTtitle = LanguageToolMatch(@"清除未读");
                btnReadedImage = ImgNamed(@"s_clear_readed");
                btnReadedBackgroundColor = COLOR_737780;
                clearReaded = YES;
            } else {
                if (model.readTag == 0) {
                    //readTag == 0，代表当前会话是清除未读的状态，未读数为0，右滑菜单显示标记未读
                    btnReadedTtitle = LanguageToolMatch(@"标记未读");
                    btnReadedImage = ImgNamed(@"s_sign_unread");
                    btnReadedBackgroundColor = COLOR_0AC3CF;
                    clearReaded = NO;
                } else {
                    //readTag == 1，代表当前会话是标记未读的状态，未读数为1，右滑菜单显示清除未读
                    btnReadedTtitle = LanguageToolMatch(@"清除未读");
                    btnReadedImage = ImgNamed(@"s_clear_readed");
                    btnReadedBackgroundColor = COLOR_737780;
                    clearReaded = YES;
                }
            }
            MGSwipeButton *btnReaded = [MGSwipeButton buttonWithTitle:btnReadedTtitle icon:btnReadedImage backgroundColor:btnReadedBackgroundColor callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
                //处理 标记未读 / 清除未读
                [weakSelf sessionUpdateReadedStatusWith:model isClear:NO];
                return NO;
            }];
            if ([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"阿拉伯语"]) {
                btnReaded.titleLabel.font = FONTR(8);
            } else {
                btnReaded.titleLabel.font = FONTR(10);
            };
            btnReaded.buttonWidth = DWScale(86);
            [btnReaded setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:5];
            
            MGSwipeButton *btnDelete = [MGSwipeButton buttonWithTitle:LanguageToolMatch(@"删除") icon:ImgNamed(@"s_session_delete") backgroundColor:COLOR_F93A2F callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
                [weakSelf sessionDeleteWith:model];
                return NO;
            }];
            if ([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"阿拉伯语"]) {
                btnDelete.titleLabel.font = FONTR(8);
            } else {
                btnDelete.titleLabel.font = FONTR(10);
            };
            btnDelete.buttonWidth = DWScale(86);
            [btnDelete setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:5];
            
            if (model.sessionType == CIMSessionTypeSingle) {
                if ([model.sessionID isEqualToString:@"100002"]) {
                    //单聊 文件助手只有删除
                    return @[btnDelete];
                } else {
                    return @[btnDelete,btnReaded];
                }
            } else {
                //群聊
                return @[btnDelete,btnReaded];
            }
        }
    }
}

- (void)swipeTableCell:(MGSwipeTableCell *)cell didChangeSwipeState:(MGSwipeState)state gestureIsActive:(BOOL)gestureIsActive {
    NSString * str;
    switch (state) {
        case MGSwipeStateNone: str = @"None"; break;
        case MGSwipeStateSwippingLeftToRight: str = @"右滑"; break;
        case MGSwipeStateSwippingRightToLeft: str = @"左滑"; break;
        case MGSwipeStateExpandingLeftToRight: str = @"右滑展开"; break;
        case MGSwipeStateExpandingRightToLeft: str = @"左滑展开"; break;
    }
    DLog(@"手势状态:%@------%@",str, gestureIsActive ? @"开始" : @"结束");
}

#pragma mark - DZNEmptyDataSetSource
//图片距离中心偏移量
- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return DWScale(-120);
}
//空态图片
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return ImgNamed(@"c_no_history_chat");
}

#pragma mark - DZNEmptyDataSetDelegate
//允许滑动
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}

#pragma mark - CIMToolSessionDelegate
- (void)cimToolSessionListUpdateWith:(NSArray <LingIMSessionModel *> *)modelList topSessionList:(NSArray <LingIMSessionModel *> *)topSessionList isFirstPage:(BOOL)isFirstPage {
    if (isFirstPage) {
        [self.sessionList replaceAllObjectsWithArray:@[]];
        [self.sessionTopList replaceAllObjectsWithArray:@[]];
    }
    [self.sessionList addObjectsFromArray:modelList];
    [self.sessionTopList addObjectsFromArray:topSessionList];
    if (isFirstPage) {
        self.currentIndex = 1;
    }
}

- (void)imSdkSessionSyncStart {
//    _viewTop.showLoading = YES;
}

-(void)handleFun{
    NSArray *sessionListSnapshot = [self.sessionList safeArray];
    NSMutableArray <NoaIMChatMessageModel *>*allSessionLatestMessageArr = [NSMutableArray new];
    [sessionListSnapshot enumerateObjectsUsingBlock:^(LingIMSessionModel *obj, NSUInteger idx, BOOL *stop) {
        if (obj) {
            [allSessionLatestMessageArr addObject:obj.sessionLatestMessage];
        }
    }];
    
    [[NoaIMSDKManager sharedTool] toolInsertOrUpdateChatMessagesWith:allSessionLatestMessageArr];
}

//DLog(@"服务端同步会话列表成功");
- (void)imSdkSessionSyncFinish {
    WeakSelf
    _viewTop.showLoading = NO;
    NSArray* tempList = [self.sessionList.safeArray copy];
    dispatch_async(self.sessionListUpdateQueue, ^{
        __block BOOL signHelperFlag = NO;
        NSMutableArray <NoaIMChatMessageModel *>*allSessionLatestMessageArr = [NSMutableArray new];
        [tempList enumerateObjectsUsingBlock:^(LingIMSessionModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj && obj.sessionLatestMessage != nil) {
                if (obj.sessionLatestMessage.messageType == CIMChatMessageType_BackMessage) {
                    if (obj.sessionLatestMessage.backDelInformSwitch != 2) {
                        [allSessionLatestMessageArr addObject:obj.sessionLatestMessage];
                    }
                } else {
                    [allSessionLatestMessageArr addObject:obj.sessionLatestMessage];
                }
            }
            if ([obj.sessionID isEqualToString:@"100003"]) {
                signHelperFlag = YES;
            }
        }];
        
        [[NoaIMSDKManager sharedTool] toolInsertOrUpdateChatMessagesWith:allSessionLatestMessageArr];
        
        //检查有没有签到助手
        if (signHelperFlag == NO) {
            LingIMSessionModel *signHelperSessionModel = [IMSDKManager toolCheckMySessionWith:@"100003"];
            if (signHelperSessionModel) {
                [weakSelf.sessionList addObject:signHelperSessionModel];
            }
        }
        [weakSelf checkIsShowFileHelpSession];
        [weakSelf refreshTableViewForSort:YES];
    });
}

//DLog(@"服务端同步会话列表失败:%@",errorMsg);
- (void)imSdkSessionSyncFailed:(NSString *)errorMsg {
    _viewTop.showLoading = NO;
    //从本地数据库加载之前缓存过的数据
    NSLog(@"服务端同步会话列表失败");
    if (self.sessionList.count > 0) {
        [self imSdkSessionSyncFinish];
    }else{
        [self getSessionListFromDB];
    }
   
}

//DLog(@"接收到新的会话:%@",model.sessionName);
- (void)cimToolSessionReceiveWith:(LingIMSessionModel *)model {
    WeakSelf
    dispatch_async(self.sessionListUpdateQueue, ^{
        StrongSelf
        //会话列表新增
        [strongSelf.sessionList insertObject:model atIndex:0];
        //如果新增的是置顶会话
        if (model.sessionTop) {
            [strongSelf.sessionTopList insertObject:model atIndex:0];
        }
        [strongSelf refreshTableViewForSort:NO];
    });
}

//DLog(@"某会话需要更新:%@",model.sessionName);
- (void)cimToolSessionUpdateWith:(LingIMSessionModel *)model {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    WeakSelf
    dispatch_async(self.sessionListUpdateQueue, ^{
        StrongSelf
        /*
        __block BOOL isHave = NO;
        //更新会话列表
        [weakSelf.sessionList enumerateObjectsUsingBlock:^(LingIMSessionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.sessionID isEqualToString:model.sessionID]) {
                if (obj.sessionTop != model.sessionTop) {
                    [strongSelf.sessionTopList removeAllObjects];
                    [strongSelf.sessionTopList addObjectsFromArray:[IMSDKManager toolGetMyTopSessionList]];
                }
                //如果有 更新数据
                [strongSelf.sessionList replaceObjectAtIndex:idx withObject:model];
                isHave = YES;
                *stop = YES;
                dispatch_semaphore_signal(semaphore);
            }
        }];
        */
        BOOL isHave = NO;
        BOOL isHaveFileHelper = NO;
        NSString *fileHelperSessionId = @"";
        if ([UserManager.userRoleAuthInfo.isShowFileAssistant.configValue isEqualToString:@"true"]) {
            fileHelperSessionId = @"100002";
            isHaveFileHelper = YES;
        } else {
            fileHelperSessionId = @"100002";
            isHaveFileHelper = NO;
        }
        for (int i = 0; i < strongSelf.sessionList.count; i++) {
            LingIMSessionModel *obj = (LingIMSessionModel *)[strongSelf.sessionList objectAtIndex:i];
            if ([obj.sessionID isEqualToString:model.sessionID]) {
                if (obj.sessionTop != model.sessionTop) {
                    [strongSelf.sessionTopList removeAllObjects];
                    if (isHaveFileHelper) {
                        [strongSelf.sessionTopList addObjectsFromArray:[IMSDKManager toolGetMyTopSessionListExcept:@""]];
                    } else {
                        [strongSelf.sessionTopList addObjectsFromArray:[IMSDKManager toolGetMyTopSessionListExcept:fileHelperSessionId]];
                    }
                }
                //如果有 更新数据
                [strongSelf.sessionList replaceObjectAtIndex:i withObject:model];
                isHave = YES;
                dispatch_semaphore_signal(semaphore);
                break;
            }
        }
        if (isHave == NO) {
            //会话列表新增
            if (isHaveFileHelper) {
                [strongSelf.sessionList insertObject:model atIndex:0];
            }
            dispatch_semaphore_signal(semaphore);
        }
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        // 主线程行级刷新：定位变动的行，移动并刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            // 重新排序数据源
            [strongSelf refreshTableViewForSort:YES];
        });
    });
}

//DLog(@"某会话已被删除:%@",model.sessionName);
- (void)cimToolSessionDeleteWith:(LingIMSessionModel *)model {
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.sessionListUpdateQueue, ^{
        // 使用 safeArray 获取快照，避免在遍历时修改数组导致崩溃
        // 如果删除的会话是置顶的
        if (model.sessionTop) {
            // 1. 获取置顶列表的快照副本
            NSArray *topListSnapshot = [weakSelf.sessionTopList safeArray];
            __block LingIMSessionModel *targetModelInTopList = nil;
            
            // 2. 在快照上遍历查找
            [topListSnapshot enumerateObjectsUsingBlock:^(LingIMSessionModel *obj, NSUInteger idx, BOOL *stop) {
                @try {
                    if (obj && [obj.sessionID isEqualToString:model.sessionID]) {
                        targetModelInTopList = obj;
                        *stop = YES;
                    }
                } @catch (NSException *exception) {
                    CIMLog(@"⚠️ [会话列表] cimToolSessionDeleteWith 置顶列表遍历异常: %@", exception);
                }
            }];
            
            // 3. 遍历结束后删除
            if (targetModelInTopList) {
                [weakSelf.sessionTopList removeObject:targetModelInTopList];
            }
        }
        
        // 会话列表删除
        // 1. 获取会话列表的快照副本
        NSArray *sessionListSnapshot = [weakSelf.sessionList safeArray];
        __block LingIMSessionModel *targetModelInSessionList = nil;
        
        // 2. 在快照上遍历查找
        [sessionListSnapshot enumerateObjectsUsingBlock:^(LingIMSessionModel *obj, NSUInteger idx, BOOL *stop) {
            @try {
                if (obj && [obj.sessionID isEqualToString:model.sessionID]) {
                    targetModelInSessionList = obj;
                    *stop = YES;
                }
            } @catch (NSException *exception) {
                CIMLog(@"⚠️ [会话列表] cimToolSessionDeleteWith 会话列表遍历异常: %@", exception);
            }
        }];
        
        // 3. 遍历结束后删除
        if (targetModelInSessionList) {
            [weakSelf.sessionList removeObject:targetModelInSessionList];
        }
        
        [weakSelf refreshTableViewForSort:YES];
    });
    
}

- (void)removePaymentAssistantModel {
    // ✅ 修复：使用 safeArray 获取快照，避免在遍历时修改数组导致崩溃
    
    // 1. 获取 sessionList 的快照副本（线程安全）
    NSArray *sessionListSnapshot = [self.sessionList safeArray];
    __block LingIMSessionModel *paymentModelInSessionList = nil;
    
    // 2. 在快照上遍历查找（不会影响原数组）
    [sessionListSnapshot enumerateObjectsUsingBlock:^(LingIMSessionModel *obj, NSUInteger idx, BOOL *stop) {
        @try {
            if (obj && obj.sessionType == CIMSessionTypePaymentAssistant) {
                paymentModelInSessionList = obj;
                *stop = YES;
            }
        } @catch (NSException *exception) {
            CIMLog(@"⚠️ [会话列表] removePaymentAssistantModel 遍历异常: %@", exception);
        }
    }];
    
    // 3. 遍历结束后，再从原数组删除（线程安全的异步操作）
    if (paymentModelInSessionList) {
        [self.sessionList removeObject:paymentModelInSessionList];
    }
    
    // 4. 对 sessionTopList 做同样处理
    NSArray *topListSnapshot = [self.sessionTopList safeArray];
    __block LingIMSessionModel *paymentModelInTopList = nil;
    
    [topListSnapshot enumerateObjectsUsingBlock:^(LingIMSessionModel *obj, NSUInteger idx, BOOL *stop) {
        @try {
            if (obj && obj.sessionType == CIMSessionTypePaymentAssistant) {
                paymentModelInTopList = obj;
                *stop = YES;
            }
        } @catch (NSException *exception) {
            CIMLog(@"⚠️ [会话列表] removePaymentAssistantModel 置顶列表遍历异常: %@", exception);
        }
    }];
    
    if (paymentModelInTopList) {
        [self.sessionTopList removeObject:paymentModelInTopList];
    }
}

- (void)checkIsShowFileHelpSession {
    //先检查是否已经有文件助手
    __block BOOL sessionListHasFileHelper = NO;
    __block BOOL sessionTopListHasFileHelper = NO;
    WeakSelf
    [self.sessionList enumerateObjectsUsingBlock:^(LingIMSessionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.sessionID isEqualToString:@"100002"]) {
            sessionListHasFileHelper = YES;
            *stop = YES;
        }
    }];
    
    [self.sessionTopList enumerateObjectsUsingBlock:^(LingIMSessionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.sessionID isEqualToString:@"100002"]) {
            sessionTopListHasFileHelper = YES;
            *stop = YES;
        }
    }];
    
    if ([UserManager.userRoleAuthInfo.isShowFileAssistant.configValue isEqualToString:@"true"]) {
        LingIMSessionModel *fileHelperSessionModel = [IMSDKManager toolCheckMySessionWith:@"100002"];
        if (fileHelperSessionModel) {
            if (sessionListHasFileHelper == NO) {
                [self.sessionList addObject:fileHelperSessionModel];
            }
            if (fileHelperSessionModel.sessionTop && sessionTopListHasFileHelper == NO) {
                [self.sessionTopList addObject:fileHelperSessionModel];
            }
        }
    } else {
        //会话列表
        if (sessionListHasFileHelper) {
            [self.sessionList enumerateObjectsUsingBlock:^(LingIMSessionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.sessionID isEqualToString:@"100002"]) {
                    [weakSelf.sessionList removeObjectAtIndex:idx];
                    *stop = YES;
                }
            }];
        }
        
        //会话置顶列表
        if (sessionTopListHasFileHelper) {
            [self.sessionTopList enumerateObjectsUsingBlock:^(LingIMSessionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.sessionID isEqualToString:@"100002"]) {
                    [weakSelf.sessionTopList removeObjectAtIndex:idx];
                    *stop = YES;
                }
            }];
        }
    }
}

/// 会话列表 用户角色权限发生变化，需要更新用户角色权限
- (void)imSdkSessionUpdateUserRoleAuthority {
    //重新获取当前用户的角色权限
    [self requestGetUserRoleAuthorityInfo];
    //重新获取用户角色配置信息
    [self requestGetRoleConfigInfo];
}

/// 会话列表全部已读
- (void)imSdkSessionListAllRead:(NSString *)lastServerMsgId {
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.sessionListUpdateQueue, ^{
        [weakSelf sessionListAllRead:lastServerMsgId];
    });
}

#pragma mark userDelgate
/// 用户头像更新
- (void)cimUserUpdateAvatar:(NSString *)avatar {
    NoaUserModel *userModel = [NoaUserModel getUserInfo];
    userModel.avatar = avatar;
    [userModel saveUserInfo];
    UserManager.userInfo.avatar = avatar;
    [_viewTop viewAppearUpdateUI];
}

/// 用户昵称更新
- (void)cimUserUpdateNickName:(NSString *)nickName {
    NoaUserModel *userModel = [NoaUserModel getUserInfo];
    userModel.nickname = nickName;
    [userModel saveUserInfo];
    UserManager.userInfo.nickname = nickName;
    [_viewTop viewAppearUpdateUI];
}

#pragma mark - ******交互事件******
//列表滚动到顶部
- (void)btnTopClick {
    [self.baseTableView setContentOffset:CGPointMake(0, 0) animated:NO];
    self.currentIndex = 1;
}


//会话置顶
- (void)sessionTopWith:(LingIMSessionModel *)model {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    
    if (model.sessionTop) {
        //取消置顶的操作
        [dict setValue:@(0) forKey:@"status"];
    }else {
        //置顶操作
        [dict setValue:@(1) forKey:@"status"];
    }
    
    WeakSelf
    if (model.sessionType == CIMSessionTypeSingle) {
        //单聊
        [dict setValue:model.sessionID forKey:@"friendUserUid"];
        [[NoaIMSDKManager sharedTool] singleConversationTop:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            //更新操作，已放在SDK里，用户无感实现
            [weakSelf sessionTopUpdateWith:model];
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            [HUD showMessageWithCode:code errorMsg:msg];
        }];
    }else{
        //群聊
        [dict setValue:model.sessionID forKey:@"groupId"];
        [[NoaIMSDKManager sharedTool] groupConversationTop:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            //更新操作，已放在SDK里，用户无感实现
            [weakSelf sessionTopUpdateWith:model];
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            [HUD showMessageWithCode:code errorMsg:msg];
        }];
    }
}
//会话消息免打扰
- (void)sessionPromtWith:(LingIMSessionModel *)model {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    
    if (model.sessionNoDisturb) {
        //取消免打扰的操作
        [dict setValue:@(0) forKey:@"status"];
    }else {
        //免打扰操作
        [dict setValue:@(1) forKey:@"status"];
    }
    
    if (model.sessionType == CIMSessionTypeSingle) {
        //单聊
        [dict setValue:model.sessionID forKey:@"friendUserUid"];
        [[NoaIMSDKManager sharedTool] singleConversationPromt:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            //更新操作，已放在SDK里，用户无感实现
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            [HUD showMessageWithCode:code errorMsg:msg];
        }];
    } else {
        //群聊
        [dict setValue:model.sessionID forKey:@"groupId"];
        [[NoaIMSDKManager sharedTool] groupConversationPromt:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            //更新操作，已放在SDK里，用户无感实现
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            [HUD showMessageWithCode:code errorMsg:msg];
        }];
    }
}
//会话已读
- (void)sessionMakeReadWith:(LingIMSessionModel *)model {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:model.sessionID forKey:@"peerUid"];
    if (![NSString isNil:UserManager.userInfo.userUID]) {
        [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    }
    if (model.sessionType == CIMSessionTypeSingle) {
        //单聊
        [dict setValue:@(0) forKey:@"dialogType"];
    }else {
        //群聊
        [dict setValue:@(1) forKey:@"dialogType"];
    }
    [[NoaIMSDKManager sharedTool] ackConversationRead:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [IMSDKManager toolOneSessionAllReadWith:model];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

- (void)sessionListAllRead:(NSString *)lastServerMsgId {
    [IMSDKManager toolSessionListAllRead];
    [NoaSessionReadTool updateAllSessionReadNumSMsgIdLastSMsgId:lastServerMsgId];
}

//会话删除
- (void)sessionDeleteWith:(LingIMSessionModel *)model {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:model.sessionID forKey:@"peerUid"];
    if (![NSString isNil:UserManager.userInfo.userUID]) {
        [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    }
    if (model.sessionType == CIMSessionTypeSingle) {
        //单聊
        [dict setValue:@(0) forKey:@"dialogType"];
    }else {
        //群聊
        [dict setValue:@(1) forKey:@"dialogType"];
    }
    [IMSDKManager deleteServerConversation:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        //删除会话成功后，仅删除本地的会话，不删除聊天记录
        [IMSDKManager toolDeleteSessionModelWith:model andDeleteAllChatModel:NO];
        
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

//会话置顶更新
- (void)sessionTopUpdateWith:(LingIMSessionModel *)sessionModel {
    WeakSelf
    dispatch_async(self.sessionListUpdateQueue, ^{
        if (sessionModel.sessionTop) {
            //执行取消置顶
            sessionModel.sessionTop = NO;
            sessionModel.sessionTopTime = 0;
            [weakSelf.sessionTopList enumerateObjectsUsingBlock:^(LingIMSessionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.sessionID isEqualToString:sessionModel.sessionID]) {
                    [weakSelf.sessionTopList removeObjectAtIndex:idx];
                    [ZTOOL doInMain:^{
                        [weakSelf.baseTableView reloadData];
                    }];
                    *stop = YES;
                }
            }];
            
        }else {
            //执行置顶操作
            sessionModel.sessionTop = YES;
            //毫秒
            NSDate *date = [NSDate date];
            long long time = [date timeIntervalSince1970] * 1000;
            sessionModel.sessionTopTime = time;
            [weakSelf.sessionTopList addObject:[sessionModel mutableCopy]];
            [ZTOOL doInMain:^{
                [weakSelf.baseTableView reloadData];
            }];
        }
    });
}

//会话 标记已读 / 标记未读 接口更新
- (void)sessionUpdateReadedStatusWith:(LingIMSessionModel *)sessionModel isClear:(BOOL)isClear {
    //dialogType：会话类型 单聊为0/群聊为1,
    NSInteger dialogType = 0;
    if (sessionModel.sessionType == CIMSessionTypeSingle) {
        dialogType = 0;
    }
    if (sessionModel.sessionType == CIMSessionTypeGroup) {
        dialogType = 1;
    }
    // readTag(当前会话状态)  0:标记已读 1标记未读
    NSInteger readTag = 0;
    if (isClear) {
        //清除真实未读数
        sessionModel.sessionUnreadCount = 0;
        //清除标记已读
        readTag = 0;
    } else {
        if (sessionModel.sessionUnreadCount > 0) {
            //清除真实未读数
            sessionModel.sessionUnreadCount = 0;
            //清除标记已读
            readTag = 0;
        } else {
            if (sessionModel.readTag == 0) {
                //当前是清除未读状态，没有未读数，将要设置为标记未读状态，readTag传1
                readTag = 1;
            }
            if (sessionModel.readTag == 1) {
                //当前是标记已读状态，有未读数，将要设置为清除未读状态，readTag传0
                readTag = 0;
            }
        }
    }

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    [dict setValue:sessionModel.sessionID forKey:@"peerUid"];
    [dict setValue:@(dialogType) forKey:@"dialogType"];
    [dict setValue:@(readTag) forKey:@"readTag"];
    [dict setValue:sessionModel.sessionLatestMessage.serviceMsgID forKey:@"latestSMsgId"];
    
    [IMSDKManager conversationReadedStatus:dict onSuccess:^(id  _Nullable data, NSString * _Nullable traceId) {
        sessionModel.readTag = readTag;
        [IMSDKManager toolUpdateSessionWith:sessionModel];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

- (void)requestClearSessionUnReadNumWithSession:(LingIMSessionModel *)sessionModel {
    
}

#pragma mark - 通知监听处理方法
//用户在线状态更新
- (void)myFriendOnlineStatusChange:(NSNotification *)sender {
    NSDictionary *userInfoDict = sender.userInfo;
    NSString *myFriendID = [userInfoDict objectForKeySafe:@"friendID"];
    WeakSelf
    [self.currentSessionList enumerateObjectsUsingBlock:^(LingIMSessionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.sessionID isEqualToString:myFriendID]) {
            //界面需要更新
            [weakSelf.baseTableView reloadData];
            *stop = YES;
        }
    }];
}

//群发助手最新消息变化
- (void)latestMassMessageChange {
    NSString *userKey = [NSString stringWithFormat:@"%@-MassMessage", UserManager.userInfo.userUID];
    NSString *jsonStr = [[MMKV defaultMMKV] getStringForKey:userKey];
    
    if (![NSString isNil:jsonStr]) {
        NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if (!error) {
            LIMMassMessageModel *massMessageModel = [LIMMassMessageModel mj_objectWithKeyValues:dict];
            if (massMessageModel) {
                [self.sessionList enumerateObjectsUsingBlock:^(LingIMSessionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.sessionType == CIMSessionTypeMassMessage) {
                        //群发助手，更新时间排序
                        obj.sessionLatestTime = [NSString dateFromTimeDate:massMessageModel.sendTime formatter:@"YYYY-MM-dd HH:mm:ss"];
                        obj.sessionLatestMassMessage = massMessageModel;
                        [IMSDKManager toolUpdateSessionWith:obj];
                        *stop = YES;
                    }
                }];
            }
        }
        
    }
    
}

//双击tabbarItem
- (void)reloadScrollToUnReadSession {
    DLog(@"双击tabbarItem");
    if (self.sessionList.count <= 0) {
        return;
    }
    if (self.sessionList.count > 0) {
        __block NSInteger totalNum = 0;
        [self.sessionList enumerateObjectsUsingBlock:^(LingIMSessionModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.sessionUnreadCount <= 0) {
                totalNum++;
            }
        }];
        if (totalNum == self.sessionList.count) {
            [self.baseTableView setContentOffset:CGPointMake(0, 0) animated:YES];
        } else {
            NSInteger tempNum = 0;
            for (NSInteger i = self.currentCellIndex.row; i < self.sessionList.count; i++) {
                tempNum++;
                LingIMSessionModel *lastModel = [self.sessionList objectAtIndex:i];
                if (lastModel.sessionUnreadCount > 0) {
                    if (i > self.currentSessionList.count) {
                        self.currentIndex = i % 100;
                    }
                    @try {
                        [self.baseTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                        self.currentCellIndex = [NSIndexPath indexPathForRow:i+1 inSection:0];
                    } @catch (NSException *exception) {
                        NSLog(@"%@",exception);
                    }
                    break;
                } else {
                    if (tempNum == (self.sessionList.count - 1 - self.currentCellIndex.row)) {
                        tempNum = 0;
                        self.currentCellIndex = [NSIndexPath indexPathForRow:0 inSection:0];
                        for (NSInteger j = self.currentCellIndex.row; j < self.sessionList.count; j++) {
                            tempNum++;
                            LingIMSessionModel *lastModel = [self.sessionList objectAtIndex:j];
                            if (lastModel.sessionUnreadCount > 0) {
                                if (j > self.currentSessionList.count) {
                                    self.currentIndex = j % 100;
                                }
                                @try {
                                    [self.baseTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                                    self.currentCellIndex = [NSIndexPath indexPathForRow:j+1 inSection:0];
                                } @catch (NSException *exception) {
                                    NSLog(@"%@",exception);
                                }
                                break;
                            }
                        }
                        break;
                    }
                }
            }
        }
    }
}

- (void)connectStateChange:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSInteger connectType = [[userInfo objectForKeySafe:@"connectType"] integerValue];
//    self.netStateView.hidden = connectType == 1;
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    [self refreshTableViewForSort:YES];
}

- (void)refreshTableViewForSort:(BOOL)sort {
    if (self.currentIndex != 0) {
        if (sort) {
            [self sessionListSortUpdate];
        }
        WeakSelf
        dispatch_async(self.sessionListUpdateQueue, ^{
            [weakSelf.currentSessionList removeAllObjects];
            NSArray *currentSafeSessionArr = weakSelf.sessionList.safeArray;
            if (currentSafeSessionArr) {
                if (currentSafeSessionArr.count > weakSelf.currentIndex * 100) {
                    [weakSelf.currentSessionList addObjectsFromArray:[NSMutableArray arrayWithArray:[currentSafeSessionArr subarrayWithRange:NSMakeRange(0, weakSelf.currentIndex * 100)]]];
                } else {
                    [weakSelf.currentSessionList addObjectsFromArray:currentSafeSessionArr];
                }
            }
            [weakSelf debounceReloadTableView];
        });
    }
}

- (void)userRoleAuthorityFileHelperChange {
    //先检查是否已经有文件助手
    __block BOOL sessionListHasFileHelper = NO;
    __block BOOL sessionTopListHasFileHelper = NO;
    WeakSelf
    [self.sessionList enumerateObjectsUsingBlock:^(LingIMSessionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.sessionID isEqualToString:@"100002"]) {
            sessionListHasFileHelper = YES;
            *stop = YES;
        }
    }];
    
    [self.sessionTopList enumerateObjectsUsingBlock:^(LingIMSessionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.sessionID isEqualToString:@"100002"]) {
            sessionTopListHasFileHelper = YES;
            *stop = YES;
        }
    }];
    
    if ([UserManager.userRoleAuthInfo.isShowFileAssistant.configValue isEqualToString:@"true"]) {
        LingIMSessionModel *fileHelperSessionModel = [IMSDKManager toolCheckMySessionWith:@"100002"];
        if (fileHelperSessionModel) {
            if (sessionListHasFileHelper == NO) {
                [self.sessionList addObject:fileHelperSessionModel];
            }
            if (fileHelperSessionModel.sessionTop && sessionTopListHasFileHelper == NO) {
                [self.sessionTopList addObject:fileHelperSessionModel];
            }
            [self refreshTableViewForSort:YES];
        }
    } else {
        dispatch_async(self.sessionListUpdateQueue, ^{
            //会话列表
            if (sessionListHasFileHelper) {
                [weakSelf.sessionList enumerateObjectsUsingBlock:^(LingIMSessionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj.sessionID isEqualToString:@"100002"]) {
                        [weakSelf.sessionList removeObjectAtIndex:idx];
                        *stop = YES;
                    }
                }];
            }
            
            //会话置顶列表
            if (sessionTopListHasFileHelper) {
                [weakSelf.sessionTopList enumerateObjectsUsingBlock:^(LingIMSessionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj.sessionID isEqualToString:@"100002"]) {
                        [weakSelf.sessionTopList removeObjectAtIndex:idx];
                        *stop = YES;
                    }
                }];
            }
            [weakSelf refreshTableViewForSort:YES];
        });
    }
}

#pragma mark - 会话列表排序更新
- (void)sessionListSortUpdate {
    //创建排序规则
    WeakSelf
    dispatch_async(self.sessionListUpdateQueue, ^{
        //会话列表 按照 时间 降序 排序 优先级最高(最新的在前面)
        NSSortDescriptor *sortDescriptorTime = [NSSortDescriptor sortDescriptorWithKey:@"sessionLatestTime" ascending:NO];
        //会话置顶 按照置顶时间排序(最新的在前面)
        NSSortDescriptor *sortDescriptorTopTime = [NSSortDescriptor sortDescriptorWithKey:@"sessionTopTime" ascending:YES];
        //按照 会话ID 降序排序 次级优先级
        NSSortDescriptor *sortDescriptorSessionID = [NSSortDescriptor sortDescriptorWithKey:@"sessionID" ascending:NO];
        
        NSMutableArray * tempSessionList = [[weakSelf coHereVisibleSessionsFromArray:weakSelf.sessionList.safeArray] mutableCopy];
        
        NSMutableArray * tempSessionTopList = [[weakSelf coHereVisibleSessionsFromArray:weakSelf.sessionTopList.safeArray] mutableCopy];
        
        [weakSelf.sessionList replaceAllObjectsWithArray:[tempSessionList sortedArrayUsingDescriptors:@[sortDescriptorTime, sortDescriptorSessionID]].mutableCopy];
        [weakSelf.sessionTopList replaceAllObjectsWithArray:[tempSessionTopList sortedArrayUsingDescriptors:@[sortDescriptorTopTime, sortDescriptorSessionID]].mutableCopy];
        [weakSelf debounceReloadTableView];
    });
}

#pragma mark - 刷新防抖
- (void)debounceReloadTableView {
    WeakSelf
    // 取消上一次待执行的 block
    if (self.pendingReloadBlock) {
        dispatch_block_cancel(self.pendingReloadBlock);
        self.pendingReloadBlock = nil;
    }
    // 创建新的防抖 block（80ms）
    dispatch_block_t block = dispatch_block_create(0, ^{
        [ZTOOL doInMain:^{
            [UIView performWithoutAnimation:^{
                [weakSelf.baseTableView reloadData];
            }];
        }];
    });
    self.pendingReloadBlock = block;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.08 * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}

- (dispatch_queue_t)sessionListUpdateQueue {
    if (_sessionListUpdateQueue == nil) {
        _sessionListUpdateQueue = dispatch_queue_create("com.CIMKit.sessionListUpdateQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _sessionListUpdateQueue;
}


- (NoaSessionNetStateView *)netStateView {
    if (_netStateView == nil) {
        _netStateView = [[NoaSessionNetStateView alloc] init];
    }
    return _netStateView;
}

- (SyncMutableArray *)sessionList {
    if (_sessionList == nil) {
        _sessionList = [[SyncMutableArray alloc] init];
    }
    return _sessionList;
}

- (SyncMutableArray *)sessionTopList {
    if (_sessionTopList == nil) {
        _sessionTopList = [[SyncMutableArray alloc] init];
    }
    return _sessionTopList;
}

- (SyncMutableArray *)currentSessionList {
    if (_currentSessionList == nil) {
        _currentSessionList = [[SyncMutableArray alloc] init];
    }
    return _currentSessionList;
}

- (UIButton *)btnTop {
    if (_btnTop == nil) {
        _btnTop = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnTop.hidden = YES;
        [_btnTop setImage:ImgNamed(@"s_go_top") forState:UIControlStateNormal];
        [_btnTop addTarget:self action:@selector(btnTopClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnTop;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
