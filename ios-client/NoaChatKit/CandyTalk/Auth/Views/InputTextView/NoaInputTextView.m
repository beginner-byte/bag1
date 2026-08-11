//
//  NoaInputTextView.m
//  NoaKit
//
//  Created by Candy on 2026/8/30.
//

#import "NoaInputTextView.h"
#import "FMDB.h"
#import "NoaAuthInputTools.h"

@interface NoaInputTextView() <UITextFieldDelegate>

@property (nonatomic, strong)UIView *bgView;
@property (nonatomic, strong)UIImageView *typeImgView;
@property (nonatomic, strong)UIButton *areaCodeBtn;
@property (nonatomic, strong)UIView *lineView;
@property (nonatomic, strong)UITextField *inputText;
@property (nonatomic, strong)UIButton *vercodeBtn;
@property (nonatomic, strong)UIButton *eyeBtn;
@property (nonatomic, strong)UIButton *clearButton;

@end

@implementation NoaInputTextView

- (instancetype)init {
    if (self = [super init]) {
        self.isEmpty = YES;
        self.enableEdit = YES;
        self.inputKeyBoardType = UIKeyboardTypeDefault;
        self.countryCodeStr = @"+86";
        self.isShowBoard = YES;//默认展示边框
        [self setupUI];
        [self setupConstraints];
        [self setupUserLocalDefaulCountryCode];
    }
    return self;
}

#pragma mark - UI
- (void)setupUI {
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.typeImgView];
    [self.bgView addSubview:self.areaCodeBtn];
    [self.bgView addSubview:self.lineView];
    [self.bgView addSubview:self.inputText];
    [self.bgView addSubview:self.vercodeBtn];
    [self.bgView addSubview:self.eyeBtn];
    [self.bgView addSubview:self.clearButton];
}

- (void)setupConstraints {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.trailing.equalTo(self);
    }];
    
    [self.typeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bgView);
        make.leading.equalTo(self.bgView).offset(DWScale(12));
        make.width.mas_equalTo(DWScale(18));
        make.height.mas_equalTo(DWScale(18));
    }];
    
    [self.areaCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bgView);
        make.leading.equalTo(self.typeImgView.mas_trailing).offset(DWScale(6));
        make.width.mas_equalTo(DWScale(45));
        make.height.mas_equalTo(DWScale(22));
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bgView);
        make.leading.equalTo(self.areaCodeBtn.mas_trailing).offset(DWScale(5));
        make.width.mas_equalTo(DWScale(2));
        make.height.mas_equalTo(DWScale(18));
    }];
    
    [self.vercodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bgView);
        make.trailing.equalTo(self.bgView).offset(DWScale(-4));
        make.width.mas_equalTo(DWScale(110));
        make.height.mas_equalTo(DWScale(38));
    }];
    
    [self.eyeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bgView);
        make.trailing.equalTo(self.vercodeBtn).offset(DWScale(-20));
        make.width.mas_equalTo(DWScale(21));
        make.height.mas_equalTo(DWScale(16));
    }];
    
    [self.clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bgView);
        make.trailing.equalTo(self.eyeBtn.mas_leading).offset(DWScale(-15));
        make.width.height.mas_equalTo(DWScale(18));
    }];
    
    [self.inputText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bgView);
        make.leading.equalTo(self.lineView.mas_trailing).offset(DWScale(6));
        make.trailing.equalTo(self.clearButton.mas_leading).offset(DWScale(-10));
        make.height.mas_equalTo(DWScale(38));
    }];
}

//默认展示用户当前设备国家地区号
- (void)setupUserLocalDefaulCountryCode {
    //select prefix from SMS_country where country_code_2 = 'HK'
    NSString *area_code = [ [NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    NSString *prefixCode;
    NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"noa_constant" ofType:@"db"];
    FMDatabase *db = [[FMDatabase alloc] initWithPath:dbPath];
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"select prefix from SMS_country where country_code_2 = '%@'", area_code];
        FMResultSet *rs = [db executeQuery:sql, area_code];//查询数据库
        if ([rs next]) {
            prefixCode = [rs stringForColumn:@"prefix"];
        }
        [rs close];
    }
    if (![NSString isNil:prefixCode]) {
        self.countryCodeStr = [NSString stringWithFormat:@"+%@", prefixCode];
        [_areaCodeBtn setTitle:self.countryCodeStr forState:UIControlStateNormal];
    } else {
        self.countryCodeStr = @"+86";
        [_areaCodeBtn setTitle:self.countryCodeStr forState:UIControlStateNormal];
    }
}

