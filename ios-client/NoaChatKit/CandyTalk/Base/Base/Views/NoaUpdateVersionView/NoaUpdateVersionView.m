//
//  NoaUpdateVersionView.m
//  NoaKit
//
//  Created by Candy on 2023/3/30.
//

#import "NoaUpdateVersionView.h"
#import "NoaToolManager.h"

@interface NoaUpdateVersionView()

@property (nonatomic, strong)UIImageView *backImgView;
@property (nonatomic, strong)UILabel *tipTitleLbl;
@property (nonatomic, strong)UILabel *tipSubTitleLbl;
@property (nonatomic, strong)UILabel *forceUpdateTipsLbl;
@property (nonatomic, strong)UIScrollView *contentScroll;
@property (nonatomic, strong)UIView *containerView;
@property (nonatomic, strong)UILabel *contentLbl;

@property (nonatomic, strong)UIButton *laterBtn;
@property (nonatomic, strong)UIButton *updateBtn;

@end

@implementation NoaUpdateVersionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    self.frame = CGRectMake(0, 0, DScreenWidth, DScreenHeight);
    self.backgroundColor = [COLOR_00 colorWithAlphaComponent:0.2];
    [CurrentWindow addSubview:self];
    
    [self addSubview:self.backImgView];
    [self.backImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(DWScale(212));
        make.width.mas_equalTo(DWScale(266));
    }];
    
    [self.backImgView addSubview:self.tipTitleLbl];
    [self.tipTitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backImgView).offset(DWScale(30));
        make.leading.equalTo(self.backImgView).offset(DWScale(20));
        make.trailing.equalTo(self.backImgView).offset(-DWScale(20));
        make.height.mas_equalTo(DWScale(22));
    }];
    
    [self.backImgView addSubview:self.tipSubTitleLbl];
    [self.tipSubTitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tipTitleLbl.mas_bottom).offset(DWScale(18));
        make.leading.equalTo(self.backImgView).offset(DWScale(20));
        make.trailing.equalTo(self.backImgView).offset(-DWScale(20));
        make.height.mas_equalTo(DWScale(20));
    }];
    
    [self.backImgView addSubview:self.forceUpdateTipsLbl];
    [self.forceUpdateTipsLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tipSubTitleLbl.mas_bottom);
        make.leading.equalTo(self.backImgView).offset(DWScale(20));
        make.trailing.equalTo(self.backImgView).offset(-DWScale(20));
        make.height.mas_equalTo(DWScale(20));
    }];
    
    /** 更新的说明内容 */
    [self.backImgView addSubview:self.contentScroll];
    [self.contentScroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.forceUpdateTipsLbl.mas_bottom).offset(DWScale(10));
        make.leading.equalTo(self.backImgView).offset(DWScale(20));
        make.trailing.equalTo(self.backImgView).offset(DWScale(-20));
        make.bottom.equalTo(self.backImgView).offset(DWScale(-108));
    }];
    
    [self.contentScroll addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentScroll);
        make.width.equalTo(self.contentScroll);//这个不能省略
    }];
    
    [self.containerView addSubview:self.contentLbl];
    [self.contentLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView).offset(DWScale(10));
        make.leading.equalTo(self.containerView).offset(DWScale(10));
        make.trailing.equalTo(self.containerView).offset(DWScale(-10));
        make.bottom.equalTo(self.containerView).offset(DWScale(-10));
    }];
    
    [self.backImgView addSubview:self.updateBtn];
    [self.updateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentScroll.mas_bottom).offset(DWScale(10));
        make.leading.equalTo(self.backImgView).offset(DWScale(20));
        make.trailing.equalTo(self.backImgView).offset(DWScale(-20));
        make.height.mas_equalTo(DWScale(34));
    }];
    
    [self.backImgView addSubview:self.laterBtn];
    [self.laterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.updateBtn.mas_bottom).offset(DWScale(10));
        make.leading.equalTo(self.backImgView).offset(DWScale(20));
        make.trailing.equalTo(self.backImgView).offset(DWScale(-20));
        make.height.mas_equalTo(DWScale(34));
    }];
}

