//
//  NoaChatInputVoiceStateView.m
//  NoaKit
//
//  Created by Candy on 2023/1/10.
//

#import "NoaChatInputVoiceStateView.h"
#import "VolumeWaverView.h"
@interface NoaChatInputVoiceStateView ()
@property (nonatomic, strong) UIView *voiceStateBgLayerView;//声音背景阴影试图
@property (nonatomic, strong) UIView *voiceStateBgView;//声音背景试图
@property (nonatomic, strong) UILabel *stateLabel;//底部状态试图
@property (nonatomic, strong) VolumeWaverView *waveView;//波浪视图

@end

@implementation NoaChatInputVoiceStateView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        
        [self setupUI];
        
    }
    return self;
}

#pragma mark - 界面布局
- (void)setupUI {
    self.voiceStateBgLayerView = [[UIView alloc] init];
    self.voiceStateBgLayerView.backgroundColor = [UIColor clearColor];
    self.voiceStateBgLayerView.layer.shadowColor = HEXCOLOR(@"4791FF").CGColor;
    self.voiceStateBgLayerView.layer.shadowOffset = CGSizeMake(0, 0); // 阴影偏移量，默认（0,0）
    self.voiceStateBgLayerView.layer.shadowOpacity = 0.4; // 不透明度
    self.voiceStateBgLayerView.layer.shadowRadius = 5;
    [self addSubview:self.voiceStateBgLayerView];
    [self.voiceStateBgLayerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(DWScale(30));
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo(DWScale(160));
        make.height.mas_equalTo(DWScale(60));
    }];
    
    self.voiceStateBgView = [[UIView alloc] init];
    self.voiceStateBgView.tkThemebackgroundColors = @[HEXCOLOR(@"4791FF"), HEXCOLOR(@"4791FF")];
    self.voiceStateBgView.layer.cornerRadius = DWScale(16);
    [self.voiceStateBgLayerView addSubview:self.voiceStateBgView];
    [self.voiceStateBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.trailing.mas_equalTo(DWScale(0));
    }];

    UIImageView * micImgView = [[UIImageView alloc] init];
    micImgView.image = ImgNamed(@"Img_chat_voice_input_mic");
    [self.voiceStateBgView addSubview:micImgView];
    [micImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(DWScale(15.5));
        make.leading.mas_equalTo(DWScale(19));
        make.width.mas_equalTo(DWScale(20));
        make.height.mas_equalTo(DWScale(20));
    }];
    
    self.waveView = [[VolumeWaverView alloc] initWithFrame:CGRectZero andType:VolumeWaverType_Bar];
    [self.voiceStateBgView addSubview:self.waveView];
    [self.waveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.centerY.mas_equalTo(micImgView);
        make.width.mas_equalTo(DWScale(44));
        make.height.mas_equalTo(DWScale(17));
    }];
    
    self.timeLabel = [UILabel new];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.font = FONTR(DWScale(16));
    [self.voiceStateBgView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.waveView);
        make.trailing.mas_equalTo(self.voiceStateBgView.mas_trailing).offset(-DWScale(16));
        make.height.mas_equalTo(DWScale(22));
    }];

    self.stateLabel = [UILabel new];
    self.stateLabel.textColor = [UIColor whiteColor];
    self.stateLabel.font = FONTR(DWScale(10));
    self.stateLabel.text = LanguageToolMatch(@"上滑取消发送");
    [self.voiceStateBgView addSubview:self.stateLabel];
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(self.voiceStateBgView.mas_bottom).offset(-DWScale(5));
        make.height.mas_equalTo(DWScale(14));
    }];
}

- (void)updateViewState:(InputVoiceStateType)stateType{
    if(stateType == InputVoiceStateSend){
        self.voiceStateBgLayerView.layer.shadowColor = HEXCOLOR(@"4791FF").CGColor;
        self.voiceStateBgView.tkThemebackgroundColors = @[HEXCOLOR(@"4791FF"), HEXCOLOR(@"4791FF")];
        self.stateLabel.text = LanguageToolMatch(@"上滑取消发送");
    }else{
        self.voiceStateBgLayerView.layer.shadowColor = HEXCOLOR(@"FF8B7B").CGColor;
        self.voiceStateBgView.tkThemebackgroundColors = @[HEXCOLOR(@"FB5161"), HEXCOLOR(@"FB5161")];
        self.stateLabel.text = LanguageToolMatch(@"松开取消发送");
    }
}

@end
