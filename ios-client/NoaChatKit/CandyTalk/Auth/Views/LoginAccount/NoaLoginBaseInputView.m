//
//  NoaLoginBaseInputView.m
//  NoaChatKit
//
//  Created by phl on 2025/11/7.
//

#import "NoaLoginBaseInputView.h"
#import "NoaFixedSizeRightView.h"
#import "NoaGraphCodeView.h"

@interface NoaLoginBaseInputView ()

/// 密码输入框
@property (nonatomic, strong) UITextField *passwordTF;

/// passwordTF的rightview
@property (nonatomic, strong) UIView *passwordTFRightContainerView;

/// 清理文本按钮
@property (nonatomic, strong) UIButton *clearBtn;

/// 密码是否隐藏按钮
@property (nonatomic, strong) UIButton *canEyesPasswordBtn;

/// 验证码背景View
@property (nonatomic, strong) UIView *codeBgView;

/// 图文验证码输入框
@property (nonatomic, strong) UITextField *codeTF;

/// codeTF的rightview
@property (nonatomic, strong) UIView *codeTFRightContainerView;

/// 图文验证码
@property (nonatomic, strong) UIImageView *codeImgView;

/// 切换下一章验证码按钮
@property (nonatomic, strong) UIButton *refreshCodeBtn;

/// 输入验证结果信号（内部实现）
@property (nonatomic, strong, readwrite) RACSubject<NSNumber *> *validationResultSignal;

@end

@implementation NoaLoginBaseInputView

#pragma mark - Lazy Loading

- (UITextField *)passwordTF {
    if (!_passwordTF) {
        _passwordTF = [[UITextField alloc] initWithFrame:CGRectZero];
        _passwordTF.tkThemebackgroundColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.05], [COLOR_5966F2_DARK colorWithAlphaComponent:0.05]];
        _passwordTF.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        // 设置圆角
        _passwordTF.layer.cornerRadius = 16;
        _passwordTF.layer.masksToBounds = YES;
        // 设置边框
        _passwordTF.layer.borderWidth = 1.0;
        _passwordTF.layer.tkThemeborderColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.05], [COLORWHITE colorWithAlphaComponent:0.4]];
        // 设置左边文字距离左边框间隔
        _passwordTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
        _passwordTF.leftViewMode = UITextFieldViewModeAlways;
        _passwordTF.keyboardType = UIKeyboardTypeDefault;
        _passwordTF.secureTextEntry = YES;
        _passwordTF.delegate = self;
        // 创建属性字符串
        NSDictionary *attributes = @{
            NSForegroundColorAttributeName: COLOR_99,
            NSFontAttributeName:FONTM(14)
        };
        _passwordTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LanguageToolMatch(@"请输入密码") attributes:attributes];
    }
    return _passwordTF;
}

- (UIView *)passwordTFRightContainerView {
    if (!_passwordTFRightContainerView) {
        _passwordTFRightContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        _passwordTFRightContainerView.tkThemebackgroundColors = @[UIColor.clearColor, UIColor.clearColor];
    }
    return _passwordTFRightContainerView;
}

- (UIButton *)clearBtn {
    if (!_clearBtn) {
        _clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clearBtn setImage:ImgNamed(@"icon_text_clear") forState:UIControlStateNormal];
    }
    return _clearBtn;
}

- (UIButton *)canEyesPasswordBtn {
    if (!_canEyesPasswordBtn) {
        _canEyesPasswordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_canEyesPasswordBtn setImage:ImgNamed(@"icon_eye_on") forState:UIControlStateNormal];
        [_canEyesPasswordBtn setImage:ImgNamed(@"icon_eye_off") forState:UIControlStateSelected];
        _canEyesPasswordBtn.selected = YES;// 默认加密
    }
    return _canEyesPasswordBtn;
}

- (UIView *)codeBgView {
    if (!_codeBgView) {
        _codeBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _codeBgView.tkThemebackgroundColors = @[UIColor.clearColor, UIColor.clearColor];
    }
    return _codeBgView;
}

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

