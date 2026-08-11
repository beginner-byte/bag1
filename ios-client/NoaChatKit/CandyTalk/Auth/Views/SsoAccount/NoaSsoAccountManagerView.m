//
//  NoaSsoAccountManagerView.m
//  NoaChatKit
//
//  Created by phl on 2025/11/5.
//

#import "NoaSsoAccountManagerView.h"
#import "JXCategoryTitleView.h"
#import "JXCategoryIndicatorLineView.h"

@interface NoaSsoAccountManagerView ()<JXCategoryViewDelegate, UITextFieldDelegate>

/// popWindows时的顶部Label
@property (nonatomic, strong) UILabel *popTopTitleLabel;

/// 顶部切换
@property (nonatomic, strong) JXCategoryTitleView *ssoTypeCategoryView;

/// 邀请码选择类型
@property (nonatomic, assign) ZSsoTypeMenu ssoType;

/// 邀请码输入
@property (nonatomic, strong) UITextField *ssoAccountTF;

/// ip输入
@property (nonatomic, strong) UITextField *ipTF;

/// ip与端口号之间的:
@property (nonatomic, strong) UILabel *ipAndPortLabel;

/// 端口号
@property (nonatomic, strong) UITextField *portTF;

/// 邀请码背景
@property (nonatomic, strong) UIView *ssoAccountBgView;

/// ip+端口背景
@property (nonatomic, strong) UIView *ipAndPortBgView;

/// popWindows时，邀请码输入Label、ip域名Label下部提示Label
@property (nonatomic, strong) UILabel *popBottomTipLabel;

/// 加入
@property (nonatomic, strong) UIButton *joinBtn;

/// 扫一扫加入服务器按钮
@property (nonatomic, strong) UIButton *scanBtn;

/// 帮助
@property (nonatomic, strong) UIButton *helpBtn;

/// 网络检测
@property (nonatomic, strong) UIButton *networkDetectionBtn;

@end

@implementation NoaSsoAccountManagerView

#pragma mark - Lazy Loading

- (UILabel *)popTopTitleLabel {
    if (!_popTopTitleLabel) {
        _popTopTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _popTopTitleLabel.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _popTopTitleLabel.font = FONTSB(20);
        _popTopTitleLabel.text = LanguageToolMatch(@"邀请码加入");
    }
    return _popTopTitleLabel;
}

- (JXCategoryTitleView *)ssoTypeCategoryView {
    if (!_ssoTypeCategoryView) {
        _ssoTypeCategoryView = [JXCategoryTitleView new];
        _ssoTypeCategoryView.delegate = self;
        _ssoTypeCategoryView.titles = @[LanguageToolMatch(@"邀请码"), LanguageToolMatch(@"IP/域名")];
        _ssoTypeCategoryView.titleColor = COLOR_00;
        _ssoTypeCategoryView.titleSelectedColor = COLOR_5966F2;
        // 设置 title 字体大小（影响 title 高度）
        _ssoTypeCategoryView.titleFont = FONTSB(16);
        _ssoTypeCategoryView.titleSelectedFont = FONTM(16);
        // 设置 title 垂直偏移量（正值向下，负值向上）
        // _ssoTypeCategoryView.titleLabelVerticalOffset = 0;
        _ssoTypeCategoryView.titleColorGradientEnabled = YES;
        _ssoTypeCategoryView.averageCellSpacingEnabled = NO;
        _ssoTypeCategoryView.contentEdgeInsetLeft = 12;
        _ssoTypeCategoryView.contentEdgeInsetRight = 12;
        _ssoTypeCategoryView.cellSpacing = 24;
        // 默认第一个
        _ssoTypeCategoryView.defaultSelectedIndex = 0;
        JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
        // 设置指示器固定宽度
        lineView.indicatorWidth = 36;
        lineView.indicatorCornerRadius = 2;
        lineView.indicatorHeight = 3;
        lineView.indicatorColor = COLOR_5966F2;
        // 设置指示器位置（底部）
        lineView.componentPosition = JXCategoryComponentPosition_Bottom;
        _ssoTypeCategoryView.indicators = @[lineView];
    }
    return _ssoTypeCategoryView;
}

