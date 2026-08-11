//
//  NoaFriendManageVC.m
//  NoaKit
//
//  Created by Candy on 2026/10/22.
//

#import "NoaFriendManageVC.h"
#import "NoaMessageAlertView.h"
#import "NoaMessageTools.h"
#import "NoaSheetInputView.h"
#import "NoaChatKit-Swift.h"  //Swift 推荐给朋友选择转发对象
#import "NoaChatKit-Swift.h"//Swift 投诉与支持
#import "NoaFriendGroupManagerVC.h"//好友分组管理

@interface NoaFriendManageVC ()
@property (nonatomic, strong) UIButton *blackBtn;//加入黑名单
@property (nonatomic, strong) UILabel *lblFriendGroup;//好友分组
@property (nonatomic, strong) LingIMFriendGroupModel *currentFriendGroupModel;//当前好友所属好友分组信息
@end

@implementation NoaFriendManageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navTitleStr = LanguageToolMatch(@"好友管理");
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    
    [self setupUI];
    [self requestGetBlackStatus];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    LingIMFriendModel *myFriendModel = [IMSDKManager toolCheckMyFriendWith:_friendUID];
    if (myFriendModel) {
        LingIMFriendGroupModel *friendGroupModel = [IMSDKManager toolCheckMyFriendGroupWith:myFriendModel.ugUuid];
        if (friendGroupModel) {
            _lblFriendGroup.text = ![NSString isNil:friendGroupModel.ugName] ? friendGroupModel.ugName : LanguageToolMatch(@"默认分组");
            _currentFriendGroupModel = friendGroupModel;
        }
    }
    
}
#pragma mark - 界面布局
- (void)setupUI {
    if (self.userModel.disableStatus == 4) {
        //已注销
        
        //删除好友
        UIButton *btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
        btnDelete.tkThemebackgroundColors = @[COLORWHITE, COLOR_F5F6F9_DARK];
        [btnDelete setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_CCCCCC_DARK]] forState:UIControlStateHighlighted];
        [btnDelete setTitle:LanguageToolMatch(@"删除好友") forState:UIControlStateNormal];
        [btnDelete setTitleColor:HEXCOLOR(@"FF3333") forState:UIControlStateNormal];
        btnDelete.titleLabel.font = FONTR(16);
        btnDelete.layer.cornerRadius = DWScale(12);
        btnDelete.layer.masksToBounds = YES;
        [btnDelete addTarget:self action:@selector(btnDeleteClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btnDelete];
        [btnDelete mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.navView.mas_bottom).offset(DWScale(16));
            make.size.mas_equalTo(CGSizeMake(DWScale(343), DWScale(54)));
        }];
        
    } else {
        
        //设置备注
        UIView *setRemarkBgView = [[UIView alloc] init];
        setRemarkBgView.tkThemebackgroundColors = @[COLORWHITE, COLOR_F5F6F9_DARK];
        [setRemarkBgView rounded:12];
        setRemarkBgView.clipsToBounds = YES;
        [self.view addSubview:setRemarkBgView];
        [setRemarkBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.navView.mas_bottom).offset(DWScale(16));
            make.centerX.equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(DWScale(343), DWScale(54)));
        }];
        
        UIButton *setRemarkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        setRemarkBtn.tkThemebackgroundColors = @[COLORWHITE, COLOR_F5F6F9_DARK];
        [setRemarkBtn setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_CCCCCC_DARK]] forState:UIControlStateHighlighted];
        [setRemarkBtn addTarget:self action:@selector(setRemarkBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [setRemarkBgView addSubview:setRemarkBtn];
        [setRemarkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.mas_equalTo(setRemarkBgView);
        }];
        
        UILabel *setRemarkLabel = [[UILabel alloc] init];
        setRemarkLabel.text = LanguageToolMatch(@"设置备注");
        setRemarkLabel.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        setRemarkLabel.font = FONTN(16);
        [setRemarkBgView addSubview:setRemarkLabel];
        [setRemarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(setRemarkBgView);
            make.leading.equalTo(setRemarkBgView).offset(16);
            make.size.mas_equalTo(CGSizeMake(DWScale(100), DWScale(22)));
        }];
        
        UIImageView * ivArrow1 = [[UIImageView alloc] initWithImage:ImgNamed(@"c_arrow_right_gray")];
        [setRemarkBgView addSubview:ivArrow1];
        [ivArrow1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(setRemarkBgView);
            make.trailing.equalTo(setRemarkBgView).offset(-DWScale(16));
            make.size.mas_equalTo(CGSizeMake(DWScale(8), DWScale(16)));
        }];

        //分组
        UIView *viewFriendGroup = [[UIView alloc] init];
        viewFriendGroup.tkThemebackgroundColors = @[COLORWHITE, COLOR_F5F6F9_DARK];
        [viewFriendGroup rounded:12];
        viewFriendGroup.clipsToBounds = YES;
        [self.view addSubview:viewFriendGroup];
        [viewFriendGroup mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(setRemarkBgView.mas_bottom).offset(DWScale(16));
            make.centerX.equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(DWScale(343), DWScale(54)));
        }];
        
        UIButton *btnFriendGroup = [UIButton buttonWithType:UIButtonTypeCustom];
        btnFriendGroup.tkThemebackgroundColors = @[COLORWHITE, COLOR_F5F6F9_DARK];
        [btnFriendGroup setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_CCCCCC_DARK]] forState:UIControlStateHighlighted];
        [btnFriendGroup addTarget:self action:@selector(btnFriendGroupClick) forControlEvents:UIControlEventTouchUpInside];
        [viewFriendGroup addSubview:btnFriendGroup];
        [btnFriendGroup mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.mas_equalTo(viewFriendGroup);
        }];
        
        UILabel *lblFriendGroupTip = [[UILabel alloc] init];
        lblFriendGroupTip.text = LanguageToolMatch(@"分组");
        lblFriendGroupTip.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        lblFriendGroupTip.font = FONTN(16);
        [viewFriendGroup addSubview:lblFriendGroupTip];
        [lblFriendGroupTip mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(viewFriendGroup);
            make.leading.equalTo(viewFriendGroup).offset(16);
            make.size.mas_equalTo(CGSizeMake(DWScale(100), DWScale(22)));
        }];
        
        UIImageView * ivArrowFriendGroup = [[UIImageView alloc] initWithImage:ImgNamed(@"c_arrow_right_gray")];
        [viewFriendGroup addSubview:ivArrowFriendGroup];
        [ivArrowFriendGroup mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(viewFriendGroup);
            make.trailing.equalTo(viewFriendGroup).offset(-DWScale(16));
            make.size.mas_equalTo(CGSizeMake(DWScale(8), DWScale(16)));
        }];
        
        _lblFriendGroup = [UILabel new];
        _lblFriendGroup.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
        _lblFriendGroup.font = FONTR(12);
        [viewFriendGroup addSubview:_lblFriendGroup];
        [_lblFriendGroup mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(viewFriendGroup);
            make.trailing.equalTo(ivArrowFriendGroup.mas_leading).offset(-DWScale(16));
        }];
        
        //推荐给朋友
        UIView *recommendBgView = [[UIView alloc] init];
        recommendBgView.tkThemebackgroundColors = @[COLORWHITE, COLOR_F5F6F9_DARK];
        [recommendBgView rounded:12];
        recommendBgView.clipsToBounds = YES;
        [self.view addSubview:recommendBgView];
        [recommendBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(viewFriendGroup.mas_bottom).offset(DWScale(16));
            make.centerX.equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(DWScale(343), DWScale(54)));
        }];
        
        UIButton *recommendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        recommendBtn.tkThemebackgroundColors = @[COLORWHITE, COLOR_F5F6F9_DARK];
        [recommendBtn setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_CCCCCC_DARK]] forState:UIControlStateHighlighted];
        [recommendBtn addTarget:self action:@selector(recommendToFriendClick) forControlEvents:UIControlEventTouchUpInside];
        [recommendBgView addSubview:recommendBtn];
        [recommendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.mas_equalTo(recommendBgView);
        }];
        
        UILabel *recommendLabel = [[UILabel alloc] init];
        recommendLabel.text = LanguageToolMatch(@"推荐给朋友");
        recommendLabel.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        recommendLabel.font = FONTN(16);
        [recommendBgView addSubview:recommendLabel];
        [recommendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(recommendBgView);
            make.leading.equalTo(recommendBgView).offset(16);
            make.size.mas_equalTo(CGSizeMake(DWScale(200), DWScale(22)));
        }];
        
        UIImageView * ivArrow2 = [[UIImageView alloc] initWithImage:ImgNamed(@"c_arrow_right_gray")];
        [recommendBgView addSubview:ivArrow2];
        [ivArrow2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(recommendBgView);
            make.trailing.equalTo(recommendBgView).offset(-DWScale(16));
            make.size.mas_equalTo(CGSizeMake(DWScale(8), DWScale(16)));
        }];

        //黑名单
        UIView *blackBackView = [[UIView alloc] init];
        blackBackView.tkThemebackgroundColors = @[COLORWHITE, COLOR_F5F6F9_DARK];
        [blackBackView rounded:12];
        [self.view addSubview:blackBackView];
        [blackBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(recommendBgView.mas_bottom).offset(DWScale(16));
            make.centerX.equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(DWScale(343), DWScale(54)));
        }];
        
        UILabel *blackLbl = [[UILabel alloc] init];
        blackLbl.text = LanguageToolMatch(@"加入黑名单");
        blackLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        blackLbl.font = FONTN(16);
        [blackBackView addSubview:blackLbl];
        [blackLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(blackBackView);
            make.leading.equalTo(blackBackView).offset(16);
            make.trailing.equalTo(blackBackView).offset(-DWScale(70));
            make.height.mas_equalTo(DWScale(22));
        }];
        
        self.blackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.blackBtn setImage:ImgNamed(@"c_switch_off") forState:UIControlStateNormal];
        [self.blackBtn setImage:ImgNamed(@"c_switch_on") forState:UIControlStateSelected];
        [self.blackBtn addTarget:self action:@selector(btnBlackListClick) forControlEvents:UIControlEventTouchUpInside];
        [blackBackView addSubview:self.blackBtn];
        [self.blackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(blackBackView);
            make.trailing.equalTo(blackBackView).offset(-16);
            make.size.mas_equalTo(CGSizeMake(DWScale(44), DWScale(44)));
        }];
        
        //投诉
        UIView *viewComplain = [[UIView alloc] init];
        viewComplain.tkThemebackgroundColors = @[COLORWHITE, COLOR_F5F6F9_DARK];
        [viewComplain rounded:12];
        viewComplain.clipsToBounds = YES;
        [self.view addSubview:viewComplain];
        [viewComplain mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(blackBackView.mas_bottom).offset(DWScale(16));
            make.centerX.equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(DWScale(343), DWScale(54)));
        }];
        
        UIButton *btnComplain = [UIButton buttonWithType:UIButtonTypeCustom];
        btnComplain.tkThemebackgroundColors = @[COLORWHITE, COLOR_F5F6F9_DARK];
        [btnComplain setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_CCCCCC_DARK]] forState:UIControlStateHighlighted];
        [btnComplain addTarget:self action:@selector(btnComplainClick) forControlEvents:UIControlEventTouchUpInside];
        [viewComplain addSubview:btnComplain];
        [btnComplain mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.mas_equalTo(viewComplain);
        }];
        
        UILabel *lblComplain = [[UILabel alloc] init];
        lblComplain.text = LanguageToolMatch(@"投诉与支持");
        lblComplain.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        lblComplain.font = FONTN(16);
        [viewComplain addSubview:lblComplain];
        [lblComplain mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(viewComplain);
            make.leading.equalTo(viewComplain).offset(16);
            make.size.mas_equalTo(CGSizeMake(DWScale(200), DWScale(22)));
        }];
        
        UIImageView * ivArrow3 = [[UIImageView alloc] initWithImage:ImgNamed(@"c_arrow_right_gray")];
        [viewComplain addSubview:ivArrow3];
        [ivArrow3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(viewComplain);
            make.trailing.equalTo(viewComplain).offset(-DWScale(16));
            make.size.mas_equalTo(CGSizeMake(DWScale(8), DWScale(16)));
        }];
        
        //删除好友
        UIButton *btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
        btnDelete.tkThemebackgroundColors = @[COLORWHITE, COLOR_F5F6F9_DARK];
        [btnDelete setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_CCCCCC_DARK]] forState:UIControlStateHighlighted];
        [btnDelete setTitle:LanguageToolMatch(@"删除好友") forState:UIControlStateNormal];
        [btnDelete setTitleColor:HEXCOLOR(@"FF3333") forState:UIControlStateNormal];
        btnDelete.titleLabel.font = FONTR(16);
        btnDelete.layer.cornerRadius = DWScale(12);
        btnDelete.layer.masksToBounds = YES;
        [btnDelete addTarget:self action:@selector(btnDeleteClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btnDelete];
        [btnDelete mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(viewComplain.mas_bottom).offset(DWScale(16));
            make.size.mas_equalTo(CGSizeMake(DWScale(343), DWScale(54)));
        }];
    }
}

