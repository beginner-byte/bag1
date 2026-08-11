//
//  NoaMediaCallMiniView.m
//  NoaKit
//
//  Created by Candy on 2023/1/9.
//

#import "NoaMediaCallMiniView.h"
#import "NoaBaseImageView.h"
#import "NoaToolManager.h"
#import "NoaMediaCallManager.h"

#import "NoaMediaCallSingleVC.h"
#import "NoaMediaCallMoreVC.h"
#import "NoaNavigationController.h"

@interface NoaMediaCallMiniView ()
@property (nonatomic, strong) NoaBaseImageView *ivHeader;//头像
@property (nonatomic, strong) UILabel *lblNickname;//昵称
@property (nonatomic, strong) UILabel *lblCallTip;//提示
@property (nonatomic, strong) UIButton *btnAccept;//接收
@property (nonatomic, strong) UIButton *btnRefuse;//拒绝
@property (nonatomic, strong) UITapGestureRecognizer *tapGes;//点击手势

@property (nonatomic, strong) NoaUserModel *userModel;//对方用户信息

@property (nonatomic, strong) NoaWindowFloatView *viewFloat;//浮窗
@end

@implementation NoaMediaCallMiniView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        
        [self setupUI];
        
        //设置为不息屏
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        
        //监听关闭UI
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaCallMiniViewDismiss) name:CALLROOMCANCEL object:nil];
        //监听是否可以加入房间
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaCallRoomSingleJoin) name:CALLROOMJOIN object:nil];
        
        //销毁一下音视频通话计时器
        [[NoaMediaCallManager sharedManager] deallocCurrentCallDurationTimer];
        
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    _viewFloat = [[NoaWindowFloatView alloc] initWithFrame:CGRectMake(0, DNavStatusBarH + DWScale(10), DScreenWidth, 0)];
    _viewFloat.dragEnable = NO;
    [CurrentWindow addSubview:_viewFloat];
    
    self.frame = CGRectMake(0, 0, DScreenWidth, 0);
    self.backgroundColor = UIColor.clearColor;
    [_viewFloat addSubview:self];
    
    
    UIView *viewContent = [[UIView alloc] initWithFrame:CGRectMake(DWScale(8), 0, DScreenWidth - DWScale(16), DWScale(80))];
    viewContent.backgroundColor = UIColor.blackColor;
    viewContent.layer.cornerRadius = DWScale(16);
    viewContent.layer.masksToBounds = YES;
    [self addSubview:viewContent];
    
    _ivHeader = [[NoaBaseImageView alloc] initWithFrame:CGRectMake(DWScale(15), DWScale(15), DWScale(50), DWScale(50))];
    _ivHeader.layer.cornerRadius = DWScale(25);
    _ivHeader.layer.masksToBounds = YES;
    [viewContent addSubview:_ivHeader];
    
    _lblNickname = [UILabel new];
    _lblNickname.textColor = UIColor.whiteColor;
    _lblNickname.font = FONTR(16);
    _lblNickname.preferredMaxLayoutWidth = DWScale(150);
    [viewContent addSubview:_lblNickname];
    [_lblNickname mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_ivHeader.mas_trailing).offset(DWScale(6));
        make.top.equalTo(_ivHeader);
    }];
    
    _lblCallTip = [UILabel new];
    _lblCallTip.textColor = UIColor.whiteColor;
    _lblCallTip.font = FONTR(14);
    _lblCallTip.preferredMaxLayoutWidth = DWScale(150);
    [viewContent addSubview:_lblCallTip];
    [_lblCallTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_lblNickname);
        make.bottom.equalTo(_ivHeader);
    }];
    
    _tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    [viewContent addGestureRecognizer:_tapGes];
    
    _btnAccept = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnAccept setImage:ImgNamed(@"ms_btn_accept") forState:UIControlStateNormal];
    [_btnAccept addTarget:self action:@selector(btnAcceptClick) forControlEvents:UIControlEventTouchUpInside];
    [viewContent addSubview:_btnAccept];
    [_btnAccept mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(viewContent);
        make.trailing.equalTo(viewContent).offset(-DWScale(15));
        make.size.mas_equalTo(CGSizeMake(DWScale(40), DWScale(40)));
    }];
    
    _btnRefuse = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnRefuse setImage:ImgNamed(@"ms_btn_cancel") forState:UIControlStateNormal];
    [_btnRefuse addTarget:self action:@selector(btnRefuseClick) forControlEvents:UIControlEventTouchUpInside];
    [viewContent addSubview:_btnRefuse];
    [_btnRefuse mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(viewContent);
        make.trailing.equalTo(_btnAccept.mas_leading).offset(-DWScale(20));
        make.size.mas_equalTo(CGSizeMake(DWScale(40), DWScale(40)));
    }];
}
#pragma mark - 界面赋值
- (void)setMediaCallOptions:(NoaMediaCallOptions *)mediaCallOptions {
    if (mediaCallOptions) {
        _mediaCallOptions = mediaCallOptions;
        
        //邀请我的用户ID
        NSString *userUid;
        if (mediaCallOptions.callRoomType == ZIMCallRoomTypeSingle) {
            //单人音视频
            //告知对方，我已收到对方的单人音视频通话请求，等待我的下一步操作
            [self requestUserReceiveCall];
            userUid = self.mediaCallOptions.inviterUid;//获取邀请者信息
        }else if (mediaCallOptions.callRoomType == ZIMCallRoomTypeGroup) {
            //多人音视频
            userUid = self.mediaCallOptions.callMediaGroupModel.args.firstObject;//获取邀请者信息
        }
        
        //获取邀请者用户信息
        [self getCallRequestUserInfoWith:userUid];
    }
}

