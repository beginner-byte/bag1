//
//  NoaApplyJoinGroupViewController.m
//  NoaKit
//
//  Created by Candy on 2023/4/6.
//

#import "NoaApplyJoinGroupViewController.h"
#import "NoaBaseImageView.h"
#import "NoaChatViewController.h"
#import "NoaAlertInputTipView.h"

@interface NoaApplyJoinGroupViewController ()

@property (nonatomic, strong)NoaBaseImageView *groupHeadImgView;
@property (nonatomic, strong)UILabel *groupTitleLbl;
@property (nonatomic, strong)UILabel *groupNumLbl;

@end

@implementation NoaApplyJoinGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navTitleStr = LanguageToolMatch(@"群设置");
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    
    [self setupUI];
}

#pragma mark - 界面布局
- (void)setupUI {
    //群信息
    UIView *groupInfoBack = [[UIView alloc] init];
    groupInfoBack.tkThemebackgroundColors = @[COLORWHITE, COLOR_F5F6F9_DARK];
    [groupInfoBack rounded:14];
    [self.view addSubview:groupInfoBack];
    [groupInfoBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navView.mas_bottom).offset(DWScale(16));
        make.leading.equalTo(self.view).offset(DWScale(16));
        make.trailing.equalTo(self.view).offset(-DWScale(16));
        make.height.mas_equalTo(DWScale(176));
    }];
    
    //群头像
    _groupHeadImgView = [[NoaBaseImageView alloc] init];
    [_groupHeadImgView rounded:DWScale(22)];
    [_groupHeadImgView sd_setImageWithURL:[_applyGroupModel.groupInfo.avatar getImageFullUrl] placeholderImage:DefaultGroup options:SDWebImageAllowInvalidSSLCertificates];
    [groupInfoBack addSubview:_groupHeadImgView];
    [_groupHeadImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.equalTo(groupInfoBack).offset(DWScale(16));
        make.width.mas_equalTo(DWScale(44));
        make.height.mas_equalTo(DWScale(44));
    }];
    
    //群名称
    _groupTitleLbl = [[UILabel alloc] init];
    _groupTitleLbl.text = _applyGroupModel.groupInfo.gName;
    _groupTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _groupTitleLbl.font = FONTN(16);
    [groupInfoBack addSubview:_groupTitleLbl];
    [_groupTitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_groupHeadImgView.mas_trailing).offset(DWScale(5));
        make.trailing.equalTo(groupInfoBack).offset(-DWScale(16));
        make.centerY.equalTo(_groupHeadImgView);
        make.height.mas_equalTo(DWScale(22));
    }];
    
    //分割线1
    UIView *infoLineView = [[UIView alloc] init];
    infoLineView.tkThemebackgroundColors = @[COLOR_EEEEEE, COLOR_EEEEEE_DARK];
    [groupInfoBack addSubview:infoLineView];
    [infoLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_groupHeadImgView.mas_bottom).offset(DWScale(16));
        make.leading.equalTo(groupInfoBack).offset(DWScale(16));
        make.trailing.equalTo(groupInfoBack).offset(-DWScale(16));
        make.height.mas_equalTo(1);
    }];
    
    //群成员title
    UILabel *memberTitleLbl = [[UILabel alloc] init];
    memberTitleLbl.text = LanguageToolMatch(@"群成员");
    memberTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    memberTitleLbl.font = FONTN(14);
    [groupInfoBack addSubview:memberTitleLbl];
    [memberTitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(infoLineView.mas_bottom).offset(DWScale(10));
        make.leading.equalTo(groupInfoBack).offset(DWScale(16));
        make.width.mas_equalTo(DWScale(100));
        make.height.mas_equalTo(DWScale(20));
    }];
    
    //箭头
    UIImageView *arrowImgView = [[UIImageView alloc] init];
    arrowImgView.image = ImgNamed(@"c_arrow_right_gray");
    [groupInfoBack addSubview:arrowImgView];
    [arrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(infoLineView.mas_bottom).offset(DWScale(12));
        make.trailing.equalTo(groupInfoBack).offset(-DWScale(16));
        make.width.mas_equalTo(DWScale(8));
        make.height.mas_equalTo(DWScale(16));
    }];
    
    //群人数
    _groupNumLbl = [[UILabel alloc] init];
    _groupNumLbl.text = [NSString stringWithFormat:LanguageToolMatch(@"%d人"), _applyGroupModel.groupInfo.groupMemberCount];
    _groupNumLbl.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    _groupNumLbl.font = FONTN(14);
    _groupNumLbl.textAlignment = NSTextAlignmentRight;
    [groupInfoBack addSubview:_groupNumLbl];
    [_groupNumLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(arrowImgView.mas_leading).offset(-DWScale(6));
        make.centerY.equalTo(memberTitleLbl);
        make.width.mas_equalTo(DWScale(60));
        make.height.mas_equalTo(DWScale(20));
    }];
    
    //群成员头像展示
    for (int i = 0; i<_applyGroupModel.groupMemberList.count; i++) {
        NoaJoinGroupMemberModel *memberModel = (NoaJoinGroupMemberModel *)[_applyGroupModel.groupMemberList objectAtIndex:i];
        
        NoaBaseImageView *memberAvatar = [[NoaBaseImageView alloc] init];
        [memberAvatar rounded:DWScale(22)];
        [memberAvatar sd_setImageWithURL:[memberModel.userAvatarFileName getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
        [groupInfoBack addSubview:memberAvatar];
        [memberAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(memberTitleLbl.mas_bottom).offset(DWScale(10));
            make.leading.equalTo(groupInfoBack).offset(DWScale(16) + (DWScale(44)+DWScale(9))*i);
            make.width.mas_equalTo(DWScale(44));
            make.height.mas_equalTo(DWScale(44));
        }];
    }
    
    //加入群聊
    UIButton *joinButton = [[UIButton alloc] init];
    [joinButton setTitle:LanguageToolMatch(@"加入群聊") forState:UIControlStateNormal];
    [joinButton setTitleColor:COLORWHITE forState:UIControlStateNormal];
    joinButton.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    [joinButton setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateSelected];
    [joinButton setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateHighlighted];
    [joinButton rounded:DWScale(16)];
    [joinButton addTarget:self action:@selector(joinGroupAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:joinButton];
    [joinButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(groupInfoBack.mas_bottom).offset(DWScale(26));
        make.leading.equalTo(self.view).offset(DWScale(16));
        make.trailing.equalTo(self.view).offset(-DWScale(16));
        make.height.mas_equalTo(DWScale(50));
    }];
    
    if ([UserManager.userRoleAuthInfo.showGroupPersonNum.configValue isEqualToString:@"true"]) {
        _groupNumLbl.hidden = NO;
    } else {
        if ([_applyGroupModel.showGroupCountOfAdm isEqualToString:@"0"]) {
            _groupNumLbl.hidden = NO;
        } else {
            _groupNumLbl.hidden = YES;
        }
    }
}

