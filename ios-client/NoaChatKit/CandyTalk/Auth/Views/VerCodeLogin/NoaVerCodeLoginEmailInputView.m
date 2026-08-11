//
//  NoaVerCodeLoginEmailInputView.m
//  NoaChatKit
//
//  Created by phl on 2025/11/18.
//

#import "NoaVerCodeLoginEmailInputView.h"
#import "NoaFixedSizeRightView.h"
#import "NoaVerCodeLoginDataHandle.h"

@interface NoaVerCodeLoginEmailInputView ()

/// 电子邮箱账号输入框
@property (nonatomic, strong) UITextField *emailTF;

/// 邮箱输入清理文本按钮
@property (nonatomic, strong) UIButton *emailTFClearBtn;

/// 输入验证结果信号（内部实现）
@property (nonatomic, strong, readwrite) RACSubject<NSNumber *> *emailValidationResultSignal;

@end

@implementation NoaVerCodeLoginEmailInputView

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
        _emailTF.keyboardType = UIKeyboardTypeEmailAddress;
        _emailTF.delegate = self;
        // 创建属性字符串
        NSDictionary *attributes = @{
            NSForegroundColorAttributeName: COLOR_99,
            NSFontAttributeName:FONTM(14)
        };
        _emailTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LanguageToolMatch(@"请输入邮箱") attributes:attributes];
        
        // 获取当前首选语言，判断是否为阿拉伯语(ar)或波斯语(fa)
        NSString *preferredLanguage = [NSLocale preferredLanguages].firstObject;
        BOOL isArabic = ([preferredLanguage hasPrefix:@"ar"] || [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"阿拉伯语"]); // 阿拉伯语代码以"ar"开头
        BOOL isPersian = ([preferredLanguage hasPrefix:@"fa"] || [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"波斯语"]); // 波斯语代码以"fa"开头
        
        // 左侧占用12个单位像素(阿拉伯语语波斯语在右侧)
        if (isArabic || isPersian) {
            // 设置左边文字距离左边框间隔
            _emailTF.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
            _emailTF.rightViewMode = UITextFieldViewModeAlways;
        } else {
            // 设置左边文字距离左边框间隔
            _emailTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
            _emailTF.leftViewMode = UITextFieldViewModeAlways;
        }
    }
    return _emailTF;
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
              CurrentLoginWay:(ZLoginAndRegisterTypeMenu)currentLoginWay {
    self = [super initWithFrame:frame CurrentLoginWay:currentLoginWay];
    if (self) {
        [self setUpUI];
        [self processData];
    }
    return self;
}

- (void)setUpUI {
    [self addSubview:self.emailTF];
    
    [self.emailTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.leading.equalTo(@20);
        make.trailing.equalTo(self).offset(-20);
        make.height.equalTo(@58);
    }];
    
    [self setupRightViewForEmailTFextField];
    
    // 调用父类的 setupUI 方法
    [super setupUI];
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
    }];
    
    // 监听文本变化
    [self.emailTF.rac_textSignal subscribeNext:^(NSString * _Nullable text) {
        updateClearButtonVisibility();
    }];
    
    // 清理账号点击事件
    [[self.emailTFClearBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        self.emailTF.text = @"";
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
}

#pragma mark - NoaLoginBaseInputView Abstract Methods

- (NSString *)getFirstInputText {
    return [self getEmailText];
}

- (UIView *)getFirstInputView {
    return self.emailTF;
}

- (RACSignal<NSString *> *)getFirstInputTextSignal {
    return self.emailTF.rac_textSignal;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
