//
//  KNVideoIjkPlayerView.m
//  NoaChatKit
//
//  Created by blackcat on 2025/9/28.
//

#import "KNVideoIjkPlayerView.h"
#import "KNPhotoAVPlayerActionBar.h"
#import "KNPhotoAVPlayerActionView.h"
#import "KNPhotoBrowserPch.h"
#import "KNProgressHUD.h"
#import "KNReachability.h"
//#import "IJKMediaFramework/IJKMediaFramework.h"
#import <FSPlayer/FSPlayerKit.h>

@interface KNVideoIjkPlayerView()<KNPhotoAVPlayerActionViewDelegate,KNPhotoAVPlayerActionBarDelegate>

@property(atomic, retain) id<FSMediaPlayback> player;

@property (nonatomic,strong) KNPhotoAVPlayerActionView *actionView;
@property (nonatomic,strong) KNPhotoAVPlayerActionBar  *actionBar;

@property (nonatomic,copy  ) NSString *url;
@property (nonatomic,strong) UIImage *placeHolder;

@property (nonatomic,strong) id timeObserver;

@property (nonatomic,assign) BOOL isPlaying;
@property (nonatomic,assign) BOOL isDragging;
@property (nonatomic,assign) BOOL isEnterBackground;
@property (nonatomic,assign) BOOL isAddObserver;
@property (nonatomic,assign) BOOL videoIsSwiping; // current video player is swiping?

@property (nonatomic,strong) KNPhotoDownloadMgr *downloadMgr;
@property (nonatomic,strong) KNPhotoItems *photoItems;
@property (nonatomic,weak  ) KNProgressHUD *progressHUD;
@property (nonatomic,copy  ) PhotoDownLoadBlock downloadBlock;

@end

@implementation KNVideoIjkPlayerView {
    float _allDuration;
    
    dispatch_source_t _timer;
    dispatch_queue_t _timerQueue;
}

- (KNPhotoAVPlayerActionView *)actionView{
    if (!_actionView) {
        _actionView = [[KNPhotoAVPlayerActionView alloc] init];
        [_actionView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(photoAVPlayerActionViewDidLongPress:)]];
        _actionView.delegate = self;
        _actionView.isBuffering = false;
        _actionView.isPlaying = false;
    }
    return _actionView;
}
- (KNPhotoAVPlayerActionBar *)actionBar{
    if (!_actionBar) {
        _actionBar = [[KNPhotoAVPlayerActionBar alloc] init];
        _actionBar.backgroundColor = [UIColor colorWithRed:45/255.0 green:45/255.0 blue:45/255.0 alpha:1.];
        _actionBar.delegate = self;
        _actionBar.isPlaying = false;
        _actionBar.hidden = true;
    }
    return _actionBar;
}

- (UIView *)playerBgView{
    if (!_playerBgView) {
        _playerBgView = [[UIView alloc] init];
    }
    return _playerBgView;
}
- (UIView *)playerView{
    if (!_player) {
        return [[UIView alloc] init];
    }
    return _player.view;
}
- (UIImageView *)placeHolderImgView{
    if (!_placeHolderImgView) {
        _placeHolderImgView = [[UIImageView alloc] init];
        _placeHolderImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _placeHolderImgView;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self.playerBgView addSubview:self.placeHolderImgView];
        [self.playerBgView addSubview:self.playerView];
        self.playerLayer = [AVPlayerLayer layer];
        
        [self addSubview:self.playerBgView];
        [self addSubview:self.actionView];
        [self addSubview:self.actionBar];
        BOOL isNeedCustomActionBar = [KNPhotoBrowserConfig share].isNeedCustomActionBar;
        if (isNeedCustomActionBar == false) {
            [self addSubview:self.actionBar];
        }
        _downloadBlock = nil;
        
#ifdef DEBUG
        [FSPlayer setLogReport:YES];
        [FSPlayer setLogLevel:FS_LOG_INFO];
#else
        [FSPlayer setLogReport:NO];
#endif
        [FSPlayer checkIfFFmpegVersionMatch:YES];
        [self setupTimer];
    }
    return self;
}

- (void)setupTimer {
    _timerQueue = dispatch_queue_create("com.ijkplayer.timer", DISPATCH_QUEUE_CONCURRENT);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _timerQueue);
    
    if (_timer) {
        dispatch_source_set_timer(_timer,
                                  dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)),
                                  (uint64_t)(0.1 * NSEC_PER_SEC),
                                  0);
        
        __weak typeof(self) weakSelf = self;
        dispatch_source_set_event_handler(_timer, ^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            
            [self tick];
        });
        
        dispatch_resume(_timer);
    }
}

