//
//  NoaMediaCallVC.m
//  NoaKit
//
//  Created by Candy on 2023/1/6.
//

#import "NoaMediaCallVC.h"
#import "UIButton+Gradient.h"

@interface NoaMediaCallVC () 

@end

@implementation NoaMediaCallVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navView.hidden = YES;
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    
    //服从音视频通话相关代理
    [NoaMediaCallManager sharedManager].delegate = self;
    [[NoaMediaCallManager sharedManager] mediaCallRoomDelegate:self];
    
    //监听关闭UI
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaCallVCDismiss) name:CALLROOMCANCEL object:nil];
    //监听是否可以加入房间
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaCallRoomJoin) name:CALLROOMJOIN object:nil];
    
    //设置为不息屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
}

#pragma mark - 加入房间
- (void)mediaCallRoomJoin {
    
}

#pragma mark - 按钮动画
- (void)btnShowAnimationWith:(UIButton *)sender {
    [UIView animateWithDuration:0.3 animations:^{
        sender.alpha = 1;
    }];
}
- (void)btnHiddenAnimationWith:(UIButton *)sender {
    [UIView animateWithDuration:0.3 animations:^{
        sender.alpha = 0;
    }];
}

#pragma mark - 交互事件
//最小化
- (void)btnMiniClick {
    
}
//接听电话
- (void)btnAcceptClick {
    
}
//挂断电话
- (void)btnEndClick {
    
}
//音频静默
- (void)btnMutedAudioClick {
    
}
//视频静默
- (void)btnMutedVideoClick {
    
}
//免提
- (void)btnExternalClick {
    
}
//摄像头切换
- (void)btnCameraSwitchClick {
    
}

