//
//  NoaCharManagerInput.m
//  NoaKit
//
//  Created by Candy on 2023/9/15.
//

#import "NoaCharManagerInput.h"

@interface NoaCharManagerInput() <UITextFieldDelegate>

@property (nonatomic, strong)UIView *bgView;
@property (nonatomic, strong)UILabel *leftTitleLbl;
@property (nonatomic, strong)UITextField *inputText;
@property (nonatomic, strong)UIButton *clearBtn;
@property (nonatomic, strong)UIButton *vercodeBtn;
@property (nonatomic, strong)UIView *bottomLineView;

@end

@implementation NoaCharManagerInput

- (instancetype)init {
    if (self = [super init]) {
        self.isEmpty = YES;
        self.inputKeyBoardType = UIKeyboardTypeDefault;
        [self setupUI];
    }
    return self;
}

#pragma mark - UI
- (void)setupUI {
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.leftTitleLbl];
    [self.bgView addSubview:self.inputText];
    [self.bgView addSubview:self.vercodeBtn];
    [self.bgView addSubview:self.clearBtn];
    [self.bgView addSubview:self.bottomLineView];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.trailing.equalTo(self);
    }];
    
    [self.leftTitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bgView);
        make.leading.equalTo(self.bgView).offset(DWScale(16));
        make.width.mas_equalTo(DWScale(75));
        make.height.mas_equalTo(DWScale(24));
    }];
    
    [self.vercodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bgView);
        make.trailing.equalTo(self.bgView).offset(-DWScale(16));
        make.width.mas_equalTo(DWScale(110));
        make.height.mas_equalTo(DWScale(38));
    }];

    [self.clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bgView);
        make.trailing.equalTo(self.vercodeBtn.mas_leading).offset(DWScale(-15));
        make.width.height.mas_equalTo(DWScale(18));
    }];
    
    [self.inputText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bgView);
        make.leading.equalTo(self.leftTitleLbl.mas_trailing).offset(DWScale(15));
        make.trailing.equalTo(self.clearBtn.mas_leading).offset(DWScale(-10));
        make.height.mas_equalTo(DWScale(38));
    }];
    
    [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.equalTo(self.bgView);
        make.height.mas_equalTo(DWScale(0.8));
    }];
}

#pragma mark - Setter
//设置输入框默认提示内容
- (void)setPlaceholderText:(NSString *)placeholderText {
    NSMutableAttributedString*text = [[NSMutableAttributedString alloc] initWithString:placeholderText];
    self.inputText.attributedPlaceholder = text;
}

- (void)setInputKeyBoardType:(UIKeyboardType)inputKeyBoardType {
    _inputKeyBoardType = inputKeyBoardType;
    self.inputText.keyboardType = _inputKeyBoardType;
}

- (void)setLeftTitleStr:(NSString *)leftTitleStr {
    _leftTitleStr = leftTitleStr;
    self.leftTitleLbl.text = _leftTitleStr;
}

//设置输入类型
- (void)setInputType:(ZCharManagerInputType)inputType {
    switch (inputType) {
        case ZCharManagerInputTypeNomal:
        {   //常规类型
            self.leftTitleLbl.hidden = NO;
            self.inputText.secureTextEntry = NO;
            self.clearBtn.hidden = YES;
            self.vercodeBtn.hidden = YES;
            self.bottomLineView.hidden = NO;
            
            [self.vercodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.trailing.equalTo(self.bgView);
                make.width.mas_equalTo(0);
                make.height.mas_equalTo(DWScale(38));
            }];
            
            [self.clearBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.trailing.equalTo(self.bgView).offset(-DWScale(16));
                make.width.height.mas_equalTo(DWScale(18));
            }];
        }
            break;
        case ZCharManagerInputTypeVercode:
        {   //验证码类型
            self.leftTitleLbl.hidden = NO;
            self.inputText.secureTextEntry = NO;
            self.clearBtn.hidden = YES;
            self.vercodeBtn.hidden = NO;
            self.bottomLineView.hidden = NO;
            
            [self.vercodeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.trailing.equalTo(self.bgView).offset(-DWScale(16));
                make.width.mas_equalTo(DWScale(110));
                make.height.mas_equalTo(DWScale(38));
            }];
        
            [self.clearBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bgView);
                make.trailing.equalTo(self.vercodeBtn.mas_leading).offset(-DWScale(15));
                make.width.height.mas_equalTo(DWScale(18));
            }];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Getter