#pragma mark - Setter
- (void)setIsCompelUpdate:(BOOL)isCompelUpdate {
    _isCompelUpdate = isCompelUpdate;
    if (_isCompelUpdate) {
        //强制更新
        [self.forceUpdateTipsLbl mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(DWScale(20));
        }];
        [_laterBtn setTitle:LanguageToolMatch(@"退出软件") forState:UIControlStateNormal];
    } else {
        //非强制跟新
        [self.forceUpdateTipsLbl mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(DWScale(0));
        }];
        [_laterBtn setTitle:LanguageToolMatch(@"暂不更新") forState:UIControlStateNormal];
    }
}

- (void)setVersionNumStr:(NSString *)versionNumStr {
    _versionNumStr = versionNumStr;
    self.tipSubTitleLbl.text = [NSString stringWithFormat:LanguageToolMatch(@"升级到最新版本v %@"), versionNumStr];
}

- (void)setUpdateDes:(NSString *)updateDes {
    _updateDes = updateDes;
    
    //实际收到的 字符串 是带有 换行字符 的(即 \\n )，因此需要对字符串进行替换，将 \\n 替换为 \n
    NSString *resultUpdateDes = [_updateDes stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    _contentLbl.text = resultUpdateDes;
    [_contentLbl changeLineSpace:5];
}

#pragma mark - Action
- (void)updateVersionViewShow {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.backImgView.transform = CGAffineTransformIdentity;
    }];
}

- (void)updateVersionViewDismiss {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.backImgView.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN, CGFLOAT_MIN);
    } completion:^(BOOL finished) {
        [[MMKV defaultMMKV] setObject:@(YES) forKey:[NSString stringWithFormat:@"ignore_%@", self.versionNumStr]];
        NSArray *subViews = [weakSelf.backImgView subviews];
        if([subViews count] != 0) {
            [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        [weakSelf.backImgView removeFromSuperview];
        weakSelf.backImgView = nil;
        [weakSelf removeFromSuperview];
    }];
}

//立即更新
- (void)updateNowAction {
    NSURL *downloadAppURL = nil;
    if (![NSString isNil:self.storeUrl]) {
        downloadAppURL = [self.storeUrl getApiHostFullUrl];
    } else {
        downloadAppURL = [NSURL URLWithString:APP_IN_APPLE_STORE_URL];
    }
    //立即更新 跳转到 App Store
    [[UIApplication sharedApplication] openURL:downloadAppURL options:@{} completionHandler:nil];
    if (_isCompelUpdate == NO) {
        //非强制更新，点击立即更新按钮后，弹窗自动关闭
        [self updateVersionViewDismiss];
    }
}

//暂不更新/退出软件
- (void)updateLaterAction {
    if (_isCompelUpdate == NO) {
        //非强制更新，弹窗自动关闭
        [self updateVersionViewDismiss];
    } else {
        //强制更新，退出软件(相当于按了Home键)
        [[UIApplication sharedApplication] performSelector:@selector(suspend)];
    }
}

#pragma mark - Lazy
- (UIImageView *)backImgView {
    if (!_backImgView) {
        _backImgView = [[UIImageView alloc] init];
        _backImgView.tkThemeimages = @[ImgNamed(@"update_version_bg"), ImgNamed(@"update_version_bg_dark")];
        [_backImgView rounded:15];
        _backImgView.userInteractionEnabled = YES;
        _backImgView.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN, CGFLOAT_MIN);
    }
    return _backImgView;
}