- (void)playerLocatePhotoItems:(KNPhotoItems *)photoItems progressHUD:(KNProgressHUD *)progressHUD placeHolder:(UIImage *_Nullable)placeHolder{
    
    _allDuration = 0.0;
    
    [self cancelDownloadMgrTask];
    
    [self addObserverAndAudioSession];
    
    _downloadBlock = nil;
    
    if (_url == photoItems.url) {
        return;
    }
    _url = photoItems.url;
    _placeHolder = placeHolder;
    _progressHUD = progressHUD;
    _photoItems  = photoItems;
    
    _downloadMgr = [[KNPhotoDownloadMgr alloc] init];
    
    if (placeHolder) {
        _placeHolderImgView.image = placeHolder;
    }
    
    NSString *newFilePath;
    if ([photoItems.url hasPrefix:@"http"]) {
        
        KNPhotoDownloadFileMgr *fileMgr = [[KNPhotoDownloadFileMgr alloc] init];
        if ([fileMgr startCheckIsExistVideo:photoItems]) {
            progressHUD.hidden = true;
            _actionView.isBuffering = true;
            
            NSString *filePath = [fileMgr startGetFilePath:photoItems];
            newFilePath = filePath;
        }
    }else {
        progressHUD.hidden = true;
        _actionView.isBuffering = true;
        newFilePath = _url;
    }
    if (!newFilePath) {
        return;
    }

    
    [self resetPlayer: newFilePath];
    
    [_actionView avplayerActionViewNeedHidden:false];
    
    _isEnterBackground = _isAddObserver = _isDragging = _isPlaying = false;
    
    _player.playbackRate = 1.0;
    [_player pause];
}

- (void)resetPlayer: (NSString *)path {
    [self removePlayerItemObserver];
    
    [_player stop];
    [_player shutdown];
    [_player.view removeFromSuperview];
    [self removePlayerItemObserver];
    
    FSOptions *options = [FSOptions optionsByDefault];
    [options setPlayerOptionIntValue:414  forKey:@"videotoolbox-max-frame-width"];
    [options setPlayerOptionIntValue:YES forKey:@"videotoolbox_hwaccel"];
    [options setPlayerOptionIntValue:1 forKey:@"enable-accurate-seek"];//开启精准seek
    [options setPlayerOptionIntValue:1500 forKey:@"accurate-seek-timeout"];

    self.player = [[FSPlayer alloc] initWithContentURL:[NSURL fileURLWithPath:path] withOptions:options];
    self.player.scalingMode = FSScalingModeAspectFit;
    [self.playerBgView addSubview:_player.view];
    [self.player prepareToPlay];
    [self addPlayerItemObserver];
}

- (void)playerCustomActionBar:(KNPhotoAVPlayerActionBar *)customBar {
    BOOL isNeedCustomActionBar = [KNPhotoBrowserConfig share].isNeedCustomActionBar;
    if (isNeedCustomActionBar == false) { return; }
    
    if (customBar == nil) { return; }
    
    [_actionBar removeFromSuperview];
    _actionBar = customBar;
    _actionBar.delegate = self;
    _actionBar.isPlaying = false;
    _actionBar.hidden = true;
    _actionBar.allDuration = (float)_player.duration;
    _actionBar.currentTime = _player.currentPlaybackTime;
    [self addSubview:_actionBar];
    
    [self layoutSubviews];
}

- (void)addObserverAndAudioSession{
    // AudioSession setting
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:true error:nil];
    if(_isSoloAmbient == true) {
        [session setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    }else {
        [session setCategory:AVAudioSessionCategoryAmbient error:nil];
    }
    
    // Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
}

/// notification function
- (void)applicationWillResignActive{
    _isEnterBackground = true;
    if (_isPlaying) [self photoAVPlayerActionBarClickWithIsPlay:false];
}

/// remove item observer
- (void)removePlayerItemObserver{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:FSPlayerLoadStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:FSPlayerDidFinishNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:FSPlayerIsPreparedToPlayNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:FSPlayerPlaybackStateDidChangeNotification object:_player];
}
/// add item observer
- (void)addPlayerItemObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:FSPlayerLoadStateDidChangeNotification
                                               object:_player];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:FSPlayerDidFinishNotification
                                               object:_player];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:FSPlayerIsPreparedToPlayNotification
                                               object:_player];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:FSPlayerPlaybackStateDidChangeNotification
                                               object:_player];
}

