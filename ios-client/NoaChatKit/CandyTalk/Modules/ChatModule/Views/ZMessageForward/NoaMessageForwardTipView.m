//
//  NoaMessageForwardTipView.m
//  NoaKit
//
//  Created by Candy on 2026/12/7.
//

#import "NoaMessageForwardTipView.h"
#import "NoaToolManager.h"
#import "NoaMessageForwardUserCell.h"
#import "NoaMessageTools.h"

@interface NoaMessageForwardTipView () <UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, strong) UIView *viewBg;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *lblContent;
@property (nonatomic, strong) UIImageView *ivContent;
@property (nonatomic, strong) UIImageView *ivVideoTip;
@property (nonatomic, strong) UILabel *lblVideoTime;

@property (nonatomic, strong) NSArray *forwardMsgList;
@property (nonatomic, strong) NSArray *toAvatarList;
@property (nonatomic, copy) NSString *fromSessionId;
@property (nonatomic, assign) ZMultiSelectType multiSelectType;
@property (nonatomic, assign) NSInteger mergeCount;

@end


@implementation NoaMessageForwardTipView

- (instancetype)initWithForwardMsg:(NSArray *)forwardMsgList toAvatarList:(NSArray *)toAvatarList mergeMsgCount:(NSInteger)mergeMsgCount fromSessionId:(NSString *)fromSessionId multiSelectType:(ZMultiSelectType)multiSelectType {
    self = [super init];
    if (self) {
        _forwardMsgList = forwardMsgList;
        _toAvatarList = toAvatarList;
        _fromSessionId = fromSessionId;
        _multiSelectType = multiSelectType;
        _mergeCount = mergeMsgCount;
        [self setupUI];
    }
    return self;
}

