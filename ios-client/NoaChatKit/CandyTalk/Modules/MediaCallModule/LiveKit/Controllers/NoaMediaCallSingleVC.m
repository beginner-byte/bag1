//
//  NoaMediaCallSingleVC.m
//  NoaKit
//
//  Created by Candy on 2023/1/6.
//

#import "NoaMediaCallSingleVC.h"
#import "UIButton+Gradient.h"

@interface NoaMediaCallSingleVC () <ZWindowFloatViewDelegate>
@property (nonatomic, strong) UIView *viewBaseBg;//基础UI层
@property (nonatomic, strong) UIView *viewVideoBg;//视频渲染层
@property (nonatomic, strong) UIView *viewActionBg;//功能层
@property (nonatomic, strong) UIView *viewHUDBg;//提示层

@property (nonatomic, strong) NoaWindowFloatView *viewFloat;//浮窗视频流
@property (nonatomic, strong) NoaMediaCallVideoView *viewFloatVideo;

@property (nonatomic, strong) NoaMediaCallVideoView *viewPositionVideo;//固定视频流

@property (nonatomic, strong) NoaUserModel *userModel;//对方用户信息
@end

@implementation NoaMediaCallSingleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [NoaMediaCallManager sharedManager].currentScreenTrackMe = YES;
    
    //默认UI
    [self setupSingalCallUI];
    
    //根据会话状态UI
    [self setupSingalUIWithCallState];
    
    //获取对方用户信息
    _userModel = [NoaMediaCallManager sharedManager].userModel;
    
    [self updateUIWithUserModel];
    
}