- (UIView *)codeTFRightContainerView {
    if (!_codeTFRightContainerView) {
        _codeTFRightContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        _codeTFRightContainerView.tkThemebackgroundColors = @[UIColor.clearColor, UIColor.clearColor];
    }
    return _codeTFRightContainerView;
}

- (UIImageView *)codeImgView {
    if (!_codeImgView) {
        _codeImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _codeImgView.layer.cornerRadius = 16;
        _codeImgView.layer.masksToBounds = YES;
    }
    return _codeImgView;
}

- (UIButton *)refreshCodeBtn {
    if (!_refreshCodeBtn) {
        _refreshCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_refreshCodeBtn setImage:ImgNamed(@"icon_refresh") forState:UIControlStateNormal];
    }
    return _refreshCodeBtn;
}

- (RACSubject<NSNumber *> *)validationResultSignal {
    if (!_validationResultSignal) {
        _validationResultSignal = [RACSubject subject];
    }
    return _validationResultSignal;
}

#pragma mark - Setter

- (void)setIsNeedShowImageCode:(BOOL)isNeedShowImageCode {
    _isNeedShowImageCode = isNeedShowImageCode;
    self.codeBgView.hidden = !_isNeedShowImageCode;
    
    UIView *firstInputView = [self getFirstInputView];
    if (_isNeedShowImageCode) {
        [self.passwordTF mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(firstInputView.mas_bottom).offset(12);
            make.leading.equalTo(@20);
            make.trailing.equalTo(self).offset(-20);
            make.height.equalTo(@57);
        }];
        
        [self.codeBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.passwordTF.mas_bottom).offset(12);
            make.leading.equalTo(@20);
            make.trailing.equalTo(self).offset(-20);
            make.height.equalTo(@57);
            make.bottom.equalTo(self);
        }];
    } else {
        [self.passwordTF mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(firstInputView.mas_bottom).offset(12);
            make.leading.equalTo(@20);
            make.trailing.equalTo(self).offset(-20);
            make.height.equalTo(@57);
            make.bottom.equalTo(self);
        }];
    }
}

- (void)setImageCodeText:(NSString *)imageCodeText {
    CIMLog(@"验证码 = %@", imageCodeText);
    _imageCodeText = [NSString isNil:imageCodeText] ? @"" : imageCodeText;
    CGSize imageCodeSize = self.codeImgView.size;
    if (imageCodeSize.width == 0 ||
        imageCodeSize.height == 0) {
        // 有一个为零，使用兜底(与布局宽高一致)
        imageCodeSize = CGSizeMake(112, 51);
    }
    UIImage *codeImage = [self createCaptchaImageWithText:_imageCodeText size:imageCodeSize];
    [self.codeImgView setImage:codeImage];
}

#pragma mark - Public Methods

- (NSString *)getPasswordText {
    return self.passwordTF.text ?: @"";
}

- (NSString *)getCodeText {
    return self.codeTF.text ?: @"";
}

- (void)triggerValidation {
    NSString *firstInput = [self getFirstInputText];
    NSString *password = [self getPasswordText];
    // 默认验证：第一个输入框和密码都不为空
    BOOL isValid = firstInput.length > 0 && password.length > 0;
    // 手动发送验证结果
    [self.validationResultSignal sendNext:@(isValid)];
}

#pragma mark - Setup Methods

/// 设置密码输入框约束（子类可重写以自定义）
- (void)setupPasswordTextFieldConstraints {
    UIView *firstInputView = [self getFirstInputView];
    [self.passwordTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(firstInputView.mas_bottom).offset(12);
        make.leading.equalTo(@20);
        make.trailing.equalTo(self).offset(-20);
        make.height.equalTo(@57);
    }];
}

