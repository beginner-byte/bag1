//
//  NoaMediaCallSampleVideoView.h
//  NoaKit
//
//  Created by Candy on 2023/5/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaMediaCallSampleVideoView : UIView

@property (nonatomic, strong) VideoView *viewVideo;//视频通话渲染 LiveKit
@property (nonatomic, strong) UIView *viewVideoZG;//视频通话渲染 ZEGO

@end

NS_ASSUME_NONNULL_END