/// function
- (void)playerWillReset{
    [_player pause];
    _isPlaying = false;
    [self removePlayerItemObserver];
}
- (void)playerWillSwipe{
    [_actionView avplayerActionViewNeedHidden:true];
    _actionBar.hidden = true;
    _progressHUD.hidden = true;
    _videoIsSwiping = true;
}
/// AVPlayer will cancel swipe
- (void)playerWillSwipeCancel{
    KNPhotoDownloadFileMgr *fileMgr = [[KNPhotoDownloadFileMgr alloc] init];
    if ([self.photoItems.url hasPrefix:@"http"]) {
        if ([fileMgr startCheckIsExistVideo:self.photoItems] == false && _progressHUD.progress != 1.0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(PhotoBrowserAnimateTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self->_progressHUD.hidden = false;
            });
        }else {
            _progressHUD.hidden = true;
        }
    }else {
        _progressHUD.hidden = true;
    }
    _videoIsSwiping = false;
    if (_actionBar.currentTime == 0) {
        [_actionView avplayerActionViewNeedHidden:false];
    }
}
- (void)playerRate:(CGFloat)rate{
    if (_isPlaying == false) {
        return;
    }
    _player.playbackRate = rate;
}
/// when dismiss, should cancel download task first
- (void)cancelDownloadMgrTask{
    if (_downloadMgr) [_downloadMgr cancelTask];
}
/// playerdownload
/// @param downloadBlock download callBack
- (void)playerDownloadBlock:(PhotoDownLoadBlock)downloadBlock{
    _downloadBlock = downloadBlock;
}

/// setter
- (void)setIsNeedAutoPlay:(BOOL)isNeedAutoPlay {
    _isNeedAutoPlay = isNeedAutoPlay;
    if (isNeedAutoPlay) {
        [self photoAVPlayerActionViewPauseOrStop];
    }
}
- (void)setIsNeedVideoPlaceHolder:(BOOL)isNeedVideoPlaceHolder{
    _isNeedVideoPlaceHolder = isNeedVideoPlaceHolder;
    self.placeHolderImgView.hidden = !isNeedVideoPlaceHolder;
}
- (void)setIsNeedVideoDismissButton:(BOOL)isNeedVideoDismissButton {
    _isNeedVideoDismissButton = isNeedVideoDismissButton;
    _actionView.isNeedVideoDismissButton = isNeedVideoDismissButton;
}
- (void)photoAVPlayerActionViewDidLongPress:(UILongPressGestureRecognizer *)longPress{
    if (_isPlaying == false) {
        return;
    }
    if ([_delegate respondsToSelector:@selector(photoPlayerLongPress:)]) {
        [_delegate photoPlayerLongPress:longPress];
    }
}

/// delegate
/**
 actionView's Pause imageView
 */
- (void)photoAVPlayerActionViewPauseOrStop{
    KNPhotoDownloadFileMgr *fileMgr = [[KNPhotoDownloadFileMgr alloc] init];
    if ([_photoItems.url hasPrefix:@"http"] == true && [fileMgr startCheckIsExistVideo:_photoItems] == false) {
        if (![[KNReachability reachabilityForInternetConnection] isReachable]) { // no network
            [_progressHUD setHidden:true];
            return;
        }
        _actionView.isDownloading = true;
        [_progressHUD setHidden:false];
        [_progressHUD setProgress:0.0];
        __weak typeof(self) weakself = self;
        [_downloadMgr downloadVideoWithPhotoItems:_photoItems downloadBlock:^(KNPhotoDownloadState downloadState, float progress) {
            [weakself.progressHUD setProgress:progress];
            if (downloadState == KNPhotoDownloadStateSuccess) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    KNPhotoDownloadFileMgr *manager = [[KNPhotoDownloadFileMgr alloc] init];
                    NSString *filePath = [manager startGetFilePath:weakself.photoItems];
                    NSData *resultData = [NSData dataWithContentsOfFile:filePath];
//                    NSData * encryptfileData = [[ZEncryptManager shareEncryManager] decrypt:resultData];
                    NSData * encryptfileData = [[EncryptManager shareEncryManager] decrypt:resultData];
                    [encryptfileData writeToFile:filePath options:0 error:nil];
                    [weakself resetPlayer:filePath];
                    
                    weakself.progressHUD.progress = 1.0;
                    
                    weakself.isPlaying = true;
                    weakself.actionBar.isPlaying = true;
                    weakself.actionView.isBuffering = true;
                    weakself.actionView.isPlaying = true;
                });
            }
            if (downloadState == KNPhotoDownloadStateUnknow || downloadState == KNPhotoDownloadStateFailure) {
                [weakself.progressHUD setProgress:0.0];
            }
            if (weakself.downloadBlock) {
                weakself.downloadBlock(downloadState, progress);
            }
        }];
    }else {
        _progressHUD.hidden = true;
        if (_isPlaying == false) {
            [_player play];
            _actionBar.isPlaying = true;
            _actionView.isPlaying = true;
        }else {
            [_player pause];
            _actionView.isPlaying = false;
            _actionBar.isPlaying = false;
        }
        
        _isPlaying = !_isPlaying;
    }
    _isEnterBackground = false;
}
- (void)photoAVPlayerActionViewDismiss{
    [self cancelDownloadMgrTask];
    if ([_delegate respondsToSelector:@selector(photoPlayerViewDismiss)]) {
        [_delegate photoPlayerViewDismiss];
    }
}
- (void)photoAVPlayerActionViewDidClickIsHidden:(BOOL)isHidden{
    [_actionBar setHidden:isHidden];
}
- (void)photoAVPlayerActionBarClickWithIsPlay:(BOOL)isNeedPlay{
    if (isNeedPlay) {
        [_player play];
        _actionView.isPlaying = true;
        _actionBar.isPlaying = true;
        _isPlaying = true;
    }else {
        [_player pause];
        _actionView.isPlaying = false;
        _actionBar.isPlaying = false;
        _isPlaying = false;
    }
}