//关闭界面
- (void)mediaCallVCDismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 懒加载
//最小化
- (UIButton *)btnMini {
    if (!_btnMini) {
        _btnMini = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnMini setImage:ImgNamed(@"ms_btn_mini") forState:UIControlStateNormal];
        [_btnMini addTarget:self action:@selector(btnMiniClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnMini;
}

//被邀请者接受通话
- (UIButton *)btnAccept {
    if (!_btnAccept) {
        _btnAccept = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnAccept.alpha = 0;
        [_btnAccept setTitleColor:COLORWHITE forState:UIControlStateNormal];
        _btnAccept.titleLabel.font = FONTR(14);
        [_btnAccept setImage:ImgNamed(@"ms_btn_accept") forState:UIControlStateNormal];
        [_btnAccept setTitle:LanguageToolMatch(@"接听") forState:UIControlStateNormal];
        [_btnAccept setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:DWScale(10)];
        [_btnAccept addTarget:self action:@selector(btnAcceptClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnAccept;
}

//被邀请者拒绝通话
- (UIButton *)btnRefuse {
    if (!_btnRefuse) {
        _btnRefuse = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnRefuse.alpha = 0;
        [_btnRefuse setTitleColor:COLORWHITE forState:UIControlStateNormal];
        _btnRefuse.titleLabel.font = FONTR(14);
        [_btnRefuse setImage:ImgNamed(@"ms_btn_cancel") forState:UIControlStateNormal];
        [_btnRefuse setTitle:LanguageToolMatch(@"拒绝") forState:UIControlStateNormal];
        [_btnRefuse setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:DWScale(10)];
        [_btnRefuse addTarget:self action:@selector(btnEndClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnRefuse;
}

//挂断
- (UIButton *)btnEnd {
    if (!_btnEnd) {
        _btnEnd = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnEnd.alpha = 0;
        [_btnEnd setTitleColor:COLORWHITE forState:UIControlStateNormal];
        _btnEnd.titleLabel.font = FONTR(14);
        [_btnEnd setImage:ImgNamed(@"ms_btn_cancel") forState:UIControlStateNormal];
        [_btnEnd setTitle:LanguageToolMatch(@"挂断") forState:UIControlStateNormal];
        [_btnEnd setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:DWScale(10)];
        [_btnEnd addTarget:self action:@selector(btnEndClick) forControlEvents:UIControlEventTouchUpInside];
        _btnEnd.titleLabel.numberOfLines = 2;
        
    }
    return _btnEnd;
}

//音频静音
- (UIButton *)btnMutedAudio {
    if (!_btnMutedAudio) {
        _btnMutedAudio = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnMutedAudio.alpha = 0;
        [_btnMutedAudio setTitle:LanguageToolMatch(@"开启静音") forState:UIControlStateNormal];
        [_btnMutedAudio setTitle:LanguageToolMatch(@"关闭静音") forState:UIControlStateSelected];
        [_btnMutedAudio setTitleColor:COLORWHITE forState:UIControlStateNormal];
        _btnMutedAudio.titleLabel.font = FONTR(14);
        [_btnMutedAudio setImage:ImgNamed(@"ms_btn_audio_muted_off") forState:UIControlStateNormal];
        [_btnMutedAudio setImage:ImgNamed(@"ms_btn_audio_muted_on") forState:UIControlStateSelected];
        [_btnMutedAudio addTarget:self action:@selector(btnMutedAudioClick) forControlEvents:UIControlEventTouchUpInside];
        _btnMutedAudio.titleLabel.numberOfLines = 2;

    }
    return _btnMutedAudio;
}

//免提
- (UIButton *)btnExternal {
    if (!_btnExternal) {
        _btnExternal = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnExternal.alpha = 0;
        [_btnExternal setTitle:LanguageToolMatch(@"开启免提") forState:UIControlStateNormal];
        [_btnExternal setTitle:LanguageToolMatch(@"关闭免提") forState:UIControlStateSelected];
        [_btnExternal setTitleColor:COLORWHITE forState:UIControlStateNormal];
        _btnExternal.titleLabel.font = FONTR(14);
        [_btnExternal setImage:ImgNamed(@"ms_btn_external_off") forState:UIControlStateNormal];//关闭免提
        [_btnExternal setImage:ImgNamed(@"ms_btn_external_on") forState:UIControlStateSelected];//开启免提
        [_btnExternal addTarget:self action:@selector(btnExternalClick) forControlEvents:UIControlEventTouchUpInside];
        _btnExternal.titleLabel.numberOfLines = 2;

    }
    return _btnExternal;
}

//视频静默
- (UIButton *)btnMutedVideo {
    if (!_btnMutedVideo) {
        _btnMutedVideo = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnMutedVideo.alpha = 0;
        [_btnMutedVideo setTitle:LanguageToolMatch(@"关闭摄像头") forState:UIControlStateNormal];
        [_btnMutedVideo setTitle:LanguageToolMatch(@"开启摄像头") forState:UIControlStateSelected];
        [_btnMutedVideo setTitleColor:COLORWHITE forState:UIControlStateNormal];
        _btnMutedVideo.titleLabel.font = FONTR(14);
        [_btnMutedVideo setImage:ImgNamed(@"ms_btn_camera_on") forState:UIControlStateNormal];
        [_btnMutedVideo setImage:ImgNamed(@"ms_btn_camera_off") forState:UIControlStateSelected];
        [_btnMutedVideo addTarget:self action:@selector(btnMutedVideoClick) forControlEvents:UIControlEventTouchUpInside];
        _btnMutedVideo.titleLabel.numberOfLines = 2;

    }
    return _btnMutedVideo;
    
}


- (UIButton *)btnCameraSwitch {
    if (!_btnCameraSwitch) {
        _btnCameraSwitch = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnCameraSwitch.alpha = 0;
        _btnCameraSwitch.enabled = NO;
        _btnCameraSwitch.titleLabel.font = FONTR(14);
        
        [_btnCameraSwitch setTitle:LanguageToolMatch(@"切换") forState:UIControlStateDisabled];
        [_btnCameraSwitch setTkThemeTitleColor:@[[COLORWHITE colorWithAlphaComponent:0.3], [COLORWHITE_DARK colorWithAlphaComponent:0.3]] forState:UIControlStateDisabled];
        [_btnCameraSwitch setImage:ImgNamed(@"ms_btn_camera_change_no") forState:UIControlStateDisabled];
        
        [_btnCameraSwitch setTitle:LanguageToolMatch(@"切换") forState:UIControlStateNormal];
        [_btnCameraSwitch setTkThemeTitleColor:@[COLORWHITE, COLORWHITE_DARK] forState:UIControlStateNormal];
        [_btnCameraSwitch setImage:ImgNamed(@"ms_btn_camera_change") forState:UIControlStateNormal];
        [_btnCameraSwitch addTarget:self action:@selector(btnCameraSwitchClick) forControlEvents:UIControlEventTouchUpInside];
        _btnCameraSwitch.titleLabel.numberOfLines = 2;

    }
    return _btnCameraSwitch;
}

-(void)layoutBtn{
    [_btnEnd setIconInTopWithSpacing:DWScale(10)];
    [_btnCameraSwitch setIconInTopWithSpacing:DWScale(10)];
    [_btnMutedVideo setIconInTopWithSpacing:DWScale(10)];
    [_btnExternal setIconInTopWithSpacing:DWScale(10)];
    [_btnMutedAudio setIconInTopWithSpacing:DWScale(10)];

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DLog(@"音视频通话VC销毁");
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