- (UITextField *)ssoAccountTF {
    if (!_ssoAccountTF) {
        _ssoAccountTF = [[UITextField alloc] initWithFrame:CGRectZero];
        // 设置圆角
        _ssoAccountTF.layer.cornerRadius = 16;
        _ssoAccountTF.layer.masksToBounds = YES;
        // 设置边框
        _ssoAccountTF.layer.borderWidth = 1.0;
        _ssoAccountTF.layer.tkThemeborderColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.05], [COLORWHITE colorWithAlphaComponent:0.4]];
        _ssoAccountTF.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _ssoAccountTF.keyboardType = UIKeyboardTypeASCIICapable;
        _ssoAccountTF.delegate = self;
        // 创建属性字符串
        NSDictionary *attributes = @{
            NSForegroundColorAttributeName: COLOR_99,
            NSFontAttributeName:FONTM(14)
        };
        _ssoAccountTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LanguageToolMatch(@"请输入邀请码") attributes:attributes];
        
        // 获取当前首选语言，判断是否为阿拉伯语(ar)或波斯语(fa)
        NSString *preferredLanguage = [NSLocale preferredLanguages].firstObject;
        BOOL isArabic = ([preferredLanguage hasPrefix:@"ar"] || [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"阿拉伯语"]); // 阿拉伯语代码以"ar"开头
        BOOL isPersian = ([preferredLanguage hasPrefix:@"fa"] || [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"波斯语"]); // 波斯语代码以"fa"开头
        
        // 左侧占用12个单位像素(阿拉伯语语波斯语在右侧)
        if (isArabic || isPersian) {
            // 设置左边文字距离左边框间隔
            _ssoAccountTF.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
            _ssoAccountTF.rightViewMode = UITextFieldViewModeAlways;
        } else {
            // 设置左边文字距离左边框间隔
            _ssoAccountTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
            _ssoAccountTF.leftViewMode = UITextFieldViewModeAlways;
        }
    }
    return _ssoAccountTF;
}

- (UITextField *)ipTF {
    if (!_ipTF) {
        _ipTF = [[UITextField alloc] initWithFrame:CGRectZero];
        _ipTF.tkThemebackgroundColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.05], [COLOR_5966F2_DARK colorWithAlphaComponent:0.05]];
        _ipTF.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        // 设置圆角
        _ipTF.layer.cornerRadius = 16;
        _ipTF.layer.masksToBounds = YES;
        // 设置边框
        _ipTF.layer.borderWidth = 1.0;
        _ipTF.layer.tkThemeborderColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.05], [COLORWHITE colorWithAlphaComponent:0.4]];
        _ipTF.keyboardType = UIKeyboardTypeASCIICapable;
        _ipTF.delegate = self;
        // 创建属性字符串
        NSDictionary *attributes = @{
            NSForegroundColorAttributeName: COLOR_99,
            NSFontAttributeName:FONTM(14)
        };
        _ipTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LanguageToolMatch(@"IP/域名") attributes:attributes];
        
        // 获取当前首选语言，判断是否为阿拉伯语(ar)或波斯语(fa)
        NSString *preferredLanguage = [NSLocale preferredLanguages].firstObject;
        BOOL isArabic = ([preferredLanguage hasPrefix:@"ar"] || [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"阿拉伯语"]); // 阿拉伯语代码以"ar"开头
        BOOL isPersian = ([preferredLanguage hasPrefix:@"fa"] || [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"波斯语"]); // 波斯语代码以"fa"开头
        
        // 左侧占用12个单位像素(阿拉伯语语波斯语在右侧)
        if (isArabic || isPersian) {
            // 设置左边文字距离左边框间隔
            _ipTF.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
            _ipTF.rightViewMode = UITextFieldViewModeAlways;
        } else {
            // 设置左边文字距离左边框间隔
            _ipTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
            _ipTF.leftViewMode = UITextFieldViewModeAlways;
        }
    }
    return _ipTF;
}

