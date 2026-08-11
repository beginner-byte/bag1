//
//  NoaGetImgVerCodeBlurView.m
//  NoaChatKit
//
//  Created by phl on 2025/11/14.
//

#import "NoaGetImgVerCodeBlurView.h"
#import "NoaGetImgVerCodeBlurDataHandle.h"
#import "NoaFixedSizeRightView.h"

@interface NoaGetImgVerCodeBlurView ()<UITextFieldDelegate>

/// 数据处理
@property (nonatomic, strong, readwrite) NoaGetImgVerCodeBlurDataHandle *dataHandle;

@property (nonatomic, strong) UILabel *topTitleLabel;

/// 验证码背景View
@property (nonatomic, strong) UIView *codeBgView;

/// 图文验证码输入框
@property (nonatomic, strong) UITextField *codeTF;

/// codeTF的rightview
@property (nonatomic, strong) UIView *codeTFRightContainerView;

/// 图文验证码
@property (nonatomic, strong) UIImageView *codeImgView;

/// 切换下一章验证码按钮
@property (nonatomic, strong) UIButton *refreshCodeBtn;

/// 清理文本按钮
@property (nonatomic, strong) UIButton *codeTFClearBtn;

/// 取消按钮
@property (nonatomic, strong) UIButton *cancelBtn;

/// 确认按钮
@property (nonatomic, strong) UIButton *doneBtn;


@end

@implementation NoaGetImgVerCodeBlurView

#pragma mark - Lazy Loading

- (UILabel *)topTitleLabel {
    if (!_topTitleLabel) {
        _topTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _topTitleLabel.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _topTitleLabel.font = FONTSB(20);
        _topTitleLabel.text = LanguageToolMatch(@"验证码验证");
    }
    return _topTitleLabel;
}

- (UIView *)codeBgView {
    if (!_codeBgView) {
        _codeBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _codeBgView.tkThemebackgroundColors = @[UIColor.clearColor, UIColor.clearColor];
    }
    return _codeBgView;
}

- (UITextField *)codeTF {
    if (!_codeTF) {
        _codeTF = [[UITextField alloc] initWithFrame:CGRectZero];
        _codeTF.tkThemebackgroundColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.05], [COLOR_5966F2_DARK colorWithAlphaComponent:0.05]];
        _codeTF.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        // 设置圆角
        _codeTF.layer.cornerRadius = 16;
        _codeTF.layer.masksToBounds = YES;
        // 设置边框
        _codeTF.layer.borderWidth = 1.0;
        _codeTF.layer.tkThemeborderColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.05], [COLORWHITE colorWithAlphaComponent:0.4]];
        // 设置左边文字距离左边框间隔
        _codeTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
        _codeTF.leftViewMode = UITextFieldViewModeAlways;
        _codeTF.keyboardType = UIKeyboardTypeDefault;
        _codeTF.delegate = self;
        // 创建属性字符串
        NSDictionary *attributes = @{
            NSForegroundColorAttributeName: COLOR_99,
            NSFontAttributeName:FONTM(14)
        };
        _codeTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LanguageToolMatch(@"验证码") attributes:attributes];
    }
    return _codeTF;
}

- (UIView *)codeTFRightContainerView {
    if (!_codeTFRightContainerView) {
        _codeTFRightContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        _codeTFRightContainerView.tkThemebackgroundColors = @[UIColor.clearColor, UIColor.clearColor];
    }
    return _codeTFRightContainerView;
}

- (UIImageView *)codeImgView {
    if (!_codeImgView) {
        _codeImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _codeImgView.layer.cornerRadius = 16;
        _codeImgView.layer.masksToBounds = YES;
    }
    return _codeImgView;
}

- (UIButton *)refreshCodeBtn {
    if (!_refreshCodeBtn) {
        _refreshCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_refreshCodeBtn setImage:ImgNamed(@"icon_refresh") forState:UIControlStateNormal];
    }
    return _refreshCodeBtn;
}

- (UIButton *)codeTFClearBtn {
    if (!_codeTFClearBtn) {
        _codeTFClearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_codeTFClearBtn setImage:ImgNamed(@"icon_text_clear") forState:UIControlStateNormal];
        _codeTFClearBtn.hidden = YES;
    }
    return _codeTFClearBtn;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
        [_cancelBtn setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = FONTM(14);
        _cancelBtn.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE];
        _cancelBtn.layer.cornerRadius = 16;
        _cancelBtn.layer.masksToBounds = YES;
        // 设置边框
        _cancelBtn.layer.borderWidth = 1.0;
        _cancelBtn.layer.tkThemeborderColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    }
    return _cancelBtn;
}

