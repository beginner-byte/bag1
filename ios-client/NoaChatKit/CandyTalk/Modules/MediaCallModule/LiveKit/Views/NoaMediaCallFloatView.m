//
//  NoaMediaCallFloatView.m
//  NoaKit
//
//  Created by Candy on 2023/1/14.
//

#import "NoaMediaCallFloatView.h"
#import "NoaMediaCallManager.h"
#import "NoaToolManager.h"
#import "NoaMediaCallVideoView.h"


@interface NoaMediaCallFloatView () <ZMediaCallManagerDelegate,RoomDelegateObjC>
@property (nonatomic, strong) UIView *viewContent;

@property (nonatomic, strong) UIImageView *ivCallState;
@property (nonatomic, strong) UILabel *lblCallTip;

@property (nonatomic, strong) NoaMediaCallVideoView *viewVideo;
@end

@implementation NoaMediaCallFloatView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        
        [self setupUI];
        
        //LiveKit SDK
        [NoaMediaCallManager sharedManager].delegate = self;
        [[NoaMediaCallManager sharedManager] mediaCallRoomDelegate:self];
        //监听关闭UI
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaCallRoomCancel) name:CALLROOMCANCEL object:nil];
        //监听是否可以加入房间
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaCallRoomJoin) name:CALLROOMJOIN object:nil];
        
        WeakSelf
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakSelf setupVideoTrack];
        });
        
    }
    return self;
}

