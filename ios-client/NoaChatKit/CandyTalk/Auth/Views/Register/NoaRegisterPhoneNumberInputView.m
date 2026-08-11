//
//  NoaRegisterPhoneNumberInputView.m
//  NoaChatKit
//
//  Created by phl on 2025/11/13.
//

#import "NoaRegisterPhoneNumberInputView.h"
#import "NoaFixedSizeRightView.h"
#import "NoaRegisterDataHandle.h"

@interface NoaRegisterPhoneNumberInputView ()

/// 手机号码输入容器
@property (nonatomic, strong) UIView *phoneNumberContainerView;

/// 区号展示/切换按钮
@property (nonatomic, strong) UIButton *areaCodeBtn;

/// 手机号码输入框
@property (nonatomic, strong) UITextField *phoneNumberTF;

/// 手机号码错误提示
@property (nonatomic, strong) UILabel *phoneNumberErrorTipLabel;

/// 账号输入清理文本按钮
@property (nonatomic, strong) UIButton *phoneNumberTFClearBtn;

/// 输入验证结果信号（发送 BOOL 值，YES 表示验证通过，NO 表示验证失败）
@property (nonatomic, strong, readwrite) RACSubject<NSNumber *> *phoneNumberValidationResultSignal;

/// 手动触发的文本信号（用于初始化后，使用self.phoneNumberTF.text = xxxx的赋值触发）
@property (nonatomic, strong) RACSubject<NSString *> *manualTextTrigger;

@end

@implementation NoaRegisterPhoneNumberInputView

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
        // 设置左边文字距离左边框间隔
        _phoneNumberTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 0)];
        _phoneNumberTF.leftViewMode = UITextFieldViewModeAlways;
        _phoneNumberTF.keyboardType = UIKeyboardTypePhonePad;
        _phoneNumberTF.delegate = self;
        // 创建属性字符串
        NSDictionary *attributes = @{
            NSForegroundColorAttributeName: COLOR_99,
            NSFontAttributeName:FONTM(14)
        };
        _phoneNumberTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LanguageToolMatch(@"请输入手机号") attributes:attributes];
        _phoneNumberTF.tkThemebackgroundColors = @[UIColor.clearColor, UIColor.clearColor];
    }
    return _phoneNumberTF;
}

- (UILabel *)phoneNumberErrorTipLabel {
    if (!_phoneNumberErrorTipLabel) {
        _phoneNumberErrorTipLabel = [UILabel new];
        _phoneNumberErrorTipLabel.tkThemetextColors = @[COLOR_FF3333, COLOR_FF3333_DARK];
        _phoneNumberErrorTipLabel.font = FONTR(14);
        _phoneNumberErrorTipLabel.numberOfLines = 0;
        _phoneNumberErrorTipLabel.hidden = YES;
    }
    return _phoneNumberErrorTipLabel;
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
           CurrentRegisterWay:(ZLoginAndRegisterTypeMenu)currentRegisterWay {
    self = [super initWithFrame:frame CurrentRegisterWay:currentRegisterWay];
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
    [self addSubview:self.phoneNumberErrorTipLabel];
    
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
    
    [self.phoneNumberErrorTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.phoneNumberTF.mas_bottom).offset(0);
        make.leading.equalTo(@20);
        make.trailing.equalTo(self).offset(-20);
        make.height.equalTo(@0);
    }];
    
    [self setupRightViewForPhoneNumberTFextField];
    
    // 调用父类的 setupUI 方法
    [super setupUI];
    
    // 手机账号支持验证号码
    self.isSupportVerCode = YES;
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
        
        // 编辑结束，校验手机号是否合法
        [NoaRegisterDataHandle checkAccountInputWithRegisterType:ZLoginTypeMenuPhoneNumber
                                                  AccountInput:self.phoneNumberTF.text
                                                WhenEditFinish:^(BOOL res, NSString * _Nullable errorText) {
            @strongify(self)
            
            if (res) {
                // 检查通过
                self.phoneNumberErrorTipLabel.text = @"";
                self.phoneNumberErrorTipLabel.hidden = YES;
                [self.phoneNumberErrorTipLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.phoneNumberTF.mas_bottom).offset(0);
                    make.leading.equalTo(@20);
                    make.trailing.equalTo(self).offset(-20);
                    make.height.equalTo(@0);
                }];
            }else {
                self.phoneNumberErrorTipLabel.text = [NSString isNil:errorText] ? @"" : errorText;
                self.phoneNumberErrorTipLabel.hidden = NO;
                [self.phoneNumberErrorTipLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.phoneNumberTF.mas_bottom).offset(12);
                    make.leading.equalTo(@20);
                    make.trailing.equalTo(self).offset(-20);
                    make.height.greaterThanOrEqualTo(@14);
                }];
            }
        }];
    }];
    
    // 监听文本变化
    [self.phoneNumberTF.rac_textSignal subscribeNext:^(NSString * _Nullable text) {
        updateClearButtonVisibility();
    }];
    
    // 清理账号点击事件
    [[self.phoneNumberTFClearBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        self.phoneNumberTF.text = @"";
        // 手动触发信号，确保程序化清空后也能触发验证
        [self.manualTextTrigger sendNext:@""];
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
    // 手动触发信号，确保程序化赋值后也能触发验证
    [self.manualTextTrigger sendNext:phoneNumber];
}

#pragma mark - NoaLoginBaseInputView Abstract Methods

- (NSString *)getFirstInputText {
    return [self getPhoneNumberText];
}

- (UIView *)getFirstInputView {
    return self.phoneNumberErrorTipLabel;
}

- (RACSubject<NSString *> *)manualTextTrigger {
    if (!_manualTextTrigger) {
        _manualTextTrigger = [RACSubject subject];
    }
    return _manualTextTrigger;
}

- (RACSignal<NSString *> *)getFirstInputTextSignal {
    // 合并用户输入信号和手动触发信号，确保程序化赋值时也能触发
    return [[RACSignal merge:@[
        self.phoneNumberTF.rac_textSignal,
        self.manualTextTrigger
    ]] startWith:self.phoneNumberTF.text ?: @""];
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