#pragma mark - 数据请求，获取对方用户信息
//获取音视频通话发起者信息
- (void)getCallRequestUserInfoWith:(NSString *)userUid{
    if (_mediaCallOptions.callRoomType == ZIMCallRoomTypeSingle) {
        //单人音视频
        LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:userUid];
        if (friendModel) {
            _userModel = [NoaUserModel new];
            _userModel.showName = friendModel.showName;
            _userModel.avatar = friendModel.avatar;
            _userModel.userName = friendModel.userName;
            _userModel.nickname = friendModel.nickname;
            _userModel.userUID = friendModel.friendUserUID;
            _userModel.remarks = friendModel.remarks;
            _userModel.descRemark = friendModel.descRemark;
            [self updateUI];
            [NoaMediaCallManager sharedManager].userModel = _userModel;
        }else {
            [self requestUserInfoWith:userUid];
        }
    }else if (_mediaCallOptions.callRoomType == ZIMCallRoomTypeGroup) {
        //多人音视频
        //群组信息
        NSString *groupID = _mediaCallOptions.callMediaGroupModel.chat_id;
        //获取群成员信息
        LingIMGroupMemberModel *groupMemberModel =  [IMSDKManager imSdkCheckGroupMemberWith:userUid groupID:groupID];
        if (groupMemberModel) {
            _userModel = [NoaUserModel new];
            _userModel.showName = groupMemberModel.showName;
            _userModel.avatar = groupMemberModel.userAvatar;
            _userModel.userName = groupMemberModel.userName;
            _userModel.nickname = groupMemberModel.userNickname;
            _userModel.userUID = groupMemberModel.userUid;
            _userModel.remarks = groupMemberModel.remarks;
            _userModel.descRemark = groupMemberModel.descRemark;
            [self updateUI];
            [NoaMediaCallManager sharedManager].userModel = _userModel;
        }else {
            [self requestUserInfoWith:userUid];
        }
    }
    
}
- (void)requestUserInfoWith:(NSString *)userUid {

    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:userUid forKey:@"userUid"];
    [IMSDKManager getUserInfoWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *userDict = (NSDictionary *)data;
            weakSelf.userModel = [NoaUserModel mj_objectWithKeyValues:userDict];
            weakSelf.userModel.userUID = [NSString stringWithFormat:@"%@",[userDict objectForKeySafe:@"userUid"]];
            [weakSelf updateUI];
            [NoaMediaCallManager sharedManager].userModel = weakSelf.userModel;
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

#pragma mark - 告知 对方 我 已收到邀请
- (void)requestUserReceiveCall {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_mediaCallOptions.callHashKey forKey:@"hash"];
    [IMSDKManager imSdkCallReceiveCallWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
    }];
}
#pragma mark - 界面更新
- (void)updateUI {
    //对方头像
    [_ivHeader sd_setImageWithURL:[_userModel.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];

    //对方昵称
    _lblNickname.text = _userModel.showName;
    
    //提示信息
    NSString *tipStr = @"";
    if (self.mediaCallOptions.callRoomType == ZIMCallRoomTypeSingle) {
        tipStr = self.mediaCallOptions.callType == LingIMCallTypeAudio ? LanguageToolMatch(@"邀请你进行语音通话") : LanguageToolMatch(@"邀请你进行视频通话");
    }else if (self.mediaCallOptions.callRoomType == ZIMCallRoomTypeGroup) {
        tipStr = self.mediaCallOptions.callType == LingIMCallTypeAudio ? LanguageToolMatch(@"邀请你进行群语音通话") : LanguageToolMatch(@"邀请你进行群视频通话");
    }
    _lblCallTip.text = tipStr;
}
#pragma mark - 动画
- (void)mediaCallMiniViewShow {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.height = DWScale(80);
        weakSelf.viewFloat.height = DWScale(80);
    }];
    
    [NoaMediaCallManager sharedManager].mediaCallState = ZMediaCallStateBegin;
}
- (void)mediaCallMiniViewDismiss {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.height = 0;
        weakSelf.viewFloat.height = 0;
    } completion:^(BOOL finished) {
        [ZTOOL doInMain:^{
            [weakSelf.viewFloat removeFromSuperview];
            weakSelf.viewFloat = nil;
        }];
    }];
}
#pragma mark - 同意音视频邀请
//单人音视频
- (void)callAccept {
    [HUD showActivityMessage:[NSString stringWithFormat:@"%@...",LanguageToolMatch(@"接听")]];
    
    [[NoaMediaCallManager sharedManager] mediaCallAcceptWith:self.mediaCallOptions onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        DLog(@"接听单人音视频通话成功，等待邀请者创建房间");
        //此时需等待发起者创建房间
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

//多人音视频
- (void)callGroupAccept {
    WeakSelf
    [[NoaMediaCallManager sharedManager] mediaCallGroupAcceptWith:self.mediaCallOptions onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        DLog(@"同意多人音视频通话");
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDict = (NSDictionary *)data;
            LIMMediaCallGroupModel *mediaCallModel = [LIMMediaCallGroupModel mj_objectWithKeyValues:dataDict];
            NoaMediaCallOptions *callOptions = [NoaMediaCallManager sharedManager].currentCallOptions;
            callOptions.callMediaGroupModel = mediaCallModel;
            NoaMediaCallMoreVC *vc = [NoaMediaCallMoreVC new];
            [vc mediaCallRoomJoin];
            NoaNavigationController *nav = [[NoaNavigationController alloc] initWithRootViewController:vc];
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            [CurrentVC presentViewController:nav animated:YES completion:nil];
            [weakSelf mediaCallMiniViewDismiss];
        }
        
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

#pragma mark - 单人音视频 房间可加入
- (void)mediaCallRoomSingleJoin {
    [HUD hideHUD];
    
    _tapGes.enabled = NO;
    
    NoaMediaCallSingleVC *callVC = [NoaMediaCallSingleVC new];
    callVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [callVC mediaCallRoomJoin];
    [CurrentVC presentViewController:callVC animated:YES completion:nil];
    
    [self mediaCallMiniViewDismiss];
}
#pragma mark - 
#pragma mark - 交互事件
- (void)tapClick {
    if (!_mediaCallOptions) return;
    _tapGes.enabled = NO;
    
    
    if (_mediaCallOptions.callRoomType == ZIMCallRoomTypeSingle) {
        NoaMediaCallSingleVC *callVC = [NoaMediaCallSingleVC new];
        callVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [CurrentVC presentViewController:callVC animated:YES completion:nil];
    }else {
        NoaMediaCallMoreVC *callVC = [NoaMediaCallMoreVC new];
        NoaNavigationController *nav = [[NoaNavigationController alloc] initWithRootViewController:callVC];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [CurrentVC presentViewController:nav animated:YES completion:nil];
    }
    
    [self mediaCallMiniViewDismiss];
}
- (void)btnAcceptClick {
    if (!_mediaCallOptions) return;
    _tapGes.enabled = NO;
    
    WeakSelf
    if (_mediaCallOptions.callType == LingIMCallTypeAudio) {
        //音频
        [ZTOOL getMicrophoneAuth:^(BOOL granted) {
            DLog(@"麦克风权限:%d",granted);
            if (weakSelf.mediaCallOptions.callRoomType == ZIMCallRoomTypeSingle) {
                //单人音视频
                [weakSelf callAccept];
            } else if (weakSelf.mediaCallOptions.callRoomType == ZIMCallRoomTypeGroup) {
                //多人音视频
                [weakSelf callGroupAccept];
            }
        }];
        
    }else {
        //视频
        [ZTOOL getMicrophoneAuth:^(BOOL granted) {
            DLog(@"麦克风权限:%d",granted);
            [ZTOOL getCameraAuth:^(BOOL granted) {
                DLog(@"相机权限:%d",granted);
                if (weakSelf.mediaCallOptions.callRoomType == ZIMCallRoomTypeSingle) {
                    //单人音视频
                    [weakSelf callAccept];
                } else if (weakSelf.mediaCallOptions.callRoomType == ZIMCallRoomTypeGroup) {
                    //多人音视频
                    [weakSelf callGroupAccept];
                }
            }];
        }];
    }
    
}
- (void)btnRefuseClick {
    _tapGes.enabled = NO;
    
    if (_mediaCallOptions) {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:self.mediaCallOptions.callHashKey forKey:@"hash"];//房间唯一标识
        [dict setValue:@"refused" forKey:@"reason"];//拒绝新的通话邀请
        WeakSelf
        //单人音视频
        
        if (_mediaCallOptions.callRoomType == ZIMCallRoomTypeSingle) {
            [[NoaMediaCallManager sharedManager] mediaCallDiscardWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                [weakSelf mediaCallMiniViewDismiss];
                [NoaMediaCallManager sharedManager].mediaCallState = ZMediaCallStateEnd;
            } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                [weakSelf mediaCallMiniViewDismiss];
            }];
            
        }
        
        //多人音视频
        if (_mediaCallOptions.callRoomType == ZIMCallRoomTypeGroup) {
            [[NoaMediaCallManager sharedManager] mediaCallGroupDiscardWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                [weakSelf mediaCallMiniViewDismiss];
                [NoaMediaCallManager sharedManager].mediaCallState = ZMediaCallStateEnd;
            } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                [weakSelf mediaCallMiniViewDismiss];
            }];
        }
        
    } else {
        [self mediaCallMiniViewDismiss];
        [NoaMediaCallManager sharedManager].mediaCallState = ZMediaCallStateEnd;
    };
    
    
}

#pragma mark - 界面销毁
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DLog(@"音视频通话-收到通话邀请弹窗-销毁");
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
