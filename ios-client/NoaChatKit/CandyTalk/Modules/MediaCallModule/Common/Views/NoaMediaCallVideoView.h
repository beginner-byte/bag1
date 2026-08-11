//
//  NoaMediaCallVideoView.h
//  NoaKit
//
//  Created by Candy on 2023/1/29.
//

#import <UIKit/UIKit.h>
#import "NoaBaseImageView.h"
#import "NoaMediaCallSampleVideoView.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaMediaCallVideoView : UIView

@property (nonatomic, strong) VideoView *viewVideo;//视频通话渲染 LiveKit
@property (nonatomic, strong) NoaMediaCallSampleVideoView *sampleViewVideo;//视频通话 视频轨道渲染

@property (nonatomic, strong) NoaBaseImageView *ivHeader;

//更新头像的大小
- (void)updateHeaderSizeWith:(CGFloat)headerW;
//是否显示头像
- (void)showHeaderWith:(BOOL)show;
@end

NS_ASSUME_NONNULL_END
