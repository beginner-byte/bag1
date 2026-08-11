//
//  NoaBaseVideoPlayerVC.m
//  NoaKit
//
//  Created by Candy on 2026/9/24.
//

#import "NoaBaseVideoPlayerVC.h"
#import "NoaBaseVideoPlayerView.h"
#import "NoaCommonProgressView.h"
#import "NoaToolManager.h"

@interface NoaBaseVideoPlayerVC () <ZBaseVideoPlayerDelegate,ZCommonProgressViewDelegate,UIGestureRecognizerDelegate>
{
    CGFloat _frameH;//展示视频的最大高度
    CGFloat _videoW;//视频宽度
    CGFloat _videoH;//视频高度
}

@property (nonatomic, strong) NoaBaseVideoPlayerView *viewVideo;//视频播放器
@property (nonatomic, strong) UIImageView *ivVideoCover;//视频封面

@property (nonatomic, strong) UIButton *btnStart;//点击开始播放视频

@property (nonatomic, strong) UIView *viewBottom;//底部功能控件
@property (nonatomic, strong) UIButton *btnPlay;//播放暂停
@property (nonatomic, strong) NoaCommonProgressView  *viewProgress;//进度条
@property (nonatomic, strong) UILabel  *lblTime;//视频时长

@property (nonatomic, assign) BOOL isHandPause;//是否是手动暂停
@property (nonatomic, assign) BOOL isCanPlay;//视频是否有效
@end

@implementation NoaBaseVideoPlayerVC

//_videoUrl = @"http:clips.vorwaerts-gmbh.de/big_buck_bunny.mp4";
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_viewVideo.isPlaying) {
        [_viewVideo pausePlay];
    }
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _isHandPause = NO;
    _isCanPlay = NO;
    
    [self setupNavUI];
    [self setupUI];
    
    //监听APP前后台状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayground:) name:UIApplicationDidBecomeActiveNotification object:nil];
}
#pragma mark - 界面布局
- (void)setupNavUI {
    self.navView.tkThemebackgroundColors = @[COLOR_22, COLOR_22];
    self.navTitleLabel.textColor = COLORWHITE;
    self.navTitleStr = LanguageToolMatch(@"视频播放");
    [self.navBtnBack setImage:ImgNamed(@"nav_back_white") forState:UIControlStateNormal];
    self.navBtnRight.hidden = NO;
    [self.navBtnRight setImage:ImgNamed(@"c_nav_more") forState:UIControlStateNormal];
}

