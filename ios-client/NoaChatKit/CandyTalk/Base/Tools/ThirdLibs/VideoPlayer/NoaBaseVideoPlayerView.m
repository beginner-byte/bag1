//
//  NoaBaseVideoPlayerView.m
//  NoaKit
//
//  Created by Candy on 2026/9/24.
//

#import "NoaBaseVideoPlayerView.h"

@implementation NoaBaseVideoPlayerView

{
    CGFloat _videoW;//视频宽度
    CGFloat _videoH;//视频高度
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        [self setupView];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupView{
    
    //创建播放器
    [PLAYER.videoPlayer setupVideoWidget:self insertIndex:0];
    PLAYER.videoPlayer.vodDelegate = self;
}
#pragma mark - 参数配置
- (void)setVideoUrl:(NSString *)videoUrl{
    if (videoUrl.length > 0) {
        _videoUrl = videoUrl;
    }
}
- (void)setFileID:(NSString *)fileID{
    if (fileID.length > 0) {
        _fileID = fileID;
    }
}

- (void)setRenderMode:(TX_Enum_Type_RenderMode)renderMode{
    [PLAYER.videoPlayer setRenderMode:renderMode];
}
- (void)setRotation:(TX_Enum_Type_HomeOrientation)rotation{
    [PLAYER.videoPlayer setRenderRotation:rotation];
}
- (void)setPlayerConfig:(TXVodPlayConfig *)playerConfig{
    [PLAYER.videoPlayer setConfig:playerConfig];
}

- (void)setSliderValue:(CGFloat)sliderValue{
    [PLAYER.videoPlayer seek:sliderValue];
}
- (void)setStartTime:(CGFloat)startTime{
    [PLAYER.videoPlayer setStartTime:startTime];
}
- (void)setIsAutoPlay:(BOOL)isAutoPlay{
    [PLAYER.videoPlayer setIsAutoPlay:isAutoPlay];
}
- (void)setIsMute:(BOOL)isMute{
    [PLAYER.videoPlayer setMute:isMute];
}
- (void)setIsLoop:(BOOL)isLoop{
    [PLAYER.videoPlayer setLoop:isLoop];
}
- (BOOL)isPlaying{
    return PLAYER.videoPlayer.isPlaying;
}

#pragma mark - 方法事件
- (void)startPlay{
    if (_videoUrl.length > 0) {
        [PLAYER.videoPlayer startPlay:_videoUrl];
    }else if (_fileID.length > 0) {
        TXPlayerAuthParams *param = [TXPlayerAuthParams new];
        param.appId = 123456789;
        param.fileId = _fileID;
        [PLAYER.videoPlayer startPlayWithParams:param];
    }
    
    _videoW = [PLAYER.videoPlayer width];
    _videoH = [PLAYER.videoPlayer height];
}
- (void)pausePlay{
    [PLAYER.videoPlayer pause];
    _videoPlayerState = ZVideoPlayerStatePause;
}
- (void)resumePlay{
    [PLAYER.videoPlayer resume];
    _videoPlayerState = ZVideoPlayerStatePlaying;
}
- (void)stopPlay{
    [PLAYER.videoPlayer stopPlay];
    _videoPlayerState = ZVideoPlayerStateStopped;
}
- (void)deallocPlayer{
    [PLAYER.videoPlayer stopPlay];
    [PLAYER.videoPlayer removeVideoWidget];
}

#pragma mark - TXVodPlayListener
//点播事件
- (void)onPlayEvent:(TXVodPlayer *)player event:(int)EvtID withParam:(NSDictionary *)param {
    if (EvtID == PLAY_EVT_PLAY_BEGIN) {
        //视频开始播放，如果有加载效果，这个时候可以结束了
        _videoPlayerState = ZVideoPlayerStatePlaying;
        
    } else if (EvtID == PLAY_EVT_PLAY_PROGRESS) {
        //视频加载进度，单位是秒，小数部分为毫秒
        float playAble = [[param objectForKeySafe:EVT_PLAYABLE_DURATION] floatValue];
        //视频播放进度，单位是秒，小数部分为毫秒
        float progress = [[param objectForKeySafe:EVT_PLAY_PROGRESS] floatValue];
        //视频总时长，单位是秒，小数部分为毫秒
        float duration = [[param objectForKeySafe:EVT_PLAY_DURATION] floatValue];
        DLog(@"视频信息%f--%f--%f",playAble,progress,duration);
        
    } else if (EvtID == PLAY_EVT_PLAY_LOADING) {
        //视频播放loading，如果能够恢复，之后会有BEGIN事件
        _videoPlayerState = ZVideoPlayerStateBuffering;
        
    } else if (EvtID == PLAY_ERR_NET_DISCONNECT){
        //网络断连,且经多次重连亦不能恢复,更多重试请自行重启播放
        _videoPlayerState = ZVideoPlayerStateFailed;
        
    } else if (EvtID == PLAY_EVT_PLAY_END) {
        //视频播放结束
        _videoPlayerState = ZVideoPlayerStateStopped;
        
    } else if (EvtID == PLAY_ERR_FILE_NOT_FOUND) {
        //文件不存在
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(videoPlayerEvent:event:param:)]) {
        [_delegate videoPlayerEvent:player event:EvtID param:param];
    }
}

//网络状态通知
- (void)onNetStatus:(TXVodPlayer *)player withParam:(NSDictionary *)param {
    
}


- (void)dealloc{
    //[PLAYER.videoPlayer stopPlay];
//    [PLAYER.videoPlayer removeVideoWidget];
    DLog(@"播放器销毁");
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
