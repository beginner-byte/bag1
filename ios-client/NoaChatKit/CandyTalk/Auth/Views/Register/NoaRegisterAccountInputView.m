//
//  NoaRegisterAccountInputView.m
//  NoaChatKit
//
//  Created by phl on 2025/11/13.
//

#import "NoaRegisterAccountInputView.h"
#import "NoaFixedSizeRightView.h"
#import "NoaRegisterDataHandle.h"

@interface NoaRegisterAccountInputView ()

/// 账号输入框
@property (nonatomic, strong) UITextField *accountTF;

/// 账号错误提示
@property (nonatomic, strong) UILabel *accountErrorTipLabel;

/// 账号输入清理文本按钮
@property (nonatomic, strong) UIButton *accountTFClearBtn;

/// 输入验证结果信号（内部实现）
@property (nonatomic, strong, readwrite) RACSubject<NSNumber *> *accountValidationResultSignal;

/// 手动触发的文本信号（用于初始化后，使用self.accountTF.text = xxxx的赋值触发）
@property (nonatomic, strong) RACSubject<NSString *> *manualTextTrigger;

@end

@implementation NoaRegisterAccountInputView

#pragma mark - Lazy Loading

- (UITextField *)accountTF {
    if (!_accountTF) {
        _accountTF = [[UITextField alloc] initWithFrame:CGRectZero];
        _accountTF.tkThemebackgroundColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.05], [COLOR_5966F2_DARK colorWithAlphaComponent:0.05]];
        _accountTF.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        // 设置圆角
        _accountTF.layer.cornerRadius = 16;
        _accountTF.layer.masksToBounds = YES;
        // 设置边框
        _accountTF.layer.borderWidth = 1.0;
        _accountTF.layer.tkThemeborderColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.05], [COLORWHITE colorWithAlphaComponent:0.4]];
        // 设置左边文字距离左边框间隔
        _accountTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
        _accountTF.leftViewMode = UITextFieldViewModeAlways;
        _accountTF.keyboardType = UIKeyboardTypeDefault;
        _accountTF.delegate = self;
        // 创建属性字符串
        NSDictionary *attributes = @{
            NSForegroundColorAttributeName: COLOR_99,
            NSFontAttributeName:FONTM(14)
        };
        _accountTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LanguageToolMatch(@"请输入账号") attributes:attributes];
    }
    return _accountTF;
}

- (UILabel *)accountErrorTipLabel {
    if (!_accountErrorTipLabel) {
        _accountErrorTipLabel = [UILabel new];
        _accountErrorTipLabel.tkThemetextColors = @[COLOR_FF3333, COLOR_FF3333_DARK];
        _accountErrorTipLabel.font = FONTR(14);
        _accountErrorTipLabel.numberOfLines = 0;
        _accountErrorTipLabel.hidden = YES;
    }
    return _accountErrorTipLabel;
}

- (UIButton *)accountTFClearBtn {
    if (!_accountTFClearBtn) {
        _accountTFClearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_accountTFClearBtn setImage:ImgNamed(@"icon_text_clear") forState:UIControlStateNormal];
    }
    return _accountTFClearBtn;
}

- (RACSubject<NSNumber *> *)accountValidationResultSignal {
    if (!_accountValidationResultSignal) {
        _accountValidationResultSignal = [RACSubject subject];
        // 将基类的验证信号转发到子类的信号
        @weakify(self)
        [self.validationResultSignal subscribeNext:^(NSNumber *isValid) {
            @strongify(self)
            [self.accountValidationResultSignal sendNext:isValid];
        }];
    }
    return _accountValidationResultSignal;
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
    [self addSubview:self.accountTF];
    [self addSubview:self.accountErrorTipLabel];
    
    [self.accountTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.leading.equalTo(@20);
        make.trailing.equalTo(self).offset(-20);
        make.height.equalTo(@58);
    }];
    
    [self.accountErrorTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.accountTF.mas_bottom).offset(0);
        make.leading.equalTo(@20);
        make.trailing.equalTo(self).offset(-20);
        make.height.equalTo(@0);
    }];
    
    [self setupRightViewForAccountTFextField];
    
    // 调用父类的 setupUI 方法
    [super setupUI];
    
    // 账号不支持验证号码
    self.isSupportVerCode = NO;
}