- (void)setupUI {
    
    [HUD showActivityMessage:LanguageToolMatch(@"视频加载中...")];
    
    self.view.backgroundColor = COLOR_00;
    
    //默认值
    _frameH = DScreenHeight - DWScale(272);
    _videoW = 0;
    _videoH = 0;
    
    //默认16:9，视频自动播放
    
    //_viewVideo = [[ZBaseVideoPlayerView alloc] initWithFrame:CGRectMake(0, DNavStatusBarH + (_frameH - DScreenWidth * 9 / 16.0) / 2.0, DScreenWidth, DScreenWidth * 9 / 16.0)];
    _viewVideo = [[NoaBaseVideoPlayerView alloc] initWithFrame:CGRectMake(0, DWScale(136), DScreenWidth, DScreenHeight - DWScale(136) * 2)];
    _viewVideo.delegate = self;
    _viewVideo.videoUrl = _videoUrl;
    [_viewVideo startPlay];
    [self.view addSubview:_viewVideo];
    
    _ivVideoCover = [UIImageView new];
    _ivVideoCover.contentMode = UIViewContentModeScaleAspectFill;
    [_ivVideoCover sd_setImageWithURL:[_videoCoverUrl getImageFullUrl] placeholderImage:nil options:SDWebImageAllowInvalidSSLCertificates];
    [self.view addSubview:_ivVideoCover];
    [_ivVideoCover mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_viewVideo);
    }];
    
    _btnStart = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnStart setImage:ImgNamed(@"c_player_stop_big") forState:UIControlStateNormal];
    [_btnStart addTarget:self action:@selector(btnPlayClick) forControlEvents:UIControlEventTouchUpInside];
    _btnStart.hidden = YES;
    [self.view addSubview:_btnStart];
    [_btnStart mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_viewVideo);
        make.size.mas_equalTo(CGSizeMake(DWScale(70), DWScale(70)));
    }];
    
    _viewBottom = [[UIView alloc] initWithFrame:CGRectMake(0, DScreenHeight - DWScale(136), DScreenWidth, DWScale(136))];
    _viewBottom.backgroundColor = COLOR_00;
    [self.view addSubview:_viewBottom];
    
    _btnPlay = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnPlay.frame = CGRectMake(DWScale(20), DWScale(30), DWScale(24), DWScale(24));
    [_btnPlay setImage:ImgNamed(@"c_player_stop_small") forState:UIControlStateNormal];
    [_btnPlay setImage:ImgNamed(@"c_player_playing_small") forState:UIControlStateSelected];
    [_btnPlay addTarget:self action:@selector(btnPlayClick) forControlEvents:UIControlEventTouchUpInside];
    [_viewBottom addSubview:_btnPlay];
    
    _viewProgress = [[NoaCommonProgressView alloc] initWithFrame:CGRectMake(DWScale(54), DWScale(40), DWScale(220), DWScale(4)) viewHeight:DWScale(4) dotHeight:DWScale(4) color:COLOR_99 progressColor:COLORWHITE dragColor:COLORWHITE cornerRadius:DWScale(2) progressDotImage:nil enablePanProgress:YES];
    _viewProgress.delegate = self;
    _viewProgress.showBigProgress = NO;
    _viewProgress.showDot = NO;
    [_viewBottom addSubview:_viewProgress];
    
    _lblTime = [UILabel new];
    _lblTime.text = @"00:00/00:00";
    _lblTime.textColor = COLORWHITE;
    _lblTime.font = FONTR(12);
    [_viewBottom addSubview:_lblTime];
    [_lblTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_btnPlay);
        make.trailing.equalTo(self.view).offset(-DWScale(20));
    }];
    
    //先关闭交互
    [self videoCanPlay:NO];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesAction:)];
    tapGes.delegate = self;
    [self.view addGestureRecognizer:tapGes];
    
    //默认状态
    self.navView.alpha = 0;
    self.viewBottom.alpha = 0;
    self.btnStart.alpha = 0;
}
//展示或隐藏功能控件
- (void)actionViewAnimation {
    __weak typeof(self) weakSelf = self;
    
    if (_viewBottom.alpha == 0) {
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.navView.alpha = 1;
            weakSelf.viewBottom.alpha = 1;
            weakSelf.btnStart.alpha = 1;
        }completion:^(BOOL finished) {
            //自动隐藏
            [weakSelf performSelector:@selector(actionViewAnimation) withObject:nil afterDelay:3];
        }];
    }else {
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.navView.alpha = 0;
            weakSelf.viewBottom.alpha = 0;
            weakSelf.btnStart.alpha = 0;
        }];
    }
}
- (void)videoCanPlay:(BOOL)canPlay {
    _btnPlay.userInteractionEnabled = canPlay;
    _btnStart.userInteractionEnabled = canPlay;
    _viewProgress.enablePan = canPlay;
}
#pragma mark - ZBaseVideoPlayerDelegate
- (void)videoPlayerEvent:(TXVodPlayer *)player event:(NSInteger)eventID param:(NSDictionary *)param {
    DLog(@"播放状态码%ld",eventID);
    if (eventID == PLAY_EVT_VOD_PLAY_PREPARED) {
        //2013视频加载完毕
    } else if (eventID == PLAY_EVT_RCV_FIRST_I_FRAME) {
        //成功获取视频第一帧
        if (_videoW == 0) {
            _videoW = player.width;
            _videoH = player.height;
            
            CGFloat duration = player.duration;
            _lblTime.text = [NSString stringWithFormat:@"00:00/%@",[NSString getTimeLength:roundf(duration)]];
            [_viewProgress setValue:0];
            
            //[self updateVideoFrameUI];
            
            //视频可以播放，打开交互
            [self videoCanPlay:YES];
            _btnPlay.selected = YES;
            
            //视频可以播放，开启3秒后进入沉浸式观看
            [self performSelector:@selector(actionViewAnimation) withObject:nil afterDelay:3];
        }
    } else if (eventID == PLAY_EVT_PLAY_BEGIN) {
        //2004视频开始播放
        [HUD hideHUD];
        _isHandPause = NO;
    } else if (eventID == PLAY_EVT_PLAY_PROGRESS) {
        //视频加载进度，单位是秒，小数部分为毫秒
        //float playAble = [[param objectForKeySafe:EVT_PLAYABLE_DURATION] floatValue];
        //视频播放进度，单位是秒，小数部分为毫秒
        //float progress = [[param objectForKeySafe:EVT_PLAY_PROGRESS] floatValue];
        //视频总时长，单位是秒，小数部分为毫秒
        //float duration = [[param objectForKeySafe:EVT_PLAY_DURATION] floatValue];
        //DLog(@"视频信息%f--%f--%f",playAble,progress,duration);
        [HUD hideHUD];
        if (_viewVideo.videoPlayerState == ZVideoPlayerStateStopped) {
            return;
        }
        
        CGFloat duration = roundf(player.duration);
        CGFloat progress = roundf(player.currentPlaybackTime);
        [_viewProgress setValue:progress / duration animateWithDuration:1.0 time:progress];
        
        _lblTime.text = [NSString stringWithFormat:@"%@/%@",[NSString getTimeLength:progress],[NSString getTimeLength:duration]];
        
    } else if (eventID == PLAY_EVT_PLAY_END) {
        [HUD hideHUD];
        [_viewVideo pausePlay];
        
        _btnPlay.selected = NO;
        _btnStart.hidden = NO;
        
        CGFloat duration = player.duration;
        _lblTime.text = [NSString stringWithFormat:@"00:00/%@",[NSString getTimeLength:roundf(duration)]];
        [_viewProgress setValue:0];
        
        _ivVideoCover.hidden = NO;
        
    } else if (eventID == PLAY_EVT_PLAY_LOADING) {
        //缓冲...
        [HUD showActivityMessage:LanguageToolMatch(@"正在缓冲...")];
    }else if (eventID == PLAY_EVT_VOD_LOADING_END) {
        //结束缓冲
        [HUD hideHUD];
    } else if (eventID == PLAY_ERR_NET_DISCONNECT){
        //-2301网络断连,且经多次重连亦不能恢复,更多重试请自行重启播放
        [HUD showMessage:LanguageToolMatch(@"未能连接到网络，请稍后重试")];
    } else if (eventID == PLAY_WARNING_RECONNECT){
        //2103网络断开，已开始重连(自动重连连续失败超过三次会放弃 -2301)
    } else if (eventID == PLAY_ERR_FILE_NOT_FOUND) {
        //文件不存在
        [HUD showMessage:LanguageToolMatch(@"播放出错了o(╥﹏╥)o")];
    }
}
//更新播放器约束
- (void)updateVideoFrameUI {
    
    CGFloat H = _videoH * DScreenWidth / (_videoW * 1.0);
    if (H > _frameH) {
        //视频最大高度为基准
        _viewVideo.width = _frameH * _videoW / (_videoH * 1.0);
        _viewVideo.height = _frameH;
        _viewVideo.y = DNavStatusBarH;
    }else {
        //视频宽度为基准
        _viewVideo.width = DScreenWidth;
        _viewVideo.height = _videoH * DScreenWidth / (_videoW * 1.0);
        _viewVideo.y = DNavStatusBarH + (_frameH - _videoH * DScreenWidth / (_videoW * 1.0)) / 2.0;
    }
    _viewVideo.x = (DScreenWidth - _viewVideo.width) / 2.0;
    
    _viewVideo.alpha = 1;
    _ivVideoCover.hidden =YES;
    
}
#pragma mark - 交互事件
- (void)btnPlayClick {
    _btnPlay.selected = !_btnPlay.selected;
    if (_btnPlay.selected) {
        [_viewVideo resumePlay];
        _btnStart.alpha = 0;
        _btnStart.hidden = YES;
    }else {
        [_viewVideo pausePlay];
        _btnStart.alpha = 1;
        _btnStart.hidden = NO;
        _isHandPause = YES;
    }
    
    if (!_ivVideoCover.hidden) {
        _ivVideoCover.hidden = YES;
    }
}
- (void)tapGesAction:(UITapGestureRecognizer *)tap{
   //取消延迟执行的方法
   [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(actionViewAnimation) object:nil];
    [self actionViewAnimation];
}