#pragma mark - 界面布局
- (void)setupUI {
    
    self.layer.cornerRadius = DWScale(16);
    self.layer.masksToBounds = YES;
    
    UIView *viewLayerBg = [UIView new];
    viewLayerBg.backgroundColor = [UIColor clearColor];
    viewLayerBg.layer.shadowColor = [UIColor blackColor].CGColor;
    viewLayerBg.layer.shadowOffset = CGSizeMake(0, 0); // 阴影偏移量，默认（0,0）
    viewLayerBg.layer.shadowOpacity = 0.1; // 不透明度
    viewLayerBg.layer.shadowRadius = 5;
    [self addSubview:viewLayerBg];
    [viewLayerBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(self).offset(DWScale(3));
        make.trailing.bottom.equalTo(self).offset(-DWScale(3));
    }];
    
    _viewContent = [UIView new];
    _viewContent.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    _viewContent.layer.cornerRadius = DWScale(16);
    _viewContent.layer.masksToBounds = YES;
    [viewLayerBg addSubview:_viewContent];
    [_viewContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(viewLayerBg);
    }];
    
    
    _ivCallState = [UIImageView new];
    [_viewContent addSubview:_ivCallState];
    [_ivCallState mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_viewContent);
        make.top.equalTo(_viewContent).offset(DWScale(27));
    }];
    
    _lblCallTip = [UILabel new];
    _lblCallTip.font = FONTR(12);
    _lblCallTip.textColor = COLOR_5966F2;
    _lblCallTip.preferredMaxLayoutWidth = DWScale(90);
    [_viewContent addSubview:_lblCallTip];
    [_lblCallTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_viewContent);
        make.top.equalTo(_ivCallState.mas_bottom).offset(DWScale(11));
    }];
    
    [_viewContent addSubview:self.viewVideo];
    [self.viewVideo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_viewContent);
    }];
    
    [self updateUIWithRoomState];
}
- (void)updateUIWithRoomState {
    NoaMediaCallOptions *currentCallOptions = [NoaMediaCallManager sharedManager].currentCallOptions;
    
    switch (currentCallOptions.callType) {
        case LingIMCallTypeAudio:
        {
            //音频
            
            _ivCallState.image = ImgNamed(@"ms_btn_accept_s");
            _lblCallTip.textColor = COLOR_5966F2;
            _lblCallTip.text = LanguageToolMatch(@"等待接通");
            
            //request请求、waiting等待、accept接受、confirm确认、discard断开连接
            if ([currentCallOptions.callState isEqualToString:@"discard"]) {
                _ivCallState.image = ImgNamed(@"ms_btn_cancel_s");
                _lblCallTip.textColor = COLOR_FF3333;
                _lblCallTip.text = LanguageToolMatch(@"通话结束");
            } else if ([currentCallOptions.callState isEqualToString:@"request"]) {
            } else if ([currentCallOptions.callState isEqualToString:@"waiting"]) {
            } else if ([currentCallOptions.callState isEqualToString:@"accept"]) {
            } else {//confirm
                _lblCallTip.text = [NSString getTimeLengthHMS:currentCallOptions.callDuration];
            }
        }
            break;
        case LingIMCallTypeVideo:
        {
            //视频
            _ivCallState.image = ImgNamed(@"ms_btn_video_accept_s");
            _lblCallTip.textColor = COLOR_5966F2;
            _lblCallTip.text = LanguageToolMatch(@"等待接通");
            
            //request请求、waiting等待、accept接受、confirm确认、discard断开连接
            if ([currentCallOptions.callState isEqualToString:@"discard"]) {
                _ivCallState.image = ImgNamed(@"ms_btn_video_cancel_s");
                _lblCallTip.textColor = COLOR_FF3333;
                _lblCallTip.text = LanguageToolMatch(@"通话结束");
            } else if ([currentCallOptions.callState isEqualToString:@"request"]) {
            } else if ([currentCallOptions.callState isEqualToString:@"waiting"]) {
            } else if ([currentCallOptions.callState isEqualToString:@"accept"]) {
            } else {
                //视频通话进行中
                self.viewVideo.hidden = NO;
                _lblCallTip.hidden = YES;
                _ivCallState.hidden = YES;
                if (self.superview) {
                    self.superview.size = CGSizeMake(DWScale(86), DWScale(126));
                }
            }
            
        }
            break;
            
        default:
            break;
    }

}
#pragma mark - 渲染视频轨道
- (void)setupVideoTrack {
    if (![NoaMediaCallManager sharedManager].currentRoomCalling) return;
    
    NoaMediaCallOptions *currentCallOptions = [NoaMediaCallManager sharedManager].currentCallOptions;
    if (currentCallOptions.callType == LingIMCallTypeAudio) return;
    
    if ([NoaMediaCallManager sharedManager].currentScreenTrackMe) {
        //本地参与者
        LocalTrackPublication *publication = [NoaMediaCallManager sharedManager].mediaCallRoom.localParticipant.localVideoTracks.firstObject;
        self.viewVideo.viewVideo.track = (LocalVideoTrack *)publication.track;
        [self.viewVideo showHeaderWith:publication.track.muted];
        
    }else {
        //远端参与者
        NSArray *remoteParticipantList = [[NoaMediaCallManager sharedManager] mediaCallRoomRemotePaticipants];
        Participant *remoteParticipant = remoteParticipantList.firstObject;
        RemoteVideoTrack *remoteVideoTrack = (RemoteVideoTrack *)remoteParticipant.videoTracks.firstObject.track;
        if (remoteVideoTrack) {
            self.viewVideo.viewVideo.track = remoteVideoTrack;
            [self.viewVideo showHeaderWith:remoteVideoTrack.muted];
        }
        
        
    }
}

