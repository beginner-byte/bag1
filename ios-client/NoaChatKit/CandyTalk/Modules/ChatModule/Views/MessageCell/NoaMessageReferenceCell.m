//
//  NoaMessageReferenceCell.m
//  NoaKit
//
//  Created by Candy on 2026/10/26.
//

#import "NoaMessageReferenceCell.h"
#import "MImageBrowserVC.h"
#import "UIButton+Gradient.h"

@interface NoaMessageReferenceCell() <MImageBrowserVCDelegate>

@end

@implementation NoaMessageReferenceCell
{
    UIImageView *_referenceTipImgView;    //左上引用箭头
    UILabel *_referenceNameLabel;         //原消息的用户名
    UIView *_referenceLineView;           //左边竖线
    UILabel *_referenceContentLabel;      //原消息文本内容
    UIImageView *_referenceImageView;     //原消息图片、视频封面
    UIImageView *_referencePlayImgView;   //原消息视频封面上播放按钮
    
    YYLabel *_contentLabel;
    UIView *_spaceLineView;
    YYLabel *_translateContentLabel;
    UIActivityIndicatorView *_activLoadingView;
    UIButton *_reTranslateBtn;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupReferenceTextUI];
        [self setupThemeUpdate];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupReferenceTextUI {
    //左上引用箭头
    _referenceTipImgView = [[UIImageView alloc] init];
    _referenceTipImgView.image = ImgNamed(@"img_msg_reference_tip");
    [self.contentView addSubview:_referenceTipImgView];
    [_referenceTipImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(12);
        make.top.equalTo(self.contentView).offset(13);
        make.width.mas_equalTo(DWScale(10));
        make.height.mas_equalTo(DWScale(8));
    }];
    
    //原消息的用户名
    _referenceNameLabel = [[UILabel alloc] init];
    _referenceNameLabel.tkThemetextColors = @[COLOR_11, COLORWHITE];
    _referenceNameLabel.numberOfLines = 1;
    _referenceNameLabel.font = FONTN(12);
    _referenceNameLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_referenceNameLabel];
    [_referenceNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_referenceTipImgView.mas_trailing).offset(5);
        make.centerY.equalTo(_referenceTipImgView);
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-10);
        make.height.mas_equalTo(DWScale(17));
    }];
    
    //左边竖线
    _referenceLineView = [[UIView alloc] init];
    _referenceLineView.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE];
    [self.contentView addSubview:_referenceLineView];
    [_referenceLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_referenceTipImgView.mas_bottom).offset(5);
        make.centerX.equalTo(_referenceTipImgView);
        make.width.mas_equalTo(DWScale(2));
        make.height.mas_equalTo(DWScale(17));
    }];
    
    //原消息文本内容
    _referenceContentLabel = [[UILabel alloc] init];
    _referenceContentLabel.tkThemetextColors = @[COLOR_11, COLOR_99];
    _referenceContentLabel.numberOfLines = 2;
    _referenceContentLabel.font = FONTN(12);
    _referenceContentLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_referenceContentLabel];
    [_referenceContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_referenceLineView.mas_trailing).offset(9);
        make.centerY.equalTo(_referenceLineView);
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-10);
        make.height.mas_equalTo(DWScale(17));
    }];
    
    //原消息图片、视频封面、表情图片
    _referenceImageView = [[UIImageView alloc] init];
    _referenceImageView.userInteractionEnabled = YES;
    _referenceImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_referenceImageView];
    [_referenceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_referenceLineView.mas_trailing).offset(9);
        make.top.equalTo(_referenceLineView);
        make.width.mas_equalTo(DWScale(54));
        make.height.mas_equalTo(DWScale(54));
    }];
    
    UITapGestureRecognizer *referenceImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(referenceImgTapClick)];
    [_referenceImageView addGestureRecognizer:referenceImgTap];
    
    //原消息视频封面播放按钮
    _referencePlayImgView = [[UIImageView alloc] init];
    _referencePlayImgView.image = ImgNamed(@"icon_video_msg_play");
    [self.contentView addSubview:_referencePlayImgView];
    [_referencePlayImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_referenceImageView);
        make.width.mas_equalTo(DWScale(24));
        make.height.mas_equalTo(DWScale(24));
    }];
    
    //当前文本消息
    _contentLabel = [YYLabel new];
    _contentLabel.numberOfLines = 0;
    _contentLabel.font = FONTN(16);
    _contentLabel.textAlignment = [ZTOOL RTLTextAlignment:NSTextAlignmentLeft];
    _contentLabel.userInteractionEnabled = YES;
    _contentLabel.backgroundColor = COLOR_CLEAR;
    _contentLabel.preferredMaxLayoutWidth = DScreenWidth - 140;
    [self.contentView addSubview:_contentLabel];
    
    _spaceLineView = [UIView new];
    _spaceLineView.tkThemebackgroundColors = @[COLOR_EAEAEA, COLOR_EAEAEA];
    _spaceLineView.hidden = YES;
    [self.contentView addSubview:_spaceLineView];
    
    _translateContentLabel = [YYLabel new];
    _translateContentLabel.textAlignment = [ZTOOL RTLTextAlignment:NSTextAlignmentLeft];
    _translateContentLabel.hidden = YES;
    _translateContentLabel.numberOfLines = 0;
    _translateContentLabel.font = FONTN(16);
    _translateContentLabel.userInteractionEnabled = YES;
    _translateContentLabel.backgroundColor = COLOR_CLEAR;
    _translateContentLabel.preferredMaxLayoutWidth = DScreenWidth - 140;
    [self.contentView addSubview:_translateContentLabel];
    
    _activLoadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    _activLoadingView.hidden = YES;
    [self.contentView addSubview:_activLoadingView];
    
    _reTranslateBtn = [[UIButton alloc] init];
    [_reTranslateBtn setTitle:LanguageToolMatch(@"翻译失败") forState:UIControlStateNormal];
    [_reTranslateBtn setImage:ImgNamed(@"icon_msg_translate_fail") forState:UIControlStateNormal];
    [_reTranslateBtn setIconInLeftWithSpacing:DWScale(2)];
    [_reTranslateBtn setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2] forState:UIControlStateNormal];
    _reTranslateBtn.titleLabel.font = FONTN(16);
    [_reTranslateBtn addTarget:self action:@selector(reTranslateAction) forControlEvents:UIControlEventTouchUpInside];
    _reTranslateBtn.hidden = YES;
    [self.contentView addSubview:_reTranslateBtn];
}