#pragma mark - ZCommonProgressViewDelegate
- (void)progressViewCurrentPlayPrecent:(CGFloat)precent dragState:(ZCommonGestureState)dragState {
    _viewVideo.sliderValue = precent * PLAYER.videoPlayer.duration;
    
    CGFloat duration = roundf(PLAYER.videoPlayer.duration);
    CGFloat progress = roundf(precent * PLAYER.videoPlayer.duration);
    _lblTime.text = [NSString stringWithFormat:@"%@/%@",[NSString getTimeLength:progress],[NSString getTimeLength:duration]];
    
}

#pragma mark - 导航栏右侧按钮点击事件
- (void)navBtnRightClicked {
    WeakSelf
    NoaPresentItem *saveItem = [NoaPresentItem creatPresentViewItemWithText:LanguageToolMatch(@"保存到手机") textColor:COLOR_11 font:FONTR(17) itemHeight:DWScale(54) backgroundColor:COLORWHITE];
    self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        if (themeIndex == 0) {
            saveItem.textColor = COLOR_11;
            saveItem.backgroundColor = COLORWHITE;
        }else {
            saveItem.textColor = COLORWHITE;
            saveItem.backgroundColor = COLOR_11;
        }
    };
    NoaPresentItem *cancelItem = [NoaPresentItem creatPresentViewItemWithText:LanguageToolMatch(@"取消") textColor:COLOR_99 font:FONTR(17) itemHeight:DWScale(54) backgroundColor:COLORWHITE];
    self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        if (themeIndex == 0) {
            cancelItem.textColor = COLOR_99;
            cancelItem.backgroundColor = COLORWHITE;
        }else {
            cancelItem.textColor = COLOR_99;
            cancelItem.backgroundColor = COLOR_11;
        }
    };
    NoaPresentView *viewAlert = [[NoaPresentView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DScreenHeight) titleItem:nil selectItems:@[saveItem] cancleItem:cancelItem doneClick:^(NSInteger index) {
        [weakSelf saveVideoInAlbum];
    } cancleClick:^{
        
    }];
    [self.view addSubview:viewAlert];
    [viewAlert showPresentView];
}
//保存视频到相册
- (void)saveVideoInAlbum {
    if (![NSString isNil:_videoUrl]) {
        [HUD showActivityMessage:LanguageToolMatch(@"正在保存...")];
        //此处的逻辑应该是，先查询本地缓存有没有该视频
        //有的话，直接保存，没有的话先缓存到本地，再保存

        NSString *videoPath = [ZTOOL videoExistsWith:_videoUrl];
        if (![NSString isNil:videoPath]) {
            //已有缓存，直接保存
            [ZTOOL saveVideoToAlbumWith:videoPath];
        }else {
            //先下载缓存，再保存
            [ZTOOL downloadVideoWith:_videoUrl completion:^(BOOL success, NSString * _Nonnull videoPath) {
                if (success) {
                    [ZTOOL saveVideoToAlbumWith:videoPath];
                }
            }];
        }
    }
}

#pragma mark - 应用退到后台
- (void)appDidEnterBackground:(NSNotification *)notify {
    if (_viewVideo.isPlaying) {
        [_viewVideo pausePlay];
    }
}

#pragma mark - 应用进入前台
- (void)appDidEnterPlayground:(NSNotification *)notify {
    if (!_viewVideo.isPlaying && !self.isHandPause) {
        //非正在播放，非手动暂停，非播放完成 后台切入前台自动播放
        [_viewVideo resumePlay];
    }
    
    self.view.backgroundColor = COLOR_00;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:self.view] || [touch.view isDescendantOfView:_viewVideo]) {
        return YES;
    }
    return NO;
}

- (void)dealloc {
    [_viewVideo deallocPlayer];
    [HUD hideHUD];
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
