//
//  NoaMediaCallSampleVideoView.m
//  NoaKit
//
//  Created by Candy on 2023/5/30.
//

#import "NoaMediaCallSampleVideoView.h"
#import "NoaToolManager.h"
#import "NoaCallManager.h"


@implementation NoaMediaCallSampleVideoView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        WeakSelf
        [ZTOOL doInMain:^{
            [weakSelf setupUI];
        }];
    }
    return self;
}

#pragma mark - 界面布局
- (void)setupUI {
    if ([NoaCallManager sharedManager].callSDKType == LingIMCallSDKTypeZego) {
        //即构音视频通话
        _viewVideoZG = [UIView new];
        [self addSubview:_viewVideoZG];
        [_viewVideoZG mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    } else {
        //LiveKit音视频通话
        _viewVideo = [VideoView new];
        [self addSubview:_viewVideo];
        [_viewVideo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
