//
//  NoaBaseVideoPlayerView.h
//  NoaKit
//
//  Created by Candy on 2026/9/24.
//

#import <UIKit/UIKit.h>
#import "NoaVideoPlayerManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZBaseVideoPlayerDelegate <NSObject>
- (void)videoPlayerEvent:(TXVodPlayer *)player event:(NSInteger)eventID param:(NSDictionary *)param;
@end

@interface NoaBaseVideoPlayerView : UIView <TXVodPlayListener>

@property (nonatomic, weak) id <ZBaseVideoPlayerDelegate> delegate;

//url播放
@property (nonatomic, copy) NSString *videoUrl;
//fileID播放(如果使用了腾讯云存储)
@property (nonatomic, copy) NSString *fileID;

//视频基本配置
@property (nonatomic, assign) TX_Enum_Type_RenderMode renderMode;//视频铺满/适应
@property (nonatomic, assign) TX_Enum_Type_HomeOrientation rotation;//画面旋转
@property (nonatomic, copy) TXVodPlayConfig *playerConfig;//播放器配置参数

//播放控制
@property (nonatomic, assign) CGFloat sliderValue;//播放进度
@property (nonatomic, assign) CGFloat startTime;//指定开始播放位置
@property (nonatomic, assign) BOOL isAutoPlay;//startPlay后是否立即播放，默认YES
@property (nonatomic, assign) BOOL isMute;//是否静音
@property (nonatomic, assign) BOOL isLoop;//是否循环播放
@property (nonatomic, assign) BOOL isPlaying;//是否正在播放
@property (nonatomic, assign) ZVideoPlayerState videoPlayerState;//播放器状态

//方法事件
- (void)startPlay;//开始播放
- (void)pausePlay;//暂停播放
- (void)resumePlay;//继续播放
- (void)stopPlay;//停止播放
- (void)deallocPlayer;//销毁播放器
//停止播放时，如果要退出当前的UI界面，要记得用removeVideoWidget销毁view控件，否则会产生内存泄漏或闪屏问题

@end

NS_ASSUME_NONNULL_END
