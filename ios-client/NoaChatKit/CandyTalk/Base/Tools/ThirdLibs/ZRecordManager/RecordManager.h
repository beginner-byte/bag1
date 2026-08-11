//
//  RecordManager.h
//  VoiceWaver_Demo
//
//  Created by MrYeL on 2018/7/24.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, RecordValuePostType){
    
    RecordValuePostType_FullCount,//满个数传：跳动均衡器传此值
    RecordValuePostType_FullTime,//满时间传：单位时间, 移动视图下传此值
};

//计时回调
typedef void (^ReturnTimeCount)(NSTimer *timer,int second);

typedef void (^conventFormatFinish)(void);

@interface RecordManager : NSObject

/** AVAudioRecorder*/
@property (nonatomic, strong) AVAudioRecorder * recorder;
/** 最大录音时间(秒)s:*/
@property (nonatomic, assign) int maxSecond;
/** timer录音计时器*/
@property (nonatomic, strong) NSTimer * timer;
/** recordTime录音时间*/
@property (nonatomic, assign) CGFloat recordTime;
/** updateFequency波形更新间隔*/
@property (nonatomic, assign) CGFloat updateFequency;

/** soundMeterCount声音数据数组容量*/
@property (nonatomic, assign) NSInteger soundMeterCount;
/** soundMeters声音数据数组*/
@property (nonatomic, strong) NSMutableArray * soundMeters;

/**当前聊天ID*/
@property (nonatomic, copy) NSString * sessionID;
/** 语音存放地址*/
@property (nonatomic, copy) NSString * voiceFilePath;
/** 语音在文件中的名称*/
@property (nonatomic, copy) NSString * voiceName;
/** 倒计时回调*/
@property (nonatomic, copy) ReturnTimeCount returnTime;
/** caf格式转换为mp3格式完成回调*/
@property (nonatomic, copy) conventFormatFinish conventFinish;

/** 传值类型: 默认满个数传*/
@property (nonatomic, assign) RecordValuePostType type;


//初始化操作
- (instancetype)initWithSessionID:(NSString *)sessionId;

#pragma mark - Method Action

/** 启动/继续*/
- (void)startRecord;
/** 完成录音*/
- (void)finishRecord;
/** 取消(删除)*/
- (void)cancelRecord;



@end
