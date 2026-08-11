//
//  NoaMediaCallMoreFloatView.m
//  NoaKit
//
//  Created by Candy on 2023/2/8.
//

#import "NoaMediaCallMoreFloatView.h"
#import "NoaMediaCallManager.h"
#import "NoaToolManager.h"

@interface NoaMediaCallMoreFloatView () <ZMediaCallManagerDelegate>
@property (nonatomic, strong) UIView *viewContent;
@property (nonatomic, strong) UIImageView *ivCallState;
@property (nonatomic, strong) UILabel *lblCallTip;
@end

@implementation NoaMediaCallMoreFloatView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = UIColor.clearColor;
        
        [self setupUI];
        [self updateUIWithRoomState];
        
        [NoaMediaCallManager sharedManager].delegate = self;
        
        //监听关闭UI
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaCallRoomCancel) name:CALLROOMCANCEL object:nil];
        
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    self.layer.cornerRadius = DWScale(16);
    self.layer.masksToBounds = YES;
    
    UIView *viewLayerBg = [UIView new];
    viewLayerBg.backgroundColor = [UIColor clearColor];
    viewLayerBg.layer.shadowColor = [UIColor blackColor].CGColor;
    viewLayerBg.layer.shadowOffset = CGSizeMake(0, 0); // 阴影偏移量，默认（0,0）
    viewLayerBg.layer.shadowOpacity = 0.1; // 不透明度
    viewLayerBg.layer.shadowRadius = 5;
    [self addSubview:viewLayerBg];
    [viewLayerBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(self).offset(DWScale(3));
        make.trailing.bottom.equalTo(self).offset(-DWScale(3));
    }];
    
    _viewContent = [UIView new];
    _viewContent.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    _viewContent.layer.cornerRadius = DWScale(16);
    _viewContent.layer.masksToBounds = YES;
    [viewLayerBg addSubview:_viewContent];
    [_viewContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(viewLayerBg);
    }];
    
    
    _ivCallState = [UIImageView new];
    [_viewContent addSubview:_ivCallState];
    [_ivCallState mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_viewContent);
        make.top.equalTo(_viewContent).offset(DWScale(27));
    }];
    
    _lblCallTip = [UILabel new];
    _lblCallTip.font = FONTR(12);
    _lblCallTip.textColor = COLOR_5966F2;
    _lblCallTip.preferredMaxLayoutWidth = DWScale(90);
    [_viewContent addSubview:_lblCallTip];
    [_lblCallTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_viewContent);
        make.top.equalTo(_ivCallState.mas_bottom).offset(DWScale(11));
    }];
    
}
- (void)updateUIWithRoomState {
    NoaMediaCallOptions *currentCallOptions = [NoaMediaCallManager sharedManager].currentCallOptions;
    
    switch (currentCallOptions.callType) {
        case LingIMCallTypeAudio:
        {
            //音频
            _ivCallState.image = ImgNamed(@"ms_btn_accept_s");
            if ([NoaMediaCallManager sharedManager].currentRoomCalling) {
                //正在通话中
                _lblCallTip.text = [NSString getTimeLengthHMS:currentCallOptions.callDuration];
            }else {
                _lblCallTip.text = LanguageToolMatch(@"等待接通");
            }
        }
            break;
        case LingIMCallTypeVideo:
        {
            //视频
            _ivCallState.image = ImgNamed(@"ms_btn_video_accept_s");
            if ([NoaMediaCallManager sharedManager].currentRoomCalling) {
                //正在通话中
                _lblCallTip.text = [NSString getTimeLengthHMS:currentCallOptions.callDuration];
            }else {
                _lblCallTip.text = LanguageToolMatch(@"等待接通");
            }
            
        }
            break;
            
        default:
            break;
    }

}

#pragma mark - 通知监听处理
//通话结束
- (void)mediaCallRoomCancel {
    NoaMediaCallOptions *currentCallOptions = [NoaMediaCallManager sharedManager].currentCallOptions;
    
    //通话取消结束
    _lblCallTip.textColor = HEXCOLOR(@"ED6542");
    _lblCallTip.text = LanguageToolMatch(@"通话结束");
    
    switch (currentCallOptions.callType) {
        case LingIMCallTypeAudio:
        {
            _ivCallState.image = ImgNamed(@"ms_btn_cancel_s");
        }
            break;
        case LingIMCallTypeVideo:
        {
            _ivCallState.image = ImgNamed(@"ms_btn_video_cancel_s");
        }
            break;
            
        default:
            break;
    }
}
#pragma mark - ZMediaCallManagerDelegate
- (void)mediaCallCurrentDuration:(NSInteger)duration {
    if (duration > 0) {
        _lblCallTip.text = [NSString getTimeLengthHMS:duration];
    }
}

#pragma mark - 界面销毁
- (void)dealloc {
    DLog(@"音视频通话-多人-浮窗销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