#pragma mark - Setter
//设置输入框预输入内容
- (void)setPreInputText:(NSString *)preInputText {
    _preInputText = preInputText;
    if (![NSString isNil:_preInputText]) {
        self.inputText.text = _preInputText;
        self.isEmpty = NO;
        self.clearButton.hidden = NO;
    } else {
        self.inputText.text = @"";
        self.isEmpty = YES;
        self.clearButton.hidden = YES;
    }
    
    if (self.inputStatus) {
        self.inputStatus();
    }
}

- (BOOL)isEmpty {
    return [NSString isNil:self.inputText.text];
}

//输入框左边的图标图片
- (void)setTipsImgName:(NSString *)tipsImgName {
    _tipsImgName = tipsImgName;
    if (![NSString isNil:_tipsImgName]) {
        self.typeImgView.image = ImgNamed(_tipsImgName);
        [self.typeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bgView);
            make.leading.equalTo(self.bgView).offset(DWScale(12));
            make.width.mas_equalTo(DWScale(18));
            make.height.mas_equalTo(DWScale(18));
        }];
    } else {
        [self.typeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bgView);
            make.leading.equalTo(self.bgView).offset(DWScale(12));
            make.width.mas_equalTo(0);
            make.height.mas_equalTo(DWScale(18));
        }];

    }
}

//设置输入框默认提示内容
- (void)setPlaceholderText:(NSString *)placeholderText {
    NSMutableAttributedString*text= [[NSMutableAttributedString alloc] initWithString:placeholderText];
    self.inputText.attributedPlaceholder = text;
}

- (void)setInputKeyBoardType:(UIKeyboardType)inputKeyBoardType {
    _inputKeyBoardType = inputKeyBoardType;
    self.inputText.keyboardType = _inputKeyBoardType;
}

- (void)setCountryCodeStr:(NSString *)countryCodeStr {
    _countryCodeStr = countryCodeStr;
    if (![NSString isNil:_countryCodeStr]) {
        [_areaCodeBtn setTitle:_countryCodeStr forState:UIControlStateNormal];
    }
}