/// 设置验证码视图约束（子类可重写以自定义）
- (void)setupCodeViewConstraints {
    [self.codeBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordTF.mas_bottom).offset(12);
        make.leading.equalTo(@20);
        make.trailing.equalTo(self).offset(-20);
        make.height.equalTo(@57);
        make.bottom.equalTo(self);
    }];
    
    [self.codeTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.leading.equalTo(@0);
        make.trailing.equalTo(self.refreshCodeBtn.mas_leading).offset(-12);
        make.height.equalTo(self.codeBgView);
    }];
    
    [self.refreshCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.centerY.equalTo(self.codeBgView);
        make.trailing.equalTo(self.codeBgView).offset(-3);
        make.width.height.equalTo(@20);
    }];
}

/// 设置UI（子类需要调用 super 并实现自己的第一个输入框）
- (void)setupUI {
    [self addSubview:self.passwordTF];
    [self setupRightViewForPasswordTextField];
    
    [self addSubview:self.codeBgView];
    [self.codeBgView addSubview:self.codeTF];
    [self setupRightViewForCodeTextField];
    [self.codeBgView addSubview:self.refreshCodeBtn];
    
    [self setupPasswordTextFieldConstraints];
    [self setupCodeViewConstraints];
}

/// 处理数据（子类需要调用 super）
- (void)processData {
    @weakify(self)
    [[self.clearBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        self.passwordTF.text = @"";
    }];
    
    [[self.canEyesPasswordBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        UIButton *canEyesPasswordBtn = x;
        if (self.passwordTF.isSecureTextEntry) {
            self.passwordTF.secureTextEntry = NO;
            // 标记按钮为非选中状态，展示非选中状态图片
            canEyesPasswordBtn.selected = NO;
        } else {
            self.passwordTF.secureTextEntry = YES;
            // 标记按钮为选中状态，展示选中状态图片
            canEyesPasswordBtn.selected = YES;
        }
    }];
    
    [[self.refreshCodeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        if (self.clickRefreshVerificationCodeBtnAction) {
            self.clickRefreshVerificationCodeBtnAction();
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
        self.passwordTF.rac_textSignal,
        self.codeTF.rac_textSignal
    ]] map:^NSNumber *(RACTuple *tuple) {
        @strongify(self)
        NSString *firstInput = tuple.first ?: @"";
        NSString *password = tuple.second ?: @"";
        
        // 默认验证：第一个输入框和密码都不为空
        BOOL isValid = firstInput.length > 0 && password.length > 0;
        
        return @(isValid);
    }];
    
    // 订阅验证结果，发送到 validationResultSignal
    [validationSignal subscribeNext:^(NSNumber *isValid) {
        @strongify(self)
        [self.validationResultSignal sendNext:isValid];
    }];
}

/// 设置密码输入rightView（包含隐藏按钮和清除按钮）
- (void)setupRightViewForPasswordTextField {
    // 创建固定宽高的容器 view
    NoaFixedSizeRightView *containerView = [[NoaFixedSizeRightView alloc] initWithFixedSize:CGSizeMake(76, 57)];
    
    // 清除按钮（只在编辑时显示）
    [containerView addSubview:self.clearBtn];
    // 隐藏/展示密码按钮（任何时候都显示）
    [containerView addSubview:self.canEyesPasswordBtn];
    [self.clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.canEyesPasswordBtn.mas_leading).offset(-12);
        make.centerY.equalTo(containerView);
        make.width.height.equalTo(@20);
    }];
    
    [self.canEyesPasswordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(containerView).offset(-12);
        make.centerY.equalTo(containerView);
        make.width.height.equalTo(@20);
    }];
    
    // 设置 rightView
    self.passwordTF.rightView = containerView;
    self.passwordTF.rightViewMode = UITextFieldViewModeAlways; // 容器始终显示，内部按钮根据状态控制
    
    @weakify(self)
    // 更新清除按钮显示状态的辅助方法
    void (^updateClearButtonVisibility)(void) = ^{
        @strongify(self)
        BOOL shouldShow = self.passwordTF.isEditing && self.passwordTF.text.length > 0;
        self.clearBtn.hidden = !shouldShow;
    };
    
    // 监听开始编辑
    [[self.passwordTF rac_signalForControlEvents:UIControlEventEditingDidBegin] subscribeNext:^(__kindof UIControl * _Nullable x) {
        updateClearButtonVisibility();
    }];
    
    // 监听结束编辑
    [[self.passwordTF rac_signalForControlEvents:UIControlEventEditingDidEnd] subscribeNext:^(__kindof UIControl * _Nullable x) {
        updateClearButtonVisibility();
    }];
    
    // 监听文本变化
    [self.passwordTF.rac_textSignal subscribeNext:^(NSString * _Nullable text) {
        updateClearButtonVisibility();
    }];
}

