//
//  NoaProxyInputView.m
//  NoaKit
//
//  Created by 小梦雯 on 2025/4/16.
//

#import "NoaProxyInputView.h"
#import "Masonry.h"
#import "AliyCloundDNSDecoder.h"
#import <pdns-sdk-ios/DNSResolver.h>
#import "LXChatEncrypt.h"
@interface NoaProxyInputView()
@property (nonatomic, strong) NoaProxySettings *currentSettings;
@property (nonatomic, strong) UITextField *addressField;
@property (nonatomic, strong) UITextField *portField;
@property (nonatomic, strong) UITextField *userNameField;
@property (nonatomic, strong) UITextField *passWordField;
@property (nonatomic, strong) UIButton *completeBtn;
@end

@implementation NoaProxyInputView {
    UIView *_containerView;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.tkThemebackgroundColors = @[[COLOR_00 colorWithAlphaComponent:0.3],[COLOR_00 colorWithAlphaComponent:0.6]];
        [self setupContainer];
        //注册键盘出现通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        // 注册键盘隐藏通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)setupContainer {
    
    _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, DScreenHeight - DWScale(514), DScreenWidth, DWScale(514))];
    _containerView.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE];
    [self addSubview:_containerView];
    
    [_containerView round:DWScale(20) RectCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
}

- (void)show {
    [CurrentWindow addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(CurrentWindow);
    }];
}

- (void)setCurrentType:(ProxyType)currentType {
    _currentType = currentType;
    NoaProxySettings *setting = [[MMKV defaultMMKV] getObjectOfClass:[NoaProxySettings class] forKey:currentType == ProxyTypeHTTP ? HTTP_PROXY_KEY : SOCKS_PROXY_KEY];
    self.currentSettings = [NoaProxySettings new];
    self.currentSettings = setting;
    [self setupInputFields];
    [self checkTextFieldStatus];
}