//设置输入类型
- (void)setInputType:(ZMessageInputViewType)inputType {
    switch (inputType) {
        case ZMessageInputViewTypeSimple:
        {   //简易类型
            self.typeImgView.hidden = YES;
            self.areaCodeBtn.hidden = YES;
            self.countryCodeStr = @"";
            self.lineView.hidden = YES;
            self.vercodeBtn.hidden = YES;
            self.eyeBtn.hidden = YES;
            self.clearButton.hidden = YES;
            self.inputText.secureTextEntry = NO;
            
            [self.typeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.leading.equalTo(self.bgView).offset(DWScale(12));
                make.width.mas_equalTo(0);
                make.height.mas_equalTo(DWScale(18));
            }];
            
            [self.areaCodeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.leading.equalTo(self.typeImgView.mas_trailing);
                make.width.mas_equalTo(0);
                make.height.mas_equalTo(DWScale(22));
            }];
            
            [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.leading.equalTo(self.areaCodeBtn.mas_trailing);
                make.width.mas_equalTo(0);
                make.height.mas_equalTo(DWScale(20));
            }];
            
            [self.vercodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.trailing.equalTo(self.bgView);
                make.width.mas_equalTo(0);
                make.height.mas_equalTo(DWScale(38));
            }];
            
            [self.eyeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.trailing.equalTo(self.bgView).offset(DWScale(-20));
                make.width.mas_equalTo(0);
                make.height.mas_equalTo(DWScale(16));
            }];
            
            [self.clearButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.trailing.equalTo(self.bgView).offset(DWScale(-20));
                make.width.height.mas_equalTo(DWScale(18));
            }];
        }
            break;
        case ZMessageInputViewTypeNomal:
        {   //常规类型
            self.typeImgView.hidden = NO;
            self.areaCodeBtn.hidden = YES;
            self.countryCodeStr = @"";
            self.lineView.hidden = YES;
            self.vercodeBtn.hidden = YES;
            self.eyeBtn.hidden = YES;
            self.clearButton.hidden = YES;
            self.inputText.secureTextEntry = NO;
            
            [self.typeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.leading.equalTo(self.bgView).offset(DWScale(12));
                make.width.mas_equalTo(DWScale(18));
                make.height.mas_equalTo(DWScale(18));
            }];
            
            [self.areaCodeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.leading.equalTo(self.typeImgView.mas_trailing);
                make.width.mas_equalTo(0);
                make.height.mas_equalTo(DWScale(22));
            }];
            
            [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.leading.equalTo(self.areaCodeBtn.mas_trailing);
                make.width.mas_equalTo(0);
                make.height.mas_equalTo(DWScale(20));
            }];
            
            [self.vercodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.trailing.equalTo(self.bgView);
                make.width.mas_equalTo(0);
                make.height.mas_equalTo(DWScale(38));
            }];
            
            [self.eyeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.trailing.equalTo(self.bgView).offset(DWScale(-20));
                make.width.mas_equalTo(0);
                make.height.mas_equalTo(DWScale(16));
            }];
            
            [self.clearButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.trailing.equalTo(self.bgView).offset(DWScale(-20));
                make.width.height.mas_equalTo(DWScale(18));
            }];
        }
            break;
        case ZMessageInputViewTypePhone:
        {   //手机号类型
            self.typeImgView.hidden = NO;
            self.areaCodeBtn.hidden = NO;
            self.countryCodeStr = self.areaCodeBtn.titleLabel.text;
            self.lineView.hidden = NO;
            self.vercodeBtn.hidden = YES;
            self.eyeBtn.hidden = YES;
            self.clearButton.hidden = YES;
            self.inputText.secureTextEntry = NO;
            
            [self.typeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.leading.equalTo(self.bgView).offset(DWScale(12));
                make.width.mas_equalTo(DWScale(18));
                make.height.mas_equalTo(DWScale(18));
            }];
            
            [self.areaCodeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.leading.equalTo(self.typeImgView.mas_trailing).offset(DWScale(6));
                make.width.mas_equalTo(DWScale(45));
                make.height.mas_equalTo(DWScale(22));
            }];
            
            [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.leading.equalTo(self.areaCodeBtn.mas_trailing).offset(DWScale(5));
                make.width.mas_equalTo(DWScale(2));
                make.height.mas_equalTo(DWScale(18));
            }];
            
            [self.vercodeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.trailing.equalTo(self.bgView);
                make.width.mas_equalTo(0);
                make.height.mas_equalTo(DWScale(38));
            }];
            
            [self.eyeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.trailing.equalTo(self.bgView).offset(DWScale(-20));
                make.width.mas_equalTo(0);
                make.height.mas_equalTo(DWScale(16));
            }];
            
            [self.clearButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.trailing.equalTo(self.bgView).offset(DWScale(-20));
                make.width.height.mas_equalTo(DWScale(18));
            }];
        }
            break;
        case ZMessageInputViewTypePassword:
        {   //密码类型
            self.typeImgView.hidden = NO;
            self.areaCodeBtn.hidden = YES;
            self.countryCodeStr = @"";
            self.lineView.hidden = YES;
            self.vercodeBtn.hidden = YES;
            self.eyeBtn.hidden = NO;
            self.clearButton.hidden = YES;
            self.inputText.secureTextEntry = YES;
            
            [self.typeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.leading.equalTo(self.bgView).offset(DWScale(12));
                make.width.mas_equalTo(DWScale(18));
                make.height.mas_equalTo(DWScale(18));
            }];
            
            [self.areaCodeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.leading.equalTo(self.typeImgView.mas_trailing);
                make.width.mas_equalTo(0);
                make.height.mas_equalTo(DWScale(22));
            }];
            
            [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.leading.equalTo(self.areaCodeBtn.mas_trailing);
                make.width.mas_equalTo(0);
                make.height.mas_equalTo(DWScale(18));
            }];
            
            [self.vercodeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.trailing.equalTo(self.bgView);
                make.width.mas_equalTo(0);
                make.height.mas_equalTo(DWScale(38));
            }];
            
            [self.eyeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.trailing.equalTo(self.bgView).offset(DWScale(-20));
                make.width.mas_equalTo(DWScale(21));
                make.height.mas_equalTo(DWScale(16));
            }];
            
            [self.clearButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.trailing.equalTo(self.eyeBtn.mas_leading).offset(DWScale(-15));
                make.width.height.mas_equalTo(DWScale(18));
            }];
        }
            break;
        case ZMessageInputViewTypeVercode:
        {   //手机号类型
            self.typeImgView.hidden = NO;
            self.areaCodeBtn.hidden = YES;
            self.countryCodeStr = @"";
            self.lineView.hidden = YES;
            self.vercodeBtn.hidden = NO;
            self.eyeBtn.hidden = YES;
            self.clearButton.hidden = YES;
            self.inputText.secureTextEntry = NO;
            
            [self.areaCodeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.leading.equalTo(self.typeImgView.mas_trailing);
                make.width.mas_equalTo(0);
                make.height.mas_equalTo(DWScale(22));
            }];
            
            [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.leading.equalTo(self.areaCodeBtn.mas_trailing);
                make.width.mas_equalTo(0);
                make.height.mas_equalTo(DWScale(18));
            }];
            
            [self.vercodeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.trailing.equalTo(self.bgView).offset(DWScale(-4));
                make.width.mas_equalTo(DWScale(110));
                make.height.mas_equalTo(DWScale(38));
            }];
            
            [self.eyeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.trailing.equalTo(self.bgView).offset(DWScale(-20));
                make.width.mas_equalTo(0);
                make.height.mas_equalTo(DWScale(16));
            }];
            
            [self.clearButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.trailing.equalTo(self.vercodeBtn.mas_leading).offset(DWScale(-20));
                make.width.height.mas_equalTo(DWScale(18));
            }];
        }
            break;
        case ZMessageInputViewTypeNoCancel:
        {   //不带一键清空text功能
            self.typeImgView.hidden = NO;
            self.areaCodeBtn.hidden = YES;
            self.countryCodeStr = @"";
            self.lineView.hidden = YES;
            self.vercodeBtn.hidden = YES;
            self.eyeBtn.hidden = YES;
            self.clearButton.hidden = YES;
            self.inputText.secureTextEntry = NO;
            
            [self.typeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.leading.equalTo(self.bgView).offset(DWScale(12));
                make.width.mas_equalTo(DWScale(18));
                make.height.mas_equalTo(DWScale(18));
            }];
            
            [self.areaCodeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.leading.equalTo(self.typeImgView.mas_trailing);
                make.width.mas_equalTo(0);
                make.height.mas_equalTo(DWScale(22));
            }];
            
            [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.leading.equalTo(self.areaCodeBtn.mas_trailing);
                make.width.mas_equalTo(0);
                make.height.mas_equalTo(DWScale(20));
            }];
            
            [self.vercodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.trailing.equalTo(self.bgView);
                make.width.mas_equalTo(0);
                make.height.mas_equalTo(DWScale(38));
            }];
            
            [self.eyeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.trailing.equalTo(self.bgView).offset(DWScale(-20));
                make.width.mas_equalTo(0);
                make.height.mas_equalTo(DWScale(16));
            }];
            
            [self.clearButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.trailing.equalTo(self.bgView).offset(DWScale(-20));
                make.width.mas_equalTo(0);
                make.height.mas_equalTo(DWScale(18));
            }];
            
            [self.inputText mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.leading.equalTo(self.lineView.mas_trailing).offset(DWScale(6));
                make.trailing.equalTo(self.bgView).offset(DWScale(-20));
                make.height.mas_equalTo(DWScale(38));
            }];
        }
            break;
        default:
            break;
    }
}

