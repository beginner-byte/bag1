//
//  NoaMessageVoiceCell.m
//  NoaKit
//
//  Created by Candy on 2023/1/5.
//

#import "NoaMessageVoiceCell.h"
#import "NoaAudioPlayAnimationView.h"

@implementation NoaMessageVoiceCell
{
    UIImageView *_voicePlayImgView;
    NoaAudioPlayAnimationView *_scheduleView;
    UILabel *_voiceDuringLbl;
    UIView *_viewDot;
    UIButton *_clickBtn;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupVoiceUI];
    }
    return self;
}

#pragma mark - UI布局
- (void)setupVoiceUI {
    _scheduleView = [[NoaAudioPlayAnimationView alloc] init];
    [_scheduleView initLayers];
    [self.contentView addSubview:_scheduleView];
    
    _voicePlayImgView = [[UIImageView alloc] init];
    _voicePlayImgView.image = ImgNamed(@"icon_voice_msg_stop_left");
    //[_voicePlayBtn setImage:ImgNamed(@"icon_voice_msg_stop_left") forState:UIControlStateNormal];
    //[_voicePlayBtn addTarget:self action:@selector(voiceMsgClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_voicePlayImgView];
    [_voicePlayImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_scheduleView.mas_leading).offset(DWScale(-10));
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(DWScale(22));
        make.height.mas_equalTo(DWScale(22));
    }];
    
    _voiceDuringLbl = [[UILabel alloc] init];
    _voiceDuringLbl.text = @"";
    _voiceDuringLbl.tkThemetextColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    _voiceDuringLbl.font = FONTN(16);
    _voiceDuringLbl.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_voiceDuringLbl];
    [_voiceDuringLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_scheduleView.mas_trailing).offset(DWScale(10));
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(DWScale(30));
        make.height.mas_equalTo(DWScale(22));
    }];
    
    _clickBtn = [[UIButton alloc] init];
    _clickBtn.backgroundColor = COLOR_CLEAR;
    [_clickBtn addTarget:self action:@selector(voiceMsgClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_clickBtn];
    [_clickBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_voicePlayImgView);
        make.trailing.equalTo(_voiceDuringLbl);
        make.centerY.equalTo(self.contentView);
        make.height.mas_equalTo(DWScale(22) + 9*2);
    }];
    
    _viewDot = [UIView new];
    _viewDot.tkThemebackgroundColors = @[HEXCOLOR(@"ED6542"), HEXCOLOR(@"ED6542")];
    _viewDot.layer.cornerRadius = DWScale(3);
    _viewDot.layer.masksToBounds = YES;
    [self.contentView addSubview:_viewDot];
    [_viewDot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_scheduleView);
        make.size.mas_equalTo(CGSizeMake(DWScale(6), DWScale(6)));
        make.leading.equalTo(_voiceDuringLbl.mas_trailing).offset(DWScale(15));
    }];
}