#pragma mark - 单聊界面布局
//默认UI
- (void)setupSingalCallUI {
    
    //1基础UI层
    _viewBaseBg = [[UIView alloc] initWithFrame:self.view.bounds];
    _viewBaseBg.backgroundColor = UIColor.clearColor;
    [self.view addSubview:_viewBaseBg];
    
    //2视频渲染层
    _viewVideoBg = [[UIView alloc] initWithFrame:self.view.bounds];
    _viewVideoBg.backgroundColor = UIColor.clearColor;
    [self.view addSubview:_viewVideoBg];
    
    //3功能层
    _viewActionBg = [[UIView alloc] initWithFrame:self.view.bounds];
    _viewActionBg.backgroundColor = UIColor.clearColor;
    [self.view addSubview:_viewActionBg];
    
    //4提示层
    _viewHUDBg = [UIView new];
    _viewHUDBg.backgroundColor = UIColor.clearColor;
    [_viewActionBg addSubview:_viewHUDBg];
    [_viewHUDBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(_viewActionBg);
        make.height.mas_equalTo(DWScale(80));
        make.bottom.equalTo(_viewActionBg).offset(-DWScale(216) - DHomeBarH);
    }];
    
    NoaMediaCallOptions *currentCallOptions = [NoaMediaCallManager sharedManager].currentCallOptions;
    
    //模糊头像背景
    _ivHeaderBg = [[NoaBaseImageView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DScreenHeight)];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DScreenHeight)];
    toolbar.barStyle = UIBarStyleBlack;
    [_ivHeaderBg addSubview:toolbar];
    [_viewBaseBg addSubview:_ivHeaderBg];
    
    //对方头像
    _ivHeader = [[NoaBaseImageView alloc] initWithImage:DefaultAvatar];
    _ivHeader.layer.cornerRadius = DWScale(44);
    _ivHeader.layer.masksToBounds = YES;
    [_viewBaseBg addSubview:_ivHeader];
    [_ivHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(DWScale(246));
        make.size.mas_equalTo(CGSizeMake(DWScale(88), DWScale(88)));
    }];
    
    //对方昵称
    _lblNickname = [UILabel new];
    _lblNickname.tkThemetextColors = @[COLORWHITE, COLORWHITE_DARK];
    _lblNickname.font = FONTM(24);
    [_viewBaseBg addSubview:_lblNickname];
    [_lblNickname mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(_ivHeader.mas_bottom).offset(DWScale(24));
        make.leading.equalTo(self.view.mas_leading).offset(16);
    }];
    _lblNickname.numberOfLines = 2;
    _lblNickname.textAlignment = NSTextAlignmentCenter;

    //会话提示信息
    _lblCallTip = [UILabel new];
    _lblCallTip.tkThemetextColors = @[COLORWHITE, COLORWHITE_DARK];
    _lblCallTip.font = FONTR(14);
    [_viewBaseBg addSubview:_lblCallTip];
    [_lblCallTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(_lblNickname.mas_bottom).offset(DWScale(16));
    }];
    
    //闪光效果
    _viewShimmer = [NoaMediaCallShimmerView new];
    [_viewBaseBg addSubview:_viewShimmer];
    [_viewShimmer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(_viewBaseBg);
        make.top.equalTo(_lblCallTip.mas_bottom).offset(DWScale(15));
        make.height.mas_equalTo(DWScale(10));
    }];
    
    //最小化按钮
    [_viewActionBg addSubview:self.btnMini];
    [self.btnMini mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(DWScale(60));
        make.leading.equalTo(self.view).offset(DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(24), DWScale(24)));
    }];
    
    //通话时长
    _lblTime = [UILabel new];
    _lblTime.font = FONTR(17);
    _lblTime.tkThemetextColors = @[COLORWHITE, COLORWHITE_DARK];
    [_viewActionBg addSubview:_lblTime];
    [_lblTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.btnMini);
    }];
    
    //功能按钮
    if (currentCallOptions.callType == LingIMCallTypeAudio) {
        //音频通话
        [_viewActionBg addSubview:self.btnMutedAudio];//静音
        [_viewActionBg addSubview:self.btnExternal];//免提
        [_viewActionBg addSubview:self.btnEnd];//挂断(包含文字)
        
        [self.btnEnd setTitle:LanguageToolMatch(@"挂断") forState:UIControlStateNormal];
        [self.btnEnd setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:DWScale(10)];
        [self.btnEnd mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-DHomeBarH - DWScale(30));
            make.size.mas_equalTo(CGSizeMake(DWScale(60), DWScale(85)));
        }];
        [self.btnMutedAudio mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.btnEnd);
            make.leading.equalTo(self.view).offset(DWScale(40));
            make.size.mas_equalTo(CGSizeMake(DWScale(60), DWScale(85)));
        }];
        [self.btnExternal mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.btnEnd);
            make.trailing.equalTo(self.view).offset(-DWScale(40));
            make.size.mas_equalTo(CGSizeMake(DWScale(60), DWScale(85)));
        }];
        
        [_viewActionBg addSubview:self.btnRefuse];//拒绝(包含文字)
        [_viewActionBg addSubview:self.btnAccept];//接受(包含文字)
        
        [self.btnRefuse setTitle:LanguageToolMatch(@"拒绝") forState:UIControlStateNormal];
        [self.btnRefuse setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:DWScale(10)];
        [self.btnRefuse mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.view).offset(DWScale(70));
            make.bottom.equalTo(self.view).offset(-DHomeBarH - DWScale(30));
            make.size.mas_equalTo(CGSizeMake(DWScale(60), DWScale(85)));
        }];
        
        [self.btnAccept setTitle:LanguageToolMatch(@"接听") forState:UIControlStateNormal];
        [self.btnAccept setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:DWScale(10)];
        [self.btnAccept mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.view).offset(-DWScale(70));
            make.bottom.equalTo(self.view).offset(-DHomeBarH - DWScale(30));
            make.size.mas_equalTo(CGSizeMake(DWScale(60), DWScale(85)));
        }];
        
    }else {
        //视频通话
        [_viewVideoBg addSubview:self.viewPositionVideo];
        [_viewActionBg addSubview:self.viewFloat];
        
        [_viewActionBg addSubview:self.btnMutedAudio];//静音
        [_viewActionBg addSubview:self.btnMutedVideo];//摄像头
        [_viewActionBg addSubview:self.btnCameraSwitch];//切换摄像头
        
        [self.btnMutedAudio mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-DHomeBarH - DWScale(110));
            make.size.mas_equalTo(CGSizeMake(DWScale(70), DWScale(85)));
        }];
        
        [self.btnMutedVideo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-DHomeBarH - DWScale(110));
            make.leading.equalTo(self.view).offset(DWScale(40));
            make.size.mas_equalTo(CGSizeMake(DWScale(70), DWScale(85)));
        }];
        
        [self.btnCameraSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-DHomeBarH - DWScale(110));
            make.trailing.equalTo(self.view).offset(-DWScale(40));
            make.size.mas_equalTo(CGSizeMake(DWScale(70), DWScale(85)));
        }];
        
        [_viewActionBg addSubview:self.btnEnd];//挂断(不含文字)
        [self.btnEnd mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.btnMutedAudio);
            make.top.equalTo(self.btnMutedAudio.mas_bottom).offset(DWScale(30));
            make.size.mas_equalTo(CGSizeMake(DWScale(60), DWScale(60)));
        }];
        
        [_viewActionBg addSubview:self.btnRefuse];//拒绝(不含文字)
        [_viewActionBg addSubview:self.btnAccept];//接受(不含文字)
        
        [self.btnRefuse mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.view).offset(DWScale(67));
            make.top.equalTo(self.btnMutedAudio.mas_bottom).offset(DWScale(30));
            make.size.mas_equalTo(CGSizeMake(DWScale(60), DWScale(60)));
        }];
        
        [self.btnAccept mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.view).offset(-DWScale(67));
            make.top.equalTo(self.btnMutedAudio.mas_bottom).offset(DWScale(30));
            make.size.mas_equalTo(CGSizeMake(DWScale(60), DWScale(60)));
        }];
    }
    [self layoutBtn];
}