- (UILabel *)ipAndPortLabel {
    if (!_ipAndPortLabel) {
        _ipAndPortLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _ipAndPortLabel.text = @":";
        _ipAndPortLabel.tkThemetextColors = @[COLOR_00, COLOR_00_DARK];
        _ipAndPortLabel.font = FONTN(16);
        _ipAndPortLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _ipAndPortLabel;
}

- (UILabel *)popBottomTipLabel {
    if (!_popBottomTipLabel) {
        _popBottomTipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _popBottomTipLabel.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _popBottomTipLabel.font = FONTR(12);
        _popBottomTipLabel.text = LanguageToolMatch(@"请输入您企业专属的邀请码或IP/域名");
    }
    return _popBottomTipLabel;
}

- (UITextField *)portTF {
    if (!_portTF) {
        _portTF = [[UITextField alloc] initWithFrame:CGRectZero];
        _portTF.tkThemebackgroundColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.05], [COLOR_5966F2_DARK colorWithAlphaComponent:0.05]];
        _portTF.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        // 设置圆角
        _portTF.layer.cornerRadius = 16;
        _portTF.layer.masksToBounds = YES;
        // 设置边框
        _portTF.layer.borderWidth = 1.0;
        _portTF.layer.tkThemeborderColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.05], [COLORWHITE colorWithAlphaComponent:0.4]];
        _portTF.keyboardType = UIKeyboardTypeNumberPad;
        _portTF.delegate = self;
        // 创建属性字符串
        NSDictionary *attributes = @{
            NSForegroundColorAttributeName: COLOR_99,
            NSFontAttributeName:FONTM(14)
        };
        _portTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LanguageToolMatch(@"端口号") attributes:attributes];
        
        // 获取当前首选语言，判断是否为阿拉伯语(ar)或波斯语(fa)
        NSString *preferredLanguage = [NSLocale preferredLanguages].firstObject;
        BOOL isArabic = ([preferredLanguage hasPrefix:@"ar"] || [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"阿拉伯语"]); // 阿拉伯语代码以"ar"开头
        BOOL isPersian = ([preferredLanguage hasPrefix:@"fa"] || [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"波斯语"]); // 波斯语代码以"fa"开头
        
        // 左侧占用12个单位像素(阿拉伯语语波斯语在右侧)
        if (isArabic || isPersian) {
            // 设置左边文字距离左边框间隔
            _portTF.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
            _portTF.rightViewMode = UITextFieldViewModeAlways;
        } else {
            // 设置左边文字距离左边框间隔
            _portTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
            _portTF.leftViewMode = UITextFieldViewModeAlways;
        }
    }
    return _portTF;
}

- (UIView *)ssoAccountBgView {
    if (!_ssoAccountBgView) {
        _ssoAccountBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _ssoAccountBgView.layer.cornerRadius = 16;
        _ssoAccountBgView.layer.masksToBounds = YES;
        _ssoAccountBgView.tkThemebackgroundColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.05], [COLOR_5966F2_DARK colorWithAlphaComponent:0.05]];
    }
    return _ssoAccountBgView;
}

- (UIView *)ipAndPortBgView {
    if (!_ipAndPortBgView) {
        _ipAndPortBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _ipAndPortBgView.hidden = YES;
    }
    return _ipAndPortBgView;
}

- (UIButton *)joinBtn {
    if (!_joinBtn) {
        _joinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_joinBtn setTitle:LanguageToolMatch(@"加入") forState:UIControlStateNormal];
        [_joinBtn setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
        _joinBtn.titleLabel.font = FONTM(14);
        _joinBtn.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
        _joinBtn.layer.cornerRadius = 16;
        _joinBtn.layer.masksToBounds = YES;
    }
    return _joinBtn;
}

- (UIButton *)scanBtn {
    if (!_scanBtn) {
        _scanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_scanBtn setTitle:LanguageToolMatch(@"扫一扫加入服务器") forState:UIControlStateNormal];
        [_scanBtn setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateNormal];
        [_scanBtn setImage:ImgNamed(@"icon_sso_scan") forState:UIControlStateNormal];
        _scanBtn.titleLabel.font = FONTM(14);
        [_scanBtn setBtnImageAlignmentType:ButtonImageAlignmentTypeLeft imageSpace:4];
        _scanBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    return _scanBtn;
}

- (UIButton *)helpBtn {
    if (!_helpBtn) {
        _helpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_helpBtn setTitle:LanguageToolMatch(@"帮助") forState:UIControlStateNormal];
        [_helpBtn setTkThemeTitleColor:@[COLOR_11, COLOR_11_DARK] forState:UIControlStateNormal];
        [_helpBtn setImage:ImgNamed(@"icon_sso_help") forState:UIControlStateNormal];
        _helpBtn.titleLabel.font = FONTM(13);
        [_helpBtn setBtnImageAlignmentType:ButtonImageAlignmentTypeRight imageSpace:6];
        _helpBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }
    return _helpBtn;
}

