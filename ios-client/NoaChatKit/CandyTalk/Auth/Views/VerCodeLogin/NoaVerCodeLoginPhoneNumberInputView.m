//
//  NoaVerCodeLoginPhoneNumberInputView.m
//  NoaChatKit
//
//  Created by phl on 2025/11/18.
//

#import "NoaVerCodeLoginPhoneNumberInputView.h"
#import "NoaFixedSizeRightView.h"
#import "NoaVerCodeLoginDataHandle.h"

@interface NoaVerCodeLoginPhoneNumberInputView ()

/// 手机号码输入容器
@property (nonatomic, strong) UIView *phoneNumberContainerView;

/// 区号展示/切换按钮
@property (nonatomic, strong) UIButton *areaCodeBtn;

/// 手机号码输入框
@property (nonatomic, strong) UITextField *phoneNumberTF;

/// 账号输入清理文本按钮
@property (nonatomic, strong) UIButton *phoneNumberTFClearBtn;

/// 输入验证结果信号（发送 BOOL 值，YES 表示验证通过，NO 表示验证失败）
@property (nonatomic, strong, readwrite) RACSubject<NSNumber *> *phoneNumberValidationResultSignal;

@end

@implementation NoaVerCodeLoginPhoneNumberInputView

#pragma mark - Lazy Loading

- (UIView *)phoneNumberContainerView {
    if (!_phoneNumberContainerView) {
        _phoneNumberContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        _phoneNumberContainerView.tkThemebackgroundColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.05], [COLOR_5966F2_DARK colorWithAlphaComponent:0.05]];
        // 设置圆角
        _phoneNumberContainerView.layer.cornerRadius = 16;
        _phoneNumberContainerView.layer.masksToBounds = YES;
        // 设置边框
        _phoneNumberContainerView.layer.borderWidth = 1.0;
        _phoneNumberContainerView.layer.tkThemeborderColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.05], [COLORWHITE colorWithAlphaComponent:0.4]];
    }
    return _phoneNumberContainerView;
}

- (UIButton *)areaCodeBtn {
    if (!_areaCodeBtn) {
        _areaCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_areaCodeBtn setTkThemeTitleColor:@[COLOR_11, COLOR_11_DARK] forState:UIControlStateNormal];
        _areaCodeBtn.titleLabel.font = FONTM(14);
        _areaCodeBtn.tkThemebackgroundColors = @[UIColor.clearColor, UIColor.clearColor];
    }
    return _areaCodeBtn;
}

- (UITextField *)phoneNumberTF {
    if (!_phoneNumberTF) {
        _phoneNumberTF = [[UITextField alloc] initWithFrame:CGRectZero];
        _phoneNumberTF.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _phoneNumberTF.keyboardType = UIKeyboardTypePhonePad;
        _phoneNumberTF.delegate = self;
        // 创建属性字符串
        NSDictionary *attributes = @{
            NSForegroundColorAttributeName: COLOR_99,
            NSFontAttributeName:FONTM(14)
        };
        _phoneNumberTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LanguageToolMatch(@"请输入手机号") attributes:attributes];
        _phoneNumberTF.tkThemebackgroundColors = @[UIColor.clearColor, UIColor.clearColor];
        
        // 获取当前首选语言，判断是否为阿拉伯语(ar)或波斯语(fa)
        NSString *preferredLanguage = [NSLocale preferredLanguages].firstObject;
        BOOL isArabic = ([preferredLanguage hasPrefix:@"ar"] || [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"阿拉伯语"]); // 阿拉伯语代码以"ar"开头
        BOOL isPersian = ([preferredLanguage hasPrefix:@"fa"] || [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"波斯语"]); // 波斯语代码以"fa"开头
        
        // 左侧占用12个单位像素(阿拉伯语语波斯语在右侧)
        if (isArabic || isPersian) {
            // 设置左边文字距离左边框间隔
            _phoneNumberTF.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
            _phoneNumberTF.rightViewMode = UITextFieldViewModeAlways;
        } else {
            // 设置左边文字距离左边框间隔
            _phoneNumberTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
            _phoneNumberTF.leftViewMode = UITextFieldViewModeAlways;
        }
    }
    return _phoneNumberTF;
}

- (UIButton *)phoneNumberTFClearBtn {
    if (!_phoneNumberTFClearBtn) {
        _phoneNumberTFClearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_phoneNumberTFClearBtn setImage:ImgNamed(@"icon_text_clear") forState:UIControlStateNormal];
    }
    return _phoneNumberTFClearBtn;
}

- (RACSubject<NSNumber *> *)phoneNumberValidationResultSignal {
    if (!_phoneNumberValidationResultSignal) {
        _phoneNumberValidationResultSignal = [RACSubject subject];
        // 将基类的验证信号转发到子类的信号
        @weakify(self)
        [self.validationResultSignal subscribeNext:^(NSNumber *isValid) {
            @strongify(self)
            [self.phoneNumberValidationResultSignal sendNext:isValid];
        }];
    }
    return _phoneNumberValidationResultSignal;
}

- (instancetype)initWithFrame:(CGRect)frame
               CurrentLoginWay:(ZLoginAndRegisterTypeMenu)currentLoginWay {
    self = [super initWithFrame:frame CurrentLoginWay:currentLoginWay];
    if (self) {
        [self setUpUI];
        [self processData];
    }
    return self;
}

