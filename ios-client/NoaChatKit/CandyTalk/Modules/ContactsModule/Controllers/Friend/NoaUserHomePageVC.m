//
//  NoaUserHomePageVC.m
//  NoaKit
//
//  Created by Candy on 2026/10/20.
//

#import "NoaUserHomePageVC.h"
#import "NoaSampleUserInfoView.h"
#import "NoaKnownTipView.h"
#import "NoaChatViewController.h"//聊天
#import "NoaFriendManageVC.h"//好友管理
#import "NoaMediaCallManager.h"//音视频通话
#import "NoaToolManager.h"
#import "NoaFriendApplyPassVC.h"
#import "NoaChatKit-Swift.h"
#import "NoaSheetInputView.h"

#import "NoaCallManager.h"//新的音视频通话
#import "NoaCallSingleVC.h"//单聊

@interface NoaUserHomePageVC ()
@property (nonatomic, strong) NoaSampleUserInfoView *viewHeader;
@property (nonatomic, strong) UILabel *blackStatusLbl;//被拉黑后的提示
@property (nonatomic, strong) UIButton *btnAddFriend;//添加好友
@property (nonatomic, strong) NoaUserModel *userModel;

@property (nonatomic, strong) UIButton *btnSingleMessage;//发消息(单独显示发消息)
@property (nonatomic, strong) UIButton *btnMessage;//发消息
@property (nonatomic, strong) UILabel *lblMessageTip;
@property (nonatomic, strong) UIButton *btnAudio;//发语音消息
@property (nonatomic, strong) UILabel *lblAudioTip;
@property (nonatomic, strong) UIButton *btnVideo;//发视频消息
@property (nonatomic, strong) UILabel *lblVideoTip;

@property (nonatomic, copy)NSString * inGroupNameStr;//在群组内昵称
@property (nonatomic, assign)BOOL isMyFriend;//是否是好友
@end

@implementation NoaUserHomePageVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //请求入口
    [self requestCheckFriend];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
 
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navBtnBack setTkThemeImage:@[ImgNamed(@"nav_back_white"), ImgNamed(@"nav_back_white")] forState:UIControlStateNormal];
    [self setupNavUI];
    [self setupUI];
    
    [self checkMyFriendOnlineStatus];
    
}

- (void)navBtnBackClicked {
    if (self.isFromQRCode) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        BOOL isHaveApplyVC = NO;
        BOOL isHaveNewFriendVC = NO;
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[NoaFriendApplyPassVC class]]) {
                isHaveApplyVC = YES;
            }
            if ([controller isKindOfClass:[CoHereNewFriendListViewController class]]) {
                isHaveNewFriendVC = YES;
            }
        }
        //判断是否从新添加好友页面返回，如果同时包含ZFriendApplyPassVC和ZNewFriendListVC，则是从新添加好友页面返回
        if(isHaveApplyVC && isHaveNewFriendVC){
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[CoHereNewFriendListViewController class]]) {
                    [self.navigationController popToViewController:controller animated:YES];
                }
            }
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - 界面布局
- (void)setupNavUI {
    self.navBtnRight.hidden = YES;
    [self.navBtnRight setImage:ImgNamed(@"icon_chat_seetting_dark") forState:UIControlStateNormal];
}
- (void)setupUI {
    
    _viewHeader = [[NoaSampleUserInfoView alloc] init];
    [_viewHeader configUserInfoWith:_userUID groupId:_groupID];
    WeakSelf;
    [_viewHeader setSetRemarkBtnBlock:^{
        NoaSheetInputView * view = [[NoaSheetInputView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) titleStr:LanguageToolMatch(@"备注") remarkStr:weakSelf.userModel.remarks desStr:weakSelf.userModel.descRemark];
        [view setSaveBtnBlock:^(NSString * _Nonnull remarkStr, NSString * _Nonnull desStr) {
            [weakSelf requestSetRemarkAndDes:remarkStr desStr:desStr];
        }];
        [view inputViewSHow];
    }];
    [_viewHeader setSetDesBtnBlock:^{
        
    }];
    [self.view addSubview:_viewHeader];
    
    [_viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.leading.mas_equalTo(0);
        make.width.mas_equalTo(DScreenWidth);
        make.bottom.mas_equalTo(-DHomeBarH - DWScale(58));
//        make.size.mas_equalTo(CGSizeMake(DWScale(56), DWScale(80)));
    }];
    
    _blackStatusLbl = [[UILabel alloc] init];
    _blackStatusLbl.text = LanguageToolMatch(@"你已将对方拉黑，无法发送消息。如需发送消息，请先关闭加入黑名单或进入个人中心移出黑名单");
    _blackStatusLbl.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    _blackStatusLbl.font = FONTN(14);
    _blackStatusLbl.textAlignment = NSTextAlignmentCenter;
    _blackStatusLbl.numberOfLines = 0;
    _blackStatusLbl.hidden = YES;
    [self.view addSubview:_blackStatusLbl];
    [_blackStatusLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.mas_equalTo(-DHomeBarH - DWScale(58));
        make.size.mas_equalTo(CGSizeMake(DWScale(343), DWScale(60)));
    }];
    
    _btnAddFriend = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnAddFriend.hidden = YES;
    [_btnAddFriend setTitle:LanguageToolMatch(@"添加好友") forState:UIControlStateNormal];
    [_btnAddFriend setTitleColor:COLORWHITE forState:UIControlStateNormal];
    _btnAddFriend.titleLabel.font = FONTR(16);
    _btnAddFriend.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2];
    [_btnAddFriend setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateHighlighted];
    [_btnAddFriend addTarget:self action:@selector(btnAddFriendClick) forControlEvents:UIControlEventTouchUpInside];
    _btnAddFriend.layer.cornerRadius = DWScale(14);
    _btnAddFriend.layer.masksToBounds = YES;
    [self.view addSubview:_btnAddFriend];
    [_btnAddFriend mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-DHomeBarH - DWScale(316));
        make.size.mas_equalTo(CGSizeMake(DWScale(343), DWScale(50)));
    }];
    
    [self addAudioVideoCallMessageBtn];
}