- (void)setConfigMessage:(NoaMessageModel *)model {
    [super setConfigMessage:model];
    
    //自己发的消息
    if (model.isSelf) {
        _scheduleView.frame = CGRectMake(_contentRect.origin.x + 48, (_contentRect.size.height - DWScale(22)) / 2 + _contentRect.origin.y, _contentRect.size.width - 90, DWScale(22));
        
        [_voiceDuringLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(_scheduleView.mas_leading).offset(DWScale(-10));
            make.centerY.equalTo(_scheduleView);
            make.width.mas_equalTo(DWScale(30));
            make.height.mas_equalTo(DWScale(22));
        }];
        
        [_voicePlayImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_scheduleView.mas_trailing).offset(DWScale(10));
            make.centerY.equalTo(_scheduleView);
            make.width.mas_equalTo(DWScale(22));
            make.height.mas_equalTo(DWScale(22));
        }];
        
        [_clickBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_voiceDuringLbl);
            make.trailing.equalTo(_voicePlayImgView);
            make.centerY.equalTo(_scheduleView);
            make.height.mas_equalTo(DWScale(22) + 9*2);
        }];
        
        _voiceDuringLbl.tkThemetextColors = @[COLORWHITE, COLORWHITE];
        if (_isAnimation == YES) {
            //[_voicePlayBtn setImage:ImgNamed(@"icon_voice_msg_play_right") forState:UIControlStateNormal];
            _voicePlayImgView.image = ImgNamed(@"icon_voice_msg_play_right");
        } else {
            //[_voicePlayBtn setImage:ImgNamed(@"icon_voice_msg_stop_right") forState:UIControlStateNormal];
            _voicePlayImgView.image = ImgNamed(@"icon_voice_msg_stop_right");
        }
        
        _viewDot.hidden = YES;
    } else {
        
        //别人发送的消息
        
        _scheduleView.frame = CGRectMake(_contentRect.origin.x + DWScale(42), (_contentRect.size.height - DWScale(22)) / 2 + _contentRect.origin.y, _contentRect.size.width - DWScale(90), DWScale(22));
        
        [_voicePlayImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(_scheduleView.mas_leading).offset(-10);
            make.centerY.equalTo(_scheduleView);
            make.width.mas_equalTo(DWScale(22));
            make.height.mas_equalTo(DWScale(22));
        }];
        
        [_voiceDuringLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_scheduleView.mas_trailing).offset(10);
            make.centerY.equalTo(_scheduleView);
            make.width.mas_equalTo(DWScale(30));
            make.height.mas_equalTo(DWScale(22));
        }];
        
        [_clickBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_voicePlayImgView);
            make.trailing.equalTo(_voiceDuringLbl);
            make.centerY.equalTo(_scheduleView);
            make.height.mas_equalTo(DWScale(22) + 9*2);
        }];
        
        _voiceDuringLbl.tkThemetextColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
        if (_isAnimation == YES) {
            //[_voicePlayBtn setImage:ImgNamed(@"icon_voice_msg_play_left") forState:UIControlStateNormal];
            _voicePlayImgView.image = ImgNamed(@"icon_voice_msg_play_left");
        } else {
            //[_voicePlayBtn setImage:ImgNamed(@"icon_voice_msg_stop_left") forState:UIControlStateNormal];
            _voicePlayImgView.image = ImgNamed(@"icon_voice_msg_stop_left");
        }
        
        if (model.message.chatMessageReaded) {
            //我已读语音消息
            _viewDot.hidden = YES;
        }else {
            //我未读语音消息
            _viewDot.hidden = NO;
            [_viewDot mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_scheduleView);
                make.size.mas_equalTo(CGSizeMake(DWScale(6), DWScale(6)));
                make.leading.equalTo(_voiceDuringLbl.mas_trailing).offset(DWScale(15));
            }];
        }
    }
    
    _scheduleView.isSelfMsg = model.isSelf;
    _scheduleView.duringTime = (int)ceil(model.message.voiceLength);
    [_scheduleView initLayers];
    _voiceDuringLbl.text = [NSString stringWithFormat:@"%0.fs", ceil(model.message.voiceLength)];
    
    if (model.isShowSelectBox) {
        _clickBtn.userInteractionEnabled = NO;
    } else {
        _clickBtn.userInteractionEnabled = YES;
    }
    
    //上传回调
    [model setUploadFileSuccess:^{
        [ZTOOL doInMain:^{
            [super configMsgSendStatus:CIMChatMessageSendTypeSuccess];
        }];
       
    }];
    [model setUploadFileFail:^{
        [ZTOOL doInMain:^{
            [super configMsgSendStatus:CIMChatMessageSendTypeFail];
        }];
    }];
}

#pragma mark - Action
- (void)voiceMsgClick {
    if ([self.delegate respondsToSelector:@selector(voiceMessageClick:)]) {
        [self.delegate voiceMessageClick:self.cellIndex];
    }
}

#pragma mark - Animation
- (void)startAnimation {
    _isAnimation = YES;
    [_scheduleView startAnimation];
    if (self.messageModel.isSelf) {
        //[_voicePlayBtn setImage:ImgNamed(@"icon_voice_msg_play_right") forState:UIControlStateNormal];
        _voicePlayImgView.image = ImgNamed(@"icon_voice_msg_play_right");
    } else {
        //[_voicePlayBtn setImage:ImgNamed(@"icon_voice_msg_play_left") forState:UIControlStateNormal];
        _voicePlayImgView.image = ImgNamed(@"icon_voice_msg_play_left");
    }
    
    //更新UI，语音消息已读
    _viewDot.hidden = YES;
    
//    //我未读语音消息，播放语音消息，相当于已读
//    if (!self.messageModel.message.chatMessageReaded && !self.messageModel.isSelf) {
//        
//        //防止重复请求同一个已读接口
//        self.messageModel.message.chatMessageReaded = YES;
//        
//        //发送消息已读
//        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//        [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
//        [dict setObjectSafe:@(self.messageModel.message.chatType) forKey:@"chatType"];
//        [dict setObjectSafe:self.messageModel.message.serviceMsgID forKey:@"smsgId"];
//        [dict setObjectSafe:self.messageModel.message.fromID forKey:@"sendMsgUserUid"];
//        if (self.messageModel.message.chatType == CIMChatType_GroupChat) {
//            [dict setObjectSafe:self.messageModel.message.toID forKey:@"groupId"];
//        }
//        
//        [[LingIMSDKManager sharedTool] readedMessage:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
//            //已读的红点处理，放在接收到 我已读消息 的 系统通知 后处理，更新本地数据库消息已读状态
//        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
//            //已读失败，放到下次进来该会话后，重新调用
//        }];
//    }
}

- (void)stopAnimation {
    _isAnimation = NO;
    [_scheduleView stopAnimation];
    if (self.messageModel.isSelf) {
        //[_voicePlayBtn setImage:ImgNamed(@"icon_voice_msg_stop_right") forState:UIControlStateNormal];
        _voicePlayImgView.image = ImgNamed(@"icon_voice_msg_stop_right");
    } else {
        //[_voicePlayBtn setImage:ImgNamed(@"icon_voice_msg_stop_left") forState:UIControlStateNormal];
        _voicePlayImgView.image = ImgNamed(@"icon_voice_msg_stop_left");
    }
}

#pragma mark - Other
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
