//
//  NoaVideoPlayerManager.h
//  NoaKit
//
//  Created by Candy on 2026/9/24.
//

// 视频播放器 Manager

#define PLAYER [NoaVideoPlayerManager sharedManager]

#import <Foundation/Foundation.h>
#import <TXLiteAVSDK.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZVideoPlayerState) {
    ZVideoPlayerStateFailed = 0,      //视频播放失败
    ZVideoPlayerStateBuffering = 1,   //缓冲中
    ZVideoPlayerStatePlaying = 2,     //播放中
    ZVideoPlayerStateStopped = 3,     //停止播放
    ZVideoPlayerStatePause = 4        //暂停播放
};

@interface NoaVideoPlayerManager : NSObject
+ (instancetype)sharedManager;

//点播播放器
@property (nonatomic, strong) TXVodPlayer *videoPlayer;
//播放器状态
@property (nonatomic, assign) ZVideoPlayerState playerState;
//当前正在播放视频的cell
@property (nonatomic) UITableViewCell * _Nullable videoPlayingCell;

@end

NS_ASSUME_NONNULL_END
