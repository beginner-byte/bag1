//
//  NoaVerCodeLoginBaseInputView.m
//  NoaChatKit
//
//  Created by phl on 2025/11/18.
//

#import "NoaVerCodeLoginBaseInputView.h"
#import "NoaFixedSizeRightView.h"
#import "NoaVerCodeLoginDataHandle.h"

@interface NoaVerCodeLoginBaseInputView ()

// MARK: 验证码输入↓
///  验证码输入框
@property (nonatomic, strong) UITextField *codeTF;

/// 验证码输入清理文本按钮
@property (nonatomic, strong) UIButton *codeTFClearBtn;

/// 验证码发送按钮
@property (nonatomic, strong) UIButton *sendCodeBtn;

// MARK: 验证码输入↑

// MARK: 其他↓
/// 输入验证结果信号（内部实现）
@property (nonatomic, strong, readwrite) RACSubject<NSNumber *> *validationResultSignal;

/// 当前登录方式
@property (nonatomic, assign) ZLoginAndRegisterTypeMenu currentLoginMenu;

@end

@implementation NoaVerCodeLoginBaseInputView

#pragma mark - Lazy Loading

- (UITextField *)codeTF {
    if (!_codeTF) {
        _codeTF = [[UITextField alloc] initWithFrame:CGRectZero];
        _codeTF.tkThemebackgroundColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.05], [COLOR_5966F2_DARK colorWithAlphaComponent:0.05]];
        _codeTF.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        // 设置圆角
        _codeTF.layer.cornerRadius = 16;
        _codeTF.layer.masksToBounds = YES;
        // 设置边框
        _codeTF.layer.borderWidth = 1.0;
        _codeTF.layer.tkThemeborderColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.05], [COLORWHITE colorWithAlphaComponent:0.4]];
        // 设置左边文字距离左边框间隔
        _codeTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
        _codeTF.leftViewMode = UITextFieldViewModeAlways;
        _codeTF.keyboardType = UIKeyboardTypeDefault;
        _codeTF.textContentType = UITextContentTypeOneTimeCode;
        _codeTF.delegate = self;
        // 创建属性字符串
        NSDictionary *attributes = @{
            NSForegroundColorAttributeName: COLOR_99,
            NSFontAttributeName:FONTM(14)
        };
        _codeTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LanguageToolMatch(@"验证码") attributes:attributes];
    }
    return _codeTF;
}

- (UIButton *)sendCodeBtn {
    if (!_sendCodeBtn) {
        _sendCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendCodeBtn setTitle:LanguageToolMatch(@"获取验证码") forState:UIControlStateNormal];
        [_sendCodeBtn setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateNormal];
        _sendCodeBtn.tkThemebackgroundColors = @[COLOR_CLEAR, COLOR_CLEAR];
        _sendCodeBtn.titleLabel.font = FONTM(14);
    }
    return _sendCodeBtn;
}

- (UIButton *)codeTFClearBtn {
    if (!_codeTFClearBtn) {
        _codeTFClearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_codeTFClearBtn setImage:ImgNamed(@"icon_text_clear") forState:UIControlStateNormal];
    }
    return _codeTFClearBtn;
}

- (RACSubject<NSNumber *> *)validationResultSignal {
    if (!_validationResultSignal) {
        _validationResultSignal = [RACSubject subject];
    }
    return _validationResultSignal;
}

#pragma mark - Setter


#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
              CurrentLoginWay:(ZLoginAndRegisterTypeMenu)currentLoginWay {
    self = [super initWithFrame:frame];
    if (self) {
        self.currentLoginMenu = currentLoginWay;
    }
    return self;
}

#pragma mark - Public Methods

- (NSString *)getCodeText {
    return self.codeTF.text ?: @"";
}