#pragma mark - 交互事件
//设置备注
- (void)setRemarkBtnClick{
    NoaSheetInputView * view = [[NoaSheetInputView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) titleStr:LanguageToolMatch(@"备注") remarkStr:self.userModel.remarks desStr:self.userModel.descRemark];
    WeakSelf;
    [view setSaveBtnBlock:^(NSString * _Nonnull remarkStr, NSString * _Nonnull desStr) {
        [weakSelf requestSetRemarkAndDes:remarkStr desStr:desStr];
    }];
    [view inputViewSHow];
}

//好友分组
- (void)btnFriendGroupClick {
    NoaFriendGroupManagerVC *vc = [NoaFriendGroupManagerVC new];
    vc.friendGroupCanEdit = NO;
    vc.currentFriendGroupModel = _currentFriendGroupModel;
    vc.friendID = _friendUID;
    [self.navigationController pushViewController:vc animated:YES];
}

//推荐给朋友
- (void)recommendToFriendClick {
    CoHereChatMultiSelectViewController *vc = [CoHereChatMultiSelectViewController new];
    vc.multiSelectType = ZMultiSelectTypeRecommentCard;
    vc.cardFriendInfo = self.userModel;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)btnDeleteClick {
    WeakSelf
    NoaMessageAlertView *msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeTitle supView:nil];
    msgAlertView.lblTitle.text = LanguageToolMatch(@"删除好友");
    msgAlertView.lblContent.text = LanguageToolMatch(@"删除后，同时删除与该好友的所有聊天记录，且不可撤回。");
    msgAlertView.lblContent.textAlignment = NSTextAlignmentLeft;
    [msgAlertView.btnSure setTitle:LanguageToolMatch(@"删除") forState:UIControlStateNormal];