- (void)setIsShowBoard:(BOOL)isShowBoard {
    _isShowBoard = isShowBoard;
    if (_isShowBoard) {
        [_bgView rounded:DWScale(14) width:1 color:COLOR_A3C8FF];
    } else {
        [_bgView rounded:DWScale(14) width:0 color:COLOR_CLEAR];
    }
}

- (void)setBgViewBackColor:(NSArray *)bgViewBackColor {
    if (bgViewBackColor) {
        _bgViewBackColor = bgViewBackColor;
        self.bgView.tkThemebackgroundColors = _bgViewBackColor;
        self.inputText.tkThemebackgroundColors = _bgViewBackColor;
    }
}

- (void)setIsSSO:(BOOL)isSSO {
    _isSSO = isSSO;
}

- (void)setIsPassword:(BOOL)isPassword {
    _isPassword = isPassword;
}

- (void)setEnableEdit:(BOOL)enableEdit {
    _enableEdit = enableEdit;
    if (_enableEdit) {
        self.inputText.userInteractionEnabled = YES;
        self.areaCodeBtn.userInteractionEnabled = YES;
    } else {
        self.inputText.userInteractionEnabled = NO;
        self.areaCodeBtn.userInteractionEnabled = NO;
    }
}

#pragma mark - Getter
- (NSUInteger)textLength {
    return self.inputText.text.length;
}