#pragma mark - 界面布局
- (void)setupUI {
    self.frame = CGRectMake(0, 0, DScreenWidth, DScreenHeight);
    self.tkThemebackgroundColors = @[[COLOR_00 colorWithAlphaComponent:0.3],[COLOR_00 colorWithAlphaComponent:0.6]];
    [CurrentWindow addSubview:self];
    
    _viewBg = [UIView new];
    _viewBg.alpha = 0;
    _viewBg.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    _viewBg.layer.cornerRadius = DWScale(14);
    _viewBg.layer.masksToBounds = YES;
    [self addSubview:_viewBg];
    
    UILabel *lblSendTip = [UILabel new];
    lblSendTip.text = LanguageToolMatch(@"发送给");
    lblSendTip.tkThemetextColors = @[COLOR_11, COLORWHITE];
    lblSendTip.font = FONTR(18);
    [_viewBg addSubview:lblSendTip];
    [lblSendTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewBg).offset(DWScale(30));
        make.leading.equalTo(_viewBg).offset(DWScale(20));
        make.height.mas_equalTo(DWScale(30));
    }];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(DWScale(30), DWScale(30));
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [_collectionView setTransform:CGAffineTransformMakeScale(-1, 1)];//水平方向翻转
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    [_collectionView registerClass:[NoaMessageForwardUserCell class] forCellWithReuseIdentifier:NSStringFromClass([NoaMessageForwardUserCell class])];
    [_viewBg addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(lblSendTip);
        make.leading.equalTo(lblSendTip.mas_trailing).offset(DWScale(20));
        make.trailing.equalTo(_viewBg).offset(-DWScale(20));
        make.height.mas_equalTo(DWScale(30));
    }];
    
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    [btnCancel setTkThemeTitleColor:@[COLOR_66, COLORWHITE] forState:UIControlStateNormal];
    btnCancel.titleLabel.font = FONTR(17);
    btnCancel.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F5F6F9_DARK];
    [btnCancel setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateSelected];
    [btnCancel setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateHighlighted];
    btnCancel.layer.cornerRadius = DWScale(22);
    btnCancel.layer.masksToBounds = YES;
    [btnCancel addTarget:self action:@selector(btnCancelClick) forControlEvents:UIControlEventTouchUpInside];
    [_viewBg addSubview:btnCancel];
    
    UIButton *btnSend = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSend setTitle:LanguageToolMatch(@"发送") forState:UIControlStateNormal];
    [btnSend setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
    btnSend.titleLabel.font = FONTR(17);
    btnSend.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    [btnSend setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateSelected];
    [btnSend setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateHighlighted];
    btnSend.layer.cornerRadius = DWScale(22);
    btnSend.layer.masksToBounds = YES;
    [btnSend addTarget:self action:@selector(btnSendClick) forControlEvents:UIControlEventTouchUpInside];
    [_viewBg addSubview:btnSend];
    
    if (_forwardMsgList.count == 1) {
        NoaMessageModel *forwardMsg = (NoaMessageModel *)[_forwardMsgList firstObject];
        if (forwardMsg.message.messageType == CIMChatMessageType_TextMessage || forwardMsg.message.messageType == CIMChatMessageType_AtMessage || forwardMsg.message.messageType == CIMChatMessageType_VoiceMessage || forwardMsg.message.messageType == CIMChatMessageType_FileMessage || forwardMsg.message.messageType == CIMChatMessageType_GeoMessage || forwardMsg.message.messageType == CIMChatMessageType_ForwardMessage) {
            _lblContent = [UILabel new];
            if (forwardMsg.message.messageType == CIMChatMessageType_TextMessage) {
                //文本消息
                NSString *resultContent = @"";
                if (forwardMsg.isSelf) {
                    resultContent = forwardMsg.message.textContent;
                } else {
                    if (![NSString isNil:forwardMsg.message.translateContent]) {
                        resultContent = forwardMsg.message.translateContent;
                    } else {
                        resultContent = forwardMsg.message.textContent;
                    }
                }
                _lblContent.text = [NSString stringWithFormat:@"%@：%@", forwardMsg.message.fromNickname, resultContent];
            } else if (forwardMsg.message.messageType == CIMChatMessageType_AtMessage) {
                // At消息
                NSString *resultAtContent = @"";
                if (forwardMsg.isSelf) {
                    resultAtContent = forwardMsg.message.atContent;
                } else {
                    if (![NSString isNil:forwardMsg.message.atTranslateContent]) {
                        resultAtContent = forwardMsg.message.atTranslateContent;
                    } else {
                        resultAtContent = forwardMsg.message.atContent;
                    }
                }
                _lblContent.text = [NSString stringWithFormat:@"%@：%@", forwardMsg.message.fromNickname, [NoaMessageTools forwardMessageAtContenTranslateToShowContent:resultAtContent atUsersDictList:forwardMsg.message.atUsersInfoList]];
            } else if (forwardMsg.message.messageType == CIMChatMessageType_VoiceMessage) {
                //语音消息
                _lblContent.text = [NSString stringWithFormat:@"%@：%@", forwardMsg.message.fromNickname, LanguageToolMatch(@"[语音]")];
            }  else if (forwardMsg.message.messageType == CIMChatMessageType_FileMessage) {
                //文件消息
                _lblContent.text = forwardMsg.message.showFileName;
            } else if (forwardMsg.message.messageType == CIMChatMessageType_GeoMessage) {
                //地理位置消息
                _lblContent.text = [NSString stringWithFormat:@"%@%@", LanguageToolMatch(@"[位置]"), forwardMsg.message.geoName];
            } else if (forwardMsg.message.messageType == CIMChatMessageType_ForwardMessage) {
                //消息记录
                _lblContent.text = [NSString stringWithFormat:@"%@", forwardMsg.message.forwardMessage.title];
            }  else {
                _lblContent.text = @"";
            }
            _lblContent.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
            _lblContent.font = FONTR(15);
            _lblContent.numberOfLines = 2;
            _lblContent.preferredMaxLayoutWidth = DWScale(255);
            [_viewBg addSubview:_lblContent];
            [_lblContent mas_makeConstraints:^(MASConstraintMaker *make) {
    //            make.centerX.equalTo(_viewBg);
                make.leading.equalTo(_viewBg).offset(DWScale(20));
                make.top.equalTo(lblSendTip.mas_bottom).offset(DWScale(10));
            }];
            
            [btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(_viewBg).offset(DWScale(20));
                make.top.equalTo(_lblContent.mas_bottom).offset(DWScale(30));
                make.size.mas_equalTo(CGSizeMake(DWScale(99), DWScale(44)));
                make.bottom.equalTo(_viewBg.mas_bottom).offset(-DWScale(30));
            }];
            
            [btnSend mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.equalTo(_viewBg).offset(-DWScale(20));
                make.centerY.equalTo(btnCancel);
                make.size.mas_equalTo(CGSizeMake(DWScale(146), DWScale(44)));
            }];
        } else if (forwardMsg.message.messageType == CIMChatMessageType_ImageMessage || forwardMsg.message.messageType == CIMChatMessageType_VideoMessage || forwardMsg.message.messageType == CIMChatMessageType_StickersMessage) {
            _ivContent = [UIImageView new];
            _ivContent.layer.cornerRadius = DWScale(10);
            _ivContent.layer.masksToBounds = YES;
            [_viewBg addSubview:_ivContent];
            [_ivContent mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(_viewBg);
                make.top.equalTo(lblSendTip.mas_bottom).offset(DWScale(10));
                make.size.mas_equalTo(CGSizeMake(DWScale(160), DWScale(160)));
            }];
            if (forwardMsg.message.messageType == CIMChatMessageType_VideoMessage) {
                _ivVideoTip = [[UIImageView alloc] initWithImage:ImgNamed(@"c_video_tip")];
                [_viewBg addSubview:_ivVideoTip];
                [_ivVideoTip mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.leading.equalTo(_ivContent).offset(DWScale(10));
                    make.bottom.equalTo(_ivContent).offset(DWScale(-10));
                    make.size.mas_equalTo(CGSizeMake(DWScale(18), DWScale(14)));
                }];
                
                _lblVideoTime = [UILabel new];
                _lblVideoTime.textColor = COLORWHITE;
                _lblVideoTime.text = @"00:00";
                _lblVideoTime.font = FONTR(14);
                [_viewBg addSubview:_lblVideoTime];
                [_lblVideoTime mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(_ivVideoTip);
                    make.leading.equalTo(_ivVideoTip.mas_trailing).offset(DWScale(4));
                }];
            }
            
            [btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(_viewBg).offset(DWScale(20));
                make.top.equalTo(_ivContent.mas_bottom).offset(DWScale(16));
                make.size.mas_equalTo(CGSizeMake(DWScale(99), DWScale(44)));
                make.bottom.equalTo(_viewBg.mas_bottom).offset(-DWScale(30));
            }];
            
            [btnSend mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.equalTo(_viewBg).offset(-DWScale(20));
                make.centerY.equalTo(btnCancel);
                make.size.mas_equalTo(CGSizeMake(DWScale(146), DWScale(44)));
            }];
        }
    } else {
        _lblContent = [UILabel new];
        if (_multiSelectType == ZMultiSelectTypeMergeForward) {
            _lblContent.text = [NSString stringWithFormat:LanguageToolMatch(@"[合并转发]已选择%ld条消息"), _mergeCount];
        } else if (_multiSelectType == ZMultiSelectTypeSingleForward) {
            _lblContent.text = [NSString stringWithFormat:LanguageToolMatch(@"[逐条转发]已选择%ld条消息"), _forwardMsgList.count];
        } else {
            _lblContent.text = [NSString stringWithFormat:LanguageToolMatch(@"[转发]已选择%ld条消息"), _forwardMsgList.count];
        }
        
        _lblContent.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
        _lblContent.font = FONTR(15);
        _lblContent.numberOfLines = 2;
        _lblContent.preferredMaxLayoutWidth = DWScale(255);
        [_viewBg addSubview:_lblContent];
        [_lblContent mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_viewBg).offset(DWScale(20));
            make.top.equalTo(lblSendTip.mas_bottom).offset(DWScale(10));
        }];
        
        [btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_viewBg).offset(DWScale(20));
            make.top.equalTo(_lblContent.mas_bottom).offset(DWScale(30));
            make.size.mas_equalTo(CGSizeMake(DWScale(99), DWScale(44)));
            make.bottom.equalTo(_viewBg.mas_bottom).offset(-DWScale(30));
        }];
        
        [btnSend mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(_viewBg).offset(-DWScale(20));
            make.centerY.equalTo(btnCancel);
            make.size.mas_equalTo(CGSizeMake(DWScale(146), DWScale(44)));
        }];
    }
    
    [_viewBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_equalTo(DWScale(295));
        make.top.equalTo(lblSendTip.mas_top).offset(-DWScale(30));
        make.bottom.equalTo(btnCancel.mas_bottom).offset(DWScale(30));
    }];
    
    //单条转发：如果是图片或是视频，此处加载图片或是视频封面
    if (_forwardMsgList.count == 1) {
        NoaMessageModel *forwardMsg = (NoaMessageModel *)[_forwardMsgList firstObject];
        if (forwardMsg.message.messageType == CIMChatMessageType_ImageMessage) {
            if (![NSString isNil:forwardMsg.message.localImgName]) {
                //本地图片
                NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, _fromSessionId];
                NSString * path = [NSString getPathWithImageName:forwardMsg.message.localImgName CustomPath:customPath];
                [_ivContent sd_setImageWithURL:[NSURL fileURLWithPath:path] placeholderImage:[UIImage imageCompressFitSizeScale:DefaultImage targetSize:CGSizeMake(forwardMsg.messageWidth, forwardMsg.messageHeight)] options:SDWebImageRetryFailed | SDWebImageAllowInvalidSSLCertificates];
            } else {
                //网络图片
                [_ivContent sd_setImageWithURL:[forwardMsg.message.imgName getImageFullUrl] placeholderImage:DefaultImage options:SDWebImageAllowInvalidSSLCertificates];
            }
        } else if (forwardMsg.message.messageType == CIMChatMessageType_VideoMessage) {
            _lblVideoTime.text = [NSDate transSecondToTimeMethod2:forwardMsg.message.videoLength];
            if (![NSString isNil:forwardMsg.message.localVideoCover]) {
                //本地视频封面
                NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, _fromSessionId];
                NSString * path = [NSString getPathWithImageName:forwardMsg.message.localVideoCover CustomPath:customPath];
                [_ivContent sd_setImageWithURL:[NSURL fileURLWithPath:path] placeholderImage:[UIImage imageCompressFitSizeScale:DefaultImage targetSize:CGSizeMake(forwardMsg.messageWidth, forwardMsg.messageHeight)] options:SDWebImageRetryFailed | SDWebImageAllowInvalidSSLCertificates];
            } else {
                [_ivContent sd_setImageWithURL:[forwardMsg.message.videoCover getImageFullUrl] placeholderImage:DefaultImage options:SDWebImageAllowInvalidSSLCertificates];
            }
        } else if (forwardMsg.message.messageType == CIMChatMessageType_StickersMessage) {
            //表情图片
            [_ivContent sd_setImageWithURL:[forwardMsg.message.stickersImg getImageFullUrl] placeholderImage:DefaultImage options:SDWebImageAllowInvalidSSLCertificates];
        }
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _toAvatarList.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NoaMessageForwardUserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NoaMessageForwardUserCell class]) forIndexPath:indexPath];
    cell.toUserDic = (NSDictionary *)[_toAvatarList objectAtIndex:indexPath.row];
    return cell;
}
#pragma mark - UICollectionViewDelegate
#pragma mark - 交互事件
- (void)btnCancelClick {
    [self viewDismiss];
}
- (void)btnSendClick {
    if (self.sureClick) {
        self.sureClick();
    }
    [self viewDismiss];
}
- (void)viewShow {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewBg.alpha = 1;
    }];
}
- (void)viewDismiss {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewBg.alpha = 0;
    } completion:^(BOOL finished) {
        [weakSelf.viewBg removeFromSuperview];
        weakSelf.viewBg = nil;
        [weakSelf removeFromSuperview];
    }];
}


@end
