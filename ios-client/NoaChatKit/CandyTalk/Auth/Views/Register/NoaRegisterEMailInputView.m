//
//  NoaRegisterEMailInputView.m
//  NoaChatKit
//
//  Created by phl on 2025/11/13.
//

#import "NoaRegisterEMailInputView.h"
#import "NoaFixedSizeRightView.h"
#import "NoaRegisterDataHandle.h"

@interface NoaRegisterEMailInputView ()

/// 电子邮箱账号输入框
@property (nonatomic, strong) UITextField *emailTF;

/// 邮箱账号错误提示
@property (nonatomic, strong) UILabel *emailErrorTipLabel;

/// 邮箱输入清理文本按钮
@property (nonatomic, strong) UIButton *emailTFClearBtn;

/// 输入验证结果信号（内部实现）
@property (nonatomic, strong, readwrite) RACSubject<NSNumber *> *emailValidationResultSignal;

/// 手动触发的文本信号（用于初始化后，使用self.emailTF.text = xxxx的赋值触发）
@property (nonatomic, strong) RACSubject<NSString *> *manualTextTrigger;

@end

@implementation NoaRegisterEMailInputView

#pragma mark - Lazy Loading

- (UITextField *)emailTF {
    if (!_emailTF) {
        _emailTF = [[UITextField alloc] initWithFrame:CGRectZero];
        _emailTF.tkThemebackgroundColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.05], [COLOR_5966F2_DARK colorWithAlphaComponent:0.05]];
        _emailTF.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        // 设置圆角
        _emailTF.layer.cornerRadius = 16;
        _emailTF.layer.masksToBounds = YES;
        // 设置边框
        _emailTF.layer.borderWidth = 1.0;
        _emailTF.layer.tkThemeborderColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.05], [COLORWHITE colorWithAlphaComponent:0.4]];
        // 设置左边文字距离左边框间隔
        _emailTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
        _emailTF.leftViewMode = UITextFieldViewModeAlways;
        _emailTF.keyboardType = UIKeyboardTypeEmailAddress;
        _emailTF.delegate = self;
        // 创建属性字符串
        NSDictionary *attributes = @{
            NSForegroundColorAttributeName: COLOR_99,
            NSFontAttributeName:FONTM(14)
        };
        _emailTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LanguageToolMatch(@"请输入邮箱") attributes:attributes];
    }
    return _emailTF;
}

- (UILabel *)emailErrorTipLabel {
    if (!_emailErrorTipLabel) {
        _emailErrorTipLabel = [UILabel new];
        _emailErrorTipLabel.tkThemetextColors = @[COLOR_FF3333, COLOR_FF3333_DARK];
        _emailErrorTipLabel.font = FONTR(14);
        _emailErrorTipLabel.numberOfLines = 0;
        _emailErrorTipLabel.hidden = YES;
    }
    return _emailErrorTipLabel;
}

- (UIButton *)emailTFClearBtn {
    if (!_emailTFClearBtn) {
        _emailTFClearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_emailTFClearBtn setImage:ImgNamed(@"icon_text_clear") forState:UIControlStateNormal];
    }
    return _emailTFClearBtn;
}

- (RACSubject<NSNumber *> *)emailValidationResultSignal {
    if (!_emailValidationResultSignal) {
        _emailValidationResultSignal = [RACSubject subject];
        // 将基类的验证信号转发到子类的信号
        @weakify(self)
        [self.validationResultSignal subscribeNext:^(NSNumber *isValid) {
            @strongify(self)
            [self.emailValidationResultSignal sendNext:isValid];
        }];
    }
    return _emailValidationResultSignal;
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
    [self addSubview:self.emailTF];
    [self addSubview:self.emailErrorTipLabel];
    
    [self.emailTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.leading.equalTo(@20);
        make.trailing.equalTo(self).offset(-20);
        make.height.equalTo(@58);
    }];
    
    [self.emailErrorTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.emailTF.mas_bottom).offset(0);
        make.leading.equalTo(@20);
        make.trailing.equalTo(self).offset(-20);
        make.height.equalTo(@0);
    }];
    
    [self setupRightViewForEmailTFextField];
    
    // 调用父类的 setupUI 方法
    [super setupUI];
    
    // 邮箱账号支持验证号码
    self.isSupportVerCode = YES;
}