- (void)addAudioVideoCallMessageBtn {
    CGFloat spacingValue = (DScreenWidth - DWScale(56)) / 4.0 - DWScale(28);
    
    //语音通话
    [self.view addSubview:self.btnAudio];
    [self.btnAudio mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.mas_equalTo(-DHomeBarH - DWScale(58));
        make.size.mas_equalTo(CGSizeMake(DWScale(56), DWScale(56)));
    }];
    
    [self.view addSubview:self.lblAudioTip];
    [self.lblAudioTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.btnAudio);
        make.top.equalTo(self.btnAudio.mas_bottom).offset(DWScale(10));
    }];
    
    //发消息
    [self.view addSubview:self.btnMessage];
    [self.btnMessage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.btnAudio);
        make.trailing.equalTo(self.btnAudio.mas_leading).offset(-spacingValue);
        make.size.mas_equalTo(CGSizeMake(DWScale(56), DWScale(56)));
    }];
    
    [self.view addSubview:self.lblMessageTip];
    [self.lblMessageTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.btnMessage);
        make.top.equalTo(self.btnMessage.mas_bottom).offset(DWScale(10));
    }];
    
    //视频通话
    [self.view addSubview:self.btnVideo];
    [self.btnVideo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.btnAudio);
        make.leading.equalTo(self.btnAudio.mas_trailing).offset(spacingValue);
        make.size.mas_equalTo(CGSizeMake(DWScale(56), DWScale(56)));
    }];
    
    [self.view addSubview:self.lblVideoTip];
    [self.lblVideoTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.btnVideo);
        make.top.equalTo(self.btnVideo.mas_bottom).offset(DWScale(10));
    }];

    [self.view addSubview:self.btnSingleMessage];
    [self.btnSingleMessage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(DWScale(16));
        make.trailing.equalTo(self.view).offset(-DWScale(16));
        make.bottom.equalTo(self.view).offset(-DWScale(91));
        make.height.mas_equalTo(DWScale(54));
    }];

    //判断是否显示的是自己
    if ([_userUID isEqualToString:UserManager.userInfo.userUID]) {
        self.btnMessage.hidden = YES;
        self.lblMessageTip.hidden = YES;
        self.btnAudio.hidden = YES;
        self.lblAudioTip.hidden = YES;
        self.btnVideo.hidden = YES;
        self.lblVideoTip.hidden = YES;
        self.btnSingleMessage.hidden = YES;
        _blackStatusLbl.hidden = YES;
        _btnAddFriend.hidden = YES;
    }
}