//根据通话状态创建UI
- (void)setupSingalUIWithCallState {
    NoaMediaCallOptions *currentCallOptions = [NoaMediaCallManager sharedManager].currentCallOptions;
    
    if ([NoaMediaCallManager sharedManager].currentRoomCalling) {
        //当前通话已连接成功
        
        _lblCallTip.hidden = YES;
        _viewShimmer.hidden = YES;
        
        if (currentCallOptions.callType == LingIMCallTypeAudio) {
            //音频通话
            if (currentCallOptions.callRoleType == LingIMCallRoleTypeResponse) {
                //被邀请者
                [self btnHiddenAnimationWith:self.btnRefuse];//隐藏拒绝按钮
                [self btnHiddenAnimationWith:self.btnAccept];//隐藏接受按钮
            }
            [self btnShowAnimationWith:self.btnMutedAudio];
            [self btnShowAnimationWith:self.btnEnd];
            [self btnShowAnimationWith:self.btnExternal];
        }else {
            //视频通话
            self.btnCameraSwitch.enabled = YES;
            [self btnShowAnimationWith:self.btnMutedVideo];
            [self btnShowAnimationWith:self.btnMutedAudio];
            [self btnShowAnimationWith:self.btnCameraSwitch];
            [self btnShowAnimationWith:self.btnEnd];
            
            _viewFloat.hidden = NO;
            _viewPositionVideo.hidden = NO;
            [_viewFloatVideo showHeaderWith:NO];
            [_viewPositionVideo showHeaderWith:NO];
            
            if (currentCallOptions.callRoleType == LingIMCallRoleTypeResponse) {
                //被邀请者
                [self btnHiddenAnimationWith:self.btnRefuse];//隐藏拒绝按钮
                [self btnHiddenAnimationWith:self.btnAccept];//隐藏接受按钮
            }
            //开启扬声器
            [[NoaMediaCallManager sharedManager] mediaCallAudioSpeaker:YES];
            
            WeakSelf
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [weakSelf setupVideoTrack];
            });
        }
    }else {
        //当前通话未连接成功
        _lblCallTip.hidden = NO;
        _viewShimmer.hidden = NO;
        
        if (currentCallOptions.callType == LingIMCallTypeAudio) {
            //音频通话
            if (currentCallOptions.callRoleType == LingIMCallRoleTypeResponse) {
                //被邀请方
                _lblCallTip.text = LanguageToolMatch(@"邀请你进行语音通话");
                [self btnShowAnimationWith:self.btnRefuse];
                [self btnShowAnimationWith:self.btnAccept];
            }else {
                //邀请方
                _lblCallTip.text = LanguageToolMatch(@"正在等待对方接受邀请");
                [self btnShowAnimationWith:self.btnMutedAudio];
                [self btnShowAnimationWith:self.btnEnd];
                [self btnShowAnimationWith:self.btnExternal];
            }
        }else {
            //视频通话
            self.btnCameraSwitch.enabled = NO;
            [self btnShowAnimationWith:self.btnMutedVideo];
            [self btnShowAnimationWith:self.btnMutedAudio];
            [self btnShowAnimationWith:self.btnCameraSwitch];
            
            if (currentCallOptions.callRoleType == LingIMCallRoleTypeResponse) {
                //被邀请方
                _lblCallTip.text = LanguageToolMatch(@"邀请你进行视频通话");
                [self btnShowAnimationWith:self.btnRefuse];
                [self btnShowAnimationWith:self.btnAccept];
            }else {
                //邀请方
                _lblCallTip.text = LanguageToolMatch(@"正在等待对方接受邀请");
                [self btnShowAnimationWith:self.btnEnd];
            }
        }
    }
}