//    [msgAlertView.btnSure setTkThemeTitleColor:@[COLOR_FF3333, COLOR_FF3333_DARK] forState:UIControlStateNormal];
//    msgAlertView.btnSure.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F5F6F9_DARK];
    [msgAlertView.btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
//    [msgAlertView.btnCancel setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
//    msgAlertView.btnCancel.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    [msgAlertView alertShow];
    msgAlertView.sureBtnBlock = ^(BOOL isCheckBox) {
        [weakSelf requestDeleteFriend];
    };
}

- (void)btnBlackListClick {
    if (self.blackBtn.selected == NO) {
        WeakSelf
        NoaMessageAlertView *msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeTitle supView:nil];
        msgAlertView.lblTitle.text = LanguageToolMatch(@"加入黑名单");
        msgAlertView.lblContent.text = LanguageToolMatch(@"加入黑名单后，你将接收不到对方信息，如需接收，请关闭加入黑名单或在个人中心移出黑名单");
        msgAlertView.lblContent.textAlignment = NSTextAlignmentLeft;
        [msgAlertView.btnSure setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
//        [msgAlertView.btnSure setTkThemeTitleColor:@[COLOR_FF3333, COLOR_FF3333_DARK] forState:UIControlStateNormal];
//        msgAlertView.btnSure.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F6F6F6_DARK];
        [msgAlertView.btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
//        [msgAlertView.btnCancel setTkThemeTitleColor:@[COLORWHITE, COLORWHITE_DARK] forState:UIControlStateNormal];
//        msgAlertView.btnCancel.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
        [msgAlertView alertShow];
        msgAlertView.sureBtnBlock = ^(BOOL isCheckBox) {
            [weakSelf requestBlackFriend];
        };
    } else {
        [self requestBlackFriend];
    }
}

//投诉
- (void)btnComplainClick {
    CoHereComplainViewController *vc = [CoHereComplainViewController new];
    vc.complainID = self.friendUID;
    vc.complainType = CIMChatType_SingleChat;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 网络请求
//设置备注和描述
- (void)requestSetRemarkAndDes:(NSString *)remark desStr:(NSString *)desStr{
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.friendUID forKey:@"friendUserUid"];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    [dict setValue:remark forKey:@"remark"];
    [dict setValue:desStr forKey:@"descRemark"];
    
    [IMSDKManager friendSetFriendRemarkAndDesWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [weakSelf.navigationController popViewControllerAnimated:YES];
        //请求更新试图
        [HUD showMessage:LanguageToolMatch(@"保存成功")];
        LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:weakSelf.userModel.userUID];
        if (friendModel != nil) {
            friendModel.remarks = remark;
            if (![NSString isNil:remark]) {
                friendModel.showName = remark;
            } else {
                friendModel.showName = friendModel.nickname;
            }
            //更新好友信息
            [weakSelf requestPullFriendInfo:friendModel.friendUserUID];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

//重新拉取好友信息
- (void)requestPullFriendInfo:(NSString *)friendUid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    [params setValue:friendUid forKey:@"friendUserUid"];
    [IMSDKManager getFriendInfoWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        NSDictionary *friendDict = (NSDictionary *)data;
        LingIMFriendModel *friendModel = [LingIMFriendModel mj_objectWithKeyValues:friendDict];
        [IMSDKManager toolUpdateMyFriendWith:friendModel];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
    }];
}

//检查是否被拉黑
- (void)requestGetBlackStatus {
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_friendUID forKey:@"friendUserUid"];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    
    [IMSDKManager getUserBlackStateWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        BOOL checkResult = [data boolValue];
        weakSelf.blackBtn.selected = checkResult;
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
    }];
    
}