- (void)setupInputFields {
    
    // 关闭按钮
    UIButton *closeBtn = [[UIButton alloc] init];
    [closeBtn setTkThemeImage:@[ImgNamed(@"icon_nav_close"), ImgNamed(@"icon_nav_close")] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setEnlargeEdge:DWScale(10)];
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = self.currentType == ProxyTypeHTTP ? LanguageToolMatch(@"使用HTTP代理") : @"SOCKS5";
    titleLabel.font = FONTB(18);
    
    // 完成按钮
    self.completeBtn = [[UIButton alloc] init];
    [self.completeBtn setTitle:LanguageToolMatch(@"完成") forState:UIControlStateNormal];
    [self.completeBtn setTkThemeTitleColor:@[[COLOR_5966F2 colorWithAlphaComponent:0.5], [COLOR_5966F2_DARK colorWithAlphaComponent:0.5]] forState:UIControlStateDisabled];
    [self.completeBtn setTkThemeTitleColor:@[COLOR_5966F2,COLOR_5966F2_DARK] forState:UIControlStateNormal];
    self.completeBtn.titleLabel.font = FONTB(16);
    [self.completeBtn addTarget:self action:@selector(completeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.completeBtn setEnlargeEdge:DWScale(10)];
    self.completeBtn.enabled = NO;
    
    // 地址输入
    UILabel *addressLabel = [self createHighlightedLabelWithText:LanguageToolMatch(@"*地址") keyword:@"*"];
    _addressField = [self createTextFieldWithPlaceholder:LanguageToolMatch(@"请输入") text:_currentSettings.address];
    
    // 端口输入
    UILabel *portLabel = [self createHighlightedLabelWithText:LanguageToolMatch(@"*端口") keyword:@"*"];
    _portField = [self createTextFieldWithPlaceholder:LanguageToolMatch(@"请输入") text:_currentSettings.port];
    _portField.keyboardType = UIKeyboardTypeNumberPad;
    
    
    // 用户名输入
    UILabel *usernameLabel = [self createHighlightedLabelWithText:LanguageToolMatch(@"用户名") keyword:@"*"];
    _userNameField = [self createTextFieldWithPlaceholder:LanguageToolMatch(@"选填") text:_currentSettings.username];
    
    // 检测链接
    UIButton *checkBtn = [[UIButton alloc] init];
    [checkBtn setTitle:LanguageToolMatch(@"测试连接") forState:UIControlStateNormal];
    [checkBtn setTkThemeTitleColor:@[COLOR_5966F2,COLOR_5966F2_DARK] forState:UIControlStateNormal];
    checkBtn.titleLabel.font = FONTR(16);
    [checkBtn addTarget:self action:@selector(checkBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    // 密码输入
    UILabel *passwordLabel = [self createHighlightedLabelWithText:LanguageToolMatch(@"密码") keyword:@"*"];
    _passWordField = [self createTextFieldWithPlaceholder:LanguageToolMatch(@"选填") text:_currentSettings.password];
    
    
    // 添加到容器
    NSArray *views = @[closeBtn, titleLabel, _completeBtn, addressLabel, _addressField, portLabel, _portField, usernameLabel, _userNameField, passwordLabel, _passWordField, checkBtn];
    for (UIView *v in views) {
        [_containerView addSubview:v];
    }
    
    // Masonry 布局
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_containerView).offset(DWScale(18));
        make.leading.equalTo(_containerView).offset(DWScale(16));
        make.width.height.mas_offset(DWScale(20));
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_containerView);
        make.centerY.equalTo(closeBtn);
        make.height.mas_offset(DWScale(23));
    }];
    
    [_completeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(closeBtn);
        make.trailing.equalTo(_containerView).offset(-DWScale(16));
    }];
    
    [addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(closeBtn.mas_bottom).offset(DWScale(30));
        make.leading.equalTo(closeBtn);
        make.height.mas_offset(DWScale(16));
    }];
    
    [_addressField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(addressLabel.mas_bottom).offset(DWScale(12));
        make.leading.equalTo(addressLabel);
        make.trailing.equalTo(_completeBtn);
        make.height.mas_equalTo(DWScale(44));
    }];
    
    [portLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_addressField.mas_bottom).offset(DWScale(24));
        make.leading.height.equalTo(addressLabel);
    }];
    
    [_portField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(portLabel.mas_bottom).offset(DWScale(12));
        make.leading.trailing.height.equalTo(_addressField);
    }];
    
    [usernameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_portField.mas_bottom).offset(DWScale(24));
        make.leading.height.equalTo(addressLabel);
    }];
    
    [_userNameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(usernameLabel.mas_bottom).offset(DWScale(12));
        make.leading.trailing.height.equalTo(_addressField);
    }];
    
    [passwordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_userNameField.mas_bottom).offset(DWScale(24));
        make.leading.height.equalTo(addressLabel);
    }];
    
    [_passWordField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(passwordLabel.mas_bottom).offset(DWScale(12));
        make.leading.trailing.height.equalTo(_addressField);
    }];
    
    [checkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_passWordField.mas_bottom).offset(DWScale(12));
        make.leading.equalTo(addressLabel);
        make.height.mas_equalTo(DWScale(16));
    }];
}

- (void)closeBtnClick {
    [self removeFromSuperview];
    if (self.cancleCallback) {
        self.cancleCallback();
    }
}

- (void)completeBtnClick {
    [self removeFromSuperview];
    
    NoaProxySettings *setting = [NoaProxySettings new];
    setting.address = self.addressField.text;
    setting.port =  self.portField.text;
    setting.username = self.userNameField.text;
    setting.password = self.passWordField.text;
    
    [[MMKV defaultMMKV] setObject:setting forKey:self.currentType == ProxyTypeHTTP ? HTTP_PROXY_KEY : SOCKS_PROXY_KEY];
}

- (void)checkBtnClick {
    if (self.addressField.text.length > 0 && self.portField.text.length > 0) {
        self.currentSettings = [NoaProxySettings new];
        self.currentSettings.address = self.addressField.text;
        self.currentSettings.port =  self.portField.text;
        self.currentSettings.username = self.userNameField.text;
        self.currentSettings.password = self.passWordField.text;
        [self checkProxy];
    } else {
        [HUD showMessage:LanguageToolMatch(@"访问失败,请检查网络设置")];
    }
    
}

- (void)checkProxy {
    [HUD showActivityMessage:@""];
    [self filtrateNetWorkWithUrl:@"http://www.baidu.com" compelete:^(NSInteger code, NSString *msg, NSData *data, NSString *traceId) {
        if (code == 200) {
            [HUD showMessage:LanguageToolMatch(@"校验通过")];
        } else {
            [HUD showMessage:LanguageToolMatch(@"访问失败,请检查网络设置")];
        }
    }];
}

