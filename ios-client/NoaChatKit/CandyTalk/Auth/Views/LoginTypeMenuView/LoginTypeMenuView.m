//
//  LoginTypeMenuView.m
//  NoaKit
//
//  Created by Candy on 2023/3/25.
//

#import "LoginTypeMenuView.h"

@interface LoginTypeMenuView()

@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic, strong) NSMutableArray *menuBtnArr;
@property (nonatomic, strong) NSMutableArray *inputViewArr;

@end

@implementation LoginTypeMenuView

- (instancetype)init {
    if (self = [super init]) {
        self.height = DWScale(104);
        self.typeWay = UserAuthTypePhone;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self addSubview:self.bottomLine];
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(DWScale(28));
        make.width.mas_equalTo(0);
        make.height.mas_equalTo(0);
    }];
}

- (void)setMenuTypeArr:(NSArray *)menuTypeArr {
    _menuTypeArr = menuTypeArr;
    if (_menuTypeArr.count > 0) {
        //移除旧的UI
        if (self.menuBtnArr.count > 0) {
            for (UIButton *oldBtn in self.menuBtnArr) {
                [oldBtn removeFromSuperview];
            }
        }
        if (self.inputViewArr.count > 0) {
            for (NoaInputTextView *oldInput in self.inputViewArr) {
                [oldInput removeFromSuperview];
            }
        }
        [self.menuBtnArr removeAllObjects];
        [self.inputViewArr removeAllObjects];
        //创建新的UI
        for (int i = 0; i < _menuTypeArr.count; i++) {
            int authType = [[_menuTypeArr objectAtIndex:i] intValue];
            
            UIButton *menuBtn = [[UIButton alloc] init];
            if ([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"英语"]) {
                if (i == 0) {
                    menuBtn.frame = CGRectMake(0 , 0, DWScale(120), DWScale(28));
                } else if (i == 1) {
                    menuBtn.frame = CGRectMake(DWScale(120) , 0, DWScale(80), DWScale(28));
                } else {
                    menuBtn.frame = CGRectMake(DWScale(120) + DWScale(80) * (i - 1) , 0, DWScale(80), DWScale(28));
                }
            } else if ([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"俄语"]) {
                if (i == 0) {
                    menuBtn.frame = CGRectMake(0 , 0, DWScale(80), DWScale(28));
                } else if (i == 1) {
                    menuBtn.frame = CGRectMake(DWScale(80) , 0, DWScale(160), DWScale(28));
                } else {
                    menuBtn.frame = CGRectMake(DWScale(160) + DWScale(80) * (i - 1) , 0, DWScale(80), DWScale(28));
                }
            } else if ([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"阿拉伯语"]) {
                if (i == 0) {
                    menuBtn.frame = CGRectMake((DScreenWidth - DWScale(25) - DWScale(25)) - (DWScale(80) * (i + 1)) , 0, DWScale(80), DWScale(28));
//                    menuBtn.frame = CGRectMake(0 , 0, DWScale(80), DWScale(28));
                } else if (i == 1) {
                    menuBtn.frame = CGRectMake(DScreenWidth - DWScale(25) - DWScale(25) - DWScale(80) - DWScale(110), 0, DWScale(110), DWScale(28));
//                    menuBtn.frame = CGRectMake(DWScale(80) , 0, DWScale(160), DWScale(28));
                } else {
                    menuBtn.frame = CGRectMake(DScreenWidth - DWScale(25) - DWScale(25) - DWScale(80) * 2 - DWScale(110), 0, DWScale(80), DWScale(28));
//                    menuBtn.frame = CGRectMake(DWScale(160) + DWScale(80) * (i - 1) , 0, DWScale(80), DWScale(28));
                }
            } else if ([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"波斯语"]) {
                menuBtn.frame = CGRectMake((DScreenWidth - DWScale(25) - DWScale(25)) - (DWScale(80) * (i + 1)) , 0, DWScale(80), DWScale(28));
            } else {
                menuBtn.frame = CGRectMake(DWScale(80) * i , 0, DWScale(80), DWScale(28));
            }
            menuBtn.titleLabel.numberOfLines = 1;
            
            menuBtn.tag = 100 + i;
            [menuBtn setTitle:[NSString getAuthContetnWithAuthType:authType] forState:UIControlStateNormal];
            [menuBtn setTkThemeTitleColor:@[COLOR_66, COLOR_66_DARK] forState:UIControlStateNormal];
            [menuBtn setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateSelected];
            [menuBtn addTarget:self action:@selector(mencClickAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:menuBtn];
            
            NoaInputTextView *accountInput = [[NoaInputTextView alloc] init];
            if (authType == UserAuthTypePhone) {
                accountInput.placeholderText = LanguageToolMatch(@"请输入手机号");
                accountInput.inputType = ZMessageInputViewTypePhone;
                accountInput.tipsImgName = @"img_phone_input_tip";
            } else if (authType == UserAuthTypeEmail) {
                accountInput.placeholderText = LanguageToolMatch(@"请输入邮箱");
                accountInput.inputType = ZMessageInputViewTypeNomal;
                accountInput.tipsImgName = @"img_email_input_tip";
            } else if (authType == UserAuthTypeAccount) {
                accountInput.placeholderText = LanguageToolMatch(@"请输入账号");
                accountInput.inputType = ZMessageInputViewTypeNomal;
                accountInput.tipsImgName = @"img_account_input_tip";
            }
            accountInput.inputText.keyboardDistanceFromTextField = DWScale(160);
            [self addSubview:accountInput];
            [accountInput mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(menuBtn.mas_bottom).offset(DWScale(32));
                make.leading.trailing.equalTo(self);
                make.height.mas_equalTo(DWScale(46));
            }];
            
            
           
            if (i == 0) {
                if(([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"简体中文"] ||
                    [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"繁体中文"])){
                    menuBtn.titleLabel.font = FONTB(19);
                }else{
                    menuBtn.titleLabel.font = FONTB(14);
                }
                menuBtn.selected = YES;
                accountInput.hidden = NO;
                self.currentInputView = accountInput;
                self.typeWay = authType;
                [self.bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(menuBtn.mas_centerX);
                    make.top.equalTo(menuBtn.mas_bottom).offset(DWScale(2));
                    make.width.mas_equalTo(DWScale(36));
                    make.height.mas_equalTo(DWScale(3));
                }];
            } else {
                if(([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"简体中文"] ||
                    [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"繁体中文"])){
                    menuBtn.titleLabel.font = FONTB(16);
                }else{
                    menuBtn.titleLabel.font = FONTB(12);
                }
                menuBtn.selected = NO;
                accountInput.hidden = YES;
            }

            [self.menuBtnArr addObject:menuBtn];
            [self.inputViewArr addObject:accountInput];
        }
        //当登录方式只有一种时，蓝色下划线不显示
        if (_menuBtnArr.count == 1) {
            self.bottomLine.hidden = YES;
        } else {
            self.bottomLine.hidden = NO;
        }
        
        WeakSelf
        self.currentInputView.inputStatus = ^{
            if (weakSelf.menuInputStatus) {
                weakSelf.menuInputStatus();
            }
        };
        self.currentInputView.textFieldEndInput = ^{
            if (weakSelf.menuTextEndInput) {
                weakSelf.menuTextEndInput();
            }
        };
        self.currentInputView.getCountryCodeAction = ^{
            if (weakSelf.getCountryCodeAction) {
                weakSelf.getCountryCodeAction();
            }
        };
    }
}

