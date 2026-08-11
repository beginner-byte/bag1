//
//  NoaLoginAccountInputView.m
//  NoaChatKit
//
//  Created by phl on 2025/11/7.
//

#import "NoaLoginAccountInputView.h"

@interface NoaLoginAccountInputView ()

/// 账号输入框
@property (nonatomic, strong) UITextField *accountTF;

/// 输入验证结果信号（内部实现）
@property (nonatomic, strong, readwrite) RACSubject<NSNumber *> *accountValidationResultSignal;

@end

@implementation NoaLoginAccountInputView

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
        _accountTF.keyboardType = UIKeyboardTypeDefault;
        _accountTF.delegate = self;
        // 创建属性字符串
        NSDictionary *attributes = @{
            NSForegroundColorAttributeName: COLOR_99,
            NSFontAttributeName:FONTM(14)
        };
        _accountTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LanguageToolMatch(@"请输入账号") attributes:attributes];
        
        // 获取当前首选语言，判断是否为阿拉伯语(ar)或波斯语(fa)
        NSString *preferredLanguage = [NSLocale preferredLanguages].firstObject;
        BOOL isArabic = ([preferredLanguage hasPrefix:@"ar"] || [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"阿拉伯语"]); // 阿拉伯语代码以"ar"开头
        BOOL isPersian = ([preferredLanguage hasPrefix:@"fa"] || [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"波斯语"]); // 波斯语代码以"fa"开头
        
        // 左侧占用12个单位像素(阿拉伯语语波斯语在右侧)
        if (isArabic || isPersian) {
            // 设置左边文字距离左边框间隔
            _accountTF.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
            _accountTF.rightViewMode = UITextFieldViewModeAlways;
        } else {
            // 设置左边文字距离左边框间隔
            _accountTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
            _accountTF.leftViewMode = UITextFieldViewModeAlways;
        }
    }
    return _accountTF;
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

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
        [self processData];
    }
    return self;
}

- (void)setUpUI {
    [self addSubview:self.accountTF];
    
    [self.accountTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.leading.equalTo(@20);
        make.trailing.equalTo(self).offset(-20);
        make.height.equalTo(@58);
    }];
    
    // 调用父类的 setupUI 方法
    [super setupUI];
}

- (void)processData {
    // 调用父类的 processData 方法
    [super processData];
}

/// 获取账号输入框文字
- (NSString *)getAccountText {
    return self.accountTF.text ?: @"";
}

#pragma mark - NoaLoginBaseInputView Abstract Methods

- (NSString *)getFirstInputText {
    return [self getAccountText];
}

- (UIView *)getFirstInputView {
    return self.accountTF;
}

- (RACSignal<NSString *> *)getFirstInputTextSignal {
    return self.accountTF.rac_textSignal;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