- (void)setupRightViewForAccountTFextField {
    // 创建固定宽高的容器 view
    NoaFixedSizeRightView *containerView = [[NoaFixedSizeRightView alloc] initWithFixedSize:CGSizeMake(42, 57)];
    
    // 清除按钮（只在编辑时显示）
    [containerView addSubview:self.accountTFClearBtn];

    [self.accountTFClearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(containerView).offset(-12);
        make.centerY.equalTo(containerView);
        make.width.height.equalTo(@20);
    }];
    
    // 设置 rightView
    self.accountTF.rightView = containerView;
    self.accountTF.rightViewMode = UITextFieldViewModeAlways; // 容器始终显示，内部按钮根据状态控制
    
    @weakify(self)
    // 更新清除按钮显示状态的辅助方法
    void (^updateClearButtonVisibility)(void) = ^{
        @strongify(self)
        BOOL shouldShow = self.accountTF.isEditing && self.accountTF.text.length > 0;
        self.accountTFClearBtn.hidden = !shouldShow;
    };
    
    // 监听开始编辑
    [[self.accountTF rac_signalForControlEvents:UIControlEventEditingDidBegin] subscribeNext:^(__kindof UIControl * _Nullable x) {
        updateClearButtonVisibility();
    }];
    
    // 监听结束编辑
    [[self.accountTF rac_signalForControlEvents:UIControlEventEditingDidEnd] subscribeNext:^(__kindof UIControl * _Nullable x) {
        updateClearButtonVisibility();
        
        // 编辑结束，校验账号是否合法
        [NoaRegisterDataHandle checkAccountInputWithRegisterType:ZLoginTypeMenuAccountPassword
                                                  AccountInput:self.accountTF.text
                                                WhenEditFinish:^(BOOL res, NSString * _Nullable errorText) {
            @strongify(self)
            
            if (res) {
                // 检查通过
                self.accountErrorTipLabel.text = @"";
                self.accountErrorTipLabel.hidden = YES;
                [self.accountErrorTipLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.accountTF.mas_bottom).offset(0);
                    make.leading.equalTo(@20);
                    make.trailing.equalTo(self).offset(-20);
                    make.height.equalTo(@0);
                }];
            }else {
                self.accountErrorTipLabel.text = [NSString isNil:errorText] ? @"" : errorText;
                self.accountErrorTipLabel.hidden = NO;
                [self.accountErrorTipLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.accountTF.mas_bottom).offset(12);
                    make.leading.equalTo(@20);
                    make.trailing.equalTo(self).offset(-20);
                    make.height.greaterThanOrEqualTo(@14);
                }];
            }
        }];
    }];
    
    // 监听文本变化
    [self.accountTF.rac_textSignal subscribeNext:^(NSString * _Nullable text) {
        updateClearButtonVisibility();
    }];
    
    // 清理账号点击事件
    [[self.accountTFClearBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        self.accountTF.text = @"";
        // 手动触发信号，确保程序化清空后也能触发验证
        [self.manualTextTrigger sendNext:@""];
        // 通知注册登录按钮状态变化
        [self.validationResultSignal sendNext:@NO];
    }];
}


- (void)processData {
    // 调用父类的 processData 方法
    [super processData];
}

/// 获取账号输入框文字
- (NSString *)getAccountText {
    return self.accountTF.text ?: @"";
}

- (void)showPrepareAccount:(NSString *)account {
    if ([NSString isNil:account]) {
        return;
    }
    self.accountTF.text = account;
    // 手动触发信号，确保程序化赋值后也能触发验证
    [self.manualTextTrigger sendNext:account];
}

#pragma mark - NoaLoginBaseInputView Abstract Methods

- (NSString *)getFirstInputText {
    return [self getAccountText];
}

- (UIView *)getFirstInputView {
    return self.accountErrorTipLabel;
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
        self.accountTF.rac_textSignal,
        self.manualTextTrigger
    ]] startWith:self.accountTF.text ?: @""];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
