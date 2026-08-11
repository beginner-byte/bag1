//
//  NoaMediaCallVideoView.m
//  NoaKit
//
//  Created by Candy on 2023/1/29.
//

#import "NoaMediaCallVideoView.h"
#import "NoaToolManager.h"
#import "NoaCallManager.h"

@interface NoaMediaCallVideoView ()

@end

@implementation NoaMediaCallVideoView

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
    self.tkThemebackgroundColors = @[COLOR_11, COLOR_11_DARK];
    
    _viewVideo = [VideoView new];
    _viewVideo.hidden = YES;
    [self addSubview:_viewVideo];
    [_viewVideo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    _sampleViewVideo = [NoaMediaCallSampleVideoView new];
    [self addSubview:_sampleViewVideo];
    [_sampleViewVideo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    _ivHeader = [[NoaBaseImageView alloc] initWithImage:DefaultAvatar];
    _ivHeader.layer.cornerRadius = DWScale(24);
    _ivHeader.layer.masksToBounds = YES;
    _ivHeader.hidden = NO;
    [self addSubview:_ivHeader];
    [_ivHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(DWScale(48), DWScale(48)));
    }];
    
}

#pragma mark - 更新头像大小
- (void)updateHeaderSizeWith:(CGFloat)headerW {
    _ivHeader.layer.cornerRadius = headerW / 2.0;
    _ivHeader.layer.masksToBounds = YES;
    [_ivHeader mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(headerW, headerW));
    }];
}
#pragma mark - 是否显示头像
- (void)showHeaderWith:(BOOL)show {
    WeakSelf
    [ZTOOL doInMain:^{
        weakSelf.ivHeader.hidden = !show;
        
        if ([NoaCallManager sharedManager].callSDKType == LingIMCallSDKTypeZego) {
            //即构
            weakSelf.sampleViewVideo.hidden = show;
        }else {
            //LiveKit
            weakSelf.viewVideo.hidden = show;
        }
        
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
