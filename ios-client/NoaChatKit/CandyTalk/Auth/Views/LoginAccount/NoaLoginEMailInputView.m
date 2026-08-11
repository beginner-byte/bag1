//
//  NoaLoginEMailInputView.m
//  NoaChatKit
//
//  Created by phl on 2025/11/7.
//

#import "NoaLoginEMailInputView.h"

@interface NoaLoginEMailInputView ()

/// 电子邮箱账号输入框
@property (nonatomic, strong) UITextField *emailTF;

/// 输入验证结果信号（内部实现）
@property (nonatomic, strong, readwrite) RACSubject<NSNumber *> *emailValidationResultSignal;

@end

@implementation NoaLoginEMailInputView

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

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
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
    
    // 调用父类的 setupUI 方法
    [super setupUI];
}

- (void)processData {
    // 调用父类的 processData 方法
    [super processData];
}

/// 获取邮箱输入框文字
- (NSString *)getEmailText {
    return self.emailTF.text ?: @"";
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
