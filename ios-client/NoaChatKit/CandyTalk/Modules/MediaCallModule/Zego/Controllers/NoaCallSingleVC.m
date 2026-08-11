//
//  NoaCallSingleVC.m
//  NoaKit
//
//  Created by Candy on 2023/5/19.
//

#import "NoaCallSingleVC.h"
#import "UIButton+Gradient.h"

@interface NoaCallSingleVC () <ZWindowFloatViewDelegate>
@property (nonatomic, strong) UIView *viewBaseBg;//基础UI层
@property (nonatomic, strong) UIView *viewVideoBg;//视频渲染层
@property (nonatomic, strong) UIView *viewActionBg;//功能层
@property (nonatomic, strong) UIView *viewHUDBg;//提示层

//浮窗视频流
@property (nonatomic, strong) NoaWindowFloatView *viewFloat;
@property (nonatomic, strong) NoaMediaCallVideoView *viewFloatVideo;

//固定视频流
@property (nonatomic, strong) NoaMediaCallVideoView *viewPositionVideo;

@property (nonatomic, strong) NoaCallUserModel *localUserModel;//本地用户信息(我)
@property (nonatomic, strong) NoaCallUserModel *remoteUserModel;//远端用户信息(对方)
@end

@implementation NoaCallSingleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupVideoTrack) name:ZGCALLROOMSINGLEMEMBERUPDATE object:nil];
    
    //获取本地和远端用户信息
    NoaCallOptions *currentCallOptions = [NoaCallManager sharedManager].currentCallOptions;
    if ([currentCallOptions.zgCallOptions.callRoomCreateUserID isEqualToString:UserManager.userInfo.userUID]) {
        //我是 单聊 邀请者
        _localUserModel = currentCallOptions.inviterUserModel;
        _remoteUserModel = currentCallOptions.inviteeUserModel;
    }else {
        //我是 单聊 被邀请者
        _localUserModel = currentCallOptions.inviteeUserModel;
        _remoteUserModel = currentCallOptions.inviterUserModel;
    }
    
    //默认UI
    [self setupSingalCallUI];
    
    //更新远端用户信息
    [self updateRemoteWithUserModel];
    
    //根据会话状态UI
    [self updateSingleUIWithCallState];
    
    //根据推流功能状态，设置按钮状态
    [self updateBtnStateWithLoacalUserModel];
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
    
    NoaCallOptions *currentCallOptions = [NoaCallManager sharedManager].currentCallOptions;
    
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
    if (currentCallOptions.zgCallOptions.callType == LingIMCallTypeAudio) {
        //音频通话
        [_viewActionBg addSubview:self.btnMutedAudio];//静音
        [_viewActionBg addSubview:self.btnExternal];//免提
        [_viewActionBg addSubview:self.btnEnd];//挂断(包含文字)
        
        [self.btnEnd setTitle:LanguageToolMatch(@"挂断") forState:UIControlStateNormal];
//        [self.btnEnd setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:DWScale(10)];
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
//        [self.btnRefuse setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:DWScale(10)];
        [self.btnRefuse mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.view).offset(DWScale(70));
            make.bottom.equalTo(self.view).offset(-DHomeBarH - DWScale(30));
            make.size.mas_equalTo(CGSizeMake(DWScale(60), DWScale(85)));
        }];
        
        [self.btnAccept setTitle:LanguageToolMatch(@"接听") forState:UIControlStateNormal];
