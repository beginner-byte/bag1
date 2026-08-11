//
//  NoaAudioPlayManager.m
//  NoaKit
//
//  Created by Candy on 2023/1/28.
//

#import "NoaAudioPlayManager.h"
#import <AVFoundation/AVFoundation.h>

static dispatch_once_t onceToken;

@interface NoaAudioPlayManager () <AVAudioPlayerDelegate>

@property(nonatomic, strong)AVAudioPlayer *player;
@property(nonatomic, strong)NSString *playPath;

@end

@implementation NoaAudioPlayManager

#pragma mark - 单例的实现
+ (instancetype)shareManager{
    static NoaAudioPlayManager *_manager = nil;
    dispatch_once(&onceToken, ^{
        //不能再使用alloc方法
        //因为已经重写了allocWithZone方法，所以这里要调用父类的分配空间的方法
        _manager = [[super allocWithZone:NULL] init];
    });
    return _manager;
}
// 防止外部调用alloc 或者 new
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [NoaAudioPlayManager shareManager];
}

// 防止外部调用copy
- (id)copyWithZone:(nullable NSZone *)zone {
    return [NoaAudioPlayManager shareManager];
}

// 防止外部调用mutableCopy
- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [NoaAudioPlayManager shareManager];
}
#pragma mark - 单例一般不需要清空，但是在执行某些功能的时候，防止数据清空不及时可以清空一下
- (void)clearManager{
    onceToken = 0;
}

#pragma mark - Function

//音频格式转换
//- (int)amrToWav:(NSString*)amrPath {
//    return [VoiceConverterHander convertAmrToWav:amrPath wavSavePath:self.playPath];
//}

//听筒模式
-(void)setAudioSession{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
}

//扬声器模式
-(void)setAudioWaiFangSession
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //设置为播放
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
}

- (BOOL)playAudioPath:(NSString *)audioPath {
    if (_player) {
        [self stop];
        _player = nil;
    }
    self.playPath = audioPath;
    
    NSError *error;
    NSURL *audioUrl = [NSURL URLWithString:self.playPath];
    _player = [[AVAudioPlayer alloc]initWithContentsOfURL:audioUrl error:&error];
    if (error) {
        NSLog(@"播放音频失败！ Error : %@", error);
    }
    _player.delegate = self;
    _player.volume = 1.0f;
    [_player prepareToPlay];
    return [_player play];
}

- (void)stop {
    if (self.isPlaying) {
        [_player stop];
        _player = nil;
    }
}

//停止对应cell的动画
- (void)stopCellAnimation {
    if (_currentVoiceCell) {
        [_currentVoiceCell stopAnimation];
    }
    _playMessageID = @"";
    _playPath = @"";
}

- (BOOL)isPlaying {
    if (_player) {
        return _player.isPlaying;
    }
    return NO;
}

#pragma mark AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer*)player successfully:(BOOL)flag {
    DLog(@"音频播放完成");
    [self stopCellAnimation];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer*)player error:(NSError*)error {
    DLog(@"音频播放失败！ Error : %@", error);
    [self stopCellAnimation];
}


@end