#pragma mark - 数据请求
//判断是否为好友
- (void)requestCheckFriend {
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_userUID forKey:@"friendUserUid"];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    
    [IMSDKManager checkMyFriendWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        BOOL isMyFriend = [data boolValue];
        weakSelf.isMyFriend = isMyFriend;
        weakSelf.navBtnRight.hidden = !isMyFriend;
        if ([weakSelf.userUID isEqualToString:UserManager.userInfo.userUID]) {
            weakSelf.btnAddFriend.hidden = YES;
        } else {
            if (isMyFriend) {
                weakSelf.btnAddFriend.hidden = YES;
                if ([ZHostTool.appSysSetModel.enableAudioAndVideoCalls isEqualToString:@"1"]) {
                    weakSelf.btnMessage.hidden = NO;
                    weakSelf.lblMessageTip.hidden = NO;
                    weakSelf.btnAudio.hidden = NO;
                    weakSelf.lblAudioTip.hidden = NO;
                    weakSelf.btnVideo.hidden = NO;
                    weakSelf.lblVideoTip.hidden = NO;
                    weakSelf.btnSingleMessage.hidden = YES;
                } else {
                    weakSelf.btnMessage.hidden = YES;
                    weakSelf.lblMessageTip.hidden = YES;
                    weakSelf.btnAudio.hidden = YES;
                    weakSelf.lblAudioTip.hidden = YES;
                    weakSelf.btnVideo.hidden = YES;
                    weakSelf.lblVideoTip.hidden = YES;
                    weakSelf.btnSingleMessage.hidden = NO;
                }
            } else {
                weakSelf.btnMessage.hidden = YES;
                weakSelf.lblMessageTip.hidden = YES;
                weakSelf.btnAudio.hidden = YES;
                weakSelf.lblAudioTip.hidden = YES;
                weakSelf.btnVideo.hidden = YES;
                weakSelf.lblVideoTip.hidden = YES;
                weakSelf.btnSingleMessage.hidden = YES;
                if ([UserManager.userRoleAuthInfo.allowAddFriend.configValue isEqualToString:@"true"]) {
                    weakSelf.btnAddFriend.hidden = NO;
                } else {
                    weakSelf.btnAddFriend.hidden = YES;
                }
            }
        }
        
        if(![NSString isNil:weakSelf.groupID]){
            [weakSelf requestGetNickInGroup];
        }else{
            if(isMyFriend){
                [weakSelf requestFriendInfo];
            }else{
                [weakSelf requestUserInfo];
            }
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

//获取用户在某个群的昵称(备注)
- (void)requestGetNickInGroup {
    //查询该用户在群里的群成员信息
    LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:_userUID groupID:_groupID];
    
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_groupID forKey:@"groupId"];
    [dict setValue:_userUID forKey:@"userUid"];
    
    [IMSDKManager groupGetUserNicKNameWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *userInGroupDict = (NSDictionary *)data;
            NSString *nickInGroup = [NSString stringWithFormat:@"%@", [userInGroupDict objectForKey:@"nicknameInGroup"]];
            weakSelf.inGroupNameStr = nickInGroup;
            //更新群成员在群里的昵称
            groupMemberModel.nicknameInGroup = nickInGroup;
            groupMemberModel.showName = nickInGroup;
            [IMSDKManager imSdkInsertOrUpdateGroupMember:groupMemberModel groupID:weakSelf.groupID];
            
            if (weakSelf.isMyFriend) {
                [weakSelf requestFriendInfo];
            } else{
                [weakSelf requestUserInfo];
            }
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        //群成员不在群组内
        if (code == 41015) {
            if(weakSelf.isMyFriend){
                [weakSelf requestFriendInfo];
            } else{
                [weakSelf requestUserInfo];
            }
        }
    }];
}