- (void)configVercodeBtnCountdown {
    self.vercodeBtn.tkThemebackgroundColors = @[COLOR_E3E8EF, COLOR_E3E8EF];
    WeakSelf
    [self.vercodeBtn startCountDownTime:60 styleIndex:2 withCountDownBlock:^{
        weakSelf.vercodeBtn.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
        [weakSelf.vercodeBtn setTitle:LanguageToolMatch(@"获取验证码") forState:UIControlStateNormal];
    }];
}

- (NSString *)getCurrentCountryCode {
    NSString *countryCode = @"";
    NSString *areaBtnTitle = self.areaCodeBtn.titleLabel.text;
    countryCode = [areaBtnTitle stringByReplacingOccurrencesOfString:@"+" withString:@""];
    return countryCode;
}

#pragma mark - TextField Action
- (void)textChangedAction {
    if (![NSString isNil:self.inputText.text]) {
        self.isEmpty = NO;
        self.clearButton.hidden = NO;
    } else {
        self.isEmpty = YES;
        self.clearButton.hidden = YES;
    }
    //将输入框输入发生变化事件传递给外部
    if (self.inputStatus) {
        self.inputStatus();
    }
}

//选择手机号国家区号
- (void)areaCodeSelectAction {
    if (self.getCountryCodeAction) {
        self.getCountryCodeAction();
    }
}

//获取验证码
- (void)getVerCodeAction {
    if (self.getVerCodeBlock) {
        self.getVerCodeBlock();
    }
}

//密码是否明文显示
- (void)passwordEyeBtnAction {
    self.eyeBtn.selected = !self.eyeBtn.selected;
    self.inputText.secureTextEntry = !self.eyeBtn.selected;
}

//输入框一键清除
- (void)inputTextClearAction {
    self.inputText.text = @"";
    self.isEmpty = YES;
    self.clearButton.hidden = YES;
    
    if (self.inputStatus) {
        self.inputStatus();
    }
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (self.textFieldEndInput) {
        self.textFieldEndInput();
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@" "] || [string isEqualToString:@"  "])
    {   //当输入为空格时
        return NO;
    } else {
        // 允许删除字符
        if ([string isEqualToString:@""]) {
            return YES;
        }
        if (_isSSO) {
            // 检查新输入的字符是否是数字或字母
            NSCharacterSet *allowedCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
            BOOL isValid = [string rangeOfCharacterFromSet:allowedCharacters].location == NSNotFound;
            return isValid;
        } else if (_isPassword) {
            if ([NoaAuthInputTools checkCreatPasswordInputWithText:string]) {
                return YES;
            } else {
                return NO;
            }
        } else {
            return YES;
        }
    }
}