- (UILabel *)tipTitleLbl {
    if (!_tipTitleLbl) {
        _tipTitleLbl = [[UILabel alloc] init];
        _tipTitleLbl.preferredMaxLayoutWidth = DWScale(226);
        //富文本
        NSString *tipsTitleStr = LanguageToolMatch(@"发现新版本");
        NSMutableAttributedString *tipsTitleAtt = [[NSMutableAttributedString alloc] initWithString:tipsTitleStr];
        tipsTitleAtt.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
            UIColor *color = nil;
            if (themeIndex == 0) {
                color = COLOR_11;
            } else {
                color = COLORWHITE;
            }
            [(NSMutableAttributedString *)itself addAttributes:@{NSForegroundColorAttributeName : color} range:NSMakeRange(0, tipsTitleStr.length)];
        };
        [tipsTitleAtt addAttributes:@{NSFontAttributeName : FONTB(16)} range:NSMakeRange(0, tipsTitleStr.length)];
        //插入的图片
        NSTextAttachment *attch = [[NSTextAttachment alloc] init];
        attch.image = [UIImage imageNamed:@"update_title_tips"];
        attch.bounds = CGRectMake(DWScale(2), -DWScale(2), DWScale(26), DWScale(18));
        NSAttributedString *imgAtt = [NSAttributedString attributedStringWithAttachment:attch];
        [tipsTitleAtt insertAttributedString:imgAtt atIndex:tipsTitleStr.length];
        
        _tipTitleLbl.attributedText = tipsTitleAtt;
    }
    return _tipTitleLbl;
}

- (UILabel *)tipSubTitleLbl {
    if (!_tipSubTitleLbl) {
        _tipSubTitleLbl = [[UILabel alloc] init];
        _tipSubTitleLbl.text = @"";
        _tipSubTitleLbl.tkThemetextColors = @[COLOR_66, COLOR_99];
        _tipSubTitleLbl.font = FONTN(14);
        _tipSubTitleLbl.textAlignment = NSTextAlignmentLeft;
    }
    return _tipSubTitleLbl;
}

- (UILabel *)forceUpdateTipsLbl {
    if (!_forceUpdateTipsLbl) {
        _forceUpdateTipsLbl = [[UILabel alloc] init];
        _forceUpdateTipsLbl.text = LanguageToolMatch(@"如果不更新将无法使用客户端！");
        _forceUpdateTipsLbl.tkThemetextColors = @[COLOR_F93A2F, COLOR_F93A2F];
        _forceUpdateTipsLbl.font = FONTN(14);
        _forceUpdateTipsLbl.textAlignment = NSTextAlignmentLeft;
    }
    return _forceUpdateTipsLbl;
}

- (UIScrollView *)contentScroll {
    if (!_contentScroll) {
        _contentScroll = [[UIScrollView alloc] init];
        _contentScroll.tkThemebackgroundColors = @[COLORWHITE, COLOR_4E5760_DARK];
        _contentScroll.showsVerticalScrollIndicator = YES;
        _contentScroll.showsHorizontalScrollIndicator = NO;
        [_contentScroll rounded:DWScale(4)];
    }
    return _contentScroll;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = COLOR_CLEAR;
    }
    return _containerView;
}

- (UILabel *)contentLbl {
    if (!_contentLbl) {
        _contentLbl = [[UILabel alloc] init];
        _contentLbl.text = @"";
        _contentLbl.tkThemetextColors = @[COLOR_66, COLOR_99];
        _contentLbl.font = FONTN(12);
        _contentLbl.numberOfLines = 0;
        [_contentLbl changeLineSpace:5];
        _contentLbl.textAlignment = NSTextAlignmentLeft;
    }
    return _contentLbl;
}

- (UIButton *)updateBtn {
    if (!_updateBtn) {
        _updateBtn = [[UIButton alloc] init];
        [_updateBtn setTitle:LanguageToolMatch(@"立即更新") forState:UIControlStateNormal];
        [_updateBtn setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
        [_updateBtn rounded:DWScale(4)];
        _updateBtn.titleLabel.font = FONTN(14);
        _updateBtn.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
        [_updateBtn addTarget:self action:@selector(updateNowAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _updateBtn;
}

- (UIButton *)laterBtn {
    if (!_laterBtn) {
        _laterBtn = [[UIButton alloc] init];
        [_laterBtn setTitle:LanguageToolMatch(@"暂不更新") forState:UIControlStateNormal];
        [_laterBtn setTkThemeTitleColor:@[COLOR_66, COLORWHITE] forState:UIControlStateNormal];
        [_laterBtn rounded:DWScale(4)];
        _laterBtn.titleLabel.font = FONTN(14);
        _laterBtn.tkThemebackgroundColors = @[COLOR_F4F5F6, COLOR_41454A_DARK];
        [_laterBtn addTarget:self action:@selector(updateLaterAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _laterBtn;
}

@end