- (UIButton *)networkDetectionBtn {
    if (!_networkDetectionBtn) {
        _networkDetectionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_networkDetectionBtn setTitle:LanguageToolMatch(@"网络检测") forState:UIControlStateNormal];
        [_networkDetectionBtn setImage:ImgNamed(@"icon_network_detection") forState:UIControlStateNormal];
        [_networkDetectionBtn setTkThemeTitleColor:@[COLOR_66, COLOR_66_DARK] forState:UIControlStateNormal];
        _networkDetectionBtn.titleLabel.font = FONTN(16);
        [_networkDetectionBtn setBtnImageAlignmentType:ButtonImageAlignmentTypeLeft imageSpace:DWScale(10)];
        // TODO: 暂时隐藏,后期网络检测业务完成HTTPDNS处理后再进行展示
        _networkDetectionBtn.hidden = YES;
    }
    return _networkDetectionBtn;
}

- (instancetype)initWithFrame:(CGRect)frame
                 IsPopWindows:(BOOL)isPopWindows {
    self = [super initWithFrame:frame IsPopWindows:isPopWindows];
    if (self) {
        [self setupView];
        [self processData];
    }
    return self;
}

- (void)setupView {
    if (self.isPopWindows) {
        [self configurePopWindows];
    }else {
        [self configureFullScreenView];
    }
}

- (void)configurePopWindows {
    [self addSubview:self.popTopTitleLabel];
    [self.popTopTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@30);
        make.leading.equalTo(@17.5);
        make.trailing.equalTo(self).offset(-17.5);
        make.height.equalTo(@32);
    }];
    
    [self addSubview:self.ssoTypeCategoryView];
    [self.ssoTypeCategoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.popTopTitleLabel.mas_bottom).offset(30);
        make.leading.equalTo(@20);
        make.height.greaterThanOrEqualTo(@36);
        make.width.equalTo(@200);
    }];
    
    // 默认展示邀请码输入
    [self addSubview:self.ssoAccountBgView];
    [self.ssoAccountBgView addSubview:self.ssoAccountTF];
    
    // ip/域名
    [self addSubview:self.ipAndPortBgView];
    [self.ipAndPortBgView addSubview:self.ipTF];
    [self.ipAndPortBgView addSubview:self.ipAndPortLabel];
    [self.ipAndPortBgView addSubview:self.portTF];
    
    [self.ssoAccountBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.ssoTypeCategoryView.mas_bottom).offset(16);
        make.leading.equalTo(@20);
        make.trailing.equalTo(self).offset(-20);
        make.height.equalTo(@58);
    }];
    
    [self.ssoAccountTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.ssoAccountBgView);
        make.leading.equalTo(@0);
        make.trailing.equalTo(self.ssoAccountBgView);
        make.height.equalTo(self.ssoAccountBgView);
    }];
    
    [self.ipAndPortBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.ssoTypeCategoryView.mas_bottom).offset(16);
        make.leading.equalTo(@20);
        make.trailing.equalTo(self).offset(-20);
        make.height.equalTo(@58);
    }];
    
    [self.ipTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.ssoAccountBgView);
        make.leading.equalTo(@0);
        make.trailing.equalTo(self.ipAndPortLabel.mas_leading);
        make.height.equalTo(self.ssoAccountBgView);
    }];
    
    [self.ipAndPortLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.ssoAccountBgView);
        make.trailing.equalTo(self.portTF.mas_leading);
        make.width.equalTo(@16);
        make.height.equalTo(self.ssoAccountBgView);
    }];
    
    [self.portTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.ssoAccountBgView);
        make.trailing.equalTo(self.ipAndPortBgView);
        make.width.equalTo(@95);
        make.height.equalTo(self.ssoAccountBgView);
    }];
    
    [self addSubview:self.popBottomTipLabel];
    [self.popBottomTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.ssoAccountBgView.mas_bottom).offset(12);
        make.leading.equalTo(@33.5);
        make.trailing.equalTo(self).offset(-33.5);
        make.height.equalTo(@12);
    }];
    
    [self addSubview:self.joinBtn];
    [self addSubview:self.scanBtn];
    [self addSubview:self.helpBtn];
    [self.joinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.ssoAccountBgView.mas_bottom).offset(72);
        make.leading.equalTo(@20);
        make.trailing.equalTo(self).offset(-20);
        make.height.equalTo(@54);
    }];
    
    [self.scanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.joinBtn.mas_bottom).offset(12);
        make.leading.equalTo(@26);
        make.width.greaterThanOrEqualTo(@132);
        make.trailing.greaterThanOrEqualTo(self.helpBtn.mas_leading).offset(-20);
        make.height.equalTo(@16);
    }];
    
    CGFloat helpTextWidth = [self calculateButtonWidthForText:self.helpBtn.titleLabel.text font:self.helpBtn.titleLabel.font];
    CGFloat helpBtnWidth = MAX(46, helpTextWidth + 4 + 16);
   
    [self.helpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scanBtn);
        make.trailing.equalTo(self).offset(-26);
        make.width.equalTo(@(helpBtnWidth));
        make.height.equalTo(@16);
    }];
}

