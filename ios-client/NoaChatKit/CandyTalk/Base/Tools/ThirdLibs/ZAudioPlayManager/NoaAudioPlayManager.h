//
//  NoaAudioPlayManager.h
//  NoaKit
//
//  Created by Candy on 2023/1/28.
//

#define ZAudioPlayerTOOL [NoaAudioPlayManager shareManager]

#import <Foundation/Foundation.h>
#import "NoaMessageVoiceCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaAudioPlayManager : NSObject

@property(nonatomic, assign, readonly)BOOL isPlaying;
@property(nonatomic, weak)NoaMessageVoiceCell *currentVoiceCell;
@property(nonatomic, strong)NSString *currentAudioPath;
@property(nonatomic,assign)NSString *playMessageID;

#pragma mark - 单例的实现
+ (instancetype)shareManager;
// 单例一般不需要清空，但是在执行某些功能的时候，防止数据清空不及时可以清空一下
- (void)clearManager;

//播放本地音频文件
- (BOOL)playAudioPath:(NSString*)audioPath;
//停止播放
- (void)stop;
//扬声器模式
-(void)setAudioWaiFangSession;
//听筒模式
-(void)setAudioSession;

@end

NS_ASSUME_NONNULL_END
