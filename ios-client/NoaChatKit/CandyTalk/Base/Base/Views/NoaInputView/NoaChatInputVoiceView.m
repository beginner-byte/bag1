//
//  NoaChatInputVoiceView.m
//  NoaKit
//
//  Created by Candy on 2023/1/6.
//

#import "NoaChatInputVoiceView.h"
@interface NoaChatInputVoiceView ()

@end


@implementation NoaChatInputVoiceView

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
    self.tipLabel = [UILabel new];
    self.tipLabel.tkThemetextColors = @[HEXCOLOR(@"A9B2BE"),HEXCOLOR(@"A9B2BE")];
    self.tipLabel.text = LanguageToolMatch(@"按住说话");
    self.tipLabel.font = FONTR(16);
    self.tipLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(DWScale(16));
        make.leading.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
        make.height.mas_equalTo(DWScale(18));
    }];
    
    
    self.voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.voiceBtn setImage:ImgNamed(@"Img_chat_voice_input_normal") forState:UIControlStateNormal];
    self.voiceBtn.adjustsImageWhenHighlighted = NO;
    
    [self.voiceBtn addTarget:self
                          action:@selector(voiceEventTouchDown:withEvent:)
                forControlEvents:UIControlEventTouchDown];
    [self.voiceBtn addTarget:self
                          action:@selector(voiceEventTouchUpInside:withEvent:)
                forControlEvents:UIControlEventTouchUpInside];
    [self.voiceBtn addTarget:self action:@selector(dragMoving:withEvent:)forControlEvents:UIControlEventTouchDragInside];
    [self.voiceBtn addTarget:self
                          action:@selector(voiceEventTouchUpOutside:withEvent:)
                forControlEvents:UIControlEventTouchUpOutside];
    [self.voiceBtn addTarget:self
                          action:@selector(voiceEventTouchDragEnter:withEvent:)
                forControlEvents:UIControlEventTouchDragEnter];
    [self.voiceBtn addTarget:self
                          action:@selector(voiceEventTouchDragExit:withEvent:)
                forControlEvents:UIControlEventTouchDragExit];
    [self.voiceBtn addTarget:self
                          action:@selector(voiceEventTouchCancel:withEvent:)
                forControlEvents:UIControlEventTouchCancel];
    [self addSubview:self.voiceBtn];
    [self.voiceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.mas_equalTo(self.tipLabel.mas_bottom).offset(DWScale(30));
        make.height.width.mas_equalTo(DWScale(100));
    }];
    
}

#pragma mark - 交互事件
- (void)dragMoving:(UIControl *)c withEvent:ev
{
    if (_delegate && [_delegate respondsToSelector:@selector(dragMoving)]) {
        [_delegate dragMoving];
    }
}

- (void)dragEnded:(UIControl *)c withEvent:ev
{
    if (_delegate && [_delegate respondsToSelector:@selector(dragEnded)]) {
        [_delegate dragEnded];
    }
}

// 点击被取消，例如进入后台
- (void)voiceEventTouchCancel:(UIButton *)sender withEvent:ev{
    [self.voiceBtn setImage:ImgNamed(@"Img_chat_voice_input_normal") forState:UIControlStateNormal];
    if (_delegate && [_delegate respondsToSelector:@selector(voiceEventTouchCancel)]) {
        [_delegate voiceEventTouchCancel];
    }
}

// 按下去
- (void)voiceEventTouchDown:(UIButton *)sender withEvent:ev
{
    self.recordVoiceFinish = NO;
    [self.voiceBtn setImage:ImgNamed(@"Img_chat_voice_input_highlight") forState:UIControlStateNormal];
    if (_delegate && [_delegate respondsToSelector:@selector(voiceEventTouchDown)]) {
        [_delegate voiceEventTouchDown];
    }
}

// 从外到内
- (void)voiceEventTouchDragEnter:(UIButton *)sender withEvent:ev
{
    [self.voiceBtn setImage:ImgNamed(@"Img_chat_voice_input_highlight") forState:UIControlStateNormal];
    if (_delegate && [_delegate respondsToSelector:@selector(voiceEventTouchDragEnter)]) {
        [_delegate voiceEventTouchDragEnter];
    }
}

// 从内到外
- (void)voiceEventTouchDragExit:(UIButton *)sender withEvent:ev
{
    [self.voiceBtn setImage:ImgNamed(@"Img_chat_voice_input_disable") forState:UIControlStateNormal];
    if (_delegate && [_delegate respondsToSelector:@selector(voiceEventTouchDragExit)]) {
        [_delegate voiceEventTouchDragExit];
    }
}

// 在button感应区域之外结束点击，取消点击
- (void)voiceEventTouchUpOutside:(UIButton *)sender withEvent:ev
{
    [self.voiceBtn setImage:ImgNamed(@"Img_chat_voice_input_normal") forState:UIControlStateNormal];
    if (_delegate && [_delegate respondsToSelector:@selector(voiceEventTouchUpOutside)]) {
        [_delegate voiceEventTouchUpOutside];
    }
}

// 在button感应区域之内结束点击，成功点击
- (void)voiceEventTouchUpInside:(UIButton *)sender withEvent:ev
{
    //如果是录音不到60秒，自己松开，执行回调
    //超过60秒，自动结束发送，不执行回调
    if (!self.recordVoiceFinish) {
        self.recordVoiceFinish = YES;
        [self.voiceBtn setImage:ImgNamed(@"Img_chat_voice_input_normal") forState:UIControlStateNormal];
        if (_delegate && [_delegate respondsToSelector:@selector(voiceEventTouchUpInside)]) {
            [_delegate voiceEventTouchUpInside];
        }
    }
}


@end
