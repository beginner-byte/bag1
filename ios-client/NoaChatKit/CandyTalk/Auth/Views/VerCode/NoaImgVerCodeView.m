//
//  NoaImgVerCodeView.m
//  NoaKit
//
//  Created by Candy on 2026/9/5.
//

#import "NoaImgVerCodeView.h"
#import "NoaGraphCodeView.h"//图形验证码

@interface NoaImgVerCodeView()

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong)NoaGraphCodeView *imgCodeView;

@property (nonatomic, strong)UITextField *imgCodeInput;

@end

@implementation NoaImgVerCodeView

//初始化
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

//兼容nib使用
- (void)awakeFromNib{
    [super awakeFromNib];
    [self setupUI];
}


- (void)setupUI{
    self.frame = CGRectMake(0, 0, DScreenWidth, DScreenHeight);
    self.tkThemebackgroundColors = @[[COLOR_00 colorWithAlphaComponent:0.2], [COLOR_00 colorWithAlphaComponent:0.6]];
    
    [self addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.equalTo(self).offset(30);
        make.trailing.equalTo(self).offset(-30);
        make.height.mas_equalTo(DWScale(195));
    }];
    
    //验证码图片
    [self.bgView addSubview:self.imgCodeView];
    [self.imgCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView).offset(DWScale(70));
        make.trailing.equalTo(self.bgView).offset(DWScale(-20));
        make.width.mas_equalTo(DWScale(90));
        make.height.mas_equalTo(DWScale(40));
    }];
    
    [self.bgView addSubview:self.imgCodeInput];
    [self.imgCodeInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.bgView).offset(DWScale(20));
        make.trailing.equalTo(self.imgCodeView.mas_leading).offset(DWScale(-10));
        make.centerY.equalTo(self.imgCodeView);
        make.height.mas_equalTo(DWScale(40));
    }];
    
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.text = LanguageToolMatch(@"验证码");
    titleLab.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    titleLab.font = FONTN(18);
    titleLab.textAlignment = NSTextAlignmentCenter;
    [self.bgView addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView).offset(DWScale(32));
        make.centerX.equalTo(self.bgView).offset(-10);
        make.width.mas_equalTo(DWScale(200));
        make.height.mas_equalTo(DWScale(21));
    }];
    
    UIButton *relaodBtn = [[UIButton alloc] init];
    [relaodBtn setTitle:LanguageToolMatch(@"换一张") forState:UIControlStateNormal];
    [relaodBtn setTkThemeTitleColor:@[COLOR_99, COLOR_99] forState:UIControlStateNormal];
    [relaodBtn addTarget:self action:@selector(getImgCodeAction) forControlEvents:UIControlEventTouchUpInside];
    relaodBtn.titleLabel.font = FONTN(13);
    [self.bgView addSubview:relaodBtn];
    [relaodBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imgCodeView.mas_bottom).offset(DWScale(6));
        make.centerX.equalTo(self.imgCodeView);
        make.height.mas_equalTo(DWScale(91));
        make.height.mas_equalTo(DWScale(18));
    }];
    
    //横线
    UIView *transverseLine = [[UIView alloc] init];
    transverseLine.tkThemebackgroundColors = @[[COLOR_3C3C43 colorWithAlphaComponent:0.3], [COLOR_3C3C43_DARK colorWithAlphaComponent:0.3]];
    [self.bgView addSubview:transverseLine];
    [transverseLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bgView).offset(DWScale(-43.5));
        make.leading.trailing.equalTo(self.bgView);
        make.height.mas_equalTo(0.5);
    }];
        
    //取消
    UIButton *cancelBtn = [[UIButton alloc] init];
    [cancelBtn setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    cancelBtn.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    [cancelBtn setTkThemeTitleColor:@[COLOR_858687, COLOR_858687_DARK] forState:UIControlStateNormal];
    [cancelBtn setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateSelected];
    [cancelBtn setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateHighlighted];
    cancelBtn.titleLabel.font = FONTN(17);
    [cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(transverseLine.mas_bottom);
        make.leading.equalTo(self.bgView);
        make.width.mas_equalTo((DScreenWidth-60)/2);
        make.bottom.equalTo(self.bgView);
    }];
    
    //确定
    UIButton *sureBtn = [[UIButton alloc] init];
    [sureBtn setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
    [sureBtn setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateNormal];
    [sureBtn setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateSelected];
    [sureBtn setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateHighlighted];
    sureBtn.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    sureBtn.titleLabel.font = FONTN(17);
    [sureBtn addTarget:self action:@selector(sureBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:sureBtn];
    [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(cancelBtn);
        make.width.mas_equalTo((DScreenWidth-60)/2);
        make.trailing.equalTo(self.bgView);
    }];
    
    //竖线
    UIView *verticalLine = [[UIView alloc] init];
    verticalLine.tkThemebackgroundColors = @[[COLOR_3C3C43 colorWithAlphaComponent:0.3], [COLOR_3C3C43_DARK colorWithAlphaComponent:0.3]];
    [self.bgView addSubview:verticalLine];
    [verticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(transverseLine.mas_bottom);
        make.bottom.equalTo(self.bgView);
        make.centerX.equalTo(self.bgView);
        make.width.mas_equalTo(0.5);
    }];
}