- (void)triggerValidation {
    NSString *firstInput = [self getFirstInputText];
    NSString *verCode = [self getCodeText];
    // 默认验证：第一个输入框和验证码都不为空
    BOOL isValid = firstInput.length > 0 && verCode.length > 0;
    // 手动发送验证结果
    [self.validationResultSignal sendNext:@(isValid)];
}

#pragma mark - Setup Methods

/// 设置验证码视图约束（子类可重写以自定义）
- (void)setupCodeViewConstraints {
    UIView *firstInputView = [self getFirstInputView];
    
    [self.codeTF mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(firstInputView.mas_bottom).offset(12);
        make.leading.equalTo(@20);
        make.trailing.equalTo(self).offset(-20);
        make.height.equalTo(@57);
        make.bottom.equalTo(self);
    }];
}

/// 设置UI（子类需要调用 super 并实现自己的第一个输入框）
- (void)setupUI {
    [self addSubview:self.codeTF];
    [self setupRightViewForCodeTextField];
    
    [self setupCodeViewConstraints];
}

/// 处理数据（子类需要调用 super）
- (void)processData {
    @weakify(self)
    [[self.sendCodeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        if (self.getVerCodeActionBlock) {
            self.getVerCodeActionBlock();
        }
    }];
    
    // 监听输入变化，进行验证
    [self setupInputValidation];
}

/// 设置输入验证逻辑
- (void)setupInputValidation {
    @weakify(self)
    // 合并第一个输入框、密码和验证码的文本信号
    RACSignal<NSNumber *> *validationSignal = [[RACSignal combineLatest:@[
        [self getFirstInputTextSignal],
        self.codeTF.rac_textSignal,
    ]] map:^NSNumber *(RACTuple *tuple) {
        @strongify(self)
        NSString *firstInput = tuple.first ?: @"";
        NSString *codeInput = tuple.second ?: @"";
        // 验证：第一个输入框和验证码都不为空
        BOOL isValid = firstInput.length > 0 && codeInput.length > 0;
        return @(isValid);
    }];
    
    // 订阅验证结果，发送到 validationResultSignal
    [validationSignal subscribeNext:^(NSNumber *isValid) {
        @strongify(self)
        [self.validationResultSignal sendNext:isValid];
    }];
}

/// 设置验证码输入rightView（包含图文验证码图片）
- (void)setupRightViewForCodeTextField {
    CGFloat sendCodeTextWidth = [self calculateButtonWidthForText:LanguageToolMatch(@"获取验证码") font:FONTM(14)];
    CGFloat sendCodeBtnWidth = MAX(94, sendCodeTextWidth);
    CGFloat clearCodeTFBtnWidth = 20;
    // 创建固定宽高的容器 view
    NoaFixedSizeRightView *containerView = [[NoaFixedSizeRightView alloc] initWithFixedSize:CGSizeMake(sendCodeBtnWidth + clearCodeTFBtnWidth + 12, 58)];
    
    // 发送验证码按钮
    [containerView addSubview:self.sendCodeBtn];
    // 清除文本按钮
    [containerView addSubview:self.codeTFClearBtn];
    
    [self.sendCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(containerView);
        make.centerY.equalTo(containerView);
        make.width.equalTo(@(sendCodeBtnWidth));
        make.height.equalTo(@58);
    }];
    
    [self.codeTFClearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.sendCodeBtn.mas_leading);
        make.centerY.equalTo(containerView);
        make.width.height.equalTo(@(clearCodeTFBtnWidth));
    }];
    
    // 设置 rightView
    self.codeTF.rightView = containerView;
    self.codeTF.rightViewMode = UITextFieldViewModeAlways; // 容器始终显示，内部按钮根据状态控制
    
    @weakify(self)
    // 更新清除按钮显示状态的辅助方法
    void (^updateClearButtonVisibility)(void) = ^{
        @strongify(self)
        BOOL shouldShow = self.codeTF.isEditing && self.codeTF.text.length > 0;
        self.codeTFClearBtn.hidden = !shouldShow;
    };
    
    // 监听开始编辑
    [[self.codeTF rac_signalForControlEvents:UIControlEventEditingDidBegin] subscribeNext:^(__kindof UIControl * _Nullable x) {
        updateClearButtonVisibility();
    }];
    
    // 监听结束编辑
    [[self.codeTF rac_signalForControlEvents:UIControlEventEditingDidEnd] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        updateClearButtonVisibility();
    }];
    
    // 监听文本变化
    [self.codeTF.rac_textSignal subscribeNext:^(NSString * _Nullable text) {
        updateClearButtonVisibility();
    }];
    
    // 清理验证码点击事件
    [[self.codeTFClearBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        self.codeTF.text = @"";
        // 通知注册登录按钮状态变化
        [self.validationResultSignal sendNext:@NO];
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@" "] || [string isEqualToString:@"  "]) {
        // 当输入为空格时，阻止输入
        return NO;
    } else {
        // 允许删除字符
        if ([string isEqualToString:@""]) {
            return YES;
        }
        return YES;
    }
}

