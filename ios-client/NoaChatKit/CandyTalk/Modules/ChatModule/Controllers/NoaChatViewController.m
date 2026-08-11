//
//  NoaChatViewController.m
//  NoaKit
//
//  Created by Candy on 2026/9/23.
//

#import "NoaChatViewController.h"
#import "NoaFileHelperSetVC.h"
#import <objc/runtime.h>

#import "NoaChatInputView.h"
#import "NoaMessageBaseCell.h"
#import "NoaMessageTextCell.h"
#import "NoaMessageImageCell.h"
#import "NoaMessageVideoCell.h"
#import "NoaMessageSystemCell.h"
#import "NoaMessageReferenceCell.h"
#import "NoaMessageAtUserCell.h"
#import "NoaMessageFileCell.h"
#import "NoaMessageVoiceCell.h"
#import "NoaMessageCallCell.h"
#import "NoaMessageGroupNoticeCell.h"
#import "NoaMessageGeoCell.h"
#import "NoaMessageCardCell.h"
#import "NoaMergeMessageRecordCell.h"
#import "NoaMessageStickersCell.h"
#import "NoaMessageGameStickersCell.h"
#import "NoaChatTopView.h"
#import "NoaChatTagModel.h"
#import "NoaBaseVideoPlayerVC.h"
#import "NoaChatMessageMoreView.h"
#import "NoaMessageAlertView.h"
#import "NoaImagePickerVC.h"              //相册
#import "NoaFilePickerVC.h"               //文件
#import "NoaMessageTools.h"
#import "NoaDraftStore.h"
#import "NoaMessageSendHander.h"
#import "NoaToolManager.h"                //工具类
#import "NoaChatSingleSetVC.h"            //单聊设置VC
#import "NoaChatGroupSetVC.h"             //群聊设置VC
#import "NoaMsgAtListViewController.h"    //@用户的列表
#import "NoaUserHomePageVC.h"             //用户个人资料
#import "NoaAudioPlayManager.h"           //语音消息播放单例
#import "NoaChatFileDetailViewController.h"   //文件消息中文件详情
#import "NoaChatGroupNoticeTipView.h"    //群公告提示
#import "NoaMediaCallManager.h"//LiveKit音视频通话
#import "NoaCallManager.h"//即构音视频通话
#import "NoaMediaCallMoreInviteVC.h"//音视频通话邀请好友
#import "NoaChatGroupCallTipView.h"//群聊多人通话提示，如果有的话
#import "KNPhotoBrowser.h"//图片视频浏览
#import "NoaFileUploadModel.h"
#import "NoaGroupModifyNoticeVC.h"
#import "NoaChatKit-Swift.h"
#import "NoaMessageTimeDeleteView.h"//消息定时删除配置
#import "NoaChatMultiSelectSendHander.h"
#import "NoaMessageMultiBottomView.h" //多选bottom
#import "NoaChatRecordDetailViewController.h" //会话记录详情
#import "NoaSensitiveManager.h" //敏感词过滤
#import "NoaChatTextUrlListView.h" //topView标签栏相关
#import "NoaChatNavLinkAddView.h"
#import "NoaMiniAppWebVC.h"//跳转webView
#import "NoaMessageTimeTool.h"
#import "NoaTranslateSettingVC.h"//翻译配置信息
#import "NoaEmojiShopViewController.h"//表情商店
#import "NoaEmojiPackageDetailViewController.h"//表情包详情
#import "NoaTranslateDefaultModel.h"
#import "NoaFileUploadManager.h"
#import "NoaMessageSendTask.h"

#import "NoaMessageVoiceHudView.h"
#import "NoaChatActivityLevelVC.h"
#import "NoaChatAtBannedView.h"
// 群公告列表
#import "NoaGroupNoticeListVC.h"
// 群公告详情页面
#import "NoaGroupNoticeDetailVC.h"
// 群置顶消息 View
#import "ZGroupTopMessageView.h"
// 群置顶消息列表页面
#import "ZGroupTopMessageListViewController.h"


#import "CandyTalkHomeViewController.h"


#define ChatTopTitleWidth DWScale(180)
#define Multi_Selected_Max_Num      100


@interface NoaChatViewController () <ZChatInputViewDelegate, UITableViewDelegate, UITableViewDataSource, ZMessageBaseCellDelegate, NoaToolMessageDelegate, NoaToolUserDelegate, ZImagePickerVCDelegate, UIDocumentInteractionControllerDelegate, KNPhotoBrowserDelegate, ZChatGroupNoticeTipViewDelegate, ZMessageTimeDeleteViewDelegate, ZMsgMultiSelectDelegate, UIGestureRecognizerDelegate, ZFileUploadTaskDelegate, ZGroupTopMessageViewDelegate>

//显示刷新界面的专门队列(消息更新)
@property (nonatomic, strong) dispatch_queue_t chatMessageUpdateQueue;
//显示刷新界面的专门队列(消息的时间计算)
@property (nonatomic, strong) dispatch_queue_t chatMessageCalculateTimeQueue;
//请求群成员接口队列
@property (nonatomic, strong) dispatch_queue_t groupChatGetMemberQueue;
@property (nonatomic, strong) NoaChatTopView *topView;
@property (nonatomic, strong) NoaChatInputView *viewInput;
@property (nonatomic, strong) NoaChatAtBannedView *atBannedView;
@property (nonatomic, strong) UIView * notalkStateBgView;//当前用户被禁言背景试图
@property (nonatomic, strong) UILabel * notalkStateLabel;//当前用户被禁言时间试图
@property (nonatomic,assign) BOOL isAllMemberNotalk;//是否全员禁言
@property (nonatomic,assign) BOOL isCurUserNotalk;//是否当前用户被禁言
@property (nonatomic,assign) NSInteger notalkTime;//禁言时间秒数
@property (nonatomic,strong) NSTimer *timer;//开启定时器
@property (nonatomic, strong) NSIndexPath *chatHistorySelectIndex;//搜索历史文本消息定位的cell位置
/// 当前正在编辑的消息位置，用于键盘变化和编辑完成后的定位。
@property (nonatomic, strong) NSIndexPath *editCellIndexPath;
@property (nonatomic, strong) NSArray *currentImageVideoMessageList;
@property (nonatomic, strong) NoaUserModel *userModel;//单聊好友信息
@property (nonatomic, strong) NoaChatGroupCallTipView *viewGroupCallTip;//音视频通话提示View
//@property (nonatomic, strong) ZFileNetProgressManager *fileUploader;
@property (nonatomic, strong) NoaChatGroupNoticeTipView *viewGroupNotice;//置顶群公告
@property (nonatomic, strong) ZGroupTopMessageView *groupTopMessageView;//群置顶消息 View

@property (nonatomic, strong) NoaGroupNoteModel *groupNoticeModel;
@property (nonatomic, assign) NSInteger messageTimeDeleteType;//0关闭 1天 7天 30天
@property (nonatomic, strong) NoaChatMultiSelectSendHander *collectionSendHander;
@property (nonatomic, assign) BOOL multiSelectStatus; //是否为多选状态
@property (nonatomic, strong) NoaMessageMultiBottomView *multiSelectBottomView;//多选-底部操作栏
@property (nonatomic, strong) SyncMutableArray *selectedMsgModels;
@property (nonatomic, strong) UIButton *btnBottom;
@property (nonatomic, strong) NoaMessageAlertView *groupAlertView;//群状态弹窗
@property (nonatomic, strong) LingIMSessionModel * sessionModel; //懒加载 会话对象
//@property (nonatomic, strong) ZMessageAlertView *translateAlertView;//翻译状态弹窗
@property (nonatomic, strong) SyncMutableArray *unReadSmsgidList;//存储等待上班的sMsgId
@property (nonatomic, strong) NSTimer *uploadReadedTimer;//上报消息已读定时器
@property (nonatomic, strong) NSTimer *loadingTimeoutTimer;//loading超时计时器（30秒）

/// 能否联网
@property (nonatomic, assign) BOOL isReachable;

@property (nonatomic, strong) NoaTranslateDefaultModel *defaultModel;
@property (nonatomic, strong) ZMessageMultiSelectView *messageMutiSelectView;
@property (nonatomic, assign) NSInteger pageNumber;

// 刷新防抖
@property (nonatomic, copy) dispatch_block_t pendingChatReloadBlock;
// 排序防抖
@property (nonatomic, copy) dispatch_block_t pendingSortBlock;


/// 判断当前的tableview是否正在scroll
@property (nonatomic, assign) BOOL isScrollIng;

/// 图片加载后调整滚动的防抖定时器
@property (nonatomic, strong) dispatch_block_t pendingImageLoadAdjustBlock;

@end

@implementation NoaChatViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [IQKeyboardManager sharedManager].enable = NO;
    
    WeakSelf
    
    self.topView.chatName = [NSString stringWithFormat:@"%@",self.chatName];
    [ZTOOL doAsync:^{
        weakSelf.sessionModel = [IMSDKManager toolCheckMySessionWith:weakSelf.sessionID];
    } completion:^{
        
    }];
    
    if (self.chatType == CIMChatType_SingleChat && !self.isFileHelperMode) {
        __block LingIMFriendModel *friendModel;
        [ZTOOL doAsync:^{
           friendModel = [IMSDKManager toolCheckMyFriendWith:weakSelf.sessionID];
        } completion:^{
            if (friendModel.disableStatus == 4) {
                weakSelf.topView.chatName = LanguageToolMatch(@"已注销");
            }
            weakSelf.topView.viewOnline.hidden = friendModel.onlineStatus ? NO : YES;
        }];

    }
    if (self.chatType == CIMChatType_GroupChat) {
        __block LingIMGroupModel *localGroupInfo ;
        [ZTOOL doAsync:^{
            localGroupInfo = [IMSDKManager toolCheckMyGroupWith:weakSelf.sessionID];
        } completion:^{
            //群主/管理员可以设置消息自动删除
            weakSelf.topView.btnTime.hidden = localGroupInfo.userGroupRole != 0 ? NO : YES;
            //仅允许群管理查看群人数（1=是，0=否）
            if ([UserManager.userRoleAuthInfo.showGroupPersonNum.configValue isEqualToString:@"true"]) {
                weakSelf.topView.chatName = [NSString showAppointWidith:ChatTopTitleWidth sessionName:localGroupInfo.groupName peopleNum:[NSString stringWithFormat:@"%ld", (long)localGroupInfo.memberCount]];
            } else {
                if ([ZHostTool.appSysSetModel.onlyAllowAdminViewGroupPersonCount isEqualToString:@"1"]) {
                    if (localGroupInfo.userGroupRole == 0) {
                        //普通群成员不显示群成员数量
                        weakSelf.topView.chatName = [NSString showAppointWidith:ChatTopTitleWidth sessionName:localGroupInfo.groupName peopleNum:@""];
                    } else {
                        //群主和管理员展示群成员数量
                        weakSelf.topView.chatName = [NSString showAppointWidith:ChatTopTitleWidth sessionName:localGroupInfo.groupName peopleNum:[NSString stringWithFormat:@"%ld", (long)localGroupInfo.memberCount]];
                    }
                } else {
                    weakSelf.topView.chatName = [NSString showAppointWidith:ChatTopTitleWidth sessionName:localGroupInfo.groupName peopleNum:[NSString stringWithFormat:@"%ld", (long)localGroupInfo.memberCount]];
                }
            }
        }];
    }
    [self.viewInput configShowAtUserListStatus:YES];
    [self requestDefaultData];
    
    
    // 进入时加载本地草稿
    NSDictionary *draft = [NoaDraftStore loadDraftForSession:self.sessionID];
    if (draft.count > 0) {
        NSString *text = [draft objectForKey:@"draftContent"];
        NSArray *atList = [draft objectForKey:@"atUser"];
        NSArray *atSegments = [draft objectForKey:@"atSegments"];
        if (text.length > 0) {
            self.viewInput.inputContentStr = text;
            [self.viewInput setSendButtonHighlighted:YES];
        }
        if (atList.count > 0) {
            [self.viewInput configAtUserInfoList:atList];
            [self.viewInput configAtSegmentsInfoList:atSegments];
            [self.viewInput setSendButtonHighlighted:YES];
        }
    }

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //上报消息已读定时器开始继续
    [self startUploadChatMsgReadedTimer];
    // 更新 header 高度，确保页面显示时 header 高度正确
    [self updateTableViewContentInset];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //离开聊天界面立即上报已读消息并暂停定时器
    [self refreshUploadChatMessageReaded];
    [self pauseUploadChatMsgReadedTimer];
    // 取消loading超时计时器
    [self stopLoadingTimeoutTimer];

    //立刻聊天界面关闭键盘
    [self.viewInput inputViewResignFirstResponder];
    [IQKeyboardManager sharedManager].enable = YES;
    
    //立刻聊天界面时，停止语音播放和播放的动画
    if (ZAudioPlayerTOOL.isPlaying) {
        [ZAudioPlayerTOOL stop];
    }
    
    if (ZAudioPlayerTOOL.currentVoiceCell) {
        [ZAudioPlayerTOOL stop];
        [ZAudioPlayerTOOL.currentVoiceCell stopAnimation];
    }
    
    // 读取输入框草稿并同步到本地持久化（不触库）
    NSString *tvContent = [self.viewInput currentInputText];
    NSArray *atList = [self.viewInput currentAtUserDictList] ?: @[];
    NSArray *atSegments = [self.viewInput currentAtSegmentsList] ?: @[];
    BOOL hasText = ![NSString isNil:tvContent];
    BOOL hasAt = atList.count > 0;
    NSMutableDictionary *draft = [NSMutableDictionary dictionary];
    if (hasText) {
        [draft setValue:tvContent forKey:@"draftContent"];
        if (hasAt) {
            [draft setValue:atList forKey:@"atUser"];
            [draft setValue:atSegments forKey:@"atSegments"];
        }
    }

    if (draft.count > 0) {
        [NoaDraftStore saveDraft:draft forSession:self.sessionID];
        if (self.draftDidChange) { self.draftDidChange(self.sessionID, draft); }
    } else {
        [NoaDraftStore deleteDraftForSession:self.sessionID];
        if (self.draftDidChange) { self.draftDidChange(self.sessionID, @{}); }
    }
    
    // 清理数据
    [self.viewInput configAtUserInfoList:@[]];
    [self.viewInput configAtSegmentsInfoList:@[]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //默认参数
    _pageNumber = 1;
    _multiSelectStatus = NO;
    //队列初始化
    _chatMessageUpdateQueue = dispatch_queue_create("com.CIMKit.chatMessageUpdateQueue", DISPATCH_QUEUE_SERIAL);
    _chatMessageCalculateTimeQueue = dispatch_queue_create("com.CIMKit.chatMessageCalculateTimeQueue", DISPATCH_QUEUE_SERIAL);
    _groupChatGetMemberQueue = dispatch_queue_create("com.CIMKit.groupChatGetMemberQueue", DISPATCH_QUEUE_CONCURRENT);
    //点击手势处理键盘
    UITapGestureRecognizer *hiddenKeyboardTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoardAndEmjoy)];
    hiddenKeyboardTap.delegate = self;
    [self.baseTableView addGestureRecognizer:hiddenKeyboardTap];
    
    //界面布局
    [self setupUI];
    
    //进入此页面先初始化地步输入框UI，再根据后台数据返回判断是否隐藏此输入框
    [self setupNotalkBottomUI];
    [self setupInputBottomUI];
    
    //通知监听
    [self chatViewAddObserver];
    
    // 监听完成后兜底刷新一次功能入口
    [self chatViewDidFinishAddObserverReloadIfNeeded];
    
    //设置接受消息和用户相关的delegate
    [IMSDKManager addMessageDelegate:self];
    [IMSDKManager addUserDelegate:self];
    
    //消息请求加载
    [HUD showActivityMessage:@"" inView:self.view];
    // 启动20秒超时计时器，防止loading一直显示
    [self startLoadingTimeoutTimer];

    [self requestHistoryList];
    
    //请求标签栏
    if (!self.isFileHelperMode) {
        [self requestChatTagList];
    }
    
    //专属处理
    if (self.chatType == CIMChatType_SingleChat && !self.isFileHelperMode) {
        //单聊
        [self requestUserInfo];
        if ([UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
            _topView.btnTime.hidden = NO;
        } else {
            _topView.btnTime.hidden = YES;
        }
        //请求单聊置顶消息列表
        [self requestSingleTopMessages];
    } else {
        //群聊
        //群聊音视频通话提示
        [self.view addSubview:self.viewGroupCallTip];
        //请求一下群成员接口更新一下数据库
        [self requestAllGroupMember];
        //请求群置顶消息列表
        [self requestGroupTopMessages];

    }
    
    [self.view addSubview:self.multiSelectBottomView];
    
    //检测消息是否自动删除
    if (!self.isFileHelperMode) {
        [self requestMessageTimeDeleteInfo];
    }
    
    //开始2秒计时检测是否有需要上传消息已读的数据
    WeakSelf
    self.uploadReadedTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [weakSelf refreshUploadChatMessageReaded];
    }];
    
    //监听网络是否正常
    [self performSelector:@selector(requestData) withObject:nil afterDelay:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChange:) name:NetWorkStatusManager.NetworkStatusChangedNotification object:nil];
}

// 在监听完成后，做一次兜底刷新，避免首次进入时错过权限变化导致功能入口未更新
- (void)chatViewDidFinishAddObserverReloadIfNeeded {
    if (_viewInput) {
        [_viewInput reloadSetupDataWithTranslateBtnStatus:_sessionModel.isSendAutoTranslate];
    }
}

#pragma mark - 监听网络状态是否可用
- (void)networkChange:(NSNotification *)notification {
    [self requestData];
}

- (void)requestData {
    //监听网络是否正常
    self.isReachable = [NetWorkStatusManager shared].getConnectStatus;
    if (!self.isReachable) {
        return;
    }
    //网络现在可用
    if (self.chatType == CIMChatType_SingleChat && !self.isFileHelperMode) {
        CIMLog(@"监听到网络变化，并且当前为网络可用，发送协议请求个人聊天信息");
        [self requestFriendInfoForServer];
    }
    if (self.chatType == CIMChatType_GroupChat) {
        CIMLog(@"监听到网络变化，并且当前为网络可用，发送协议请求群组聊天信息");
        [self getGroupInfoFromServer];
    }
}

- (void)hideKeyBoardAndEmjoy{
    [self.viewInput inputViewResignFirstResponder];
}

- (void)navBtnBackClicked {
    if (self.isFromQRCode) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [super navBtnBackClicked];
    }
}

#pragma mark - 界面布局
- (void)setupUI {
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_EEEEEE_DARK];

    self.navView.hidden = YES;
    UIView *viewTopBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DNavStatusBarH)];
    viewTopBg.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
    [self.view addSubview:viewTopBg];
    
    WeakSelf;
    CGFloat topViewHeight = self.isFileHelperMode ? 44 : 44 + DWScale(40);
    _topView = [[NoaChatTopView alloc] initWithFrame:CGRectMake(0, DStatusBarH, DScreenWidth, topViewHeight)];
    _topView.sessionId = self.sessionID;
    _topView.chatType = self.chatType;
    _topView.isShowTagTool = !self.isFileHelperMode;
    _topView.chatName = self.chatName;
    [self.view addSubview:_topView];
    _topView.navBackBlock = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    _topView.navRightBlock = ^{
        if (weakSelf.isFileHelperMode) {
            NoaFileHelperSetVC *vc = [NoaFileHelperSetVC new];
            vc.sessionID = weakSelf.sessionID;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        } else if (weakSelf.chatType == CIMChatType_SingleChat) {
            //单聊-Setting
            NoaChatSingleSetVC *vc = [NoaChatSingleSetVC new];
            vc.friendUid = weakSelf.sessionID;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        } else {
            //群聊-Setting
            NoaChatGroupSetVC *vc = [NoaChatGroupSetVC new];
            vc.groupID = weakSelf.sessionID;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }
    };
    _topView.navTimeBlock = ^{
        [weakSelf messageTimeDeleteViewShow];
    };
    _topView.navCancelBlock = ^{
        [weakSelf setupMultiSelectedStatusDefaultIsReload:YES];
    };
    _topView.navLinkBlock = ^(NSInteger linkIndex) {
        if (linkIndex == Chat_Top_Nav_Link_Notice) {
            //群公告
            /**
             * TODO: 旧代码，导航条下方群公告，原先是跳转到编辑页面
             //跳转到群公告界面
             NoaGroupModifyNoticeVC * vc = [NoaGroupModifyNoticeVC new];
             */
            // TODO: 新版本：跳转到列表页面
            NoaGroupNoticeListVC *vc = [NoaGroupNoticeListVC new];
            vc.groupInfoModel = weakSelf.groupInfo;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        } else {
            //跳转Web
            NoaChatTagModel *clickTagModel = (NoaChatTagModel *)[weakSelf.topView.chatLinkArr objectAtIndex:linkIndex];
            
            NoaFloatMiniAppModel * floadModel = [[NoaFloatMiniAppModel alloc] init];
            floadModel.url = clickTagModel.tagUrl;
            floadModel.floladId = [NSString stringWithFormat:@"%li",clickTagModel.tagId];
            floadModel.title = clickTagModel.tagName;
            floadModel.headerUrl = clickTagModel.tagIcon;
            
            NoaMiniAppWebVC *webVC = [[NoaMiniAppWebVC alloc] init];
            webVC.webViewTitle = clickTagModel.tagName;
            webVC.webViewUrl = clickTagModel.tagUrl;
            webVC.floatMiniAppModel = floadModel;
            webVC.webType = ZMiniAppWebVCTypeMiniApp;
            [weakSelf.navigationController pushViewController:webVC animated:YES];
        }
    };
    
    _topView.navNetworkDetectBlock = ^{
        CoHereNetworkDetectionViewController *vc = [CoHereNetworkDetectionViewController new];
        NoaSsoInfoModel *ssoModel = [NoaSsoInfoModel getSSOInfo];
        vc.currentSsoNumber = ssoModel.liceseId;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
    self.baseTableView.delegate = self;
    self.baseTableView.dataSource = self;
    self.baseTableView.estimatedRowHeight = 0;
    self.baseTableView.estimatedSectionHeaderHeight = 0;
    self.baseTableView.estimatedSectionFooterHeight = 0;
    self.baseTableView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_EEEEEE_DARK];
    [self.view addSubview:self.baseTableView];
    
    //添加下拉加载
    self.baseTableView.mj_header = self.refreshHeader;
    
    //滚动到底部快捷键
    self.btnBottom = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnBottom.hidden = YES;
    [self.btnBottom setImage:ImgNamed(@"c_go_bottom") forState:UIControlStateNormal];
    [self.btnBottom addTarget:self action:@selector(btnBottomClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnBottom];
}

//刷新底部输入框状态
- (void)reloadBottomView{
    if (self.isAllMemberNotalk) {
        //全员禁言
        _notalkStateLabel.text = LanguageToolMatch(@"全员禁言");
    } else if (self.isCurUserNotalk) {
        //当前用户被禁言
        if (self.isCurUserNotalk) {
            if ([[NSDate getOvertime:[NSString stringWithFormat:@"%ld",self.notalkTime] isShowSecondStr:YES] isEqualToString:LanguageToolMatch(@"禁言")]) {
                _notalkStateLabel.text = [NSString stringWithFormat:@"%@",[NSDate getOvertime:[NSString stringWithFormat:@"%ld",self.notalkTime] isShowSecondStr:YES]];
            } else {
                _notalkStateLabel.text = [NSString stringWithFormat:LanguageToolMatch(@"禁言中 %@"),[NSDate getOvertime:[NSString stringWithFormat:@"%ld",self.notalkTime] isShowSecondStr:YES]];
                //self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeAction) userInfo:nil repeats:YES];
                WeakSelf
                self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
                    [weakSelf timeAction];
                }];
            }
        }
    }
    [self updateBottomInputUI];
}

- (void)setupMultiSelectedStatusDefaultIsReload:(BOOL)isRelaod {
    self.multiSelectStatus = NO;
    self.multiSelectBottomView.selectNum = 0;
    self.multiSelectBottomView.hidden = YES;
    [self.baseTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(_topView.mas_bottom);
        make.bottom.equalTo(self.viewInput.mas_top);
    }];
    [self.selectedMsgModels removeAllObjects];
    self.topView.showCancel = NO;
    if (self.chatType == CIMChatType_SingleChat) {
        //单聊
        if ([UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
            _topView.btnTime.hidden = NO;
        } else {
            _topView.btnTime.hidden = YES;
        }
    }
    if (self.chatType == CIMChatType_GroupChat) {
        //群聊
        _topView.btnTime.hidden = self.groupInfo.userGroupRole != 0 ? NO : YES;
    }

    [self.messageModels enumerateObjectsUsingBlock:^(NoaMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.multiSelected = NO;
    }];
    if (isRelaod) {
        [self.baseTableView reloadData];
    }
    //显示底部输入框
    self.viewInput.hidden = NO;
    [self.messageMutiSelectView removeFromSuperview];
    [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NoaChatGroupNoticeTipView class]]) {
            obj.hidden = NO;
        }
    }];
    // 更新 header 高度
    [self updateTableViewContentInset];

}

//创建底部输入框UI
- (void)setupInputBottomUI {
    if (!self.viewInput) {
        self.viewInput = [[NoaChatInputView alloc] initWithFrame:CGRectMake(0, DScreenHeight - DWScale(56 + 50) - DHomeBarH, DScreenWidth, DWScale(56 + 50) + DHomeBarH)];
        self.viewInput.sessionID = self.sessionID;
        self.viewInput.delegate = self;
        self.viewInput.inputContentStr = @"";
        self.viewInput.moreType = self.isFileHelperMode
            ? ZChatInputViewTypeFileHelper
            : ZChatInputViewTypeChat;
        [self.view addSubview:self.viewInput];
        [self.viewInput reloadSetupDataWithTranslateBtnStatus:_sessionModel.isSendAutoTranslate];
        
        if (self.groupInfo) {
            if (self.groupInfo.isPrivateChat && self.groupInfo.userGroupRole == 0) {
                [self.viewInput configShowAtUserListStatus:NO];
            } else {
                [self.viewInput configShowAtUserListStatus:YES];
            }
        } else {
            [self.viewInput configShowAtUserListStatus:YES];
        }
        if (_sessionModel == nil) {
            _sessionModel = [IMSDKManager toolCheckMySessionWith:self.sessionID];
        }
        [self.viewInput configTranslateBtnStatus:_sessionModel.isSendAutoTranslate];
    }
}
//禁言UI
- (void)setupNotalkBottomUI{
    if (self.timer) {
        //关闭定时器
        [self.timer setFireDate:[NSDate distantFuture]];
        //取消定时器
        [self.timer invalidate];
        self.timer = nil;
    }
    
    self.notalkStateBgView = [[UIView alloc] initWithFrame:CGRectMake(0, DScreenHeight - DWScale(56) - DHomeBarH, DScreenWidth, DWScale(56) + DHomeBarH)];
    self.notalkStateBgView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_EEEEEE_DARK];
    self.notalkStateBgView.hidden = YES;
    [self.view addSubview:self.notalkStateBgView];
    
    _notalkStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(DWScale(16), 0, DScreenWidth-DWScale(16)*2, DWScale(50))];
    _notalkStateLabel.font = FONTR(16);
    _notalkStateLabel.textAlignment = NSTextAlignmentCenter;
    _notalkStateLabel.tkThemebackgroundColors = @[COLORWHITE,COLOR_11];
    _notalkStateLabel.tkThemetextColors = @[COLOR_66,COLOR_66_DARK];
    _notalkStateLabel.layer.cornerRadius = DWScale(14);
    _notalkStateLabel.clipsToBounds = YES;
    [self.notalkStateBgView addSubview:_notalkStateLabel];
}

- (void)updateBottomInputUI {
    if (self.isAllMemberNotalk ) {
        self.viewInput.hidden = YES;
        self.notalkStateBgView.hidden = NO;
        //更新回到底部按钮约束
        [self.btnBottom mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.notalkStateBgView.mas_top).offset(-DWScale(25));
            make.trailing.equalTo(self.view).offset(-DWScale(20));
            make.size.mas_equalTo(CGSizeMake(DWScale(36), DWScale(36)));
        }];
        
        //修改列表界面布局约束
        [self.baseTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.top.equalTo(_topView.mas_bottom);
            make.bottom.equalTo(self.notalkStateBgView.mas_top);
        }];
    } else if (self.isCurUserNotalk) {
        if (self.notalkTime > 0) {
            self.viewInput.hidden = YES;
            self.notalkStateBgView.hidden = NO;
            //更新回到底部按钮约束
            [self.btnBottom mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.notalkStateBgView.mas_top).offset(-DWScale(25));
                make.trailing.equalTo(self.view).offset(-DWScale(20));
                make.size.mas_equalTo(CGSizeMake(DWScale(36), DWScale(36)));
            }];
            
            //修改列表界面布局约束
            [self.baseTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(self.view);
                make.top.equalTo(_topView.mas_bottom);
                make.bottom.equalTo(self.notalkStateBgView.mas_top);
            }];
        } else {
            self.viewInput.hidden = NO;
            self.notalkStateBgView.hidden = YES;
            //更新回到底部按钮约束
            [self.btnBottom mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.viewInput.mas_top).offset(-DWScale(25));
                make.trailing.equalTo(self.view).offset(-DWScale(20));
                make.size.mas_equalTo(CGSizeMake(DWScale(36), DWScale(36)));
            }];
            
            //修改列表界面布局约束
            [self.baseTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(self.view);
                make.top.equalTo(_topView.mas_bottom);
                make.bottom.equalTo(self.viewInput.mas_top);
            }];
        }
    } else {
        self.viewInput.hidden = NO;
        self.notalkStateBgView.hidden = YES;
        //更新回到底部按钮约束
        [self.btnBottom mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.viewInput.mas_top).offset(-DWScale(25));
            make.trailing.equalTo(self.view).offset(-DWScale(20));
            make.size.mas_equalTo(CGSizeMake(DWScale(36), DWScale(36)));
        }];
        
        //修改列表界面布局约束
        [self.baseTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.top.equalTo(_topView.mas_bottom);
            make.bottom.equalTo(self.viewInput.mas_top);
        }];
    }
    // 更新 contentInset
    [self updateTableViewContentInset];
}

// 获取空白 header 的高度，用于在 tableView 顶部留出空间给 viewGroupNotice 或 groupTopMessageView
- (CGFloat)getHeaderSpacerHeight {
    // 检查 viewGroupNotice 是否显示
    BOOL hasGroupNotice = [self hasGroupNoticeDisplayed];
    
    // 检查 groupTopMessageView 是否显示
    BOOL hasGroupTopMessage = NO;
    if (self.groupTopMessageView && !self.groupTopMessageView.hidden && !self.multiSelectStatus) {
        hasGroupTopMessage = YES;
    }
    
    // 计算需要的高度
    CGFloat headerHeight = 0;
    if (hasGroupNotice) {
        // viewGroupNotice: y = DWScale(10), height = DWScale(42), 底部 = DWScale(52)
        headerHeight = DWScale(10) + DWScale(42);
    } else if (hasGroupTopMessage) {
        // groupTopMessageView: y = DWScale(8), height = DWScale(48), 底部 = DWScale(56)
        headerHeight = DWScale(8) + DWScale(48);
    }
    
    return headerHeight;
}

// 更新 tableView 的 contentInset，为 viewGroupNotice 或 groupTopMessageView 留出空间
- (void)updateTableViewContentInset {
    CGFloat topInset = [self getHeaderSpacerHeight];
    
    self.baseTableView.contentInset = UIEdgeInsetsMake(topInset, 0, 0, 0);
    self.baseTableView.scrollIndicatorInsets = UIEdgeInsetsMake(topInset, 0, 0, 0);

}

#pragma mark - 各种通知监听处理
- (void)chatViewAddObserver {
    //通用监听
    //查询历史消息后点击跳转到消息为止的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestSelectHistoryList:) name:@"ChatHistorySelectMessage" object:nil];
    //搜索历史记录页面接收到删除文件的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMessageTabView:) name:@"HistoryVCDeleteFileNotification" object:nil];
    //消息自动删除监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageTimeDelete:) name:@"ChatMessageTimeDelete" object:nil];
    //用户角色权限发生变化(是否允许上传文件)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userRoleAuthorityUploadFileChange) name:@"UserRoleAuthorityUploadFileChangeNotification" object:nil];
    //用户角色权限发生变化(是否允许上传图片/视频)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userRoleAuthorityUploadImageVideoChange) name:@"UserRoleAuthorityUpImageVideoFileChangeNotification" object:nil];
    //用户角色权限发生变化(是否允许删除消息)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userRoleAuthorityDeleteMessageChange) name:@"UserRoleAuthorityDeleteMessageChangeNotification" object:nil];
    //置顶消息定位通知（单聊和群聊通用）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupTopMessageLocation:) name:@"TopMessageLocationNotification" object:nil];
    //专属监听
    if (self.chatType == CIMChatType_SingleChat) {
        //单聊
        //好友在线状态更新
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myFriendOnlineStatusChange:) name:@"MyFriendOnlineStatusChange" object:nil];
        
    } else {
        //群聊
        //群聊-在群设置里分享本群二维码到本群，接收通知，UI界面上需要App端本地添加当前这条二维码消息
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareQRcodeAddLocalMessageToUI:) name:@"MessageShareQRCodeToSelfGroupNotification" object:nil];
        //群内禁止私聊状态更新
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupNoChatStatusChange:) name:@"GroupNoChatStatusChange" object:nil];
        //群封禁状态更新
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupBanStatusChange:) name:@"GroupBannedStatusChange" object:nil];
        //聊天和会话列表的刷新
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatAndSessionReload:) name:@"ReloadChatAndSessionVC" object:nil];
        
        // 某个用户被群管理、群主清空消息后发送的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteUserMessageEvent:) name:@"GroupDeleteMemberHistoryNotification" object:nil];
    }
    // app从前台进入后台，暂停已读消息上报的定时器
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseUploadChatMsgReadedTimer) name:UIApplicationDidEnterBackgroundNotification object:nil];
    // app从后台进入前台 重新拉取群信息groupInfo，避免从后台进入前台或者网络从无网变成有网时，groupInfo里一些状态发生改变而没有及时更新groupInfo 并且 开始已读消息上报的定时器
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startUploadChatMsgReadedTimer) name:UIApplicationWillEnterForegroundNotification object:nil];
    // socket重连IMConnectReConnect
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketReConnectEvent) name:@"IMConnectReConnect" object:nil];
    //systemConfig中是否允许音视频通话开发状态发生变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appSystemConfigEnableAudioAndVideoCalls) name:@"AppSystemConfigEnableAudioAndVideoCalls" object:nil];
}

#pragma mark - socket重连回调
- (void)socketReConnectEvent {
    WeakSelf
    // 游标优先用会话最新 serviceMsgID，其次列表最后一条；用于拉取断线期间的更新缺口
    NSString *newestSid = self.sessionModel.sessionLatestServerMsgID ?: @"";
    if (newestSid.length == 0 && self.messageModels.count > 0) {
        newestSid = ((NoaMessageModel *)self.messageModels.lastObject).message.serviceMsgID ?: @"";
    }
    if (newestSid.length == 0 && self.messageModels.count > 0) {
        // 兼容尚未 ACK 的边界：退回 client msgID（服务端也可能按 msg 匹配不到，仅作兜底）
        newestSid = ((NoaMessageModel *)self.messageModels.lastObject).message.msgID ?: @"";
    }
    NSString *oldestSid = @"";
    if (self.messageModels.count > 0) {
        oldestSid = ((NoaMessageModel *)self.messageModels.firstObject).message.serviceMsgID ?: ((NoaMessageModel *)self.messageModels.firstObject).message.msgID ?: @"";
    }
    DLog(@"[MsgTime] reconnect gap-fill newestSid=%@ oldestSid=%@ listCount=%lu", newestSid, oldestSid, (unsigned long)self.messageModels.count);
    [IMSDKManager messageReConnectGetHistoryRecordWith:_sessionID chatType:_chatType lastMessageId:oldestSid messageId:newestSid offset:0 historyList:^(NSArray<NoaIMChatMessageModel *> * _Nullable chatMessageHistory, NSInteger offset) {
        
        if (chatMessageHistory.count > 0) {
            // offset=0 且列表已有数据时走增量 merge，避免整表替换跳动
            [weakSelf dealChatMessageHistoryWith:chatMessageHistory offset:offset];
        }else {
            [ZTOOL doInMain:^{
                [weakSelf.baseTableView.mj_header endRefreshing];
            }];
        }
    }];
}

//开始已读消息上报的定时器
- (void)startUploadChatMsgReadedTimer {
    [self checkChatViewUnreadedMessage];
    //上报已读开始定时器
    if (self.uploadReadedTimer) {
        [self.uploadReadedTimer setFireDate:[NSDate distantPast]];
    }
}

//暂停已读消息上报的定时器
- (void)pauseUploadChatMsgReadedTimer {
    if (self.uploadReadedTimer) {
        [self.uploadReadedTimer setFireDate:[NSDate distantFuture]];
    }
}

#pragma mark - 消息已读数据上报，2秒检查一次unReadSmsgidList是否有值，如果有就上传并及时清空
-(void)refreshUploadChatMessageReaded {
    //消息已读上报
    if (self.unReadSmsgidList.count > 0) {
       NoaIMChatMessageModel *uploadReadedMesage = [NoaMessageSendHander ZMessageReadedWithMsgSidList:[self.unReadSmsgidList safeArray] withToUserId:self.sessionID withChatType:self.chatType];
        [IMSDKManager toolSendChatMessageWith:uploadReadedMesage];
        [self.unReadSmsgidList removeAllObjects];
    }
}

#pragma mark - 收到用户角色 uploadFile 权限发生变化的通知
- (void)userRoleAuthorityUploadFileChange {
    [_viewInput reloadSetupDataWithTranslateBtnStatus:_sessionModel.isSendAutoTranslate];
}

#pragma mark - 收到用户角色 uploadImageVideo 权限发生变化的通知
- (void)userRoleAuthorityUploadImageVideoChange {
    [_viewInput reloadSetupDataWithTranslateBtnStatus:_sessionModel.isSendAutoTranslate];
}

#pragma mark - 收到用户角色 是否允许删除消息 权限发生变化的通知
- (void)userRoleAuthorityDeleteMessageChange {
    if (self.chatType == CIMChatType_SingleChat) {
        //单聊
        if ([UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
            _topView.btnTime.hidden = NO;
        } else {
            _topView.btnTime.hidden = YES;
        }
    }
}
#pragma mark - 群置顶消息定位通知
- (void)groupTopMessageLocation:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *smsgId = [userInfo objectForKeySafe:@"smsgId"];
    // 支持单聊和群聊：单聊传 friendUid，群聊传 groupId
    NSString *sessionId = [userInfo objectForKeySafe:@"groupId"] ?: [userInfo objectForKeySafe:@"friendUid"];
    
    // 检查是否是当前会话
    if (![sessionId isEqualToString:self.sessionID]) {
        return;
    }
    
    if (!smsgId.length) {
        return;
    }
    
    // 先尝试从数据库获取消息，以获取 sendTime（排除删除和撤回的消息）
    NoaIMChatMessageModel *targetMessage = [IMSDKManager toolGetOneChatMessageWithServiceMessageIDExcludeDeleted:smsgId sessionID:self.sessionID];
    if (!targetMessage) {
        [HUD showMessage:LanguageToolMatch(@"找不到本条消息") inView:self.view];
        return;
    }
    
    long long startTime = targetMessage.sendTime;
    
    // 当前显示的第一条消息发送时间
    long long nowFirstMessageTime = 0;
    if (self.messageModels.count > 0) {
        NoaMessageModel *model = [self.messageModels objectAtIndex:0];
        nowFirstMessageTime = model.message.sendTime;
    }
    
    __block NSInteger modelIndex = 0;
    if (startTime < nowFirstMessageTime) {
        // 被选中的消息，不在当前列表里，查询此时间范围内消息。为了界面体验，多请求一点数据
        __block NSMutableArray *newMessageList = [[NSMutableArray alloc] init];
        // 查询到的数据
        NSMutableArray *history = [IMSDKManager toolGetChatMessageHistoryWith:_sessionID startTime:startTime endTime:nowFirstMessageTime].mutableCopy;
        // 多请求一点数据
        NSArray *moreHistory = [IMSDKManager toolGetChatMessageHistoryWith:_sessionID offset:history.count + self.messageModels.count];
        NSRange moreRange = NSMakeRange(0, moreHistory.count);
        NSIndexSet *moreIndex = [NSIndexSet indexSetWithIndexesInRange:moreRange];
        [history insertObjects:moreHistory atIndexes:moreIndex];
        
        [history enumerateObjectsUsingBlock:^(NoaIMChatMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NoaMessageModel *newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:obj];
            [newMessageList addObject:newMsgModel];
            if ([obj.serviceMsgID isEqualToString:smsgId]) {
                modelIndex = idx;
            }
        }];
        NSRange range = NSMakeRange(0, newMessageList.count);
        NSIndexSet *nsindex = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.messageModels insertObjects:newMessageList atIndexes:nsindex];
    } else {
        [self.messageModels enumerateObjectsUsingBlock:^(NoaMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.message.serviceMsgID isEqualToString:smsgId]) {
                modelIndex = idx;
                *stop = YES;
            }
        }];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:modelIndex inSection:0];
    _chatHistorySelectIndex = indexPath;
    [self.baseTableView reloadData];
    
    // 当前总行数下标 防止越界崩溃
    NSInteger totalRowIndex = [self.baseTableView numberOfRowsInSection:0] - 1;
    if (_chatHistorySelectIndex.row > totalRowIndex) {
        _chatHistorySelectIndex = [NSIndexPath indexPathForRow:totalRowIndex inSection:0];
    }
    // 延迟执行滚动到指定位置
    WeakSelf
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        [weakSelf.baseTableView scrollToRowAtIndexPath:weakSelf.chatHistorySelectIndex atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        [weakSelf checkVisibleCellDoAnimation];
    });
}


//systemconfig每5分钟刷新是否音视频通过权限
- (void)appSystemConfigEnableAudioAndVideoCalls {
    [self.viewGroupCallTip updateUI];
    [_viewInput reloadSetupDataWithTranslateBtnStatus:_sessionModel.isSendAutoTranslate];
}

#pragma mark - 数据请求
//获取标签栏数据
- (void)requestChatTagList {
    //标签类型：1单聊 2群聊
    NSInteger tagType = (self.chatType == CIMChatType_SingleChat ? 1 : 2);
    WeakSelf;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:self.sessionID forKey:@"dialog"];
    [dict setObjectSafe:[NSNumber numberWithInteger:tagType] forKey:@"tagType"];
    if (![NSString isNil:UserManager.userInfo.userUID]) {
        [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    }
    [IMSDKManager MessageChatTagListWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD hideHUD];

        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDict = (NSDictionary *)data;
            NSArray *tagList =  (NSArray *)[dataDict objectForKey:@"conversationTagVos"];
            weakSelf.topView.chatLinkArr = [NoaChatTagModel mj_objectArrayWithKeyValuesArray:tagList];
            weakSelf.topView.isShowGroupNotice = [[dataDict objectForKey:@"groupNotice"] boolValue];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [ZTOOL doInMain:^{
            [HUD showMessageWithCode:code errorMsg:msg inView:weakSelf.view];
        }];

    }];
}

//是否禁言/禁言时间
- (void)getUserNotalkState {
    WeakSelf;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:self.sessionID forKey:@"groupId"];
    if (![NSString isNil:UserManager.userInfo.userUID]) {
        [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    }
    [[NoaIMHttpManager sharedManager] groupGetUserNotalkStateWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD hideHUD];

        if (data && [data isKindOfClass:[NSDictionary class]]) {
            if(weakSelf.groupInfo.userGroupRole == 0) {
                //isGroupChat;//群组是否被禁言 0否 1是
                NSInteger isGroupChat = [[data objectForKeySafe:@"isGroupChat"] integerValue];
                weakSelf.isAllMemberNotalk = (isGroupChat == 1 ? YES : NO);
            } else if (weakSelf.groupInfo.userGroupRole == 1 || weakSelf.groupInfo.userGroupRole == 2) {
                weakSelf.isAllMemberNotalk = NO;
            }
            //个人是否被禁言 0否 1是
            NSInteger isGroupForbid = [[data objectForKeySafe:@"isGroupForbid"] integerValue];
            weakSelf.isCurUserNotalk = (isGroupForbid == 1 ? YES : NO);
            if (![NSString isNil:[NSString stringWithFormat:@"%@",[data objectForKeySafe:@"startTime"]]] && ![NSString isNil:[NSString stringWithFormat:@"%@",[data objectForKeySafe:@"endTime"]]]) {
                weakSelf.notalkTime = [NSDate getTimeDifferenceWithStartTime:[NSString stringWithFormat:@"%@",[data objectForKeySafe:@"startTime"]] andEndTime:[NSString stringWithFormat:@"%@",[data objectForKeySafe:@"endTime"]] timeFormatter:@"yyyy-MM-dd HH:mm:ss"];
            } else {
                weakSelf.notalkTime = 0;
            }
            [weakSelf reloadBottomView];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [ZTOOL doInMain:^{
            [HUD hideHUD];
        }];

    }];
}

//获取本地群聊信息
- (void)getGroupInfoFromDB {
    //先去本地数据库信息进行展示
    LingIMGroupModel *groupModel = [IMSDKManager toolCheckMyGroupWith:self.sessionID];
    if (groupModel) {
        if (groupModel.groupStatus == 0) {
            //群封禁
//            [self showTipAlertView:LanguageToolMatch(@"该群已被封禁，如需申诉请联系管理员") btnName:LanguageToolMatch(@"我知道了") isNeedDelete:NO];
            [self deleteSessionAndChatMessage];

        } else if (groupModel.groupStatus == 1) {
            //群状态 正常
        } else if (groupModel.groupStatus == 2) {
            if (self.groupInfo.groupInformStatus == 1) {
                //群状态 解散
                [self showTipAlertView:LanguageToolMatch(@"群聊已解散") btnName:LanguageToolMatch(@"我知道了") isNeedDelete:YES];
            } else {
                [self deleteSessionAndChatMessage];
                WeakSelf
                [self.navigationController.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[CandyTalkHomeViewController class]]) {
                        CandyTalkHomeViewController *vc = (CandyTalkHomeViewController *)obj;
                        [weakSelf.navigationController popToViewController:vc animated:YES];
                        *stop = YES;
                    }
                }];
            }
        }
    }
}

//群聊时，重新获取groupInfo
- (void)getGroupInfoFromServer {
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.sessionID forKey:@"groupId"];
    if (![NSString isNil:UserManager.userInfo.userUID]) {
        [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    }
    [[NoaIMSDKManager sharedTool] getGroupInfoWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)data;
            LingIMGroup *groupInfoModel = [LingIMGroup mj_objectWithKeyValues:dict];
            LingIMGroupModel *imGroupModel = [NoaMessageTools netWorkGroupModelToDBGroupModel:groupInfoModel];
            if (imGroupModel) {
                LingIMGroupModel *localGroupModel = [IMSDKManager toolCheckMyGroupWith:groupInfoModel.groupId];
                imGroupModel.lastSyncMemberTime = localGroupModel.lastSyncMemberTime;
                imGroupModel.lastSyncActiviteScoreime = localGroupModel.lastSyncActiviteScoreime;
                [IMSDKManager toolInsertOrUpdateGroupModelWith:imGroupModel];
                if (imGroupModel.isNetCall != localGroupModel.isNetCall || imGroupModel.userGroupRole != localGroupModel.userGroupRole) {
                    [weakSelf appSystemConfigEnableAudioAndVideoCalls];
                }
                
            }
            //仅允许群管理查看群人数（1=是，0=否）
            if ([UserManager.userRoleAuthInfo.showGroupPersonNum.configValue isEqualToString:@"true"]) {
                weakSelf.topView.chatName = [NSString showAppointWidith:ChatTopTitleWidth sessionName:groupInfoModel.groupName peopleNum:[NSString stringWithFormat:@"%ld", (long)groupInfoModel.memberCount]];
            } else {
                if ([ZHostTool.appSysSetModel.onlyAllowAdminViewGroupPersonCount isEqualToString:@"1"]) {
                    if (groupInfoModel.userGroupRole == 0) {
                        //普通群成员不显示群成员数量
                        weakSelf.topView.chatName = [NSString showAppointWidith:ChatTopTitleWidth sessionName:groupInfoModel.groupName peopleNum:@""];
                    } else {
                        //群主和管理员展示群成员数量
                        weakSelf.topView.chatName = [NSString showAppointWidith:ChatTopTitleWidth sessionName:groupInfoModel.groupName peopleNum:[NSString stringWithFormat:@"%ld", (long)groupInfoModel.memberCount]];
                    }
                } else {
                    weakSelf.topView.chatName = [NSString showAppointWidith:ChatTopTitleWidth sessionName:groupInfoModel.groupName peopleNum:[NSString stringWithFormat:@"%ld", (long)groupInfoModel.memberCount]];
                }
            }
            
            
            weakSelf.groupInfo = groupInfoModel;
            // 群聊时，将群聊信息传递给topView，让其用来判断是否隐藏显示添加连接、设置链接按钮
            weakSelf.topView.groupInfo = weakSelf.groupInfo;
            
            
            if (weakSelf.groupInfo.isPrivateChat && weakSelf.groupInfo.userGroupRole == 0) {
                [weakSelf.viewInput configShowAtUserListStatus:NO];
            } else {
                [weakSelf.viewInput configShowAtUserListStatus:YES];
            }
        
            //我是否还在本群
            if (!weakSelf.groupInfo.userInGroup) {
                //判断一下当前群组状态 0封禁 1正常 2解散
                if (weakSelf.groupInfo.groupStatus == 0) {
                    //群封禁
                    [weakSelf deleteSessionAndChatMessage];

//                    [self showTipAlertView:LanguageToolMatch(@"该群已被封禁，如需申诉请联系管理员") btnName:LanguageToolMatch(@"我知道了") isNeedDelete:NO];
                } else if (weakSelf.groupInfo.groupStatus == 2) {
                    if (self.groupInfo.groupInformStatus == 1) {
                        //群解散
                        [weakSelf deleteSessionAndChatMessage];

//                        [weakSelf showTipAlertView:LanguageToolMatch(@"群聊已解散") btnName:LanguageToolMatch(@"我知道了") isNeedDelete:YES];
                    } else {
                        [weakSelf deleteSessionAndChatMessage];
                        [weakSelf.navigationController.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            if ([obj isKindOfClass:[CandyTalkHomeViewController class]]) {
                                CandyTalkHomeViewController *vc = (CandyTalkHomeViewController *)obj;
                                [weakSelf.navigationController popToViewController:vc animated:YES];
                                *stop = YES;
                            }
                        }];
                    }
                }
            }else {
                //判断一下当前群组状态 0封禁 1正常 2解散
                if (weakSelf.groupInfo.groupStatus == 0) {
                    //群封禁
                    [self showTipAlertView:LanguageToolMatch(@"该群已被封禁，如需申诉请联系管理员") btnName:LanguageToolMatch(@"我知道了") isNeedDelete:NO];
                } else if (weakSelf.groupInfo.groupStatus == 2) {
                    if (self.groupInfo.groupInformStatus == 1) {
                        [weakSelf deleteSessionAndChatMessage];

                        //群解散
//                        [weakSelf showTipAlertView:LanguageToolMatch(@"群聊已解散") btnName:LanguageToolMatch(@"我知道了") isNeedDelete:YES];
                    } else {
                        [weakSelf deleteSessionAndChatMessage];
                        [weakSelf.navigationController.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            if ([obj isKindOfClass:[CandyTalkHomeViewController class]]) {
                                CandyTalkHomeViewController *vc = (CandyTalkHomeViewController *)obj;
                                [weakSelf.navigationController popToViewController:vc animated:YES];
                                *stop = YES;
                            }
                        }];
                    }
                }
            }
            
            //群主/管理员可以设置消息自动删除
            weakSelf.topView.btnTime.hidden = weakSelf.groupInfo.userGroupRole != 0 ? NO : YES;
            
            if (![NSString isNil:groupInfoModel.groupNotice.noticeId]) {
                // 如果最新群公告存在，就请求群公告信息
                // TODO: 新版本代码---只要有群公告，就展示(不考虑置顶)
                [weakSelf showGroupNoticeTipViewWith:groupInfoModel.groupNotice.content translateNoticeContent:groupInfoModel.groupNotice.translateContent];
                weakSelf.topView.isShowGroupNotice = YES;
                [weakSelf requestGroupNoticeInfo];
            } else {
                // 群内无任何群公告信息，就移除置顶群公告
                [weakSelf groupNoticeTipAction:0];
                weakSelf.topView.isShowGroupNotice = NO;
            }
        } else {
            //接口成功了但是返回数据格式不对
            weakSelf.topView.chatName = [NSString showAppointWidith:ChatTopTitleWidth sessionName:self.chatName peopleNum:@""];
            //从本地获取群信息
            [weakSelf getGroupInfoFromDB];
        }
        //群禁言状态
        [weakSelf getUserNotalkState];
        //删除该时间戳之前的本地消息
        [weakSelf deleteMessageBeforTime: weakSelf.groupInfo.canMsgTime];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        weakSelf.topView.chatName = [NSString showAppointWidith:ChatTopTitleWidth sessionName:self.chatName peopleNum:@""];
        //群禁言状态
        [weakSelf getUserNotalkState];
        //群信息接口请求失败，使用本地缓存数据进行群状态展示
        [weakSelf getGroupInfoFromDB];
    }];
}

//获取群聊公告信息
- (void)requestGroupNoticeInfo {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:self.sessionID forKey:@"groupId"];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    NSString *groupNoticeId = self.groupInfo.groupNotice.noticeId == nil ? @"" : self.groupInfo.groupNotice.noticeId;
    [dict setObjectSafe:groupNoticeId forKey:@"noticeId"];
    WeakSelf
    [IMSDKManager groupCheckOneGroupNoticeWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDict = (NSDictionary *)data;
            NoaGroupNoteModel *groupNoticeModel = [NoaGroupNoteModel mj_objectWithKeyValues:dataDict];
            /**
             * TODO: 旧版本代码---群公告未读且置顶时展示
             if ([groupNoticeModel.readStatus isEqualToString:@"0"] && [groupNoticeModel.topStatus isEqualToString:@"1"]) {
                 //未读且置顶
                 [weakSelf showGroupNoticeTipViewWith:groupNoticeModel.content translateNoticeContent:groupNoticeModel.translateContent];
             }
             */
            weakSelf.groupNoticeModel = groupNoticeModel;
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
    }];
}

//单聊-获取用户信息
- (void)requestUserInfo {
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_sessionID forKey:@"userUid"];
    [IMSDKManager getUserInfoWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD hideHUD];

        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *userDict = (NSDictionary *)data;
            weakSelf.userModel = [NoaUserModel mj_objectWithKeyValues:userDict];
            weakSelf.userModel.userUID = [NSString stringWithFormat:@"%@",[userDict objectForKeySafe:@"userUid"]];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg inView:weakSelf.view];
    }];
}

//获取群组成员
- (void)requestAllGroupMemberReloadTable:(BOOL)reload {
    WeakSelf;
    [ZTOOL doInBackground:^{
        [IMSDKManager imSdkCreatSaveGroupMemberTableWith:self.sessionID syncGroupMemberSuccess:^{
            if (reload) {
                [weakSelf.baseTableView reloadData];
            }
        } syncGroupMemberFaiule:^{
        }];
    }];
}
//请求群置顶消息列表
// 判断是否有群公告显示
- (BOOL)hasGroupNoticeDisplayed {
    return _viewGroupNotice != nil && !_viewGroupNotice.hidden && !self.multiSelectStatus;
}

- (void)requestGroupTopMessages {
    if (self.chatType != CIMChatType_GroupChat || !self.sessionID.length) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    [params setObjectSafe:self.sessionID forKey:@"groupId"];
    
    WeakSelf
    [IMSDKManager MessageQueryGroupTopMsgsWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD hideHUD];
        // 如果有群公告显示，则隐藏群置顶消息
        if ([weakSelf hasGroupNoticeDisplayed]) {
            weakSelf.groupTopMessageView.hidden = YES;
            // 更新 header 高度
            [weakSelf updateTableViewContentInset];
            return;
        }
        
        // data 直接就是数组
        NSArray *rows = nil;
        if ([data isKindOfClass:[NSArray class]]) {
            rows = (NSArray *)data;
        }
        
        if ([rows isKindOfClass:[NSArray class]] && rows.count > 0) {
            // 取出所有数据，不再限制数量，直接传递字典数组
            [weakSelf.groupTopMessageView updateWithTopMessages:rows sessionID:weakSelf.sessionID];
        } else {
            [weakSelf.groupTopMessageView updateWithTopMessages:nil sessionID:weakSelf.sessionID];
        }
        // 延迟更新 header 高度，等待 groupTopMessageView 的显示/隐藏动画完成（动画时间 0.3 秒）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf updateTableViewContentInset];
        });
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [ZTOOL doInMain:^{
            [HUD hideHUD];
            // 请求失败，隐藏置顶消息 View
            [weakSelf.groupTopMessageView updateWithTopMessages:nil sessionID:weakSelf.sessionID];
            // 延迟更新 header 高度，等待 groupTopMessageView 的显示/隐藏动画完成（动画时间 0.3 秒）
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf updateTableViewContentInset];
            });
        }];
        
    }];
}

//获取群组成员信息，然后再获取群组成员的活跃积分
- (void)requestAllGroupMember {
    WeakSelf;
    [ZTOOL doInBackground:^{
        [IMSDKManager imSdkCreatSaveGroupMemberTableWith:self.sessionID syncGroupMemberSuccess:^{
            [HUD hideHUD];

            LingIMGroupModel *localGroupInfo = [IMSDKManager toolCheckMyGroupWith:weakSelf.sessionID];
            long long currentTime = [NSDate getCurrentTimeIntervalWithSecond];
            if ((currentTime - localGroupInfo.lastSyncActiviteScoreime)/1000 > [ZHostTool.appSysSetModel.member_active_points_interval longLongValue]) {
                [weakSelf requestAllGroupMemberActiviteScore];
            } else {
                [weakSelf.baseTableView reloadData];
            }
        } syncGroupMemberFaiule:^{
            [HUD hideHUD];

        }];
    }];
}

- (void)requestAllGroupMemberActiviteScore {
    WeakSelf
    [ZTOOL doInBackground:^{
        [IMSDKManager imSdkGetGroupMemberActiviteScoreTableWith:self.sessionID syncMemberActiviteScoreSuccess:^{
            [weakSelf.baseTableView reloadData];
        } syncMemberActiviteScoreFaiule:^{
        }];
    }];
}

//添加表情图片到表情收藏
- (void)requestAddStickersToCollectionWithDic:(NSMutableDictionary *)dict  isReloadCollection:(BOOL)isReloadCollection {
    WeakSelf
    [IMSDKManager imSdkUserAddStickersToCollectList:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD showMessage:LanguageToolMatch(@"操作成功") inView:weakSelf.view];
        if (isReloadCollection) {
            [weakSelf.viewInput reloadGetMyCollectionStickers];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg inView:weakSelf.view];
    }];
}

//修改了当前会话的翻译配置信息，更新到服务端
- (void)requestTranslateConfigUpload {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:![NSString isNil:_sessionModel.sendTranslateChannel] ? _sessionModel.sendTranslateChannel : @"" forKey:@"channel"];
    [dict setObjectSafe:![NSString isNil:_sessionModel.sendTranslateChannelName] ? _sessionModel.sendTranslateChannelName : @"" forKey:@"channelName"];
    [dict setObjectSafe:_sessionModel.sessionID forKey:@"dialogId"];
    [dict setObjectSafe:_sessionModel.translateConfigId forKey:@"id"];
    [dict setObjectSafe:@(1) forKey:@"level"];      //级别：0：用户全局配置；1:会话级别
    [dict setObjectSafe:![NSString isNil:_sessionModel.sendTranslateLanguage] ? _sessionModel.sendTranslateLanguage : @"" forKey:@"targetLang"];
    [dict setObjectSafe:![NSString isNil:_sessionModel.sendTranslateLanguageName] ? _sessionModel.sendTranslateLanguageName : @"" forKey:@"targetLangName"];
    [dict setObjectSafe:@(_sessionModel.isSendAutoTranslate) forKey:@"translateSwitch"];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    [dict setObjectSafe:![NSString isNil:_sessionModel.receiveTranslateChannel] ? _sessionModel.receiveTranslateChannel : @"" forKey:@"receiveChannel"];
    [dict setObjectSafe:![NSString isNil:_sessionModel.receiveTranslateChannelName] ? _sessionModel.receiveTranslateChannelName : @"" forKey:@"receiveChannelName"];
    [dict setObjectSafe:![NSString isNil:_sessionModel.receiveTranslateLanguage] ? _sessionModel.receiveTranslateLanguage : @"" forKey:@"receiveTargetLang"];
    [dict setObjectSafe:![NSString isNil:_sessionModel.receiveTranslateLanguageName] ? _sessionModel.receiveTranslateLanguageName : @"" forKey:@"receiveTargetLangName"];
    [dict setObjectSafe:@(_sessionModel.isReceiveAutoTranslate) forKey:@"receiveTranslateSwitch"];
    
    
    [IMSDKManager imSdkTranslateUploadNewTranslateConfig:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
       
    }];
}

//获取翻译默认值
- (void)requestDefaultData {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (![NSString isNil:UserManager.userInfo.userUID]) {
        [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    }
    WeakSelf
    [[NoaIMSDKManager sharedTool] userTranslateDefaultWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if (data) {
            weakSelf.defaultModel = [NoaTranslateDefaultModel mj_objectWithKeyValues:data];
            if ([NSString isNil:weakSelf.sessionModel.sendTranslateChannel]) {
                weakSelf.sessionModel.sendTranslateChannel = weakSelf.defaultModel.sendChannel;
                weakSelf.sessionModel.sendTranslateChannelName = weakSelf.defaultModel.sendChannelName;
            }
            if ([NSString isNil:weakSelf.sessionModel.sendTranslateLanguage]) {
                weakSelf.sessionModel.sendTranslateLanguage = weakSelf.defaultModel.sendTargetLang;
                weakSelf.sessionModel.sendTranslateLanguageName = weakSelf.defaultModel.sendTargetLangName;
            }
            if ([NSString isNil:weakSelf.sessionModel.receiveTranslateChannel]) {
                weakSelf.sessionModel.receiveTranslateChannel = weakSelf.defaultModel.receiveChannel;
                weakSelf.sessionModel.receiveTranslateChannelName = weakSelf.defaultModel.receiveChannelName;
            }
            if ([NSString isNil:weakSelf.sessionModel.receiveTranslateLanguage]) {
                weakSelf.sessionModel.receiveTranslateLanguage = weakSelf.defaultModel.receiveTargetLang;
                weakSelf.sessionModel.receiveTranslateLanguageName = weakSelf.defaultModel.receiveTargetLangName;
            }
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [ZTOOL doInMain:^{
            [HUD showMessageWithCode:code errorMsg:msg inView:weakSelf.view];
        }];

    }];
}

- (void)requestFriendInfoForServer {
    WeakSelf
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    [params setValue:self.sessionID forKey:@"friendUserUid"];
    [IMSDKManager getFriendInfoWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        StrongSelf
        NSDictionary *friendDict = (NSDictionary *)data;
        LingIMFriendModel *friendModel = [LingIMFriendModel mj_objectWithKeyValues:friendDict];
        [strongSelf deleteMessageBeforTime:friendModel.canMsgTime];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
    }];
}

// 删除某会话的某个时间之前的全部消息
- (void)deleteMessageBeforTime:(long long)canMsgTime {
    if (canMsgTime == 0) return;
    BOOL result = [IMSDKManager toolMessageDeleteBeforTime:canMsgTime withSessionID:self.sessionID];
    if (result) {
        WeakSelf
        [self.messageModels enumerateObjectsUsingBlock:^(NoaMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            StrongSelf
            if (obj.message.sendTime <= canMsgTime) {
                [strongSelf.messageModels removeObject:obj];
            }
        }];
        //处理消息是否显示时间
        [self computeVisibleTime];
        [ZTOOL doInMain:^{
            StrongSelf
            [strongSelf.baseTableView reloadData];
        }];
    }
}

#pragma mark - 获取消息记录
- (void)requestHistoryList {
    NoaMessageModel *model = [self.messageModels objectAtIndex:0];
    NSString *serviceMsgID = model.message.serviceMsgID;
    
    WeakSelf
    [IMSDKManager messageGetHistoryRecordWith:_sessionID chatType:_chatType serviceMsgID:serviceMsgID offset:self.messageModels.count pageNum:_pageNumber historyList:^(NSArray<NoaIMChatMessageModel *> * _Nullable chatMessageHistory, NSInteger offset, BOOL isLocal, NSInteger pageNumber) {
        if (!serviceMsgID && isLocal) {
            // 1.本地无任何聊天记录 2.这个回调是本地查询返回的回调，需要展示loading,等服务端数据返回后隐藏
            [ZTOOL doInMain:^{
                //消息请求加载
                [HUD showActivityMessage:@"" inView:weakSelf.view];
            }];
        }
        
        weakSelf.pageNumber = pageNumber;
        if (chatMessageHistory.count > 0) {
            if (isLocal && chatMessageHistory.count < 10) {
                [ZTOOL doInMain:^{
                    [HUD hideHUD];
                }];
            } else {
                [ZTOOL doInMain:^{
                    [HUD hideHUD];
                }];
            }
            [weakSelf dealChatMessageHistoryWith:chatMessageHistory offset:offset];
        } else {
            [ZTOOL doInMain:^{
                [HUD hideHUD];
                [weakSelf.baseTableView.mj_header endRefreshing];
            }];
        }
    }];
}

- (void)headerRefreshData {
    [self requestHistoryList];
}

//消息处理
- (void)dealChatMessageHistoryWith:(NSArray<NoaIMChatMessageModel *> * _Nullable) chatMessageHistory offset:(NSInteger)offset {
    WeakSelf
    dispatch_async(_chatMessageUpdateQueue, ^{
        __block NSMutableArray *newMessageList = [[NSMutableArray alloc] init];
        [chatMessageHistory enumerateObjectsUsingBlock:^(NoaIMChatMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.messageType == CIMChatMessageType_ServerMessage) {
                if (weakSelf.groupInfo.groupInformStatus == 1) {
                    if (obj.backDelInformSwitch == 0) {
                        NoaMessageModel *newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:obj];
                        [newMessageList addObject:newMsgModel];
                    } else {
                        if (obj.backDelInformUidArray != nil) {
                            if (obj.backDelInformUidArray.count == 0) {
                                NoaMessageModel *newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:obj];
                                [newMessageList addObject:newMsgModel];
                            } else {
                                if ([obj.backDelInformUidArray containsObject:UserManager.userInfo.userUID]) {
                                    NoaMessageModel *newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:obj];
                                    [newMessageList addObject:newMsgModel];
                                }
                            }
                        }
                    }
                }
            } else if (obj.messageType == CIMChatMessageType_BackMessage) {
                if (obj.backDelInformSwitch != 2) {
                    NoaMessageModel *newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:obj];
                    [newMessageList addObject:newMsgModel];
                }
            } else {
                NoaMessageModel *newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:obj];
                [newMessageList addObject:newMsgModel];
            }
            
        }];
        
        BOOL shouldScrollToBottom = NO;
        BOOL isFirstScreen = (offset == 0 && weakSelf.messageModels.count == 0);
        if (offset == 0) {
            if (isFirstScreen) {
                // 首次进入：直接填充
                [weakSelf.messageModels removeAllObjects];
                [weakSelf.messageModels addObjectsFromArray:newMessageList];
                shouldScrollToBottom = YES;
            } else {
                // 已有列表时（本地先展示后再同步服务端）：增量合并，禁止整表替换导致突然插入旧消息/跳动
                [weakSelf mergeHistoryMessageModels:newMessageList];
            }
        } else {
            // 上拉更旧：去重后前置插入
            NSMutableArray *toPrepend = [NSMutableArray array];
            for (NoaMessageModel *incoming in newMessageList) {
                if (![weakSelf containsChatMessageModel:incoming]) {
                    [toPrepend addObject:incoming];
                }
            }
            if (toPrepend.count > 0) {
                NSRange range = NSMakeRange(0, toPrepend.count);
                NSIndexSet *nsindex = [NSIndexSet indexSetWithIndexesInRange:range];
                [weakSelf.messageModels insertObjects:toPrepend atIndexes:nsindex];
            }
            newMessageList = toPrepend;
        }
        //处理消息是否显示时间
        [weakSelf computeVisibleTime];
        
        [ZTOOL doInMain:^{
            [weakSelf.baseTableView.mj_header endRefreshing];
            [weakSelf debounceChatReload];
            
            if (offset == 0) {
                if (shouldScrollToBottom) {
                    if (weakSelf.viewInput.isEditMode && weakSelf.editCellIndexPath) {
                       // 当前正在编辑中，不要滚动
                    } else {
                        [weakSelf tableViewScrollToBottom:NO duration:0.25];
                    }
                    [weakSelf performSelector:@selector(checkChatViewUnreadedMessage) withObject:nil afterDelay:1.2];
                }
            } else {
                //下拉加载，将新加载数据的最后一条，滚动到顶部
                if (newMessageList.count > 0 && [weakSelf.baseTableView numberOfRowsInSection:0] != 0) {
                    //判断当前总下标
                    NSInteger currentTotalRowIndex = [weakSelf.baseTableView numberOfRowsInSection:0] - 1;//(0-9)10条数据
                    //需要滚动到的新下标
                    NSInteger newScrollRowIndex = newMessageList.count;//下拉刷新需要显示下拉之前的消息，所以不-1
                    //对比新下标和总下标
                    NSIndexPath *scrollIndexPath;
                    if (newScrollRowIndex >= currentTotalRowIndex) {
                        scrollIndexPath = [NSIndexPath indexPathForRow:currentTotalRowIndex inSection:0];
                    }else {
                        scrollIndexPath = [NSIndexPath indexPathForRow:newScrollRowIndex inSection:0];
                    }
                    [weakSelf.baseTableView scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                }
            }
        }];
    });
}

/// 当前列表是否已包含该消息（msgID / serviceMsgID）
- (BOOL)containsChatMessageModel:(NoaMessageModel *)model {
    if (!model) { return NO; }
    NSString *msgID = model.message.msgID ?: @"";
    NSString *sid = model.message.serviceMsgID ?: @"";
    for (NoaMessageModel *existing in self.messageModels.safeArray) {
        if (msgID.length > 0 && existing.message.msgID.length > 0 && [existing.message.msgID isEqualToString:msgID]) {
            return YES;
        }
        if (sid.length > 0 && existing.message.serviceMsgID.length > 0 && [existing.message.serviceMsgID isEqualToString:sid]) {
            return YES;
        }
    }
    return NO;
}

/// 历史同步增量合并：只补缺口/更新内容，保留当前浏览稳定性
- (void)mergeHistoryMessageModels:(NSArray<NoaMessageModel *> *)incomingList {
    if (incomingList.count == 0) { return; }
    BOOL didChange = NO;
    for (NoaMessageModel *incoming in incomingList) {
        NSString *msgID = incoming.message.msgID ?: @"";
        NSString *sid = incoming.message.serviceMsgID ?: @"";
        NSInteger foundIndex = NSNotFound;
        NSArray *snapshot = self.messageModels.safeArray;
        for (NSInteger i = 0; i < snapshot.count; i++) {
            NoaMessageModel *existing = snapshot[i];
            BOOL sameMsg = (msgID.length > 0 && existing.message.msgID.length > 0 && [existing.message.msgID isEqualToString:msgID]);
            BOOL sameSid = (sid.length > 0 && existing.message.serviceMsgID.length > 0 && [existing.message.serviceMsgID isEqualToString:sid]);
            if (sameMsg || sameSid) {
                foundIndex = i;
                break;
            }
        }
        if (foundIndex != NSNotFound) {
            NoaMessageModel *existing = [self.messageModels objectAtIndex:foundIndex];
            // 已成功消息：避免服务端时间小幅抖动覆盖导致跨日跳动
            if (existing.message.messageSendType == CIMChatMessageSendTypeSuccess &&
                existing.message.sendTime > 0 &&
                incoming.message.sendTime > 0 &&
                llabs(existing.message.sendTime - incoming.message.sendTime) <= 3000) {
                incoming.message.sendTime = existing.message.sendTime;
            }
            // 保留本地翻译等展示状态
            if (existing.message.translateStatus != CIMTranslateStatusNone) {
                incoming.message.translateStatus = existing.message.translateStatus;
                incoming.message.translateContent = existing.message.translateContent ?: incoming.message.translateContent;
                incoming.message.againTranslateContent = existing.message.againTranslateContent ?: incoming.message.againTranslateContent;
            }
            [self.messageModels replaceObjectAtIndex:foundIndex withObject:incoming];
            didChange = YES;
        } else {
            [self.messageModels addObject:incoming];
            didChange = YES;
        }
    }
    if (didChange) {
        NSArray *sorted = [NSMutableArray sortMultiSelectedMessageArr:self.messageModels.safeArray.mutableCopy];
        [self.messageModels replaceAllObjectsWithArray:sorted];
    }
}

#pragma mark - NSNotification通知监听方法处理>>>>>>
//接收到删除文件的通知刷新当前页面
- (void)reloadMessageTabView:(NSNotification *)sender{
    //更新聊天页面
    __block NoaMessageModel * msgModel;
    NoaMessageModel * senderMsgModel = sender.object;
    [self.messageModels enumerateObjectsUsingBlock:^(NoaMessageModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([senderMsgModel.message.serviceMsgID isEqualToString:obj.message.serviceMsgID]){
            msgModel = obj;
            *stop = YES;
        }
    }];

    [self.messageModels removeObject:msgModel];
    //处理消息是否显示时间
    [self computeVisibleTime];
    
    WeakSelf
    [ZTOOL doInMain:^{
        [weakSelf.baseTableView reloadData];
    }];
    
    if ([[sender.userInfo objectForKeySafe:@"deleteType"] integerValue] == ZMsgDeleteTypeOneWay) {
        [self updateRefreshMsgWithOriginalMsg:msgModel.message.serviceMsgID];
    }
}

//获得选中消息列表
- (void)requestSelectHistoryList:(NSNotification *)sender {
    NSDictionary *userInfo = sender.userInfo;
    if ([userInfo.allKeys containsObject:@"selectMessageID"]) {
        NSString *messageID = [userInfo objectForKeySafe:@"selectMessageID"];
        long long startTime = [[userInfo objectForKeySafe:@"selectMessageSendTime"] longLongValue];
        //优化一下，不需要每次都查询数据，兼容某些系统不生效的问题
        //当前显示的第一条消息发送实现
        long long nowFirstMessageTime = 0;
        if (self.messageModels.count > 0) {
            NoaMessageModel *model = [self.messageModels objectAtIndex:0];
            nowFirstMessageTime = model.message.sendTime;
        }
    
        __block NSInteger modelIndex = 0;
        if (startTime < nowFirstMessageTime) {
            //被选中的消息，不在当前列表里，查询此时间范围内消息。为了界面体验，多请求一点数据
            __block NSMutableArray *newMessageList = [[NSMutableArray alloc] init];
            //查询到的数据
            NSMutableArray *history = [IMSDKManager toolGetChatMessageHistoryWith:_sessionID startTime:startTime endTime:nowFirstMessageTime].mutableCopy;
            //多请求一点数据
            NSArray *moreHistory = [IMSDKManager toolGetChatMessageHistoryWith:_sessionID offset:history.count + self.messageModels.count];
            NSRange moreRange = NSMakeRange(0, moreHistory.count);
            NSIndexSet *moreIndex = [NSIndexSet indexSetWithIndexesInRange:moreRange];
            [history insertObjects:moreHistory atIndexes:moreIndex];
            
            [history enumerateObjectsUsingBlock:^(NoaIMChatMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NoaMessageModel *newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:obj];
                [newMessageList addObject:newMsgModel];
                if ([obj.msgID isEqualToString:messageID]) {
                    modelIndex = idx;
                }
            }];
            NSRange range = NSMakeRange(0, newMessageList.count);
            NSIndexSet *nsindex = [NSIndexSet indexSetWithIndexesInRange:range];
            [self.messageModels insertObjects:newMessageList atIndexes:nsindex];
        } else {
            [self.messageModels enumerateObjectsUsingBlock:^(NoaMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.message.msgID isEqualToString:messageID]) {
                    modelIndex = idx;
                    *stop = YES;
                }
            }];
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:modelIndex inSection:0];
        _chatHistorySelectIndex = indexPath;
        [self.baseTableView reloadData];
        
        //当前总行数下标 防止越界崩溃
        NSInteger totalRowIndex = [self.baseTableView numberOfRowsInSection:0] - 1;
        if (_chatHistorySelectIndex.row > totalRowIndex) {
            _chatHistorySelectIndex = [NSIndexPath indexPathForRow:totalRowIndex inSection:0];
        }
        //延迟执行滚动到指定位置
        WeakSelf
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            [weakSelf.baseTableView scrollToRowAtIndexPath:weakSelf.chatHistorySelectIndex atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
            [weakSelf checkVisibleCellDoAnimation];
        });
    }
}

//群聊-在群设置里分享本群二维码到本群，接收通知，UI界面上需要App端本地添加当前这条二维码消息
- (void)shareQRcodeAddLocalMessageToUI:(NSNotification *)sender {
    NoaIMChatMessageModel *shareQRcodeMsgModel = sender.object;
    shareQRcodeMsgModel.messageSendType = CIMChatMessageSendTypeSuccess;
    shareQRcodeMsgModel.localImg = nil;
    shareQRcodeMsgModel.localImgName = nil;
    shareQRcodeMsgModel.localVideoName = nil;
    shareQRcodeMsgModel.localVoiceName = nil;
    shareQRcodeMsgModel.localVideoCover = nil;
    shareQRcodeMsgModel.localGeoImgName = nil;
    //转发消息是转发给当前聊天对象
    if ([self.sessionID isEqualToString:shareQRcodeMsgModel.toID]) {
        NoaMessageModel *sendMsg = [[NoaMessageModel alloc] initWithMessageModel:shareQRcodeMsgModel];
        //刷新并滚动到底部
        [self.messageModels addObject:sendMsg];
        //处理消息是否显示时间
        [self computeVisibleTime];
        
        WeakSelf
        [ZTOOL doInMain:^{
            [weakSelf.baseTableView reloadData];
        }];
        //加载滚动到底部
        [self tableViewScrollToBottom:NO duration:0.25];
    }
}

//群内禁止私聊状态更新
- (void)groupNoChatStatusChange:(NSNotification *)sender {
    NSDictionary *groupNoChatDict = sender.userInfo;
    NSString *groupID = [groupNoChatDict objectForKeySafe:@"gid"];
    if ([groupID isEqualToString:_sessionID]) {
        //当前群的 群内禁止私聊状态更新
        NSInteger status = [[groupNoChatDict objectForKeySafe:@"status"] integerValue];
        _groupInfo.isPrivateChat = status == 1 ? YES : NO;
    }
}

//用户在线状态更新
- (void)myFriendOnlineStatusChange:(NSNotification *)sender {
    NSDictionary *userInfoDict = sender.userInfo;
    NSString *myFriendID = [userInfoDict objectForKeySafe:@"friendID"];
    if ([myFriendID isEqualToString:_sessionID]) {
        BOOL onlineStatus = [[userInfoDict objectForKeySafe:@"friendStatus"] integerValue] == 1 ? YES : NO;
        _topView.viewOnline.hidden = !onlineStatus;
    }
}

//消息自动删除
- (void)messageTimeDelete:(NSNotification *)sender {
    NSDictionary *messageDeleteDict = sender.userInfo;
    //消息删除执行时间
    long long messageDeleteTime = [[messageDeleteDict objectForKeySafe:@"messageDeleteTime"] longLongValue];
    //消息删除类型
    NSInteger messageDeleteType = [[messageDeleteDict objectForKeySafe:@"messageDeleteType"] integerValue];
    //消息删除的会话
    NSString *messageDeleteSession = [messageDeleteDict objectForKeySafe:@"messageDeleteSession"];
    if (messageDeleteType > 0 && [messageDeleteSession isEqualToString:_sessionID]) {
        WeakSelf
        //需要删除的消息时间线
        long long messageCanDeleteTimeLine = messageDeleteTime - messageDeleteType * 24 * 60 * 60 * 1000;
        dispatch_async(_chatMessageUpdateQueue, ^{
            [IMSDKManager toolMessageDeleteBeforTime:messageCanDeleteTimeLine withSessionID:weakSelf.sessionID];
            NSArray *snapshot = [weakSelf.messageModels safeArray];
            NSMutableArray *kept = [NSMutableArray arrayWithCapacity:snapshot.count];
            [snapshot enumerateObjectsUsingBlock:^(NoaMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.message.sendTime > messageCanDeleteTimeLine) {
                    [kept addObject:obj];
                }
            }];
            [weakSelf.messageModels removeAllObjects];
            [weakSelf.messageModels addObjectsFromArray:kept];
            //处理消息是否显示时间
            [weakSelf computeVisibleTime];
            [ZTOOL doInMain:^{
                [weakSelf.baseTableView reloadData];
            }];
        });
    }
}

//群封禁状态变化监听
- (void)groupBanStatusChange:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *groupID = [userInfo objectForKeySafe:@"gid"];
    if ([groupID isEqualToString:self.sessionID] && [CurrentVC isKindOfClass:[NoaChatViewController class]]) {
        //当前群封禁状态改变，且当前显示聊天界面
        NSInteger bannedState = [[userInfo objectForKeySafe:@"status"] integerValue];
        if (bannedState) {
            [self showTipAlertView:LanguageToolMatch(@"该群已被封禁，如需申诉请联系管理员") btnName:LanguageToolMatch(@"我知道了") isNeedDelete:NO];
        } else {
            //弹窗消失
            [self dismissTipAlertView];
        }
    }
}

- (void)deleteUserMessageEvent:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *groupID = [userInfo objectForKeySafe:@"gid"];
    
    // 如果当前不是聊天界面，或者不是当前所在的群，则不处理禁言列表的更新操作
    if (![groupID isEqualToString:self.sessionID] || ![CurrentVC isKindOfClass:[NoaChatViewController class]]) {
        return;
    }
    
    NSArray *userIdList = [userInfo objectForKeySafe:@"deleteMemberUidList"];
    [self refreshMessageListAfterDeleteMemberHistHistory:userIdList];
}

#pragma mark - 通过点击全局搜索结果进入聊天界面
- (void)clickSearchResultInChatRoomWithMessage:(NoaIMChatMessageModel *)messageModel {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:messageModel.msgID forKey:@"selectMessageID"];
    [dict setValue:@(messageModel.sendTime) forKey:@"selectMessageSendTime"];
    
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ChatHistorySelectMessage" object:nil userInfo:dict];
    });
}
#pragma mark - 展示群公告提示View
- (void)showGroupNoticeTipViewWith:(NSString *)groupNoticeStr translateNoticeContent:(NSString *)translateContent {
    if (!_viewGroupNotice) {
        [self.view addSubview:self.viewGroupNotice];
    }
    //处理公告文字内容
    NSString *tempGroupNoctice = @"";
    if (![NSString isNil:translateContent]) {
        NSString *currentLanguageMapCode = [ZLanguageTOOL languageCodeFromDevieInfo];
        NSDictionary *noticeDict = [NSString  jsonStringToDic:translateContent];
        if (![[noticeDict allKeys] containsObject:currentLanguageMapCode]) {
            if ([currentLanguageMapCode isEqualToString:@"lb"]) {
                tempGroupNoctice = (NSString *)[noticeDict objectForKeySafe:@"lbb"];
            } else if ([currentLanguageMapCode isEqualToString:@"no"]) {
                tempGroupNoctice = (NSString *)[noticeDict objectForKeySafe:@"nor"];
            } else {
                NSString *notice_en = (NSString *)[noticeDict objectForKeySafe:@"en"];
                tempGroupNoctice = notice_en;
            }
        } else {
            NSString *notice_current = (NSString *)[noticeDict objectForKeySafe:currentLanguageMapCode];
            tempGroupNoctice = notice_current;
        }
    } else {
        tempGroupNoctice = groupNoticeStr;
    }
    
    _viewGroupNotice.lblGroupNotice.text = tempGroupNoctice;
    
    if (self.multiSelectStatus) {
        _viewGroupNotice.hidden = YES;
    } else {
        // 显示群公告时，隐藏群置顶消息（群公告优先级更高）
        if (self.groupTopMessageView) {
            self.groupTopMessageView.hidden = YES;
        }

    }
    // 更新 header 高度
    [self updateTableViewContentInset];

}

#pragma mark - 禁言定时器
- (void)timeAction{
    self.notalkTime--;
    if (self.notalkTime <= 0) {
        //关闭定时器
        [self.timer setFireDate:[NSDate distantFuture]];
        //取消定时器
        [self.timer invalidate];
        self.timer = nil;
        [self updateBottomInputUI];
    }else{
        _notalkStateLabel.text = [NSString stringWithFormat:LanguageToolMatch(@"禁言中 %@"),[NSDate getOvertime:[NSString stringWithFormat:@"%ld",self.notalkTime] isShowSecondStr:YES]];
    }
}

#pragma mark <是否超过发送消息时间间隔>
-(BOOL)isExceedSendMsgTimeInterval:(long long)msgSendTime{
    //判断当前聊天类型为群聊
    if(self.chatType == CIMChatType_GroupChat){
        if (self.groupInfo.userGroupRole == 2 || self.groupInfo.userGroupRole == 1) {
            //群主或管理员不受限制
            return YES;
        } else if (self.groupInfo.userGroupRole == 0) {
            //默认时间间隔为2秒 若 服务器返回 以服务器返回为准
            if(msgSendTime - self.sessionModel.lastSendMsgTime >=
               (ZHostTool.appSysSetModel.groupMessageInterval == 0 ? (2 * 1000) : ZHostTool.appSysSetModel.groupMessageInterval)){
                self.sessionModel.lastSendMsgTime = msgSendTime;
                [DBTOOL insertOrUpdateSessionModelWith:self.sessionModel];
                return YES;
            }else {
                [HUD showMessage:LanguageToolMatch(@"发送频次过快，请稍后重试！") inView:self.view];
                return NO;
            }
        } else {
            return YES;
        }
    } else{
        return YES;
    }
}

#pragma mark - ZChatInputViewDelegate
- (void)chatInputViewHeightChanged:(CGFloat)heigh {
    self.btnBottom.hidden = YES;
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewInput.height = heigh;
        weakSelf.viewInput.y = DScreenHeight - heigh;
        [ZTOOL doInMain:^{
            //修改列表界面布局约束
            [weakSelf.baseTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(weakSelf.view);
                make.top.equalTo(weakSelf.topView.mas_bottom);
                make.bottom.equalTo(weakSelf.viewInput.mas_top);
            }];
            [weakSelf.btnBottom mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(weakSelf.viewInput.mas_top).offset(-DWScale(25));
            }];
            [weakSelf tableViewScrollToBottom:NO duration:0.25];
        }];
    }];
}

#pragma mark - 文本消息、At消息 发送
- (void)chatInputViewSend:(NSString *)sendStr atUserList:(NSArray *)atUsersDictList atUserSegmentList:(NSArray *)atUserSegmentList {
    //发送内容不能为空
    if ([NSString isNil:sendStr]) {
        [HUD showMessage:LanguageToolMatch(@"发送内容不能为空")];
        return;
    }
    NSString *referenceId = @"";
    if (atUsersDictList.count > 0 && atUserSegmentList.count > 0) {
        //@用户消息（使用正则匹配@昵称，避免富文本和字符串位置不匹配的问题）
        NSString *originalStr = [NSString stringWithString:sendStr];
        // 构建@昵称到uid的映射表
        NSMutableDictionary<NSString *, NSString *> *atNameToUidMap = [NSMutableDictionary dictionary];

        NSUInteger atIndex = 0;
        for (NSDictionary *atUserDic in atUsersDictList) {
            if (atIndex >= atUserSegmentList.count) break;
            NSDictionary *seg = atUserSegmentList[atIndex];
            if (![seg isKindOfClass:NSDictionary.class]) {

                atIndex++;
                continue;
            }
            NSArray *atKeyArr = [atUserDic allKeys];
            NSString *atKey = (NSString *)[atKeyArr firstObject];
            NSString *atName = (NSString *)[atUserDic objectForKey:atKey];
            if ([atKey isEqualToString:UserManager.userInfo.userUID]) {
                atName = LanguageToolMatch(@"我自己");

            }
            if (atName && atKey) {
                NSString *atPattern = [NSString stringWithFormat:@"@%@ ", atName];
                [atNameToUidMap setObject:atKey forKey:atPattern];
            }
            atIndex++;
        }
        // 使用正则表达式匹配所有@昵称，按出现顺序替换
        NSMutableString *resultStr = [NSMutableString stringWithString:originalStr];
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@[\\u4e00-\\u9fa5\\w\\-\\_，]+ " options:0 error:&error];
        if (!error) {
            NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:originalStr options:0 range:NSMakeRange(0, originalStr.length)];
            // 倒序替换，避免索引偏移
            for (NSInteger i = matches.count - 1; i >= 0; i--) {
                NSTextCheckingResult *match = matches[i];
                NSString *matchedText = [originalStr substringWithRange:match.range];
                NSString *uid = [atNameToUidMap objectForKey:matchedText];
                if (uid) {
                    [resultStr replaceCharactersInRange:match.range withString:[NSString stringWithFormat:@"\v%@\v ", uid]];
                    // 移除已使用的映射，避免重复匹配
                    [atNameToUidMap removeObjectForKey:matchedText];
                }
            }

        }
        NSString *atContentStr = resultStr;

        if (self.viewInput.messageModelReference) {
            //@消息-引用
            referenceId = self.viewInput.messageModelReference.message.serviceMsgID;
        } else {
            //普通 @消息
            referenceId = @"";
        }
        NoaIMChatMessageModel *atSendMessage = [NoaMessageSendHander ZMessageAtUserSend:ZSensitiveFilter(atContentStr) showContent:@"" withAtUsersDicList:atUsersDictList withToUserId:self.sessionID withChatType:self.chatType referenceMsgId:referenceId];
        //判断是否大于群发消息间隔
        if(![self isExceedSendMsgTimeInterval:atSendMessage.sendTime]){
            return;
        }
        if (_sessionModel.isSendAutoTranslate == 1 && [UserManager isTranslateEnabled]) {
            atSendMessage.translateStatus = CIMTranslateStatusLoading;
            WeakSelf
            [self requestTranslateActionWithContent:atContentStr atUserDictList:atUsersDictList isSend:YES messageType:atSendMessage.messageType success:^(NSString * _Nullable result) {
                atSendMessage.atTranslateContent = result;
                atSendMessage.translateStatus = CIMTranslateStatusSuccess;
                //发送消息
                [IMSDKManager toolSendChatMessageWith:atSendMessage];
                // 更新会话最新时间并清空草稿，落库后通知刷新
                if (weakSelf.sessionModel) {
                    weakSelf.sessionModel.sessionLatestTime = atSendMessage.sendTime;
                    weakSelf.sessionModel.sessionLatestMessage = atSendMessage;
                    weakSelf.sessionModel.sessionLatestServerMsgID = atSendMessage.serviceMsgID ? atSendMessage.serviceMsgID : @"";
                    // 清除本地草稿并点对点刷新
                    [NoaDraftStore deleteDraftForSession:weakSelf.sessionID];
                    // 清空输入框与 @ 列表，并复位发送按钮
                    weakSelf.viewInput.inputContentStr = @"";
                    [weakSelf.viewInput configAtUserInfoList:@[]];
                    [weakSelf.viewInput configAtSegmentsInfoList:@[]];
//                    [weakSelf.viewInput setSendButtonHighlighted:NO];
                    if (weakSelf.draftDidChange) { weakSelf.draftDidChange(weakSelf.sessionID, @{}); }
                }
                [IMSDKManager toolInsertOrUpdateChatMessageWith:atSendMessage];
                [weakSelf replaceMessageModelWithNewMsgModel:atSendMessage];
            } failure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                atSendMessage.translateStatus = CIMTranslateStatusFail;
                atSendMessage.messageSendType = CIMChatMessageSendTypeFail;
                [IMSDKManager toolInsertOrUpdateChatMessageWith:atSendMessage];
                [weakSelf replaceMessageModelWithNewMsgModel:atSendMessage];
            }];
        } else {
            atSendMessage.translateStatus = CIMTranslateStatusNone;
            //发送消息
            [IMSDKManager toolSendChatMessageWith:atSendMessage];
            // 更新会话最新时间并清空草稿
            if (self.sessionModel) {
                self.sessionModel.sessionLatestTime = atSendMessage.sendTime;
                self.sessionModel.sessionLatestMessage = atSendMessage;
                self.sessionModel.sessionLatestServerMsgID = atSendMessage.serviceMsgID ? atSendMessage.serviceMsgID : @"";
                [NoaDraftStore deleteDraftForSession:self.sessionID];
                self.viewInput.inputContentStr = @"";
                [self.viewInput configAtUserInfoList:@[]];
                [self.viewInput configAtSegmentsInfoList:@[]];
//                [self.viewInput setSendButtonHighlighted:NO];
                if (self.draftDidChange) { self.draftDidChange(self.sessionID, @{}); }
            }
        }
        //添加到UI上
        [self chatListAppendMessage:atSendMessage];
        //如果发送的是引用消息，将输入框上引用的UI隐藏
        if (self.viewInput.messageModelReference) {
            WeakSelf
            [ZTOOL doInMain:^{
                weakSelf.viewInput.messageModelReference = nil;
            }];
        }
    } else {
        if (self.viewInput.messageModelReference) {
            //文本消息-引用
            referenceId = self.viewInput.messageModelReference.message.serviceMsgID;
        } else {
            //普通文本消息
            referenceId = @"";
        }
        NoaIMChatMessageModel *textSendMsg = [NoaMessageSendHander ZMessageTextSend:ZSensitiveFilter(sendStr) withToUserId:self.sessionID  withChatType:self.chatType referenceMsgId:referenceId];
        //判断是否大于群发消息间隔
        if(![self isExceedSendMsgTimeInterval:textSendMsg.sendTime]){
            return;
        }
        //翻译
        if (_sessionModel.isSendAutoTranslate == 1 && [UserManager isTranslateEnabled]) {
            textSendMsg.translateStatus = CIMTranslateStatusLoading;
            WeakSelf
            [self requestTranslateActionWithContent:sendStr atUserDictList:@[] isSend:YES messageType:textSendMsg.messageType success:^(NSString * _Nullable result) {
                textSendMsg.translateContent = result;
                textSendMsg.translateStatus = CIMTranslateStatusSuccess;
                //发送消息
                [IMSDKManager toolSendChatMessageWith:textSendMsg];
                // 更新会话最新时间并清空草稿
                if (weakSelf.sessionModel) {
                    weakSelf.sessionModel.sessionLatestTime = textSendMsg.sendTime;
                    weakSelf.sessionModel.sessionLatestMessage = textSendMsg;
                    weakSelf.sessionModel.sessionLatestServerMsgID = textSendMsg.serviceMsgID ? textSendMsg.serviceMsgID : @"";
                    [NoaDraftStore deleteDraftForSession:weakSelf.sessionID];
                    weakSelf.viewInput.inputContentStr = @"";
                    [weakSelf.viewInput configAtUserInfoList:@[]];
                    [weakSelf.viewInput configAtSegmentsInfoList:@[]];
//                    [weakSelf.viewInput setSendButtonHighlighted:NO];
                    if (weakSelf.draftDidChange) { weakSelf.draftDidChange(weakSelf.sessionID, @{}); }
                }
                [IMSDKManager toolInsertOrUpdateChatMessageWith:textSendMsg];
                [weakSelf replaceMessageModelWithNewMsgModel:textSendMsg];
            } failure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                textSendMsg.translateStatus = CIMTranslateStatusFail;
                textSendMsg.messageSendType = CIMChatMessageSendTypeFail;
                [IMSDKManager toolInsertOrUpdateChatMessageWith:textSendMsg];
                [weakSelf replaceMessageModelWithNewMsgModel:textSendMsg];
            }];
        } else {
            textSendMsg.translateStatus = CIMTranslateStatusNone;
            //发送消息
            [IMSDKManager toolSendChatMessageWith:textSendMsg];
            // 更新会话最新时间并清空草稿
            if (self.sessionModel) {
                self.sessionModel.sessionLatestTime = textSendMsg.sendTime;
                self.sessionModel.sessionLatestMessage = textSendMsg;
                self.sessionModel.sessionLatestServerMsgID = textSendMsg.serviceMsgID ? textSendMsg.serviceMsgID : @"";
                [NoaDraftStore deleteDraftForSession:self.sessionID];
                self.viewInput.inputContentStr = @"";
                [self.viewInput configAtUserInfoList:@[]];
                [self.viewInput configAtSegmentsInfoList:@[]];
//                [self.viewInput setSendButtonHighlighted:NO];
                if (self.draftDidChange) { self.draftDidChange(self.sessionID, @{}); }
            }
        }
        //添加到UI上
        [self chatListAppendMessage:textSendMsg];
        //如果发送的是引用消息，将输入框上引用内容的UI隐藏
        if (self.viewInput.messageModelReference) {
            WeakSelf
            [ZTOOL doInMain:^{
                weakSelf.viewInput.messageModelReference = nil;
            }];
        }
    }
    
    //输入框置空并恢复初始状态
    WeakSelf
    [ZTOOL doInMain:^{
        weakSelf.viewInput.inputContentStr = @"";
    }];
}

#pragma mark - 编辑已发送消息
// 将显示态 @昵称 按记录区间还原为服务端使用的 \vUID\v 格式。
- (NSString *)encodedEditContentFromDisplayText:(NSString *)displayText atSegments:(NSArray *)atSegments {
    NSMutableString *encoded = [displayText mutableCopy] ?: NSMutableString.string;
    NSArray *sortedSegments = [atSegments sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *left, NSDictionary *right) {
        NSRange leftRange = NSRangeFromString([left objectForKey:@"range"] ?: NSStringFromRange(NSMakeRange(0, 0)));
        NSRange rightRange = NSRangeFromString([right objectForKey:@"range"] ?: NSStringFromRange(NSMakeRange(0, 0)));
        return leftRange.location < rightRange.location ? NSOrderedDescending : NSOrderedAscending;
    }];
    for (NSDictionary *segment in sortedSegments) {
        NSRange range = NSRangeFromString([segment objectForKey:@"range"] ?: NSStringFromRange(NSMakeRange(NSNotFound, 0)));
        NSString *userID = [segment objectForKey:@"uid"];
        if (range.location == NSNotFound || NSMaxRange(range) > encoded.length || userID.length == 0) {
            continue;
        }
        [encoded replaceCharactersInRange:range withString:[NSString stringWithFormat:@"\v%@\v ", userID]];
    }
    return encoded;
}

// 用户确认编辑：校验正文，并在需要时先生成发送端译文。
- (void)chatInputViewEditConfirm {
    if (!self.viewInput.messageModelEdit) {
        return;
    }
    NSString *displayText = self.viewInput.currentInputText;
    NSArray *atUsers = self.viewInput.currentAtUserDictList ?: @[];
    NSArray *atSegments = self.viewInput.currentAtSegmentsList ?: @[];
    if ([NSString isNil:displayText]) {
        [HUD showMessage:LanguageToolMatch(@"发送内容不能为空")];
        return;
    }
    NSString *sendContent = atUsers.count > 0 && atSegments.count > 0 ? [self encodedEditContentFromDisplayText:displayText atSegments:atSegments] : displayText;
    BOOL shouldTranslate = self.sessionModel.isSendAutoTranslate == 1 && [UserManager isTranslateEnabled];
    if (!shouldTranslate) {
        [self sendEditMessageWithDisplayContent:displayText sendContent:sendContent atUserList:atUsers translateContent:@""];
        return;
    }
    [HUD showActivityMessage:@"" inView:self.view];
    WeakSelf
    CIMChatMessageType messageType = atUsers.count > 0 ? CIMChatMessageType_AtMessage : CIMChatMessageType_TextMessage;
    [self requestTranslateActionWithContent:sendContent atUserDictList:atUsers isSend:YES messageType:messageType success:^(NSString * _Nullable result) {
        [HUD hideHUD];
        [weakSelf sendEditMessageWithDisplayContent:displayText sendContent:sendContent atUserList:atUsers translateContent:result ?: @""];
    } failure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD hideHUD];
        [HUD showMessageWithCode:code errorMsg:msg inView:weakSelf.view];
    }];
}

// 用户取消编辑时恢复普通输入框，不修改原消息。
- (void)chatInputViewEditCancel {
    [self exitEditMode];
}

// 构造编辑请求并在成功后原位替换消息，保留发送时间和已读状态。
- (void)sendEditMessageWithDisplayContent:(NSString *)displayContent
                              sendContent:(NSString *)sendContent
                               atUserList:(NSArray *)atUsers
                         translateContent:(NSString *)translateContent {
    NoaMessageModel *editingModel = self.viewInput.messageModelEdit;
    NoaIMChatMessageModel *original = editingModel.message;
    if (!original) {
        return;
    }

    IMChatMessage *request = [[LingIMModelTool sharedTool] getChatMessageModelFromLingIMChatMessageModel:original];
    request.sMsgId = original.serviceMsgID;
    request.isEncry = original.isEncry;
    request.snapchat = original.snapchat;
    request.sendTime = original.sendTime;
    if (atUsers.count > 0) {
        request.mType = IMChatMessage_MessageType_AtMessage;
        AtMessage *atMessage = AtMessage.new;
        atMessage.content = sendContent;
        atMessage.translate = translateContent ?: @"";
        atMessage.ext = original.messageType == CIMChatMessageType_AtMessage ? original.atExt : original.textExt;
        for (NSDictionary *atUser in atUsers) {
            NSString *userID = atUser.allKeys.firstObject;
            NSString *nickname = [atUser objectForKey:userID];
            if (userID.length == 0 || nickname.length == 0) {
                continue;
            }
            AtInfo *information = AtInfo.new;
            information.uId = userID;
            information.uNick = nickname;
            [atMessage.atInfoArray addObject:information];
        }
        request.atMessage = atMessage;
    } else {
        request.mType = IMChatMessage_MessageType_TextMessage;
        TextMessage *textMessage = TextMessage.new;
        textMessage.content = sendContent;
        textMessage.translate = translateContent ?: @"";
        textMessage.ext = original.messageType == CIMChatMessageType_TextMessage ? original.textExt : original.atExt;
        request.textMessage = textMessage;
    }

    [HUD showActivityMessage:@"" inView:self.view];
    WeakSelf
    [IMSDKManager editMessage:request.data onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD hideHUD];
        NoaIMChatMessageModel *updatedMessage = [[LingIMModelTool sharedTool] getChatMessageModelFromIMChatMessage:request];
        updatedMessage.messageSendType = original.messageSendType;
        updatedMessage.messageStatus = original.messageStatus;
        updatedMessage.chatMessageReaded = original.chatMessageReaded;
        updatedMessage.haveReadCount = original.haveReadCount;
        updatedMessage.totalNeedReadCount = original.totalNeedReadCount;
        updatedMessage.localTranslatedShown = original.localTranslatedShown;
        if (updatedMessage.messageType == CIMChatMessageType_AtMessage) {
            updatedMessage.showContent = displayContent;
        }
        [IMSDKManager toolInsertOrUpdateChatMessageWith:updatedMessage];
        NoaMessageModel *updatedModel = [[NoaMessageModel alloc] initWithEditMessageModel:updatedMessage];
        for (NSInteger index = 0; index < weakSelf.messageModels.count; index++) {
            NoaMessageModel *candidate = [weakSelf.messageModels objectAtIndex:index];
            if ([candidate.message.msgID isEqualToString:updatedMessage.msgID]) {
                [weakSelf.messageModels replaceObjectAtIndex:index withObject:updatedModel];
                break;
            }
        }
        [weakSelf.baseTableView reloadData];
        [weakSelf exitEditMode];
        [HUD showMessage:LanguageToolMatch(@"编辑成功") inView:weakSelf.view];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD hideHUD];
        [HUD showMessageWithCode:code errorMsg:msg inView:weakSelf.view];
    }];
}

//翻译接口调用
- (void)requestTranslateActionWithContent:(NSString *)content
                           atUserDictList:(NSArray *)atUserList
                                   isSend:(BOOL)isSend
                              messageType:(CIMChatMessageType)messageType
                                  success:(void(^)(NSString  * _Nullable result))success
                                  failure:(void(^)(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId))failure {
    WeakSelf
    [NoaMessageTools translationSplit:content atUserList:atUserList finish:^(NSString * _Nonnull translationString,
                                                                            NSString * _Nonnull atString,
                                                                            NSString * _Nonnull emojiString) {
        //判断 如果内容只有表情或者at消息将消息重新拼装返回
        if([NSString isNil:translationString]){
            NSMutableString *sendResultStr = [NSMutableString string];
            [sendResultStr appendString:![NSString isNil:atString] ? atString : @""];
            [sendResultStr appendString:![NSString isNil:emojiString] ? emojiString : @""];
            [sendResultStr trimString];
            if (success) {
                success(sendResultStr);
            }
        } else {
            //如果有翻译内容 调用接口 翻译成功后 重新拼装好返回
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            if (isSend) {
                [dict setObjectSafe:weakSelf.sessionModel.sendTranslateChannel forKey:@"channelCode"];
                [dict setObjectSafe:weakSelf.sessionModel.sendTranslateLanguage forKey:@"to"];
                [dict setObjectSafe:ZSensitiveFilter(translationString) forKey:@"content"];
                [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
            } else {
                [dict setObjectSafe:weakSelf.sessionModel.receiveTranslateChannel forKey:@"channelCode"];
                [dict setObjectSafe:weakSelf.sessionModel.receiveTranslateLanguage forKey:@"to"];
                [dict setObjectSafe:ZSensitiveFilter(translationString) forKey:@"content"];
                [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
            }
            
            [IMSDKManager imSdkTranslateYuueeContent:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                NSMutableString *result = [NSMutableString stringWithString:(NSString *)data];
                NSMutableString *sendResultStr = [NSMutableString string];
                [sendResultStr appendString:![NSString isNil:result] ? result : @""];
                [sendResultStr appendString:![NSString isNil:atString] ? atString : @""];
                [sendResultStr appendString:![NSString isNil:emojiString] ? emojiString : @""];
               if (success) {
                   success(sendResultStr);
               }
            } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                if (code == Translate_yuuee_no_balance_code) {
                    //提示
                    [HUD showMessage:LanguageToolMatch(@"当前账户字符数不足，已关闭翻译功能，请增加字符后使用。") inView:weakSelf.view];
                }
                if (code == Translate_yuuee_unbind_error_code) {
                    [HUD showMessage:LanguageToolMatch(@"您尚未绑定字符账号，无法使用翻译功能，请绑定后使用。") inView:weakSelf.view];
                }
                if (failure) {
                    failure(code,msg,traceId);
                }
            }];
        }
    }];
}


#pragma mark - 语音消息发送(录制完成的音频文件路径、音频名称、音频时长)
- (void)chatInputViewVoicePath:(NSString *)vociePath voiceName:(NSString *)voiceName voiceDuration:(CGFloat)voiceDuration {
    WeakSelf
    [NoaMessageSendHander ZMessageVoiceSend:vociePath fileName:voiceName voiceDuring:voiceDuration withToUserId:self.sessionID withChatType:self.chatType compelete:^(NoaIMChatMessageModel * _Nonnull sendChatMsg) {
        //判断是否大于群发消息间隔
        if (![weakSelf isExceedSendMsgTimeInterval:sendChatMsg.sendTime]) {
            return;
        }
        //上传的语音文件
        NSData *audioData = [NSData dataWithContentsOfFile:sendChatMsg.localVoicePath options:NSDataReadingMappedIfSafe error:nil];
        NoaFileUploadTask *audioTask = [[NoaFileUploadTask alloc] initWithTaskId:sendChatMsg.msgID filePath:sendChatMsg.localVoicePath originFilePath:@"" fileName:sendChatMsg.localVoiceName fileType:@"" isEncrypt:NO dataLength:audioData.length uploadType:ZHttpUploadTypeVoice beSendMessage:sendChatMsg delegate:self];
        audioTask.messageTaskType = FileUploadMessageTaskTypeVoice;
        
        NSBlockOperation * blockOperation = [NSBlockOperation blockOperationWithBlock:^{
            NSLog(@"语音文件上传任务完成");
            if (audioTask.status == FileUploadTaskStatus_Completed) {
                sendChatMsg.voiceName = audioTask.originUrl;
                [IMSDKManager toolSendChatMessageWith:sendChatMsg];
            }
            if (audioTask.status == FileUploadTaskStatus_Failed) {
                [ZTOOL doInMain:^{
                    [HUD showMessage:LanguageToolMatch(@"上传失败") inView:weakSelf.view];
                }];
            }
        }];
        NoaFileUploadGetSTSTask *getSTSTask = [[NoaFileUploadGetSTSTask alloc] init];
        [audioTask addDependency:getSTSTask];
        [[NoaFileUploadManager sharedInstance].operationQueue addOperation:getSTSTask];
        
        [blockOperation addDependency:audioTask];
        [[NoaFileUploadManager sharedInstance] addUploadTask:audioTask];
        [[NoaFileUploadManager sharedInstance].operationQueue addOperation:blockOperation];
        
        //将配置好的消息 1.存储到数据库 2.添加到UI上展示(此时展示的图片或视频还没上传完成，正在上传中...)
        [IMSDKManager toolInsertOrUpdateChatMessageWith:sendChatMsg];
        [weakSelf chatListAppendMessage:sendChatMsg];
        
        if (audioData.length < 1024) {
            //录音文件保存本地沙盒失败
            NSMutableDictionary *loganDict = [NSMutableDictionary dictionary];
            [loganDict setObject:@"转换成mp3格式的录音文件小于1KB" forKey:@"recordVocieFail"];//失败原因
            [IMSDKManager imSdkWriteLoganWith:LingIMLoganTypeApi loganContent:[[NoaIMLoganManager sharedManager] configLoganContent:loganDict]];

        }
    }];
}

#pragma mark - 音频通话
- (void)chatInputViewAudioCall {
    //关闭群音视频功能
    if ([ZHostTool.appSysSetModel.enableAudioAndVideoCalls isEqualToString:@"0"]) {
        [HUD showMessage:LanguageToolMatch(@"该群已关闭音视频功能") inView:self.view];
        return;
    } else {
        if (self.chatType == CIMChatType_GroupChat) {
            if (self.groupInfo.isNetCall && self.groupInfo.userGroupRole == 0) {
                [HUD showMessage:LanguageToolMatch(@"该群已关闭音视频功能") inView:self.view];
                return;
            }
        }
    }
    
    WeakSelf
    [ZTOOL getMicrophoneAuth:^(BOOL granted) {
        if (weakSelf.chatType == CIMChatType_SingleChat) {
            //单聊
            LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:self.sessionID];
            if (friendModel && friendModel.disableStatus == 4) {
                [HUD showMessage:LanguageToolMatch(@"账号已注销") inView:weakSelf.view];
                return;
            }
            if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"0"]) {
                //LiveKit
                [weakSelf lkCallRequestForSingleWith:LingIMCallTypeAudio];
            } else if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"1"]) {
                //即构
                [weakSelf zgCallRequestForSingleWith:LingIMCallTypeAudio];
            }
        } else {
            //群聊
            if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"0"]) {
                //LiveKit
                [weakSelf lkCallRequestForGroupWith:LingIMCallTypeAudio];
            } else if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"1"]) {
                //即构
                [weakSelf zgCallRequestForGroupWith:LingIMCallTypeAudio];
            }
        }
    }];
}

#pragma mark - 视频通话
- (void)chatInputViewVideoCall {
    //关闭群音视频功能
    if ([ZHostTool.appSysSetModel.enableAudioAndVideoCalls isEqualToString:@"0"]) {
        [HUD showMessage:LanguageToolMatch(@"该群已关闭音视频功能") inView:self.view];
        return;
    } else {
        if (self.chatType == CIMChatType_GroupChat) {
            if (self.groupInfo.isNetCall && self.groupInfo.userGroupRole == 0) {
                [HUD showMessage:LanguageToolMatch(@"该群已关闭音视频功能") inView:self.view];
                return;
            }
        }
    }
    
    WeakSelf
    [ZTOOL getMicrophoneAuth:^(BOOL granted) {
        [ZTOOL getCameraAuth:^(BOOL granted) {
            if (weakSelf.chatType == CIMChatType_SingleChat) {
                //单聊
                LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:self.sessionID];
                if (friendModel && friendModel.disableStatus == 4) {
                    [HUD showMessage:LanguageToolMatch(@"账号已注销") inView:weakSelf.view];
                    return;
                }
                
                if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"0"]) {
                    //LiveKit
                    [weakSelf lkCallRequestForSingleWith:LingIMCallTypeVideo];
                }else if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"1"]) {
                    //即构
                    [weakSelf zgCallRequestForSingleWith:LingIMCallTypeVideo];
                }
            }else {
                //群聊
                if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"0"]) {
                    //LiveKit
                    [weakSelf lkCallRequestForGroupWith:LingIMCallTypeVideo];
                }else if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"1"]) {
                    //即构
                    [weakSelf zgCallRequestForGroupWith:LingIMCallTypeVideo];
                }
            }
            
        }];
    }];
}

#pragma mark - 选择图片/视频
- (void)chatInputViewShowImage {
    //先检测权限，再进入相册，解决某些系统第一次不能获取照片，杀死进程后可以获取照片的问题
    WeakSelf
    [ZTOOL getPhotoLibraryAuth:^(BOOL granted) {
        if (granted) {
            [ZTOOL doInMain:^{
                NoaImagePickerVC *vc = [NoaImagePickerVC new];
                vc.maxSelectNum = 9;
                vc.isNeedEdit = NO;
                vc.hasCamera = YES;
                vc.delegate = self;
                [vc setPickerType:ZImagePickerTypeAll];
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }];
        } else {
            [HUD showWarningMessage:LanguageToolMatch(@"相册权限未开启，请在设置中选择当前应用，开启相册权限") inView:self.view];
        }
    }];
}
#pragma mark - ZImagePickerVCDelegate
- (void)imagePickerVCSelected {
    if (IMAGEPICKER.zSelectedAssets.count > 0) {
        //判断是否大于群发消息间隔
        //可能选择多个文件，需要统一处理
        if(![self isExceedSendMsgTimeInterval:[NSDate currentTimeIntervalWithMillisecond]]){
            return;
        }
        /// 发送图片、视频消息
        [HUD showActivityMessage:LanguageToolMatch(@"处理中...") inView:self.view];
        //目录路径
        NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, self.sessionID];
        WeakSelf
        [NoaMessageSendHander ZMessageMediaSend:IMAGEPICKER.zSelectedAssets withToUserId:self.sessionID withChatType:self.chatType compelete:^(NSArray <NoaIMChatMessageModel *> * sendChatMsgArr) {
            
            __block NSMutableArray * taskArray = [NSMutableArray array];
            [sendChatMsgArr enumerateObjectsUsingBlock:^(NoaIMChatMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                //生成上传任务，开始上传
                if (obj.messageType == CIMChatMessageType_ImageMessage) {
                    //沙盒路径
                    NSString *localThumbImgPath = [NSString getPathWithImageName:obj.localthumbImgName CustomPath:customPath];
                    NSString *localImgPath = [NSString getPathWithImageName:obj.localImgName CustomPath:customPath];

                    //缩略图
                    NSData *thumbImgData = [NSData dataWithContentsOfFile:localThumbImgPath];
                    NoaFileUploadTask *thumbImgTask = [[NoaFileUploadTask alloc] initWithTaskId:[NSString stringWithFormat:@"%@_thumb", obj.msgID] filePath:localThumbImgPath originFilePath:localImgPath fileName:obj.localthumbImgName fileType:@"" isEncrypt:YES dataLength:thumbImgData.length uploadType:ZHttpUploadTypeImageThumbnail beSendMessage:obj delegate:self];
                    thumbImgTask.messageTaskType = FileUploadMessageTaskTypeThumbImage;
                    [taskArray addObject:thumbImgTask];
                    
                    //图片
                    NoaFileUploadTask *imgTask = [[NoaFileUploadTask alloc] initWithTaskId:obj.msgID filePath:localImgPath originFilePath:@"" fileName:obj.localImgName fileType:@"" isEncrypt:YES dataLength:obj.imgSize uploadType:ZHttpUploadTypeImage beSendMessage:obj delegate:self];
                    imgTask.messageTaskType = FileUploadMessageTaskTypeImage;
                    [taskArray addObject:imgTask];
                }
                if (obj.messageType == CIMChatMessageType_VideoMessage) {
                    //视频-封面图
                    NSString *localCoverPath = [NSString getPathWithImageName:obj.localVideoCover CustomPath:customPath];
                    NoaFileUploadTask *coverTask = [[NoaFileUploadTask alloc] initWithTaskId:[NSString stringWithFormat:@"%@_cover", obj.msgID] filePath:localCoverPath originFilePath:@"" fileName:obj.localVideoCover fileType:@"" isEncrypt:YES dataLength:obj.videoCoverSize uploadType:ZHttpUploadTypeImage beSendMessage:obj delegate:self];
                    coverTask.messageTaskType = FileUploadMessageTaskTypeCover;
                    [taskArray addObject:coverTask];
                    
                    //视频-视频
                    NSString *localVideoPath = [NSString getPathWithVideoName:obj.localVideoName CustomPath:customPath];
                    NoaFileUploadTask *videoTask = [[NoaFileUploadTask alloc] initWithTaskId:obj.msgID filePath:localVideoPath originFilePath:@"" fileName:obj.localVideoName fileType:@"" isEncrypt:YES dataLength:obj.videoSize uploadType:ZHttpUploadTypeVideo beSendMessage:obj delegate:self];
                    videoTask.messageTaskType = FileUploadMessageTaskTypeVideo;
                    [taskArray addObject:videoTask];
                }
                if (obj.messageType == CIMChatMessageType_FileMessage) {
                    //文件(大图以文件方式发送，超过200M的视频以文件方式发送)
                    NSString *localFilePath = [NSString getPathWithFileName:obj.fileName CustomPath:customPath];
                    NoaFileUploadTask *fileTask = [[NoaFileUploadTask alloc] initWithTaskId:obj.msgID filePath:localFilePath originFilePath:@"" fileName:obj.fileName fileType:obj.fileType isEncrypt:YES dataLength:obj.fileSize uploadType:ZHttpUploadTypeFile beSendMessage:obj delegate:self];
                    fileTask.messageTaskType = FileUploadMessageTaskTypeFile;
                    [taskArray addObject:fileTask];
                }
            }];
            NoaFileUploadGetSTSTask *getSTSTask = [[NoaFileUploadGetSTSTask alloc] init];
            getSTSTask.uploadTask = taskArray;
            [[NoaFileUploadManager sharedInstance].operationQueue addOperation:getSTSTask];
            
            NoaMessageSendTask *messageSendTask = [[NoaMessageSendTask alloc] init];
            messageSendTask.uploadTask = taskArray;
            [taskArray enumerateObjectsUsingBlock:^(NoaFileUploadTask *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [[NoaFileUploadManager sharedInstance] addUploadTask:obj];
            }];

            [[NoaFileUploadManager sharedInstance].operationQueue addOperation:messageSendTask];
            
            [ZTOOL doInMain:^{
                [HUD hideHUD];
            }];
            
            NSMutableArray <NoaIMChatMessageModel *> *messageList = [NSMutableArray new];
            [sendChatMsgArr enumerateObjectsUsingBlock:^(NoaIMChatMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                //将配置好的消息添加到UI上展示(此时展示的图片或视频还没上传完成，正在上传中...)
                [messageList addObject:obj];
                [weakSelf chatListAppendMessage:obj];
            }];
            
            //将配置好的消息存储到数据库
            [IMSDKManager toolInsertOrUpdateChatMessagesWith:messageList];
        }];
        [IMAGEPICKER.zSelectedAssets removeAllObjects];
    }
}

#pragma mark - 选择文件
- (void)chatInputViewShowFile {
    //先检测权限，再进入，解决某些系统第一次不能获取相册，杀死进程后可以获取相册的问题
    WeakSelf
    [ZTOOL getPhotoLibraryAuth:^(BOOL granted) {
        if (granted) {
            [ZTOOL doInMain:^{
                NSString *fileFolderPath = [NSString getFileDiectoryWithCustomPath:[NSString stringWithFormat:@"%@-%@",UserManager.userInfo.userUID, weakSelf.sessionID]];
                NoaFilePickerVC *vc = [NoaFilePickerVC new];
                vc.sessionFoldPath = fileFolderPath;
                [weakSelf.navigationController pushViewController:vc animated:YES];
                //直接选择 手机储存的文件
                vc.savePhoneFileSuccess = ^(NoaFilePickModel *selectFileModel) {
                    //判断是否大于群发消息间隔
                    if(![self isExceedSendMsgTimeInterval:[NSDate currentTimeIntervalWithMillisecond]]){
                        return;
                    }
                    //手机储存中的文件
                    [weakSelf recombineFileSendData:selectFileModel sendFileDataList:nil];
                };
                //选择的 App中的文件或者相册视频 数组里可以是 PHAsset或者本地文件沙盒路径
                vc.saveLingXinFileSuccess = ^(NSArray * _Nonnull sendSelectFileArr) {
                    //判断是否大于群发消息间隔
                    //多个文件同时发送，需要统一处理
                    if(![self isExceedSendMsgTimeInterval:[NSDate currentTimeIntervalWithMillisecond]]){
                        return;
                    }
                    [weakSelf recombineFileSendData:nil sendFileDataList:sendSelectFileArr];
                };
            }];
        } else {
            [HUD showWarningMessage:LanguageToolMatch(@"相册权限未开启，请在设置中选择当前应用，开启相册权限") inView:weakSelf.view];
        }
    }];
}

//发送文件类型消息时上传文件并组合消息体
- (void)recombineFileSendData:(NoaFilePickModel *)sendFileModel sendFileDataList:(NSArray <NoaFilePickModel *> *)sendFileDataList {
    [HUD showActivityMessage:LanguageToolMatch(@"处理中...") inView:self.view];
    WeakSelf
    if (sendFileDataList == nil) {
        //手机中存储的文件(每次只发1个文件)
        [NoaMessageSendHander ZMessageFileSendData:sendFileModel withToUserId:self.sessionID withChatType:self.chatType compelete:^(NoaIMChatMessageModel * _Nonnull sendChatMsg) {
            //目录
            NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, self.sessionID];
            NSString *localFilePath = [NSString getPathWithFileName:sendChatMsg.fileName CustomPath:customPath];
            //上传文件
            NoaFileUploadTask *fileTask = [[NoaFileUploadTask alloc] initWithTaskId:sendChatMsg.msgID filePath:localFilePath originFilePath:@"" fileName:sendChatMsg.fileName fileType:sendChatMsg.fileType isEncrypt:YES dataLength:sendChatMsg.fileSize uploadType:ZHttpUploadTypeFile beSendMessage:sendChatMsg delegate:self];
            fileTask.messageTaskType = FileUploadMessageTaskTypeFile;
            
            NSBlockOperation * blockOperation = [NSBlockOperation blockOperationWithBlock:^{
                NSLog(@"文件上传任务完成");
                if (fileTask.status == FileUploadTaskStatus_Completed) {
                    sendChatMsg.filePath = fileTask.originUrl;
                    [IMSDKManager toolSendChatMessageWith:sendChatMsg];
                }
                if (fileTask.status == FileUploadTaskStatus_Failed) {
                    [ZTOOL doInMain:^{
                        [HUD showMessage:LanguageToolMatch(@"上传失败") inView:weakSelf.view];
                    }];
                }
            }];
            NoaFileUploadGetSTSTask *getSTSTask = [[NoaFileUploadGetSTSTask alloc] init];
            [fileTask addDependency:getSTSTask];
            [[NoaFileUploadManager sharedInstance].operationQueue addOperation:getSTSTask];
            
            [blockOperation addDependency:fileTask];
            [[NoaFileUploadManager sharedInstance] addUploadTask:fileTask];
            [[NoaFileUploadManager sharedInstance].operationQueue addOperation:blockOperation];
            
            [ZTOOL doInMain:^{
                [HUD hideHUD];
            }];
            //将配置好的消息 1.存储到数据库 2.添加到UI上展示
            [IMSDKManager toolInsertOrUpdateChatMessageWith:sendChatMsg];
            [weakSelf chatListAppendMessage:sendChatMsg];
        }];
    } else {
        //相册/App中的文件(每次可能是多个文件)
        __block NSMutableArray *taskArray = [NSMutableArray array];
        __block NSMutableArray *sengMessageArr = [NSMutableArray array];
        dispatch_group_t myGroup = dispatch_group_create();
        [sendFileDataList enumerateObjectsUsingBlock:^(NoaFilePickModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            dispatch_group_enter(myGroup);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [NoaMessageSendHander ZMessageFileSendData:obj withToUserId:weakSelf.sessionID withChatType:weakSelf.chatType compelete:^(NoaIMChatMessageModel * _Nonnull sendChatMsg) {
                    //目录
                    NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, weakSelf.sessionID];
                    NSString *localFilePath = [NSString getPathWithFileName:sendChatMsg.fileName CustomPath:customPath];
                    //上传文件
                    NoaFileUploadTask *fileTask = [[NoaFileUploadTask alloc] initWithTaskId:sendChatMsg.msgID filePath:localFilePath originFilePath:@"" fileName:sendChatMsg.fileName fileType:sendChatMsg.fileType isEncrypt:YES dataLength:sendChatMsg.fileSize uploadType:ZHttpUploadTypeFile beSendMessage:sendChatMsg delegate:weakSelf];
                    fileTask.messageTaskType = FileUploadMessageTaskTypeFile;
                    [taskArray addObject:fileTask];
                    [sengMessageArr addObject:sendChatMsg];
                    dispatch_group_leave(myGroup);
                }];
            });
        }];
        
        dispatch_group_notify(myGroup, dispatch_get_main_queue(), ^{
            NoaFileUploadGetSTSTask *getSTSTask = [[NoaFileUploadGetSTSTask alloc] init];
            getSTSTask.uploadTask = taskArray;
            [[NoaFileUploadManager sharedInstance].operationQueue addOperation:getSTSTask];
            
            NoaMessageSendTask *messageSendTask = [[NoaMessageSendTask alloc] init];
            messageSendTask.uploadTask = taskArray;
            [taskArray enumerateObjectsUsingBlock:^(NoaFileUploadTask *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [[NoaFileUploadManager sharedInstance] addUploadTask:obj];
            }];

            [[NoaFileUploadManager sharedInstance].operationQueue addOperation:messageSendTask];
            
            [ZTOOL doInMain:^{
                [HUD hideHUD];
            }];
            
            NSMutableArray <NoaIMChatMessageModel *> *messageList = [NSMutableArray new];
            [sengMessageArr enumerateObjectsUsingBlock:^(NoaIMChatMessageModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                //将配置好的消息 1.存储到数据库 2.添加到UI上展示
                [messageList addObject:obj];
                [weakSelf chatListAppendMessage:obj];
            }];
            
            //将配置好的消息存储到数据库
            [IMSDKManager toolInsertOrUpdateChatMessagesWith:messageList];
        });
    }
}

#pragma mark - @用户
- (void)chatInputViewAtUser {
    if (_chatType == CIMChatType_GroupChat) {//群聊
        //防止获取群信息接口失败，可以进行用户头像点击跳转
        if (!_groupInfo) {
            // 群信息未获取到，尝试调起@列表
            [self showAtUserListView];

            return;
        }
    
        //群开启了群内禁止私聊，普通群成员不可以点击用户头像跳转
        if (_groupInfo.isPrivateChat && _groupInfo.userGroupRole == 0) {
            // 没有权限@别人，不调起@列表（允许输入@，但不调起列表）
            // 注意：shouldChangeTextInRange 中已经返回 YES，允许输入@符号，但不调起@列表

            return;
        }
        [self showAtUserListView];
    } else { //单聊
        [self showAtUserListView];
    }
}

//输入 @ 时显示需要好友或者群成员列表
- (void)showAtUserListView {
    NoaMsgAtListViewController *atUserVC = [[NoaMsgAtListViewController alloc] init];
    atUserVC.chatType = self.chatType;
    atUserVC.sessionId = self.sessionID;
    atUserVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self addChildViewController:atUserVC];
    [self.view addSubview:atUserVC.view];
    WeakSelf
    atUserVC.AtUserSelectClick = ^(id atModel) {
        //用户选择了艾特的成员
        if (atModel) {
            NSDictionary *atUser;
            if (weakSelf.chatType == CIMChatType_SingleChat) {
                NoaUserModel *clickModel = (NoaUserModel *)atModel;
                atUser = @{
                    clickModel.userUID : clickModel.nickname
                };
            }
            if (weakSelf.chatType == CIMChatType_GroupChat) {
                LingIMGroupMemberModel *clickModel = (LingIMGroupMemberModel *)atModel;
                NSString *displayName = ![NSString isNil:clickModel.showName] ? clickModel.showName : clickModel.userNickname;
                atUser = @{
                    clickModel.userUid : displayName
                };
            }
            [weakSelf.viewInput inputViewInsertAtUserInfo:atUser];
        } else {
            //用户没选择了艾特的成员，相当于输入艾特
            [weakSelf.viewInput inputViewInsertAtUserInfo:nil];
        }
    };
}

//发送位置信息类型的消息
- (void)sendGeoLocationMessageWithLat:(NSString *)lat lng:(NSString *)lng name:(NSString *)name cImg:(UIImage *)cImg detail:(NSString *)detail {
    WeakSelf
    [NoaMessageSendHander ZMessageLocationSendWithLng:lng lat:lat name:name cImg:cImg detail:detail withToUserId:self.sessionID withChatType:self.chatType compelete:^(NoaIMChatMessageModel * _Nonnull sendChatMsg) {
        //判断是否大于群发消息间隔
        if(![self isExceedSendMsgTimeInterval:sendChatMsg.sendTime]){
            return;
        }
        //地理位置地图截图
        NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, weakSelf.sessionID];
        NSString *geoImgPath = [NSString getPathWithImageName:sendChatMsg.localGeoImgName CustomPath:customPath];
        NSData *geoImgData = [NSData dataWithContentsOfFile:geoImgPath options:NSDataReadingMappedIfSafe error:nil];
        NoaFileUploadTask *geoImgTask = [[NoaFileUploadTask alloc] initWithTaskId:sendChatMsg.msgID filePath:geoImgPath originFilePath:@"" fileName:sendChatMsg.localGeoImgName fileType:@"" isEncrypt:YES dataLength:geoImgData.length uploadType:ZHttpUploadTypeImage beSendMessage:sendChatMsg delegate:self];
        geoImgTask.messageTaskType = FileUploadMessageTaskTypeImage;
        
        NSBlockOperation * blockOperation = [NSBlockOperation blockOperationWithBlock:^{
            NSLog(@"地理位置图片上传任务完成");
            if (geoImgTask.status == FileUploadTaskStatus_Completed) {
                sendChatMsg.geoImg = geoImgTask.originUrl;
                [IMSDKManager toolSendChatMessageWith:sendChatMsg];
            }
            if (geoImgTask.status == FileUploadTaskStatus_Failed) {
                [ZTOOL doInMain:^{
                    [HUD showMessage:LanguageToolMatch(@"上传失败") inView:weakSelf.view];
                }];
            }
        }];
        
        NoaFileUploadGetSTSTask *getSTSTask = [[NoaFileUploadGetSTSTask alloc] init];
        [geoImgTask addDependency:getSTSTask];
        [[NoaFileUploadManager sharedInstance].operationQueue addOperation:getSTSTask];

        [blockOperation addDependency:geoImgTask];
        [[NoaFileUploadManager sharedInstance] addUploadTask:geoImgTask];
        [[NoaFileUploadManager sharedInstance].operationQueue addOperation:blockOperation];
    
        //将消息添加到UI上
        [IMSDKManager toolInsertOrUpdateChatMessageWith:sendChatMsg];
        [weakSelf chatListAppendMessage:sendChatMsg];
    }];
}

#pragma mark - 展示收藏列表
- (void)chatInputViewCollection {
    CoHereMyCollectionViewController *myCollectionVC = [[CoHereMyCollectionViewController alloc] init];
    myCollectionVC.isFromChat = YES;
    myCollectionVC.chatType = self.chatType;
    myCollectionVC.chatSession = self.sessionID;
    [self.navigationController pushViewController:myCollectionVC animated:YES];
    WeakSelf
    [myCollectionVC setSendCollectionMsgBlock:^(NoaMyCollectionItemModel * _Nonnull collectionMessage) {
        if (collectionMessage) {
            //判断是否大于群发消息间隔
            if(![weakSelf isExceedSendMsgTimeInterval:[NSDate currentTimeIntervalWithMillisecond]]){
                return;
            }
            [weakSelf sendCollectionUserForwardAction:collectionMessage];
        }
    }];
}

- (void)sendCollectionUserForwardAction:(NoaMyCollectionItemModel *)collectionMsg {
    self.collectionSendHander.fromSessionId = self.sessionID;
    [self.collectionSendHander chatCollectionMessagSendWith:collectionMsg chatType:self.chatType sessionId:self.sessionID];
    WeakSelf
    [self.collectionSendHander setCollectionSendCompleteBlock:^(BOOL isSuccess, NoaIMChatMessageModel * _Nullable sendCollectionMsg) {
        if (isSuccess) {
            [HUD showMessage:LanguageToolMatch(@"已发送") inView:weakSelf.view];
        } else {
            [HUD showMessage:LanguageToolMatch(@"操作失败") inView:weakSelf.view];
        }
        sendCollectionMsg.localImg = nil;
        sendCollectionMsg.localImgName = nil;
        sendCollectionMsg.localVideoName = nil;
        sendCollectionMsg.localVoiceName = nil;
        sendCollectionMsg.localVideoCover = nil;
        sendCollectionMsg.localGeoImgName = nil;
        //转发消息是转发给当前聊天对象
        if ([weakSelf.sessionID isEqualToString:sendCollectionMsg.toID]) {
            //刷新并滚动到底部
            [ZTOOL doInMain:^{
                NoaMessageModel *sendMsg = [[NoaMessageModel alloc] initWithMessageModel:sendCollectionMsg];
                [weakSelf.messageModels addObject:sendMsg];
                //处理消息是否显示时间
                [weakSelf computeVisibleTime];
                [weakSelf.baseTableView reloadData];
                //加载滚动到底部
                [weakSelf tableViewScrollToBottom:NO duration:0.25];
            }];
        }
    }];
}

#pragma mark - 展示翻译选择通道和语种View
- (void)chatInputViewTranslate {
    NoaTranslateSettingVC *translateSetVC = [[NoaTranslateSettingVC alloc] init];
    translateSetVC.sessionModel = _sessionModel;
    [self.navigationController pushViewController:translateSetVC animated:YES];
}

#pragma mark - 展示输入框表情手势-表情商店
- (void)chatInputViewSearchMoreEmojiAction {
    NoaEmojiShopViewController *vc = [[NoaEmojiShopViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 发送 收藏的表情、表情包表情、搜索到的表情
- (void)chatInputViewStickersSend:(NoaIMStickersModel *)sendStickersModel {
    NoaIMChatMessageModel *stickersMessageModel = [NoaMessageSendHander ZMessageStickersSendContentUrl:sendStickersModel.contentUrl stickerThumbImgUrl:sendStickersModel.thumbUrl stickerId:sendStickersModel.stickersId stickerName:sendStickersModel.name stickerHeight:sendStickersModel.height stickerWidth:sendStickersModel.width stickerSize:sendStickersModel.size isStickersSet:sendStickersModel.isStickersSet stickerExt:@"" withToUserId:self.sessionID withChatType:self.chatType];
    //判断是否大于群发消息间隔
    if(![self isExceedSendMsgTimeInterval:stickersMessageModel.sendTime]){
        return;
    }
    //发送的表情消息
    [self chatListAppendMessage:stickersMessageModel];
    [IMSDKManager toolInsertOrUpdateChatMessageWith:stickersMessageModel];
    [IMSDKManager toolSendChatMessageWith:stickersMessageModel];
}

#pragma mark - 打开相册-向收藏表情里添加表情
- (void)chatInputViewOpenAlumAddCollectGifImg {
    //先检测权限，再进入相册，解决某些系统第一次不能获取照片，杀死进程后可以获取照片的问题
    WeakSelf
    [ZTOOL getPhotoLibraryAuth:^(BOOL granted) {
        if (granted) {
            [ZTOOL doInMain:^{
                NoaImagePickerVC *vc = [NoaImagePickerVC new];
                vc.isSignlePhoto = YES;
                vc.isNeedEdit = NO;
                vc.hasCamera = YES;
                vc.delegate = self;
                [vc setPickerType:ZImagePickerTypeImage];
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }];
        }else {
            [HUD showWarningMessage:LanguageToolMatch(@"相册权限未开启，请在设置中选择当前应用，开启相册权限") inView:weakSelf.view];
        }
    }];
}

#pragma mark - 发送收藏表情里游戏表情：石头剪刀布、摇骰子
- (void)chatInputViewPlayGameStickerAction:(ZChatGameStickerType)gameType {
    //判断是否大于群发消息间隔
    if(![self isExceedSendMsgTimeInterval:[NSDate currentTimeIntervalWithMillisecond]]){
        return;
    }
    NSString *resultContent;
    ZChatGameStickerType gameStickersType = ZChatGameStickerTypeFingerGuessing;
    if (gameType == ZChatGameStickerTypeFingerGuessing) {
        //石头剪刀布
        resultContent = [NSString randomNumWithMin:1 max:3];
        gameStickersType = ZChatGameStickerTypeFingerGuessing;
    }
    if (gameType == ZChatGameStickerTypePlayDice) {
        //摇骰子
        resultContent = [NSString randomNumWithMin:1 max:6];
        gameStickersType = ZChatGameStickerTypePlayDice;
    }
    
    //生成消息体
    NoaIMChatMessageModel *gameStickersMessageModel = [NoaMessageSendHander ZMessageGameStickersSendResultContent:resultContent gameStickersType:gameStickersType gameStickerExt:@"" withToUserId:self.sessionID withChatType:self.chatType];
    //发送游戏表情消息
    [IMSDKManager toolSendChatMessageWith:gameStickersMessageModel];
    //添加到UI上
    [self chatListAppendMessage:gameStickersMessageModel];
}
#pragma mark - ZImagePickerVCDelegate
- (void)imagePickerClipImage:(UIImage *)resultImg localIdenti:(NSString *)localIdenti {
    //添加图片到收藏表情
    NSData *stickerData = UIImageJPEGRepresentation(resultImg, 0.5);
    //添加表情需要的参数
    long long stickersSize = CGImageGetHeight(resultImg.CGImage) * CGImageGetBytesPerRow(resultImg.CGImage);
    float stickersWidth = resultImg.size.width;
    float stickersHeight = resultImg.size.height;
    NSString *stickersKey = [[NSString stringWithFormat:@"%@%lld", localIdenti, stickersSize] MD5Encryption];
    //fileName 文件名为：userid+当前时间戳
    NSString *fileName = [[NSString alloc] initWithFormat:@"%@_%lld.%@", UserManager.userInfo.userUID, [NSDate currentTimeIntervalWithMillisecond], [NSString getImageFileFormat:stickerData]];
    //保存到本地沙盒及本地沙盒完整路径
    NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, self.sessionID];
    [NSString saveImageToSaxboxWithData:stickerData CustomPath:customPath ImgName:fileName];
    NSString *stickerPath = [NSString getPathWithImageName:fileName CustomPath:customPath];
 
    NSMutableArray * taskArray = [NSMutableArray array];
    
    //上传缩略图
    NSData *thumbnailImgData = [UIImage compressImageSize:[UIImage imageWithData:stickerData] toByte:50*1024];
    NSString *thumbnailFileName = [NSString stringWithFormat:@"thumbnail_%@",fileName];
    [NSString saveImageToSaxboxWithData:thumbnailImgData CustomPath:customPath ImgName:thumbnailFileName];
    NSString *stickerThumbPath = [NSString getPathWithImageName:thumbnailFileName CustomPath:customPath];
    NoaFileUploadTask *stickerThumbTask = [[NoaFileUploadTask alloc] initWithTaskId:thumbnailFileName filePath:stickerThumbPath originFilePath:@"" fileName:thumbnailFileName fileType:@"" isEncrypt:YES dataLength:thumbnailImgData.length uploadType:ZHttpUploadTypeStickers beSendMessage:nil delegate:self];
    stickerThumbTask.messageTaskType = FileUploadMessageTaskTypeStickerThumb;
    [taskArray addObject:stickerThumbTask];
    //上传原图
    NoaFileUploadTask *stickerTask = [[NoaFileUploadTask alloc] initWithTaskId:fileName filePath:stickerPath originFilePath:@"" fileName:fileName fileType:@"" isEncrypt:YES dataLength:stickerData.length uploadType:ZHttpUploadTypeStickers beSendMessage:nil delegate:self];
    stickerTask.messageTaskType = FileUploadMessageTaskTypeSticker;
    [taskArray addObject:stickerTask];
    
    //组装接口数据
    NSMutableDictionary *stickersDic = [NSMutableDictionary dictionary];
    [stickersDic setObjectSafe:@(stickersHeight) forKey:@"height"];
    [stickersDic setObjectSafe:@(stickersSize) forKey:@"size"];
    [stickersDic setObjectSafe:stickersKey forKey:@"stickersKey"];
    [stickersDic setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    [stickersDic setObjectSafe:@(stickersWidth) forKey:@"width"];
    
    WeakSelf
    __block NSInteger taskNum = 0;
    NSBlockOperation * blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        //上传表情图片完成
        [taskArray enumerateObjectsUsingBlock:^(NoaFileUploadTask *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.status == FileUploadTaskStatus_Completed) {
                if (obj.messageTaskType == FileUploadMessageTaskTypeStickerThumb) {
                    [stickersDic setObjectSafe:obj.originUrl forKey:@"thumbUrl"];//缩略图地址
                    taskNum++;
                }
                if (obj.messageTaskType == FileUploadMessageTaskTypeSticker) {
                    [stickersDic setObjectSafe:obj.originUrl forKey:@"contentUrl"];//原图地址
                    taskNum++;
                }
                if (taskNum == 2) {
                    //调用接口
                    [weakSelf requestAddStickersToCollectionWithDic:stickersDic isReloadCollection:NO];
                }
            } else {
                [ZTOOL doInMain:^{
                    [HUD showMessage:LanguageToolMatch(@"上传失败") inView:weakSelf.view];
                }];
            }
        }];
    }];
    NoaFileUploadGetSTSTask *getSTSTask = [[NoaFileUploadGetSTSTask alloc] init];
    getSTSTask.uploadTask = taskArray;
    [[NoaFileUploadManager sharedInstance].operationQueue addOperation:getSTSTask];

    [taskArray enumerateObjectsUsingBlock:^(NoaFileUploadTask *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[NoaFileUploadManager sharedInstance] addUploadTask:obj];
        [blockOperation addDependency:obj];
    }];
    
    [[NoaFileUploadManager sharedInstance].operationQueue addOperation:blockOperation];
    [IMAGEPICKER.zSelectedAssets removeAllObjects];
}

#pragma mark - 合并转发(将选择的消息进行数据转换成合并转发需要的IMChatMessage)
- (void)sendChatRecordMessage:(NSMutableArray *)msgModels {
    //选择 消息记录 接收者
    CoHereChatMultiSelectViewController *vc = [CoHereChatMultiSelectViewController new];
    vc.multiSelectType = ZMultiSelectTypeMergeForward;
    vc.mergeMsgCount = msgModels.count;
    [self.navigationController pushViewController:vc animated:YES];
    WeakSelf
    vc.messageRecordReceverListBlock = ^(NSArray * _Nonnull selectedReceverInfoArr) {
        NSString *recordTitle  = @"";
        if (weakSelf.chatType == CIMChatType_SingleChat) {
            //单聊
            recordTitle = [NSString stringWithFormat:LanguageToolMatch(@"%@与%@的会话记录"), UserManager.userInfo.nickname, weakSelf.chatName];
        } else {
            recordTitle = LanguageToolMatch(@"群聊会话记录");
        }
        //根据消息时间进行升序排列
        NSArray *sortResultArr = [NSMutableArray sortMultiSelectedMessageArr:msgModels];
        WeakSelf
        [NoaMessageSendHander ZMessageMergeForwardSendWith:sortResultArr withTitle:recordTitle withToUserInfoArr:selectedReceverInfoArr compelete:^(NSArray <NoaIMChatMessageModel *> *sendChatMsgList) {
            //发送消息
            [sendChatMsgList enumerateObjectsUsingBlock:^(NoaIMChatMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [IMSDKManager toolSendChatMessageWith:obj];
                if ([obj.toID isEqualToString:weakSelf.sessionID]) {
                    //添加到UI上(如果转发给当前聊天)
                    [weakSelf chatListAppendMessage:obj];
                }
            }];
        }];
        [weakSelf setupMultiSelectedStatusDefaultIsReload:YES];
    };
}

#pragma mark - ZFileUploadTaskDelegate
//任务状态改变回调
-(void)fileUploadTask:(NoaFileUploadTask *)task didChangTaskStatus:(FileUploadTaskStatus)status error:(NSError *)error {}

//任务上传进度回调
-(void)fileUploadTask:(NoaFileUploadTask *)task didChangTaskProgress:(float)progress {}

//任务暂停
-(void)fileUploadTaskDidPause:(NoaFileUploadTask *)task {}

//任务继续
-(void)fileUploadTaskDidResume:(NoaFileUploadTask *)task {}

//重新上传
-(void)fileUploadTaskDidReupload:(NoaFileUploadTask *)task {}

#pragma mark - 消息列表追加消息
- (void)chatListAppendMessage:(NoaIMChatMessageModel *)newMessage {
    if (newMessage != nil) {
        //删除 要撤回的消息
        if (newMessage.messageType == CIMChatMessageType_BackMessage) {
            if (newMessage.chatType == CIMChatType_SingleChat) {
                if (([newMessage.fromID isEqualToString:self.sessionID] && [newMessage.toID isEqualToString:UserManager.userInfo.userUID]) || ([newMessage.fromID isEqualToString:UserManager.userInfo.userUID] && [newMessage.toID isEqualToString:self.sessionID])) {
                    
                    [self updateDeleteMessageAndRefreshMsgWithOriginalMsg:newMessage.backDelServiceMsgID];
                    
                }
            } else if (newMessage.chatType == CIMChatType_GroupChat && [newMessage.toID isEqualToString:self.sessionID]) {
                
                [self updateDeleteMessageAndRefreshMsgWithOriginalMsg:newMessage.backDelServiceMsgID];
                
            } else {
                return;
            }
        }
        
        //删除 双向删除的消息
        if (newMessage.messageType == CIMChatMessageType_BilateralDel) {
            
            [self updateDeleteMessageAndRefreshMsgWithOriginalMsg:newMessage.backDelServiceMsgID];
            return;
        }
        
        //解散群聊不追加消息
        if (newMessage.serverMessage.sMsgType == IMServerMessage_ServerMsgType_DelGroupMessage) {
            return;
        }
        //移出群聊不追加消息
        if (newMessage.serverMessage.sMsgType == IMServerMessage_ServerMsgType_KickGroupMessage) {
            return;
        }
        //退出群聊不追加消息
        if (newMessage.serverMessage.sMsgType == IMServerMessage_ServerMsgType_OutGroupMessage) {
            return;
        }
        //当前被移除群聊的是我自己
//        if (newMessage.serverMessage.sMsgType == IMServerMessage_ServerMsgType_KickGroupMessage) {
//            KickGroupMessage *kickmember = newMessage.serverMessage.kickGroupMessage;
//            if ([kickmember.uid isEqualToString:UserManager.userInfo.userUID]) {
//                //当前被移除群聊的是我自己，就不再界面上追加消息了
//                return;
//            }
//        }

        NoaMessageModel *newMsgModel;
        if (newMessage.chatType == CIMChatType_GroupChat) {
            newMsgModel = [self handleMessageWithGroupInformStatusAndInformSwitch:newMessage];
        } else {
            newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:newMessage];
        }
        if (newMsgModel == nil) {return;}
        
        // 检查是否已存在相同 msgID 的消息，如果存在则不添加
        NSString *newMsgID = newMsgModel.message.msgID;
        BOOL isExist = NO;
        if (newMsgID.length > 0) {
            for (NoaMessageModel *existingModel in self.messageModels.safeArray) {
                if (existingModel.message.msgID.length > 0 && [existingModel.message.msgID isEqualToString:newMsgID]) {
                    isExist = YES;
                    break;
                }
            }
        }
        
        if (!isExist) {
            // 不存在相同 msgID 的消息，添加
            [self.messageModels addObject:newMsgModel];
        }
        
        
        if ((newMessage.chatType == CIMChatType_SingleChat && (([newMessage.fromID isEqualToString:self.sessionID] && [newMessage.toID isEqualToString:UserManager.userInfo.userUID]) || ([newMessage.fromID isEqualToString:UserManager.userInfo.userUID] && [newMessage.toID isEqualToString:self.sessionID]))) || (newMessage.chatType == CIMChatType_GroupChat && [newMessage.toID isEqualToString:self.sessionID])) {
            
            //当前会话接收到的消息上报已读
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self checkHistoryListForUnreadMessage:@[newMsgModel]];
            });
        }
    
        //处理消息是否显示时间
        [self computeOneMessageVisibleTimeWithMessage:newMsgModel currentIndex:self.messageModels.count - 1];

        //对展示的所有消息按照sendTime进行排序，排序方法里在排序结束后有reloadData
        [self reviceMessageSortMessagListWithSendTime];

        WeakSelf
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.26 * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            [weakSelf.baseTableView reloadData];
            //加载滚动到底部
            [weakSelf tableViewScrollToBottom:NO duration:0.25];
        });
    }
}

//处理 开启/关闭群通知、关闭/打开 关闭群提示 开关 相关逻辑处理
- (NoaMessageModel *)handleMessageWithGroupInformStatusAndInformSwitch:(NoaIMChatMessageModel *)newMessage {
    NoaMessageModel *newMsgModel = nil;
    /*这几类消息单独处理，开启/关闭群通知、关闭/打开 关闭群提示 开关 控制，决定是否显示*/
    if (newMessage.chatType == CIMChatType_GroupChat) {
        if (newMessage.messageType == CIMChatMessageType_BackMessage) {
            /**撤回消息**/
            if (newMessage.backDelInformSwitch != 2) {
                if (newMessage.backDelInformSwitch == 0) {
                    newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:newMessage];
                }
                if (newMessage.backDelInformSwitch == 1) {
                    if (newMessage.backDelInformUidArray != nil) {
                        if (newMessage.backDelInformUidArray.count == 0) {
                            newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:newMessage];
                        } else {
                            if ([newMessage.backDelInformUidArray containsObject:UserManager.userInfo.userUID]) {
                                newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:newMessage];
                            }
                        }
                    }
                }
            }
        } else if (newMessage.serverMessage.sMsgType == IMServerMessage_ServerMsgType_OutGroupMessage) {
            /**主动退群**/
            if (self.groupInfo.groupInformStatus == 1) {
                OutGroupMessage *outGroupMessage = newMessage.serverMessage.outGroupMessage;
                if (outGroupMessage.informSwitch == 1) {
                    //需要展示的人
                    if ([outGroupMessage.informUidArray containsObject:UserManager.userInfo.userUID]) {
                        //追加消息
                        newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:newMessage];
                    }
                } else {
                    if (outGroupMessage.type != 2) { //排除虚拟用户退群，虚拟用户退群只更新群成员信息，不显示系统消息提示
                        //开关关闭，所有人都显示该条提示
                        //追加消息
                        newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:newMessage];
                    }
                }
            }
        } else if (newMessage.serverMessage.sMsgType == IMServerMessage_ServerMsgType_KickGroupMessage) {
            /**群主/群管理 踢人**/
            KickGroupMessage *kickGroupMessage = newMessage.serverMessage.kickGroupMessage;
            if (self.groupInfo.groupInformStatus == 1) {
                if (kickGroupMessage.informSwitch == 1) {
                    if ([kickGroupMessage.informUidArray containsObject:UserManager.userInfo.userUID]) {
                        //追加消息
                        newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:newMessage];
                    }
                } else {
                    if (kickGroupMessage.type != 2) { //排除虚拟用户被踢，虚拟用户退群只更新群成员信息，不显示系统消息提示
                        //开关关闭，踢人的系统消息所有人都能看见
                        //追加消息
                        newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:newMessage];
                    }
                }
            }
        } else if (newMessage.serverMessage.sMsgType == IMServerMessage_ServerMsgType_EstoppelGroupMessage) {
            /**全员禁言/解除禁言提示*/
            if (self.groupInfo.groupInformStatus == 1) {
                newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:newMessage];
            }
        } else if (newMessage.serverMessage.sMsgType == IMServerMessage_ServerMsgType_GroupSingleForbidMessage) {
            /**单人禁言**/
            if (self.groupInfo.groupInformStatus == 1) {
                /* 群内收到单人禁言消息GroupSingleForbidMessage：
                 1、to_uid等于自己，代表自己被禁言/解除禁言；（展示内容和之前一样）
                 2、from_uid等于自己，代表自己禁言/解除禁言了某人；（展示内容和之前一样）
                 3、to_uid不等于自己，from_uid不等于自己，自己是群主，代表管理员主动禁言/解除禁言了某人；（展示内容和之前一样）
                 4、其他情况，代表群主或管理员禁言/解除禁言了某人；（不展示）*/
                if ([newMessage.serverMessage.groupSingleForbidMessage.toUid isEqualToString:UserManager.userInfo.userUID] || [newMessage.serverMessage.groupSingleForbidMessage.fromUid isEqualToString:UserManager.userInfo.userUID] || (![newMessage.serverMessage.groupSingleForbidMessage.toUid isEqualToString:UserManager.userInfo.userUID] && ![newMessage.serverMessage.groupSingleForbidMessage.fromUid isEqualToString:UserManager.userInfo.userUID] && self.groupInfo.userGroupRole != 0)) {
                    //追加消息
                    newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:newMessage];
                }
            }
        } else if (newMessage.serverMessage.sMsgType == IMServerMessage_ServerMsgType_InviteConfirmGroupMessage) {
            /**邀请进群**/
            if (self.groupInfo.groupInformStatus == 1) {
                //邀请进群
                InviteConfirmGroupMessage *inviteModel = newMessage.serverMessage.inviteConfirmGroupMessage;
                if (inviteModel.informSwitch == 1) {
                    //开关打开
                    if ([inviteModel.informUidArray containsObject:UserManager.userInfo.userUID]) {
                        newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:newMessage];
                    }
                } else {
                    if (inviteModel.type != 5) { //排除掉邀虚拟用户进群，虚拟用户进群只更新群成员信息，不显示系统消息提示
                        //开关关闭，所有人都显示该条提示
                        //追加消息
                        newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:newMessage];
                    }
                }
            }
        } else if (newMessage.serverMessage.sMsgType == IMServerMessage_ServerMsgType_NoticeGroupMessage) {
            /**发布/修改群公告**/
            if (self.groupInfo.groupInformStatus == 1) {
                newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:newMessage];
            }
        } else if (newMessage.serverMessage.sMsgType == IMServerMessage_ServerMsgType_DelGroupNotice) {
            /**删除请公告**/
            if (self.groupInfo.groupInformStatus == 1) {
                newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:newMessage];
            }
        } else if (newMessage.serverMessage.sMsgType == IMServerMessage_ServerMsgType_AdminGroupMessage) {
            /**变更群管理员**/
            if (self.groupInfo.groupInformStatus == 1) {
                AdminGroupMessage *adminGroupMessage = newMessage.serverMessage.adminGroupMessage;
                //设置管理员
                if (adminGroupMessage.informSwitch == 1) {
                    if ([adminGroupMessage.informUidArray containsObject:UserManager.userInfo.userUID]) {
                        newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:newMessage];
                    }
                } else {
                    newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:newMessage];
                }
            }
        } else if (newMessage.serverMessage.sMsgType == IMServerMessage_ServerMsgType_TransferOwnerMessage) {
            /**移交群主**/
            if (self.groupInfo.groupInformStatus == 1) {
                TransferOwnerMessage *transferOwnerMessage = newMessage.serverMessage.transferOwnerMessage;
                if (transferOwnerMessage.informSwitch == 1) {
                    if ([transferOwnerMessage.informUidArray containsObject:UserManager.userInfo.userUID]) {
                        //追加消息
                        newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:newMessage];
                    }
                } else {
                    newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:newMessage];
                }
            }
        } else if (newMessage.serverMessage.sMsgType == IMServerMessage_ServerMsgType_NameGroupMessage) {
            /**修改群名称**/
            if (self.groupInfo.groupInformStatus == 1) {
                newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:newMessage];
            }
        } else if (newMessage.serverMessage.sMsgType == IMServerMessage_ServerMsgType_InviteJoinGroupNoFriendMessage) {
            /**邀请好友进群，好友拒绝进群，邀请的好友实际为"非好友关系"，被删除*/
            if (self.groupInfo.groupInformStatus == 1) {
                newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:newMessage];
            }
        } else if (newMessage.serverMessage.sMsgType == IMServerMessage_ServerMsgType_AvatarGroupMessage) {
            /**修改群头像**/
            if (self.groupInfo.groupInformStatus == 1) {
                newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:newMessage];
            }
        } else if (newMessage.serverMessage.sMsgType == IMServerMessage_ServerMsgType_ScheduleDeleteMessage) {
            /**定时删除设置提示**/
            if (self.groupInfo.groupInformStatus == 1) {
                newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:newMessage];
            }
        } else if (newMessage.serverMessage.sMsgType == IMServerMessage_ServerMsgType_InviteJoinGroupBlackFriendMessage) {
            /**邀请好友进群，好友拒绝进群，邀请的好友实际为"非好友关系"，被拉黑**/
            if (self.groupInfo.groupInformStatus == 1) {
                newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:newMessage];
            }
        } else if (newMessage.serverMessage.sMsgType == IMServerMessage_ServerMsgType_IsShowHistoryMessage) {
            /**新成员可查看历史消息提示**/
            if (self.groupInfo.groupInformStatus == 1) {
                newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:newMessage];
            }
        } else if (newMessage.serverMessage.sMsgType == IMServerMessage_ServerMsgType_CreateGroupMessage) {
            /**创建群组**/
            //开启群通知默认为打开，关闭群提示开关默认打开，除了群主，其他人不显示该条提示
            if (self.groupInfo.userGroupRole != 0) {
                //群主
                newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:newMessage];
            }
        } else {
            //追加消息
            newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:newMessage];
        }
    }
    
    return newMsgModel;
}
#pragma mark - CIMToolMessageDelegate
- (void)cimToolChatMessageReceive:(NoaIMChatMessageModel *)message {
    if ([message.fromID isEqualToString:UserManager.userInfo.userUID] && ![message.toID isEqualToString:self.sessionID]) {
        //这是转发给别人的消息
        return;
    }
    
    WeakSelf
    // 编辑通知只用于刷新引用该原消息的气泡，不作为新的系统消息追加到列表。
    if (message.serverMessage.sMsgType == IMServerMessage_ServerMsgType_EditedOneMsg) {
        [self updateRefreshMsgWithOriginalMsg:message.serviceMsgID];
        return;
    }
    //群成员权限发送变化或者群名发生变化，重新获取groupInfo (转让群主 || 变更管理员 || 群名更改)
    if (message.serverMessage.sMsgType == IMServerMessage_ServerMsgType_TransferOwnerMessage || message.serverMessage.sMsgType == IMServerMessage_ServerMsgType_AdminGroupMessage || message.serverMessage.sMsgType == IMServerMessage_ServerMsgType_NameGroupMessage) {
        if([message.toID isEqualToString:self.sessionID]){
            [self getGroupInfoFromServer];
            [self requestAllGroupMemberReloadTable:YES];
        }
    }
    
    //如果是全员解禁言、单独解禁言等操作需要单独处理
    if (message.serverMessage.sMsgType == IMServerMessage_ServerMsgType_EstoppelGroupMessage || message.serverMessage.sMsgType == IMServerMessage_ServerMsgType_GroupSingleForbidMessage || message.serverMessage.sMsgType == IMServerMessage_ServerMsgType_IsShowHistoryMessage) {
        if([message.toID isEqualToString:self.sessionID]){
            [self getGroupInfoFromServer];
        }
    }
    
    //是否开启全员禁止拨打音视频 状态发生变化
    if (message.serverMessage.sMsgType == IMServerMessage_ServerMsgType_GroupIsAllowNetCallMessage) {
        if([message.toID isEqualToString:self.sessionID]){
            [self getGroupInfoFromServer];
            return;
        }
    }
    
    //群通知 开关状态发生变化
    if (message.serverMessage.sMsgType == IMServerMessage_ServerMsgType_UpdateGroupInformStatusForAdminSystem) {
        if([message.serverMessage.groupStatusMessage.gid isEqualToString:self.sessionID]){
            [self getGroupInfoFromServer];
            return;
        }
    }
    
    //是否开启"关闭群提示" 状态发生变化
    if (message.serverMessage.sMsgType == IMServerMessage_ServerMsgType_GroupMessageInform) {
        if([message.toID isEqualToString:self.sessionID]){
            [self getGroupInfoFromServer];
            return;
        }
    }

    //删除群公告 该消息转发给在线所有成员
    if (message.serverMessage.sMsgType == IMServerMessage_ServerMsgType_DelGroupNotice) {
        if([message.toID isEqualToString:self.sessionID]){
            /**
             * TODO: 旧版本代码
             //移除置顶群公告
             [self groupNoticeTipAction:0];
             */
            
            // TODO: 新版本-查询群信息，无任何群公告后，不展示置顶群公告
            [self getGroupInfoFromServer];
            return;
        }
    }
    //群消息置顶/取消置顶 该消息转发给在线所有成员
    if (message.serverMessage.sMsgType == IMServerMessage_ServerMsgType_GroupMessageTop) {
        if([message.toID isEqualToString:self.sessionID]){
            [self requestGroupTopMessages];
            return;
        }
    }
    
    if (message.serverMessage.sMsgType == IMServerMessage_ServerMsgType_DialogUserMessageTop) {
        if(([message.fromID isEqualToString:self.sessionID] && [message.toID isEqualToString:UserManager.userInfo.userUID]) || ([message.fromID isEqualToString:UserManager.userInfo.userUID] && [message.toID isEqualToString:self.sessionID])){
            [self requestSingleTopMessages];
            return;
        }
    }
    
    //单聊
    if (message.chatType == CIMChatType_SingleChat) {
        //撤回消息通知、双向删除
        if (message.messageType == CIMChatMessageType_BackMessage || message.messageType == CIMChatMessageType_BilateralDel) {
            //表示该条消息是当前会话的
            dispatch_async(_chatMessageUpdateQueue, ^{
                [weakSelf chatListAppendMessage:message];
            });
        } else if (([message.fromID isEqualToString:self.sessionID] && [message.toID isEqualToString:UserManager.userInfo.userUID]) || ([message.fromID isEqualToString:UserManager.userInfo.userUID] && [message.toID isEqualToString:self.sessionID])) {
            //表示该条消息是当前会话的
            [self chatListAppendMessage:message];
        }
    }
    //群聊
    if (message.chatType == CIMChatType_GroupChat) {
        //撤回消息通知
        if (message.messageType == CIMChatMessageType_BackMessage || message.messageType == CIMChatMessageType_BilateralDel) {
            //表示该条消息是当前会话的
            dispatch_async(_chatMessageUpdateQueue, ^{
                [weakSelf chatListAppendMessage:message];
            });
        } else if ([message.toID isEqualToString:self.sessionID]) {
            //表示该条消息是当前会话的
            [self chatListAppendMessage:message];
        }
    }
    
    //收到群公告更改消息(群公告的serverMessage和CIMChatMessageType_GroupNotice消息类型 群公告消息 功能重合，此处做一遍备注)
    if (message.serverMessage.sMsgType == IMServerMessage_ServerMsgType_NoticeGroupMessage) {
        if([message.toID isEqualToString:self.sessionID]){
            NoticeGroupMessage *noticeMessage = message.serverMessage.noticeGroupMessage;
            self.groupNoticeModel.translateContent = noticeMessage.transNotice;
            self.groupInfo.groupNotice.translateContent = noticeMessage.transNotice;
            
           /**
            * TODO: 旧版本代码，根据群公告状态展示置顶的群公告
            if(message.serverMessage.noticeGroupMessage.isTop == 1) {
                //群公告置顶 在顶部显示群公告
                [self showGroupNoticeTipViewWith:message.serverMessage.noticeGroupMessage.notice translateNoticeContent:message.serverMessage.noticeGroupMessage.transNotice];
            }else {
                //移除置顶群公告
                [self groupNoticeTipAction:0];
            }
            */
            
            // TODO: 新版本-查询群信息，无任何群公告后，不展示置顶群公告
            [self getGroupInfoFromServer];
        }
    }

    //踢出群聊
    if (message.serverMessage.sMsgType == IMServerMessage_ServerMsgType_KickGroupMessage) {
        //判断移除的群成员是否为自己
        if (self.chatType == CIMChatType_GroupChat && [message.serverMessage.kickGroupMessage.gid isEqualToString:self.groupInfo.groupId]) {
            if ([message.serverMessage.kickGroupMessage.uid isEqualToString:UserManager.userInfo.userUID]) {
                if (self.groupInfo.groupInformStatus == 1) {
                    [self deleteSessionAndChatMessage];

//                    [self showTipAlertView:LanguageToolMatch(@"你已被移出群聊") btnName:LanguageToolMatch(@"我知道了") isNeedDelete:NO];
                } else {
                    [self deleteSessionAndChatMessage];
                    [weakSelf.navigationController.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj isKindOfClass:[CandyTalkHomeViewController class]]) {
                            CandyTalkHomeViewController *vc = (CandyTalkHomeViewController *)obj;
                            [weakSelf.navigationController popToViewController:vc animated:YES];
                            *stop = YES;
                        }
                    }];
                }
            }  else {
                if([message.toID isEqualToString:self.sessionID]){
                    //更新群信息
                    [self getGroupInfoFromServer];
                    //[IMSDKManager imSdkDeleteGroupMemberWith:message.serverMessage.kickGroupMessage.uid groupID:self.groupInfo.groupId];
                    if (message.serverMessage.kickGroupMessage.msgDel) {
                        //移除群成员时选择了同时移除该成员在本群发出的所有消息
                        NSArray *tempMessageArr = [self.messageModels.safeArray copy];
                        for (int i = 0; i<tempMessageArr.count; i++) {
                            NoaMessageModel *msgModel = [tempMessageArr objectAtIndex:i];
                            if ([msgModel.message.fromID isEqualToString:message.serverMessage.kickGroupMessage.uid]) {
                                //更新当前UI的数据
                                [self.messageModels removeObject:msgModel];
                            }
                        }
                        //处理消息是否显示时间
                        [self computeVisibleTime];
                        //更新UI，局部刷新
                        [self.baseTableView reloadData];
                    }
                }
            }
        }
    }
    
    //判断是否为解散群组
    if (message.serverMessage.sMsgType == IMServerMessage_ServerMsgType_DelGroupMessage) {
        //操作者id不是当前用户，并且删除的群id是当前群
        if ([message.serverMessage.delGroupMessage.gid isEqualToString:self.sessionID]) {
            if (self.groupInfo.groupInformStatus == 1) {
                //群解散
//                [self showTipAlertView:LanguageToolMatch(@"群聊已解散") btnName:LanguageToolMatch(@"我知道了") isNeedDelete:NO];
                [self deleteSessionAndChatMessage];
            } else {
                [self deleteSessionAndChatMessage];
            }
        }
    }
    
    //判断是否为退出群聊
    if (message.serverMessage.sMsgType == IMServerMessage_ServerMsgType_OutGroupMessage) {
        if ([message.serverMessage.outGroupMessage.uid isEqualToString:UserManager.userInfo.userUID]) {
            [self deleteSessionAndChatMessage];
//                [self showTipAlertView:LanguageToolMatch(@"你已退出该群聊") btnName:LanguageToolMatch(@"我知道了") isNeedDelete:NO];
        } else {
            if([message.toID isEqualToString:self.sessionID]){
                [IMSDKManager imSdkDeleteGroupMemberWith:message.serverMessage.outGroupMessage.uid groupID:self.groupInfo.groupId];
                [self getGroupInfoFromServer];
            }
        }
    }
    
    //邀请进群，更新群信息
    if (message.serverMessage.sMsgType == IMServerMessage_ServerMsgType_InviteConfirmGroupMessage) {
        if([message.toID isEqualToString:self.sessionID]){
            [self getGroupInfoFromServer];
            [self requestAllGroupMemberReloadTable:YES];
        }
    }
    
    //消息定时自动删除逻辑处理
    if (message.serverMessage.sMsgType == IMServerMessage_ServerMsgType_ScheduleDeleteMessage) {
        ScheduleDeleteMessage *messageTimeDeleteModel = message.serverMessage.scheduleDeleteMessage;
        _messageTimeDeleteType = messageTimeDeleteModel.freq;
    }
    
    //即构音视频通话
    if (message.chatType == CIMChatType_NetCallChat) {
        if (message.netCallChatType == LingIMCallRoomTypeSingle) {
            //单聊
            if (([message.fromID isEqualToString:UserManager.userInfo.userUID] && [message.toID isEqualToString:self.sessionID])
                || ([message.fromID isEqualToString:self.sessionID] && [message.toID isEqualToString:UserManager.userInfo.userUID])) {
                //该消息属于当前会话
                [self chatListAppendMessage:message];
            }
        }else if (message.netCallChatType == LingIMCallRoomTypeGroup) {
            //群聊
            if ([message.toID isEqualToString:self.sessionID]) {
                //该消息属于当前会话
                [self chatListAppendMessage:message];
            }
            
        }
    }
    
    //更新群成员数据库
    if (message.serverMessage.sMsgType == IMServerMessage_ServerMsgType_InviteConfirmGroupMessage) {
        [self requestAllGroupMemberReloadTable:NO];
    }
}

- (void)cimToolChatMessageSendSuccess:(IMChatMessageACK *)messageACK {
    DLog(@"消息发送成功：%@--服务端生成ID:%@ --服务端生成发送时间:%lld",messageACK.ackMsgId,messageACK.sMsgId, messageACK.sendTime);
    WeakSelf
    dispatch_async(_chatMessageUpdateQueue, ^{
        for (int i = 0; i<weakSelf.messageModels.count; i++) {
            NoaMessageModel *msgModel = [weakSelf.messageModels objectAtIndex:i];
            if ([msgModel.message.msgID isEqualToString:messageACK.ackMsgId]) {
                long long localSendTime = msgModel.message.sendTime;
                //更新本地数据
                msgModel.message.messageSendType = CIMChatMessageSendTypeSuccess;
                msgModel.message.serviceMsgID = messageACK.sMsgId;
                if (messageACK.sendTime > 0) {
                    msgModel.message.sendTime = messageACK.sendTime;
                }
                DLog(@"[MsgTime] ack msgId=%@ localSendTime=%lld ackSendTime=%lld delta=%lld sMsgId=%@",
                     messageACK.ackMsgId, localSendTime, messageACK.sendTime, messageACK.sendTime - localSendTime, messageACK.sMsgId);
                [weakSelf.messageModels replaceObjectAtIndex:i withObject:msgModel];
                
                // ACK 回写 sendTime/serviceMsgID 后立刻稳定重排（内部会 computeVisibleTime）
                [weakSelf reviceMessageSortMessagListWithSendTime];
                break;
            }
        }
    });
}

- (void)cimToolChatMessageSendFail:(NSString *)messageID {
    DLog(@"消息发送失败：%@",messageID);
    WeakSelf
    dispatch_async(_chatMessageUpdateQueue, ^{
        for (int i = 0; i<weakSelf.messageModels.count; i++) {
            NoaMessageModel *msgModel = [weakSelf.messageModels objectAtIndex:i];
            if ([msgModel.message.msgID isEqualToString:messageID]) {
                //更新本地数据
                NoaMessageModel *newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:msgModel.message];
                newMsgModel.message.messageSendType = CIMChatMessageSendTypeFail;
                [weakSelf.messageModels replaceObjectAtIndex:i withObject:newMsgModel];
                
                //处理消息是否显示时间
                [weakSelf computeVisibleTime];
                [ZTOOL doInMain:^{
                    //更新UI，局部刷新
                    //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    //[weakSelf.baseTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
                    [weakSelf.baseTableView reloadData];
                }];
            }
        }
    });
}

- (void)imSdkChatMessageUpdateUserRoleAuthority {
    //重新获取当前用户的角色权限
    [self requestGetUserRoleAuthorityInfo];
    //重新获取用户角色配置信息
    [self requestGetRoleConfigInfo];
}

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

#pragma mark - tableView滚动到底部
- (void)tableViewScrollToBottom:(BOOL)animated duration:(CGFloat)duration {
    if (self.messageModels.count > 0) {
        
        if (_btnBottom.hidden == NO) {
            CIMLog(@"[ScrollToBottom] 跳过：btnBottom 未隐藏");
            return;
        }
        if (self.baseTableView.dragging || self.baseTableView.decelerating || self.baseTableView.tracking || self.baseTableView.editing) {
            CIMLog(@"[ScrollToBottom] 跳过：用户正在操作 tableView");
            return ;
        }
        
        if (self.isScrollIng) {
            CIMLog(@"[ScrollToBottom] 跳过：正在滚动中");
            return;
        }
        
        // 检查是否已经在底部附近（避免不必要的滚动）
        [self.baseTableView layoutIfNeeded];
        CGFloat currentContentHeight = self.baseTableView.contentSize.height;
        CGFloat currentOffsetY = self.baseTableView.contentOffset.y;
        CGFloat tableViewHeight = self.baseTableView.bounds.size.height;
        CGFloat contentInsetBottom = self.baseTableView.contentInset.bottom;
        CGFloat bottomDistance = currentContentHeight - currentOffsetY - tableViewHeight - contentInsetBottom;
        
        // 如果已经在底部附近（距离底部在 0-10 像素之间），不需要滚动
        // 注意：bottomDistance 为负数时，说明 offsetY 已经超过了应该滚动到的位置，或者 contentSize 还没计算好，需要滚动
        if (bottomDistance >= 0 && bottomDistance <= 10 && currentContentHeight > 0) {
            CIMLog(@"[ScrollToBottom] 跳过：已在底部附近，bottomDistance=%.1f", bottomDistance);
            return;
        }
        
        // 如果 bottomDistance 为负数，说明需要滚动（可能是 contentSize 还没计算好，或者 offsetY 异常）
        if (bottomDistance < 0) {
            CIMLog(@"[ScrollToBottom] bottomDistance 为负数(%.1f)，需要滚动，继续执行", bottomDistance);
        }
        
        self.isScrollIng = YES;
        CIMLog(@"[ScrollToBottom] 开始滚动，消息数量：%lu, animated：%d, 当前offsetY=%.1f, contentHeight=%.1f, bottomDistance=%.1f", 
               (unsigned long)self.messageModels.count, animated, currentOffsetY, currentContentHeight, bottomDistance);
        
        // 先 reloadData
        [self.baseTableView reloadData];
        
        // 延迟执行，确保 reloadData 完成后再滚动
        // 使用 dispatch_async 确保在下一个 runloop 执行
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performScrollToBottomWithAnimated:animated retryCount:0 lastContentHeight:0];
        });
    };
}

/// 执行滚动到底部，带重试机制确保 cell 高度计算完成
- (void)performScrollToBottomWithAnimated:(BOOL)animated retryCount:(NSInteger)retryCount lastContentHeight:(CGFloat)lastContentHeight {
    // 最大重试次数，避免无限循环
    if (retryCount > 10) {
        CIMLog(@"[ScrollToBottom] performScrollToBottom 超过最大重试次数，停止");
        self.isScrollIng = NO;
        return;
    }
    
    // 检查数据源
    if (self.messageModels.count == 0) {
        CIMLog(@"[ScrollToBottom] performScrollToBottom 数据源为空，停止");
        self.isScrollIng = NO;
        return;
    }
    
    // 确保布局完成
    [self.baseTableView layoutIfNeeded];
    
    // 计算所有 cell 的总高度（基于 model.cellHeight）
    CGFloat totalCellHeight = 0;
    CGFloat maxCellHeight = 0;
    NSInteger longTextCellCount = 0;
    for (NoaMessageModel *model in self.messageModels.safeArray) {
        totalCellHeight += model.cellHeight;
        if (model.cellHeight > maxCellHeight) {
            maxCellHeight = model.cellHeight;
        }
        // 检测超长文本（cellHeight > 500 认为是超长文本）
        if (model.cellHeight > 500) {
            longTextCellCount++;
        }
    }
    
    // 获取当前 contentSize 和 tableView 尺寸
    CGFloat currentContentHeight = self.baseTableView.contentSize.height;
    CGFloat tableViewHeight = self.baseTableView.bounds.size.height;
    CGFloat contentInsetBottom = self.baseTableView.contentInset.bottom;
    CGFloat currentOffsetY = self.baseTableView.contentOffset.y;
    
    // 计算 contentSize 和 totalCellHeight 的差异
    CGFloat heightDifference = fabs(currentContentHeight - totalCellHeight);
    
    CIMLog(@"[ScrollToBottom] performScrollToBottom retryCount=%ld, lastHeight=%.1f, currentHeight=%.1f, totalCellHeight=%.1f, heightDiff=%.1f, tableViewHeight=%.1f, offsetY=%.1f, maxCellHeight=%.1f, longTextCount=%ld", 
           (long)retryCount, lastContentHeight, currentContentHeight, totalCellHeight, heightDifference, tableViewHeight, currentOffsetY, maxCellHeight, (long)longTextCellCount);
    
    // 如果检测到超长文本，记录详细信息
    if (longTextCellCount > 0) {
        CIMLog(@"[ScrollToBottom] ⚠️ 检测到超长文本：数量=%ld, 最大cell高度=%.1f, contentSize=%.1f, totalCellHeight=%.1f, 差异=%.1f", 
               (long)longTextCellCount, maxCellHeight, currentContentHeight, totalCellHeight, heightDifference);
    }
    
    // 检查 contentSize 是否稳定（连续两次检查相同，说明已经计算完成）
    BOOL isContentSizeStable = (lastContentHeight > 0 && fabs(currentContentHeight - lastContentHeight) < 0.1);
    
    // 如果 contentSize 还没稳定，需要等待
    if (!isContentSizeStable && retryCount < 5) {
        CGFloat changeAmount = currentContentHeight - lastContentHeight;
        CIMLog(@"[ScrollToBottom] performScrollToBottom contentSize 不稳定，变化量=%.1f，等待重试", changeAmount);
        
        // 如果检测到超长文本，等待时间需要更长
        NSTimeInterval delay = 0.1;
        if (longTextCellCount > 0 || maxCellHeight > 500) {
            delay = 0.2; // 超长文本需要更长的等待时间
            CIMLog(@"[ScrollToBottom] ⚠️ 检测到超长文本，延长等待时间到 %.2f 秒", delay);
        }
        
        // contentSize 还在变化，延迟重试
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self performScrollToBottomWithAnimated:animated retryCount:retryCount + 1 lastContentHeight:currentContentHeight];
        });
        return;
    }
    
    // 如果 contentSize 和 totalCellHeight 差异很大，说明可能还有 cell 高度没计算好
    if (heightDifference > 100 && retryCount < 8) {
        CIMLog(@"[ScrollToBottom] ⚠️ contentSize(%.1f) 和 totalCellHeight(%.1f) 差异较大(%.1f)，可能还有 cell 高度没计算好，等待重试", 
               currentContentHeight, totalCellHeight, heightDifference);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self performScrollToBottomWithAnimated:animated retryCount:retryCount + 1 lastContentHeight:currentContentHeight];
        });
        return;
    }
    
    // 如果 contentSize 为 0 或太小，但总高度已经计算好，使用总高度
    if (currentContentHeight < tableViewHeight * 0.5 && totalCellHeight > 0) {
        CIMLog(@"[ScrollToBottom] performScrollToBottom contentSize 太小，使用总高度：%.1f -> %.1f", currentContentHeight, totalCellHeight);
        currentContentHeight = totalCellHeight;
    } else if (totalCellHeight > currentContentHeight + 50) {
        // 如果 totalCellHeight 明显大于 contentSize，说明 contentSize 可能还没计算好
        CIMLog(@"[ScrollToBottom] ⚠️ totalCellHeight(%.1f) 明显大于 contentSize(%.1f)，差异=%.1f，可能还有 cell 高度没计算好", 
               totalCellHeight, currentContentHeight, totalCellHeight - currentContentHeight);
        if (retryCount < 8) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self performScrollToBottomWithAnimated:animated retryCount:retryCount + 1 lastContentHeight:currentContentHeight];
            });
            return;
        }
    }
    
    //防止越界崩溃
    NSInteger totalRowIndex = [self.baseTableView numberOfRowsInSection:0] - 1;
    if (totalRowIndex < 0) {
        CIMLog(@"[ScrollToBottom] performScrollToBottom 行数为0，停止");
        self.isScrollIng = NO;
        return;
    }
    
    //加载滚动到底部
    @try {
        if (animated) {
            CIMLog(@"[ScrollToBottom] performScrollToBottom 使用动画滚动到 row=%ld", (long)totalRowIndex);
            // 有动画时使用 scrollToRowAtIndexPath
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:totalRowIndex inSection:0];
            [self.baseTableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
            
            // 延迟重置标志位，确保滚动完成
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.isScrollIng = NO;
            });
        } else {
            CIMLog(@"[ScrollToBottom] performScrollToBottom 无动画，等待 contentSize 稳定");
            // 无动画时，等待 contentSize 稳定后再滚动（避免图片加载导致先下后上的问题）
            // 先不滚动，等待 contentSize 稳定
            [self waitForContentSizeStableThenScroll:currentContentHeight animated:animated retryCount:retryCount];
        }
    } @catch (NSException *exception) {
        CIMLog(@"[ScrollToBottom] performScrollToBottom 异常: %@", exception);
        self.isScrollIng = NO;
    }
}

/// 等待 contentSize 稳定后再滚动（避免图片加载导致先下后上的问题）
- (void)waitForContentSizeStableThenScroll:(CGFloat)lastContentHeight animated:(BOOL)animated retryCount:(NSInteger)retryCount {
    // 最大重试次数，避免无限循环
    if (retryCount > 15) {
        CIMLog(@"[ScrollToBottom] waitForContentSizeStable 超过最大重试次数，强制滚动");
        // 超时后强制滚动
        [self performFinalScroll:animated];
        return;
    }
    
    // 检查数据源
    if (self.messageModels.count == 0) {
        CIMLog(@"[ScrollToBottom] waitForContentSizeStable 数据源为空，停止");
        self.isScrollIng = NO;
        return;
    }
    
    // 确保布局完成
    [self.baseTableView layoutIfNeeded];
    
    // 计算所有 cell 的总高度（用于检测超长文本）
    CGFloat totalCellHeight = 0;
    CGFloat maxCellHeight = 0;
    for (NoaMessageModel *model in self.messageModels.safeArray) {
        totalCellHeight += model.cellHeight;
        if (model.cellHeight > maxCellHeight) {
            maxCellHeight = model.cellHeight;
        }
    }
    
    // 获取当前 contentSize
    CGFloat currentContentHeight = self.baseTableView.contentSize.height;
    CGFloat tableViewHeight = self.baseTableView.bounds.size.height;
    CGFloat currentOffsetY = self.baseTableView.contentOffset.y;
    CGFloat contentInsetBottom = self.baseTableView.contentInset.bottom;
    CGFloat bottomDistance = currentContentHeight - currentOffsetY - tableViewHeight - contentInsetBottom;
    
    // 计算 contentSize 和 totalCellHeight 的差异
    CGFloat heightDifference = totalCellHeight - currentContentHeight;
    
    CIMLog(@"[ScrollToBottom] waitForContentSizeStable retryCount=%ld, lastHeight=%.1f, currentHeight=%.1f, totalCellHeight=%.1f, heightDiff=%.1f, tableViewHeight=%.1f, offsetY=%.1f, bottomDistance=%.1f, maxCellHeight=%.1f", 
           (long)retryCount, lastContentHeight, currentContentHeight, totalCellHeight, heightDifference, tableViewHeight, currentOffsetY, bottomDistance, maxCellHeight);
    
    // 如果 totalCellHeight 明显大于 contentSize，说明可能还有 cell 高度没计算好（特别是超长文本）
    if (heightDifference > 100 && retryCount < 10) {
        CIMLog(@"[ScrollToBottom] ⚠️ waitForContentSizeStable totalCellHeight(%.1f) 明显大于 contentSize(%.1f)，差异=%.1f，可能还有 cell 高度没计算好，继续等待", 
               totalCellHeight, currentContentHeight, heightDifference);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self waitForContentSizeStableThenScroll:currentContentHeight animated:animated retryCount:retryCount + 1];
        });
        return;
    }
    
    // 如果已经在底部附近（距离底部在 0-10 像素之间），不需要等待，直接结束
    // 注意：bottomDistance 为负数时，说明需要滚动，不能跳过
    if (bottomDistance >= 0 && bottomDistance <= 10 && currentContentHeight > 0) {
        CIMLog(@"[ScrollToBottom] waitForContentSizeStable 已在底部附近，停止等待，bottomDistance=%.1f", bottomDistance);
        self.isScrollIng = NO;
        return;
    }
    
    // 如果 bottomDistance 为负数，说明需要滚动，继续等待 contentSize 稳定
    if (bottomDistance < 0) {
        CIMLog(@"[ScrollToBottom] waitForContentSizeStable bottomDistance 为负数(%.1f)，需要滚动，继续等待", bottomDistance);
    }
    
    // 如果 contentSize 为 0 或太小，说明还没计算好，需要等待
    if (currentContentHeight < tableViewHeight * 0.3 && retryCount < 5) {
        CIMLog(@"[ScrollToBottom] waitForContentSizeStable contentSize 太小(%.1f < %.1f)，等待", currentContentHeight, tableViewHeight * 0.3);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self waitForContentSizeStableThenScroll:currentContentHeight animated:animated retryCount:retryCount + 1];
        });
        return;
    }
    
    // 检查 contentSize 是否稳定（需要连续多次检查都稳定，而不是只检查两次）
    CGFloat changeAmount = currentContentHeight - lastContentHeight;
    BOOL isStable = (lastContentHeight > 0 && fabs(changeAmount) < 0.5);
    
    // 如果 contentSize 还在变化，继续等待（需要等待更长时间，确保图片加载完成）
    if (!isStable && retryCount < 12) {
        // contentSize 还在变化，延迟重试（延迟时间根据变化幅度调整）
        // 如果变化量较大，说明图片还在加载，需要等待更长时间
        NSTimeInterval delay;
        if (changeAmount > 100) {
            delay = 0.5; // 变化很大，等待更长时间
        } else if (changeAmount > 50) {
            delay = 0.4; // 变化较大
        } else if (changeAmount > 10) {
            delay = 0.3; // 变化中等
        } else {
            delay = 0.2; // 变化较小
        }
        
        CIMLog(@"[ScrollToBottom] waitForContentSizeStable contentSize 不稳定，变化量=%.1f，延迟%.2f秒后重试", changeAmount, delay);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self waitForContentSizeStableThenScroll:currentContentHeight animated:animated retryCount:retryCount + 1];
        });
        return;
    }
    
    // contentSize 稳定了，执行滚动
    CIMLog(@"[ScrollToBottom] waitForContentSizeStable contentSize 已稳定(%.1f)，执行滚动", currentContentHeight);
    [self performFinalScroll:animated];
}

/// 执行最终的滚动到底部
- (void)performFinalScroll:(BOOL)animated {
    if (self.messageModels.count == 0) {
        CIMLog(@"[ScrollToBottom] performFinalScroll 数据源为空，停止");
        self.isScrollIng = NO;
        return;
    }
    
    // 确保布局完成
    [self.baseTableView layoutIfNeeded];
    
    // 获取当前 contentSize 和 tableView 尺寸
    CGFloat currentContentHeight = self.baseTableView.contentSize.height;
    CGFloat tableViewHeight = self.baseTableView.bounds.size.height;
    CGFloat contentInsetBottom = self.baseTableView.contentInset.bottom;
    CGFloat currentOffsetY = self.baseTableView.contentOffset.y;
    
    //防止越界崩溃
    NSInteger totalRowIndex = [self.baseTableView numberOfRowsInSection:0] - 1;
    if (totalRowIndex < 0) {
        CIMLog(@"[ScrollToBottom] performFinalScroll 行数为0，停止");
        self.isScrollIng = NO;
        return;
    }
    
    @try {
        if (animated) {
            CIMLog(@"[ScrollToBottom] performFinalScroll 使用动画滚动到 row=%ld", (long)totalRowIndex);
            // 有动画时使用 scrollToRowAtIndexPath
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:totalRowIndex inSection:0];
            [self.baseTableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
            
            // 延迟重置标志位，确保滚动完成
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.isScrollIng = NO;
            });
        } else {
            // 无动画时，直接使用 setContentOffset
            // 计算目标 offsetY
            CGFloat targetOffsetY;
            CGFloat bottomDistance = currentContentHeight - currentOffsetY - tableViewHeight - contentInsetBottom;
            
            if (currentContentHeight <= tableViewHeight) {
                // 如果 contentSize 小于等于 tableViewHeight，滚动到 contentSize 的底部（但不能小于 0）
                // 但如果 bottomDistance 为负数，说明需要滚动到 contentSize 的底部
                targetOffsetY = MAX(0, currentContentHeight - tableViewHeight + contentInsetBottom);
                // 如果计算出的 targetOffsetY 是 0，但 bottomDistance 为负数，说明 contentSize 可能还没计算好
                // 此时应该滚动到 contentSize 的底部（即 0，因为 contentSize 太小）
                if (targetOffsetY == 0 && bottomDistance < 0) {
                    // contentSize 太小，但需要滚动，说明可能还有 cell 高度没计算好
                    // 先滚动到 0，然后等待 contentSize 变化
                    targetOffsetY = 0;
                    CIMLog(@"[ScrollToBottom] ⚠️ performFinalScroll contentSize(%.1f) 太小，bottomDistance=%.1f，先滚动到 0，等待 contentSize 变化", 
                           currentContentHeight, bottomDistance);
                }
            } else {
                // 正常情况，滚动到底部
                targetOffsetY = MAX(0, currentContentHeight - tableViewHeight + contentInsetBottom);
            }
            
            CGFloat adjustOffset = targetOffsetY - currentOffsetY;
            
            CIMLog(@"[ScrollToBottom] performFinalScroll 设置 offsetY: %.1f -> %.1f (调整量=%.1f), contentHeight=%.1f, tableViewHeight=%.1f, insetBottom=%.1f, bottomDistance=%.1f", 
                   currentOffsetY, targetOffsetY, adjustOffset, currentContentHeight, tableViewHeight, contentInsetBottom, bottomDistance);
            
            [self.baseTableView setContentOffset:CGPointMake(0, targetOffsetY) animated:NO];
            
            // 立即验证滚动结果
            dispatch_async(dispatch_get_main_queue(), ^{
                CGFloat actualOffsetY = self.baseTableView.contentOffset.y;
                CGFloat actualContentHeight = self.baseTableView.contentSize.height;
                CGFloat actualBottomDistance = actualContentHeight - actualOffsetY - tableViewHeight - contentInsetBottom;
                CIMLog(@"[ScrollToBottom] performFinalScroll 滚动后验证: offsetY=%.1f, contentHeight=%.1f, bottomDistance=%.1f", 
                       actualOffsetY, actualContentHeight, actualBottomDistance);
            });
            
            // 滚动完成后，如果 contentSize 还在变化（图片加载），需要再次调整
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self adjustScrollIfContentSizeChanged:currentContentHeight];
            });
        }
    } @catch (NSException *exception) {
        CIMLog(@"[ScrollToBottom] performFinalScroll 异常: %@", exception);
        self.isScrollIng = NO;
    }
}

/// 如果 contentSize 变化了（图片加载完成），调整滚动位置
- (void)adjustScrollIfContentSizeChanged:(CGFloat)lastContentHeight {
    // 检查数据源
    if (self.messageModels.count == 0) {
        CIMLog(@"[ScrollToBottom] adjustScrollIfContentSizeChanged 数据源为空，停止");
        self.isScrollIng = NO;
        return;
    }
    
    // 确保布局完成
    [self.baseTableView layoutIfNeeded];
    
    // 获取当前 contentSize 和滚动位置
    CGFloat currentContentHeight = self.baseTableView.contentSize.height;
    CGFloat currentOffsetY = self.baseTableView.contentOffset.y;
    CGFloat tableViewHeight = self.baseTableView.bounds.size.height;
    CGFloat contentInsetBottom = self.baseTableView.contentInset.bottom;
    
    // 计算当前距离底部的距离
    CGFloat bottomDistance = currentContentHeight - currentOffsetY - tableViewHeight - contentInsetBottom;
    
    // 如果 contentSize 变大了，需要调整
    BOOL contentSizeIncreased = (currentContentHeight > lastContentHeight + 1);
    CGFloat changeAmount = currentContentHeight - lastContentHeight;
    
    CIMLog(@"[ScrollToBottom] adjustScrollIfContentSizeChanged lastHeight=%.1f, currentHeight=%.1f, 变化量=%.1f, offsetY=%.1f, bottomDistance=%.1f, contentSizeIncreased=%d", 
           lastContentHeight, currentContentHeight, changeAmount, currentOffsetY, bottomDistance, contentSizeIncreased);
    
    // 需要调整的条件：
    // 1. contentSize 变大了，且满足以下条件之一：
    //    - 当前在底部附近（距离底部小于 50 像素）
    //    - contentSize 变化很大（变化量 > 100），说明可能是超长文本的 cell 高度计算完成
    // 2. contentSize 没有变化，但 bottomDistance 很大（为负数或 > 100），说明需要滚动到底部
    BOOL needAdjust = (contentSizeIncreased && (bottomDistance < 50 || changeAmount > 100)) || 
                      (!contentSizeIncreased && (bottomDistance < 0 || bottomDistance > 100));
    
    if (needAdjust) {
        CIMLog(@"[ScrollToBottom] adjustScrollIfContentSizeChanged 需要调整，原因：contentSizeIncreased=%d, bottomDistance=%.1f, changeAmount=%.1f", 
               contentSizeIncreased, bottomDistance, changeAmount);
        CIMLog(@"[ScrollToBottom] adjustScrollIfContentSizeChanged 需要调整，启动防抖");
        // 取消之前的防抖任务
        if (self.pendingImageLoadAdjustBlock) {
            dispatch_block_cancel(self.pendingImageLoadAdjustBlock);
            self.pendingImageLoadAdjustBlock = nil;
        }
        
        // 使用防抖机制，等待 contentSize 稳定后再调整
        WeakSelf
        self.pendingImageLoadAdjustBlock = dispatch_block_create(0, ^{
            StrongSelf
            if (!strongSelf) return;
            
            [strongSelf.baseTableView layoutIfNeeded];
            CGFloat stableContentHeight = strongSelf.baseTableView.contentSize.height;
            CGFloat stableOffsetY = strongSelf.baseTableView.contentOffset.y;
            CGFloat stableTableViewHeight = strongSelf.baseTableView.bounds.size.height;
            CGFloat stableContentInsetBottom = strongSelf.baseTableView.contentInset.bottom;
            CGFloat stableBottomDistance = stableContentHeight - stableOffsetY - stableTableViewHeight - stableContentInsetBottom;
            
            CIMLog(@"[ScrollToBottom] adjustScrollIfContentSizeChanged 防抖执行: stableHeight=%.1f, stableOffsetY=%.1f, stableBottomDistance=%.1f", 
                   stableContentHeight, stableOffsetY, stableBottomDistance);
            
            // 如果距离底部超过 1 像素，才调整
            if (stableBottomDistance > 1) {
                CGFloat targetOffsetY = MAX(0, stableContentHeight - stableTableViewHeight + stableContentInsetBottom);
                CGFloat adjustOffset = targetOffsetY - stableOffsetY;
                
                // 如果调整量大于 5 像素，才调整（避免微小抖动）
                // 或者如果 bottomDistance 很大（说明需要滚动到底部），也调整
                if (fabs(adjustOffset) > 5 || stableBottomDistance > 100) {
                    CIMLog(@"[ScrollToBottom] adjustScrollIfContentSizeChanged 执行调整: offsetY %.1f -> %.1f (调整量=%.1f, bottomDistance=%.1f)", 
                           stableOffsetY, targetOffsetY, adjustOffset, stableBottomDistance);
                    [strongSelf.baseTableView setContentOffset:CGPointMake(0, targetOffsetY) animated:NO];
                    
                    // 如果 contentSize 还在变化，继续监听
                    if (stableContentHeight > lastContentHeight + 1) {
                        CIMLog(@"[ScrollToBottom] adjustScrollIfContentSizeChanged contentSize 还在变化，继续监听");
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [strongSelf adjustScrollIfContentSizeChanged:stableContentHeight];
                        });
                        return;
                    }
                } else {
                    CIMLog(@"[ScrollToBottom] adjustScrollIfContentSizeChanged 调整量太小(%.1f)，不调整", adjustOffset);
                }
            } else {
                CIMLog(@"[ScrollToBottom] adjustScrollIfContentSizeChanged 已在底部，不需要调整");
            }
            
            strongSelf.isScrollIng = NO;
            strongSelf.pendingImageLoadAdjustBlock = nil;
        });
        
        // 延迟执行防抖任务
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), self.pendingImageLoadAdjustBlock);
    } else {
        CIMLog(@"[ScrollToBottom] adjustScrollIfContentSizeChanged 不需要调整，结束");
        self.isScrollIng = NO;
    }
}


- (void)cimToolMessageDeleteAll:(NSString *)sessionID {
    if ([sessionID isEqualToString:self.sessionID]) {
        //当前会话的消息清空了
        WeakSelf
        dispatch_async(_chatMessageUpdateQueue, ^{
            weakSelf.pageNumber = 1;
            [weakSelf.messageModels removeAllObjects];
            [ZTOOL doInMain:^{
                [weakSelf.baseTableView reloadData];
            }];
        });
    }
}

- (void)cimToolChatMessageUpdate:(NoaIMChatMessageModel *)message {
    WeakSelf
    dispatch_async(_chatMessageUpdateQueue, ^{
        for (int i = 0; i<weakSelf.messageModels.count; i++) {
            NoaMessageModel *msgModel = [weakSelf.messageModels objectAtIndex:i];
            if ([msgModel.message.serviceMsgID isEqualToString:message.serviceMsgID]) {
                NoaMessageModel *updateMessage = [[NoaMessageModel alloc] initWithMessageModel:message];
                [weakSelf.messageModels replaceObjectAtIndex:i withObject:updateMessage];
                //处理消息是否显示时间
                [weakSelf computeVisibleTime];
                [ZTOOL doInMain:^{
                    [weakSelf.baseTableView reloadData];
                }];
            }
        }
    });
}

// 接收 SDK 合并后的编辑消息并替换当前聊天列表中的原消息。
- (void)cimToolEditChatMessageUpdate:(NoaIMChatMessageModel *)message {
    WeakSelf
    dispatch_async(_chatMessageUpdateQueue, ^{
        for (NSInteger index = 0; index < weakSelf.messageModels.count; index++) {
            NoaMessageModel *existing = [weakSelf.messageModels objectAtIndex:index];
            // 编辑通知使用 msgID 查询并更新原消息，因此优先使用 msgID 匹配界面模型。
            BOOL isSameMessageID = existing.message.msgID.length > 0 &&
                                   message.msgID.length > 0 &&
                                   [existing.message.msgID isEqualToString:message.msgID];
            // serviceMsgID 在部分编辑通知中可能为空或与旧模型不一致，仅作为兼容性兜底。
            BOOL isSameServiceMessageID = existing.message.serviceMsgID.length > 0 &&
                                          message.serviceMsgID.length > 0 &&
                                          [existing.message.serviceMsgID isEqualToString:message.serviceMsgID];
            if (!isSameMessageID && !isSameServiceMessageID) {
                continue;
            }
            NoaMessageModel *updated = [[NoaMessageModel alloc] initWithEditMessageModel:message];
            [weakSelf.messageModels replaceObjectAtIndex:index withObject:updated];
            if ([weakSelf.viewInput.messageModelReference.message.msgID isEqualToString:message.msgID]) {
                weakSelf.viewInput.messageModelReference = updated;
            }
            [ZTOOL doInMain:^{
                // 编辑不改变发送时间，因此无需重新计算整组时间间隔。
                [weakSelf.baseTableView reloadData];
            }];
            break;
        }
    });
}

#pragma mark - CIMToolUserDelegate
- (void)imsdkSynUserAllTranslateConfig:(NSArray <LingIMTranslateConfigModel *> *)configInfoArr {
    if (configInfoArr.count > 0) {
        __weak typeof(self) weakSelf = self;
        [configInfoArr enumerateObjectsUsingBlock:^(LingIMTranslateConfigModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([weakSelf.sessionID isEqualToString:obj.dialogId]) {
                _sessionModel.isSendAutoTranslate = obj.translateSwitch;
                _sessionModel.sendTranslateChannel = obj.channel;
                _sessionModel.sendTranslateChannelName = obj.channelName;
                _sessionModel.sendTranslateLanguage = obj.targetLang;
                _sessionModel.sendTranslateLanguageName = obj.targetLangName;
                _sessionModel.translateConfigId = obj.configId;
                //更新到本地
                [DBTOOL insertOrUpdateSessionModelWith:_sessionModel];
            }
        }];
    }
}

/// 其他登录端更新了翻译配置信息
- (void)imsdkUserUpdateTranslateConfigInfo:(UserTranslateConfigUploadMessage *)translateConfig {
    if (![translateConfig.dialogId isEqualToString:@"0"]) {
        //如果是当前会话翻译配置信息发生修改同步
        if ([_sessionModel.sessionID isEqualToString:translateConfig.dialogId]) {
            _sessionModel.isSendAutoTranslate = translateConfig.translateSwitch;
            _sessionModel.sendTranslateChannel = translateConfig.channel;
            _sessionModel.sendTranslateChannelName = translateConfig.channelName;
            _sessionModel.sendTranslateLanguage = translateConfig.targetLang;
            _sessionModel.sendTranslateLanguageName = translateConfig.targetLangName;
            _sessionModel.isReceiveAutoTranslate = translateConfig.receiveTranslateSwitch;
            _sessionModel.receiveTranslateChannel = translateConfig.receiveChannel;
            _sessionModel.receiveTranslateChannelName = translateConfig.receiveChannelName;
            _sessionModel.receiveTranslateLanguage = translateConfig.receiveTargetLang;
            _sessionModel.receiveTranslateLanguageName = translateConfig.receiveTargetLangName;
            _sessionModel.translateConfigId = [NSString stringWithFormat:@"%lld", translateConfig.id_p];
            
            [self.viewInput configTranslateBtnStatus:_sessionModel.isSendAutoTranslate];
            
            //更新到本地
            [DBTOOL insertOrUpdateSessionModelWith:_sessionModel];
        }
    }
}

- (void)imSdkUserCloseAutoTranslateAndErrorCode:(NSInteger)errorCode errorMsg:(NSString *)errorMsg sessionModel:(LingIMSessionModel *)sessionModel {
    _sessionModel = [IMSDKManager toolCheckMySessionWith:self.sessionID];
}

#pragma mark - 仅仅是分割线
- (void)dismissTipAlertView {
    if (_groupAlertView) {
        [_groupAlertView alertDismiss];
        _groupAlertView = nil;
    };
}

//显示群提升信息的弹窗
- (void)showTipAlertView:(NSString *)content btnName:(NSString *)btnName isNeedDelete:(BOOL)isNeedDelete {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 统一检查是否已有弹窗显示，避免重复弹窗
        if (self.groupAlertView != nil && self.groupAlertView.isShow) {
            NSLog(@"已有弹窗显示，忽略新的弹窗请求: %@", content);
            return;
        }
        
        // 先关闭可能存在的旧弹窗
        [self dismissTipAlertView];
        
        // 创建新的弹窗
        self.groupAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeNomal supView:nil];
        self.groupAlertView.lblContent.text = content;
        self.groupAlertView.lblContent.textAlignment = NSTextAlignmentCenter;
        self.groupAlertView.btnCancel.hidden = YES;
        [self.groupAlertView.btnSure setTitle:btnName forState:UIControlStateNormal];
        [self.groupAlertView.btnSure setTkThemeTitleColor:@[COLORWHITE, COLORWHITE_DARK] forState:UIControlStateNormal];
        self.groupAlertView.btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2];
        [self.groupAlertView.btnSure mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.groupAlertView);
        }];
        [self.groupAlertView alertShow];
        
        // 使用 WeakSelf 避免循环引用，并在 block 中安全地处理弹窗
        WeakSelf
        self.groupAlertView.sureBtnBlock = ^(BOOL isCheckBox) {
            // 保存需要执行的操作
            BOOL shouldDelete = isNeedDelete;
            
            // 先清理弹窗引用，避免循环引用
            if (weakSelf.groupAlertView) {
                weakSelf.groupAlertView = nil;
            }
            
            // 执行相应的操作
            if (shouldDelete) {
                [weakSelf deleteSessionAndChatMessage];
            } else {
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        };
    });
}

//删除会话 + 清空聊天内容
- (void)deleteSessionAndChatMessage {
    LingIMSessionModel *model = [IMSDKManager toolCheckMySessionWith:self.groupInfo.groupId];
    if (model) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:model.sessionID forKey:@"peerUid"];
        [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
        if (model.sessionType == CIMSessionTypeSingle) {
            //单聊
            [dict setValue:@(0) forKey:@"dialogType"];
        }else {
            //群聊
            [dict setValue:@(1) forKey:@"dialogType"];
        }
        __weak typeof(self) weakSelf = self;

        //删除会话
        [[NoaIMSDKManager sharedTool] deleteServerConversation:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            //删除本地聊天记录 删除本地会话
            [IMSDKManager toolDeleteSessionModelWith:model andDeleteAllChatModel:YES];
            //清除缓存
            [NoaMessageTools clearChatLocalImgAndVideoFromSessionId:self.sessionID];
            if (self->_chatType == CIMChatType_SingleChat) {
                //删除好友
                [IMSDKManager toolDeleteMyFriendWith:self.sessionID];
            } else if (self->_chatType == CIMChatType_GroupChat) {
                //删除群组
                [IMSDKManager toolDeleteMyGroupWith:self.sessionID];
            }
            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            [HUD showMessageWithCode:code errorMsg:msg];
        }];

    }
}

- (void)reviceMessageSortMessagListWithSendTime {
    WeakSelf
    if (self.pendingSortBlock) {
        dispatch_block_cancel(self.pendingSortBlock);
        self.pendingSortBlock = nil;
    }
    dispatch_block_t block = dispatch_block_create(0, ^{
        dispatch_async(self->_chatMessageUpdateQueue, ^{
            NSArray *sortResultArr = [NSMutableArray sortMultiSelectedMessageArr:[weakSelf.messageModels.safeArray mutableCopy]];
            [weakSelf.messageModels replaceAllObjectsWithArray:sortResultArr];
            // 排序后重算日期条，保证与列表顺序一致
            [weakSelf computeVisibleTime];
            [weakSelf debounceChatReload];
        });
    });
    self.pendingSortBlock = block;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.08 * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}

#pragma mark - 刷新/排序防抖
- (void)debounceChatReload {
    WeakSelf
    if (self.pendingChatReloadBlock) {
        dispatch_block_cancel(self.pendingChatReloadBlock);
        self.pendingChatReloadBlock = nil;
    }
    dispatch_block_t block = dispatch_block_create(0, ^{
        [UIView performWithoutAnimation:^{
            [weakSelf.baseTableView reloadData];
        }];
    });
    self.pendingChatReloadBlock = block;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.08 * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}

//撤回或者删除了某条消息，并处理引用这条消息的消息里被引用消息展示状态
- (void)updateDeleteMessageAndRefreshMsgWithOriginalMsg:(NSString *)originalMsgId {
    WeakSelf
    dispatch_async(_chatMessageUpdateQueue, ^{
        for (int i = 0; i<weakSelf.messageModels.count; i++) {
            NoaMessageModel *tempMessageModel = [weakSelf.messageModels objectAtIndex:i];
            if ([originalMsgId isEqualToString:tempMessageModel.message.serviceMsgID]) {
                //UI层删除被撤回的消息
                [weakSelf.messageModels removeObject:tempMessageModel];
            }
            if (tempMessageModel.message.referenceMsgId != nil && [tempMessageModel.message.referenceMsgId isEqualToString:originalMsgId]) {
                NoaMessageModel *refreshMsg = [[NoaMessageModel alloc] initWithMessageModel:tempMessageModel.message];
                [weakSelf.messageModels replaceObjectAtIndex:i withObject:refreshMsg];
            }
        }
        //处理消息是否显示时间
        [weakSelf computeVisibleTime];
        [ZTOOL doInMain:^{
            [weakSelf.baseTableView reloadData];
        }];
    });
}

//当撤回或者删除了某条消息，那引用这条消息的消息里也要改变被引用消息展示状态
- (void)updateRefreshMsgWithOriginalMsg:(NSString *)originalMsgId {
    WeakSelf
    dispatch_async(_chatMessageUpdateQueue, ^{
        for (int i = 0; i<weakSelf.messageModels.count; i++) {
            NoaMessageModel *msgModel = [weakSelf.messageModels objectAtIndex:i];
            if (msgModel.message.referenceMsgId != nil && [msgModel.message.referenceMsgId isEqualToString:originalMsgId]) {
                NoaMessageModel *refreshMsg = [[NoaMessageModel alloc] initWithMessageModel:msgModel.message];
                [weakSelf.messageModels replaceObjectAtIndex:i withObject:refreshMsg];
                //处理消息是否显示时间
                [weakSelf computeVisibleTime];
                [ZTOOL doInMain:^{
                    [weakSelf.baseTableView reloadData];
                }];
            }
        }
    });
}

#pragma mark - UITableViewDelegate  UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageModels.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaMessageModel *model = [self.messageModels objectAtIndex:indexPath.row];
    return model.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // 不再使用 section header，改用 contentInset
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.messageModels.count) {
        NoaMessageBaseCell *cell = [NoaMessageBaseCell new];
        NoaMessageModel *model = [self.messageModels objectAtIndex:indexPath.row];
        model.isShowSelectBox = self.multiSelectStatus;
        model.isActivityLevel = self.groupInfo.isActiveEnabled;
        model.userGroupRole = self.groupInfo.userGroupRole;
        //cell
        switch (model.message.messageType) {
            case CIMChatMessageType_TextMessage:    //文本消息
            {
                //文本消息
                if (![NSString isNil:model.message.referenceMsgId]) {
                    //引用类文本消息
                    cell = [tableView dequeueReusableCellWithIdentifier:@"referenceTextCell"];
                    if (cell == nil) {
                        cell = [[NoaMessageReferenceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"referenceTextCell"];
                    }
                } else {
                    //纯文本消息
                    cell = [tableView dequeueReusableCellWithIdentifier:@"textCell"];
                    if (cell == nil) {
                        cell = [[NoaMessageTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"textCell"];
                    }
                }
                cell.delegate = self;
                cell.sessionId = self.sessionID;
                [cell setConfigMessage:model];
            }
                break;
            case CIMChatMessageType_ImageMessage:   //图片消息
            {
                //图片消息
                cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell"];
                if (cell == nil) {
                    cell = [[NoaMessageImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"imageCell"];
                }
                cell.delegate = self;
                cell.sessionId = self.sessionID;
                [cell setConfigMessage:model];
            }
                break;
            case CIMChatMessageType_StickersMessage:   //表情消息
            {
                //表情消息
                cell = [tableView dequeueReusableCellWithIdentifier:@"stickerCell"];
                if (cell == nil) {
                    cell = [[NoaMessageStickersCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"stickerCell"];
                }
                cell.delegate = self;
                cell.sessionId = self.sessionID;
                [cell setConfigMessage:model];
            }
                break;
            case CIMChatMessageType_VideoMessage:   //视频消息
            {
                //视频消息
                cell = [tableView dequeueReusableCellWithIdentifier:@"videoCell"];
                if (cell == nil) {
                    cell = [[NoaMessageVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"videoCell"];
                }
                cell.delegate = self;
                cell.sessionId = self.sessionID;
                [cell setConfigMessage:model];
            }
                break;
            case CIMChatMessageType_AtMessage:   //At消息
            {
                if (![NSString isNil:model.message.referenceMsgId]) {
                    //引用消息 + At
                    cell = [tableView dequeueReusableCellWithIdentifier:@"referenceTextCell"];
                    if (cell == nil) {
                        cell = [[NoaMessageReferenceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"referenceTextCell"];
                    }
                } else {
                    //At消息
                    cell = [tableView dequeueReusableCellWithIdentifier:@"AtUsetCell"];
                    if (cell == nil) {
                        cell = [[NoaMessageAtUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AtUsetCell"];
                    }
                }
                cell.delegate = self;
                cell.sessionId = self.sessionID;
                [cell setConfigMessage:model];
            }
                break;
            case CIMChatMessageType_FileMessage:   //文件消息
            {
                //文件消息
                NoaMessageFileCell *fileCell = [tableView dequeueReusableCellWithIdentifier:[NoaMessageFileCell cellIdentifier]];
                if (fileCell == nil) {
                    fileCell = [[NoaMessageFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NoaMessageFileCell cellIdentifier]];
                }
                fileCell.delegate = self;
                fileCell.sessionId = self.sessionID;
                [fileCell setConfigMessage:model];
                cell = fileCell;
            }
                break;
            case CIMChatMessageType_VoiceMessage:   //音频消息
            {
                //音频消息
                cell = [tableView dequeueReusableCellWithIdentifier:@"voiceCell"];
                if (cell == nil) {
                    cell = [[NoaMessageVoiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"voiceCell"];
                }
                cell.delegate = self;
                cell.sessionId = self.sessionID;
                [cell setConfigMessage:model];
            }
                break;
            case CIMChatMessageType_CardMessage:    //名片消息
            {
                //名片消息
                cell = [tableView dequeueReusableCellWithIdentifier:@"nameCardCell"];
                if (cell == nil) {
                    cell = [[NoaMessageCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"nameCardCell"];
                }
                cell.delegate = self;
                cell.sessionId = self.sessionID;
                [cell setConfigMessage:model];
            }
                break;
            case CIMChatMessageType_GeoMessage:    //地理位置消息
            {
                //地理位置消息
                cell = [tableView dequeueReusableCellWithIdentifier:@"geoLocationCell"];
                if (cell == nil) {
                    cell = [[NoaMessageGeoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"geoLocationCell"];
                }
                cell.delegate = self;
                cell.sessionId = self.sessionID;
                [cell setConfigMessage:model];
            }
                break;
            case CIMChatMessageType_GroupNotice:   //群公告消息
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"groupNoticeCell"];
                if (!cell) {
                    cell = [[NoaMessageGroupNoticeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"groupNoticeCell"];
                }
                cell.delegate = self;
                cell.sessionId = self.sessionID;
                [cell setConfigMessage:model];
            }
                break;
            case CIMChatMessageType_ForwardMessage:    //合并转发的消息记录
            {
                //合并转发的消息记录
                cell = [tableView dequeueReusableCellWithIdentifier:@"NoaMergeMessageRecordCell"];
                if (cell == nil) {
                    cell = [[NoaMergeMessageRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NoaMergeMessageRecordCell"];
                }
                cell.delegate = self;
                cell.sessionId = self.sessionID;
                [cell setConfigMessage:model];
            }
                break;
            case CIMChatMessageType_NetCallMessage://即构 音视频通话
            {
                //音视频通话操作提示消息
                cell = [tableView dequeueReusableCellWithIdentifier:@"mediaCallCell"];
                if (cell == nil) {
                    cell = [[NoaMessageCallCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mediaCallCell"];
                }
                cell.delegate = self;
                cell.sessionId = self.sessionID;
                [cell setConfigMessage:model];
            }
                break;
            case CIMChatMessageType_GameStickersMessage:   //游戏表情消息
            {
                //游戏表情消息
                cell = [tableView dequeueReusableCellWithIdentifier:@"gameStickerCell"];
                if (cell == nil) {
                    cell = [[NoaMessageGameStickersCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"gameStickerCell"];
                }
                cell.delegate = self;
                cell.sessionId = self.sessionID;
                [cell setConfigMessage:model];
            }
                break;
            case CIMChatMessageType_BackMessage:    //撤回提示消息
            case CIMChatMessageType_ServerMessage:  //系统通知类消息
            {
                //音视频通话操作提示消息
                IMServerMessage *serverMessage = model.message.serverMessage;
                CustomEvent *customEvent = serverMessage.customEvent;
                if (customEvent.type == 101 || customEvent.type == 103) {
                    //音视频通话操作提示消息
                    cell = [tableView dequeueReusableCellWithIdentifier:@"mediaCallCell"];
                    if (cell == nil) {
                        cell = [[NoaMessageCallCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mediaCallCell"];
                    }
                    cell.delegate = self;
                    cell.sessionId = self.sessionID;
                    [cell setConfigMessage:model];
                    break;
                }
                
                //其他系统通知类型消息展示
                cell = [tableView dequeueReusableCellWithIdentifier:@"systemTipsCell"];
                if (cell == nil) {
                    cell = [[NoaMessageSystemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"systemTipsCell"];
                }
                cell.delegate = self;
                cell.sessionId = self.sessionID;
                [cell setConfigMessage:model];
            }
                break;
            default:
                break;
        }
        cell.cellIndex = indexPath;
        return cell;
    } else {
        return [UITableViewCell new];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[YYLabel class]]) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 滑动聊天消息时收起键盘
    [self hideKeyBoardAndEmjoy];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat height = scrollView.frame.size.height;
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    CGFloat bottomOffset = scrollView.contentSize.height - contentOffsetY;
    if (bottomOffset <= (height + DWScale(100))) {
        //在最底部
        _btnBottom.hidden = YES;
    } else {
        _btnBottom.hidden = NO;
    }
    [self checkChatViewUnreadedMessage];
}

#pragma mark - 检查当前聊天页面展示的可见的消息中是否有未读消息，如果有就存起来，2秒后上传消息已读
- (void)checkChatViewUnreadedMessage {
    NSArray *indexPathArr = [self.baseTableView indexPathsForVisibleRows];
    if (indexPathArr.count > 0 && self.messageModels.count > 0) {
        NSIndexPath *firstIndexPath = [indexPathArr firstObject];
        if ((firstIndexPath.row + indexPathArr.count - 1) > (self.messageModels.count - 1)) {
            return;
        }
        NSRange range = NSMakeRange(firstIndexPath.row, indexPathArr.count);
        if((range.location + range.length) <= self.messageModels.count){
            NSArray *indexMessageArr = [[self.messageModels.safeArray subarrayWithRange:range] copy];
            [self checkHistoryListForUnreadMessage:indexMessageArr];
        }
    }
}

#pragma mark - 列表滚动到最底部
- (void)btnBottomClick {
    //列表滚动到最底部
    _btnBottom.hidden = YES;
    [self tableViewScrollToBottom:YES duration:0.25];
}

#pragma mark - 消息已读
- (void)checkHistoryListForUnreadMessage:(NSArray *)historyList {
    if (historyList.count > 0) {
        WeakSelf
        [historyList enumerateObjectsUsingBlock:^(NoaMessageModel * _Nonnull chatMessage, NSUInteger idx, BOOL * _Nonnull stop) {
            StrongSelf
            if (!chatMessage.message.chatMessageReaded && ![chatMessage.message.fromID isEqualToString:UserManager.userInfo.userUID]) {
                //别人发送的，我未读的 消息
                switch (chatMessage.message.messageType) {
                    case CIMChatMessageType_TextMessage:
                    case CIMChatMessageType_ImageMessage:
                    case CIMChatMessageType_FileMessage:
                    case CIMChatMessageType_VideoMessage:
                    case CIMChatMessageType_AtMessage:
                    case CIMChatMessageType_GroupNotice:
                    case CIMChatMessageType_CardMessage:
                    case CIMChatMessageType_GeoMessage:
                    case CIMChatMessageType_ForwardMessage:
                    case CIMChatMessageType_StickersMessage:
                    case CIMChatMessageType_GameStickersMessage:
                    {
                        //消息未读并且为被加入待上传已读的数组里
                        NSString *sMsgIdAndSendUid = [NSString stringWithFormat:@"%@_%@_%@", chatMessage.message.serviceMsgID, chatMessage.message.fromID, chatMessage.message.msgID];
                        if (![strongSelf.unReadSmsgidList containsObject:sMsgIdAndSendUid]) {
                            [strongSelf.unReadSmsgidList addObject:sMsgIdAndSendUid];
                        }
                    }
                        break;
                    default:
                        break;
                }
            }
        }];
    }
}
//判断自己发送的消息是否过了允许撤回的时效(是否可以撤回)
- (BOOL)mySendMessageHasAbleRevoke:(long long)msgSendTime {
    if ([ZHostTool.appSysSetModel.messageRecallTime intValue] <= 0) {
        return NO;
    } else {
        BOOL result = YES;
        //当前时间戳：秒
        //不允许撤回的失效时间戳
        long long intervalSeond = [ZHostTool.appSysSetModel.messageRecallTime intValue] * 60;
        long long expireTimeSecond = (msgSendTime/1000) + intervalSeond;
        //当前时间戳
        long long nowTimeSecond = [NSDate currentTimeIntervalWithSecond];
        //比较
        if (nowTimeSecond <= expireTimeSecond) {
            result = YES;
        } else {
            result = NO;
        }
        return result;
    }
}

#pragma mark - ZMessageBaseCellDelegate 消息Cell交互代理
//点击用户头像
- (void)userAvatarClick:(NSString *)userId role:(NSInteger)role {
    //多选状态不能跳转
    if (self.multiSelectStatus) return;
    
    if (_chatType == CIMChatType_SingleChat) {
        NoaUserHomePageVC *vc = [NoaUserHomePageVC new];
        vc.userUID = userId;
        vc.groupID = @"";
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (_chatType == CIMChatType_GroupChat) {
        //防止获取群信息接口失败，可以进行用户头像点击跳转
        if (!_groupInfo) return;
        //机器人
        if (role == 3) return;
        if ([UserManager.userRoleAuthInfo.groupSecurity.configValue isEqualToString:@"true"]) {
            NoaUserHomePageVC *vc = [NoaUserHomePageVC new];
            vc.userUID = userId;
            vc.groupID = self.groupInfo.groupId;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            //群开启了群内禁止私聊，普通群成员不可以点击用户头像跳转
            if (_groupInfo.isPrivateChat && _groupInfo.userGroupRole == 0) return;
            
            NoaUserHomePageVC *vc = [NoaUserHomePageVC new];
            vc.userUID = userId;
            vc.groupID = self.groupInfo.groupId;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

//长按用户头像 At 用户
- (void)userAvatarLongTapClick:(NSString *)userId nickname:(NSString *)nickname role:(NSInteger)role {
    //群聊
    if (self.chatType == CIMChatType_GroupChat) {
        //忽略机器人
        if (role == 3) return;
        //长按的不是自己的头像
        if (![userId isEqualToString:UserManager.userInfo.userUID]) {
            NSDictionary *atUser = @{
                [NSString stringWithFormat:@"%@",userId] : [NSString stringWithFormat:@"%@",nickname]
            };
            [self.viewInput inputViewInsertAtUserInfo:atUser];
        }
    }
}

- (void)userAvatarLongTapClickAtAndBanned:(NSString *)userId nickname:(NSString *)nickname role:(NSInteger)role cellIndex:(nonnull NSIndexPath *)cellIndex{
    self.atBannedView.userName = nickname;
    NoaMessageBaseCell *avatarLongTapCell = [self.baseTableView cellForRowAtIndexPath:cellIndex];
    CGRect targetRect = [self.baseTableView convertRect:avatarLongTapCell.frame toView:self.view];
    [self.atBannedView showWithTargetRect:targetRect];
    __weak typeof(self) weakSelf = self;
    [self.atBannedView setAtCallback:^{
        //群聊
        if (self.chatType == CIMChatType_GroupChat) {
            //忽略机器人
            if (role == 3) return;
            //长按的不是自己的头像
            if (![userId isEqualToString:UserManager.userInfo.userUID]) {
                NSDictionary *atUser = @{
                    [NSString stringWithFormat:@"%@",userId] : [NSString stringWithFormat:@"%@",nickname]
                };
                [weakSelf.viewInput inputViewInsertAtUserInfo:atUser];
            }
        }
    }];
    [self.atBannedView setBannedCallback:^{
        NoaMessageAlertView *msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeTitle supView:nil];
        msgAlertView.lblTitle.text = LanguageToolMatch(@"是否永久禁言当前用户？");
        msgAlertView.lblTitle.font = FONTB(18);
        msgAlertView.lblTitle.textAlignment = NSTextAlignmentCenter;
        msgAlertView.lblContent.text = @"";
        msgAlertView.lblContent.font = FONTN(14);
        msgAlertView.lblContent.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        msgAlertView.lblContent.textAlignment = NSTextAlignmentCenter;
        [msgAlertView.btnSure setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
        [msgAlertView.btnSure setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
        msgAlertView.btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
        [msgAlertView.btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
        [msgAlertView.btnCancel setTkThemeTitleColor:@[COLOR_66, COLOR_66_DARK] forState:UIControlStateNormal];
        msgAlertView.btnCancel.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F6F6F6_DARK];
        msgAlertView.isSizeDivide = YES;
        [msgAlertView alertShow];
        msgAlertView.sureBtnBlock = ^(BOOL isCheckBox) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObjectSafe:@"-1" forKey:@"expireTime"];
            [dict setObjectSafe:@[userId] forKey:@"forbidUidList"];
            [dict setObjectSafe:weakSelf.sessionID forKey:@"groupId"];
            [dict setObjectSafe:@"1" forKey:@"operationType"];
            if (![NSString isNil:UserManager.userInfo.userUID]) {
                [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
            }
            [IMSDKManager groupSetNotalkMemberWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                if (data) {
                    [HUD showMessage:LanguageToolMatch(@"操作成功") inView:weakSelf.view];
                }
            } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                [HUD showMessageWithCode:code errorMsg:msg inView:weakSelf.view];
            }];
        };
    }];
    
    [self.atBannedView setCleanUserMessageCallback:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) {
            return;
        }
        NoaMessageAlertView *msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeTitle supView:nil];
        msgAlertView.lblTitle.text = LanguageToolMatch(@"清空用户消息");
        msgAlertView.lblTitle.font = FONTB(18);
        msgAlertView.lblTitle.textAlignment = NSTextAlignmentCenter;
        msgAlertView.lblContent.text = [NSString stringWithFormat:LanguageToolMatch(@"此操作将永久删除用户“%@”在本群内的所有发言记录，且所有群成员都将无法查看"), self.atBannedView.userName];
        msgAlertView.lblContent.font = FONTN(14);
        msgAlertView.lblContent.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        msgAlertView.lblContent.textAlignment = NSTextAlignmentCenter;
        [msgAlertView.btnSure setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
        [msgAlertView.btnSure setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
        msgAlertView.btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
        [msgAlertView.btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
        [msgAlertView.btnCancel setTkThemeTitleColor:@[COLOR_66, COLOR_66_DARK] forState:UIControlStateNormal];
        msgAlertView.btnCancel.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F6F6F6_DARK];
        msgAlertView.isSizeDivide = YES;
        [msgAlertView alertShow];
        msgAlertView.sureBtnBlock = ^(BOOL isCheckBox) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObjectSafe:@[userId] forKey:@"targetUidList"];
            [dict setObjectSafe:weakSelf.sessionID forKey:@"groupId"];
            if (![NSString isNil:UserManager.userInfo.userUID]) {
                [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
            }
            [IMSDKManager groupDeleteMemberHistoryMessageWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                if (data) {
                    [HUD showMessage:LanguageToolMatch(@"操作成功") inView:weakSelf.view];
                    [weakSelf refreshMessageListAfterDeleteMemberHistHistory:@[userId]];
                }
            } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                [HUD showMessageWithCode:code errorMsg:msg inView:weakSelf.view];
            }];
        };
    }];
}

- (void)refreshMessageListAfterDeleteMemberHistHistory:(NSArray *)memberUidList {
    NSSet<NSString *> *memberUidSet = [NSSet setWithArray:memberUidList];
    NSPredicate *keepPredicate = [NSPredicate predicateWithBlock:^BOOL(NoaMessageModel *messageModel, NSDictionary *bindings) {
        return ![memberUidSet containsObject:messageModel.message.fromID];
    }];
    [self.messageModels filterUsingPredicate:keepPredicate];
    [self.baseTableView reloadData];
}

//图片或视频的浏览
- (void)messageCellBrowserImageAndVideo:(NoaIMChatMessageModel *)messageModel {
    if (self.multiSelectStatus) {
        return;
    }
    [self.viewInput inputViewResignFirstResponder];
    [self imageVideoBrowserWith:messageModel];
}

#pragma mark - UITableViewDelegate (GIF 播放控制)
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[NoaMessageImageCell class]]) {
        SEL sel = NSSelectorFromString(@"startGifPlayback");
        if ([cell respondsToSelector:sel]) {
            ((void (*)(id, SEL))objc_msgSend)(cell, sel);
        }
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[NoaMessageImageCell class]]) {
        SEL sel = NSSelectorFromString(@"stopGifPlayback");
        if ([cell respondsToSelector:sel]) {
            ((void (*)(id, SEL))objc_msgSend)(cell, sel);
        }
    }
}

//长按消息 菜单弹窗
- (void)messageCellLongTapWithIndex:(NSIndexPath *)cellIndex {
    if (self.multiSelectStatus) {
        return;
    }
    // 打开其他消息菜单前结束上一次编辑，防止输入框仍指向旧消息。
    if (self.viewInput.isEditMode) {
        [self exitEditMode];
    }
    //弹出菜单弹窗时，需要先调用一下输入框隐藏键盘的方法
    NoaMessageBaseCell *longTapCell = [self.baseTableView cellForRowAtIndexPath:cellIndex];
    NoaMessageModel *longTapModel = [self.messageModels objectAtIndex:cellIndex.row];
    //配置弹窗里的菜单选项
    NSMutableArray *menuArr = [NSMutableArray array];
    if (longTapModel.message.messageSendType == CIMChatMessageSendTypeFail || longTapModel.message.messageSendType == CIMChatMessageSendTypeSending  || longTapModel.message.messageType == CIMChatMessageType_NetCallMessage) {
        //发送失败或者发送中的消息，只能存在”复制或者删除“操作
        if (longTapModel.message.messageType == CIMChatMessageType_TextMessage || longTapModel.message.messageType == CIMChatMessageType_AtMessage) {
            //文字消息、 @消息（复制、删除）
            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopy]];
            if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
            }
        } else if (longTapModel.message.messageType == CIMChatMessageType_ImageMessage || longTapModel.message.messageType == CIMChatMessageType_VideoMessage || longTapModel.message.messageType == CIMChatMessageType_VoiceMessage || longTapModel.message.messageType == CIMChatMessageType_FileMessage || longTapModel.message.messageType == CIMChatMessageType_CardMessage || longTapModel.message.messageType == CIMChatMessageType_GeoMessage || longTapModel.message.messageType == CIMChatMessageType_ForwardMessage || longTapModel.message.messageType == CIMChatMessageType_StickersMessage || longTapModel.message.messageType == CIMChatMessageType_GameStickersMessage || longTapModel.message.messageType == CIMChatMessageType_NetCallMessage) {
            //图片/视频/音频/文件/名片/表情/游戏表情 消息（删除）
            if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
            } else {
                return;
            }
        }
    } else {
        //我在本群的角色(0普通成员;1管理员;2群主)
        if (self.chatType == CIMChatType_GroupChat) {   //群聊
            if (longTapModel.isSelf) {
                //文字消息、 @消息（复制、转发、删除、撤回、引用）
                if (longTapModel.message.messageType == CIMChatMessageType_TextMessage || longTapModel.message.messageType == CIMChatMessageType_AtMessage) {
                    if (longTapModel.message.messageType == CIMChatMessageType_TextMessage) {
                        if (![NSString isNil:longTapModel.message.translateContent] && longTapModel.message.translateStatus == CIMTranslateStatusSuccess && ![longTapModel.message.textContent isEqualToString:longTapModel.message.translateContent]) {
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopyContent]];
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopyTranslate]];
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                            if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                            }
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeRevoke]];
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                        } else {
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopy]];
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                            if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                            }
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeRevoke]];
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                        }
                    }
                    if (longTapModel.message.messageType == CIMChatMessageType_AtMessage) {
                        if (![NSString isNil:longTapModel.message.atTranslateContent] && longTapModel.message.translateStatus == CIMTranslateStatusSuccess && ![longTapModel.message.atContent isEqualToString:longTapModel.message.atTranslateContent]) {
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopyContent]];
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopyTranslate]];
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                            if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                            }
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeRevoke]];
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                        } else {
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopy]];
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                            if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                            }
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeRevoke]];
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                        }
                    }
                } else if (longTapModel.message.messageType == CIMChatMessageType_ImageMessage || longTapModel.message.messageType == CIMChatMessageType_VideoMessage || longTapModel.message.messageType == CIMChatMessageType_FileMessage || longTapModel.message.messageType == CIMChatMessageType_GeoMessage || longTapModel.message.messageType == CIMChatMessageType_ForwardMessage) {
                    //图片/视频/文件消息（转发、删除、撤回、引用）
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                    if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                    }
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeRevoke]];
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                } else if (longTapModel.message.messageType == CIMChatMessageType_VoiceMessage) {
                    //语音消息（转发、听筒播放、删除、撤回、引用）
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeMutePlayback]];
                    if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                    }
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeRevoke]];
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
    
                } else if (longTapModel.message.messageType == CIMChatMessageType_CardMessage) {
                    //名片消息（删除、引用）
                    if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                    }
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeRevoke]];
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                } else if (longTapModel.message.messageType == CIMChatMessageType_StickersMessage) {
                    //表情消息（删除、撤回、引用）
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeStickersAdd]];
                    if (longTapModel.message.isStickersSet) {
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeStickersPackage]];
                    }
                    if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                    }
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeRevoke]];
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                } else if (longTapModel.message.messageType == CIMChatMessageType_GameStickersMessage) {
                    //游戏表情消息（删除、引用）
                    if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                    }
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeRevoke]];
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                } else {
                    return;
                }
                //检查是否过了可撤回的时间间隔
                if ([self mySendMessageHasAbleRevoke:longTapModel.message.sendTime] == NO && self.groupInfo.userGroupRole == 0) {
                    //不可以撤回了
                    [menuArr removeObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeRevoke]];
                }
            } else {
                //1管理员;2群主
                if (self.groupInfo.userGroupRole == 2 || self.groupInfo.userGroupRole == 1) {
                    //文字消息、 @消息（复制、转发、删除、引用）
                    if (longTapModel.message.messageType == CIMChatMessageType_TextMessage || longTapModel.message.messageType == CIMChatMessageType_AtMessage) {
                        if (longTapModel.message.messageType == CIMChatMessageType_TextMessage) {
                            if (longTapModel.message.translateStatus == CIMTranslateStatusSuccess && ![NSString isNil:longTapModel.message.againTranslateContent]) {
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopyContent]];
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopyTranslate]];
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                                if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                                }
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                            } else {
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopy]];
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                                if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                                }
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                            }
                        }
                        if (longTapModel.message.messageType == CIMChatMessageType_AtMessage) {
                            if (longTapModel.message.translateStatus == CIMTranslateStatusSuccess && ![NSString isNil:longTapModel.message.againAtTranslateContent]) {
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopyContent]];
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopyTranslate]];
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                                if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                                }
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                            } else {
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopy]];
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                                if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                                }
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                            }
                        }
                    } else if (longTapModel.message.messageType == CIMChatMessageType_ImageMessage || longTapModel.message.messageType == CIMChatMessageType_VideoMessage || longTapModel.message.messageType == CIMChatMessageType_FileMessage || longTapModel.message.messageType == CIMChatMessageType_GeoMessage || longTapModel.message.messageType == CIMChatMessageType_ForwardMessage) {
                        //图片/视频/文件消息（转发、删除、引用）
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                        if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                        }
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                    } else if (longTapModel.message.messageType == CIMChatMessageType_VoiceMessage) {
                        //语音消息（转发、听筒播放、删除、引用）
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeMutePlayback]];
                        if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                        }
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                    } else if (longTapModel.message.messageType == CIMChatMessageType_CardMessage) {
                        //名片消息 (删除、引用）
                        if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                        }
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                    } else if (longTapModel.message.messageType == CIMChatMessageType_StickersMessage) {
                        //表情消息（转发、删除、引用）
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeStickersAdd]];
                        if (longTapModel.message.isStickersSet) {
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeStickersPackage]];
                        }
                        if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                        }
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                    } else if (longTapModel.message.messageType == CIMChatMessageType_GameStickersMessage) {
                        //游戏表情消息（删除、引用）
                        if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                        }
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                    } else {
                        return;
                    }
                    if (self.groupInfo.userGroupRole == 2) {
                        //群主(可以撤回任何人的消息)
                        if ([ZHostTool.appSysSetModel.groupMangerMessageRecallTime isEqualToString:@"1"]) {
                            //0关闭，1开启
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeRevoke]];
                        }
                    }
                    if (self.groupInfo.userGroupRole == 1) {
                        //管理员(只能撤回其他普通成员的消息，不能撤回群组和其他管理员发的消息)
                        NSArray *groupOwnerMangerArr = [IMSDKManager imSdkGetGroupOwnerAndManagerWith:self.groupInfo.groupId];
                        NSMutableArray *owerMangerUidArr = [NSMutableArray array];
                        [groupOwnerMangerArr enumerateObjectsUsingBlock:^(LingIMGroupMemberModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            if (![obj.userUid isEqualToString:UserManager.userInfo.userUID]) {
                                [owerMangerUidArr addObject:obj.userUid];
                            }
                        }];
                        if (![owerMangerUidArr containsObject:longTapModel.message.fromID]) {
                            if ([ZHostTool.appSysSetModel.groupMangerMessageRecallTime isEqualToString:@"1"]) {
                                //0关闭，1开启
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeRevoke]];
                            }
                        }
                    }
                } else {//普通群员
                    if (longTapModel.message.messageType == CIMChatMessageType_TextMessage || longTapModel.message.messageType == CIMChatMessageType_AtMessage) {
                        //文字消息、 @消息（复制、转发、引用）
                        if (longTapModel.message.messageType == CIMChatMessageType_TextMessage) {
                            if (longTapModel.message.translateStatus == CIMTranslateStatusSuccess && ![NSString isNil:longTapModel.message.againTranslateContent]) {
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopyContent]];
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopyTranslate]];
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                                if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                                }
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                            } else {
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopy]];
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                                if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                                }
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                            }
                        }
                        if (longTapModel.message.messageType == CIMChatMessageType_AtMessage) {
                            if (longTapModel.message.translateStatus == CIMTranslateStatusSuccess && ![NSString isNil:longTapModel.message.againAtTranslateContent]) {
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopyContent]];
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopyTranslate]];
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                                if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                                }
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                            } else {
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopy]];
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                                if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                                }
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                            }
                        }
                    } else if (longTapModel.message.messageType == CIMChatMessageType_ImageMessage || longTapModel.message.messageType == CIMChatMessageType_VideoMessage || longTapModel.message.messageType == CIMChatMessageType_FileMessage || longTapModel.message.messageType == CIMChatMessageType_GeoMessage || longTapModel.message.messageType == CIMChatMessageType_ForwardMessage) {
                        //图片/文件/视频...消息（转发、删除、引用）
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                        if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                        }
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                    } else if (longTapModel.message.messageType == CIMChatMessageType_VoiceMessage) {
                        //语音消息（转发、听筒播放、删除、引用）
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeMutePlayback]];
                        if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                        }
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                    } else if (longTapModel.message.messageType == CIMChatMessageType_CardMessage) {
                        //名片消息(删除、引用）
                        if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                        }
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                    } else if (longTapModel.message.messageType == CIMChatMessageType_StickersMessage) {
                        //表情消息（转发、删除、引用）
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeStickersAdd]];
                        if (longTapModel.message.isStickersSet) {
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeStickersPackage]];
                        }
                        if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                        }
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                    } else if (longTapModel.message.messageType == CIMChatMessageType_GameStickersMessage) {
                        //游戏表情消息（删除、引用）
                        if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                        }
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                    } else {
                        return;
                    }
                }
            }
        } else {    //单聊
            if (longTapModel.isSelf) {  //该消息是自己发送的
                if (longTapModel.message.messageType == CIMChatMessageType_TextMessage ||longTapModel.message.messageType == CIMChatMessageType_AtMessage) {
                    //文字消息、 @消息（复制、转发、删除、撤回、引用）
                    if (longTapModel.message.messageType == CIMChatMessageType_TextMessage) {
                        if (![NSString isNil:longTapModel.message.translateContent] && longTapModel.message.translateStatus == CIMTranslateStatusSuccess && ![longTapModel.message.textContent isEqualToString:longTapModel.message.translateContent]) {
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopyContent]];
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopyTranslate]];
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                            if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                            }
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeRevoke]];
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                        } else {
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopy]];
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                            if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                            }
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeRevoke]];
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                        }
                    }
                    if (longTapModel.message.messageType == CIMChatMessageType_AtMessage) {
                        if (![NSString isNil:longTapModel.message.atTranslateContent] && longTapModel.message.translateStatus == CIMTranslateStatusSuccess && ![longTapModel.message.atContent isEqualToString:longTapModel.message.atTranslateContent]) {
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopyContent]];
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopyTranslate]];
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                            if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                            }
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeRevoke]];
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                        } else {
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopy]];
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                            if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                            }
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeRevoke]];
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                        }
                    }
                } else if (longTapModel.message.messageType == CIMChatMessageType_ImageMessage || longTapModel.message.messageType == CIMChatMessageType_VideoMessage || longTapModel.message.messageType == CIMChatMessageType_FileMessage || longTapModel.message.messageType == CIMChatMessageType_GeoMessage || longTapModel.message.messageType == CIMChatMessageType_ForwardMessage) {
                    //图片/视频/文件消息（转发、删除、撤回、引用）
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                    if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                    }
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeRevoke]];
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                } else if (longTapModel.message.messageType == CIMChatMessageType_VoiceMessage) {
                    //语音消息（转发、听筒播放、删除、撤回、引用）
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeMutePlayback]];
                    if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                    }
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeRevoke]];
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                } else if (longTapModel.message.messageType == CIMChatMessageType_CardMessage) {
                    //名片消息（删除、引用）
                    if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                    }
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeRevoke]];
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                } else if (longTapModel.message.messageType == CIMChatMessageType_StickersMessage) {
                    //表情消息（转发、删除、撤回、引用）
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeStickersAdd]];
                    if (longTapModel.message.isStickersSet) {
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeStickersPackage]];
                    }
                    if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                    }
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeRevoke]];
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                } else if (longTapModel.message.messageType == CIMChatMessageType_GameStickersMessage) {
                    //游戏表情消息（删除、撤回、引用）
                    if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                    }
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeRevoke]];
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                } else {
                    return;
                }
                //检查是否过来可撤回的时间间隔
                if ([self mySendMessageHasAbleRevoke:longTapModel.message.sendTime] == NO) {
                    //不可以撤回了
                    [menuArr removeObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeRevoke]];
                }
            } else {    //该消息是对方发送的
                if (longTapModel.message.messageType == CIMChatMessageType_TextMessage || longTapModel.message.messageType == CIMChatMessageType_AtMessage) {
                    //文字消息、 @消息（复制、转发、删除、引用）
                    if (longTapModel.message.messageType == CIMChatMessageType_TextMessage) {
                        if (longTapModel.message.translateStatus == CIMTranslateStatusSuccess && ![NSString isNil:longTapModel.message.againTranslateContent]) {
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopyContent]];
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopyTranslate]];
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                            if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                            }
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                        } else {
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopy]];
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                            if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                            }
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                        }
                    }
                    if (longTapModel.message.messageType == CIMChatMessageType_AtMessage) {
                        if (longTapModel.message.translateStatus == CIMTranslateStatusSuccess && ![NSString isNil:longTapModel.message.againAtTranslateContent]) {
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopyContent]];
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopyTranslate]];
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                            if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                            }
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                        } else {
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCopy]];
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                            if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                            }
                            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                        }
                    }
                } else if (longTapModel.message.messageType == CIMChatMessageType_ImageMessage || longTapModel.message.messageType == CIMChatMessageType_VideoMessage || longTapModel.message.messageType == CIMChatMessageType_FileMessage || longTapModel.message.messageType == CIMChatMessageType_GeoMessage || longTapModel.message.messageType == CIMChatMessageType_ForwardMessage) {
                    //图片/视频/文件...消息（转发、删除、引用）
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                    if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                    }
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                } else if (longTapModel.message.messageType == CIMChatMessageType_VoiceMessage) {
                    //语音消息（转发、听筒播放、删除、引用）
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeMutePlayback]];
                    if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                    }
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                } else if (longTapModel.message.messageType == CIMChatMessageType_CardMessage) {
                    //名片消息（删除、引用）
                    if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                    }
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                } else if (longTapModel.message.messageType == CIMChatMessageType_StickersMessage) {
                    //表情消息（转发、删除、撤回、引用）
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeStickersAdd]];
                    if (longTapModel.message.isStickersSet) {
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeStickersPackage]];
                    }
                    if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                    }
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                } else if (longTapModel.message.messageType == CIMChatMessageType_GameStickersMessage) {
                    //游戏表情消息（删除、引用）
                    if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"] || [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                        [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeDelete]];
                    }
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeReference]];
                } else {
                    return;
                }
            }
        }
        //收藏
        if (longTapModel.message.messageType == CIMChatMessageType_TextMessage || longTapModel.message.messageType == CIMChatMessageType_AtMessage || longTapModel.message.messageType == CIMChatMessageType_ImageMessage || longTapModel.message.messageType == CIMChatMessageType_VideoMessage || longTapModel.message.messageType == CIMChatMessageType_FileMessage || longTapModel.message.messageType == CIMChatMessageType_GeoMessage) {
            //文本消息(包括引用消息)、图片消息、视频消息、文件消息、位置信息消息支持 收藏
            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeCollection]];
        }
        //多选
        if (longTapModel.message.messageType == CIMChatMessageType_TextMessage || longTapModel.message.messageType == CIMChatMessageType_AtMessage || longTapModel.message.messageType == CIMChatMessageType_ImageMessage || longTapModel.message.messageType == CIMChatMessageType_VideoMessage || longTapModel.message.messageType == CIMChatMessageType_VoiceMessage ||
            longTapModel.message.messageType == CIMChatMessageType_FileMessage || longTapModel.message.messageType == CIMChatMessageType_GeoMessage || longTapModel.message.messageType == CIMChatMessageType_ForwardMessage || longTapModel.message.messageType == CIMChatMessageType_StickersMessage) {
            //文本消息、图片消息、视频消息、语音消息、文件消息、位置信息消息、表情消息支持多选
            [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeMultiSelect]];
        }
    
        //存为链接（文本消息、引用消息、At消息） 翻译相关
        if (longTapModel.message.messageType == CIMChatMessageType_TextMessage || longTapModel.message.messageType == CIMChatMessageType_AtMessage) {
            //存为链接
            NSArray *urlArr;
            if (longTapModel.message.messageType == CIMChatMessageType_TextMessage) {
                urlArr = [longTapModel.message.textContent getUrlFromString];
            } else if (longTapModel.message.messageType == CIMChatMessageType_AtMessage) {
                urlArr = [longTapModel.message.showContent getUrlFromString];
            }
            if (urlArr.count > 0) {
                [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeAddTag]];
            }
            //翻译相关
            if (longTapModel.message.messageType == CIMChatMessageType_TextMessage) {
                if (longTapModel.message.translateStatus == CIMTranslateStatusSuccess && ![NSString isNil:longTapModel.message.againTranslateContent]) {
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeShowTranslate]];//翻译
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeHiddenTranslate]];//隐藏译文
                } else {
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeShowTranslate]];//翻译
                }
            } else if (longTapModel.message.messageType == CIMChatMessageType_AtMessage) {
                if (longTapModel.message.translateStatus == CIMTranslateStatusSuccess && ![NSString isNil:longTapModel.message.againAtTranslateContent]) {
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeShowTranslate]];//翻译
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeHiddenTranslate]];//隐藏译文
                } else {
                    [menuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeShowTranslate]];//翻译
                }
            }
        }
    }
    
    // 针对转发消息，不提供“转发/多选”菜单项
    if (longTapModel.message.messageType == CIMChatMessageType_ForwardMessage) {
        [menuArr removeObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeForward]];
        [menuArr removeObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeMultiSelect]];
    }

    // 编辑入口统一在菜单构建完成后插入，避免群聊和单聊分支重复维护相同规则。
    if ([self canEditMessage:longTapModel]) {
        NSNumber *editItem = @(MessageMenuItemActionTypeEdit);
        if (![menuArr containsObject:editItem]) {
            NSUInteger revokeIndex = [menuArr indexOfObject:@(MessageMenuItemActionTypeRevoke)];
            NSUInteger referenceIndex = [menuArr indexOfObject:@(MessageMenuItemActionTypeReference)];
            NSUInteger insertIndex = revokeIndex != NSNotFound ? revokeIndex + 1 : referenceIndex;
            if (insertIndex == NSNotFound || insertIndex > menuArr.count) {
                insertIndex = menuArr.count;
            }
            [menuArr insertObject:editItem atIndex:insertIndex];
        }
    }
    
    //计算消息的坐标位置,确定菜单弹窗弹出的位置的坐标
    CGRect targetRect = [self.baseTableView convertRect:longTapCell.frame toView:self.view];
    if (longTapModel.isSelf) {
        //x坐标为气泡最右端
        targetRect.origin.x = DScreenWidth - 16 - 40 - 6 - longTapModel.messageWidth - 20;
    } else {
        //x坐标为气泡最左端
        targetRect.origin.x = 16 + 40 + 6;
    }
    //y坐标为气泡最下端 width和height是cell的宽度和高度
    targetRect.origin.y -= (10 + DWScale(20));
    
    BOOL isBottom = (cellIndex.row == (self.messageModels.count - 1) && self.messageModels.count > 2) ? YES : NO;
    //显示出弹窗
    NoaChatMessageMoreView *msgMoreMenu = [[NoaChatMessageMoreView alloc] initWithMenu:menuArr targetRect:targetRect isFromMy:longTapModel.isSelf isBottom:isBottom msgContentSize:CGSizeMake(longTapModel.messageWidth, longTapModel.messageHeight)];
    WeakSelf;
    
    // 使用弱引用避免循环引用
    __weak typeof(msgMoreMenu) weakMsgMoreMenu = msgMoreMenu;
    
    // 对于群聊的文字消息和@消息，查询置顶状态并动态添加菜单项
    // 只有在 groupMsgPinning 是 "true" 时才请求接口动态添加
    // 引用消息不添加置顶和取消置顶按钮
    if (self.chatType == CIMChatType_GroupChat &&
        (longTapModel.message.messageType == CIMChatMessageType_TextMessage || longTapModel.message.messageType == CIMChatMessageType_AtMessage) &&
        longTapModel.message.serviceMsgID.length > 0 &&
        [NSString isNil:longTapModel.message.referenceMsgId] && // 引用消息不添加置顶按钮
        [UserManager.userRoleAuthInfo.groupMsgPinning.configValue isEqualToString:@"true"]) {
        // 异步查询置顶状态
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
        [params setObjectSafe:self.sessionID forKey:@"groupId"];
        [params setObjectSafe:longTapModel.message.serviceMsgID forKey:@"smsgId"];
        
        // 使用关联对象保存 type 值和消息模型
        objc_setAssociatedObject(msgMoreMenu, @"msgTopType", nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(msgMoreMenu, @"msgModel", longTapModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [IMSDKManager MessageQueryGroupMsgStatusWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            __strong typeof(weakMsgMoreMenu) strongMsgMoreMenu = weakMsgMoreMenu;
            if (!strongMsgMoreMenu) { return; }
            
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dataDic = (NSDictionary *)data;
                NSInteger type = [[dataDic objectForKeySafe:@"type"] integerValue];
                
                // 保存 type 值到关联对象
                objc_setAssociatedObject(strongMsgMoreMenu, @"msgTopType", @(type), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                
                // 根据 type 值动态添加菜单项
                NSMutableArray *updatedMenuArr = [menuArr mutableCopy];
                
                // 获取用户角色
                NSInteger userGroupRole = weakSelf.groupInfo ? weakSelf.groupInfo.userGroupRole : 0;
                
                if (type == 2 || type == 3) {
                    // type == 2 或 type == 3：直接添加取消置顶菜单项
                    if (![updatedMenuArr containsObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeGroupTopCancel]]) {
                        [updatedMenuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeGroupTopCancel]];
                    }
                } else if (type == 1) {
                    // type == 1：判断当前身份，如果是群主或管理员才添加
                    if (userGroupRole == 1 || userGroupRole == 2) {
                        // 群主或管理员：添加取消置顶菜单项
                        if (![updatedMenuArr containsObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeGroupTopCancel]]) {
                            [updatedMenuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeGroupTopCancel]];
                        }
                    }
                    else {
                        //群成员添加置顶菜单项可个人置顶
                        if (![updatedMenuArr containsObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeGroupTop]]) {
                            [updatedMenuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeGroupTop]];
                        }
                    }
                    
                } else {
                    // 未置顶，添加置顶菜单项
                    if (![updatedMenuArr containsObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeGroupTop]]) {
                        [updatedMenuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeGroupTop]];
                    }
                }
                
                // 更新菜单显示
                [strongMsgMoreMenu updateMenuItems:updatedMenuArr];
            }
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            // 查询失败，不添加置顶相关菜单项
        }];
    }
    
    // 对于单聊的文字消息和@消息，查询置顶状态并动态添加菜单项
    // 只有在 userMsgPinning 是 "true" 时才请求接口动态添加
    // 引用消息不添加置顶和取消置顶按钮
    if (self.chatType == CIMChatType_SingleChat && 
        (longTapModel.message.messageType == CIMChatMessageType_TextMessage || longTapModel.message.messageType == CIMChatMessageType_AtMessage) &&
        longTapModel.message.serviceMsgID.length > 0 &&
        [NSString isNil:longTapModel.message.referenceMsgId] && // 引用消息不添加置顶按钮
        [UserManager.userRoleAuthInfo.userMsgPinning.configValue isEqualToString:@"true"]) {
        // 异步查询置顶状态
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
        [params setObjectSafe:self.sessionID forKey:@"friendUid"];
        [params setObjectSafe:longTapModel.message.serviceMsgID forKey:@"smsgId"];
        
        // 使用关联对象保存 type 值和消息模型
        objc_setAssociatedObject(msgMoreMenu, @"msgTopType", nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(msgMoreMenu, @"msgModel", longTapModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [IMSDKManager MessageQueryUserMsgStatusWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            __strong typeof(weakMsgMoreMenu) strongMsgMoreMenu = weakMsgMoreMenu;
            if (!strongMsgMoreMenu) { return; }
            
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dataDic = (NSDictionary *)data;
                NSInteger type = [[dataDic objectForKeySafe:@"type"] integerValue];
                
                // 保存 type 值到关联对象
                objc_setAssociatedObject(strongMsgMoreMenu, @"msgTopType", @(type), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                
                // 根据 type 值动态添加菜单项
                NSMutableArray *updatedMenuArr = [menuArr mutableCopy];
                
                if (type == 0) {
                    // type == 0：未置顶，添加置顶菜单项
                    if (![updatedMenuArr containsObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeSingleTop]]) {
                        [updatedMenuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeSingleTop]];
                    }
                } else {
                    // type != 0：已置顶（1全局、2个人、3全局+个人），添加取消置顶菜单项
                    if (![updatedMenuArr containsObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeSingleTopCancel]]) {
                        [updatedMenuArr addObject:[NSNumber numberWithInteger:MessageMenuItemActionTypeSingleTopCancel]];
                    }
                }
                
                // 更新菜单显示
                [strongMsgMoreMenu updateMenuItems:updatedMenuArr];
            }
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            // 查询失败，不添加置顶相关菜单项
        }];
    }
    
    [msgMoreMenu setMenuClick:^(MessageMenuItemActionType actionType) {
        __strong typeof(weakMsgMoreMenu) strongMsgMoreMenu = weakMsgMoreMenu;
        switch (actionType) {
            case MessageMenuItemActionTypeCopy:
                //复制
                [weakSelf messageCopyActionWithModel:longTapModel];
                break;
            case MessageMenuItemActionTypeCopyContent:
                //复制原文
                [weakSelf messageCopyContentActionWithModel:longTapModel];
                break;
            case MessageMenuItemActionTypeCopyTranslate:
                //复制译文
                [weakSelf messageCopyTranslateActionWithModel:longTapModel];
                break;
            case MessageMenuItemActionTypeForward:
                //转发
                [weakSelf messageForwardActionWithMsgList:@[longTapModel] multiSelectType:ZMultiSelectTypeSingleForward];
                break;
            case MessageMenuItemActionTypeDelete:
                //删除
                [weakSelf messageDeleteActionWithMsg:longTapModel index:cellIndex.row];
                break;
            case MessageMenuItemActionTypeRevoke:
                //撤回
                [weakSelf messageRevokeActionWithMsg:longTapModel];
                break;
            case MessageMenuItemActionTypeEdit:
                //编辑已发送消息
                [weakSelf messageEditActionWithMsg:longTapModel];
                break;
            case MessageMenuItemActionTypeReference:
                //引用
                [weakSelf messageReferenceActionWithMsg:longTapModel];
                break;
            case MessageMenuItemActionTypeCollection:
                //收藏
                [weakSelf messageCollectionActionWithMsg:longTapModel];
                break;
            case MessageMenuItemActionTypeMultiSelect:
                //多选
                [weakSelf messageMultiSelectAction];
                break;
            case MessageMenuItemActionTypeAddTag:
                //url存为标签
                [weakSelf messageTextContentUrlAddTagWithMsg:longTapModel];
                break;
            case MessageMenuItemActionTypeShowTranslate:
                //翻译
                [weakSelf messageContentTranslateActionWithMsg:longTapModel];
                break;
            case MessageMenuItemActionTypeHiddenTranslate:
                //隐藏译文
                [weakSelf messageContentHiddenTranslateActionWithMsg:longTapModel];
                break;
            case MessageMenuItemActionTypeStickersAdd:
                //添加表情到收藏
                [weakSelf messageStickersAddToCollectionActionWithMsg:longTapModel];
                break;
            case MessageMenuItemActionTypeStickersPackage:
                //查找当前表情所属表情包
                [weakSelf messageStickersSearchPackageActionWithMsg:longTapModel];
                break;
            case MessageMenuItemActionTypeMutePlayback:
                //听筒播放
                [weakSelf messageMutePlaybackActionWithMsg:longTapModel cellIndex:cellIndex];
                break;
            case MessageMenuItemActionTypeGroupTop:
                //置顶
                [weakSelf messageGroupTopActionWithMsg:longTapModel msgMoreMenu:strongMsgMoreMenu];
                break;
            case MessageMenuItemActionTypeGroupTopCancel:
                //取消置顶
                [weakSelf messageGroupTopCancelActionWithMsg:longTapModel msgMoreMenu:strongMsgMoreMenu];
                break;
            case MessageMenuItemActionTypeSingleTop:
                //单聊置顶
                [weakSelf messageSingleTopActionWithMsg:longTapModel msgMoreMenu:strongMsgMoreMenu];
                break;
            case MessageMenuItemActionTypeSingleTopCancel:
                //单聊取消置顶
                [weakSelf messageSingleTopCancelActionWithMsg:longTapModel msgMoreMenu:strongMsgMoreMenu];
                break;
            default:
                break;
        }
    }];
}

//消息发送失败，重发消息
- (void)messageReSendClick:(NSIndexPath *)cellIndex {
    if (self.multiSelectStatus) {
        return;
    }
    NoaMessageModel *reSendMsgModel = [self.messageModels objectAtIndex:cellIndex.row];
    WeakSelf
    if (reSendMsgModel.message.messageType == CIMChatMessageType_FileMessage) {
        NoaPresentItem *saveItem = [NoaPresentItem creatPresentViewItemWithText:LanguageToolMatch(@"重新上传") textColor:COLOR_11 font:FONTR(17) itemHeight:DWScale(54) backgroundColor:COLORWHITE];
        self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
            if (themeIndex == 0) {
                saveItem.textColor = COLOR_11;
                saveItem.backgroundColor = COLORWHITE;
            }else {
                saveItem.textColor = COLORWHITE;
                saveItem.backgroundColor = COLOR_11;
            }
        };
        NoaPresentItem *cancelItem = [NoaPresentItem creatPresentViewItemWithText:LanguageToolMatch(@"取消") textColor:COLOR_99 font:FONTR(17) itemHeight:DWScale(54) backgroundColor:COLORWHITE];
        self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
            if (themeIndex == 0) {
                cancelItem.textColor = COLOR_99;
                cancelItem.backgroundColor = COLORWHITE;
            }else {
                cancelItem.textColor = COLOR_99;
                cancelItem.backgroundColor = COLOR_11;
            }
        };
        NoaPresentView *viewAlert = [[NoaPresentView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DScreenHeight) titleItem:nil selectItems:@[saveItem] cancleItem:cancelItem doneClick:^(NSInteger index) {
            [weakSelf reSendFailMessageWithReSendMsg:reSendMsgModel Index:cellIndex.row];
        } cancleClick:^{
            
        }];
        [self.view addSubview:viewAlert];
        [viewAlert showPresentView];
    } else {
        NoaMessageAlertView *msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeNomal supView:nil];
        msgAlertView.lblContent.text = LanguageToolMatch(@"是否重新发送");
        [msgAlertView.btnSure setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
        [msgAlertView alertShow];
        msgAlertView.sureBtnBlock = ^(BOOL isCheckBox) {
            [weakSelf reSendFailMessageWithReSendMsg:reSendMsgModel Index:cellIndex.row];
        };
    }
}

//给非好友发送消息，notFriend消息中点击添加好友的弹窗
- (void)systemMessageNotFriendAlert:(NSIndexPath *)cellIndex {
    if (self.multiSelectStatus) {
        return;
    }
    NoaMessageAlertView *msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeNomal supView:nil];
    msgAlertView.lblContent.text = LanguageToolMatch(@"点击确认发送好友验证申请，对方同意后即可对话聊天。");
    [msgAlertView.btnSure setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
    [msgAlertView alertShow];
    WeakSelf
    msgAlertView.sureBtnBlock = ^(BOOL isCheckBox) {
        [weakSelf chatAddFriend];
    };
}

//语音消息点击，播放或者停止
- (void)voiceMessageClick:(NSIndexPath *)cellIndex {
    if (self.multiSelectStatus) {
        return;
    }
    [ZAudioPlayerTOOL setAudioWaiFangSession];
    NoaMessageVoiceCell *clickVoiceCell = (NoaMessageVoiceCell *)[self.baseTableView cellForRowAtIndexPath:cellIndex];
    NoaMessageModel *voiceMsgModel = [self.messageModels objectAtIndex:cellIndex.row];
    if (ZAudioPlayerTOOL.isPlaying) {
        [ZAudioPlayerTOOL stop];
    }
    if (clickVoiceCell.isAnimation) {
        [clickVoiceCell stopAnimation];
        [ZAudioPlayerTOOL stop];
    } else {
        [self voicePlay:clickVoiceCell voiceMsgModel:voiceMsgModel];
    }
}

- (void)voicePlay:(NoaMessageVoiceCell *)clickVoiceCell voiceMsgModel:(NoaMessageModel *)voiceMsgModel {
    if (ZAudioPlayerTOOL.currentVoiceCell && ![ZAudioPlayerTOOL.currentVoiceCell isEqual:clickVoiceCell]) {
        [ZAudioPlayerTOOL stop];
        [ZAudioPlayerTOOL.currentVoiceCell stopAnimation];
    }
    ZAudioPlayerTOOL.currentVoiceCell = clickVoiceCell;
    if (voiceMsgModel.isSelf) {
        //本地音频文件路径
        NSString *folderPath = [NSString getVoiceDiectoryWithCustomPath:[NSString stringWithFormat:@"%@-%@",UserManager.userInfo.userUID, _sessionID]];
        NSString *meLocalPath = [NSString stringWithFormat:@"%@/%@", folderPath, voiceMsgModel.message.localVoiceName];
        //判断本地音频文件是否存在
        if ([[NSFileManager defaultManager] fileExistsAtPath:meLocalPath]) {
            //本地存在对应的音频文件
            BOOL isPlay = [ZAudioPlayerTOOL playAudioPath:meLocalPath];
            if (isPlay) {
                [clickVoiceCell startAnimation];
                ZAudioPlayerTOOL.currentAudioPath = voiceMsgModel.message.localVoiceName;
                ZAudioPlayerTOOL.playMessageID = voiceMsgModel.message.msgID;
            }
        } else {
            //本地不存在对应的音频文件，需要先缓存，再播放(先判断是否有网络)
            if (self.isReachable) {
                //有网络，下载语音文件，下载成功后并进行播放
                NSString *downloadVoicePath = [NSString stringWithFormat:@"%@/%@", folderPath, [voiceMsgModel.message.voiceName MD5Encryption]];
                //下载语音音频文件
                [NoaMessageTools downloadAudioWith:voiceMsgModel.message.voiceName AudioCachePath:downloadVoicePath completion:^(BOOL success, NSString * _Nonnull audioPath) {
                    if (success) {
                        BOOL isPlay = [ZAudioPlayerTOOL playAudioPath:audioPath];
                        if (isPlay) {
                            [clickVoiceCell startAnimation];
                            ZAudioPlayerTOOL.currentAudioPath = voiceMsgModel.message.localVoiceName;
                            ZAudioPlayerTOOL.playMessageID = voiceMsgModel.message.msgID;
                        }
                    } else {
                        [HUD showMessage:LanguageToolMatch(@"语音播放失败，请稍后再试") inView:self.view];
                    }
                }];
            } else {
                //无网络
                [HUD showMessage:LanguageToolMatch(@"网络错误,播放失败") inView:self.view];
            }
        }
    } else {
        //本地音频文件路径
        NSString *folderPath = [NSString getVoiceDiectoryWithCustomPath:[NSString stringWithFormat:@"%@-%@",UserManager.userInfo.userUID, _sessionID]];
        NSString *meLocalPath = [NSString stringWithFormat:@"%@/%@", folderPath, [voiceMsgModel.message.voiceName MD5Encryption]];
        //判断本地音频文件是否存在
        if ([[NSFileManager defaultManager] fileExistsAtPath:meLocalPath]) {
            //本地存在对应的音频文件
            BOOL isPlay = [ZAudioPlayerTOOL playAudioPath:meLocalPath];
            if (isPlay) {
                [clickVoiceCell startAnimation];
                ZAudioPlayerTOOL.currentAudioPath = voiceMsgModel.message.voiceName;
                ZAudioPlayerTOOL.playMessageID = voiceMsgModel.message.msgID;
            }
        } else {
            //本地不存在对应的音频文件，需要先缓存，再播放(先判断是否有网络)
            if (self.isReachable) {
                //有网络，下载语音文件，下载成功后并进行播放
                WeakSelf
                [NoaMessageTools downloadAudioWith:voiceMsgModel.message.voiceName AudioCachePath:meLocalPath completion:^(BOOL success, NSString * _Nonnull audioPath) {
                    if (success) {
                        BOOL isPlay = [ZAudioPlayerTOOL playAudioPath:audioPath];
                        if (isPlay) {
                            //上报该条语音消息已读
                            if (![voiceMsgModel.message.fromID isEqualToString:UserManager.userInfo.userUID]) {
                                //消息未读并且为被加入待上传已读的数组里
                                NSString *sMsgIdAndSendUid = [NSString stringWithFormat:@"%@_%@_%@", voiceMsgModel.message.serviceMsgID, voiceMsgModel.message.fromID, voiceMsgModel.message.msgID];
                                if (!voiceMsgModel.message.chatMessageReaded && ![weakSelf.unReadSmsgidList containsObject:sMsgIdAndSendUid]) {
                                    voiceMsgModel.message.chatMessageReaded = YES;
                                    [weakSelf.unReadSmsgidList addObject:sMsgIdAndSendUid];
                                }
                            }
                            [clickVoiceCell startAnimation];
                            ZAudioPlayerTOOL.currentAudioPath = voiceMsgModel.message.voiceName;
                            ZAudioPlayerTOOL.playMessageID = voiceMsgModel.message.msgID;
                        }
                    } else {
                        [HUD showMessage:LanguageToolMatch(@"语音播放失败，请稍后再试") inView:weakSelf.view];
                    }
                }];
            } else {
                //无网络
                [HUD showMessage:LanguageToolMatch(@"网络错误,播放失败") inView:self.view];
            }
        }
    }
}
//消息气泡点击
- (void)messageBubbleClick:(NSIndexPath *)cellIndex {
    if (self.multiSelectStatus) {
        return;
    }
    NoaMessageModel *bubbleMsgClickModel = [self.messageModels objectAtIndex:cellIndex.row];
    if (bubbleMsgClickModel.message.messageType == CIMChatMessageType_FileMessage) {
        //文件消息-文件详情
        NSString *foldPath = [NSString getFileDiectoryWithCustomPath:[NSString stringWithFormat:@"%@-%@",UserManager.userInfo.userUID, self.sessionID]];
        NSString *fileFullPath = [NSString stringWithFormat:@"%@/%@", foldPath, bubbleMsgClickModel.message.fileName];
        
        NoaChatFileDetailViewController *fileDetailVC = [[NoaChatFileDetailViewController alloc] init];
        fileDetailVC.fileMsgModel = bubbleMsgClickModel;
        fileDetailVC.fromSessionId = self.sessionID;
        fileDetailVC.localFilePath = fileFullPath;
        fileDetailVC.isShowRightBtn = YES;
        fileDetailVC.isFromCollcet = NO;
        [self.navigationController pushViewController:fileDetailVC animated:YES];
    } else if (bubbleMsgClickModel.message.messageType == CIMChatMessageType_CardMessage) {
        //名片消息-用户个人资料页
        NoaUserHomePageVC *userHomeVC = [NoaUserHomePageVC new];
        userHomeVC.userUID = bubbleMsgClickModel.message.cardUserId;
        userHomeVC.groupID = @"";
        [self.navigationController pushViewController:userHomeVC animated:YES];
    } else if (bubbleMsgClickModel.message.messageType == CIMChatMessageType_ForwardMessage) {
        //消息记录详情页面
        NoaChatRecordDetailViewController *chatRecordDetailVC = [[NoaChatRecordDetailViewController alloc] init];
        chatRecordDetailVC.levelNum = 1;
        chatRecordDetailVC.model = bubbleMsgClickModel;
        [self.navigationController pushViewController:chatRecordDetailVC animated:YES];
    }
}

- (void)messageCellClick:(NSIndexPath *)cellIndex {
    if (!self.multiSelectStatus) return;

    // 安全校验
    if (cellIndex.row >= self.messageModels.count) return;

    NoaMessageModel *multiClickModel = [self.messageModels objectAtIndex:cellIndex.row];
    CIMChatMessageType type = multiClickModel.message.messageType;

    // 判断是否是不能选择的类型
    BOOL isValidType =
        type != CIMChatMessageType_GroupNotice &&
        type != CIMChatMessageType_CardMessage &&
        type != CIMChatMessageType_GameStickersMessage &&
        type != CIMChatMessageType_NetCallMessage &&
        type != CIMChatMessageType_ServerMessage &&
        type != CIMChatMessageType_ForwardMessage &&
        multiClickModel.message.messageSendType == CIMChatMessageSendTypeSuccess;

    if (!isValidType) return;

    // 如果未被选中且已达上限
    if (!multiClickModel.multiSelected && self.selectedMsgModels.count >= Multi_Selected_Max_Num) {
        [HUD showMessage:LanguageToolMatch(@"最多选择100条消息") inView:self.view];
        return;
    }

    // 反选
    multiClickModel.multiSelected = !multiClickModel.multiSelected;
    [self.messageModels replaceObjectAtIndex:cellIndex.row withObject:multiClickModel];

    // 更新UI
    [self.baseTableView reloadData];

    // 更新选中数组
    if (multiClickModel.multiSelected) {
        [self.selectedMsgModels addObject:multiClickModel];
    } else {
        WeakSelf
        [self.selectedMsgModels enumerateObjectsUsingBlock:^(NoaMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (multiClickModel.multiSelected == NO && [obj.message.msgID isEqualToString:multiClickModel.message.msgID]) {
                [weakSelf.selectedMsgModels removeObject:obj];
            }
        }];
    }

    self.multiSelectBottomView.selectNum = self.selectedMsgModels.count;
}


- (void)messageTextContainUrlClick:(NSString *)urlStr messageModel:(nonnull NoaMessageModel *)messageModel {
    //跳转Web
    
    NoaFloatMiniAppModel * floadModel = [[NoaFloatMiniAppModel alloc] init];
    floadModel.url = urlStr;
    floadModel.floladId = [NSString stringWithFormat:@"%@_%@",messageModel.message.msgID,urlStr];
    floadModel.title = nil;
    floadModel.headerUrl = nil;
    
    NoaMiniAppWebVC *webVC = [[NoaMiniAppWebVC alloc] init];
    webVC.webViewUrl = urlStr;
    webVC.webType = ZMiniAppWebVCTypeMiniApp;
    webVC.floatMiniAppModel = floadModel;
    [self.navigationController pushViewController:webVC animated:YES];
}

//自己发送的消息重新翻译
- (void)messageTextReTranslateClick:(NSIndexPath *)cellIndex {
    NoaMessageModel *reTranslateMsgModel = [self.messageModels objectAtIndex:cellIndex.row];
    WeakSelf
    //At消息
    if (reTranslateMsgModel.message.messageType == CIMChatMessageType_AtMessage) {
        //@用户消息
        reTranslateMsgModel.message.translateStatus = CIMTranslateStatusLoading;
        [self requestTranslateActionWithContent:reTranslateMsgModel.message.atContent atUserDictList:reTranslateMsgModel.message.atUsersInfoList isSend:reTranslateMsgModel.isSelf ? YES : NO messageType:reTranslateMsgModel.message.messageType success:^(NSString * _Nullable result) {
            reTranslateMsgModel.message.atTranslateContent = result;
            reTranslateMsgModel.message.translateStatus = CIMTranslateStatusSuccess;
            [IMSDKManager toolInsertOrUpdateChatMessageWith:reTranslateMsgModel.message];
            //替换消息并刷新界面
            [weakSelf replaceMessageModelWithNewMsgModel:reTranslateMsgModel.message];
            if (reTranslateMsgModel.isSelf) {
                [IMSDKManager toolSendChatMessageWith:reTranslateMsgModel.message];
            }
        } failure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            reTranslateMsgModel.message.translateStatus = CIMTranslateStatusFail;
            //替换消息并刷新界面
            [weakSelf replaceMessageModelWithNewMsgModel:reTranslateMsgModel.message];
            reTranslateMsgModel.message.messageSendType = CIMChatMessageSendTypeFail;
            [IMSDKManager toolInsertOrUpdateChatMessageWith:reTranslateMsgModel.message];
        }];
        //替换消息并刷新界面
        [self replaceMessageModelWithNewMsgModel:reTranslateMsgModel.message];
    } else {
        //文本消息
        reTranslateMsgModel.message.translateStatus = CIMTranslateStatusLoading;
        [self requestTranslateActionWithContent:reTranslateMsgModel.message.textContent atUserDictList:@[] isSend:reTranslateMsgModel.isSelf ? YES : NO messageType:reTranslateMsgModel.message.messageType success:^(NSString * _Nullable result) {
            reTranslateMsgModel.message.translateContent = result;
            reTranslateMsgModel.message.translateStatus = CIMTranslateStatusSuccess;
            [IMSDKManager toolInsertOrUpdateChatMessageWith:reTranslateMsgModel.message];
            //替换消息并刷新界面
            [weakSelf replaceMessageModelWithNewMsgModel:reTranslateMsgModel.message];
            if (reTranslateMsgModel.isSelf) {
                [IMSDKManager toolSendChatMessageWith:reTranslateMsgModel.message];
            }
        } failure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            reTranslateMsgModel.message.translateStatus = CIMTranslateStatusFail;
            //替换消息并刷新界面
            [weakSelf replaceMessageModelWithNewMsgModel:reTranslateMsgModel.message];
            reTranslateMsgModel.message.messageSendType = CIMChatMessageSendTypeFail;
            [IMSDKManager toolInsertOrUpdateChatMessageWith:reTranslateMsgModel.message];
        }];
        //替换消息并刷新界面
        [self replaceMessageModelWithNewMsgModel:reTranslateMsgModel.message];
    }
}

//游戏表情动画执行结束
- (void)gameMessageAnimationComplete:(NSIndexPath *)cellIndex {
    NoaMessageModel *msgModel = [self.messageModels objectAtIndex:cellIndex.row];
    msgModel.message.isGameAnimationed = YES;
    [self.messageModels replaceObjectAtIndex:cellIndex.row withObject:msgModel];
    [IMSDKManager toolInsertOrUpdateChatMessageWith:msgModel.message];
}

//群成员活跃等级标签点击
- (void)groupMemberActivityLevelTagClick:(NSIndexPath *)cellIndex {
    if (self.groupInfo.isActiveEnabled == 1) {
        NoaChatActivityLevelVC *vc = [[NoaChatActivityLevelVC alloc] init];
        vc.groupInfo = self.groupInfo;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

// 群公告消息，点击时获取
- (void)messageCellClickGroupNotice:(NSIndexPath *)cellIndex {
    [HUD showActivityMessage:@"" inView:self.view];
    
    NoaMessageModel *groupNoticMsgModel = [self.messageModels objectAtIndex:cellIndex.row];
    NSString *groupNoticeID = groupNoticMsgModel.message.groupNoticeID;
    
    // 获取单个群公告信息
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:self.groupInfo.groupId forKey:@"groupId"];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    [dict setObjectSafe:groupNoticeID forKey:@"noticeId"];
    @weakify(self)
    [IMSDKManager groupCheckOneGroupNoticeWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        @strongify(self)
        [HUD hideHUD];
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDict = (NSDictionary *)data;
            NoaGroupNoteModel *groupNoticeModel = [NoaGroupNoteModel mj_objectWithKeyValues:dataDict];
            NoaGroupNoticeDetailVC *vc = [NoaGroupNoticeDetailVC new];
            vc.groupInfoModel = self.groupInfo;
            vc.groupNoticeModel = groupNoticeModel;
            [self.navigationController pushViewController:vc animated:YES];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        @strongify(self)
        [HUD hideHUD];
        if (code == 41034) {
            [HUD showMessage:LanguageToolMatch(@"公告已删除") inView:self.view];
        }else {
            [HUD showMessageWithCode:code errorMsg:msg inView:self.view];
        }
    }];
}

#pragma mark - 消息重新发送
- (void)reSendFailMessageWithReSendMsg:(NoaMessageModel *)reSendMsgModel Index:(NSInteger)index {
    WeakSelf
    if (![NetWorkStatusManager shared].getConnectStatus) {
        return;
    }
    [NoaMessageSendHander ZMessageReSendWithFailMsg:reSendMsgModel compelete:^(NoaIMChatMessageModel * _Nonnull sendChatMsg) {
        // 优先按旧消息ID精确移除，避免索引失真导致重复；找不到再按索引兜底
        NSString *oldMsgID = nil;
        if ([reSendMsgModel respondsToSelector:@selector(message)] && reSendMsgModel.message) {
            oldMsgID = reSendMsgModel.message.msgID;
        }
        BOOL removed = NO;
        if (oldMsgID.length > 0) {
            for (NSInteger i = weakSelf.messageModels.count - 1; i >= 0; i--) {
                NoaMessageModel *m = [weakSelf.messageModels objectAtIndex:i];
                if ([m respondsToSelector:@selector(message)] && m.message && [m.message.msgID isEqualToString:oldMsgID]) {
                    [weakSelf.messageModels removeObjectAtIndex:i];
                    removed = YES;
                    break;
                }
            }
        }
        if (!removed && index >= 0 && index < weakSelf.messageModels.count) {
            [weakSelf.messageModels removeObjectAtIndex:index];
        }
        // 重新追加到底部
        [weakSelf chatListAppendMessage:sendChatMsg];
        //如果是文本消息、At消息、名片消息，添加到UI上后，直接发送消息
        if (sendChatMsg.messageType == CIMChatMessageType_TextMessage || sendChatMsg.messageType == CIMChatMessageType_AtMessage) {
            if (weakSelf.sessionModel.isSendAutoTranslate == 1) {
                //At消息
                if (sendChatMsg.messageType == CIMChatMessageType_AtMessage) {
                    //@用户消息
                    sendChatMsg.translateStatus = CIMTranslateStatusLoading;
                    [self requestTranslateActionWithContent:sendChatMsg.atContent atUserDictList:sendChatMsg.atUsersInfoList  isSend:YES messageType:sendChatMsg.messageType success:^(NSString * _Nullable result) {
                        sendChatMsg.atTranslateContent = result;
                        sendChatMsg.translateStatus = CIMTranslateStatusSuccess;
                        //替换消息并刷新界面
                        [weakSelf replaceMessageModelWithNewMsgModel:sendChatMsg];
                        [IMSDKManager toolSendChatMessageWith:sendChatMsg];
                    } failure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                        sendChatMsg.translateStatus = CIMTranslateStatusFail;
                        sendChatMsg.messageSendType = CIMChatMessageSendTypeFail;
                        //替换消息并刷新界面
                        [weakSelf replaceMessageModelWithNewMsgModel:sendChatMsg];
                    }];
                } else {
                    //文本消息
                    sendChatMsg.translateStatus = CIMTranslateStatusLoading;
                    [self requestTranslateActionWithContent:sendChatMsg.textContent atUserDictList:@[] isSend:YES messageType:sendChatMsg.messageType success:^(NSString * _Nullable result) {
                        sendChatMsg.translateContent = result;
                        sendChatMsg.translateStatus = CIMTranslateStatusSuccess;
                        //替换消息并刷新界面
                        [weakSelf replaceMessageModelWithNewMsgModel:sendChatMsg];
                        [IMSDKManager toolSendChatMessageWith:sendChatMsg];
                    } failure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                        sendChatMsg.translateStatus = CIMTranslateStatusFail;
                        sendChatMsg.messageSendType = CIMChatMessageSendTypeFail;
                        //替换消息并刷新界面
                        [weakSelf replaceMessageModelWithNewMsgModel:sendChatMsg];
                    }];
                }
            } else {
                [IMSDKManager toolSendChatMessageWith:sendChatMsg];
            }
        } else if (sendChatMsg.messageType == CIMChatMessageType_CardMessage || sendChatMsg.messageType == CIMChatMessageType_ForwardMessage || sendChatMsg.messageType == CIMChatMessageType_StickersMessage || sendChatMsg.messageType == CIMChatMessageType_GameStickersMessage) {
    
            [IMSDKManager toolSendChatMessageWith:sendChatMsg];
            
        } else if (sendChatMsg.messageType == CIMChatMessageType_ImageMessage || sendChatMsg.messageType == CIMChatMessageType_VideoMessage || sendChatMsg.messageType == CIMChatMessageType_VoiceMessage || reSendMsgModel.message.messageType == CIMChatMessageType_FileMessage || sendChatMsg.messageType == CIMChatMessageType_GeoMessage) {
            NSMutableArray *taskArray = [NSMutableArray array];
            NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, sendChatMsg.toID];
            if (sendChatMsg.messageType == CIMChatMessageType_ImageMessage) {
                //沙盒路径
                NSString *localThumbImgPath = [NSString getPathWithImageName:sendChatMsg.localthumbImgName CustomPath:customPath];
                NSString *imagePath = [NSString getPathWithImageName:sendChatMsg.localImgName CustomPath:customPath];

                //缩略图
                NSData *thumbImgData = [NSData dataWithContentsOfFile:localThumbImgPath];
                NoaFileUploadTask *thumbImgTask = [[NoaFileUploadTask alloc] initWithTaskId:[NSString stringWithFormat:@"%@_thumb", sendChatMsg.msgID] filePath:localThumbImgPath originFilePath:imagePath fileName:sendChatMsg.localthumbImgName fileType:@"" isEncrypt:YES dataLength:thumbImgData.length uploadType:ZHttpUploadTypeImageThumbnail beSendMessage:sendChatMsg delegate:self];
                thumbImgTask.messageTaskType = FileUploadMessageTaskTypeThumbImage;
                [taskArray addObject:thumbImgTask];
                [[NoaFileUploadManager sharedInstance] addUploadTask:thumbImgTask];

                //图片
                NoaFileUploadTask *imgTask = [[NoaFileUploadTask alloc] initWithTaskId:sendChatMsg.msgID filePath:imagePath originFilePath:@"" fileName:sendChatMsg.localImgName fileType:@"" isEncrypt:YES dataLength:sendChatMsg.imgSize uploadType:ZHttpUploadTypeImage beSendMessage:sendChatMsg delegate:self];
                imgTask.messageTaskType = FileUploadMessageTaskTypeImage;
                [taskArray addObject:imgTask];
                [[NoaFileUploadManager sharedInstance] addUploadTask:imgTask];
            } else if (sendChatMsg.messageType == CIMChatMessageType_VideoMessage) {
                /// 视频
                //视频封面上传
                NSString *coverPath = [NSString getPathWithImageName:sendChatMsg.localVideoCover CustomPath:customPath];
                NoaFileUploadTask *coverTask = [[NoaFileUploadTask alloc] initWithTaskId:[NSString stringWithFormat:@"%@_cover", sendChatMsg.msgID] filePath:coverPath originFilePath:@"" fileName:sendChatMsg.localVideoCover fileType:@"" isEncrypt:YES dataLength:sendChatMsg.videoCoverSize uploadType:ZHttpUploadTypeImage beSendMessage:sendChatMsg delegate:self];
                coverTask.messageTaskType = FileUploadMessageTaskTypeCover;
                [taskArray addObject:coverTask];
                [[NoaFileUploadManager sharedInstance] addUploadTask:coverTask];
                
                //视频文件上传
                NSString *videoPath = [NSString getPathWithVideoName:sendChatMsg.localVideoName CustomPath:customPath];
                NoaFileUploadTask *videoTask = [[NoaFileUploadTask alloc] initWithTaskId:sendChatMsg.msgID filePath:videoPath originFilePath:@"" fileName:sendChatMsg.localVideoName fileType:@"" isEncrypt:YES dataLength:sendChatMsg.videoSize uploadType:ZHttpUploadTypeVideo beSendMessage:sendChatMsg delegate:self];
                videoTask.messageTaskType = FileUploadMessageTaskTypeVideo;
                [taskArray addObject:videoTask];
                [[NoaFileUploadManager sharedInstance] addUploadTask:videoTask];
            } else if (sendChatMsg.messageType == CIMChatMessageType_VoiceMessage) {
                //音频
                NSData *audioData = [NSData dataWithContentsOfFile:sendChatMsg.localVoicePath options:NSDataReadingMappedIfSafe error:nil];
                NoaFileUploadTask *voiceTask = [[NoaFileUploadTask alloc] initWithTaskId:sendChatMsg.msgID filePath:sendChatMsg.localVoicePath originFilePath:@"" fileName:sendChatMsg.localVoiceName fileType:@"" isEncrypt:NO dataLength:audioData.length uploadType:ZHttpUploadTypeVoice beSendMessage:sendChatMsg delegate:self];
                voiceTask.messageTaskType = FileUploadMessageTaskTypeVoice;
                [taskArray addObject:voiceTask];
                [[NoaFileUploadManager sharedInstance] addUploadTask:voiceTask];
            } else if (sendChatMsg.messageType == CIMChatMessageType_FileMessage) {
                //文件
                NSString *filePath = [NSString getPathWithFileName:sendChatMsg.fileName CustomPath:customPath];

                NoaFileUploadTask *fileTask = [[NoaFileUploadTask alloc] initWithTaskId:sendChatMsg.msgID filePath:filePath originFilePath:@"" fileName:sendChatMsg.fileName fileType:sendChatMsg.fileType isEncrypt:YES dataLength:sendChatMsg.fileSize uploadType:ZHttpUploadTypeFile beSendMessage:sendChatMsg delegate:self];
                fileTask.messageTaskType = FileUploadMessageTaskTypeFile;
                [taskArray addObject:fileTask];
                [[NoaFileUploadManager sharedInstance] addUploadTask:fileTask];
            } else if (sendChatMsg.messageType == CIMChatMessageType_GeoMessage) {
                //地理位置
                NSString *geoImgPath = [NSString getPathWithImageName:sendChatMsg.localGeoImgName CustomPath:customPath];
                NSData *geoImgData = [NSData dataWithContentsOfFile:sendChatMsg.localVoicePath options:NSDataReadingMappedIfSafe error:nil];
                NoaFileUploadTask *geoImgTask = [[NoaFileUploadTask alloc] initWithTaskId:sendChatMsg.msgID filePath:geoImgPath originFilePath:@"" fileName:sendChatMsg.localImgName fileType:@"" isEncrypt:YES dataLength:geoImgData.length uploadType:ZHttpUploadTypeImage beSendMessage:sendChatMsg delegate:self];
                geoImgTask.messageTaskType = FileUploadMessageTaskTypeImage;
                [taskArray addObject:geoImgTask];
                [[NoaFileUploadManager sharedInstance] addUploadTask:geoImgTask];
            }
            NoaFileUploadGetSTSTask *getSTSTask = [[NoaFileUploadGetSTSTask alloc] init];
            getSTSTask.uploadTask = taskArray;
            [[NoaFileUploadManager sharedInstance].operationQueue addOperation:getSTSTask];
            
            NoaMessageSendTask *messageSendTask = [[NoaMessageSendTask alloc] init];
            messageSendTask.uploadTask = taskArray;
            [[NoaFileUploadManager sharedInstance].operationQueue addOperation:messageSendTask];
        }
    }];
}

#pragma mark - ZMsgMultiSelectDelegate 多选bottom事件代理
//多选-合并转发
- (void)mergeForwardMessageAction {
    if (self.selectedMsgModels.count <= 0) {
        return;
    }
    
    //合并转发
    [self sendChatRecordMessage:[self.selectedMsgModels.safeArray copy]];
    //UI恢复原样
    [self setupMultiSelectedStatusDefaultIsReload:YES];
}

//多选-逐条转发
- (void)singleForwardMessageAction {
    if (self.selectedMsgModels.count <= 0) {
        return;
    }
    
    //根据消息时间进行升序排列
    NSArray *sortResultArr = [NSMutableArray sortMultiSelectedMessageArr:self.selectedMsgModels.safeArray];
    //逐条转发调用的还是以前转发消息的接口
    [self messageForwardActionWithMsgList:sortResultArr multiSelectType:ZMultiSelectTypeSingleForward];
    //UI恢复原样
    [self setupMultiSelectedStatusDefaultIsReload:YES];
}

//多选-删除
- (void)deleteSelectedMessageAction {
    if (self.selectedMsgModels.count <= 0) {
        return;
    }
    
    WeakSelf
    NoaMessageAlertView *msgAlertView;
    if (self.chatType == CIMChatType_SingleChat) {  //单聊
        msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeNomal supView:nil];
        //msgAlertView.checkboxLblContent.text = LanguageToolMatch(@"从我和当前好友的设备删除");
    } else {    //群聊
        //1管理员;2群主
        if (self.groupInfo.userGroupRole == 2 || self.groupInfo.userGroupRole == 1) {
            msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeCheckBox supView:nil];
            msgAlertView.checkboxLblContent.text = LanguageToolMatch(@"从所有人设备中删除");
        } else if (self.groupInfo.userGroupRole == 0) { //自己只能删除自己，单向删除
            msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeNomal supView:nil];
        }
    }
    msgAlertView.lblContent.text = LanguageToolMatch(@"删除所选消息");
    [msgAlertView.btnSure setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
    [msgAlertView.btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    [msgAlertView alertShow];
    msgAlertView.sureBtnBlock = ^(BOOL isCheckBox) {
        [weakSelf integratedMultiSelectedDeleteData:isCheckBox ? ZMsgDeleteTypeBothWay : ZMsgDeleteTypeOneWay];
    };
}

//整合 多选-删除 的数据
- (void)integratedMultiSelectedDeleteData:(ZMsgDeleteType)deleteType {
    //删除所选消息
    __block NSMutableArray *selectedMsgIdArr = [NSMutableArray array];
    [self.selectedMsgModels enumerateObjectsUsingBlock:^(NoaMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [selectedMsgIdArr addObject:obj.message.serviceMsgID];
    }];
    [self messageDeleteWithSMgIds:selectedMsgIdArr withDeleteType:deleteType];
}

#pragma mark - 长按菜单弹窗点击事件
//复制
- (void)messageCopyActionWithModel:(NoaMessageModel *)menuModel {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (menuModel.message.messageType == CIMChatMessageType_TextMessage) {
        pasteboard.string = menuModel.message.textContent;
    } else if (menuModel.message.messageType == CIMChatMessageType_AtMessage) {
        pasteboard.string = menuModel.message.showContent;
    } else {
        return;
    }
    [HUD showMessage:LanguageToolMatch(@"复制成功") inView:self.view];
}

//复制原文
- (void)messageCopyContentActionWithModel:(NoaMessageModel *)menuModel {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (menuModel.message.messageType == CIMChatMessageType_TextMessage) {
        pasteboard.string =  ![NSString isNil:menuModel.message.againTranslateContent] ? menuModel.message.translateContent : menuModel.message.textContent;
    } else if (menuModel.message.messageType == CIMChatMessageType_AtMessage) {
        pasteboard.string = menuModel.message.showContent;
    } else {
        return;
    }
    [HUD showMessage:LanguageToolMatch(@"复制成功") inView:self.view];
}

//复制译文
- (void)messageCopyTranslateActionWithModel:(NoaMessageModel *)menuModel {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (menuModel.message.messageType == CIMChatMessageType_TextMessage) {
        pasteboard.string = ![NSString isNil:menuModel.message.againTranslateContent] ? menuModel.message.againTranslateContent : menuModel.message.translateContent;
    } else if (menuModel.message.messageType == CIMChatMessageType_AtMessage) {
        pasteboard.string = menuModel.message.showTranslateContent;
    } else {
        return;
    }
    [HUD showMessage:LanguageToolMatch(@"复制成功") inView:self.view];
}
//转发
- (void)messageForwardActionWithMsgList:(NSArray *)msgModelList multiSelectType:(ZMultiSelectType)multiSelectType {
    CoHereChatMultiSelectViewController *vc = [CoHereChatMultiSelectViewController new];
    vc.multiSelectType = multiSelectType;
    vc.fromSessionId = self.sessionID;
    vc.forwardMsgList = msgModelList;
    [self.navigationController pushViewController:vc animated:YES];
    WeakSelf
    vc.forwardMsgSendSuccess = ^(NSArray<NoaIMChatMessageModel *> * _Nullable sendForwardMsgList) {
        [HUD showMessage:LanguageToolMatch(@"转发成功") inView:weakSelf.view];
        //转发消息是转发给当前聊天对象
        [sendForwardMsgList enumerateObjectsUsingBlock:^(NoaIMChatMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([weakSelf.sessionID isEqualToString:obj.toID]) {
                NoaMessageModel *sendMsg = [[NoaMessageModel alloc] initWithMessageModel:obj];
                //刷新并滚动到底部
                [weakSelf.messageModels addObject:sendMsg];
            }
        }];
        //[weakSelf setupMultiSelectedStatusDefaultIsReload:NO];
        //处理消息是否显示时间
        [weakSelf computeVisibleTime];
        [ZTOOL doInMain:^{
            [weakSelf.baseTableView reloadData];
        }];
        //加载滚动到底部
        [weakSelf tableViewScrollToBottom:NO duration:0.25];
    };
    vc.forwardMsgSendFail = ^{
        //[weakSelf setupMultiSelectedStatusDefaultIsReload:YES];
    };
}

//仅本地删除
- (void)messageDeleteActionWithMsg:(NoaMessageModel *)msgModel index:(NSInteger)msgIndex {
    NoaMessageModel *deleteMsgModel = [self.messageModels objectAtIndex:msgIndex];
    
    //如果消息是发送中/发送失败的状态、音视频消息，删除操作只删除本地且只有单向删除，如果消息发送成功，则是按正常删除逻辑
    if (deleteMsgModel.message.messageSendType == CIMChatMessageSendTypeFail || deleteMsgModel.message.messageSendType == CIMChatMessageSendTypeSending || deleteMsgModel.message.messageType == CIMChatMessageType_NetCallMessage) {
        WeakSelf
        NoaMessageAlertView *msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeNomal supView:nil];
        msgAlertView.lblContent.text = LanguageToolMatch(@"删除所选消息");
        [msgAlertView.btnSure setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
        [msgAlertView.btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
        [msgAlertView alertShow];
        msgAlertView.sureBtnBlock = ^(BOOL isCheckBox) {
            //只从本地删除
            BOOL isDelete = [IMSDKManager toolDeleteChatMessageWith:msgModel.message];
            if (isDelete) {
                [weakSelf.messageModels removeObject:msgModel];
                //处理消息是否显示时间
                [weakSelf computeVisibleTime];
                
                [ZTOOL doInMain:^{
                    [weakSelf.baseTableView reloadData];
                }];
            }
        };
    } else {
        WeakSelf
        NoaMessageAlertView *msgAlertView;
        if (self.chatType == CIMChatType_SingleChat) {  //单聊
            if (msgModel.isSelf) {
                //我自己发送的消息，可以双向删除
                if ([UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                    msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeCheckBox supView:nil];
                    msgAlertView.checkboxLblContent.text = LanguageToolMatch(@"从我和当前好友的设备删除");
                } else {
                    msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeNomal supView:nil];
                }
            } else {
                //对方发送的消息，只能单向删除
                msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeNomal supView:nil];
            }
        } else {    //群聊
            //1管理员;2群主
            if (self.groupInfo.userGroupRole == 2 || self.groupInfo.userGroupRole == 1) {
                if ([UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                    msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeCheckBox supView:nil];
                    msgAlertView.checkboxLblContent.text = LanguageToolMatch(@"从所有人设备中删除");
                } else {
                    msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeNomal supView:nil];
                }
            } else if (self.groupInfo.userGroupRole == 0) { //自己只能删除自己，单向删除
                if (msgModel.isSelf) {
                    if ([UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"true"]) {
                        msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeCheckBox supView:nil];
                        msgAlertView.checkboxLblContent.text = LanguageToolMatch(@"从所有人设备中删除");
                    } else {
                        msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeNomal supView:nil];
                    }
                } else {
                    msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeNomal supView:nil];
                }
            }
        }
        msgAlertView.lblContent.text = LanguageToolMatch(@"删除所选消息");
        [msgAlertView.btnSure setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
        [msgAlertView.btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
        [msgAlertView alertShow];
        msgAlertView.sureBtnBlock = ^(BOOL isCheckBox) {
            [weakSelf.selectedMsgModels addObject:msgModel];
            [weakSelf messageDeleteWithSMgIds:@[msgModel.message.serviceMsgID] withDeleteType:isCheckBox ? ZMsgDeleteTypeBothWay : ZMsgDeleteTypeOneWay];
        };
    }
}

// 判断某条消息是否满足编辑权限、类型、禁言和时限要求。
- (BOOL)canEditMessage:(NoaMessageModel *)messageModel {
    if (!messageModel.isSelf || self.isCurUserNotalk || self.isAllMemberNotalk) {
        return NO;
    }
    NSInteger editableMinutes = UserManager.userRoleAuthInfo.editMsgSwitch.configValue.integerValue;
    if (editableMinutes <= 0) {
        return NO;
    }
    CIMChatMessageType messageType = messageModel.message.messageType;
    if (messageType != CIMChatMessageType_TextMessage && messageType != CIMChatMessageType_AtMessage) {
        return NO;
    }
    long long elapsedMilliseconds = [NSDate getCurrentServerMillisecondTime] - messageModel.message.sendTime;
    if (elapsedMilliseconds < 0) {
        // 客户端时间略早于服务端时仍允许编辑，最终权限由服务端校验。
        return YES;
    }
    return elapsedMilliseconds <= editableMinutes * 60LL * 1000LL;
}

// 进入编辑模式并将原正文、@ 用户和对应高亮区间回填到输入框。
- (void)messageEditActionWithMsg:(NoaMessageModel *)messageModel {
    if (![self canEditMessage:messageModel]) {
        return;
    }
    if (self.viewInput.isEditMode) {
        [self exitEditMode];
    }
    for (NSInteger index = 0; index < self.messageModels.count; index++) {
        NoaMessageModel *candidate = [self.messageModels objectAtIndex:index];
        if ([candidate.message.msgID isEqualToString:messageModel.message.msgID]) {
            self.editCellIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
            break;
        }
    }
    self.viewInput.messageModelEdit = messageModel;
    self.viewInput.isEditMode = YES;
    NSString *displayContent = messageModel.message.messageType == CIMChatMessageType_AtMessage ? messageModel.message.showContent : messageModel.message.textContent;
    self.viewInput.inputContentStr = displayContent ?: @"";
    if (messageModel.message.messageType == CIMChatMessageType_AtMessage) {
        [self.viewInput editAtMessageWithAtUserInfoList:messageModel.message.atUsersInfoList ?: @[]];
    } else {
        [self.viewInput configAtUserInfoList:@[]];
        [self.viewInput configAtSegmentsInfoList:@[]];
    }
    self.viewInput.messageModelReference = nil;
    [self.viewInput setSendButtonHighlighted:displayContent.length > 0];
    [self.viewInput inputViewBecomeFirstResponder];
}

// 退出编辑模式并清理只属于本次编辑的输入状态。
- (void)exitEditMode {
    if (!self.viewInput.isEditMode) {
        return;
    }
    self.viewInput.isEditMode = NO;
    self.viewInput.messageModelEdit = nil;
    self.editCellIndexPath = nil;
    self.viewInput.inputContentStr = @"";
    [self.viewInput configAtUserInfoList:@[]];
    [self.viewInput configAtSegmentsInfoList:@[]];
    [self.viewInput setSendButtonHighlighted:NO];
}

//撤回
- (void)messageRevokeActionWithMsg:(NoaMessageModel *)msgModel {
    NoaMessageAlertView *msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeNomal supView:nil];
    msgAlertView.lblContent.text = LanguageToolMatch(@"撤回所选消息");
    [msgAlertView.btnSure setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
    [msgAlertView.btnSure setTkThemeTitleColor:@[COLORWHITE,COLORWHITE] forState:UIControlStateNormal];
    msgAlertView.btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2];
    [msgAlertView.btnSure setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateSelected];
    [msgAlertView.btnSure setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateHighlighted];
    
    [msgAlertView.btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    [msgAlertView.btnCancel setTkThemeTitleColor:@[COLOR_66,COLORWHITE] forState:UIControlStateNormal];
    msgAlertView.btnCancel.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F5F6F9_DARK];
    [msgAlertView.btnCancel setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateSelected];
    [msgAlertView.btnCancel setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateHighlighted];
    [msgAlertView alertShow];
    WeakSelf
    msgAlertView.sureBtnBlock = ^(BOOL isCheckBox) {
        [weakSelf messageReCallWithMsg:msgModel];
    };
}

//引用
- (void)messageReferenceActionWithMsg:(NoaMessageModel *)msgModel {
    self.viewInput.messageModelReference = msgModel;
    [self.viewInput inputViewBecomeFirstResponder];
}

//收藏
- (void)messageCollectionActionWithMsg:(NoaMessageModel *)msgModel {
    //调用收藏消息接口
    //消息的会话类型
    NSString *chatTypeStr = self.chatType == CIMChatType_SingleChat ? @"SINGLE_CHAT" : @"GROUP_CHAT";
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObjectSafe:msgModel.message.serviceMsgID forKey:@"smsgId"];
    [dic setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    [dic setObjectSafe:chatTypeStr forKey:@"chatType"];
    WeakSelf
    [IMSDKManager MessageCollectionSave:dic onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD hideHUD];
        BOOL result = [data boolValue];
        if (result) {
            [HUD showMessage:LanguageToolMatch(@"收藏成功") inView:weakSelf.view];
        } else {
            [HUD showMessage:LanguageToolMatch(@"收藏失败") inView:weakSelf.view];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg inView:weakSelf.view];
    }];
}

//多选
- (void)messageMultiSelectAction {
    NSLog(@"消息多选");
    [self.viewInput inputViewResignFirstResponder];
    
    [self.selectedMsgModels removeAllObjects];
    [self.multiSelectBottomView reloadShowMultiBottom];
    self.multiSelectBottomView.hidden = NO;
    [self.view bringSubviewToFront:self.multiSelectBottomView];
    [self.baseTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(_topView.mas_bottom);
        make.bottom.equalTo(self.multiSelectBottomView.mas_top);
    }];
    self.multiSelectStatus = YES;
    self.topView.showCancel = YES;
    self.topView.btnTime.hidden = YES;
    [self.baseTableView reloadData];
    //隐藏底部输入框
    self.viewInput.hidden = YES;
    [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NoaChatGroupNoticeTipView class]]) {
            obj.hidden = YES;
        }
    }];
    [self.view addSubview:self.messageMutiSelectView];
    [self.messageMutiSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(self.topView.mas_bottom).offset(DWScale(20));
        make.height.mas_equalTo(DWScale(24));
    }];
    WeakSelf
    [self.messageMutiSelectView setSelectCallback:^{
        for (NSInteger i = 0; i < weakSelf.messageModels.count; i++) {
            NoaMessageModel *multiClickModel = [weakSelf.messageModels objectAtIndex:i];
            multiClickModel.multiSelected = NO;
            [weakSelf.messageModels replaceObjectAtIndex:i withObject:multiClickModel];
        }
        [weakSelf.baseTableView reloadData];
        [weakSelf.baseTableView.indexPathsForVisibleRows enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGRect rect = [weakSelf.baseTableView rectForRowAtIndexPath:obj];
            CGRect cellRect = [weakSelf.baseTableView convertRect:rect toView:weakSelf.view];
            UITableViewCell *cell = [weakSelf.baseTableView.visibleCells objectAtIndex:idx];
            if ([cell isKindOfClass:[NoaMessageContentBaseCell class]]) {
                NoaMessageContentBaseCell *contentCell = (NoaMessageContentBaseCell *)cell;
                if ((cellRect.origin.y + contentCell.selectedStatusBtn.origin.y) > (weakSelf.messageMutiSelectView.origin.y)) {
                    [weakSelf multiSelectManage:obj];
                    *stop = YES;
                    return;
                }
            }
        }];
    }];
}

- (void)multiSelectManage:(NSIndexPath *)indexPath {
    [self.selectedMsgModels removeAllObjects];
    for (NSInteger i = indexPath.row; i < self.messageModels.count; i++) {
        NoaMessageModel *multiClickModel = [self.messageModels objectAtIndex:i];
        if (multiClickModel.message.messageType != CIMChatMessageType_GroupNotice && multiClickModel.message.messageType != CIMChatMessageType_CardMessage && multiClickModel.message.messageType != CIMChatMessageType_GameStickersMessage && multiClickModel.message.messageType != CIMChatMessageType_NetCallMessage &&  multiClickModel.message.messageType != CIMChatMessageType_ServerMessage && multiClickModel.message.messageType != CIMChatMessageType_ForwardMessage && multiClickModel.message.messageType != CIMChatMessageType_BackMessage && multiClickModel.message.messageSendType == CIMChatMessageSendTypeSuccess) {
            NoaMessageModel *multiClickModel = [self.messageModels objectAtIndex:i];
            if (multiClickModel.multiSelected == NO && self.selectedMsgModels.count >= Multi_Selected_Max_Num) {
                [HUD showMessage:LanguageToolMatch(@"最多选择100条消息") inView:self.view];
                break;
            }
            multiClickModel.multiSelected = YES;
            [self.messageModels replaceObjectAtIndex:i withObject:multiClickModel];
            [self.selectedMsgModels addObject:multiClickModel];
        }
    }
    [self.baseTableView reloadData];
    self.multiSelectBottomView.selectNum = self.selectedMsgModels.count;
}

//存为
- (void)messageTextContentUrlAddTagWithMsg:(NoaMessageModel *)msgModel {
    NSArray *urlArr;
    if (msgModel.message.messageType == CIMChatMessageType_TextMessage) {
        urlArr = [msgModel.message.textContent getUrlFromString];
    } else if (msgModel.message.messageType == CIMChatMessageType_AtMessage) {
        urlArr = [msgModel.message.showContent getUrlFromString];
    }
    if (urlArr.count > 0) {
        NoaChatTextUrlListView *textUrlListView = [[NoaChatTextUrlListView alloc] initWithDataList:urlArr];
        [textUrlListView viewShow];
        WeakSelf
        [textUrlListView setTextUrlClickBlock:^(NSInteger clickIndex) {
            NSString *tagUrl = (NSString *)[urlArr objectAtIndexSafe:clickIndex];
            [weakSelf chatTopViewAddNewTagWithUrl:tagUrl];
        }];
    }
}

- (void)chatTopViewAddNewTagWithUrl:(NSString *)tagUrl {
    NoaChatNavLinkAddView *addView = [[NoaChatNavLinkAddView alloc] init];
    addView.viewType = ChatLinkAddViewTypeAdd;
    addView.defaultUrlStr = tagUrl;
    [addView linkAddViewShow];
    WeakSelf
    [addView setNewTagFinsihBlock:^(NSInteger tagId, NSString * _Nonnull tagName, NSString * _Nonnull tagUrl, NSInteger updateIndex) {
        //新增
        [weakSelf.topView chatRoomAddNewTagActionWithTagName:tagName tagUrl:tagUrl];
    }];
}

//翻译
- (void)messageContentTranslateActionWithMsg:(NoaMessageModel *)msgModel {
    if ([NSString isNil:self.sessionModel.receiveTranslateChannel] && [NSString isNil:self.sessionModel.receiveTranslateLanguage]) {
        [HUD showMessage:LanguageToolMatch(@"请选择消息翻译的通道和语种") inView:self.view];
        NoaTranslateSettingVC *vc = [[NoaTranslateSettingVC alloc] init];
        vc.sessionModel = _sessionModel;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if ([NSString isNil:self.sessionModel.receiveTranslateLanguage]) {
        [HUD showMessage:LanguageToolMatch(@"请选择消息翻译的语种") inView:self.view];
        NoaTranslateSettingVC *vc = [[NoaTranslateSettingVC alloc] init];
        vc.sessionModel = _sessionModel;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    WeakSelf
    //At消息
    if (msgModel.message.messageType == CIMChatMessageType_AtMessage) {
        //@用户消息
        msgModel.message.translateStatus = CIMTranslateStatusLoading;
        [self requestTranslateActionWithContent:msgModel.message.atContent atUserDictList:msgModel.message.atUsersInfoList isSend:NO messageType:msgModel.message.messageType success:^(NSString * _Nullable result) {
            if (msgModel.isSelf) {
                msgModel.message.atTranslateContent = result;
            } else {
                msgModel.message.againAtTranslateContent = result;
            }
            msgModel.message.translateStatus = CIMTranslateStatusSuccess;
            [IMSDKManager toolInsertOrUpdateChatMessageWith:msgModel.message];
            //替换消息并刷新界面
            [weakSelf replaceMessageModelWithNewMsgModel:msgModel.message];
        } failure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            msgModel.message.translateStatus = CIMTranslateStatusFail;
            //替换消息并刷新界面
            [weakSelf replaceMessageModelWithNewMsgModel:msgModel.message];
        }];
        //替换消息并刷新界面
        [self replaceMessageModelWithNewMsgModel:msgModel.message];
    } else {
        //文本消息
        msgModel.message.translateStatus = CIMTranslateStatusLoading;
        [self requestTranslateActionWithContent:msgModel.message.textContent atUserDictList:@[] isSend:NO messageType:msgModel.message.messageType success:^(NSString * _Nullable result) {
            if (msgModel.isSelf) {
                msgModel.message.translateContent = result;
            } else {
                msgModel.message.againTranslateContent = result;
            }
            msgModel.message.translateStatus = CIMTranslateStatusSuccess;
            [IMSDKManager toolInsertOrUpdateChatMessageWith:msgModel.message];
            //替换消息并刷新界面
            [weakSelf replaceMessageModelWithNewMsgModel:msgModel.message];
        } failure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            msgModel.message.translateStatus = CIMTranslateStatusFail;
            //替换消息并刷新界面
            [weakSelf replaceMessageModelWithNewMsgModel:msgModel.message];
        }];
        //替换消息并刷新界面
        [self replaceMessageModelWithNewMsgModel:msgModel.message];
    }
}

//隐藏译文
- (void)messageContentHiddenTranslateActionWithMsg:(NoaMessageModel *)msgModel {
    msgModel.message.translateStatus = CIMTranslateStatusNone;
    //替换消息并刷新界面
    if (msgModel.isSelf) {
        msgModel.message.translateContent = nil;
        msgModel.message.atTranslateContent = nil;
    } else {
        msgModel.message.againTranslateContent = nil;
        msgModel.message.againAtTranslateContent = nil;
    }
    [self replaceMessageModelWithNewMsgModel:msgModel.message];
}

//添加表情到收藏
- (void)messageStickersAddToCollectionActionWithMsg:(NoaMessageModel *)msgModel {
    //组装接口数据
    NSMutableDictionary *stickersDic = [NSMutableDictionary dictionary];
    [stickersDic setObjectSafe:msgModel.message.stickersImg forKey:@"contentUrl"];
    [stickersDic setObjectSafe:@(msgModel.message.stickersHeight) forKey:@"height"];
    [stickersDic setObjectSafe:@(msgModel.message.stickersSize) forKey:@"size"];
    [stickersDic setObjectSafe:msgModel.message.stickersId forKey:@"stickersKey"];
    [stickersDic setObjectSafe:msgModel.message.stickersThumbnailImg forKey:@"thumbUrl"];
    [stickersDic setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    [stickersDic setObjectSafe:@(msgModel.message.stickersWidth) forKey:@"width"];
    //调用接口
    [self requestAddStickersToCollectionWithDic:stickersDic isReloadCollection:YES];
}

//听筒播放语音
- (void)messageMutePlaybackActionWithMsg:(NoaMessageModel *)msgModel cellIndex:(NSIndexPath *)cellIndex {
    NoaMessageVoiceHudView *voiceHudView = [NoaMessageVoiceHudView new];
    [self.view addSubview:voiceHudView];
    [voiceHudView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).offset(DNavStatusBarH + 20);
    }];
    if (self.multiSelectStatus) {
        return;
    }
    [ZAudioPlayerTOOL setAudioSession];
    NoaMessageVoiceCell *clickVoiceCell = (NoaMessageVoiceCell *)[self.baseTableView cellForRowAtIndexPath:cellIndex];
    NoaMessageModel *voiceMsgModel = [self.messageModels objectAtIndex:cellIndex.row];
    if (ZAudioPlayerTOOL.isPlaying) {
        [ZAudioPlayerTOOL stop];
    }
    if (clickVoiceCell.isAnimation) {
        [clickVoiceCell stopAnimation];
        [ZAudioPlayerTOOL stop];
    }
    [self voicePlay:clickVoiceCell voiceMsgModel:voiceMsgModel];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [voiceHudView removeFromSuperview];
    });
}

//查找当前表情所属表情包
- (void)messageStickersSearchPackageActionWithMsg:(NoaMessageModel *)msgModel {
    //跳转表情包详情
    NoaEmojiPackageDetailViewController *vc = [[NoaEmojiPackageDetailViewController alloc] init];
    vc.stickersId = ![NSString isNil:msgModel.message.stickersId] ? msgModel.message.stickersId : @"";
    [self.navigationController pushViewController:vc animated:YES];
}
//消息置顶
- (void)messageGroupTopActionWithMsg:(NoaMessageModel *)msgModel msgMoreMenu:(NoaChatMessageMoreView *)msgMoreMenu {
    if (!msgModel || !msgModel.message.serviceMsgID.length) {
        return;
    }
    
    // 根据用户角色显示不同的选择框
    NSInteger userGroupRole = self.groupInfo.userGroupRole; // 0=普通成员, 1=管理员, 2=群主
    
    if (userGroupRole == 0) {
        // 普通成员：显示普通提示框（带标题）
        NoaMessageAlertView *alertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeTitle supView:nil];
        alertView.lblTitle.text = LanguageToolMatch(@"置顶消息");
        alertView.lblContent.text = LanguageToolMatch(@"你确定置顶本条消息吗?");
        [alertView.btnSure setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
        [alertView.btnSure setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
        alertView.btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
        [alertView.btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
        [alertView.btnCancel setTkThemeTitleColor:@[COLOR_66, COLOR_66_DARK] forState:UIControlStateNormal];
        alertView.btnCancel.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F6F6F6_DARK];
        alertView.sureBtnBlock = ^(BOOL isCheckBox) {
            // 个人置顶
            [self doSetMsgTopWithMsgModel:msgModel msgStatus:2];
        };
        alertView.cancelBtnBlock = ^{
        };
        [alertView alertShow];
    } else {
        // 群主/管理：显示带复选框的弹框
        NoaMessageAlertView *alertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeTitleCheckBoxAboveButton supView:nil];
        alertView.lblTitle.text = LanguageToolMatch(@"置顶消息");
        alertView.lblContent.text = LanguageToolMatch(@"你确定置顶本条消息吗?");
        alertView.checkboxLblContent.text = LanguageToolMatch(@"为所有群成员置顶");
        [alertView.btnSure setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
        [alertView.btnSure setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
        alertView.btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
        [alertView.btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
        [alertView.btnCancel setTkThemeTitleColor:@[COLOR_66, COLOR_66_DARK] forState:UIControlStateNormal];
        alertView.btnCancel.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F6F6F6_DARK];
        alertView.isSelectCheckBox = NO;
        alertView.sureBtnBlock = ^(BOOL isCheckBox) {
            // 根据复选框状态决定：勾选=全局置顶(1)，未勾选=个人置顶(2)
            NSInteger msgStatus = isCheckBox ? 1 : 2;
            [self doSetMsgTopWithMsgModel:msgModel msgStatus:msgStatus];
        };
        alertView.cancelBtnBlock = ^{
        };
        [alertView alertShow];
    }
}

//消息取消置顶
- (void)messageGroupTopCancelActionWithMsg:(NoaMessageModel *)msgModel msgMoreMenu:(NoaChatMessageMoreView *)msgMoreMenu {
    if (!msgModel || !msgModel.message.serviceMsgID.length) {
        return;
    }
    
    // 获取保存的 type 值
    NSNumber *typeNum = objc_getAssociatedObject(msgMoreMenu, @"msgTopType");
    NSInteger type = typeNum ? typeNum.integerValue : 0;
    
    // 获取用户角色
    NSInteger userGroupRole = self.groupInfo ? self.groupInfo.userGroupRole : 0;
    
    // 根据 type 值和用户角色显示不同的提示框
    if (type == 2) {
        // type == 2：显示取消个人置顶弹框
        [self showCancelPersonalTopAlertWithMsgModel:msgModel];
    } else if (type == 1) {
        // type == 1：判断身份
        if (userGroupRole == 1 || userGroupRole == 2) {
            // 群主或管理员：显示取消全局置顶弹框
            [self showCancelGlobalTopAlertWithMsgModel:msgModel];
        }
        // 普通成员：不弹框
    } else if (type == 3) {
        // type == 3：根据身份显示不同弹框
        if (userGroupRole == 1 || userGroupRole == 2) {
            // 群主或管理员：显示取消全局置顶弹框
            [self showCancelGlobalTopAlertWithMsgModel:msgModel];
        } else {
            // 群成员：显示取消个人置顶弹框
            [self showCancelPersonalTopAlertWithMsgModel:msgModel];
        }
    } else {
        // 如果 type 值异常，再次查询
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
        [params setObjectSafe:self.sessionID forKey:@"groupId"];
        [params setObjectSafe:msgModel.message.serviceMsgID forKey:@"smsgId"];
        
        WeakSelf;
        [IMSDKManager MessageQueryGroupMsgStatusWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dataDic = (NSDictionary *)data;
                NSInteger currentType = [[dataDic objectForKeySafe:@"type"] integerValue];
                NSInteger currentUserGroupRole = weakSelf.groupInfo ? weakSelf.groupInfo.userGroupRole : 0;
                
                if (currentType == 2) {
                    // type == 2：显示取消个人置顶弹框
                    [weakSelf showCancelPersonalTopAlertWithMsgModel:msgModel];
                } else if (currentType == 1) {
                    // type == 1：判断身份
                    if (currentUserGroupRole == 1 || currentUserGroupRole == 2) {
                        // 群主或管理员：显示取消全局置顶弹框
                        [weakSelf showCancelGlobalTopAlertWithMsgModel:msgModel];
                    }
                    // 普通成员：不弹框
                } else if (currentType == 3) {
                    // type == 3：根据身份显示不同弹框
                    if (currentUserGroupRole == 1 || currentUserGroupRole == 2) {
                        // 群主或管理员：显示取消全局置顶弹框
                        [weakSelf showCancelGlobalTopAlertWithMsgModel:msgModel];
                    } else {
                        // 群成员：显示取消个人置顶弹框
                        [weakSelf showCancelPersonalTopAlertWithMsgModel:msgModel];
                    }
                }
            }
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            // 查询失败
        }];
    }
}

// 显示取消全局置顶提示框
- (void)showCancelGlobalTopAlertWithMsgModel:(NoaMessageModel *)msgModel {
    NoaMessageAlertView *alertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeTitle supView:nil];
    alertView.lblTitle.text = LanguageToolMatch(@"取消全局置顶");
    alertView.lblContent.text = LanguageToolMatch(@"你确定取消本条消息的全局置顶吗?");
    [alertView.btnSure setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
    [alertView.btnSure setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
    alertView.btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    [alertView.btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    [alertView.btnCancel setTkThemeTitleColor:@[COLOR_66, COLOR_66_DARK] forState:UIControlStateNormal];
    alertView.btnCancel.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F6F6F6_DARK];
    alertView.sureBtnBlock = ^(BOOL isCheckBox) {
        // 取消全局置顶
        [self doSetMsgTopWithMsgModel:msgModel msgStatus:3];
    };
    alertView.cancelBtnBlock = ^{
    };
    [alertView alertShow];
}

// 显示取消置顶提示框（个人置顶）
- (void)showCancelPersonalTopAlertWithMsgModel:(NoaMessageModel *)msgModel {
    NoaMessageAlertView *alertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeTitle supView:nil];
    alertView.lblTitle.text = LanguageToolMatch(@"取消置顶");
    alertView.lblContent.text = LanguageToolMatch(@"你确定取消本条置顶消息吗?");
    [alertView.btnSure setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
    [alertView.btnSure setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
    alertView.btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    [alertView.btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    [alertView.btnCancel setTkThemeTitleColor:@[COLOR_66, COLOR_66_DARK] forState:UIControlStateNormal];
    alertView.btnCancel.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F6F6F6_DARK];
    alertView.sureBtnBlock = ^(BOOL isCheckBox) {
        // 取消个人置顶
        [self doSetMsgTopWithMsgModel:msgModel msgStatus:4];
    };
    alertView.cancelBtnBlock = ^{
    };
    [alertView alertShow];
}

//执行置顶/取消置顶操作
- (void)doSetMsgTopWithMsgModel:(NoaMessageModel *)msgModel msgStatus:(NSInteger)msgStatus {
    if (!msgModel || !msgModel.message.serviceMsgID.length) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    [params setObjectSafe:self.sessionID forKey:@"groupId"];
    [params setObjectSafe:msgModel.message.serviceMsgID forKey:@"smsgId"];
    [params setObjectSafe:@(msgStatus) forKey:@"msgStatus"];
    
    WeakSelf;
    [IMSDKManager groupSetMsgTopWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        // 置顶/取消置顶成功，更新置顶消息列表
        if (weakSelf && weakSelf.chatType == CIMChatType_GroupChat) {
            [weakSelf requestGroupTopMessages];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        // 置顶/取消置顶失败
        [HUD showMessageWithCode:code errorMsg:msg inView:weakSelf.view];
    }];
}

//单聊消息置顶
- (void)messageSingleTopActionWithMsg:(NoaMessageModel *)msgModel msgMoreMenu:(NoaChatMessageMoreView *)msgMoreMenu {
    if (!msgModel || !msgModel.message.serviceMsgID.length) {
        return;
    }
    
    // 显示带复选框的弹框
    NoaMessageAlertView *alertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeTitleCheckBoxAboveButton supView:nil];
    alertView.lblTitle.text = LanguageToolMatch(@"置顶消息");
    alertView.lblContent.text = LanguageToolMatch(@"你确定置顶本条消息吗?");
    alertView.checkboxLblContent.text = LanguageToolMatch(@"我和对方均置顶");
    [alertView.btnSure setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
    [alertView.btnSure setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
    alertView.btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    [alertView.btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    [alertView.btnCancel setTkThemeTitleColor:@[COLOR_66, COLOR_66_DARK] forState:UIControlStateNormal];
    alertView.btnCancel.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F6F6F6_DARK];
    alertView.isSelectCheckBox = NO;
    alertView.sureBtnBlock = ^(BOOL isCheckBox) {
        // 根据复选框状态决定：勾选=全局置顶(1)，未勾选=个人置顶(2)
        NSInteger msgStatus = isCheckBox ? 1 : 2;
        [self doSetSingleMsgTopWithMsgModel:msgModel msgStatus:msgStatus];
    };
    alertView.cancelBtnBlock = ^{
    };
    [alertView alertShow];
}

//单聊消息取消置顶
- (void)messageSingleTopCancelActionWithMsg:(NoaMessageModel *)msgModel msgMoreMenu:(NoaChatMessageMoreView *)msgMoreMenu {
    if (!msgModel || !msgModel.message.serviceMsgID.length) {
        return;
    }
    
    // 获取保存的 type 值
    NSNumber *typeNum = objc_getAssociatedObject(msgMoreMenu, @"msgTopType");
    NSInteger type = typeNum ? typeNum.integerValue : 0;
    
    // 根据 type 值显示不同的提示框
    if (type == 1 || type == 3) {
        // type == 1 或 type == 3：显示取消全局置顶弹框
        [self showCancelSingleGlobalTopAlertWithMsgModel:msgModel];
    } else if (type == 2) {
        // type == 2：显示取消置顶弹框
        [self showCancelSingleTopAlertWithMsgModel:msgModel];
    } else {
        // 如果 type 值异常，再次查询
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
        [params setObjectSafe:self.sessionID forKey:@"friendUid"];
        [params setObjectSafe:msgModel.message.serviceMsgID forKey:@"smsgId"];
        
        WeakSelf;
        [IMSDKManager MessageQueryUserMsgStatusWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dataDic = (NSDictionary *)data;
                NSInteger currentType = [[dataDic objectForKeySafe:@"type"] integerValue];
                
                if (currentType == 1 || currentType == 3) {
                    // type == 1 或 type == 3：显示取消全局置顶弹框
                    [weakSelf showCancelSingleGlobalTopAlertWithMsgModel:msgModel];
                } else if (currentType == 2) {
                    // type == 2：显示取消置顶弹框
                    [weakSelf showCancelSingleTopAlertWithMsgModel:msgModel];
                }
            }
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            // 查询失败
        }];
    }
}

// 显示取消单聊全局置顶提示框
- (void)showCancelSingleGlobalTopAlertWithMsgModel:(NoaMessageModel *)msgModel {
    NoaMessageAlertView *alertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeTitle supView:nil];
    alertView.lblTitle.text = LanguageToolMatch(@"取消全局置顶");
    alertView.lblContent.text = LanguageToolMatch(@"你确定取消本条消息的全局置顶吗?");
    [alertView.btnSure setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
    [alertView.btnSure setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
    alertView.btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    [alertView.btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    [alertView.btnCancel setTkThemeTitleColor:@[COLOR_66, COLOR_66_DARK] forState:UIControlStateNormal];
    alertView.btnCancel.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F6F6F6_DARK];
    alertView.sureBtnBlock = ^(BOOL isCheckBox) {
        // 取消全局置顶
        [self doSetSingleMsgTopWithMsgModel:msgModel msgStatus:3];
    };
    alertView.cancelBtnBlock = ^{
    };
    [alertView alertShow];
}

// 显示取消单聊置顶提示框（个人置顶）
- (void)showCancelSingleTopAlertWithMsgModel:(NoaMessageModel *)msgModel {
    NoaMessageAlertView *alertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeTitle supView:nil];
    alertView.lblTitle.text = LanguageToolMatch(@"取消置顶");
    alertView.lblContent.text = LanguageToolMatch(@"你确定取消本条置顶消息吗?");
    [alertView.btnSure setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
    [alertView.btnSure setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
    alertView.btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    [alertView.btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    [alertView.btnCancel setTkThemeTitleColor:@[COLOR_66, COLOR_66_DARK] forState:UIControlStateNormal];
    alertView.btnCancel.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F6F6F6_DARK];
    alertView.sureBtnBlock = ^(BOOL isCheckBox) {
        // 取消个人置顶
        [self doSetSingleMsgTopWithMsgModel:msgModel msgStatus:4];
    };
    alertView.cancelBtnBlock = ^{
    };
    [alertView alertShow];
}

//执行单聊置顶/取消置顶操作
- (void)doSetSingleMsgTopWithMsgModel:(NoaMessageModel *)msgModel msgStatus:(NSInteger)msgStatus {
    if (!msgModel || !msgModel.message.serviceMsgID.length) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    [params setObjectSafe:self.sessionID forKey:@"friendUid"];
    [params setObjectSafe:msgModel.message.serviceMsgID forKey:@"smsgId"];
    [params setObjectSafe:@(msgStatus) forKey:@"msgStatus"];
    
    WeakSelf;
    [IMSDKManager MessageSetMsgTopWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        // 置顶/取消置顶成功，更新置顶消息列表
        if (weakSelf && weakSelf.chatType == CIMChatType_SingleChat) {
            [weakSelf requestSingleTopMessages];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        // 置顶/取消置顶失败
        [HUD showMessageWithCode:code errorMsg:msg inView:weakSelf.view];
    }];
}

//请求单聊置顶消息列表（悬浮窗数据）
- (void)requestSingleTopMessages {
    if (self.chatType != CIMChatType_SingleChat || !self.sessionID.length) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    [params setObjectSafe:@(0) forKey:@"type"]; // type=0 查询悬浮的10条记录
    [params setObjectSafe:self.sessionID forKey:@"friendUid"];
    
    WeakSelf
    [IMSDKManager MessageQueryUserTopMsgsWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        // data 直接就是数组
        NSArray *rows = nil;
        if ([data isKindOfClass:[NSArray class]]) {
            rows = (NSArray *)data;
        }
        
        if ([rows isKindOfClass:[NSArray class]] && rows.count > 0) {
            // 取出所有数据，直接传递字典数组
            [weakSelf.groupTopMessageView updateWithTopMessages:rows sessionID:weakSelf.sessionID];
        } else {
            [weakSelf.groupTopMessageView updateWithTopMessages:nil sessionID:weakSelf.sessionID];
        }
        // 延迟更新 header 高度，等待 groupTopMessageView 的显示/隐藏动画完成（动画时间 0.3 秒）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf updateTableViewContentInset];
        });
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [ZTOOL doInMain:^{
            // 请求失败，隐藏置顶消息 View
            [weakSelf.groupTopMessageView updateWithTopMessages:nil sessionID:weakSelf.sessionID];
            // 延迟更新 header 高度，等待 groupTopMessageView 的显示/隐藏动画完成（动画时间 0.3 秒）
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf updateTableViewContentInset];
            });
        }];
    }];
}

//替换messageModel
- (void)replaceMessageModelWithNewMsgModel:(NoaIMChatMessageModel *)chatMessageModel {
    for(int i = 0; i<self.messageModels.count;i++) {
        NoaMessageModel *tempMessagModel = (NoaMessageModel *)[self.messageModels objectAtIndex:i];
        if ([tempMessagModel.message.msgID isEqualToString:chatMessageModel.msgID]) {
            NoaMessageModel *newMessagModel = [[NoaMessageModel alloc] initWithMessageModel:chatMessageModel];
            [self.messageModels replaceObjectAtIndex:i withObject:newMessagModel];
            //刷新界面
            [self.baseTableView reloadData];
            WeakSelf
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.26 * NSEC_PER_SEC));
            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                //加载滚动到底部
                [weakSelf tableViewScrollToBottom:NO duration:0.08];
            });
        }
    }
}

#pragma mark - Network Request
//删除消息(单向/双向)
- (void)messageDeleteWithSMgIds:(NSArray *)sMsgIdsList withDeleteType:(ZMsgDeleteType)deleteType {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithInteger:self.chatType],@"chatType",
                    @"",@"msgId",
                    sMsgIdsList,@"msgIdList",
                    [NSNumber numberWithInteger:deleteType],@"operationStatus",
                    self.sessionID,@"receiveId",
                    UserManager.userInfo.userUID,@"userUid",
                    @"",@"sMsgId",nil];
    
    WeakSelf
    [HUD showActivityMessage:LanguageToolMatch(@"删除中...") inView:self.view];
    [[NoaIMSDKManager sharedTool] deleteMessage:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [weakSelf.selectedMsgModels enumerateObjectsUsingBlock:^(NoaMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //接口成功后，删除本地
            BOOL isDelete = [IMSDKManager toolDeleteChatMessageWith:obj.message];
            if (isDelete) {
                [weakSelf updateDeleteMessageAndRefreshMsgWithOriginalMsg:obj.message.serviceMsgID];
            }
        }];
      
        [weakSelf setupMultiSelectedStatusDefaultIsReload:NO];
        //处理消息是否显示时间
        [weakSelf computeVisibleTime];
        [ZTOOL doInMain:^{
            [weakSelf.baseTableView reloadData];
        }];
        [HUD showMessage:LanguageToolMatch(@"消息删除成功") inView:weakSelf.view];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessage:LanguageToolMatch(@"消息删除失败") inView:weakSelf.view];
        [weakSelf setupMultiSelectedStatusDefaultIsReload:YES];
    }];
}

//消息撤回
- (void)messageReCallWithMsg:(NoaMessageModel *)msgModel {
    //status  消息的状态：1-正常，2-撤回，3-删除
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithInteger:msgModel.message.chatType],@"chatType",
                                   UserManager.userInfo.userUID,@"userUid",
                                   UserManager.userInfo.nickname,@"operateNick",
                                   msgModel.message.toID,@"receiveId",
                                   msgModel.message.serviceMsgID,@"sMsgId",
                                   [NSNumber numberWithInteger:2],@"status",
                                   msgModel.message.fromID,@"uid",nil];
    
    WeakSelf
    [IMSDKManager recallMessage:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        BOOL isRecalled = [data boolValue];
        if (isRecalled) {
            //撤回成功后，本地删除该条消息，修改消息状态为2(其实收到撤回提示消息已经做了处理，这个可以不用写的，但...)
            BOOL isDelete = [IMSDKManager toolBackDeleteChatMessageWith:msgModel.message];
            if (isDelete) {
                [weakSelf.messageModels removeObject:msgModel];
                //处理消息是否显示时间
                [weakSelf computeVisibleTime];
                [ZTOOL doInMain:^{
                    [weakSelf.baseTableView reloadData];
                }];
                
                if ([msgModel.message.fromID isEqualToString:UserManager.userInfo.userUID]) {
                    [weakSelf updateRefreshMsgWithOriginalMsg:msgModel.message.serviceMsgID];
                }
            }
        } else {
            [HUD showMessage:LanguageToolMatch(@"消息撤回失败") inView:weakSelf.view];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg inView:weakSelf.view];
    }];
}
//添加好友
- (void)chatAddFriend {
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.sessionID forKey:@"friendUserUid"];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    
    [IMSDKManager addContactWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD showMessage:LanguageToolMatch(@"已发送") inView:weakSelf.view];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg inView:weakSelf.view];
    }];
}
#pragma mark - Loading超时处理
//启动loading超时计时器（30秒）
- (void)startLoadingTimeoutTimer {
    // 先取消之前的计时器（如果存在）
    [self stopLoadingTimeoutTimer];
    
    WeakSelf
    self.loadingTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:20.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [weakSelf checkAndHideLoadingIfNeeded];
    }];
}

//停止loading超时计时器
- (void)stopLoadingTimeoutTimer {
    if (self.loadingTimeoutTimer) {
        [self.loadingTimeoutTimer invalidate];
        self.loadingTimeoutTimer = nil;
    }
}

//检查并隐藏loading（如果还在显示）
- (void)checkAndHideLoadingIfNeeded {
    // 检查当前view上是否还有HUD显示
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    if (hud != nil) {
        // loading还在显示，隐藏它
        [HUD hideHUD];
    }
    // 如果loading已经隐藏，不做任何操作
    [HUD hideHUD];
}


#pragma mark - Other
//计算每条消息是否显示时间
-(void)computeVisibleTime {
    WeakSelf
    dispatch_async(_chatMessageCalculateTimeQueue, ^{
        NSArray *snapshot = [weakSelf.messageModels safeArray];
        if (snapshot.count == 0) { return; }
        NSMutableArray *updated = [snapshot mutableCopy];
        long long prevSendTime = 0;
        for (NSUInteger i = 0; i < updated.count; i++) {
            NoaMessageModel *msg = updated[i];
            if (i == 0) {
                prevSendTime = msg.message.sendTime;
                msg.isShowSendTime = YES;
            } else {
                BOOL sameDay = [NoaMessageTimeTool isSameDay:msg.message.sendTime Time2:prevSendTime];
                msg.isShowSendTime = sameDay ? NO : YES;
                prevSendTime = msg.message.sendTime;
            }
            updated[i] = msg;
        }
        // 批量一次性写入，避免多次 barrier
        [weakSelf.messageModels replaceAllObjectsWithArray:updated];
    });
}

//如果某条消息增加、删除、撤回等单条消息操作后，只需继续该消息和前一条消息的时间间隔
- (void)computeOneMessageVisibleTimeWithMessage:(NoaMessageModel *)currentMsg currentIndex:(NSInteger)currentIndex {
    if (currentIndex < self.messageModels.count) {
        if (currentIndex == 0) {
            currentMsg.isShowSendTime = YES;
        } else {
            NoaMessageModel *prevMessage = [self.messageModels objectAtIndex:currentIndex - 1];
            //如果聊天消息是同一天的，不显示间隔的日期
            if ([NoaMessageTimeTool isSameDay:currentMsg.message.sendTime Time2: prevMessage.message.sendTime]){
                //不显示时间
                currentMsg.isShowSendTime = NO;
            } else {
                //不显示时间
                currentMsg.isShowSendTime = YES;
            }
        }
        [self.messageModels replaceObjectAtIndex:currentIndex withObject:currentMsg];
    }
}

#pragma mark - 获取可视化的cell执行选中的动画
- (void)checkVisibleCellDoAnimation {
    if (!_chatHistorySelectIndex) return;;
    
    NoaMessageModel *selectedModel = [self.messageModels objectAtIndex:_chatHistorySelectIndex.row];
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [ZTOOL doInMain:^{
            NSArray <NSIndexPath *> *visibleList = [weakSelf.baseTableView indexPathsForVisibleRows];
            [visibleList enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NoaMessageModel *model = [weakSelf.messageModels objectAtIndex:obj.row];
                if ([selectedModel.message.msgID isEqualToString:model.message.msgID]) {
                    //需要执行动画的cell
                    NoaMessageBaseCell *cellBase = [weakSelf.baseTableView cellForRowAtIndexPath:weakSelf.chatHistorySelectIndex];
                    [cellBase mesaagePositionAnimation];
                    //动画执行完后，注销记录
                    weakSelf.chatHistorySelectIndex = nil;
                    *stop = YES;
                }
            }];
            
        }];
    });
}

#pragma mark - ******图片和视频的浏览******
- (void)imageVideoBrowserWith:(NoaIMChatMessageModel *)messageModel {
    if ([NSString isNil:_sessionID]) return;
    
    NSArray *currentImageVideoMessageList = [IMSDKManager toolGetChatMessageHistoryWith:_sessionID offset:0 messageType:@[@(CIMChatMessageType_VideoMessage), @(CIMChatMessageType_ImageMessage)] textMessageLike:nil];
    currentImageVideoMessageList = [[currentImageVideoMessageList reverseObjectEnumerator] allObjects];
    _currentImageVideoMessageList = currentImageVideoMessageList;
    
    WeakSelf
    __block NSMutableArray *browserMessages = [NSMutableArray array];
    __block NSInteger messageModelIndex = 0;//点击的cell在图片视频列表中的位置
    [currentImageVideoMessageList enumerateObjectsUsingBlock:^(NoaIMChatMessageModel * _Nonnull chatMessage, NSUInteger idx, BOOL * _Nonnull stop) {
        //找到被点击的消息 下标
        if ([messageModel.msgID isEqualToString:chatMessage.msgID]) {
            messageModelIndex = idx;
        }
        if (chatMessage.messageType == CIMChatMessageType_ImageMessage) {
            KNPhotoItems *item = [[KNPhotoItems alloc] init];
            //图片
            item.isVideo = false;
            //网络图片
            item.url = [chatMessage.imgName getImageFullString];
            //缩略图地址
            item.thumbnailUrl = [chatMessage.thumbnailImg getImageFullString];
            [browserMessages addObjectIfNotNil:item];
        } else if (chatMessage.messageType == CIMChatMessageType_VideoMessage) {
            //视频
            KNPhotoItems *item = [[KNPhotoItems alloc] init];
            item.isVideo = true;
            if (chatMessage.localVideoCover) {
                //本地视频封面
                NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, weakSelf.sessionID];
                NSString *pathStr = [NSString getPathWithImageName:chatMessage.localVideoCover CustomPath:customPath];
                UIImage *localImage = [NSString getImageWithImgName:chatMessage.localVideoCover CustomPath:customPath];
                if (localImage) {
                    item.videoPlaceHolderImageUrl = pathStr;
                } else {
                    //网络视频封面
                    item.videoPlaceHolderImageUrl = [chatMessage.videoCover getImageFullString];
                }
            }else {
                //网络视频封面
                item.videoPlaceHolderImageUrl = [chatMessage.videoCover getImageFullString];
                //item.videoPlaceHolderImageUrlThumbnail视频封面缩略图地址
            }
            if (chatMessage.localVideoName) {
                //本地视频地址
                NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, weakSelf.sessionID];
                NSString *videoUrl = [NSString getPathWithVideoName:chatMessage.localVideoName CustomPath:customPath];
                NSData *localVideoData = [NSString getVideoDataWithVideoName:chatMessage.localVideoName CustomPath:customPath];
                if (localVideoData) {
                    item.url = videoUrl;
                } else {
                    item.url = [chatMessage.videoName getImageFullString];
                }
            } else {
                //网络视频地址
                item.url = [chatMessage.videoName getImageFullString];
            }
            [browserMessages addObjectIfNotNil:item];
        }
    }];
    
    KNPhotoBrowser *photoBrowser = [[KNPhotoBrowser alloc] init];
    [KNPhotoBrowserConfig share].isNeedCustomActionBar = false;
    photoBrowser.delegate = self;
    photoBrowser.itemsArr = browserMessages;
    photoBrowser.placeHolderColor = UIColor.lightTextColor;
    photoBrowser.currentIndex = messageModelIndex;
    photoBrowser.isSoloAmbient = true;//音频模式
    photoBrowser.isNeedPageNumView = false;//分页
    photoBrowser.isNeedRightTopBtn = true;//更多按钮
    photoBrowser.isNeedLongPress = false;//长按
    photoBrowser.isNeedPanGesture = true;//拖拽
    photoBrowser.isNeedPrefetch = true;//预取图像(最大8)
    photoBrowser.isNeedAutoPlay = true;//自动播放
    photoBrowser.isNeedOnlinePlay = false;//在线播放(先自动下载视频)
    [photoBrowser present];
}

#pragma mark - KNPhotoBrowserDelegate
//图片浏览右侧按钮点击事件
- (void)photoBrowser:(KNPhotoBrowser *)photoBrowser rightBtnOperationActionWithIndex:(NSInteger)index {
    NoaIMChatMessageModel *currentModel = [_currentImageVideoMessageList objectAtIndexSafe:index];
    
    NSString *imageUrl;
    NSString *videoUrl;
    if (currentModel.messageType == CIMChatMessageType_ImageMessage) {
        imageUrl = [currentModel.imgName getImageFullString];
    }else if (currentModel.messageType == CIMChatMessageType_VideoMessage) {
        //视频
        if (currentModel.localVideoName) {
            //本地视频地址
            NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, self.sessionID];
            videoUrl = [NSString getPathWithVideoName:currentModel.localVideoName CustomPath:customPath];
        }else {
            //网络视频地址
            videoUrl = [currentModel.videoName getImageFullString];
        }
    }
    
    WeakSelf
    NoaPresentItem *saveItem = [NoaPresentItem creatPresentViewItemWithText:LanguageToolMatch(@"保存到手机") textColor:COLOR_11 font:FONTR(17) itemHeight:DWScale(54) backgroundColor:COLORWHITE];
    self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        if (themeIndex == 0) {
            saveItem.textColor = COLOR_11;
            saveItem.backgroundColor = COLORWHITE;
        }else {
            saveItem.textColor = COLORWHITE;
            saveItem.backgroundColor = COLOR_11;
        }
    };
    NoaPresentItem *cancelItem = [NoaPresentItem creatPresentViewItemWithText:LanguageToolMatch(@"取消") textColor:COLOR_99 font:FONTR(17) itemHeight:DWScale(54) backgroundColor:COLORWHITE];
    self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        if (themeIndex == 0) {
            cancelItem.textColor = COLOR_99;
            cancelItem.backgroundColor = COLORWHITE;
        }else {
            cancelItem.textColor = COLOR_99;
            cancelItem.backgroundColor = COLOR_11;
        }
    };
    NoaPresentView *viewAlert = [[NoaPresentView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DScreenHeight) titleItem:nil selectItems:@[saveItem] cancleItem:cancelItem doneClick:^(NSInteger index) {
        if (![NSString isNil:imageUrl]) {
            NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, weakSelf.sessionID];
            [ZTOOL saveImageToAlbumWith:imageUrl Cusotm:customPath];
        }
        if (![NSString isNil:videoUrl]) {
            [weakSelf saveVideoToAlbumWithUrl:videoUrl];
        }
        
    } cancleClick:^{
    }];
    [CurrentVC.view addSubview:viewAlert];
    [viewAlert showPresentView];
}

//保存视频到相册
- (void)saveVideoToAlbumWithUrl:(NSString *)videoUrl {
    [HUD showActivityMessage:LanguageToolMatch(@"正在保存...") inView:self.view];
    //此处的逻辑应该是，先查询本地缓存有没有该视频
    //有的话，直接保存，没有的话先缓存到本地，再保存
    NSString *videoPath = [ZTOOL videoExistsWith:videoUrl];
    if (![NSString isNil:videoPath]) {
        //已有缓存，直接保存
        [ZTOOL saveVideoToAlbumWith:videoPath];
    }else {
        //先下载缓存，再保存
        [ZTOOL downloadVideoWith:videoUrl completion:^(BOOL success, NSString * _Nonnull videoPath) {
            if (success) {
                [ZTOOL saveVideoToAlbumWith:videoPath];
            }
        }];
    }
}

#pragma mark - ZChatGroupNoticeTipViewDelegate 群公告提示代理方法
- (void)groupNoticeTipAction:(NSInteger)actionTag {
    if (actionTag == 0) {
        if (_groupNoticeModel) {
            //关闭的时候，标记该置顶群公告为已读状态
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:self.sessionID forKey:@"groupId"];
            [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
            [dict setValue:_groupNoticeModel.noticeId forKey:@"noticeId"];
            [IMSDKManager groupReadGroupNoticeWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            }];
        }
        //关闭
        if (_viewGroupNotice) {
            [_viewGroupNotice removeFromSuperview];
            _viewGroupNotice = nil;
        }
        // 关闭群公告后，重新请求并显示群置顶消息（如果有）
        if (self.chatType == CIMChatType_GroupChat) {
            [self requestGroupTopMessages];
        }

    }else {
        //跳转到群公告界面
        /**
         * TODO: 旧代码：跳转到编辑页面
         NoaGroupModifyNoticeVC * vc = [NoaGroupModifyNoticeVC new];
         */
        
        // TODO: 新版本：跳转到列表页面
        NoaGroupNoticeListVC *vc = [NoaGroupNoticeListVC new];
        vc.groupInfoModel = self.groupInfo;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - 消息定时删除功能逻辑处理
//获取定时删除消息信息
- (void)requestMessageTimeDeleteInfo {
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_sessionID forKey:@"peerUid"];//会话ID
    [dict setValue:@(_chatType) forKey:@"dialogType"];//聊天类型
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];//操作人
    [IMSDKManager MessageTimeDeleteInfoWith:dict onSuccess:^(id  _Nullable data, long long serviceTime) {
        [HUD hideHUD];
        if([data isKindOfClass:[NSDictionary class]]){
            NSDictionary *dataDict = (NSDictionary *)data;
            NSInteger freqValue = [[dataDict objectForKeySafe:@"freq"] integerValue];
            weakSelf.messageTimeDeleteType = freqValue;
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD hideHUD];
    }];
}

//定时按钮点击事件
- (void)messageTimeDeleteViewShow {
    [self hideKeyBoardAndEmjoy];
    NoaMessageTimeDeleteView *timeDeleteView;
    if (_messageTimeDeleteType == 0) {
        timeDeleteView = [[NoaMessageTimeDeleteView alloc] initWithShowCloseView:NO];
    }else {
        timeDeleteView = [[NoaMessageTimeDeleteView alloc] initWithShowCloseView:YES];
    }
    timeDeleteView.delegate = self;
    [timeDeleteView viewShow];
}

#pragma mark - ZMessageTimeDeleteViewDelegate
- (void)messageTimeDeleteType:(NSInteger)deleteType {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@(_chatType) forKey:@"dialogType"];
    [dict setValue:_sessionID forKey:@"peerUid"];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    [dict setValue:@(deleteType) forKey:@"freq"];
    WeakSelf
    [IMSDKManager MessageTimeDeleteSetWith:dict onSuccess:^(id  _Nullable data, long long serviceTime) {
        //设置成功后，根据接收到的推送消息来处理消息定时删除的逻辑
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg inView:weakSelf.view];
    }];
}

#pragma mark - LiveKit 音视频通话 邀请者 单聊
- (void)lkCallRequestForSingleWith:(LingIMCallType)callType {
    if (!_userModel) return;
    if ([NoaMediaCallManager sharedManager].mediaCallState != ZMediaCallStateEnd) return;

    NoaMediaCallOptions *callOptions = [NoaMediaCallOptions new];
    callOptions.callType = callType;//语音/视频通话
    callOptions.callRoleType = LingIMCallRoleTypeRequest;//发起者
    callOptions.callRoomType = ZIMCallRoomTypeSingle;//单人视频聊天
    callOptions.inviterUid = UserManager.userInfo.userUID;//发起者Uid
    callOptions.inviteeUid = self.sessionID;
    callOptions.callMicState = LingIMCallMicrophoneMuteStateOff;//音频打开
    callOptions.callCameraState = callType == LingIMCallTypeVideo ? LingIMCallCameraMuteStateOff : LingIMCallCameraMuteStateOn;//视频通话的时候 视频打开
    [NoaMediaCallManager sharedManager].currentCallOptions = callOptions;
    [NoaMediaCallManager sharedManager].userModel = self.userModel;
    [[NoaMediaCallManager sharedManager] mediaCallRequestWith:callOptions onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [NoaMediaCallManager sharedManager].mediaCallState = ZMediaCallStateBegin;
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [NoaMediaCallManager sharedManager].mediaCallState = ZMediaCallStateEnd;
    }];
}

#pragma mark - LiveKit 音视频通话 邀请者 群聊
- (void)lkCallRequestForGroupWith:(LingIMCallType)callType {
    WeakSelf
    if ([NoaMediaCallManager sharedManager].mediaCallState != ZMediaCallStateEnd) return;
    
    [ZTOOL doInMain:^{
        NoaMediaCallMoreInviteVC *vc = [NoaMediaCallMoreInviteVC new];
        vc.groupID = weakSelf.sessionID;
        vc.callType = callType;//语音/视频通话
        vc.requestMore = 1;
        vc.currentRoomUser = @[UserManager.userInfo.userUID];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
    
}

#pragma mark - 即构 音视频通话 邀请者 单聊
- (void)zgCallRequestForSingleWith:(LingIMCallType)callType {
    if (!_userModel) return;
    if ([NoaCallManager sharedManager].callState != ZCallStateEnd) return;
    
    //被被邀请者信息配置
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_userModel.userUID forKey:@"userID"];
    [dict setValue:_userModel.showName forKey:@"userShowName"];
    [dict setValue:_userModel.avatar forKey:@"userAvatar"];
    
    [[NoaCallManager sharedManager] requestSingleCallWith:dict callType:callType];
}

#pragma mark - 即构 音视频通话 邀请者 群聊
- (void)zgCallRequestForGroupWith:(LingIMCallType)callType {
    WeakSelf
    [ZTOOL doInMain:^{
        NoaMediaCallMoreInviteVC *vc = [NoaMediaCallMoreInviteVC new];
        vc.groupID = weakSelf.sessionID;
        vc.callType = callType;
        vc.requestMore = 1;
        vc.currentRoomUser = @[UserManager.userInfo.userUID];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
}

#pragma mark - Lazy
- (SyncMutableArray *)messageModels {
    if (!_messageModels) {
        _messageModels = [[SyncMutableArray alloc] init];
    }
    return _messageModels;
}

- (NoaChatGroupCallTipView *)viewGroupCallTip {
    if (!_viewGroupCallTip) {
        _viewGroupCallTip = [[NoaChatGroupCallTipView alloc] initWithFrame:CGRectMake(DWScale(17), DWScale(10) + DNavStatusBarH + DWScale(40), DScreenWidth - DWScale(34), DWScale(52))];
        _viewGroupCallTip.groupID = _sessionID;
    }
    return _viewGroupCallTip;
}

- (NoaChatGroupNoticeTipView *)viewGroupNotice {
    if (!_viewGroupNotice) {
        _viewGroupNotice = [[NoaChatGroupNoticeTipView alloc] initWithFrame:CGRectMake(DWScale(DWScale(17)), DStatusBarH + 44 + DWScale(40) + DWScale(10), DScreenWidth - DWScale(34), DWScale(42))];
        _viewGroupNotice.delegate = self;
    }
    return _viewGroupNotice;
}

- (ZGroupTopMessageView *)groupTopMessageView {
    if (!_groupTopMessageView) {
        _groupTopMessageView = [[ZGroupTopMessageView alloc] initWithFrame:CGRectMake(DWScale(16), DStatusBarH + 44 + DWScale(40) + DWScale(8), DScreenWidth - DWScale(32), DWScale(48))];
        _groupTopMessageView.delegate = self;
        [self.view addSubview:_groupTopMessageView];
    }
    return _groupTopMessageView;
}

- (NoaChatMultiSelectSendHander *)collectionSendHander {
    if (!_collectionSendHander) {
        _collectionSendHander = [[NoaChatMultiSelectSendHander alloc] init];
    }
    return _collectionSendHander;
}

- (NoaMessageMultiBottomView *)multiSelectBottomView {
    if (!_multiSelectBottomView) {
        _multiSelectBottomView = [[NoaMessageMultiBottomView alloc] initWithFrame:CGRectMake(0, DScreenHeight - DWScale(56) - DHomeBarH, DScreenWidth, DWScale(56) + DHomeBarH)];
        _multiSelectBottomView.hidden = YES;
        _multiSelectBottomView.delegate = self;
    }
    return _multiSelectBottomView;
}

- (SyncMutableArray *)selectedMsgModels {
    if (!_selectedMsgModels) {
        _selectedMsgModels = [[SyncMutableArray alloc] init];
    }
    return _selectedMsgModels;
}

-(LingIMSessionModel *)sessionModel{
    if (_sessionModel == nil) {
        _sessionModel = [IMSDKManager toolCheckMySessionWith:self.sessionID];
    }
    return _sessionModel;
}

- (SyncMutableArray *)unReadSmsgidList {
    if (!_unReadSmsgidList) {
        _unReadSmsgidList = [[SyncMutableArray alloc] init];
    }
    return _unReadSmsgidList;
}

- (NoaTranslateDefaultModel *)defaultModel{
    if (_defaultModel == nil) {
        _defaultModel = [[NoaTranslateDefaultModel alloc] init];
    }
    return _defaultModel;
}

- (ZMessageMultiSelectView *)messageMutiSelectView{
    if (_messageMutiSelectView == nil) {
        _messageMutiSelectView = [[ZMessageMultiSelectView alloc] init];
    }
    return _messageMutiSelectView;
}

- (NoaChatAtBannedView *)atBannedView {
    if (_atBannedView == nil) {
        _atBannedView = [[NoaChatAtBannedView alloc] init];
    }
    return _atBannedView;
}

#pragma mark - life cycle
- (void)didMoveToParentViewController:(UIViewController *)parent{
    // 无论push 进来 还是 pop 出去 正常跑
    // 就算继续push 到下一层 pop 回去还是继续
    if (parent == nil) {
        [self.timer invalidate];
        self.timer = nil;
        
        [self.uploadReadedTimer invalidate];
        self.uploadReadedTimer = nil;
        [self stopLoadingTimeoutTimer];

        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}
#pragma mark - ZGroupTopMessageViewDelegate
- (void)groupTopMessageViewDidClickListButton:(ZGroupTopMessageView *)view {
    // 跳转到消息置顶列表页面
    ZGroupTopMessageListViewController *vc = [[ZGroupTopMessageListViewController alloc] init];
    vc.groupId = self.sessionID;
    vc.groupInfo = self.groupInfo;
    // 传递会话类型
    vc.chatType = self.chatType;
    vc.friendUid = self.chatType == CIMChatType_SingleChat ? self.sessionID : nil;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)groupTopMessageViewDidClickLocationButtonWithSmsgId:(NSString *)smsgId {
    // 在列表页面中点击定位按钮，跳转到对应的消息位置
    // TODO: 实现定位到消息的逻辑
}

- (void)groupTopMessageViewDidClickView:(ZGroupTopMessageView *)view {
    // 点击整个 view 时，定位当前显示的消息
    NSString *smsgId = [view currentSmsgId];
    if (smsgId.length > 0) {
        // 发送通知定位消息
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TopMessageLocationNotification" object:nil userInfo:@{@"smsgId": smsgId, @"groupId": self.sessionID}];
    }
}

- (void)dealloc {
    [self dismissTipAlertView];
    
    [self.timer invalidate];
    self.timer = nil;
    
    [self.uploadReadedTimer invalidate];
    self.uploadReadedTimer = nil;
    [self stopLoadingTimeoutTimer];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