//        [self.btnAccept setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:DWScale(10)];
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
            make.bottom.equalTo(self.view).offset(-DHomeBarH - DWScale(140));
            make.size.mas_equalTo(CGSizeMake(DWScale(70), DWScale(105)));
        }];
        
        [self.btnMutedVideo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-DHomeBarH - DWScale(140));
            make.leading.equalTo(self.view).offset(DWScale(40));
            make.size.mas_equalTo(CGSizeMake(DWScale(70), DWScale(105)));
        }];
        
        [self.btnCameraSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-DHomeBarH - DWScale(140));
            make.trailing.equalTo(self.view).offset(-DWScale(40));
            make.size.mas_equalTo(CGSizeMake(DWScale(70), DWScale(105)));
        }];
        
        [_viewActionBg addSubview:self.btnEnd];//挂断(包含文字)
        [self.btnEnd mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.btnMutedAudio);
            make.bottom.equalTo(self.view).offset(-DHomeBarH - DWScale(20));
            make.size.mas_equalTo(CGSizeMake(DWScale(70), DWScale(90)));
        }];
        
        [_viewActionBg addSubview:self.btnRefuse];//拒绝(不含文字)
        [_viewActionBg addSubview:self.btnAccept];//接受(不含文字)
        
        [self.btnRefuse mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.view).offset(DWScale(67));
            make.bottom.equalTo(self.view).offset(-DHomeBarH - DWScale(20));
            make.size.mas_equalTo(CGSizeMake(DWScale(60), DWScale(60)));
        }];
        
        [self.btnAccept mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.view).offset(-DWScale(67));
            make.bottom.equalTo(self.view).offset(-DHomeBarH - DWScale(20));
            make.size.mas_equalTo(CGSizeMake(DWScale(60), DWScale(60)));
        }];
    }
    [self layoutBtn];

}