#pragma mark - Abstract Methods (子类必须实现)

- (NSString *)getFirstInputText {
    NSAssert(NO, @"子类必须实现 getFirstInputText 方法");
    return @"";
}

- (UIView *)getFirstInputView {
    NSAssert(NO, @"子类必须实现 getFirstInputView 方法");
    return nil;
}

- (RACSignal<NSString *> *)getFirstInputTextSignal {
    NSAssert(NO, @"子类必须实现 getFirstInputTextSignal 方法");
    return [RACSignal return:@""];
}


/// MARK: 根据文本计算长度
- (CGFloat)calculateButtonWidthForText:(NSString *)text font:(UIFont *)font {
    NSDictionary *attributes = @{NSFontAttributeName: font};
    CGSize size = [text sizeWithAttributes:attributes];
    CGFloat textWidth = size.width + 24; // 左右各12的内边距,多余出来一点
    return textWidth;
}

// MARK: 验证码倒计时展示
- (void)startVerCodeCountDown {
    @weakify(self)
    
    [ZTOOL doInMain:^{
        @strongify(self)
        // 如果按钮已经禁用，说明倒计时正在进行，避免重复调用
        if (!self.sendCodeBtn.enabled) {
            return;
        }
        
        self.sendCodeBtn.enabled = NO;
        self.sendCodeBtn.tkThemebackgroundColors = @[COLOR_E3E8EF, COLOR_E3E8EF];
        
        int timeOut = 60;
        NSString *title = [NSString stringWithFormat:LanguageToolMatch(@"重新获取(%d)"), timeOut];
        [self.sendCodeBtn setTitle:title forState:UIControlStateNormal];
        CGFloat sendCodeTextWidth = [self calculateButtonWidthForText:title font:self.sendCodeBtn.titleLabel.font];
        CGFloat sendCodeBtnWidth = MAX(94, sendCodeTextWidth);
        
        [self.sendCodeBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(sendCodeBtnWidth));
        }];
        
        [self.sendCodeBtn startCountDownTime:timeOut title:title CountDownBlock:^(int count) {
            @strongify(self)
            NSString *title = [NSString stringWithFormat:LanguageToolMatch(@"重新获取(%d)"), count];
            [self.sendCodeBtn setTitle:title forState:UIControlStateNormal];
        } Finish:^{
            @strongify(self)
            self.sendCodeBtn.enabled = YES;
            self.sendCodeBtn.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
            
            NSString *title = LanguageToolMatch(@"获取验证码");
            [self.sendCodeBtn setTitle:title forState:UIControlStateNormal];
            CGFloat sendCodeTextWidth = [self calculateButtonWidthForText:title font:self.sendCodeBtn.titleLabel.font];
            CGFloat sendCodeBtnWidth = MAX(94, sendCodeTextWidth);
            
            [self.sendCodeBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(sendCodeBtnWidth));
            }];
        }];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
