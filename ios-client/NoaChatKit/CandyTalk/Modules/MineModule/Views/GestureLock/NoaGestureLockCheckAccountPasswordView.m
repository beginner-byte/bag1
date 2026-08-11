//
//  NoaGestureLockCheckAccountPasswordView.m
//  NoaKit
//
//  Created by Candy on 2023/4/24.
//

#import "NoaGestureLockCheckAccountPasswordView.h"
#import "NoaToolManager.h"
#import "LXChatEncrypt.h"

@interface NoaGestureLockCheckAccountPasswordView ()
@property (nonatomic, strong) UIView *viewContent;
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UITextField *tfPassword;
@property (nonatomic, strong) UIButton *btnEye;
@property (nonatomic, strong) UIButton *btnSure;

@property (nonatomic, copy) NSString *gesturePassword;//手势密码
@property (nonatomic, assign) NSInteger checkNumber;//验证手势密码次数
@property (nonatomic, assign) NSInteger checkAccountPasswordNumber;//验证用户密码次数
//键盘高度
@property (nonatomic, assign) CGFloat keyboardH;
@end

@implementation NoaGestureLockCheckAccountPasswordView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        
        //键盘监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(systemKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(systemKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        NSString *userKey = [NSString stringWithFormat:@"%@-GesturePassword", UserManager.userInfo.userUID];
        NSString *jsonStr = [[MMKV defaultMMKV] getStringForKey:userKey];
        
        if (![NSString isNil:jsonStr]) {
            
            NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
            if (!error) {
                _gesturePassword = [dict objectForKeySafe:@"password"];
                _checkNumber = [[dict objectForKeySafe:@"checkNumber"] integerValue];
                _checkAccountPasswordNumber = [[dict objectForKeySafe:@"checkAccountPassword"] integerValue];
            }
            
            @weakify(self)
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC));
            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                @strongify(self)
                [self.tfPassword becomeFirstResponder];
            });
            
        }
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(DScreenWidth, DScreenHeight));
    }];
    self.tkThemebackgroundColors = @[[COLOR_00 colorWithAlphaComponent:0.3], [COLOR_00_DARK colorWithAlphaComponent:0.3]];
    
    _viewContent = [[UIView alloc] init];
    _viewContent.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
    [_viewContent round:DWScale(16) RectCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
    [self addSubview:_viewContent];
    [_viewContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.centerX.equalTo(self);
        make.height.mas_equalTo(DWScale(238) + DHomeBarH);
        
    }];
    
    _lblTitle = [UILabel new];
    _lblTitle.text = LanguageToolMatch(@"请输入账户密码");
    _lblTitle.font = FONTR(16);
    _lblTitle.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [_viewContent addSubview:_lblTitle];
    [_lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewContent).offset(DWScale(40));
        make.centerX.equalTo(_viewContent);
    }];
    
    UIView *viewTF = [UIView new];
    viewTF.layer.cornerRadius = DWScale(14);
    viewTF.layer.masksToBounds = YES;
    viewTF.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
    [_viewContent addSubview:viewTF];
    [viewTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lblTitle.mas_bottom).offset(DWScale(20));
        make.centerX.equalTo(_viewContent);
        make.size.mas_equalTo(CGSizeMake(DWScale(343), DWScale(48)));
    }];
    
    
    _tfPassword = [[UITextField alloc] init];
    _tfPassword.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _tfPassword.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
    _tfPassword.font = FONTN(16);
    _tfPassword.placeholder = LanguageToolMatch(@"请输入账户密码");
    _tfPassword.secureTextEntry = YES;
    _tfPassword.textAlignment = NSTextAlignmentLeft;
    [_tfPassword addTarget:self action:@selector(textFieldChanged) forControlEvents:UIControlEventEditingChanged];
    [_viewContent addSubview:_tfPassword];
    [_tfPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(viewTF);
        make.leading.equalTo(viewTF).offset(DWScale(16));
        make.trailing.equalTo(viewTF).offset(-DWScale(16));
        make.height.mas_equalTo(DWScale(40));
    }];
    
    _btnEye = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnEye setImage:ImgNamed(@"icon_eye_off") forState:UIControlStateNormal];
    [_btnEye setImage:ImgNamed(@"icon_eye_on") forState:UIControlStateSelected];
    _btnEye.selected = NO;
    _btnEye.hidden = YES;
    [_btnEye addTarget:self action:@selector(btnEyeClick) forControlEvents:UIControlEventTouchUpInside];
    [_viewContent addSubview:_btnEye];
    [_btnEye mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(viewTF);
        make.trailing.equalTo(viewTF).offset(-DWScale(20));
        make.size.mas_equalTo(CGSizeMake(DWScale(24), DWScale(24)));
    }];
    
    _btnSure = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnSure setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    [_btnSure setTkThemeTitleColor:@[COLORWHITE, COLORWHITE_DARK] forState:UIControlStateNormal];
    _btnSure.titleLabel.font = FONTR(16);
    [_btnSure setTkThemebackgroundColors:@[COLOR_5966F2, COLOR_5966F2_DARK]];
    _btnSure.layer.cornerRadius = DWScale(14);
    _btnSure.layer.masksToBounds = YES;
    [_btnSure addTarget:self action:@selector(btnSureClick) forControlEvents:UIControlEventTouchUpInside];
    [_viewContent addSubview:_btnSure];
    [_btnSure mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_viewContent);
        make.top.equalTo(viewTF.mas_bottom).offset(DWScale(20));
        make.size.mas_equalTo(CGSizeMake(DWScale(343), DWScale(48)));
    }];
}