- (UIButton *)doneBtn {
    if (!_doneBtn) {
        _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_doneBtn setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
        [_doneBtn setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
        _doneBtn.titleLabel.font = FONTM(14);
        _doneBtn.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
        _doneBtn.layer.cornerRadius = 16;
        _doneBtn.layer.masksToBounds = YES;
    }
    return _doneBtn;
}

- (instancetype)initWithFrame:(CGRect)frame
                 IsPopWindows:(BOOL)isPopWindows
                   DataHandle:(NoaGetImgVerCodeBlurDataHandle *)dataHandle {
    if (self = [super initWithFrame:frame IsPopWindows:isPopWindows]) {
        self.dataHandle = dataHandle;
        [self setUpImgVerCodeBlurView];
        [self processData];
    }
    return self;
}

- (void)setUpImgVerCodeBlurView {
    // 标题
    [self addSubview:self.topTitleLabel];
    
    [self.topTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@20);
        make.leading.equalTo(@17.5);
        make.trailing.equalTo(self).offset(-17.5);
        make.height.equalTo(@32);
    }];
    // 验证码输入
    [self addSubview:self.codeBgView];
    [self.codeBgView addSubview:self.codeTF];
    [self setupRightViewForCodeTextField];
    [self.codeBgView addSubview:self.refreshCodeBtn];
    [self setupCodeViewConstraints];
    
    // 取消按钮
    [self addSubview:self.cancelBtn];
    // 确认按钮
    [self addSubview:self.doneBtn];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.codeBgView.mas_bottom).offset(48);
        make.leading.equalTo(@17.5);
        make.width.equalTo(self.doneBtn);
        make.height.equalTo(@54);
    }];
    
    [self.doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.codeBgView.mas_bottom).offset(48);
        make.leading.equalTo(self.cancelBtn.mas_trailing).offset(12);
        make.trailing.equalTo(self).offset(-17.5);
        make.width.equalTo(self.cancelBtn);
        make.height.equalTo(@54);
    }];
}

/// 设置验证码输入rightView（包含图文验证码图片）
- (void)setupRightViewForCodeTextField {
    // 创建固定宽高的容器 view
    NoaFixedSizeRightView *containerView = [[NoaFixedSizeRightView alloc] initWithFixedSize:CGSizeMake(79, 62)];
    
    // 图文验证码
    [containerView addSubview:self.codeImgView];
    // 清理按钮
    [containerView addSubview:self.codeTFClearBtn];
    
    [self.codeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(containerView).offset(-4);
        make.centerY.equalTo(containerView);
        make.width.equalTo(@112);
        make.height.equalTo(@51);
    }];
    
    [self.codeTFClearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.codeImgView.mas_leading).offset(-4);
        make.centerY.equalTo(containerView);
        make.width.height.equalTo(@20);
    }];
    
    // 设置 rightView
    self.codeTF.rightView = containerView;
    self.codeTF.rightViewMode = UITextFieldViewModeAlways; // 容器始终显示，内部按钮根据状态控制
}

/// 设置验证码视图约束（子类可重写以自定义）
- (void)setupCodeViewConstraints {
    [self.codeBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topTitleLabel.mas_bottom).offset(16);
        make.leading.equalTo(@17.5);
        make.trailing.equalTo(self).offset(-17.5);
        make.height.equalTo(@62);
    }];
    
    [self.codeTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.leading.equalTo(@0);
        make.trailing.equalTo(self.refreshCodeBtn.mas_leading).offset(-12);
        make.height.equalTo(self.codeBgView);
    }];
    
    [self.refreshCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.centerY.equalTo(self.codeBgView);
        make.trailing.equalTo(self.codeBgView).offset(-3);
        make.width.height.equalTo(@20);
    }];
}