-(void)setupThemeUpdate {
    self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        NoaMessageReferenceCell * cell = itself;
        [ZTOOL doInMain:^{
            cell->_contentLabel.attributedText = cell.messageModel.attStr;
            cell->_translateContentLabel.attributedText = cell.messageModel.translateAttStr;
        }];
    };
}

- (void)setConfigMessage:(NoaMessageModel *)model {
    [super setConfigMessage:model];
    
    _contentLabel.frame = _contentRect;
    
    //左上引用箭头
    [_referenceTipImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_contentLabel).offset(2);
        make.top.equalTo(_contentLabel.mas_top).offset(-model.referenceMsgHeight);
        make.width.mas_equalTo(DWScale(10));
        make.height.mas_equalTo(DWScale(8));
    }];
    
    //原消息的用户名
    [_referenceNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_referenceTipImgView.mas_trailing).offset(5);
        make.centerY.equalTo(_referenceTipImgView);
        make.trailing.equalTo(_contentLabel.mas_trailing);
        make.height.mas_equalTo(DWScale(17));
    }];
    
    //原消息文本内容
    [_referenceContentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_referenceLineView.mas_trailing).offset(9);
        make.centerY.equalTo(_referenceLineView);
        make.trailing.equalTo(_contentLabel.mas_trailing);
        make.height.mas_equalTo(model.referenceMsgHeight - 17 - 6);
    }];
    
    if (model.referenceMsg == nil) {
        _referenceNameLabel.text = LanguageToolMatch(@"未知");
        _referenceContentLabel.hidden = NO;
        _referenceImageView.hidden = YES;
        _referencePlayImgView.hidden = YES;
        
        _referenceContentLabel.attributedText = model.referenceAttStr;
        [_referenceLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_referenceTipImgView.mas_bottom).offset(5);
            make.centerX.equalTo(_referenceTipImgView);
            make.width.mas_equalTo(DWScale(2));
            make.height.mas_equalTo(model.referenceMsgHeight - 17 - 6);
        }];
    } else {
        _referenceNameLabel.text = model.referenceMsg.fromNickname;;
        if (model.referenceMsg.messageType == CIMChatMessageType_TextMessage || model.referenceMsg.messageType == CIMChatMessageType_AtMessage) {
            //引用文本消息
            _referenceContentLabel.hidden = NO;
            _referenceImageView.hidden = YES;
            _referencePlayImgView.hidden = YES;
            
            _referenceContentLabel.attributedText = model.referenceAttStr;
            [_referenceLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_referenceTipImgView.mas_bottom).offset(5);
                make.centerX.equalTo(_referenceTipImgView);
                make.width.mas_equalTo(DWScale(2));
                make.height.mas_equalTo(model.referenceMsgHeight - 17 - 6);
            }];
        } else if (model.referenceMsg.messageType == CIMChatMessageType_ImageMessage) {
            if (model.referenceMsg.messageStatus == 1) { //正常
                //引用图片消息
                _referenceContentLabel.hidden = YES;
                _referenceImageView.hidden = NO;
                _referencePlayImgView.hidden = YES;
                
                _referenceImageView.contentMode = UIViewContentModeScaleAspectFit;
                [_referenceImageView rounded:6];
                [_referenceImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(DWScale(54));
                    make.height.mas_equalTo(DWScale(54));
                }];
                
                //加载图片
                if (![NSString isNil:model.message.localImgName]) {
                    NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, self.sessionId];
                    NSString * path = [NSString getPathWithImageName:model.referenceMsg.localImgName CustomPath:customPath];
                    [_referenceImageView sd_setImageWithURL:[NSURL fileURLWithPath:path] placeholderImage:[UIImage imageCompressFitSizeScale:DefaultImage targetSize:CGSizeMake(DWScale(54), DWScale(54))] options:SDWebImageRetryFailed | SDWebImageAllowInvalidSSLCertificates];
                } else {
                    WeakSelf;
                    [_referenceImageView sd_setImageWithURL:[model.referenceMsg.imgName getImageFullUrl] placeholderImage:[UIImage imageCompressFitSizeScale:DefaultImage targetSize:CGSizeMake(DWScale(50), DWScale(50))] options: SDWebImageRetryFailed | SDWebImageAllowInvalidSSLCertificates progress:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                        StrongSelf;
                        [strongSelf loadWithImage:image imageViewMode:UIViewContentModeScaleAspectFit URL:[model.referenceMsg.imgName getImageFullString] error:error];
                    }];
                }
                [_referenceLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_referenceTipImgView.mas_bottom).offset(5);
                    make.centerX.equalTo(_referenceTipImgView);
                    make.width.mas_equalTo(DWScale(2));
                    make.height.mas_equalTo(DWScale(54));
                }];
            } else {
                _referenceContentLabel.hidden = NO;
                _referenceImageView.hidden = YES;
                _referencePlayImgView.hidden = YES;
                
                _referenceContentLabel.attributedText = model.referenceAttStr;
                [_referenceLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_referenceTipImgView.mas_bottom).offset(5);
                    make.centerX.equalTo(_referenceTipImgView);
                    make.width.mas_equalTo(DWScale(2));
                    make.height.mas_equalTo(model.referenceMsgHeight - 17 - 6);
                }];
            }
        } else if (model.referenceMsg.messageType == CIMChatMessageType_StickersMessage) {
            if (model.referenceMsg.messageStatus == 1) { //正常
                //引用表情消息
                _referenceContentLabel.hidden = YES;
                _referenceImageView.hidden = NO;
                _referencePlayImgView.hidden = YES;
                
                _referenceImageView.contentMode = UIViewContentModeScaleAspectFit;
                [_referenceImageView rounded:6];
                [_referenceImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(DWScale(54));
                    make.height.mas_equalTo(DWScale(54));
                }];
                WeakSelf;
                //加载表情图片
                [_referenceImageView sd_setImageWithURL:[model.referenceMsg.stickersImg getImageFullUrl] placeholderImage:[UIImage imageCompressFitSizeScale:DefaultImage targetSize:CGSizeMake(DWScale(50), DWScale(50))] options:SDWebImageRetryFailed | SDWebImageAllowInvalidSSLCertificates progress:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    StrongSelf;
                    [strongSelf loadWithImage:image imageViewMode:UIViewContentModeScaleAspectFit URL:[model.referenceMsg.stickersImg getImageFullString] error:error];
                }];
                [_referenceLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_referenceTipImgView.mas_bottom).offset(5);
                    make.centerX.equalTo(_referenceTipImgView);
                    make.width.mas_equalTo(DWScale(2));
                    make.height.mas_equalTo(DWScale(54));
                }];
            } else {
                _referenceContentLabel.hidden = NO;
                _referenceImageView.hidden = YES;
                _referencePlayImgView.hidden = YES;
                
                _referenceContentLabel.attributedText = model.referenceAttStr;
                [_referenceLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_referenceTipImgView.mas_bottom).offset(5);
                    make.centerX.equalTo(_referenceTipImgView);
                    make.width.mas_equalTo(DWScale(2));
                    make.height.mas_equalTo(model.referenceMsgHeight - 17 - 6);
                }];
            }
        } else if (model.referenceMsg.messageType == CIMChatMessageType_GameStickersMessage) {
            if (model.referenceMsg.messageStatus == 1) { //正常
                //引用表情消息
                _referenceContentLabel.hidden = YES;
                _referenceImageView.hidden = NO;
                _referencePlayImgView.hidden = YES;
                
                _referenceImageView.contentMode = UIViewContentModeScaleToFill;
                [_referenceImageView rounded:6];
                [_referenceImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(DWScale(54));
                    make.height.mas_equalTo(DWScale(54));
                }];
                
                //加载游戏表情图片
                NSString *contentImgName;
                if (model.referenceMsg.gameSticekersType == ZChatGameStickerTypeFingerGuessing) {
                    //石头剪刀布
                    contentImgName = [NSString stringWithFormat:@"icon_chat_message_stoneScissorCloth%@", model.referenceMsg.gameStickersResut];
                } else if (model.referenceMsg.gameSticekersType == ZChatGameStickerTypePlayDice) {
                    //摇骰子
                    contentImgName = [NSString stringWithFormat:@"icon_chat_message_dice%@", model.referenceMsg.gameStickersResut];
                } else {
                    contentImgName = @"";
                }
                //设置图片
                [_referenceImageView setImage:ImgNamed(contentImgName)];
                [_referenceLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_referenceTipImgView.mas_bottom).offset(5);
                    make.centerX.equalTo(_referenceTipImgView);
                    make.width.mas_equalTo(DWScale(2));
                    make.height.mas_equalTo(DWScale(54));
                }];
            } else {
                _referenceContentLabel.hidden = NO;
                _referenceImageView.hidden = YES;
                _referencePlayImgView.hidden = YES;
                
                _referenceContentLabel.attributedText = model.referenceAttStr;
                [_referenceLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_referenceTipImgView.mas_bottom).offset(5);
                    make.centerX.equalTo(_referenceTipImgView);
                    make.width.mas_equalTo(DWScale(2));
                    make.height.mas_equalTo(model.referenceMsgHeight - 17 - 6);
                }];
            }
        } else if (model.referenceMsg.messageType == CIMChatMessageType_VideoMessage) {
            if (model.referenceMsg.messageStatus == 1) { //正常
                //引用视频消息
                _referenceContentLabel.hidden = YES;
                _referenceImageView.hidden = NO;
                _referencePlayImgView.hidden = NO;
                
                _referenceImageView.contentMode = UIViewContentModeScaleAspectFit;
                [_referenceImageView rounded:6];
                [_referenceImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(DWScale(54));
                    make.height.mas_equalTo(DWScale(54));
                }];
                
                //加载视频封面
                if (![NSString isNil:model.message.localVideoCover]) {
                    NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, self.sessionId];
                    NSString * path = [NSString getPathWithImageName:model.referenceMsg.localVideoCover CustomPath:customPath];
                    [_referenceImageView sd_setImageWithURL:[NSURL fileURLWithPath:path] placeholderImage:[UIImage imageCompressFitSizeScale:DefaultImage targetSize:CGSizeMake(DWScale(54), DWScale(54))] options:SDWebImageRetryFailed | SDWebImageAllowInvalidSSLCertificates];
                } else {
                    WeakSelf;
                    [_referenceImageView sd_setImageWithURL:[model.referenceMsg.videoCover getImageFullUrl] placeholderImage:[UIImage imageCompressFitSizeScale:DefaultImage targetSize:CGSizeMake(DWScale(50), DWScale(50))] options:SDWebImageAllowInvalidSSLCertificates progress:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                        StrongSelf;
                        [strongSelf loadWithImage:image imageViewMode:UIViewContentModeScaleAspectFit URL:[model.referenceMsg.videoCover getImageFullString] error:error];
                    }];
                }
                [_referenceLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_referenceTipImgView.mas_bottom).offset(5);
                    make.centerX.equalTo(_referenceTipImgView);
                    make.width.mas_equalTo(DWScale(2));
                    make.height.mas_equalTo(DWScale(54));
                }];
            } else {
                _referenceContentLabel.hidden = NO;
                _referenceImageView.hidden = YES;
                _referencePlayImgView.hidden = YES;
                
                _referenceContentLabel.attributedText = model.referenceAttStr;
                [_referenceLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_referenceTipImgView.mas_bottom).offset(5);
                    make.centerX.equalTo(_referenceTipImgView);
                    make.width.mas_equalTo(DWScale(2));
                    make.height.mas_equalTo(model.referenceMsgHeight - 17 - 6);
                }];
            }
        } else if (model.referenceMsg.messageType == CIMChatMessageType_VoiceMessage || model.referenceMsg.messageType == CIMChatMessageType_FileMessage || model.referenceMsg.messageType == CIMChatMessageType_CardMessage || model.referenceMsg.messageType == CIMChatMessageType_GeoMessage || model.referenceMsg.messageType == CIMChatMessageType_ForwardMessage) {
            //引用语音消息、文件、名片消息
            _referenceContentLabel.hidden = NO;
            _referenceImageView.hidden = YES;
            _referencePlayImgView.hidden = YES;
            
            _referenceContentLabel.attributedText = model.referenceAttStr;
            [_referenceLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_referenceTipImgView.mas_bottom).offset(5);
                make.centerX.equalTo(_referenceTipImgView);
                make.width.mas_equalTo(DWScale(2));
                make.height.mas_equalTo(model.referenceMsgHeight - 17 - 6);
            }];
        } else {
            _referenceContentLabel.hidden = YES;
            _referenceImageView.hidden = YES;
            _referencePlayImgView.hidden = YES;
        }
    }
    
    //文本内容如果包含url，则对url进行变色处理，并可点击
    _contentLabel.attributedText = model.attStr;
    NSArray *urlArr = [model.message.textContent getUrlFromString];
    if (urlArr.count > 0) {
        for (NSString *urlStr in urlArr) {
            WeakSelf
            if (model.isSelf) {
                [model.attStr yy_setTextHighlightRange:[model.attStr.string rangeOfString:urlStr] color:COLOR_E7B9AE backgroundColor:COLOR_CLEAR tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                    [weakSelf textMsgUrlClick:urlStr];
                }];
            } else {
                [model.attStr yy_setTextHighlightRange:[model.attStr.string rangeOfString:urlStr] color:COLOR_5966F2 backgroundColor:COLOR_CLEAR tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                    [weakSelf textMsgUrlClick:urlStr];
                }];
            }
        }
    }

    //译文
    if (model.message.translateStatus == CIMTranslateStatusSuccess) {
        _activLoadingView.hidden = YES;
        [_activLoadingView stopAnimating];
        _reTranslateBtn.hidden = YES;
        if (model.translateAttStr.length > 0) {
            _spaceLineView.hidden = NO;
            [_spaceLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(_contentLabel);
                make.top.equalTo(_contentLabel.mas_bottom).offset(DWScale(2));
                make.height.mas_equalTo(DWScale(0.8));
            }];
            
            _translateContentLabel.hidden = NO;
            _translateContentLabel.attributedText = model.translateAttStr;
            [_translateContentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self.contentView).offset(_contentRect.origin.x);
                make.top.equalTo(_spaceLineView.mas_bottom).offset(DWScale(1));
                make.width.mas_equalTo(model.translateMessageWidth);
                make.height.mas_equalTo(model.translateMessageHeight);
            }];
        } else {
            _spaceLineView.hidden = YES;
            _translateContentLabel.hidden = YES;
            _activLoadingView.hidden = YES;
            [_activLoadingView stopAnimating];
            _reTranslateBtn.hidden = YES;
        }
        NSArray *translateUrlArr;
        if (model.message.messageType == CIMChatMessageType_TextMessage) {
            translateUrlArr = [model.message.translateContent getUrlFromString];
        }
        if (model.message.messageType == CIMChatMessageType_AtMessage) {
            translateUrlArr = [model.message.showTranslateContent getUrlFromString];
        }
        if (translateUrlArr.count > 0) {
            for (NSString *translateUrlStr in translateUrlArr) {
                WeakSelf
                if (model.isSelf) {
                    [model.attStr yy_setTextHighlightRange:[model.translateAttStr.string rangeOfString:translateUrlStr] color:COLOR_E7B9AE backgroundColor:COLOR_CLEAR tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                        [weakSelf textMsgUrlClick:translateUrlStr];
                    }];
                } else {
                    [model.attStr yy_setTextHighlightRange:[model.translateAttStr.string rangeOfString:translateUrlStr] color:COLOR_5966F2 backgroundColor:COLOR_CLEAR tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                        [weakSelf textMsgUrlClick:translateUrlStr];
                    }];
                }
            }
        }
    } else if (model.message.translateStatus == CIMTranslateStatusLoading) {
        _activLoadingView.hidden = NO;
        [_activLoadingView startAnimating];
        _reTranslateBtn.hidden = YES;
        _translateContentLabel.hidden = YES;
        _spaceLineView.hidden = NO;
        
        [_spaceLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(_contentLabel);
            make.top.equalTo(_contentLabel.mas_bottom).offset(DWScale(2));
            make.height.mas_equalTo(DWScale(0.8));
        }];
        
        [_activLoadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_contentLabel);
            make.top.equalTo(_spaceLineView.mas_bottom).offset(DWScale(14));
            make.width.mas_equalTo(22);
            make.height.mas_equalTo(22);
        }];
    } else if (model.message.translateStatus == CIMTranslateStatusFail) {
        _activLoadingView.hidden = YES;
        [_activLoadingView stopAnimating];
        _reTranslateBtn.hidden = NO;
        _translateContentLabel.hidden = YES;
        _spaceLineView.hidden = NO;
        
        [_spaceLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(_contentLabel);
            make.top.equalTo(_contentLabel.mas_bottom).offset(DWScale(2));
            make.height.mas_equalTo(DWScale(0.8));
        }];
        
        if (model.isSelf) {
            [_reTranslateBtn setImage:ImgNamed(@"icon_msg_translate_fail_white") forState:UIControlStateNormal];
            [_reTranslateBtn setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
        } else {
            [_reTranslateBtn setImage:ImgNamed(@"icon_msg_translate_fail") forState:UIControlStateNormal];
            [_reTranslateBtn setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2] forState:UIControlStateNormal];
        }
        [_reTranslateBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView).offset(_contentRect.origin.x);
            make.top.equalTo(_spaceLineView.mas_bottom).offset(DWScale(2));
            make.width.mas_equalTo(model.translateMessageWidth);
            make.height.mas_equalTo(model.translateMessageHeight);
        }];
    } else {
        _activLoadingView.hidden = YES;
        [_activLoadingView stopAnimating];
        _reTranslateBtn.hidden = YES;
        _translateContentLabel.hidden = YES;
        _spaceLineView.hidden = YES;
    }

    if (model.isSelf) {
        _referenceTipImgView.image = ImgNamed(@"img_msg_reference_tip");
        _referenceLineView.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE];
        _referenceNameLabel.tkThemetextColors = @[COLORWHITE, COLORWHITE];
        _referenceContentLabel.tkThemetextColors = @[COLORWHITE, COLORWHITE];
    } else {
        _referenceTipImgView.image = ImgNamed(@"img_msg_reference_tip_blue");
        _referenceLineView.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
        _referenceNameLabel.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _referenceContentLabel.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    }
}