#pragma mark - Keyboard Notification
-(void)keyboardWillShow:(NSNotification *) notification{
    //获取键盘的高度
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    float keyboardHeight = keyboardRect.size.height;
    //更新约束
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(CurrentWindow).offset(-(keyboardHeight - DWScale(24)));
        make.bottom.equalTo(CurrentWindow).offset(-(keyboardHeight - DWScale(24)));
        make.leading.trailing.equalTo(CurrentWindow);
    }];
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [UIView animateWithDuration:0.15 animations:^{
        [self layoutIfNeeded];
    }];
}

-(void)keyboardWillHide: (NSNotification *) notification{
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(CurrentWindow);
    }];
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [UIView animateWithDuration:0.15 animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)filtrateNetWorkWithUrl:(NSString *)urlStr compelete:(void(^)(NSInteger code, NSString *msg, NSData *data, NSString *traceId))compelete {
    ProxyType currentType = self.currentType;
    
    NSString *traceId = [[NoaIMManagerTool sharedManager] getMessageID];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    config.URLCache = nil;
    if (currentType == ProxyTypeHTTP) {
        NoaProxySettings *setting = self.currentSettings;
        config.connectionProxyDictionary = @{
            // 开启 HTTP 代理
            (__bridge id)kCFNetworkProxiesHTTPEnable: @YES,
            // 代理服务器地址和端口
            (__bridge id)kCFNetworkProxiesHTTPProxy: setting.address,
            (__bridge id)kCFNetworkProxiesHTTPPort: @([setting.port intValue]),
            
            // 代理认证（可选）
            (__bridge id)kCFProxyUsernameKey: setting.username,
            (__bridge id)kCFProxyPasswordKey: setting.password
        };
    } else if (currentType == ProxyTypeSOCKS5) {
        NoaProxySettings *setting = self.currentSettings;
        config.connectionProxyDictionary = @{
            (__bridge NSString *)kCFStreamPropertySOCKSProxyHost: setting.address,
            (__bridge NSString *)kCFStreamPropertySOCKSProxyPort: @([setting.port intValue]),
            (__bridge NSString *)kCFStreamPropertySOCKSUser: setting.username,        // 如果需要
            (__bridge NSString *)kCFStreamPropertySOCKSPassword: setting.password      // 如果需要
        };
    }
    
    
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        if (error == nil && (long)httpResponse.statusCode == 200) {
            compelete(httpResponse.statusCode, @"-", data, traceId);
        } else {
            if (error == nil) {
                compelete(httpResponse.statusCode, @"", nil, traceId);
            } else {
                NSString *errorDescription = [NSString isNil:[error localizedDescription]] ? @"-" : [error localizedDescription];
                compelete(error.code, errorDescription, nil, traceId);
            }
            
        }
    }];
    [dataTask resume];
    
    
}

- (void)textFieldDidChange {
    [self checkTextFieldStatus];
}

- (void)checkTextFieldStatus {
    if (self.addressField.text.length > 0 && self.portField.text.length > 0) {
        self.completeBtn.enabled = YES;
    } else {
        self.completeBtn.enabled = NO;
    }
}

#pragma mark - 组件工厂方法
// 创建 UILabel 并设置富文本
- (UILabel *)createHighlightedLabelWithText:(NSString *)text keyword:(NSString *)keyword {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:COLOR_11
                             range:NSMakeRange(0, text.length)];
    
    NSRange searchRange = NSMakeRange(0, text.length);
    while (YES) {
        NSRange foundRange = [text rangeOfString:keyword
                                         options:0
                                           range:searchRange];
        if (foundRange.location == NSNotFound) break;
        
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:COLOR_F81205
                                 range:foundRange];
        
        searchRange.location = foundRange.location + foundRange.length;
        searchRange.length = text.length - searchRange.location;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.attributedText = attributedString;
    label.numberOfLines = 0;
    return label;
}

- (UITextField *)createTextFieldWithPlaceholder:(NSString *)placeholder text:(NSString *)text {
    UITextField *tf = [UITextField new];
    tf.font = FONTR(14);
    tf.placeholder = placeholder;
    tf.text = text;
    [tf rounded:DWScale(8) width:DWScale(1) color:COLOR_E6E6E6];
    // 设置左右内边距为12
    UIView *leftPadding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 40)];
    tf.leftView = leftPadding;
    tf.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *rightPadding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 40)];
    tf.rightView = rightPadding;
    tf.rightViewMode = UITextFieldViewModeAlways;
    [tf addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    return tf;
}

@end