#pragma mark - 监听键盘
- (void)systemKeyboardWillShow:(NSNotification *)notification {
    //显示系统键盘
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardH = keyboardRect.size.height;
    _keyboardH -= DHomeBarH;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.viewContent.y = DScreenHeight - DWScale(238) - DHomeBarH - self.keyboardH;
    }];
    
}
- (void)systemKeyboardWillHide:(NSNotification *)notification {
    //隐藏系统键盘
    _keyboardH = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.viewContent.y = DScreenHeight - DWScale(238) - DHomeBarH;
    }];
}
#pragma mark - 交互事件
- (void)btnEyeClick {
    _btnEye.selected = !_btnEye.selected;
    _tfPassword.secureTextEntry = !_btnEye.selected;
}
- (void)btnSureClick {
    if (![NSString isNil:_tfPassword.text] && _checkAccountPasswordNumber < 5) {
        //确定
        [self requestGetEncryptKey];
    }else {
        //取消
        [_tfPassword resignFirstResponder];
    }
}

#pragma mark - 获取秘钥信息
- (void)requestGetEncryptKey {
    [HUD showActivityMessage:@"" inView:self];
    
    @weakify(self)
    [IMSDKManager authGetEncryptKeySuccess:^(id  _Nullable data, NSString * _Nullable traceId) {
        @strongify(self)
        [HUD hideHUD];
        
        //调用注册接口，传入加密密钥
        if([data isKindOfClass:[NSString class]]){
            NSString *encryptKey = (NSString *)data;
            [self requestCheckUserPassword:encryptKey];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        @strongify(self)
        
        [HUD hideHUD];
        [HUD showMessageWithCode:code errorMsg:msg inView:self];
    }];
}
#pragma mark - 验证用户密码
- (void)requestCheckUserPassword:(NSString *)encryptKey {
    //AES对称加密后的密码
    NSString *passwordKey = [NSString stringWithFormat:@"%@%@", encryptKey, _tfPassword.text];
    NSString *userPwStr = [LXChatEncrypt method4:passwordKey];
    //调用校验密码接口
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObjectSafe:userPwStr forKey:@"password"];
    [params setObjectSafe:encryptKey forKey:@"encryptKey"];
    [params setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    
    [HUD showActivityMessage:@"" inView:self];
    
    @weakify(self)
    [IMSDKManager userCheckUserPasswordWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        @strongify(self)
        [HUD hideHUD];
        
        BOOL checkResult = [data boolValue];
        if (checkResult) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(gestureLockCheckAccountPasswordSuccess)]) {
                [self.delegate gestureLockCheckAccountPasswordSuccess];
            }
        } else {
            
            self.lblTitle.text = LanguageToolMatch(@"验证账户密码失败");
            
            self.checkAccountPasswordNumber++;
            NSString *userKey = [NSString stringWithFormat:@"%@-GesturePassword", UserManager.userInfo.userUID];
            NSDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:self.gesturePassword forKey:@"password"];//手势密码信息
            [dict setValue:@(self.checkNumber) forKey:@"checkNumber"];//验证手势密码次数
            [dict setValue:@(self.checkAccountPasswordNumber) forKey:@"checkAccountPassword"];//验证用户密码次数
            [[MMKV defaultMMKV] setString:[dict mj_JSONString] forKey:userKey];
            
            
            
            if (self.checkAccountPasswordNumber >= 5) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(gestureLockCheckAccountPasswordFail)]) {
                    [self.delegate gestureLockCheckAccountPasswordFail];
                }
            }
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        @strongify(self)
        [HUD hideHUD];
        
        [HUD showMessageWithCode:code errorMsg:msg inView:self];
    }];
}

#pragma mark - 输入框内容实时监听
- (void)textFieldChanged {
    if (![NSString isNil:_tfPassword.text]) {
        _btnEye.hidden = NO;
        [_btnSure setTitle:LanguageToolMatch(@"确定") forState:UIControlStateNormal];
    } else {
        _btnEye.hidden = YES;
        [_btnSure setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