/// 处理数据（子类需要调用 super）
- (void)processData {
    @weakify(self)
    [[self.codeTFClearBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        self.codeTF.text = @"";
    }];
    
    [[self.refreshCodeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        // 清空上一次输入的验证码
        self.codeTF.text = @"";
        // 发起请求
        [self requestImgCode];
    }];
    
    [[self.cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        [self.dataHandle.dismissSubject sendNext:@1];
    }];
    
    [[self.doneBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        NSString *inputCode = [self.codeTF.text lowercaseString];
        NSString *requestCode = [self.dataHandle.imgVerCode lowercaseString];
        if ([NSString isNil:inputCode]) {
            [self.dataHandle.showToastSubject sendNext:LanguageToolMatch(@"请输入验证码")];
            return;
        }
        
        if (![inputCode isEqualToString:requestCode]) {
            [self.dataHandle.showToastSubject sendNext:LanguageToolMatch(@"验证码不正确，请重新输入")];
            [self requestImgCode];
            return;
        }
        
        [self.dataHandle.configureFinishSubject sendNext:[NSString isNil:inputCode] ? @"" : inputCode];
    }];
    
    // 点击获取验证码的时候，获取图文验证码给弹窗用
    [self.dataHandle.getImgVerCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [HUD hideHUD];
        
        if (![x isKindOfClass:[NSDictionary class]]) {
            return;
        }
        
        NSDictionary *resDic = x;
        BOOL isSuccess = [[resDic objectForKey:@"res"] boolValue];
        if (!isSuccess) {
            NSDictionary *errorDic = [resDic objectForKey:@"error"];
            if (!errorDic) {
                [self.dataHandle.showToastSubject sendNext: LanguageToolMatch(@"图形验证码获取失败")];
                return;
            }
            
            NSInteger code = [[errorDic objectForKey:@"code"] integerValue];
            NSString *msg = [errorDic objectForKey:@"msg"];
            [self.dataHandle.showToastSubject sendNext:LanguageToolCodeMatch(code, msg)];
            return;
        }
        
        // 成功
        NSString *codeStr = [resDic objectForKey:@"code"];
        if (codeStr.length == 0) {
            return;
        }
    
        self.dataHandle.imgVerCode = codeStr;
        [self showImageCode];
    }];
    
    // 更新清除按钮显示状态的辅助方法
    void (^updateClearButtonVisibility)(void) = ^{
        @strongify(self)
        BOOL shouldShow = self.codeTF.isEditing && self.codeTF.text.length > 0;
        self.codeTFClearBtn.hidden = !shouldShow;
    };
    
    // 监听开始编辑
    [[self.codeTF rac_signalForControlEvents:UIControlEventEditingDidBegin] subscribeNext:^(__kindof UIControl * _Nullable x) {
        updateClearButtonVisibility();
    }];
    
    // 监听结束编辑
    [[self.codeTF rac_signalForControlEvents:UIControlEventEditingDidEnd] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        updateClearButtonVisibility();
    }];
    
    // 监听文本变化
    [self.codeTF.rac_textSignal subscribeNext:^(NSString * _Nullable text) {
        updateClearButtonVisibility();
    }];
    
    if ([NSString isNil:self.dataHandle.imgVerCode]) {
        // 外部传入的验证码为空，主动发起一次获取
        [self requestImgCode];
    }else {
        [self showImageCode];
    }
}

- (void)showImageCode {
    CGSize imageCodeSize = self.codeImgView.size;
    if (imageCodeSize.width == 0 ||
        imageCodeSize.height == 0) {
        // 有一个为零，使用兜底(与布局宽高一致)
        imageCodeSize = CGSizeMake(112, 51);
    }
    UIImage *codeImage = [self createCaptchaImageWithText:self.dataHandle.imgVerCode size:imageCodeSize];
    [self.codeImgView setImage:codeImage];
}

- (void)requestImgCode {
    [HUD showActivityMessage:@"" inView:self];
    [self.dataHandle.getImgVerCommand execute:nil];
}

#pragma mark - 绘制二维码背景图+文字
//根据服务器返回的或者自己设置的codeStr绘制图形验证码
- (UIImage *)createCaptchaImageWithText:(NSString *)text size:(CGSize)size {
    // 开始图形上下文
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    // 设置背景颜色
    [[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1] setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    
    // 设置字体和颜色
    NSArray *colors = @[
        [UIColor redColor],
        [UIColor greenColor],
        [UIColor blueColor],
        [UIColor orangeColor],
        [UIColor grayColor],
        [UIColor cyanColor],
        [UIColor purpleColor],
        [UIColor darkGrayColor],
        [UIColor magentaColor],
        [UIColor systemPinkColor],
        [UIColor systemBlueColor],
        [UIColor systemBrownColor]
    ];
    
    for (int i = 0; i < text.length; i++) {
        // 随机颜色
        UIColor *color = colors[i % colors.count];
        NSDictionary *attributes = @{
            NSFontAttributeName: [UIFont boldSystemFontOfSize:26],
            NSForegroundColorAttributeName: color
        };
        
        // 计算字符的绘制区域
        NSString *character = [text safeSubstringWithRange:NSMakeRange(i, 1)];
        CGSize charSize = [character sizeWithAttributes:attributes];
        CGRect charRect = CGRectMake(10 + i * (size.width / text.length), (size.height - charSize.height) / 2, charSize.width, charSize.height);
        
        // 绘制字符
        [character drawInRect:charRect withAttributes:attributes];
    }
    
    // 添加干扰线
//    for (int i = 0; i < 1; i++) {
//        [self drawRandomLineInRect:CGRectMake(0, 0, size.width, size.height)];
//    }
    
    // 获取生成的图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 结束图形上下文
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)drawRandomLineInRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    CGContextSetLineWidth(context, 1.0);
   
    CGFloat startX = arc4random() % (int)rect.size.width;
    CGFloat startY = arc4random() % (int)rect.size.height;
    CGFloat length = rect.size.width;//arc4random() % 10 + 5; // 线段长度为5到15的随机值
    CGFloat endX = startX + (arc4random() % 2 ? length : -length);
    CGFloat endY = startY + (arc4random() % 2 ? length : -length);
   
    CGContextMoveToPoint(context, startX, startY);
    CGContextAddLineToPoint(context, endX, endY);
    CGContextStrokePath(context);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
