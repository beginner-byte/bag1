//
//  RecordManager.m
//  VoiceWaver_Demo
//
//  Created by MrYeL on 2018/7/24.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import "RecordManager.h"
#import "NSString+Addition.h"
#import "NoaLameTool.h"
static RecordManager *shareRecord = nil;

@interface RecordManager ()<AVAudioRecorderDelegate>

/** 倒计时*/
@property (nonatomic, strong) NSTimer * countTimer;

/** 倒计时数量*/
@property (nonatomic, assign) int count;

/** 语音文件暂存地址地址*/
@property (nonatomic, copy) NSString * cacheFilePath;

// 允许转码
@property (nonatomic, assign) BOOL enableEncode;

@end

@implementation RecordManager
#pragma mark - lazyLoad
- (NSTimer *)timer {
    if (!_timer) {
        CGFloat time = self.updateFequency;
        if (self.type == RecordValuePostType_FullCount) {
          time = self.updateFequency /self.soundMeterCount;
        }
        _timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (NSTimer *)countTimer {
    if(!_countTimer){
        _countTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    }
    return _countTimer;
}

- (NSMutableArray *)soundMeters {
    if (!_soundMeters) {
        _soundMeters = [NSMutableArray new];
    }
    return _soundMeters;
}

- (NSURL *)cacheUrl {
    NSURL *url =  [NSURL fileURLWithPath:self.cacheFilePath];
    DLog(@"filePath:\n%@", _cacheFilePath);
    return url;
}

- (NSString *)voiceName {
    if([NSString isNil:_voiceName]){
        NSString *fileName = [[NSString alloc] initWithFormat:@"%@_%lld.mp3", UserManager.userInfo.userUID, [NSDate currentTimeIntervalWithMillisecond]];
        _voiceName = fileName;
    }
    DLog(@"_voiceName %@", _voiceName);
    return _voiceName;
}

- (NSString *)voiceFilePath {
    NSString *fileName = self.voiceName;
    // 将音频转移放入沙盒目录下
    NSString *folderPath = [NSString getVoiceDiectoryWithCustomPath:[NSString stringWithFormat:@"%@-ChatSession", UserManager.userInfo.userUID]];
    NSString *voicePath = [NSString stringWithFormat:@"%@/%@", folderPath, fileName];
    _voiceFilePath = voicePath;
    return _voiceFilePath;
}

- (instancetype)initWithSessionID:(NSString *)sessionId {
    self = [super init];
    if (self) {
        self.sessionID = sessionId;
        [self initial];
    }
    return self;
}

#pragma mark - Config
/** 初始化默认值*/
- (void)initial {
    self.soundMeterCount = 3;
    self.updateFequency = 0.25;
    self.maxSecond = 60;
    self.count = self.maxSecond;
    self.type = RecordValuePostType_FullCount;
}

/// 配置录音文件路径
- (void)configureCachePath {
    // 创建日期格式化器
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    // 设置日期格式 (24小时制使用大写 HH)
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    // 设置时区（通常使用系统时区）
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];

    // 当前日期
    NSDate *currentDate = [NSDate date];

    // 转换为字符串
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    
    // 文件路径
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    self.cacheFilePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"cache_voice_%@.pcm", dateString]];
}

/// 配置record（开启录音=时调用）
- (void)configRecord {
    [self configureCachePath];
    
    //判断是否可用
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session requestRecordPermission:^(BOOL granted) {
        if (!granted) {
            /// 录音权限未开启
            return;
        }
        
        // 录音权限已开启，配置音频对象
        [self configureAudioSession];
    }];
}

/// 配置录音
- (void)configureAudioSession {
    // 如果之前有创建录音对象，先释放，等下方重新创建(需要更改录音文件地址，必须要重新创建)
    if (_recorder) {
        _recorder = nil;
    }
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    if( [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&sessionError]){
        DLog(@"session config Succeed");
        
        // 2. PCM 录音设置
        NSDictionary *pcmSettings = @{
            // 设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
            AVFormatIDKey: @(kAudioFormatLinearPCM),
            // 录音的质量
            AVEncoderAudioQualityKey: @(AVAudioQualityMedium),
            // 设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）,
            AVSampleRateKey: @44100.0,
            // 录音通道数  1 或 2 ，要转换成mp3格式必须为双通道 : 音轨
            AVNumberOfChannelsKey: @2,
            // 线性采样位数  8、16、24、32
            AVLinearPCMBitDepthKey: @16,
//            AVLinearPCMIsBigEndianKey: @NO,
//            AVLinearPCMIsFloatKey: @NO
        };
        
        NSError *recorderError;
        NSURL *url = [self cacheUrl];
        self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:pcmSettings error:&recorderError];
        if (recorderError) {
            [HUD showMessage:LanguageToolMatch(@"录音组件初始化失败！")];
            NSMutableDictionary *loganDict = [NSMutableDictionary dictionary];
            [loganDict setObject:[NSString stringWithFormat:@"录音初始化失败: %@",recorderError.localizedDescription] forKey:@"recordVocieFail"];//失败原因
            [IMSDKManager imSdkWriteLoganWith:LingIMLoganTypeApi loganContent:[[NoaIMLoganManager sharedManager] configLoganContent:loganDict]];

            return;
        }
        self.recorder.delegate = self;
        [self.recorder setMeteringEnabled:YES];
        // 开始录音
        [session setActive:YES error:nil];
    } else {
        DLog(@"session config failed");
        NSMutableDictionary *loganDict = [NSMutableDictionary dictionary];
        [loganDict setObject:@"录音初始化失败: session config failed" forKey:@"recordVocieFail"];
        [IMSDKManager imSdkWriteLoganWith:LingIMLoganTypeApi loganContent:[[NoaIMLoganManager sharedManager] configLoganContent:loganDict]];

    }
}