//获取用户信息
- (void)requestUserInfo {
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_userUID forKey:@"userUid"];
    [IMSDKManager getUserInfoWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *userDict = (NSDictionary *)data;
            weakSelf.userModel = [NoaUserModel mj_objectWithKeyValues:userDict];
            weakSelf.userModel.userUID = [NSString stringWithFormat:@"%@",[userDict objectForKeySafe:@"userUid"]];
            if (weakSelf.userModel.disableStatus == 4) {
                //如果该账号是注销状态，更新好友表和群成员表状态
        
                //群成员表
                LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:weakSelf.userModel.userUID groupID:weakSelf.groupID];
                if (groupMemberModel == nil) {
                    groupMemberModel = [[LingIMGroupMemberModel alloc] init];
                }
                groupMemberModel.userName = weakSelf.userModel.userName;
                groupMemberModel.userUid = weakSelf.userModel.userUID;
                groupMemberModel.userNickname = weakSelf.userModel.nickname;
                groupMemberModel.userAvatar = weakSelf.userModel.avatar;
                groupMemberModel.disableStatus = weakSelf.userModel.disableStatus;
                [IMSDKManager imSdkInsertOrUpdateGroupMember:groupMemberModel groupID:weakSelf.groupID];
                
                //好友表
                LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:weakSelf.userModel.userUID];
                if (friendModel != nil) {
                    friendModel.disableStatus = weakSelf.userModel.disableStatus;
                    //更新好友信息
                    [IMSDKManager toolUpdateMyFriendWith:friendModel];
                }
            }
            
            if (![NSString isNil:weakSelf.groupID]) {
                //查询该用户在群里的群成员信息
                LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:weakSelf.userModel.userUID groupID:weakSelf.groupID];
                if (groupMemberModel != nil) {
                    groupMemberModel.userName = weakSelf.userModel.userName;
                    groupMemberModel.userUid = weakSelf.userModel.userUID;
                    groupMemberModel.userNickname = weakSelf.userModel.nickname;
                    groupMemberModel.userAvatar = weakSelf.userModel.avatar;
                    groupMemberModel.disableStatus = weakSelf.userModel.disableStatus;
                    if (![NSString isNil:weakSelf.userModel.remarks]) {
                        groupMemberModel.remarks = weakSelf.userModel.remarks;
                        groupMemberModel.showName = weakSelf.userModel.remarks;
                    }
                    [IMSDKManager imSdkInsertOrUpdateGroupMember:groupMemberModel groupID:weakSelf.groupID];
                }
            }
            
            [weakSelf.viewHeader updateUIWithUserModel:weakSelf.userModel isMyFriend:weakSelf.isMyFriend inGroupUserName:weakSelf.inGroupNameStr];
            [weakSelf checkAccountDisableStatus];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

//获取好友信息
- (void)requestFriendInfo{
    WeakSelf
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    [params setValue:_userUID forKey:@"friendUserUid"];
    [IMSDKManager getFriendInfoWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        NSDictionary *userDict = (NSDictionary *)data;
        weakSelf.userModel = [NoaUserModel mj_objectWithKeyValues:userDict];
        weakSelf.userModel.userUID = [NSString stringWithFormat:@"%@",[userDict objectForKeySafe:@"friendUserUID"]];
        if (weakSelf.userModel.disableStatus == 4) {
            //如果该账号是注销状态，更新好友表和群成员表状态
            //群成员表
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:weakSelf.userModel.userUID groupID:weakSelf.groupID];
            if (groupMemberModel == nil) {
                groupMemberModel = [[LingIMGroupMemberModel alloc] init];
            }
            groupMemberModel.userName = weakSelf.userModel.userName;
            groupMemberModel.userUid = weakSelf.userModel.userUID;
            groupMemberModel.userNickname = weakSelf.userModel.nickname;
            groupMemberModel.userAvatar = weakSelf.userModel.avatar;
            groupMemberModel.disableStatus = weakSelf.userModel.disableStatus;
            [IMSDKManager imSdkInsertOrUpdateGroupMember:groupMemberModel groupID:weakSelf.groupID];
            
            //好友表
            LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:weakSelf.userModel.userUID];
            if (friendModel != nil) {
                friendModel.disableStatus = weakSelf.userModel.disableStatus;
                friendModel.nickname = weakSelf.userModel.nickname;
                friendModel.nicknamePinyin = weakSelf.userModel.nicknamePinyin;
                friendModel.remarks = weakSelf.userModel.remarks;
                friendModel.remarksPinyin = weakSelf.userModel.remarksPinyin;
                [IMSDKManager toolUpdateMyFriendWith:friendModel];
            }
            
        } else {
            //检查是否被拉黑
            [weakSelf requestGetBlackStatus];
            
            //好友表
            LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:weakSelf.userModel.userUID];
            if (friendModel != nil) {
                friendModel.nickname = weakSelf.userModel.nickname;
                friendModel.nicknamePinyin = weakSelf.userModel.nicknamePinyin;
                friendModel.remarks = weakSelf.userModel.remarks;
                friendModel.remarksPinyin = weakSelf.userModel.remarksPinyin;
                [IMSDKManager toolUpdateMyFriendWith:friendModel];
            }
        }
        if (![NSString isNil:weakSelf.groupID]) {
            //查询该用户在群里的群成员信息
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:weakSelf.userModel.userUID groupID:weakSelf.groupID];
            if (groupMemberModel != nil) {
                if (![NSString isNil:weakSelf.userModel.remarks]) {
                    groupMemberModel.remarks = weakSelf.userModel.remarks;
                    groupMemberModel.showName = weakSelf.userModel.remarks;
                    [IMSDKManager imSdkInsertOrUpdateGroupMember:groupMemberModel groupID:weakSelf.groupID];
                }
            }
        }
        
        [weakSelf.viewHeader updateUIWithUserModel:weakSelf.userModel isMyFriend:weakSelf.isMyFriend inGroupUserName:weakSelf.inGroupNameStr];
        [weakSelf checkAccountDisableStatus];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        
    }];
}