- (void)configureFullScreenView {
    [self addSubview:self.ssoTypeCategoryView];
    [self.ssoTypeCategoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@20);
        make.top.equalTo(@30);
        make.height.greaterThanOrEqualTo(@36);
        make.width.equalTo(@200);
    }];
    
    // 默认展示邀请码输入
    [self addSubview:self.ssoAccountBgView];
    [self.ssoAccountBgView addSubview:self.ssoAccountTF];
    
    // ip/域名
    [self addSubview:self.ipAndPortBgView];
    [self.ipAndPortBgView addSubview:self.ipTF];
    [self.ipAndPortBgView addSubview:self.ipAndPortLabel];
    [self.ipAndPortBgView addSubview:self.portTF];
    
    [self.ssoAccountBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.ssoTypeCategoryView.mas_bottom).offset(16);
        make.leading.equalTo(@20);
        make.trailing.equalTo(self).offset(-20);
        make.height.equalTo(@58);
    }];
    
    [self.ssoAccountTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.ssoAccountBgView);
        make.leading.equalTo(@0);
        make.trailing.equalTo(self.ssoAccountBgView);
        make.height.equalTo(self.ssoAccountBgView);
    }];
    
    [self.ipAndPortBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.ssoTypeCategoryView.mas_bottom).offset(16);
        make.leading.equalTo(@20);
        make.trailing.equalTo(self).offset(-20);
        make.height.equalTo(@58);
    }];
    
    [self.ipTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.ssoAccountBgView);
        make.leading.equalTo(@0);
        make.trailing.equalTo(self.ipAndPortLabel.mas_leading);
        make.height.equalTo(self.ssoAccountBgView);
    }];
    
    [self.ipAndPortLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.ssoAccountBgView);
        make.trailing.equalTo(self.portTF.mas_leading);
        make.width.equalTo(@16);
        make.height.equalTo(self.ssoAccountBgView);
    }];
    
    [self.portTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.ssoAccountBgView);
        make.trailing.equalTo(self.ipAndPortBgView);
        make.width.equalTo(@95);
        make.height.equalTo(self.ssoAccountBgView);
    }];
    
    
    [self addSubview:self.joinBtn];
    [self addSubview:self.scanBtn];
    [self addSubview:self.helpBtn];
    [self.joinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.ssoAccountBgView.mas_bottom).offset(48);
        make.leading.equalTo(@20);
        make.trailing.equalTo(self).offset(-20);
        make.height.equalTo(@54);
    }];
    
    [self.scanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.joinBtn.mas_bottom).offset(12);
        make.leading.equalTo(@26);
        make.width.greaterThanOrEqualTo(@132);
        make.trailing.greaterThanOrEqualTo(self.helpBtn.mas_leading).offset(-20);
        make.height.equalTo(@16);
    }];
    
    CGFloat helpTextWidth = [self calculateButtonWidthForText:self.helpBtn.titleLabel.text font:self.helpBtn.titleLabel.font];
    CGFloat helpBtnWidth = MAX(46, helpTextWidth + 4 + 16);
   
    [self.helpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scanBtn);
        make.trailing.equalTo(self).offset(-26);
        make.width.equalTo(@(helpBtnWidth));
        make.height.equalTo(@16);
    }];
    
    [self addSubview:self.networkDetectionBtn];
    [self.networkDetectionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        // 24为与版本号展示间隔，22为高度
        make.bottom.equalTo(self).offset(-(DHomeBarH + 24 + 22));
    }];
}