#pragma mark - Action
- (void)mencClickAction:(id)sender {
    UIButton *clickBtn = (UIButton *)sender;
    for (int i = 0; i<self.menuBtnArr.count; i++) {
        UIButton *menuBtn = (UIButton *)[self.menuBtnArr objectAtIndex:i];
        NoaInputTextView *accountInput = (NoaInputTextView *)[self.inputViewArr objectAtIndex:i];
            
        if ((menuBtn.tag - 100) == (clickBtn.tag - 100)) {
            int authType = [[_menuTypeArr objectAtIndex:i] intValue];
            if(([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"简体中文"] ||
                [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"繁体中文"])){
                menuBtn.titleLabel.font = FONTB(20);
            }else{
                menuBtn.titleLabel.font = FONTB(16);
            }
            menuBtn.selected = YES;
            accountInput.hidden = NO;
            self.currentInputView = accountInput;
            self.typeWay = authType;
            [self.bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(menuBtn.mas_centerX);
                make.top.equalTo(menuBtn.mas_bottom).offset(DWScale(2));
                make.width.mas_equalTo(DWScale(36));
                make.height.mas_equalTo(DWScale(3));
            }];
            
            WeakSelf
            self.currentInputView.inputStatus = ^{
                if (weakSelf.menuInputStatus) {
                    weakSelf.menuInputStatus();
                }
            };
            self.currentInputView.textFieldEndInput = ^{
                if (weakSelf.menuTextEndInput) {
                    weakSelf.menuTextEndInput();
                }
            };
        } else {
            if(([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"简体中文"] ||
                [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"繁体中文"])){
                menuBtn.titleLabel.font = FONTB(16);
            }else{
                menuBtn.titleLabel.font = FONTB(12);
            }
            menuBtn.selected = NO;
            accountInput.hidden = YES;
        }
    }
    if (self.switchLoginTypeBlock) {
        self.switchLoginTypeBlock();
    }
}

#pragma mark - Lazy
- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    }
    return _bottomLine;
}

- (NSMutableArray *)menuBtnArr {
    if (!_menuBtnArr) {
        _menuBtnArr = [[NSMutableArray alloc] init];
    }
    return _menuBtnArr;
}

- (NSMutableArray *)inputViewArr {
    if (!_inputViewArr) {
        _inputViewArr = [[NSMutableArray alloc] init];
    }
    return _inputViewArr;
}

@end