- (void)photoAVPlayerActionBarBeginChange{
    _isDragging = true;
}
- (void)photoAVPlayerActionBarChangeValue:(float)value{
    self.player.currentPlaybackTime = value;
    self.actionBar.currentTime = value;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.playerBgView.frame = CGRectMake(10, 0, self.frame.size.width - 20, self.frame.size.height);
    self.playerView.frame   = self.playerBgView.bounds;
    self.playerLayer.frame  = self.playerView.bounds;
    self.actionView.frame   = self.playerBgView.frame;
    self.placeHolderImgView.frame  = self.playerBgView.bounds;
    
    if (PBDeviceHasBang) {
        self.actionBar.frame    = CGRectMake(15, self.frame.size.height - 70, self.frame.size.width - 30, 40);
    }else {
        self.actionBar.frame    = CGRectMake(15, self.frame.size.height - 50, self.frame.size.width - 30, 40);
    }
}

#pragma mark - 播放器状态监听
- (void)tick {
    if (!_player) return;
    if (!_player.isPlaying) return;
    if (_isDragging) return;
    [ZTOOL doInMain:^{
        self->_actionBar.currentTime = self->_player.currentPlaybackTime;
    }];
}

- (void)loadStateDidChange:(NSNotification*)notification
{
    //    MPMovieLoadStateUnknown        = 0,
    //    MPMovieLoadStatePlayable       = 1 << 0,
    //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started

    FSPlayerLoadState loadState = _player.loadState;

    if ((loadState & FSPlayerLoadStatePlayable) != 0) {
        _placeHolderImgView.hidden = true;
        self.actionBar.allDuration = (float)_player.duration;
    } else if ((loadState & FSPlayerLoadStatePlaythroughOK) != 0) {
        float duration = _player.duration;
        _actionBar.allDuration = duration;
        _allDuration = duration;
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
    } else if ((loadState & FSPlayerLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    //    MPMovieFinishReasonPlaybackEnded,
    //    MPMovieFinishReasonPlaybackError,
    //    MPMovieFinishReasonUserExited
    int reason = [[[notification userInfo] valueForKey:FSPlayerDidFinishReasonUserInfoKey] intValue];

    switch (reason)
    {
        case FSFinishReasonPlaybackEnded:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            self.player.currentPlaybackTime = 0;
            [self.player pause];
            self.actionBar.currentTime = 0;
            self.isPlaying = false;
            self.actionBar.isPlaying = false;
            self.actionView.isPlaying = false;
            [self.actionView avplayerActionViewNeedHidden:self.videoIsSwiping];
            break;

        case FSFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;

        case FSFinishReasonPlaybackError:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            break;

        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    NSLog(@"mediaIsPreparedToPlayDidChange\n");
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    //    MPMoviePlaybackStateStopped,
    //    MPMoviePlaybackStatePlaying,
    //    MPMoviePlaybackStatePaused,
    //    MPMoviePlaybackStateInterrupted,
    //    MPMoviePlaybackStateSeekingForward,
    //    MPMoviePlaybackStateSeekingBackward

    switch (_player.playbackState)
    {
        case FSPlayerPlaybackStateStopped: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            break;
        }
        case FSPlayerPlaybackStatePlaying: {
            _isBeginPlayed = YES;
            self.actionBar.currentTime = (float)_player.currentPlaybackTime;
            self.actionBar.allDuration = (float)_player.duration;
            self.actionView.isBuffering = false;
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            break;
        }
        case FSPlayerPlaybackStatePaused: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            break;
        }
        case FSPlayerPlaybackStateInterrupted: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
        }
        case FSPlayerPlaybackStateSeekingForward:
        case FSPlayerPlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            self.actionBar.currentTime = (float)_player.currentPlaybackTime;
            _isDragging = false;
            break;
        }
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}

- (void)dealloc{
    [self removeObserverAndAudioSesstion];
    dispatch_source_cancel(_timer);
}

- (void)removeObserverAndAudioSesstion{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[AVAudioSession sharedInstance] setActive:false withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

@end