- (void)processData {
    // 默认是输入邀请码
    self.ssoType = ZSsoTypeMenuCompanyId;
    
    @weakify(self)
    
    // 暗黑模式切换
    self.ssoTypeCategoryView.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        @strongify(self)
        if (themeIndex == 0) {
            self.ssoTypeCategoryView.titleColor = COLOR_00;
            self.ssoTypeCategoryView.titleSelectedColor = COLOR_5966F2;
        }else {
            self.ssoTypeCategoryView.titleColor = COLOR_00_DARK;
            self.ssoTypeCategoryView.titleSelectedColor = COLOR_5966F2_DARK;
        }
        // 不刷新颜色不生效
        [self.ssoTypeCategoryView reloadDataWithoutListContainer];
    };
    
    // 根据 ssoType 类型动态决定启用按钮的条件
    // 如果 ssoType 为 ZSsoTypeMenuCompanyId，检查 ssoAccountTF 是否有值
    // 如果 ssoType 为 ZSsoTypeMenuIPAndDomain，检查 ipTF 是否有值
    RAC(self.joinBtn, enabled) = [RACSignal
                                  combineLatest:@[
        RACObserve(self, ssoType),
        self.ssoAccountTF.rac_textSignal,
        self.ipTF.rac_textSignal] reduce:^NSNumber *(NSNumber *ssoType, NSString *ssoAccountText, NSString *ipText) {
        @strongify(self)
        
        ZSsoTypeMenu type = [ssoType integerValue];
        BOOL enabled = NO;
        
        if (type == ZSsoTypeMenuCompanyId) {
            // 邀请码模式：检查邀请码输入框是否有值
            enabled = (ssoAccountText && ssoAccountText.length > 0);
        } else if (type == ZSsoTypeMenuIPAndDomain) {
            // IP/域名模式：检查 IP 输入框是否有值
            enabled = (ipText && ipText.length > 0);
        }
        
        self.joinBtn.alpha = enabled ? 1.0 : 0.7;
        
        return @(enabled);
    }];
    
    [[self.joinBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        NSString *ssoStr = @"";
        if (self.ssoType == ZSsoTypeMenuCompanyId) {
            // 邀请码类型
            ssoStr = [NSString isNil:self.ssoAccountTF.text] ? @"" : [self.ssoAccountTF.text lowercaseString];
            if (self.clickLoginBtnAction) {
                self.clickLoginBtnAction(self.ssoType, ssoStr);
            }
        }else if (self.ssoType == ZSsoTypeMenuIPAndDomain) {
            // ip域名类型
            NSString *ip = [NSString isNil:self.ipTF.text] ? @"" : self.ipTF.text;
            NSString *port = [NSString isNil:self.portTF.text] ? @"" : self.portTF.text;
            if (ip.length == 0) {
                if (self.clickLoginBtnAction) {
                    self.clickLoginBtnAction(self.ssoType, ssoStr);
                }
                return;
            }
            ssoStr = ip;
            if (port.length > 0) {
                ssoStr = [ssoStr stringByAppendingFormat:@":%@", port];
            }
            if (self.clickLoginBtnAction) {
                self.clickLoginBtnAction(self.ssoType, ssoStr);
            }
        }else {
            // 未知类型
            if (self.clickLoginBtnAction) {
                self.clickLoginBtnAction(self.ssoType, @"");
            }
        }
    }];
    
    [[self.scanBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        if (self.clickScanBtnAction) {
            self.clickScanBtnAction();
        }
    }];
    
    [[self.helpBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        if (self.clickHelpBtnAction) {
            self.clickHelpBtnAction();
        }
    }];
    
    [[self.networkDetectionBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        
        if (self.ssoType != ZSsoTypeMenuCompanyId) {
            // IP/域名返回空
            if (self.clickNetworkDetectionBtnAction) {
                self.clickNetworkDetectionBtnAction(@"");
            }
            return;
        }
        
        // 邀请码类型，返回邀请码
        NSString *ssoStr = [NSString isNil:self.ssoAccountTF.text] ? @"" : [self.ssoAccountTF.text lowercaseString];
        if (self.clickNetworkDetectionBtnAction) {
            self.clickNetworkDetectionBtnAction(ssoStr);
        }
    }];
}

/// 设置网络检测入口的可用状态。
/// @param enabled YES 显示，NO 隐藏。
- (void)setNetworkDetectionEnabled:(BOOL)enabled {
    self.networkDetectionBtn.hidden = !enabled;
}