//检查账号是否已注销
- (void)checkAccountDisableStatus {
    if (self.userModel.disableStatus == 4) {
        //已注销
        self.btnSingleMessage.hidden = YES;
        self.btnMessage.hidden = YES;
        self.lblMessageTip.hidden = YES;
        self.btnAudio.hidden = YES;
        self.lblAudioTip.hidden = YES;
        self.btnVideo.hidden = YES;
        self.lblVideoTip.hidden = YES;
        _btnAddFriend.hidden = YES;
        _blackStatusLbl.hidden = YES;
    }
}

//检查是否被拉黑
- (void)requestGetBlackStatus {
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_userUID forKey:@"friendUserUid"];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    
    [IMSDKManager getUserBlackStateWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        BOOL isBlack = [data boolValue];
        
        if(isBlack){
            if ([ZHostTool.appSysSetModel.enableAudioAndVideoCalls isEqualToString:@"1"]) {
                weakSelf.btnMessage.hidden = isBlack;
                weakSelf.lblMessageTip.hidden = isBlack;
                weakSelf.btnAudio.hidden = isBlack;
                weakSelf.lblAudioTip.hidden = isBlack;
                weakSelf.btnVideo.hidden = isBlack;
                weakSelf.lblVideoTip.hidden = isBlack;
            } else {
                weakSelf.btnSingleMessage.hidden = isBlack;
            }
        } else {
            if ([ZHostTool.appSysSetModel.enableAudioAndVideoCalls isEqualToString:@"1"]) {
                weakSelf.btnMessage.hidden = !weakSelf.isMyFriend;
                weakSelf.lblMessageTip.hidden = !weakSelf.isMyFriend;
                weakSelf.btnAudio.hidden = !weakSelf.isMyFriend;
                weakSelf.lblAudioTip.hidden = !weakSelf.isMyFriend;
                weakSelf.btnVideo.hidden = !weakSelf.isMyFriend;
                weakSelf.lblVideoTip.hidden = !weakSelf.isMyFriend;
            } else {
                weakSelf.btnSingleMessage.hidden = !weakSelf.isMyFriend;
            }
        }
        
        weakSelf.blackStatusLbl.hidden = !isBlack;
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
    }];
    
}