#pragma mark - Setter

- (void)setImgCodeStr:(NSString *)imgCodeStr {
    _imgCodeStr = imgCodeStr;
    if (![NSString isNil:_imgCodeStr]) {
        [self.imgCodeView setCodeStr:_imgCodeStr];
        [self.imgCodeView setNeedsDisplay];
    } else {
        [self getImgCodeAction];
    }
}


#pragma mark - show / dismiss
- (void)show {
    [CurrentWindow addSubview:self];
}

- (void)dismiss {
    [self removeFromSuperview];
}

#pragma mark - Action
- (void)getImgCodeAction {
    //重新获取图形验证码
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.loginName forKey:@"loginName"];
    [params setValue:@(self.verCodeType) forKey:@"type"];
                                
    WeakSelf
    [IMSDKManager authGetImgVerCodeWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if([data isKindOfClass:[NSString class]]){
            NSString *codeStr = (NSString *)data;
            weakSelf.imgCodeStr = codeStr;
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [weakSelf dismiss];
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

- (void)cancelBtnAction {
    [self dismiss];
    if (self.cancelBtnBlock) {
        self.cancelBtnBlock();
    }
}

- (void)sureBtnAction {
    if (![NSString isNil:self.imgCodeInput.text]) {
        if ([self.imgCodeStr isEqualToString:[self.imgCodeInput.text lowercaseString]]) {
            [self dismiss];
            if (self.sureBtnBlock) {
                self.sureBtnBlock(self.imgCodeStr);
            }
        } else {
            [self getImgCodeAction];
            [HUD showMessage:LanguageToolMatch(@"验证码不正确，请重新输入")];
        }
        self.imgCodeInput.text = @"";
    } else {
        [HUD showMessage:LanguageToolMatch(@"请输入验证码")];
    }
}

#pragma mark - Lazy
- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        [_bgView rounded:14];
    }
    return _bgView;
}

- (NoaGraphCodeView *)imgCodeView {
    if (!_imgCodeView) {
        _imgCodeView = [[NoaGraphCodeView alloc] init];
        _imgCodeView.userInteractionEnabled = YES;
        [_imgCodeView rounded:12 width:1 color:COLOR_F5F6F9];
        
        UITapGestureRecognizer *getCodeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getImgCodeAction)];
        [_imgCodeView addGestureRecognizer:getCodeTap];
    }
    return _imgCodeView;
}

- (UITextField *)imgCodeInput {
    if (!_imgCodeInput) {
        _imgCodeInput = [[UITextField alloc] init];
        _imgCodeInput.tkThemetextColors = @[COLOR_11, COLORWHITE];
        _imgCodeInput.font = FONTN(13);
        _imgCodeInput.placeholder = LanguageToolMatch(@"请输入验证码");
        UIView * leftView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _imgCodeInput.leftView = leftView;
        _imgCodeInput.leftViewMode = UITextFieldViewModeAlways;
        [_imgCodeInput rounded:4 width:1 color:COLOR_C6C6C8];
    }
    return _imgCodeInput;
}

@end