//删除好友
- (void)requestDeleteFriend {
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_friendUID forKey:@"friendUserUid"];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    
    [IMSDKManager deleteContactWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD showMessage:LanguageToolMatch(@"删除成功")];
        
        //清空本地数据，删除好友服务端会删除聊天记录
        [weakSelf deleteSessionAndChatHistory];
        
        //清空好友相关的缓存
        [NoaMessageTools clearChatLocalImgAndVideoFromSessionId:weakSelf.friendUID];
        
        //返回到指定界面
        [weakSelf performSelector:@selector(navigationBackToVC) withObject:nil afterDelay:0.3];
        
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        if(code == LingIMHttpResponseCodeExamineStatus){
            [HUD showMessage:LanguageToolMatch(@"提交成功，系统稍后处理")];
        }else if (code == LingIMHttpResponseCodeNoneExamineStatus){
            [HUD showMessage:LanguageToolMatch(@"您已经提交过申请，请耐心等待审核")];
        }else{
            [HUD showMessageWithCode:code errorMsg:msg];
        }
    }];
    
}
//删除会话和聊天数据
- (void)deleteSessionAndChatHistory {
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_friendUID forKey:@"peerUid"];
    [dict setValue:@(0) forKey:@"dialogType"];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    
    [IMSDKManager deleteServerConversation:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        //删除本地会话，同时删除本地聊天内容
        LingIMSessionModel *sessionModel = [IMSDKManager toolCheckMySessionWith:weakSelf.friendUID];
        [IMSDKManager toolDeleteSessionModelWith:sessionModel andDeleteAllChatModel:YES];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
    }];
    
}