- (void)scanQrcodeChangeSsoType:(ZSsoTypeMenu)ssoType
                        SsoInfo:(NSString *)ssoInfo {
    NSString *ssoInfoStr = [NSString isNil:ssoInfo] ? @"" : ssoInfo;
    NSInteger selectIndex = 0;
    switch (ssoType) {
        case ZSsoTypeMenuCompanyId:
            // 邀请码
            selectIndex = 0;
            self.ssoAccountTF.text = ssoInfoStr;
            break;
        case ZSsoTypeMenuIPAndDomain:
            // 域名、ip地址
            selectIndex = 1;
            [self analysicIpAndPortWithIpDomainPort:ssoInfoStr];
            break;
        default:
            // 默认邀请码
            selectIndex = 0;
            self.ssoAccountTF.text = ssoInfoStr;
            break;
    }
    if (self.ssoTypeCategoryView.selectedIndex != selectIndex) {
        // 设置后会触发didSelectedItemAtIndex代理
        [self.ssoTypeCategoryView selectItemAtIndex:selectIndex];
    }
}

/// 根据域名、ip地址分析并回显
/// - Parameter ipDomainPortStr: ip域名地址
- (void)analysicIpAndPortWithIpDomainPort:(NSString *)ipDomainPortStr {
    NSString *resultIpDomainPort = @"";
    if ([ipDomainPortStr containsString:@"http://"]) {
        resultIpDomainPort = [ipDomainPortStr stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    }
    
    if ([resultIpDomainPort containsString:@"https://"]) {
        resultIpDomainPort = [resultIpDomainPort stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    }
    
    NSArray *httpPortArr = [resultIpDomainPort componentsSeparatedByString:@":"];
    if (httpPortArr.count == 2) {
        self.ipTF.text = httpPortArr[0];
        self.portTF.text = httpPortArr[1];
        return;
    }
    
    self.ipTF.text = resultIpDomainPort;
    self.portTF.text = @"";
}

/// MARK: JXCategoryViewDelegate Methods
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    if (index == 0) {
        // 邀请码加入
        self.ssoAccountBgView.hidden = NO;
        self.ipAndPortBgView.hidden = YES;
        self.ssoType = ZSsoTypeMenuCompanyId;
    }else {
        // ip/端口号登录
        self.ssoAccountBgView.hidden = YES;
        self.ipAndPortBgView.hidden = NO;
        self.ssoType = ZSsoTypeMenuIPAndDomain;
    }
}

/// MARK: UITextFieldDelegate Methods
// 使用代理方法实现输入验证（在输入前阻止，用户体验更好）
// 如果需要完全用 RAC 控制，可以使用 rac_textSignal + 后处理，但会有字符短暂出现的问题
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@" "] || [string isEqualToString:@"  "]) {
        // 当输入为空格时，阻止输入
        return NO;
    } else {
        // 允许删除字符
        if ([string isEqualToString:@""]) {
            return YES;
        }
        
        // 判断是哪个输入框
        if (textField == self.ssoAccountTF) {
            // 邀请码输入框：检查新输入的字符是否是数字或字母
            NSCharacterSet *allowedCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
            BOOL isValid = [string rangeOfCharacterFromSet:allowedCharacters].location == NSNotFound;
            return isValid;
        }
        return YES;
    }
}

- (void)textFieldDidPaste:(UITextField *)textField {
    if (textField == self.ssoAccountTF) {
        // textFieldDidPaste 在粘贴之后调用，此时粘贴的内容已经插入到 textField 中
        // 由于正常输入已经在 shouldChangeCharactersInRange 中拦截，所以只需要过滤当前文本中的非法字符
        // 这些非法字符只可能来自粘贴操作
        NSString *currentText = textField.text ?: @"";
        
        // 过滤掉非字母、非数字的字符
        NSCharacterSet *allowedCharacters = [NSCharacterSet alphanumericCharacterSet];
        NSString *filteredText = [[currentText componentsSeparatedByCharactersInSet:[allowedCharacters invertedSet]] componentsJoinedByString:@""];
        
        // 如果过滤后的文本与当前文本不同，说明有非法字符被过滤掉了，需要更新
        if (![filteredText isEqualToString:currentText]) {
            textField.text = filteredText;
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    // 兜底逻辑：过滤空格（防止通过代码直接设置 text 时包含空格）
    NSString *temText = [[textField.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@""];
    if (![temText isEqualToString:textField.text]) {
        textField.text = temText;
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