#pragma mark - Action
- (void)textMsgUrlClick:(NSString *)urlStr {
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageTextContainUrlClick:messageModel:)]) {
        [self.delegate messageTextContainUrlClick:urlStr messageModel:self.messageModel];
    }
}

- (void)referenceImgTapClick {
    if (self.messageModel.referenceMsg.messageType == CIMChatMessageType_ImageMessage || self.messageModel.referenceMsg.messageType == CIMChatMessageType_VideoMessage) {
        //图片或视频浏览
        if (self.delegate && [self.delegate respondsToSelector:@selector(messageCellBrowserImageAndVideo:)]) {
            [self.delegate messageCellBrowserImageAndVideo:self.messageModel.referenceMsg];
        }
    }
}

- (void)reTranslateAction {
    if (self.messageModel.message.messageSendType == CIMChatMessageSendTypeSuccess && self.messageModel.message.translateStatus == CIMTranslateStatusFail && self.messageModel.isSelf) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageTextReTranslateClick:)]) {
        [self.delegate messageTextReTranslateClick:self.cellIndex];
    }
}

- (void)loadWithImage:(UIImage *)image imageViewMode:(UIViewContentMode)mode URL:(NSString *)url error:(NSError *)error {
    
    if (!image) {
        _referenceImageView.image = [UIImage imageCompressFitSizeScale:DefaultNoImage targetSize:CGSizeMake(DWScale(50), DWScale(50))];
        [self loadImageFailWithURL:url error:error];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