- (void)textFieldDidPaste:(UITextField *)textField {
    if (_isSSO) {
        // 检查粘贴板内容，如果包含非数字或字母的字符，则移除它们
        NSString *pastedString = [UIPasteboard generalPasteboard].string;
        NSCharacterSet *allowedCharacters = [NSCharacterSet alphanumericCharacterSet];
        NSString *strippedString = [[pastedString componentsSeparatedByCharactersInSet:[allowedCharacters invertedSet]] componentsJoinedByString:@""];
        if (![pastedString isEqualToString:strippedString]) {
            textField.text = strippedString;
        }
    }
    if (_isPassword) {
        NSString *pastedString = [UIPasteboard generalPasteboard].string;
        if ([NoaAuthInputTools checkCreatPasswordEndWithTextFormat:pastedString]) {
            textField.text = pastedString;
        } else {
            textField.text = @"";
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    //过滤空格
    NSString *temText = [[self.inputText.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@""];
    self.inputText.text = temText;
}

#pragma mark - Lazy
- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
        _bgView.userInteractionEnabled = YES;
        [_bgView rounded:DWScale(14) width:1 color:COLOR_A3C8FF];
    }
    return _bgView;
}

- (UIImageView *)typeImgView {
    if (!_typeImgView) {
        _typeImgView = [[UIImageView alloc] init];
    }
    return _typeImgView;
}

- (UIButton *)areaCodeBtn {
    if (!_areaCodeBtn) {
        _areaCodeBtn = [[UIButton alloc] init];
        [_areaCodeBtn setTitle:@"+86" forState:UIControlStateNormal];
        [_areaCodeBtn setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateNormal];
        _areaCodeBtn.titleLabel.font = FONTN(16);
        [_areaCodeBtn addTarget:self action:@selector(areaCodeSelectAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _areaCodeBtn;
}
 
- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.tkThemebackgroundColors = @[COLOR_DFDFDF, COLOR_DFDFDF];
    }
    return _lineView;
}

- (UITextField *)inputText {
    if (!_inputText) {
        _inputText = [[UITextField alloc] init];
        _inputText.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _inputText.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
        _inputText.font = FONTN(16);
        _inputText.delegate = self;
        _inputText.textAlignment = NSTextAlignmentLeft;
        _inputText.keyboardType = self.inputKeyBoardType;
        [_inputText addTarget:self action:@selector(textChangedAction) forControlEvents:UIControlEventEditingChanged];
        if(([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"简体中文"] ||
            [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"繁体中文"])){
            _inputText.font = FONTN(16);
        }else{
            _inputText.font = FONTB(12);
        }
    }
    return _inputText;
}

- (UIButton *)vercodeBtn {
    if (!_vercodeBtn) {
        _vercodeBtn = [[UIButton alloc] init];
        [_vercodeBtn setTitle:LanguageToolMatch(@"获取验证码") forState:UIControlStateNormal];
        [_vercodeBtn rounded:12];
        _vercodeBtn.titleLabel.font = FONTN(15);
        [_vercodeBtn setTitleColor:COLORWHITE forState:UIControlStateNormal];
        _vercodeBtn.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
        [_vercodeBtn setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateSelected];
        [_vercodeBtn setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateHighlighted];
        [_vercodeBtn addTarget:self action:@selector(getVerCodeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _vercodeBtn;
}

- (UIButton *)eyeBtn {
    if (!_eyeBtn) {
        _eyeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_eyeBtn setImage:ImgNamed(@"icon_eye_off") forState:UIControlStateNormal];
        [_eyeBtn setImage:ImgNamed(@"icon_eye_on") forState:UIControlStateSelected];
        _eyeBtn.selected = NO;
        _eyeBtn.hidden = YES;
        [_eyeBtn addTarget:self action:@selector(passwordEyeBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _eyeBtn;
}

- (UIButton *)clearButton {
    if (!_clearButton) {
        _clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clearButton setImage:ImgNamed(@"icon_text_clear") forState:UIControlStateNormal];
        _clearButton.hidden = YES;
        [_clearButton addTarget:self action:@selector(inputTextClearAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clearButton;
}

@end
