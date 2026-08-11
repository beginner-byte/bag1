//
//  NoaChatHistoryHeaderView.m
//  NoaKit
//
//  Created by Candy on 2024/8/12.
//

#import "NoaChatHistoryHeaderView.h"
#import "NoaBaseUserModel.h"

@interface NoaChatHistoryHeaderView ()

@property (nonatomic, strong) UIStackView *backStack;
@property (nonatomic, strong) UILabel *fromTitleLbl;
@property (nonatomic, strong) UIImageView *avatorImgView;
@property (nonatomic, strong) UILabel *moreNumLbl;
@property (nonatomic, strong) UIImageView *arrowImgView;
@property (nonatomic, strong) UIButton *resetButton;

@end

@implementation NoaChatHistoryHeaderView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        [self setupUI];
    }
    return self;
}

#pragma mark - 界面布局
- (void)setupUI {
    [self addSubview:self.backStack];
    [self.backStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(DWScale(6));
        make.leading.equalTo(self.mas_leading).offset(DWScale(16));
        make.height.mas_equalTo(DWScale(26));
    }];
    
    [self.backStack addArrangedSubview:self.fromTitleLbl];
    [self.fromTitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(DWScale(15));
    }];
    
    [self.backStack addArrangedSubview:self.avatorImgView];
    [self.avatorImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(DWScale(18));
        make.height.mas_equalTo(DWScale(18));
    }];
    
    [self.backStack addArrangedSubview:self.moreNumLbl];
    [self.moreNumLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(DWScale(15));
    }];
    
    [self.backStack addArrangedSubview:self.arrowImgView];
    [self.arrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(DWScale(14));
        make.height.mas_equalTo(DWScale(14));
    }];
    
    [self addSubview:self.resetButton];
    [self.resetButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(DWScale(6));
        make.trailing.equalTo(self.mas_trailing).offset(DWScale(-16));
        make.height.mas_equalTo(DWScale(26));
    }];
}

- (void)setUserInfoList:(NSMutableArray *)userInfoList {
    self.arrowImgView.hidden = YES;
    self.moreNumLbl.hidden = YES;
    self.avatorImgView.hidden = YES;
    self.fromTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    self.resetButton.hidden = YES;
    if (userInfoList.count > 0) {
        _userInfoList = userInfoList;
        if (_userInfoList.count == 1) {
            self.fromTitleLbl.tkThemetextColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
            NoaBaseUserModel *userModel = (NoaBaseUserModel *)[_userInfoList firstObject];
            self.avatorImgView.hidden = NO;
            [self.avatorImgView sd_setImageWithURL:[userModel.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
        }
        if (_userInfoList.count > 1) {
            self.fromTitleLbl.tkThemetextColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
            NoaBaseUserModel *userModel = (NoaBaseUserModel *)[_userInfoList lastObject];
            self.avatorImgView.hidden = NO;
            [self.avatorImgView  sd_setImageWithURL:[userModel.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
            self.moreNumLbl.hidden = NO;
            self.moreNumLbl.text = [NSString stringWithFormat:@"+%ld", _userInfoList.count - 1];
        }
        self.resetButton.hidden = NO;
    } else {
        self.arrowImgView.hidden = NO;
        self.fromTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    }
}

#pragma mark - Click Action
- (void)selectUserTapClick {
    if (_delegate && [_delegate respondsToSelector:@selector(headerClickAction)]) {
        [_delegate headerClickAction];
    }
}

- (void)resetButtonClick {
    [self.userInfoList removeAllObjects];
    self.arrowImgView.hidden = NO;
    self.moreNumLbl.hidden = YES;
    self.avatorImgView.hidden = YES;
    self.fromTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    self.resetButton.hidden = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(headerResetAction)]) {
        [_delegate headerResetAction];
    }
}


#pragma mark - Lazy
- (UIStackView *)backStack {
    if (_backStack == nil) {
        _backStack = [[UIStackView alloc] init];
        _backStack.alignment = UIStackViewAlignmentCenter;
        _backStack.distribution = UIStackViewDistributionFill;
        _backStack.axis = UILayoutConstraintAxisHorizontal;
        _backStack.spacing = DWScale(6);
        _backStack.layoutMargins = UIEdgeInsetsMake(0, DWScale(6), 0, DWScale(6));
        _backStack.layoutMarginsRelativeArrangement = YES;
    
        _backStack.tkThemebackgroundColors = @[COLOR_E6E8EF, COLOR_E6E8EF_DARK];
        [_backStack rounded:DWScale(6)];
        
        UITapGestureRecognizer *stackTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectUserTapClick)];
        [_backStack addGestureRecognizer:stackTap];
    }
    return _backStack;
}

- (UILabel *)fromTitleLbl {
    if (_fromTitleLbl == nil) {
        _fromTitleLbl = [[UILabel alloc] init];
        _fromTitleLbl.text = LanguageToolMatch(@"来自用户");
        _fromTitleLbl.font = FONTN(12);
        _fromTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    }
    return _fromTitleLbl;
}

- (UIImageView *)avatorImgView {
    if (_avatorImgView == nil) {
        _avatorImgView = [[UIImageView alloc] init];
        _avatorImgView.image = DefaultAvatar;
        [_avatorImgView rounded:DWScale(18/2)];
        _avatorImgView.hidden = YES;
    }
    return _avatorImgView;
}

- (UILabel *)moreNumLbl {
    if (_moreNumLbl == nil) {
        _moreNumLbl = [[UILabel alloc] init];
        _moreNumLbl.text = @"+1";
        _moreNumLbl.font = FONTN(12);
        _moreNumLbl.tkThemetextColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
        _moreNumLbl.hidden = YES;
    }
    return _moreNumLbl;
}

- (UIImageView *)arrowImgView {
    if (_arrowImgView == nil) {
        _arrowImgView = [[UIImageView alloc] init];
        _arrowImgView.image = ImgNamed(@"chat_history_header_arrow");
    }
    return _arrowImgView;
}

- (UIButton *)resetButton {
    if (_resetButton == nil) {
        _resetButton = [[UIButton alloc] init];
        [_resetButton setTitle:LanguageToolMatch(@"重置") forState:UIControlStateNormal];
        [_resetButton setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateNormal];
        [_resetButton addTarget:self action:@selector(resetButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _resetButton.titleLabel.font = FONTN(14);
        _resetButton.hidden = YES;
    }
    return _resetButton;
}

@end
