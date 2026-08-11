//
//  NoaChatInputReferenceView.m
//  NoaKit
//
//  Created by Candy on 2026/9/27.
//

#import "NoaChatInputReferenceView.h"

@interface NoaChatInputReferenceView ()
@property (nonatomic, strong) UILabel *lblReferenceUser;//应用消息来源人
@property (nonatomic, strong) UILabel *lblReference;//引用消息内容
@property (nonatomic, strong) UIButton *btnClose;//删除引用消息
@end


@implementation NoaChatInputReferenceView
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
    UIImageView *ivReference = [[UIImageView alloc] initWithImage:ImgNamed(@"c_input_share")];
    ivReference.frame = CGRectMake(DWScale(16), DWScale(20), DWScale(22), DWScale(22));
    [self addSubview:ivReference];
    
    _lblReferenceUser = [UILabel new];
    _lblReferenceUser.textColor = COLOR_5966F2;
    _lblReferenceUser.text = LanguageToolMatch(@"引用：");
    _lblReferenceUser.font = FONTR(16);
    [self addSubview:_lblReferenceUser];
    [_lblReferenceUser mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(DWScale(48));
        make.top.equalTo(self).offset(DWScale(10));
        make.trailing.equalTo(self).offset(-DWScale(48));
        make.height.mas_equalTo(DWScale(22));
    }];
    
    _lblReference = [UILabel new];
    _lblReference.text = @"引用消息内容(纯文本，[视频]，[图片]，[语音]，[文件]等)";
    _lblReference.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    _lblReference.font = FONTR(12);
    _lblReference.numberOfLines = 1;
    [self addSubview:_lblReference];
    [_lblReference mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(_lblReferenceUser);
        make.height.mas_equalTo(DWScale(20));
        make.bottom.equalTo(self).offset(-DWScale(10));
    }];
    
    _btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnClose setTkThemeImage:@[ImgNamed(@"icon_chat_refresh_close"), ImgNamed(@"icon_chat_refresh_close_dark")] forState:UIControlStateNormal];
    [_btnClose addTarget:self action:@selector(btnCloseClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btnClose];
    [_btnClose mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.trailing.equalTo(self).offset(-DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(22), DWScale(22)));
    }];
    
}

#pragma mark - Data
- (void)setReferenceMsgModel:(NoaMessageModel *)referenceMsgModel {
    _referenceMsgModel = referenceMsgModel;
    
    //UI赋值
    _lblReferenceUser.text = [NSString stringWithFormat:@"%@%@", LanguageToolMatch(@"引用："),  _referenceMsgModel.message.fromNickname];
    if (_referenceMsgModel.message.messageType == CIMChatMessageType_TextMessage) {
        //引用文本
        if ([NSString isNil:_referenceMsgModel.message.translateContent]) {
            //译文为空
            _lblReference.text = _referenceMsgModel.message.textContent;
        } else {
            //有译文
            if (_referenceMsgModel.isSelf) {
                _lblReference.text = _referenceMsgModel.message.textContent;
            } else {
                _lblReference.text = _referenceMsgModel.message.translateContent;
            }
        }
        
    }  else if (_referenceMsgModel.message.messageType == CIMChatMessageType_AtMessage) {
        //引用At消息
        _lblReference.text =_referenceMsgModel.message.showContent == nil ? @"" : _referenceMsgModel.message.showContent;
    } else if (_referenceMsgModel.message.messageType == CIMChatMessageType_ImageMessage) {
        //引用图片
        _lblReference.text = LanguageToolMatch(@"[图片]");
    } else if (_referenceMsgModel.message.messageType == CIMChatMessageType_VideoMessage) {
        //引用视频
        _lblReference.text = LanguageToolMatch(@"[视频]");
    } else if (_referenceMsgModel.message.messageType == CIMChatMessageType_VoiceMessage) {
        //引用语音
        _lblReference.text = LanguageToolMatch(@"[语音]");
    } else if (_referenceMsgModel.message.messageType == CIMChatMessageType_FileMessage) {
        //引用文件
        _lblReference.text = LanguageToolMatch(@"[文件]");
    } else if (_referenceMsgModel.message.messageType == CIMChatMessageType_CardMessage) {
        //引用名片
        _lblReference.text = [NSString stringWithFormat:@"%@%@", LanguageToolMatch(@"[个人名片]"), referenceMsgModel.message.cardNickName];
    } else if (_referenceMsgModel.message.messageType == CIMChatMessageType_GeoMessage) {
        //引用地位位置
        _lblReference.text = [NSString stringWithFormat:@"%@%@", LanguageToolMatch(@"[位置]"), referenceMsgModel.message.geoName];
    } else if (_referenceMsgModel.message.messageType == CIMChatMessageType_ForwardMessage) {
        //引用消息记录
        _lblReference.text = [NSString stringWithFormat:@"%@%@", LanguageToolMatch(@"[会话记录]"), referenceMsgModel.message.forwardMessage.title];
    } else if (_referenceMsgModel.message.messageType == CIMChatMessageType_StickersMessage) {
        //引用表情
        _lblReference.text = LanguageToolMatch(@"[表情]");
    } else if (_referenceMsgModel.message.messageType == CIMChatMessageType_GameStickersMessage) {
        //引用游戏表情
        _lblReference.text = LanguageToolMatch(@"[表情]");
    } else {
        _lblReference.text = LanguageToolMatch(@"未知");
    }
}

#pragma mark - 交互事件
- (void)btnCloseClick {
    if (_delegate && [_delegate respondsToSelector:@selector(referenceViewClose)]) {
        [_delegate referenceViewClose];
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
