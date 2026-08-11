//
//  NoaChatAtBannedView.m
//  NoaKit
//
//  Created by Candy on 2025/7/4.
//

#import "NoaChatAtBannedView.h"

@interface NoaChatAtBannedView()

/// @按钮
@property (nonatomic, strong) UIButton *atBtn;

/// 禁言用户
@property (nonatomic, strong) UIButton *bannedBtn;

/// 清空用户消息
@property (nonatomic, strong) UIButton *cleanUserMessageBtn;

/// 背景
@property (nonatomic, strong) UIView *backView;
@end

@implementation NoaChatAtBannedView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectTapAction:)]];
    
    self.backView.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
    [self addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@108);
        make.height.equalTo(@120);
    }];
    
    [self.backView addSubview:self.atBtn];
    [self.atBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@12);
        make.leading.equalTo(self.backView);
        make.trailing.equalTo(self.backView);
        make.height.equalTo(@28);
    }];
    
    UIView *atBtnline = [UIView new];
    atBtnline.tkThemebackgroundColors = @[COLOR_EEEEEE, COLOR_EEEEEE_DARK];
    [self.backView addSubview:atBtnline];
    [atBtnline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.atBtn.mas_bottom).offset(1);
        make.centerX.equalTo(self.backView);
        make.leading.equalTo(self.backView).offset(12);
        make.trailing.equalTo(self.backView).offset(-12);
        make.height.equalTo(@1);
    }];
    
    [self.backView addSubview:self.bannedBtn];
    [self.bannedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(atBtnline.mas_bottom).offset(2);
        make.leading.equalTo(self.backView);
        make.trailing.equalTo(self.backView);
        make.height.equalTo(@28);
    }];
    
    UIView *bannedBtnline = [UIView new];
    bannedBtnline.tkThemebackgroundColors = @[COLOR_EEEEEE, COLOR_EEEEEE_DARK];
    [self.backView addSubview:bannedBtnline];
    [bannedBtnline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bannedBtn.mas_bottom).offset(1);
        make.centerX.equalTo(self.backView);
        make.leading.equalTo(self.backView).offset(12);
        make.trailing.equalTo(self.backView).offset(-12);
        make.height.equalTo(@1);
    }];
    
    [self.backView addSubview:self.cleanUserMessageBtn];
    [self.cleanUserMessageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bannedBtnline.mas_bottom).offset(2);
        make.leading.equalTo(self.backView);
        make.trailing.equalTo(self.backView);
        make.height.equalTo(@28);
    }];
}

- (void)dissView {
    [self removeFromSuperview];
}

- (void)showWithTargetRect:(CGRect)targetRect {
    [CurrentWindow addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.trailing.mas_equalTo(CurrentWindow);
    }];
    
    [self.backView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(CurrentWindow).offset(40);
        make.top.mas_equalTo(CurrentWindow).offset(33 + targetRect.origin.y);
        make.width.equalTo(@108);
        make.height.equalTo(@120);
    }];
    
    [self.backView setNeedsLayout];
    [self.backView setNeedsDisplay];
    
    self.backView.layer.cornerRadius = DWScale(8);
    self.backView.layer.tkThemeborderColors = @[COLOR_E8E8E8,COLOR_E8E8E8_DARK];
    self.backView.layer.borderWidth = DWScale(0.5);
    self.backView.layer.tkThemeshadowColors = @[[HEXCOLOR(@"000000") colorWithAlphaComponent:0.08], [HEXCOLOR(@"000000") colorWithAlphaComponent:0.08]];
    self.backView.layer.shadowOffset = CGSizeMake(4, 4);
    self.backView.layer.shadowOpacity = 0.1;
}

- (void)atBtnClickEvent {
    if (self.atCallback) {
        self.atCallback();
    }
    [self dissView];
}

- (void)bannedBtnClickEvent {
    if (self.bannedCallback) {
        self.bannedCallback();
    }
    [self dissView];
}

- (void)cleanUserMessageClickEvent {
    if (self.cleanUserMessageCallback) {
        self.cleanUserMessageCallback();
    }
    [self dissView];
}

- (void)selectTapAction:(UITapGestureRecognizer *)tap{
    [self dissView];
}

- (void)setUserName:(NSString *)userName {
    _userName = userName;
    [self.atBtn setTitle:[NSString stringWithFormat:@"@%@",userName] forState:UIControlStateNormal];
}

- (UIButton *)atBtn {
    if (!_atBtn) {
        _atBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_atBtn setTkThemeTitleColor:@[COLOR_66, COLOR_66_DARK] forState:UIControlStateNormal];
        _atBtn.titleLabel.font = FONTN(14);
        [_atBtn addTarget:self action:@selector(atBtnClickEvent) forControlEvents:UIControlEventTouchUpInside];
        _atBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _atBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 0);

    }
    return _atBtn;
}

- (UIButton *)bannedBtn {
    if (!_bannedBtn) {
        _bannedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bannedBtn setTkThemeTitleColor:@[COLOR_66, COLOR_66_DARK] forState:UIControlStateNormal];
        _bannedBtn.titleLabel.font = FONTN(14);
        [_bannedBtn setTitle:LanguageToolMatch(@"永久禁言") forState:UIControlStateNormal];
        [_bannedBtn addTarget:self action:@selector(bannedBtnClickEvent) forControlEvents:UIControlEventTouchUpInside];
        _bannedBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _bannedBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 0);
    }
    return _bannedBtn;
}

- (UIButton *)cleanUserMessageBtn {
    if (!_cleanUserMessageBtn) {
        _cleanUserMessageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cleanUserMessageBtn setTkThemeTitleColor:@[HEXCOLOR(@"FF3333"), HEXCOLOR(@"FF3333")] forState:UIControlStateNormal];
        _cleanUserMessageBtn.titleLabel.font = FONTN(14);
        [_cleanUserMessageBtn setTitle:LanguageToolMatch(@"清空用户消息") forState:UIControlStateNormal];
        [_cleanUserMessageBtn addTarget:self action:@selector(cleanUserMessageClickEvent) forControlEvents:UIControlEventTouchUpInside];
        _cleanUserMessageBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _cleanUserMessageBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 0);
    }
    return _cleanUserMessageBtn;
}

- (UIView *)backView {
    if (_backView == nil) {
        _backView = [[UIView alloc] init];
    }
    return _backView;
}

@end
