//
//  NoaMessageTextCell.m
//  NoaKit
//
//  Created by Candy on 2026/9/28.
//

#import "NoaMessageTextCell.h"
//#import <YYText/NSAttributedString+YYText.h>
//#import <YYText/YYLabel.h>
#import "UIButton+Gradient.h"

@implementation NoaMessageTextCell
{
    YYLabel *_contentLabel;
    UIView *_spaceLineView;
    YYLabel *_translateContentLabel;
    UIActivityIndicatorView *_activLoadingView;
    UIButton *_reTranslateBtn;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupTextUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupTextUI {
    _contentLabel = [YYLabel new];
    _contentLabel.numberOfLines = 0;
    _contentLabel.font = FONTN(16);
    _contentLabel.userInteractionEnabled = YES;
    _contentLabel.backgroundColor = COLOR_CLEAR;
    [self.contentView addSubview:_contentLabel];
    
    _spaceLineView = [UIView new];
    _spaceLineView.tkThemebackgroundColors = @[COLOR_EAEAEA, COLOR_EAEAEA];
    _spaceLineView.hidden = YES;
    [self.contentView addSubview:_spaceLineView];
    
    _translateContentLabel = [YYLabel new];
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

- (void)setConfigMessage:(NoaMessageModel *)model {
    [super setConfigMessage:model];
    
    if (model.message.translateStatus == CIMTranslateStatusNone) {
        if (![NSString isNil:model.message.translateContent] || ![NSString isNil:model.message.againTranslateContent]) {
            model.message.translateStatus = CIMTranslateStatusSuccess;
        } else {
            model.message.translateStatus = CIMTranslateStatusNone;
        }
    }
    
    //原文
    _contentLabel.frame = _contentRect;
    //文本内容如果包含url，则对url进行变色处理，并可点击
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
    _contentLabel.attributedText = model.attStr;
    if (model.messageWidth > 45) {
        _contentLabel.textAlignment = [ZTOOL RTLTextAlignment:NSTextAlignmentLeft];
    } else {
        _contentLabel.textAlignment =[ZTOOL RTLTextAlignment:NSTextAlignmentCenter];
    }
    
    // 全局翻译开关（默认开启）
    BOOL translateEnabled = [UserManager isTranslateEnabled];
    BOOL hasTranslatedHistory = (model.message.localTranslatedShown == 1);
    if (!translateEnabled && !hasTranslatedHistory) {
        // 开关关闭且无历史译文：不展示译文区域
        _activLoadingView.hidden = YES;
        [_activLoadingView stopAnimating];
        _reTranslateBtn.hidden = YES;
        _translateContentLabel.hidden = YES;
        _spaceLineView.hidden = YES;
        return;
    }
    if (!translateEnabled && model.message.translateStatus == CIMTranslateStatusLoading) {
        // 开关关闭时不展示加载态
        _activLoadingView.hidden = YES;
        [_activLoadingView stopAnimating];
        _reTranslateBtn.hidden = YES;
        _translateContentLabel.hidden = YES;
        _spaceLineView.hidden = YES;
        // 如有历史译文，上面的 hasTranslatedHistory 已使 status 在前面被置为 Success
        if (!hasTranslatedHistory) {
            return;
        }
    }
    
    //译文
    if (model.message.translateStatus == CIMTranslateStatusSuccess) {
        // 首次成功展示译文则本地打标并入库
        if (model.message.localTranslatedShown != 1) {
            model.message.localTranslatedShown = 1;
            [IMSDKManager toolInsertOrUpdateChatMessageWith:model.message];
        }
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
        
        //译文文本内容如果包含url，则对url进行变色处理，并可点击
        NSArray *translateUrlArr = [model.message.translateContent getUrlFromString];
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
        _translateContentLabel.attributedText = model.translateAttStr;
        if (model.translateMessageWidth> 45) {
            _translateContentLabel.textAlignment = [ZTOOL RTLTextAlignment:NSTextAlignmentLeft];
        } else {
            _translateContentLabel.textAlignment =[ZTOOL RTLTextAlignment:NSTextAlignmentCenter];
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
}

#pragma mark - Action
- (void)textMsgUrlClick:(NSString *)urlStr {
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageTextContainUrlClick:messageModel:)]) {
        [self.delegate messageTextContainUrlClick:urlStr messageModel:self.messageModel];
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

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