/// 设置验证码输入rightView（包含图文验证码图片）
- (void)setupRightViewForCodeTextField {
    // 创建固定宽高的容器 view
    NoaFixedSizeRightView *containerView = [[NoaFixedSizeRightView alloc] initWithFixedSize:CGSizeMake(75, 62)];
    
    // 图文验证码
    [containerView addSubview:self.codeImgView];
    
    [self.codeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(containerView).offset(-12);
        make.centerY.equalTo(containerView);
        make.width.equalTo(@112);
        make.height.equalTo(@51);
    }];
    
    // 设置 rightView
    self.codeTF.rightView = containerView;
    self.codeTF.rightViewMode = UITextFieldViewModeAlways; // 容器始终显示，内部按钮根据状态控制
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

#pragma mark - 绘制二维码背景图+文字
//根据服务器返回的或者自己设置的codeStr绘制图形验证码
- (UIImage *)createCaptchaImageWithText:(NSString *)text size:(CGSize)size {
    // 开始图形上下文
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    // 设置背景颜色
    [[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1] setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    
    // 设置字体和颜色
    NSArray *colors = @[
        [UIColor redColor],
        [UIColor greenColor],
        [UIColor blueColor],
        [UIColor orangeColor],
        [UIColor grayColor],
        [UIColor cyanColor],
        [UIColor purpleColor],
        [UIColor darkGrayColor],
        [UIColor magentaColor],
        [UIColor systemPinkColor],
        [UIColor systemBlueColor],
        [UIColor systemBrownColor]
    ];
    
    for (int i = 0; i < text.length; i++) {
        // 随机颜色
        UIColor *color = colors[i % colors.count];
        NSDictionary *attributes = @{
            NSFontAttributeName: [UIFont boldSystemFontOfSize:26],
            NSForegroundColorAttributeName: color
        };
        
        // 计算字符的绘制区域
        NSString *character = [text safeSubstringWithRange:NSMakeRange(i, 1)];
        CGSize charSize = [character sizeWithAttributes:attributes];
        CGRect charRect = CGRectMake(10 + i * (size.width / text.length), (size.height - charSize.height) / 2, charSize.width, charSize.height);
        
        // 绘制字符
        [character drawInRect:charRect withAttributes:attributes];
    }
    
    // 添加干扰线
//    for (int i = 0; i < 1; i++) {
//        [self drawRandomLineInRect:CGRectMake(0, 0, size.width, size.height)];
//    }
    
    // 获取生成的图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 结束图形上下文
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)drawRandomLineInRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    CGContextSetLineWidth(context, 1.0);
   
    CGFloat startX = arc4random() % (int)rect.size.width;
    CGFloat startY = arc4random() % (int)rect.size.height;
    CGFloat length = rect.size.width;//arc4random() % 10 + 5; // 线段长度为5到15的随机值
    CGFloat endX = startX + (arc4random() % 2 ? length : -length);
    CGFloat endY = startY + (arc4random() % 2 ? length : -length);
   
    CGContextMoveToPoint(context, startX, startY);
    CGContextAddLineToPoint(context, endX, endY);
    CGContextStrokePath(context);
}

@end



