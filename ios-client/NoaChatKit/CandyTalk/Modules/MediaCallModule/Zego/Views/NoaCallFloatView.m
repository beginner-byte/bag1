//
//  NoaCallFloatView.m
//  NoaKit
//
//  Created by Candy on 2023/5/24.
//

#import "NoaCallFloatView.h"
#import "NoaCallManager.h"
#import "NoaToolManager.h"
#import "NoaMediaCallVideoView.h"

@interface NoaCallFloatView () <ZCallManagerDelegate>
@property (nonatomic, strong) UIView *viewContent;

@property (nonatomic, strong) UIImageView *ivCallState;
@property (nonatomic, strong) UILabel *lblCallTip;

@property (nonatomic, strong) NoaMediaCallVideoView *viewVideo;

@end

@implementation NoaCallFloatView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.alpha = 0;
        
        [NoaCallManager sharedManager].delegate = self;
        
        //界面布局
        [self setupUI];
        //根据房间通话状态，更新UI
        [self updateUIWithRoomState];
        
        //监听关闭UI
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callRoomEnd) name:ZGCALLROOMEND object:nil];
        //监听是否可以加入房间
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callRoomJoin) name:ZGCALLROOMJOIN object:nil];
        //监听摄像头静默状态
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callRoomCameraMute:) name:ZGCALLROOMCAMERAMUTE object:nil];
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
    
    _viewVideo = [NoaMediaCallVideoView new];
    [_viewVideo updateHeaderSizeWith:DWScale(38)];
    [_viewContent addSubview:_viewVideo];
    [_viewVideo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_viewContent);
    }];
    [_viewVideo layoutIfNeeded];
    _viewVideo.hidden = YES;
    
}
- (void)updateUIWithRoomState {
    
    //当前音视频通话信息
    NoaCallOptions *currentCallOptions = [NoaCallManager sharedManager].currentCallOptions;
    
    if (currentCallOptions.zgCallOptions.callType == LingIMCallTypeAudio) {
        //音频通话
        switch ([NoaCallManager sharedManager].callState) {
            case ZCallStateBegin://刚开始通话进程
            {
                _ivCallState.image = ImgNamed(@"ms_btn_accept_s");
                _lblCallTip.text = LanguageToolMatch(@"等待接通");
            }
                break;
            case ZCallStateCalling://当前正在通话中
            {
                _ivCallState.image = ImgNamed(@"ms_btn_accept_s");
                _lblCallTip.text = [NSString getTimeLengthHMS:currentCallOptions.zgCallOptions.callDuration];
            }
                break;
            case ZCallStateEnd://通话进程结束
            {
                _ivCallState.image = ImgNamed(@"ms_btn_cancel_s");
                _lblCallTip.textColor = COLOR_FF3333;
                _lblCallTip.text = LanguageToolMatch(@"通话结束");
            }
                break;
            default:
                break;
        }
    }else {
        //视频通话
        
        switch ([NoaCallManager sharedManager].callState) {
            case ZCallStateBegin://刚开始通话进程
            {
                _ivCallState.image = ImgNamed(@"ms_btn_video_accept_s");
                _lblCallTip.text = LanguageToolMatch(@"等待接通");
            }
                break;
            case ZCallStateCalling://当前正在通话中
            {
                _viewVideo.hidden = NO;
                _lblCallTip.hidden = YES;
                _ivCallState.hidden = YES;
                if (self.superview) {
                    self.superview.size = CGSizeMake(DWScale(86), DWScale(126));
                }
            }
                break;
            case ZCallStateEnd://通话进程结束
            {
                _ivCallState.image = ImgNamed(@"ms_btn_video_cancel_s");
                _lblCallTip.textColor = COLOR_FF3333;
                _lblCallTip.text = LanguageToolMatch(@"通话结束");
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - 视频通话更新头像
- (void)setUserModel:(NoaCallUserModel *)userModel {
    if (userModel) {
        _userModel = userModel;
        
        [self performSelector:@selector(updateViewVideoTrack) withObject:nil afterDelay:0.1];
    }
}

- (void)updateViewVideoTrack {
    self.alpha = 1;
    
    if ([NoaCallManager sharedManager].currentCallOptions.zgCallOptions.callType == LingIMCallTypeVideo) {
        //视频通话
        [_viewVideo.ivHeader sd_setImageWithURL:[_userModel.userAvatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
        
        [_viewVideo showHeaderWith:_userModel.cameraState == LingIMCallCameraMuteStateOn ? YES : NO];
        
        if ([NoaCallManager sharedManager].callState == ZCallStateCalling) {
            if ([_userModel.userUid isEqualToString:UserManager.userInfo.userUID]) {
                //主界面是我
                [[NoaCallManager sharedManager] callRoomStartPreviewWith:_viewVideo.sampleViewVideo.viewVideoZG];
            }else {
                //主界面是远端(对方)
                [[NoaCallManager sharedManager] callRoomStartPlayingStream:_userModel.streamID with:_viewVideo.sampleViewVideo.viewVideoZG];
            }
        }
        
    }
}


#pragma mark - 通知监听处理
//通话取消
- (void)callRoomEnd {
    //当前音视频通话信息
    NoaCallOptions *currentCallOptions = [NoaCallManager sharedManager].currentCallOptions;
    
    //通话取消结束
    _lblCallTip.textColor = COLOR_FF3333;
    _lblCallTip.text = LanguageToolMatch(@"通话结束");
    
    switch (currentCallOptions.zgCallOptions.callType) {
        case LingIMCallTypeAudio:
        {
            _ivCallState.image = ImgNamed(@"ms_btn_cancel_s");
        }
            break;
        case LingIMCallTypeVideo:
        {
            _viewVideo.hidden = YES;
            _lblCallTip.hidden = NO;
            _ivCallState.hidden = NO;
            _ivCallState.image = ImgNamed(@"ms_btn_video_cancel_s");
        }
            break;
            
        default:
            break;
    }
    
}
//通话开始接入
- (void)callRoomJoin {
    //我当前是邀请者，在浮窗界面才会接收到次通知
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
            //更新界面
            [weakSelf updateUIWithRoomState];
            [weakSelf updateViewVideoTrack];
            //通话计时器
            [[NoaCallManager sharedManager] createCurrentCallDurationTimer];
            [[NoaCallManager sharedManager] createCallHeartBeatTimer];
        }else {
            [HUD showMessage:LanguageToolMatch(@"传入参数不合法")];
        }
    }];

}
#pragma mark - 远端摄像头静默状态
- (void)callRoomCameraMute:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    //远端摄像头静默状态改变的用户
    NSString *userUid = [NSString stringWithFormat:@"%@", [userInfo objectForKeySafe:@"userUid"]];
    //远端摄像头静默状态
    BOOL cameraMute = [[userInfo objectForKeySafe:@"cameraMute"] boolValue];
    
    if ([userUid isEqualToString:_userModel.userUid]) {
        _userModel.cameraState = cameraMute ? LingIMCallCameraMuteStateOn : LingIMCallCameraMuteStateOff;
    }
    
    //更新界面的头像
    [_viewVideo showHeaderWith:_userModel.cameraState == LingIMCallCameraMuteStateOn ? YES : NO];
}

#pragma mark - ZCallManagerDelegate
- (void)currentCallDurationTime:(NSInteger)duration {
    if (duration > 0) {
        _lblCallTip.text = [NSString getTimeLengthHMS:duration];
    }else {
        _lblCallTip.text = @"";
    }
}

#pragma mark - 界面销毁
- (void)dealloc {
    DLog(@"即构-音视频通话-单人-浮窗销毁");
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