#pragma mark - 更新UI
//更新对方的用户信息UI
- (void)updateUIWithUserModel {
    //对方头像
    [_ivHeader sd_setImageWithURL:[self.userModel.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
    [_ivHeaderBg sd_setImageWithURL:[self.userModel.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
    //对方昵称
    _lblNickname.text = self.userModel.nickname;
}

#pragma mark - 音视频房间加入
- (void)mediaCallRoomJoin {
    [HUD hideHUD];
    
    if ([NoaMediaCallManager sharedManager].currentRoomCalling) return;
    
    NoaIMCallOptions *callOptions = [NoaIMCallOptions new];
    callOptions.callRoomUrl = [NoaMediaCallManager sharedManager].currentCallOptions.callRoomUrl;
    callOptions.callRoomToken = [NoaMediaCallManager sharedManager].currentCallOptions.callRoomToken;
    callOptions.callType = [NoaMediaCallManager sharedManager].currentCallOptions.callType;
    callOptions.callRoleType = [NoaMediaCallManager sharedManager].currentCallOptions.callRoleType;
    callOptions.callMicState = [NoaMediaCallManager sharedManager].currentCallOptions.callMicState;
    callOptions.callCameraState = [NoaMediaCallManager sharedManager].currentCallOptions.callCameraState;
    
    [[NoaMediaCallManager sharedManager] mediaCallConnectRoomWith:callOptions delegate:self];
}

#pragma mark - 接受通话
- (void)callAccept {
    [HUD showActivityMessage:[NSString stringWithFormat:@"%@...",LanguageToolMatch(@"接听")]];
    
    NoaMediaCallOptions *currentCallOptions = [NoaMediaCallManager sharedManager].currentCallOptions;
    
    [[NoaMediaCallManager sharedManager] mediaCallAcceptWith:currentCallOptions onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        DLog(@"接听单人音视频通话成功，等待邀请者创建房间");
        
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
        DLog(@"接听单人音视频通话失败");
    }];
}

#pragma mark - 渲染视频轨道
- (void)setupVideoTrack {
    if (![NoaMediaCallManager sharedManager].currentRoomCalling) return;
    
    //本地参与者
    LocalTrackPublication *publication = [NoaMediaCallManager sharedManager].mediaCallRoom.localParticipant.localVideoTracks.firstObject;
    [self updateVideoTrackWith:publication.track remoteTrack:NO];
    
    //远端参与者
    NSArray *remoteParticipantList = [[NoaMediaCallManager sharedManager] mediaCallRoomRemotePaticipants];
    Participant *remoteParticipant = remoteParticipantList.firstObject;
    if (remoteParticipant) {
        [self updateVideoTrackWith:remoteParticipant.videoTracks.firstObject.track remoteTrack:YES];
    }
    
    //头像展示
    if ([NoaMediaCallManager sharedManager].currentScreenTrackMe) {
        //我的头像
        [self.viewPositionVideo.ivHeader sd_setImageWithURL:[UserManager.userInfo.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];//展示本地轨道
        //对方头像
        [self.viewFloatVideo.ivHeader sd_setImageWithURL:[self.userModel.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];//展示远端轨道
    }else {
        [self.viewFloatVideo.ivHeader sd_setImageWithURL:[UserManager.userInfo.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];//展示本地轨道
        
        [self.viewPositionVideo.ivHeader sd_setImageWithURL:[self.userModel.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];//展示远端轨道
    }
}

- (void)updateVideoTrackWith:(id)videoTrack remoteTrack:(BOOL)remote {
    if ([videoTrack conformsToProtocol:@protocol(VideoTrack)]) {
        if ([NoaMediaCallManager sharedManager].currentScreenTrackMe) {
            if (remote) {
                //远端
                self.viewFloatVideo.viewVideo.track = videoTrack;
                RemoteVideoTrack *temp = (RemoteVideoTrack *)videoTrack;
                [self.viewFloatVideo showHeaderWith:temp.muted];
            } else {
                //本地
                self.viewPositionVideo.viewVideo.track = videoTrack;
                LocalVideoTrack *temp = (LocalVideoTrack *)videoTrack;
                [self.viewPositionVideo showHeaderWith:temp.muted];
            }
        } else {
            if (remote) {
                //远端
                self.viewPositionVideo.viewVideo.track = videoTrack;
                RemoteVideoTrack *temp = (RemoteVideoTrack *)videoTrack;
                [self.viewPositionVideo showHeaderWith:temp.muted];
            } else {
                //本地
                self.viewFloatVideo.viewVideo.track = videoTrack;
                LocalVideoTrack *temp = (LocalVideoTrack *)videoTrack;
                [self.viewFloatVideo showHeaderWith:temp.muted];
            }
        }
    }
}

- (void)updateVideoTrackUIWith:(BOOL)showHeader remote:(BOOL)remote {
    if ([NoaMediaCallManager sharedManager].currentScreenTrackMe) {
        if (remote) {
            [self.viewFloatVideo showHeaderWith:showHeader];
        }else {
            [self.viewPositionVideo showHeaderWith:showHeader];
        }
    } else {
        if (remote) {
            [self.viewPositionVideo showHeaderWith:showHeader];
        } else {
            [self.viewFloatVideo showHeaderWith:showHeader];
        }
    }
}

#pragma mark - 交互事件
//最小化
- (void)btnMiniClick {
    NoaWindowFloatView *viewMediaCall = [NoaWindowFloatView new];
    viewMediaCall.isKeepBounds = YES;

    NoaMediaCallOptions *currentCallOptions = [NoaMediaCallManager sharedManager].currentCallOptions;
    if (currentCallOptions.callType == LingIMCallTypeAudio) {
        //音频通话
        viewMediaCall.frame = CGRectMake(0, DNavStatusBarH, DWScale(86), DWScale(101));
    } else {
        //视频通话
        if ([NoaMediaCallManager sharedManager].currentRoomCalling) {
            //当前正在通话中
            viewMediaCall.frame = CGRectMake(0, DNavStatusBarH, DWScale(86), DWScale(126));
        } else {
            viewMediaCall.frame = CGRectMake(0, DNavStatusBarH, DWScale(86), DWScale(101));
        }
    }
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    viewMediaCall.delegate = appDelegate;
    appDelegate.viewFloatWindow = viewMediaCall;
    
    NoaMediaCallFloatView *viewFloat = [NoaMediaCallFloatView new];
    viewFloat.userModel = self.userModel;
    [viewMediaCall addSubview:viewFloat];
    [viewFloat mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(viewMediaCall);
    }];
    [CurrentWindow addSubview:viewMediaCall];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//通话结束
- (void)btnEndClick {
    NoaMediaCallOptions *currentCallOptions = [NoaMediaCallManager sharedManager].currentCallOptions;
    
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:currentCallOptions.callHashKey forKey:@"hash"];
    
    //配置挂断原因
    if (currentCallOptions.callRoleType == LingIMCallRoleTypeRequest) {
        //邀请者
        if (![NoaMediaCallManager sharedManager].currentRoomCalling) {
            //取消通话
            [dict setValue:@"cancel" forKey:@"reason"];//主叫方取消通话
        } else {
            //挂断通话
            [dict setValue:@"" forKey:@"reason"];//通话建立之后正常挂断
        }
    } else {
        //被邀请者
        if (![NoaMediaCallManager sharedManager].currentRoomCalling) {
            //拒绝通话
            [dict setValue:@"refused" forKey:@"reason"];//拒绝
        } else {
            //挂断电话
            [dict setValue:@"" forKey:@"reason"];//通话建立之后正常挂断
        }
    }
    
    //调用接口
    [[NoaMediaCallManager sharedManager] mediaCallDiscardWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
        
        if ([NoaMediaCallManager sharedManager].currentRoomCalling) {
            //断开连接
            [[NoaMediaCallManager sharedManager] mediaCallDisconnect];
        }
        
        [NoaMediaCallManager sharedManager].mediaCallState = ZMediaCallStateEnd;
        
        NSString *discardReason = [NSString stringWithFormat:@"%@", [dict objectForKeySafe:@"reason"]];
        if ([NSString isNil:discardReason]) {
            //销毁一下定时器，挂断操作
            [[NoaMediaCallManager sharedManager] deallocCurrentCallDurationTimer];            
        }
        
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

/*
 /// reason:原因
 /// 1."": 空字符串, 通话建立之后正常挂断
 /// 2.disconnect: 通话中断, 服务器强制挂断
 /// 3.missed: 对方无应答, 客户端主叫方呼叫超时挂断
 /// 4.cancel: 通话已取消, 主叫方取消通话
 /// 5.refused: 对方已拒绝
 */

- (void)btnAcceptClick {
    NoaMediaCallOptions *currentCallOptions = [NoaMediaCallManager sharedManager].currentCallOptions;
    if (!currentCallOptions) return;
    WeakSelf
    if (currentCallOptions.callType == LingIMCallTypeAudio) {
        //音频
        [ZTOOL getMicrophoneAuth:^(BOOL granted) {
            DLog(@"麦克风权限:%d",granted);
            [weakSelf callAccept];
        }];
    } else {
        //视频
        [ZTOOL getMicrophoneAuth:^(BOOL granted) {
            DLog(@"麦克风权限:%d",granted);
            [ZTOOL getCameraAuth:^(BOOL granted) {
                DLog(@"相机权限:%d",granted);
                [weakSelf callAccept];
            }];
        }];
    }
}

//音频静默
- (void)btnMutedAudioClick {
    WeakSelf
    if (self.btnMutedAudio.isSelected) {
        //执行关闭静音
        [[NoaMediaCallManager sharedManager] mediaCallAudioMute:NO complete:^(BOOL isMuted) {
            if (!isMuted) {
                weakSelf.btnMutedAudio.selected = NO;
                [HUD showMessage:LanguageToolMatch(@"静音关闭") inView:weakSelf.viewHUDBg];
            }
        }];
    } else {
        //执行开启静音
        [[NoaMediaCallManager sharedManager] mediaCallAudioMute:YES complete:^(BOOL isMuted) {
            if (isMuted) {
                weakSelf.btnMutedAudio.selected = YES;
                [HUD showMessage:LanguageToolMatch(@"静音开启") inView:weakSelf.viewHUDBg];
            }
        }];
    }
}

//视频静默
- (void)btnMutedVideoClick {
    WeakSelf
    if (self.btnMutedVideo.isSelected) {
        //执行关闭静默
        [[NoaMediaCallManager sharedManager] mediaCallVideoMute:NO complete:^(BOOL isMuted) {
            if (!isMuted) {
                weakSelf.btnMutedVideo.selected = NO;
                [HUD showMessage:LanguageToolMatch(@"摄像头开启") inView:weakSelf.viewHUDBg];
            }
        }];
    } else {
        //执行开启静默
        [[NoaMediaCallManager sharedManager] mediaCallVideoMute:YES complete:^(BOOL isMuted) {
            if (isMuted) {
                weakSelf.btnMutedVideo.selected = YES;
                [HUD showMessage:LanguageToolMatch(@"摄像头关闭") inView:weakSelf.viewHUDBg];
            }
        }];
    }
}

//扬声器
- (void)btnExternalClick {
    if (self.btnExternal.isSelected) {
        //关闭免提扬声器
        [[NoaMediaCallManager sharedManager] mediaCallAudioSpeaker:NO];
        self.btnExternal.selected = NO;
        [HUD showMessage:LanguageToolMatch(@"免提关闭") inView:_viewHUDBg];
    }else {
        //开启免提扬声器
        [[NoaMediaCallManager sharedManager] mediaCallAudioSpeaker:YES];
        self.btnExternal.selected = YES;
        [HUD showMessage:LanguageToolMatch(@"免提开启") inView:_viewHUDBg];
    }
}

//切换摄像头
- (void)btnCameraSwitchClick {
    [[NoaMediaCallManager sharedManager] mediaCallVideoCameraSwitch:^(BOOL success) {
        DLog(@"切换摄像头");
    }];
}

#pragma mark - ZMediaCallManagerDelegate
- (void)mediaCallCurrentDuration:(NSInteger)duration {
    if (duration > 0) {
        _lblTime.text = [NSString getTimeLengthHMS:duration];
    }else {
        _lblTime.text = @"";
    }
}

#pragma mark - RoomDelegateObjC
//房间状态更新
- (void)room:(Room *)room didUpdateConnectionState:(enum ConnectionState)connectionState oldConnectionState:(enum ConnectionState)oldConnectionState {
    switch (connectionState) {
        case ConnectionStateDisconnected:
        {
            DLog(@"当前房间-断开连接-0");
        }
            break;
        case ConnectionStateConnecting:
        {
            DLog(@"当前房间-正在连接-1");
        }
            break;
        case ConnectionStateReconnecting:
        {
            DLog(@"当前房间-重新连接-2");
        }
            break;
        case ConnectionStateConnected:
        {
            DLog(@"当前房间-连接成功-3");
            if ([NoaMediaCallManager sharedManager].mediaCallState != ZMediaCallStateCall) {
                //连接成功后，执行一次即可
                [NoaMediaCallManager sharedManager].mediaCallState = ZMediaCallStateCall;
                //更新UI 主线程
                WeakSelf
                [ZTOOL doInMain:^{
                    [weakSelf setupSingalUIWithCallState];
                    [[NoaMediaCallManager sharedManager] createCurrentCallDurationTimer];
                    [HUD showMessage:LanguageToolMatch(@"连接成功") inView:weakSelf.viewHUDBg];
                }];
            }
        }
        default:
            break;
    }
    DLog(@"房间代理---0");
}

//房间连接成功
- (void)room:(Room *)room didConnectIsReconnect:(BOOL)isReconnect {
    DLog(@"当前房间-连接成功");
    DLog(@"房间代理---1");
}

//房间连接失败
- (void)room:(Room *)room didFailToConnectWithError:(NSError *)error {
    DLog(@"当前房间-连接失败");
    DLog(@"房间代理---2");
}

//房间断开连接
- (void)room:(Room *)room didDisconnectWithError:(NSError *)error {
    DLog(@"当前房间-断开连接");
    DLog(@"房间代理---3");
}

//房间有参与者加入
- (void)room:(Room *)room participantDidJoin:(RemoteParticipant *)participant {
    DLog(@"当前房间-有参与者加入");
    DLog(@"房间代理---4");
}

//房间有参与者离开
- (void)room:(Room *)room participantDidLeave:(RemoteParticipant *)participant {
    DLog(@"当前房间-有参与者离开");
    DLog(@"房间代理---5");
}

//参与者扬声器改变
- (void)room:(Room *)room didUpdateSpeakers:(NSArray<Participant *> *)speakers {
    DLog(@"当前房间-参与者扬声器改变，是谁在说话");
    DLog(@"房间代理---6");
}

//房间的元数据发生改变
- (void)room:(Room *)room didUpdateMetadata:(NSString *)metadata {
    DLog(@"当前房间-元数据发生改变");
    DLog(@"房间代理---7");
}

//房间的参与者元数据发生改变 ParticipantDelegate有相同功能 participant:didUpdateMetadata:
- (void)room:(Room *)room participant:(Participant *)participant didUpdateMetadata:(NSString *)metadata {
    DLog(@"当前房间-参与者元数据发生改变");
    DLog(@"房间代理---8");
}

- (void)room:(Room *)room participant:(Participant *)participant didUpdateConnectionQuality:(enum ConnectionQuality)connectionQuality {
    DLog(@"房间代理---9");
    
}

//房间的参与者轨道静默状态发生改变 ParticipantDelegate有相同功能 participant:publication:didUpdateMuted:
- (void)room:(Room *)room participant:(Participant *)participant publication:(TrackPublication *)publication didUpdateMuted:(BOOL)muted {
    DLog(@"房间代理---10");
    if ([participant isKindOfClass:[LocalParticipant class]]) {
        //本地参与者轨道发生变化
        LocalTrackPublication *localT = (LocalTrackPublication *)publication;
        if ([localT.track isKindOfClass:[LocalVideoTrack class]]) {
            //本地参与者视频轨道发生变化
            [self updateVideoTrackUIWith:muted remote:NO];
            if (!muted) {
                //本地参与者视频轨道静默关闭
                [self updateVideoTrackWith:localT.track remoteTrack:NO];
            }
        } else {
            DLog(@"本地参与者音频轨道发生变化");
        }
    } else {
        //远端参与者轨道发生变化
        RemoteTrackPublication *remoteT = (RemoteTrackPublication *)publication;
        if ([remoteT.track isKindOfClass:[RemoteVideoTrack class]]) {
            //远端参与者视频轨道发生变化
            [self updateVideoTrackUIWith:muted remote:YES];
            if (!muted) {
                [self updateVideoTrackWith:remoteT.track remoteTrack:YES];
            }
        } else {
            DLog(@"远端参与者音频轨道发生变化");
        }
    }
}

- (void)room:(Room *)room participant:(Participant *)participant didUpdatePermissions:(ParticipantPermissions *)permissions {
    DLog(@"房间代理---11");
}

- (void)room:(Room *)room participant:(RemoteParticipant *)participant publication:(RemoteTrackPublication *)publication didUpdateStreamState:(enum StreamState)streamState {
    DLog(@"房间代理---12");
}

- (void)room:(Room *)room participant:(RemoteParticipant *)participant didPublishPublication:(RemoteTrackPublication *)publication {
    DLog(@"房间代理---13");
}

- (void)room:(Room *)room participant:(RemoteParticipant *)participant didUnpublishPublication:(RemoteTrackPublication *)publication {
    DLog(@"房间代理---14");
}

//房间的本地参与者 订阅了一个新的远端音视频轨道；只要有新的轨道可以使用，这个事件就会触发
- (void)room:(Room *)room participant:(RemoteParticipant *)participant didSubscribePublication:(RemoteTrackPublication *)publication track:(Track *)track {
    DLog(@"房间代理---15");
    //单聊直接用，如果是多人，要更新远端轨道数组
    [self setupVideoTrack];
    
//    id remoteTrack = publication.track;
//    if ([remoteTrack conformsToProtocol:@protocol(VideoTrack)]) {
//        if ([ZMediaCallManager sharedManager].currentScreenTrackMe) {
//            self.viewFloatVideo.viewVideo.track = remoteTrack;
//        } else {
//            self.viewPositionVideo.viewVideo.track = remoteTrack;
//        }
//    }
}

- (void)room:(Room *)room participant:(RemoteParticipant *)participant didFailToSubscribe:(NSString *)trackSid error:(NSError *)error {
    DLog(@"房间代理---16");
}

- (void)room:(Room *)room publication:(RemoteParticipant *)participant didUnsubscribePublication:(RemoteTrackPublication *)publication track:(Track *)track {
    DLog(@"房间代理---17");
}

- (void)room:(Room *)room participant:(RemoteParticipant *)participant didReceiveData:(NSData *)data {
    DLog(@"房间代理---18");
}

//房间的 本地 参与者 发布了 音视频轨道
- (void)room:(Room *)room localParticipant:(LocalParticipant *)localParticipant didPublishPublication:(LocalTrackPublication *)publication {
    DLog(@"房间代理---19");
    [self setupVideoTrack];
//    id localTrack = publication.track;
//    if ([localTrack conformsToProtocol:@protocol(VideoTrack)]) {
//        if ([ZMediaCallManager sharedManager].currentScreenTrackMe) {
//            self.viewPositionVideo.viewVideo.track = localTrack;
//        } else {
//            self.viewFloatVideo.viewVideo.track = localTrack;
//        }
//    }
}

- (void)room:(Room *)room localParticipant:(LocalParticipant *)localParticipant didUnpublishPublication:(LocalTrackPublication *)publication {
    DLog(@"房间代理---20");
}

- (void)room:(Room *)room participant:(RemoteParticipant *)participant didUpdate:(RemoteTrackPublication *)publication permission:(BOOL)allowed {
    DLog(@"房间代理---21");
}

#pragma mark - ZWindowFloatViewDelegate
- (void)clickFloatView:(NoaWindowFloatView *)floatView {
    [NoaMediaCallManager sharedManager].currentScreenTrackMe = ![NoaMediaCallManager sharedManager].currentScreenTrackMe;
    [self setupVideoTrack];
    
//    //本地参与者
//    LocalTrackPublication *publication = [ZMediaCallManager sharedManager].mediaCallRoom.localParticipant.localVideoTracks.firstObject;
//    id localTrack = publication.track;
//    if ([localTrack conformsToProtocol:@protocol(VideoTrack)]) {
//        if ([ZMediaCallManager sharedManager].currentScreenTrackMe) {
//            self.viewPositionVideo.viewVideo.track = localTrack;
//        } else {
//            self.viewFloatVideo.viewVideo.track = localTrack;
//        }
//    }
//
//    //远端参与者
//    NSArray *remoteParticipantList = [[ZMediaCallManager sharedManager] mediaCallRoomRemotePaticipants];
//    Participant *remoteParticipant = remoteParticipantList.firstObject;
//    id remoteTrack = remoteParticipant.videoTracks.firstObject.track;
//    if ([remoteTrack conformsToProtocol:@protocol(VideoTrack)]) {
//        if ([ZMediaCallManager sharedManager].currentScreenTrackMe) {
//            self.viewFloatVideo.viewVideo.track = remoteTrack;
//        } else {
//            self.viewPositionVideo.viewVideo.track = remoteTrack;
//        }
//    }
}

#pragma mark - 懒加载
- (NoaWindowFloatView *)viewFloat {
    if (!_viewFloat) {
        _viewFloat = [[NoaWindowFloatView alloc] initWithFrame:CGRectMake(DScreenWidth - DWScale(128), DNavStatusBarH + DWScale(34), DWScale(112), DWScale(200))];
        _viewFloat.layer.cornerRadius = DWScale(8);
        _viewFloat.layer.masksToBounds = YES;
        _viewFloat.delegate = self;
        _viewFloat.hidden = YES;
        
        _viewFloatVideo = [[NoaMediaCallVideoView alloc] initWithFrame:CGRectMake(0, 0, DWScale(112), DWScale(200))];
        _viewFloatVideo.layer.cornerRadius = DWScale(8);
        _viewFloatVideo.layer.masksToBounds = YES;
        [_viewFloat addSubview:_viewFloatVideo];
    }
    return _viewFloat;
}

- (NoaMediaCallVideoView *)viewPositionVideo {
    if (!_viewPositionVideo) {
        _viewPositionVideo = [[NoaMediaCallVideoView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DScreenHeight)];
        _viewPositionVideo.hidden = YES;
    }
    return _viewPositionVideo;
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