- (long long)fileSizeAtPath:(NSString*)filePath{
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

// 音频格式转换caf转为mp3
- (void)voiceCafToMp3{
    //语音存放文件夹地址
    NSString *folderPath = [NSString getVoiceDiectoryWithCustomPath:[NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, self.sessionID]];
    // 判断文件夹是否存在
    if(![[NSFileManager defaultManager] fileExistsAtPath:folderPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    NSString *desPathStr = self.voiceFilePath;
    DLog(@"des pathStr%@", desPathStr);

    NSString *srcPath = self.cacheFilePath;

    if([[NSFileManager defaultManager] fileExistsAtPath:srcPath]){
        WeakSelf
        
        long size = [self fileSizeAtPath:srcPath];
        NSLog(@"文件大小： %ld", size);
        
        /// 将pcm文件转换为mp3文件
        [NoaLameTool conventToMp3WithCafFilePath:srcPath mp3FilePath:desPathStr callback:^(BOOL result) {
            StrongSelf
            if (srcPath) {
                // 删除录音文件(pcm临时文件)
                [[NSFileManager defaultManager] removeItemAtPath:srcPath error:nil];
                // 移除缓存路径文件
                strongSelf.cacheFilePath = nil;
            }
           
            if (result) {
                if (strongSelf.conventFinish) {
                    strongSelf.conventFinish();
                }
            } else {
                [HUD showMessage:LanguageToolMatch(@"录音出错了，请稍后再试！")];
            }
        }];
    } else {
        // 录音文件保存本地沙盒失败
        NSMutableDictionary *loganDict = [NSMutableDictionary dictionary];
        [loganDict setObject:@"录音文件未成功保存本地" forKey:@"recordVocieFail"];//失败原因
        [IMSDKManager imSdkWriteLoganWith:LingIMLoganTypeApi loganContent:[[NoaIMLoganManager sharedManager] configLoganContent:loganDict]];

    }
}

#pragma mark - Method Action
- (void)startRecord {
    [self configRecord];
    self.enableEncode = NO;
    self.count = self.maxSecond;
    self.voiceName = @"";
    self.recordTime = 0;
    [self.recorder prepareToRecord];
    [self.recorder record];
    [self.timer setFireDate:[NSDate distantPast]];
    [self.countTimer setFireDate:[NSDate distantPast]];
}

/// 取消录音
- (void)cancelRecord {
    [self stopRecord];
    
    // 释放录音对象
    self.recorder = nil;
    
    if (self.cacheFilePath) {
        // 删除pcm临时文件
        [[NSFileManager defaultManager] removeItemAtPath:self.cacheFilePath error:nil];
        
        // 移除pcm临时文件路径
        self.cacheFilePath = nil;
    }
}

- (void)finishRecord {
    self.enableEncode = YES;
    [self stopRecord];
}

- (void)stopRecord {
    [self.timer invalidate];
    self.timer = nil;
    
    [self.countTimer invalidate];
    self.countTimer = nil;
    
    [self.recorder stop];
    
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

#pragma mark -  Timmer
- (void)updateMeters {
    
    [self.recorder updateMeters];
    if (self.type == RecordValuePostType_FullTime) {
        self.recordTime += self.updateFequency;
    } else {
        self.recordTime += (self.updateFequency/self.soundMeterCount);
    }
    
    float decibels = [self.recorder averagePowerForChannel:0];
    [self addSoundMeter:decibels];
    
    if (self.recordTime >= self.maxSecond) {
        // end
        [self finishRecord];
    }
}

- (void)addSoundMeter:(CGFloat)itemValue {
    
    if (self.soundMeters.count > self.soundMeterCount - 1) {
        
        if (self.type == RecordValuePostType_FullCount) {
            [self.soundMeters removeAllObjects];
        } else {
            [self.soundMeters removeObjectAtIndex:0];
        }
    }

    [self.soundMeters addObject:@(itemValue)];

    if (self.type == RecordValuePostType_FullTime) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMeters" object:self.soundMeters];

    } else {
        if (self.soundMeters.count == self.soundMeterCount) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMeters" object:self.soundMeters];
        }
    }
}

#pragma mark - 倒计时
- (void)timerFired:(NSTimer *)timer {
    _count--;
    if (self.returnTime) {
        self.returnTime(timer,_count);
    }
}

#pragma mark AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (flag) {
        if (self.enableEncode) {
            [self voiceCafToMp3];
        }
        
    } else {
        NSLog(@"录音结束---但是出错了");
    }
    self.enableEncode = NO;
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error {
    NSString *errorString = [NSString stringWithFormat:@"录音报错了，audioRecorderEncodeErrorDidOccur - %@", error.localizedDescription];
    NSMutableDictionary *loganDict = [NSMutableDictionary dictionary];
    [loganDict setObject:errorString forKey:@"recordVocieFail"];//失败原因
    [IMSDKManager imSdkWriteLoganWith:LingIMLoganTypeApi loganContent:[[NoaIMLoganManager sharedManager] configLoganContent:loganDict]];

}

@end