#pragma mark - Setter
- (void)setApplyGroupModel:(NoaJoinGroupModel *)applyGroupModel {
    _applyGroupModel = applyGroupModel;
}

#pragma mark - Action
- (void)navBtnBackClicked {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//加入群聊
- (void)joinGroupAction {
    if (self.applyGroupModel.groupInfo.isNeedVerify) {
        NoaAlertInputTipView *joinApplyAlertTip = [NoaAlertInputTipView new];
        joinApplyAlertTip.lblTip.text = LanguageToolMatch(@"群主或管理员已启用“群聊邀请确认”, 请描述邀请原因");
        joinApplyAlertTip.textView.placeHolder = LanguageToolMatch(@"说明邀请理由");
        [joinApplyAlertTip alertTipViewShow];
        WeakSelf
        [joinApplyAlertTip setSureBtnBlock:^(NSString * _Nonnull inputStr) {
            [weakSelf requestApplyJoinGroupWithReason:inputStr];
        }];
    } else {
        [self requestApplyJoinGroupWithReason:@""];
    }
}

#pragma mark - Request NetWorking
- (void)requestApplyJoinGroupWithReason:(NSString *)reason {
    int isTop = 0;//会话是否置顶,1:置顶0：取消置顶
    int isDnd = 0;//会话是否免打扰,1:开启免打扰0：取消免打扰
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:[NSNumber numberWithInt:isDnd] forKey:@"adviceStatus"];
    [dict setObjectSafe:reason forKey:@"applyDesc"];
    [dict setObjectSafe:_applyGroupModel.groupInfo.gid forKey:@"groupId"];
    [dict setObjectSafe:@4 forKey:@"inviteType"];//邀请进群类型(4:二维码邀请,2:链接邀请,3:邀请入群,1:面对面入群)
    [dict setObjectSafe:_applyGroupModel.shareUserUid forKey:@"inviteUserId"];
    [dict setObjectSafe:[NSNumber numberWithInt:isTop] forKey:@"topStatus"];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    
    WeakSelf
    [HUD showActivityMessage:@""];
    [IMSDKManager UserApplyJoinGroupWithData:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD hideHUD];
        BOOL result = [data boolValue];
        if (result) {
            if (self.applyGroupModel.groupInfo.isNeedVerify) {
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            } else {
                //进入群聊天
                NoaChatViewController *chatVC = [[NoaChatViewController alloc] init];
                chatVC.isFromQRCode = YES;
                chatVC.chatName = weakSelf.applyGroupModel.groupInfo.gName;
                chatVC.sessionID = weakSelf.applyGroupModel.groupInfo.gid;
                chatVC.chatType = CIMChatType_GroupChat;
                [weakSelf.navigationController pushViewController:chatVC animated:YES];
            }
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD hideHUD];
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}


@end