#pragma mark - 视频通话更新头像
- (void)setUserModel:(NoaUserModel *)userModel {
    if (userModel) {
        _userModel = userModel;
        
        NoaMediaCallOptions *currentCallOptions = [NoaMediaCallManager sharedManager].currentCallOptions;
        if (currentCallOptions.callType == LingIMCallTypeVideo) {
            
            if ([NoaMediaCallManager sharedManager].currentScreenTrackMe) {
                //我的头像
                [self.viewVideo.ivHeader sd_setImageWithURL:[UserManager.userInfo.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
            }else {
                //对方头像
                [self.viewVideo.ivHeader sd_setImageWithURL:[_userModel.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
            }
        }
    }
}
#pragma mark - 通知监听处理
//加入房间
- (void)mediaCallRoomJoin {
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
- (void)mediaCallRoomCancel {
    NoaMediaCallOptions *currentCallOptions = [NoaMediaCallManager sharedManager].currentCallOptions;
    
    //通话取消结束
    _lblCallTip.textColor = COLOR_FF3333;
    _lblCallTip.text = LanguageToolMatch(@"通话结束");
    
    switch (currentCallOptions.callType) {
        case LingIMCallTypeAudio:
        {
            _ivCallState.image = ImgNamed(@"ms_btn_cancel_s");
        }
            break;
        case LingIMCallTypeVideo:
        {
            self.viewVideo.hidden = YES;
            _lblCallTip.hidden = NO;
            _ivCallState.hidden = NO;
            _ivCallState.image = ImgNamed(@"ms_btn_video_cancel_s");
        }
            break;
            
        default:
            break;
    }
}
#pragma mark - ZMediaCallManagerDelegate
- (void)mediaCallCurrentDuration:(NSInteger)duration {
    if (duration > 0) {
        _lblCallTip.text = [NSString getTimeLengthHMS:duration];
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
                [NoaMediaCallManager sharedManager].mediaCallState = ZMediaCallStateCall;
                WeakSelf
                //更新UI 主线程
                [ZTOOL doInMain:^{
                    [[NoaMediaCallManager sharedManager] createCurrentCallDurationTimer];
                    [weakSelf updateUIWithRoomState];
                }];
            }
            
        }
            
        default:
            break;
    }
}

//房间的参与者轨道静默状态发生改变 ParticipantDelegate有相同功能 participant:publication:didUpdateMuted:
- (void)room:(Room *)room participant:(Participant *)participant publication:(TrackPublication *)publication didUpdateMuted:(BOOL)muted {
    DLog(@"房间代理---10");
    if ([participant isKindOfClass:[LocalParticipant class]]) {
        //本地参与者轨道发生变化
        LocalTrackPublication *localT = (LocalTrackPublication *)publication;
        if ([localT.track isKindOfClass:[LocalVideoTrack class]]) {
            //本地参与者视频轨道发生变化
            //判断当前浮窗显示的是否是本地参与者的视频轨道
            if ([NoaMediaCallManager sharedManager].currentScreenTrackMe) {
                [self.viewVideo showHeaderWith:muted];
                if (!muted) {
                    self.viewVideo.viewVideo.track = (LocalVideoTrack *)localT.track;
                }
            }
            
            
        }else {
            DLog(@"本地参与者音频轨道发生变化");
        }
        
        
        
    }else {
        //远端参与者轨道发生变化
        RemoteTrackPublication *remoteT = (RemoteTrackPublication *)publication;
        if ([remoteT.track isKindOfClass:[RemoteVideoTrack class]]) {
            //远端参与者视频轨道发生变化
            //判断当前浮窗显示的是否是本地参与者的视频轨道
            if (![NoaMediaCallManager sharedManager].currentScreenTrackMe) {
                [self.viewVideo showHeaderWith:muted];
                if (!muted) {
                    self.viewVideo.viewVideo.track = (RemoteVideoTrack *)remoteT.track;
                }
            }
            
            
        }else {
            DLog(@"远端参与者音频轨道发生变化");
        }
        
    }
    
}
//房间的本地参与者 订阅了一个新的远端音视频轨道；只要有新的轨道可以使用，这个事件就会触发
- (void)room:(Room *)room participant:(RemoteParticipant *)participant didSubscribePublication:(RemoteTrackPublication *)publication track:(Track *)track {
    DLog(@"房间代理---15");
    [self setupVideoTrack];
}
//房间的 本地 参与者 发布了 音视频轨道
- (void)room:(Room *)room localParticipant:(LocalParticipant *)localParticipant didPublishPublication:(LocalTrackPublication *)publication {
    DLog(@"房间代理---19");
    [self setupVideoTrack];
}
#pragma mark - 懒加载
- (NoaMediaCallVideoView *)viewVideo {
    if (!_viewVideo) {
        _viewVideo = [NoaMediaCallVideoView new];
        [_viewVideo updateHeaderSizeWith:DWScale(38)];
        _viewVideo.hidden = YES;
    }
    return _viewVideo;
}

#pragma mark - 界面销毁
- (void)dealloc {
    DLog(@"音视频通话-单人-浮窗销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