- (void)setUpUI {
    [self addSubview:self.phoneNumberContainerView];
    [self.phoneNumberContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.leading.equalTo(@20);
        make.trailing.equalTo(self).offset(-20);
        make.height.equalTo(@58);
    }];
    
    [self.phoneNumberContainerView addSubview:self.areaCodeBtn];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.tkThemebackgroundColors = @[COLOR_D9D9D9, COLORWHITE];
    [self.phoneNumberContainerView addSubview:lineView];
    [self.phoneNumberContainerView addSubview:self.phoneNumberTF];
    
    CGFloat areaCodeTextWidth = [self calculateButtonWidthForText:self.areaCodeBtn.titleLabel.text font:self.areaCodeBtn.titleLabel.font];
    CGFloat areaCodeBtnWidth = MAX(42, areaCodeTextWidth);
    [self.areaCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.leading.equalTo(@4);
        make.width.equalTo(@(areaCodeBtnWidth));
        make.height.equalTo(self.phoneNumberContainerView);
    }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.phoneNumberContainerView);
        make.leading.equalTo(self.areaCodeBtn.mas_trailing);
        make.width.equalTo(@1);
        make.height.equalTo(@17);
    }];
    
    [self.phoneNumberTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.leading.equalTo(lineView.mas_trailing);
        make.trailing.equalTo(self.phoneNumberContainerView).offset(-12);
        make.height.equalTo(self.phoneNumberContainerView);
    }];
    
    // 调用父类的 setupUI 方法
    [super setupUI];
}

- (void)setupRightViewForPhoneNumberTFextField {
    // 创建固定宽高的容器 view
    NoaFixedSizeRightView *containerView = [[NoaFixedSizeRightView alloc] initWithFixedSize:CGSizeMake(42, 57)];
    
    // 清除按钮（只在编辑时显示）
    [containerView addSubview:self.phoneNumberTFClearBtn];

    [self.phoneNumberTFClearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(containerView).offset(-12);
        make.centerY.equalTo(containerView);
        make.width.height.equalTo(@20);
    }];
    
    // 设置 rightView
    self.phoneNumberTF.rightView = containerView;
    self.phoneNumberTF.rightViewMode = UITextFieldViewModeAlways; // 容器始终显示，内部按钮根据状态控制
    
    @weakify(self)
    // 更新清除按钮显示状态的辅助方法
    void (^updateClearButtonVisibility)(void) = ^{
        @strongify(self)
        BOOL shouldShow = self.phoneNumberTF.isEditing && self.phoneNumberTF.text.length > 0;
        self.phoneNumberTFClearBtn.hidden = !shouldShow;
    };
    
    // 监听开始编辑
    [[self.phoneNumberTF rac_signalForControlEvents:UIControlEventEditingDidBegin] subscribeNext:^(__kindof UIControl * _Nullable x) {
        updateClearButtonVisibility();
    }];
    
    // 监听结束编辑
    [[self.phoneNumberTF rac_signalForControlEvents:UIControlEventEditingDidEnd] subscribeNext:^(__kindof UIControl * _Nullable x) {
        updateClearButtonVisibility();
    }];
    
    // 监听文本变化
    [self.phoneNumberTF.rac_textSignal subscribeNext:^(NSString * _Nullable text) {
        updateClearButtonVisibility();
    }];
    
    // 清理账号点击事件
    [[self.phoneNumberTFClearBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        self.phoneNumberTF.text = @"";
        // 通知注册登录按钮状态变化
        [self.validationResultSignal sendNext:@NO];
    }];
}

- (void)processData {
    // 调用父类的 processData 方法
    [super processData];
    
    // 处理区号按钮点击事件
    @weakify(self)
    [[self.areaCodeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        if (self.clickChangeAreaCodeBtnAction) {
            self.clickChangeAreaCodeBtnAction();
        }
    }];
}

- (void)refreshAreaCode:(NSString *)areaCode {
    [self.areaCodeBtn setTitle:areaCode forState:UIControlStateNormal];
    
    // 重新设置布局，避免展示...
    CGFloat areaCodeTextWidth = [self calculateButtonWidthForText:self.areaCodeBtn.titleLabel.text font:self.areaCodeBtn.titleLabel.font];
    CGFloat areaCodeBtnWidth = MAX(42, areaCodeTextWidth);
    [self.areaCodeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.leading.equalTo(@4);
        make.width.equalTo(@(areaCodeBtnWidth));
        make.height.equalTo(self.phoneNumberContainerView);
    }];
}

/// 获取手机号输入框文字
- (NSString *)getPhoneNumberText {
    return self.phoneNumberTF.text ?: @"";
}

- (void)showPreparePhoneNumber:(NSString *)phoneNumber {
    if ([NSString isNil:phoneNumber]) {
        return;
    }
    self.phoneNumberTF.text = phoneNumber;
}

#pragma mark - NoaLoginBaseInputView Abstract Methods

- (NSString *)getFirstInputText {
    return [self getPhoneNumberText];
}

- (UIView *)getFirstInputView {
    return self.phoneNumberTF;
}

- (RACSignal<NSString *> *)getFirstInputTextSignal {
    return self.phoneNumberTF.rac_textSignal;
}

/// MARK: 根据文本计算长度
- (CGFloat)calculateButtonWidthForText:(NSString *)text font:(UIFont *)font {
    NSDictionary *attributes = @{NSFontAttributeName: font};
    CGSize size = [text sizeWithAttributes:attributes];
    CGFloat textWidth = size.width + 35; // 左右各16的内边距,多余出来一点
    return textWidth;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
