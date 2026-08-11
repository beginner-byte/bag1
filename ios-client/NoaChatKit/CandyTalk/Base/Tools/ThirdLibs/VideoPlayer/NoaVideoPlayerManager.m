//
//  NoaVideoPlayerManager.m
//  NoaKit
//
//  Created by Candy on 2026/9/24.
//

#import "NoaVideoPlayerManager.h"

@implementation NoaVideoPlayerManager

+ (instancetype)sharedManager{
    static NoaVideoPlayerManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /*
         不能再使用alloc方法
         因为已经重写了allocWithZone方法，所以这里要调用父类的分配空间的方法
         */
        manager = [[super allocWithZone:NULL] init];
        
    });
    
    return manager;
}

// 防止外部调用alloc 或者 new
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [NoaVideoPlayerManager sharedManager];
}

// 防止外部调用copy
- (id)copyWithZone:(nullable NSZone *)zone {
    return [NoaVideoPlayerManager sharedManager];
}

// 防止外部调用mutableCopy
- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [NoaVideoPlayerManager sharedManager];
}

- (instancetype)init {
    if (self == [super init]) {
        // 初始化代码
    }
    return self;
}

#pragma mark - 获取视频缓存位置
- (NSString *)getVideoCachePath{
    NSString *videoCachePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"video/videoCache"]];
    NSFileManager *fileManager  = [NSFileManager defaultManager];
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory 判断是否一个目录
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:videoCachePath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES)) {
        //在Document目录下创建一个drafts目录
        [fileManager createDirectoryAtPath:videoCachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return videoCachePath;
}

#pragma mark - 懒加载
- (TXVodPlayer *)videoPlayer {
    if (!_videoPlayer) {
        
        //基本配置
        TXVodPlayConfig *config = [TXVodPlayConfig new];
        config.playerType = PLAYER_FFPLAY;
        config.cacheFolderPath = [self getVideoCachePath];
        config.maxCacheItems = 10;
        config.enableAccurateSeek = YES;
        config.autoRotate = NO;
        config.progressInterval = 0.1;
        config.smoothSwitchBitrate = NO;
        
        //创建播放器
        _videoPlayer = [TXVodPlayer new];
        _videoPlayer.enableHWAcceleration = YES;
        [_videoPlayer setRenderMode:RENDER_MODE_FILL_EDGE];
        [_videoPlayer setConfig:config];
        
    }
    return _videoPlayer;
}

@end