- (void)requestSetRemarkAndDes:(NSString *)remark desStr:(NSString *)desStr{
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_userUID forKey:@"friendUserUid"];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    [dict setValue:remark forKey:@"remark"];
    [dict setValue:desStr forKey:@"descRemark"];
    
    [IMSDKManager friendSetFriendRemarkAndDesWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        //请求更新试图
        [weakSelf requestCheckFriend];
        [HUD showMessage:LanguageToolMatch(@"保存成功")];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

//界面赋值
- (void)updateUI {
    LingIMFriendModel *myFriend = [IMSDKManager toolCheckMyFriendWith:_userModel.userUID];
    if (myFriend) {
        //更新一下数据库
        myFriend.avatar = _userModel.avatar;//头像
        myFriend.nickname = _userModel.nickname;//昵称
        myFriend.userName = _userModel.userName;//账号
        myFriend.remarks = _userModel.remarks;//备注
        myFriend.descRemark = _userModel.descRemark;//描述
        [IMSDKManager toolUpdateMyFriendWith:myFriend];
    }
}
#pragma mark - 用户在线状态
- (void)checkMyFriendOnlineStatus {
    LingIMFriendModel *myFriendModel = [IMSDKManager toolCheckMyFriendWith:_userUID];
    if (myFriendModel) {
        _viewHeader.viewOnline.hidden = myFriendModel.onlineStatus ? NO : YES;
    }else {
        _viewHeader.viewOnline.hidden = YES;
    }
    
    //好友在线状态更新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myFriendOnlineStatusChange:) name:@"MyFriendOnlineStatusChange" object:nil];
}
#pragma mark - 交互事件
//发消息
- (void)btnMessageClick {
    NoaChatViewController *vc = [NoaChatViewController new];
    vc.sessionID = _userUID;
    vc.chatName = _userModel.nickname;
    vc.chatType = CIMChatType_SingleChat;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)btnAddFriendClick {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_userUID forKey:@"friendUserUid"];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    [IMSDKManager addContactWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD showMessage:LanguageToolMatch(@"已发送")];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        NoaKnownTipView *viewTip = [NoaKnownTipView new];
        viewTip.lblTip.text = LanguageToolMatch(msg);
        [viewTip knownTipViewSHow];
    }];
}

-(void)navBtnRightClicked {
    NoaFriendManageVC *vc = [NoaFriendManageVC new];
    vc.friendUID = _userUID;
    vc.userModel = self.userModel;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)btnAudioClick {
    if (!_userModel) return;

    WeakSelf
    //申请麦克风权限
    [ZTOOL getMicrophoneAuth:^(BOOL granted) {
        //发起 单聊 音频通话 邀请
        if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"0"]) {
            //LiveKit
            [weakSelf lkCallRequestForSingleWith:LingIMCallTypeAudio];
        }else if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"1"]) {
            //即构
            [weakSelf zgCallRequestForSingleWith:LingIMCallTypeAudio];
        }
    }];
    
}

- (void)btnVideoClick {
    if (!_userModel) return;
    
    WeakSelf
    //申请麦克风权限
    [ZTOOL getMicrophoneAuth:^(BOOL granted) {
        //申请摄像头权限
        [ZTOOL getCameraAuth:^(BOOL granted) {
            //发起 单聊 视频通话 邀请
            if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"0"]) {
                //LiveKit
                [self lkCallRequestForSingleWith:LingIMCallTypeVideo];
            }else if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"1"]) {
                //即构
                [weakSelf zgCallRequestForSingleWith:LingIMCallTypeVideo];
            }
        }];
    }];
}

//用户在线状态更新
- (void)myFriendOnlineStatusChange:(NSNotification *)sender {
    NSDictionary *userInfoDict = sender.userInfo;
    NSString *myFriendID = [userInfoDict objectForKeySafe:@"friendID"];
    if ([myFriendID isEqualToString:_userUID]) {
        BOOL onlineStatus = [[userInfoDict objectForKeySafe:@"friendStatus"] integerValue] == 1 ? YES : NO;
        _viewHeader.viewOnline.hidden = !onlineStatus;
    }
}

#pragma mark - LiveKit 音视频通话 邀请者
- (void)lkCallRequestForSingleWith:(LingIMCallType)callType {
    
    if ([NoaMediaCallManager sharedManager].mediaCallState != ZMediaCallStateEnd) return;
    
    NoaMediaCallOptions *callOptions = [NoaMediaCallOptions new];
    callOptions.callType = callType;//音视频聊天类型
    callOptions.callRoleType = LingIMCallRoleTypeRequest;//发起者
    callOptions.callRoomType = ZIMCallRoomTypeSingle;//单人视频聊天
    callOptions.inviterUid = UserManager.userInfo.userUID;//发起者Uid
    callOptions.inviteeUid = _userUID;
    callOptions.callMicState = LingIMCallMicrophoneMuteStateOff;//音频打开
    callOptions.callCameraState = callType == LingIMCallTypeVideo ? LingIMCallCameraMuteStateOff : LingIMCallCameraMuteStateOn;//视频打开
    
    [NoaMediaCallManager sharedManager].currentCallOptions = callOptions;
    [NoaMediaCallManager sharedManager].userModel = self.userModel;
    
    [[NoaMediaCallManager sharedManager] mediaCallRequestWith:callOptions onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [NoaMediaCallManager sharedManager].mediaCallState = ZMediaCallStateBegin;
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [NoaMediaCallManager sharedManager].mediaCallState = ZMediaCallStateEnd;
    }];
    
}