- (void)setupRightViewForEmailTFextField {
    // 创建固定宽高的容器 view
    NoaFixedSizeRightView *containerView = [[NoaFixedSizeRightView alloc] initWithFixedSize:CGSizeMake(42, 57)];
    
    // 清除按钮（只在编辑时显示）
    [containerView addSubview:self.emailTFClearBtn];

    [self.emailTFClearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(containerView).offset(-12);
        make.centerY.equalTo(containerView);
        make.width.height.equalTo(@20);
    }];
    
    // 设置 rightView
    self.emailTF.rightView = containerView;
    self.emailTF.rightViewMode = UITextFieldViewModeAlways; // 容器始终显示，内部按钮根据状态控制
    
    @weakify(self)
    // 更新清除按钮显示状态的辅助方法
    void (^updateClearButtonVisibility)(void) = ^{
        @strongify(self)
        BOOL shouldShow = self.emailTF.isEditing && self.emailTF.text.length > 0;
        self.emailTFClearBtn.hidden = !shouldShow;
    };
    
    // 监听开始编辑
    [[self.emailTF rac_signalForControlEvents:UIControlEventEditingDidBegin] subscribeNext:^(__kindof UIControl * _Nullable x) {
        updateClearButtonVisibility();
    }];
    
    // 监听结束编辑
    [[self.emailTF rac_signalForControlEvents:UIControlEventEditingDidEnd] subscribeNext:^(__kindof UIControl * _Nullable x) {
        updateClearButtonVisibility();
        
        // 编辑结束，校验邮箱账号是否合法
        [NoaRegisterDataHandle checkAccountInputWithRegisterType:ZLoginTypeMenuEmail
                                                  AccountInput:self.emailTF.text
                                                WhenEditFinish:^(BOOL res, NSString * _Nullable errorText) {
            @strongify(self)
            
            if (res) {
                // 检查通过
                self.emailErrorTipLabel.text = @"";
                self.emailErrorTipLabel.hidden = YES;
                [self.emailErrorTipLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.emailTF.mas_bottom).offset(0);
                    make.leading.equalTo(@20);
                    make.trailing.equalTo(self).offset(-20);
                    make.height.equalTo(@0);
                }];
            }else {
                self.emailErrorTipLabel.text = [NSString isNil:errorText] ? @"" : errorText;
                self.emailErrorTipLabel.hidden = NO;
                [self.emailErrorTipLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.emailTF.mas_bottom).offset(12);
                    make.leading.equalTo(@20);
                    make.trailing.equalTo(self).offset(-20);
                    make.height.greaterThanOrEqualTo(@14);
                }];
            }
        }];
    }];
    
    // 监听文本变化
    [self.emailTF.rac_textSignal subscribeNext:^(NSString * _Nullable text) {
        updateClearButtonVisibility();
    }];
    
    // 清理账号点击事件
    [[self.emailTFClearBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        self.emailTF.text = @"";
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

/// 获取邮箱输入框文字
- (NSString *)getEmailText {
    return self.emailTF.text ?: @"";
}

- (void)showPrepareEmail:(NSString *)eMail {
    if ([NSString isNil:eMail]) {
        return;
    }
    self.emailTF.text = eMail;
    // 手动触发信号，确保程序化赋值后也能触发验证
    [self.manualTextTrigger sendNext:eMail];
}

#pragma mark - NoaLoginBaseInputView Abstract Methods

- (NSString *)getFirstInputText {
    return [self getEmailText];
}

- (UIView *)getFirstInputView {
    return self.emailErrorTipLabel;
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
        self.emailTF.rac_textSignal,
        self.manualTextTrigger
    ]] startWith:self.emailTF.text ?: @""];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