- (NSUInteger)textLength {
    return self.inputText.text.length;
}

- (void)configVercodeBtnCountdown {
    self.vercodeBtn.tkThemebackgroundColors = @[COLOR_C2DBFF, COLOR_C2DBFF_DARK];
    WeakSelf
    [self.vercodeBtn startCountDownTime:60 styleIndex:2 withCountDownBlock:^{
        weakSelf.vercodeBtn.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
        [weakSelf.vercodeBtn setTitle:LanguageToolMatch(@"获取验证码") forState:UIControlStateNormal];
    }];
}

#pragma mark - TextField Action
- (void)textChangedAction {
    if (![NSString isNil:self.inputText.text]) {
        self.isEmpty = NO;
        self.clearBtn.hidden = NO;
    } else {
        self.isEmpty = YES;
        self.clearBtn.hidden = YES;
    }
    //将输入框输入发生变化事件传递给外部
    if (self.inputStatus) {
        self.inputStatus();
    }
}

//获取验证码
- (void)getVerCodeAction {
    if (self.getVerCodeBlock) {
        self.getVerCodeBlock();
    }
}

//输入框一键清除
- (void)inputTextClearAction {
    self.inputText.text = @"";
    self.isEmpty = YES;
    self.clearBtn.hidden = YES;
    
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
        return YES;
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
    }
    return _bgView;
}

- (UILabel *)leftTitleLbl {
    if (!_leftTitleLbl) {
        _leftTitleLbl = [[UILabel alloc] init];
        _leftTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _leftTitleLbl.font = FONTN(16);
    }
    return _leftTitleLbl;
}

- (UITextField *)inputText {
    if (!_inputText) {
        _inputText = [[UITextField alloc] init];
        _inputText.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _inputText.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
        _inputText.font = FONTN(14);
        _inputText.delegate = self;
        _inputText.textAlignment = NSTextAlignmentLeft;
        _inputText.keyboardType = self.inputKeyBoardType;
        [_inputText addTarget:self action:@selector(textChangedAction) forControlEvents:UIControlEventEditingChanged];
    }
    return _inputText;
}

- (UIButton *)vercodeBtn {
    if (!_vercodeBtn) {
        _vercodeBtn = [[UIButton alloc] init];
        [_vercodeBtn setTitle:LanguageToolMatch(@"获取验证码") forState:UIControlStateNormal];
        [_vercodeBtn rounded:DWScale(8)];
        _vercodeBtn.titleLabel.font = FONTN(14);
        [_vercodeBtn setTitleColor:COLORWHITE forState:UIControlStateNormal];
        _vercodeBtn.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
        [_vercodeBtn setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateSelected];
        [_vercodeBtn setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateHighlighted];
        [_vercodeBtn addTarget:self action:@selector(getVerCodeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _vercodeBtn;
}

- (UIButton *)clearBtn {
    if (!_clearBtn) {
        _clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clearBtn setImage:ImgNamed(@"icon_text_clear") forState:UIControlStateNormal];
        _clearBtn.hidden = YES;
        [_clearBtn addTarget:self action:@selector(inputTextClearAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clearBtn;
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] init];
        _bottomLineView.tkThemebackgroundColors = @[[COLOR_00 colorWithAlphaComponent:0.1], [COLOR_00 colorWithAlphaComponent:0.1]];
    }
    return _bottomLineView;
}


@end
