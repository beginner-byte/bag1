//
//  NoaCallVC.m
//  NoaKit
//
//  Created by Candy on 2023/5/19.
//

#import "NoaCallVC.h"
#import "UIButton+Gradient.h"

/// 视频通话功能按钮，负责在按钮状态变化时稳定地按“图标在上、文字在下”重新布局。
@interface NoaCallActionButton : UIButton

/// 是否启用视频通话专用的垂直图文布局；音频通话保持原有 UIButton 布局。
@property (nonatomic, assign) BOOL callVerticalLayoutEnabled;
/// 图标允许占用的最大尺寸，按屏幕比例设置且保持图片原始宽高比。
@property (nonatomic, assign) CGSize callIconMaxSize;
/// 图标和文字之间的垂直间距，单位为 point。
@property (nonatomic, assign) CGFloat callImageTitleSpacing;

@end

@implementation NoaCallActionButton

/// 根据当前 Normal、Selected 或 Disabled 状态的图片和标题重新计算内部布局。
/// 图片始终保持原始宽高比；标题最多使用按钮已配置的行数，不改变按钮点击区域。
- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.callVerticalLayoutEnabled || !self.currentImage || self.currentTitle.length == 0) {
        return;
    }

    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;

    CGFloat buttonWidth = CGRectGetWidth(self.bounds);
    CGFloat buttonHeight = CGRectGetHeight(self.bounds);
    if (buttonWidth <= 0 || buttonHeight <= 0) {
        return;
    }

    CGSize sourceImageSize = self.currentImage.size;
    if (sourceImageSize.width <= 0 || sourceImageSize.height <= 0) {
        return;
    }
    CGFloat imageScale = MIN(self.callIconMaxSize.width / sourceImageSize.width,
                             self.callIconMaxSize.height / sourceImageSize.height);
    imageScale = MIN(imageScale, buttonWidth / sourceImageSize.width);
    CGSize imageSize = CGSizeMake(floor(sourceImageSize.width * imageScale),
                                  floor(sourceImageSize.height * imageScale));

    CGFloat maxTitleHeight = MAX(0, buttonHeight - imageSize.height - self.callImageTitleSpacing);
    CGSize titleSize = [self.titleLabel sizeThatFits:CGSizeMake(buttonWidth, maxTitleHeight)];
    CGFloat titleHeight = MIN(ceil(titleSize.height), maxTitleHeight);
    CGFloat contentHeight = imageSize.height + self.callImageTitleSpacing + titleHeight;
    CGFloat contentTop = MAX(0, floor((buttonHeight - contentHeight) / 2.0));

    self.imageView.frame = CGRectMake(floor((buttonWidth - imageSize.width) / 2.0),
                                      contentTop,
                                      imageSize.width,
                                      imageSize.height);
    self.titleLabel.frame = CGRectMake(0,
                                       CGRectGetMaxY(self.imageView.frame) + self.callImageTitleSpacing,
                                       buttonWidth,
                                       titleHeight);
}

@end

@interface NoaCallVC ()

@end

@implementation NoaCallVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navView.hidden = YES;
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [NoaCallManager sharedManager].delegate = self;
    
    //监听关闭UI
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callRoomEnd) name:ZGCALLROOMEND object:nil];
    //监听是否可以加入房间
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callRoomJoin) name:ZGCALLROOMJOIN object:nil];
    //监听摄像头静默状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callRoomCameraMute:) name:ZGCALLROOMCAMERAMUTE object:nil];
    
    //设置为不息屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
}

#pragma mark - 加入房间
- (void)callRoomJoin {
    
}

#pragma mark - 关闭界面通话结束
- (void)callRoomEnd {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - 摄像头静默状态改变
- (void)callRoomCameraMute:(NSNotification *)notification {
    
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

//免提 扬声器
- (void)btnExternalClick {
}

//音频静默
- (void)btnMutedAudioClick {
}

//视频静默
- (void)btnMutedVideoClick {
}

//摄像头切换
- (void)btnCameraSwitchClick {
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
        _btnEnd = [[NoaCallActionButton alloc] initWithFrame:CGRectZero];
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
        _btnMutedAudio = [[NoaCallActionButton alloc] initWithFrame:CGRectZero];
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
        _btnMutedVideo = [[NoaCallActionButton alloc] initWithFrame:CGRectZero];
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
        _btnCameraSwitch = [[NoaCallActionButton alloc] initWithFrame:CGRectZero];
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DLog(@"音视频通话VC销毁");
}

/// 根据当前通话类型配置功能按钮的图文布局。
/// 视频通话使用状态自适应的垂直布局；音频通话继续使用原有间距逻辑，避免改变既有页面。
- (void)layoutBtn {
    NoaCallOptions *currentCallOptions = [NoaCallManager sharedManager].currentCallOptions;
    if (currentCallOptions.zgCallOptions.callType == LingIMCallTypeVideo) {
        NSArray<NoaCallActionButton *> *videoActionButtons = @[
            (NoaCallActionButton *)_btnMutedVideo,
            (NoaCallActionButton *)_btnMutedAudio,
            (NoaCallActionButton *)_btnCameraSwitch,
            (NoaCallActionButton *)_btnEnd
        ];
        for (NoaCallActionButton *button in videoActionButtons) {
            button.callVerticalLayoutEnabled = YES;
            button.callIconMaxSize = CGSizeMake(DWScale(60), DWScale(60));
            button.callImageTitleSpacing = DWScale(10);
            [button setNeedsLayout];
        }
        return;
    }

    [_btnEnd setIconInTopWithSpacing:DWScale(10)];
    [_btnExternal setIconInTopWithSpacing:DWScale(10)];
    [_btnMutedAudio setIconInTopWithSpacing:DWScale(10)];
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