#pragma mark - 即构 音视频通话 邀请者
- (void)zgCallRequestForSingleWith:(LingIMCallType)callType {
    if (!_userModel) return;
    
    if ([NoaCallManager sharedManager].callState != ZCallStateEnd) return;
    
    //被被邀请者信息配置
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_userUID forKey:@"userID"];
    [dict setValue:_userModel.showName forKey:@"userShowName"];
    [dict setValue:_userModel.avatar forKey:@"userAvatar"];
    
    [[NoaCallManager sharedManager] requestSingleCallWith:dict callType:callType];
    
}

#pragma mark - Lazy
- (UIButton *)btnSingleMessage {
    if (!_btnSingleMessage) {
        _btnSingleMessage = [[UIButton alloc] init];
        _btnSingleMessage.hidden = YES;
        [_btnSingleMessage setImage:ImgNamed(@"single_call_text") forState:UIControlStateNormal];
        [_btnSingleMessage setTitle:LanguageToolMatch(@"发消息") forState:UIControlStateNormal];
        _btnSingleMessage.tkThemebackgroundColors = @[COLOR_11, COLOR_11_DARK];
        [_btnSingleMessage rounded:DWScale(14)];
        [_btnSingleMessage setBtnImageAlignmentType:ButtonImageAlignmentTypeLeft imageSpace:10];
        [_btnSingleMessage addTarget:self action:@selector(btnMessageClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnSingleMessage;
}

- (UIButton *)btnAudio {
    if (!_btnAudio) {
        _btnAudio = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnAudio.hidden = YES;
        [_btnAudio setImage:ImgNamed(@"call_audio") forState:UIControlStateNormal];
        [_btnAudio addTarget:self action:@selector(btnAudioClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnAudio;
}

- (UILabel *)lblAudioTip {
    if (!_lblAudioTip) {
        _lblAudioTip = [UILabel new];
        _lblAudioTip.hidden = YES;
        _lblAudioTip.text = LanguageToolMatch(@"语音通话");
        _lblAudioTip.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        if ([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"俄语"]) {
            _lblAudioTip.font = FONTR(10);
        } else {
            _lblAudioTip.font = FONTR(16);
        }
    }
    return _lblAudioTip;
}

- (UIButton *)btnMessage {
    if (!_btnMessage) {
        _btnMessage = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnMessage.hidden = YES;
        [_btnMessage setImage:ImgNamed(@"call_text") forState:UIControlStateNormal];
        [_btnMessage addTarget:self action:@selector(btnMessageClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnMessage;
}

- (UILabel *)lblMessageTip {
    if (!_lblMessageTip) {
        _lblMessageTip = [UILabel new];
        _lblMessageTip.hidden = YES;
        _lblMessageTip.text = LanguageToolMatch(@"发消息");
        _lblMessageTip.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        if ([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"俄语"]) {
            _lblMessageTip.font = FONTR(10);
        } else {
            _lblMessageTip.font = FONTR(16);
        }
    }
    return _lblMessageTip;
}

- (UIButton *)btnVideo {
    if (!_btnVideo) {
        _btnVideo = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnVideo.hidden = YES;
        [_btnVideo setImage:ImgNamed(@"call_video") forState:UIControlStateNormal];
        [_btnVideo addTarget:self action:@selector(btnVideoClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnVideo;
}

- (UILabel *)lblVideoTip {
    if (!_lblVideoTip) {
        _lblVideoTip = [UILabel new];
        _lblVideoTip.hidden = YES;
        _lblVideoTip.text = LanguageToolMatch(@"视频通话");
        _lblVideoTip.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        if ([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"俄语"]) {
            _lblVideoTip.font = FONTR(10);
        } else {
            _lblVideoTip.font = FONTR(16);
        }
    }
    return _lblVideoTip;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