#pragma mark - 更新UI
//根据通话状态创建UI
- (void)updateSingleUIWithCallState {
    NoaCallOptions *currentCallOptions = [NoaCallManager sharedManager].currentCallOptions;
    
    if ([NoaCallManager sharedManager].callState == ZCallStateCalling) {
        //当前通话已连接成功
        
        _lblCallTip.hidden = YES;
        _viewShimmer.hidden = YES;
        
        if (currentCallOptions.zgCallOptions.callType == LingIMCallTypeAudio) {
            //音频通话
            if (![currentCallOptions.zgCallOptions.callRoomCreateUserID isEqualToString:UserManager.userInfo.userUID]) {
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
            
            if (![currentCallOptions.zgCallOptions.callRoomCreateUserID isEqualToString:UserManager.userInfo.userUID]) {
                //被邀请者
                [self btnHiddenAnimationWith:self.btnRefuse];//隐藏拒绝按钮
                [self btnHiddenAnimationWith:self.btnAccept];//隐藏接受按钮
            }
            
            //开启扬声器
            [[NoaCallManager sharedManager] callRoomSpeakerMute:NO];
            
            //渲染视频
            [self performSelector:@selector(setupVideoTrack) withObject:nil afterDelay:0.2];
        }
        
        
    }else {
        //当前通话未连接成功
        _lblCallTip.hidden = NO;
        _viewShimmer.hidden = NO;
        
        if (currentCallOptions.zgCallOptions.callType == LingIMCallTypeAudio) {
            //音频通话
            if (![currentCallOptions.zgCallOptions.callRoomCreateUserID isEqualToString:UserManager.userInfo.userUID]) {
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
            
            if (![currentCallOptions.zgCallOptions.callRoomCreateUserID isEqualToString:UserManager.userInfo.userUID]) {
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

//更新远端用户信息
- (void)updateRemoteWithUserModel {
    [_ivHeader sd_setImageWithURL:[_remoteUserModel.userAvatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
    [_ivHeaderBg sd_setImageWithURL:[_remoteUserModel.userAvatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
    _lblNickname.text = _remoteUserModel.userShowName;
}
//根据推流功能状态，设置按钮状态
- (void)updateBtnStateWithLoacalUserModel {
    if ([NoaCallManager sharedManager].callState == ZCallStateCalling) {
        //当前正在通话中
        //麦克风
        LingIMCallMicrophoneMuteState micState = _localUserModel.micState;
        self.btnMutedAudio.selected = micState == LingIMCallMicrophoneMuteStateOn ? YES : NO;
        
        if ([NoaCallManager sharedManager].currentCallOptions.zgCallOptions.callType == LingIMCallTypeAudio) {
            //扬声器
            LingIMCallSpeakerMuteState speakerState = _localUserModel.speakerState;
            self.btnExternal.selected = speakerState == LingIMCallSpeakerMuteStateOn ? NO : YES;
            [[NoaCallManager sharedManager] callRoomSpeakerMute:speakerState == LingIMCallSpeakerMuteStateOn ? YES : NO];
        }else {
            //摄像头
            LingIMCallCameraMuteState cameraState = _localUserModel.cameraState;
            self.btnMutedVideo.selected = cameraState == LingIMCallCameraMuteStateOn ? YES : NO;
        }
    }
}
#pragma mark - 渲染视频轨道
- (void)setupVideoTrack {
    
    if ([NoaCallManager sharedManager].callState != ZCallStateCalling) return;
    
    if ([NoaCallManager sharedManager].showMeTrack) {
        //我的 音视频流 在固定主界面上
        
        //本地流预览加载
        [[NoaCallManager sharedManager] callRoomStartPreviewWith:_viewPositionVideo.sampleViewVideo.viewVideoZG];
        [_viewPositionVideo.ivHeader sd_setImageWithURL:[_localUserModel.userAvatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
        [_viewPositionVideo showHeaderWith:_localUserModel.cameraState == LingIMCallCameraMuteStateOn ? YES : NO];
        
        //远端流预览加载
        [[NoaCallManager sharedManager] callRoomStartPlayingStream:_remoteUserModel.streamID with:_viewFloatVideo.sampleViewVideo.viewVideoZG];
        [_viewFloatVideo.ivHeader sd_setImageWithURL:[_remoteUserModel.userAvatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
        [_viewFloatVideo showHeaderWith:_remoteUserModel.cameraState == LingIMCallCameraMuteStateOn ? YES : NO];
        
    }else {
        //我的 音视频流 在浮窗界面上
        
        //本地流预览加载
        [[NoaCallManager sharedManager] callRoomStartPreviewWith:_viewFloatVideo.sampleViewVideo.viewVideoZG];
        [_viewFloatVideo.ivHeader sd_setImageWithURL:[_localUserModel.userAvatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
        [_viewFloatVideo showHeaderWith:_localUserModel.cameraState == LingIMCallCameraMuteStateOn ? YES : NO];
        
        //远端流预览加载
        [[NoaCallManager sharedManager] callRoomStartPlayingStream:_remoteUserModel.streamID with:_viewPositionVideo.sampleViewVideo.viewVideoZG];
        [_viewPositionVideo.ivHeader sd_setImageWithURL:[_remoteUserModel.userAvatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
        [_viewPositionVideo showHeaderWith:_remoteUserModel.cameraState == LingIMCallCameraMuteStateOn ? YES : NO];
    }

    
}


#pragma mark - 交互事件
//最小化
- (void)btnMiniClick {
    
    NoaWindowFloatView *viewMediaCall = [NoaWindowFloatView new];
    viewMediaCall.isKeepBounds = YES;
    //当前通话信息
    NoaCallOptions *currentCallOptions = [NoaCallManager sharedManager].currentCallOptions;
    
    if (currentCallOptions.zgCallOptions.callType == LingIMCallTypeAudio) {
        //音频通话
        viewMediaCall.frame = CGRectMake(0, DNavStatusBarH, DWScale(86), DWScale(101));
    } else {
        //视频通话
        if ([NoaCallManager sharedManager].callState == ZCallStateCalling) {
            //当前正在通话中
            viewMediaCall.frame = CGRectMake(0, DNavStatusBarH, DWScale(86), DWScale(126));
        } else {
            viewMediaCall.frame = CGRectMake(0, DNavStatusBarH, DWScale(86), DWScale(101));
        }
    }
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    viewMediaCall.delegate = appDelegate;
    appDelegate.viewFloatWindow = viewMediaCall;
    
    //浮窗 谁在固定主屏幕上，显示的就是谁
    NoaCallUserModel *showUserModel;
    if ([NoaCallManager sharedManager].showMeTrack) {
        //我展示在固定主屏上
        showUserModel = _localUserModel;
    }else {
        //远端展示在固定主屏上
        showUserModel = _remoteUserModel;
    }
    
    NoaCallFloatView *viewFloat = [[NoaCallFloatView alloc] init];
    viewFloat.userModel = showUserModel;
    [viewMediaCall addSubview:viewFloat];
    [viewFloat mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(viewMediaCall);
    }];
    
    [CurrentWindow addSubview:viewMediaCall];

    [self dismissViewControllerAnimated:YES completion:nil];
}

//通话结束
- (void)btnEndClick {
    
    NoaCallOptions *currentCallOptions = [NoaCallManager sharedManager].currentCallOptions;
    if (currentCallOptions) {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        if ([currentCallOptions.zgCallOptions.callRoomCreateUserID isEqualToString:UserManager.userInfo.userUID]) {
            //我是邀请者
            if ([NoaCallManager sharedManager].callState == ZCallStateCalling) {
                //通话已接听--结束通话
                [dict setValue:@"hangup" forKey:@"discardType"];//挂断类型 结束
            }else {
                //通话未接听--取消通话
                [dict setValue:@"cancel" forKey:@"discardType"];//挂断类型 取消
            }
        }else {
            //我是被邀请者
            if ([NoaCallManager sharedManager].callState == ZCallStateCalling) {
                //通话已接听--结束通话
                [dict setValue:@"hangup" forKey:@"discardType"];//挂断类型 结束
            }else {
                //通话未接听--拒绝通话
                [dict setValue:@"refuse" forKey:@"discardType"];//挂断类型 拒绝
            }
        }
        
        [dict setValue:currentCallOptions.zgCallOptions.callID forKey:@"callId"];
        WeakSelf
        [[NoaCallManager sharedManager] callDiscardWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            //成功
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            //失败错误提示
            [HUD showMessageWithCode:code errorMsg:msg];
        }];
        
        //调用接口后，已经清空了本次通话的信息，如果接口报错了，再次点击挂断，可以退出界面
        //这个体验，暂时先不改，和安卓的保持一致
        
    }else {
        
        //退出房间
        [[NoaCallManager sharedManager] callRoomLogout];
        //清空本次通话的配置
        [[NoaCallManager sharedManager] clearManagerConfig];
        
        //界面消失
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    
    
}

//接听通话
- (void)btnAcceptClick {
    NoaCallOptions *currentCallOptions = [NoaCallManager sharedManager].currentCallOptions;
    if (!currentCallOptions) return;
    
    WeakSelf
    if (currentCallOptions.zgCallOptions.callType == LingIMCallTypeAudio) {
        //音频
        [ZTOOL getMicrophoneAuth:^(BOOL granted) {
            DLog(@"麦克风权限:%d",granted);
            //单人音视频
            [weakSelf callAccept];
        }];
    }else {
        //视频
        [ZTOOL getMicrophoneAuth:^(BOOL granted) {
            DLog(@"麦克风权限:%d",granted);
            [ZTOOL getCameraAuth:^(BOOL granted) {
                DLog(@"相机权限:%d",granted);
                //单人音视频
                [weakSelf callAccept];
            }];
        }];
    }
}

//扬声器
- (void)btnExternalClick {
    if ([NoaCallManager sharedManager].callState != ZCallStateCalling) return;
    
    self.btnExternal.selected = !self.btnExternal.selected;
    
    [[NoaCallManager sharedManager] callRoomSpeakerMute:!self.btnExternal.selected];
    
    if (self.btnExternal.selected) {
        [HUD showMessage:LanguageToolMatch(@"免提开启")];
    }else {
        [HUD showMessage:LanguageToolMatch(@"免提关闭")];
    }
    
    _localUserModel.speakerState = [NoaCallManager sharedManager].callRoomSpeakerState;
}

//音频静默
- (void)btnMutedAudioClick {
    if ([NoaCallManager sharedManager].callState != ZCallStateCalling) return;
    self.btnMutedAudio.selected = !self.btnMutedAudio.selected;
    [[NoaCallManager sharedManager] callRoomMicrophoneMute:self.btnMutedAudio.selected];
    if (self.btnMutedAudio.selected) {
        [HUD showMessage:LanguageToolMatch(@"静音开启")];
    }else {
        [HUD showMessage:LanguageToolMatch(@"静音关闭")];
    }
    
    _localUserModel.micState = [NoaCallManager sharedManager].callRoomMirophoneState;
}

//视频静默
- (void)btnMutedVideoClick {
    if ([NoaCallManager sharedManager].callState != ZCallStateCalling) return;
    self.btnMutedVideo.selected = !self.btnMutedVideo.selected;
    [[NoaCallManager sharedManager] callRoomCameraMute:self.btnMutedVideo.selected];
    if (self.btnMutedVideo.selected) {
        [HUD showMessage:LanguageToolMatch(@"摄像头关闭")];
    }else {
        [HUD showMessage:LanguageToolMatch(@"摄像头开启")];
    }
    
    _localUserModel.cameraState = [NoaCallManager sharedManager].callRoomCameraState;
    
    //更新视频渲染界面
    [self setupVideoTrack];
}


//切换摄像头
- (void)btnCameraSwitchClick {
    if ([NoaCallManager sharedManager].callState != ZCallStateCalling) return;
    
    self.btnCameraSwitch.selected = !self.btnCameraSwitch.selected;
    [[NoaCallManager sharedManager] callRoomCameraUseFront:self.btnCameraSwitch.selected];
    
    _localUserModel.cameraDirection = [NoaCallManager sharedManager].callRoomCameraDirection;
}

#pragma mark - ZCallManagerDelegate
- (void)currentCallDurationTime:(NSInteger)duration {
    if (duration > 0) {
        _lblTime.text = [NSString getTimeLengthHMS:duration];
    }else {
        _lblTime.text = @"";
    }
}

#pragma mark - ZWindowFloatViewDelegate
- (void)clickFloatView:(NoaWindowFloatView *)floatView {
    [NoaCallManager sharedManager].showMeTrack = ![NoaCallManager sharedManager].showMeTrack;
    [self setupVideoTrack];
}

#pragma mark - 接听单人音视频通话
- (void)callAccept {
    NoaCallOptions *currentCallOptions = [NoaCallManager sharedManager].currentCallOptions;
    if (currentCallOptions) {
        WeakSelf
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:currentCallOptions.zgCallOptions.callID forKey:@"callId"];
        [[NoaCallManager sharedManager] callAcceptWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            //被邀请者，同意音视频通话请求后，先进入房间
            [weakSelf callRoomJoin];
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            [HUD showMessageWithCode:code errorMsg:msg];
        }];
    }else {
        [HUD showMessage:LanguageToolMatch(@"操作失败")];
    }
    
}

#pragma mark - ******通知监听方法处理******
#pragma mark - 音视频房间加入
- (void)callRoomJoin {
    
    WeakSelf
    
    if ([NoaCallManager sharedManager].callState == ZCallStateCalling) return;
    
    NoaCallOptions *currentCallOptions = [NoaCallManager sharedManager].currentCallOptions;
    
    //第一步 初始化单例
    [[NoaCallManager sharedManager] callRoomCreateEngineWithOptions:currentCallOptions.zgCallOptions];
    //第二步 登录房间
    [[NoaCallManager sharedManager] callRoomLogin:^(int errorCode, NSDictionary * _Nullable extendedData) {
        if (errorCode == 0) {
            //第三步 开始推流
            [NoaCallManager sharedManager].callState = ZCallStateCalling;
            [[NoaCallManager sharedManager] callRoomStartPublish];
            //界面更新
            [weakSelf updateSingleUIWithCallState];
            [weakSelf updateBtnStateWithLoacalUserModel];
            //通话计时器
            [[NoaCallManager sharedManager] createCurrentCallDurationTimer];
            [[NoaCallManager sharedManager] createCallHeartBeatTimer];
        }else {
            [HUD showMessage:LanguageToolMatch(@"传入参数不合法")];
        }
    }];
    //第三步 开始推流
    
}
#pragma mark - 远端摄像头静默状态
- (void)callRoomCameraMute:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    //远端摄像头静默状态改变的用户
    //NSString *userUid = [NSString stringWithFormat:@"%@", [userInfo objectForKeySafe:@"userUid"]];
    //远端摄像头静默状态
    BOOL cameraMute = [[userInfo objectForKeySafe:@"cameraMute"] boolValue];
    
    _remoteUserModel.cameraState = cameraMute ? LingIMCallCameraMuteStateOn : LingIMCallCameraMuteStateOff;
    
    //更新视频渲染界面
    [self setupVideoTrack];
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
        [_viewFloatVideo showHeaderWith:NO];
        [_viewFloat addSubview:_viewFloatVideo];
    }
    return _viewFloat;
}

- (NoaMediaCallVideoView *)viewPositionVideo {
    if (!_viewPositionVideo) {
        _viewPositionVideo = [[NoaMediaCallVideoView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DScreenHeight)];
        [_viewPositionVideo showHeaderWith:NO];
        _viewPositionVideo.hidden = YES;
    }
    return _viewPositionVideo;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