// 移除/加入 黑名单
- (void)requestBlackFriend {
    
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    [dict setValue:_friendUID forKey:@"friendUserUid"];
    
    if (self.blackBtn.selected) {
        //移出黑名单
        [dict setValue:@(0) forKey:@"status"];
        [IMSDKManager removeUserFromBlackListWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            BOOL blackAction = [data boolValue];
            weakSelf.blackBtn.selected = !blackAction;
            if (blackAction) {
                [HUD showMessage:LanguageToolMatch(@"解除黑名单成功")];
            }else {
                [HUD showMessage:LanguageToolMatch(@"解除黑名单失败")];
            }
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            [HUD showMessageWithCode:code errorMsg:msg];
        }];
        
    }else {
        //加入黑名单
        [dict setValue:@(1) forKey:@"status"];
        [IMSDKManager addUserToBlackListWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            BOOL blackAction = [data boolValue];
            weakSelf.blackBtn.selected = blackAction;
            if (blackAction) {
                [HUD showMessage:LanguageToolMatch(@"拉黑成功")];
            }else {
                [HUD showMessage:LanguageToolMatch(@"拉黑失败")];
            }
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            if(code == LingIMHttpResponseCodeExamineStatus){
                [HUD showMessage:LanguageToolMatch(@"提交成功，系统稍后处理")];
            }else if (code == LingIMHttpResponseCodeNoneExamineStatus){
                [HUD showMessage:LanguageToolMatch(@"您已经提交过申请，请耐心等待审核")];
            }else{
                [HUD showMessageWithCode:code errorMsg:msg];
            }
        }];
    }
}

//返回到指定vc
- (void)navigationBackToVC {
//    NSMutableArray *vcList = [self.navigationController.viewControllers mutableCopy];
//
//    for (NSInteger i = 0; i < self.navigationController.viewControllers.count; i++) {
//
//        UIViewController *vc = [self.navigationController.viewControllers objectAtIndexSafe:i];
//
//        if ([NSStringFromClass([vc class]) isEqualToString:@"ZUserHomePageVC"]) {
//            //用户主页
//            [vcList removeObjectAtIndexSafe:i];
//            self.navigationController.viewControllers = vcList;
//            [self.navigationController popViewControllerAnimated:YES];
//            return;
//        }
//
//    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
