//
//  NoaImgVerCodeInputView.m
//  NoaKit
//
//  Created by Candy on 2026/9/5.
//

#import "NoaImgVerCodeInputView.h"
#import "NoaGraphCodeView.h"//图形验证码

@interface NoaImgVerCodeInputView()

@property (nonatomic, strong)NoaGraphCodeView *imgCodeView;

@end

@implementation NoaImgVerCodeInputView

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
    self.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    
    //验证码图片
    [self addSubview:self.imgCodeView];
    [self.imgCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.equalTo(self);
        make.width.mas_equalTo(DWScale(125));
        make.height.mas_equalTo(DWScale(48));
    }];
    
    [self addSubview:self.imgCodeInput];
    [self.imgCodeInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.equalTo(self);
        make.trailing.equalTo(self.imgCodeView.mas_leading).offset(DWScale(-4));
        make.centerY.equalTo(self.imgCodeView);
        make.height.mas_equalTo(DWScale(48));
    }];
    
    UIButton *relaodBtn = [[UIButton alloc] init];
    [relaodBtn setTitle:LanguageToolMatch(@"换一张") forState:UIControlStateNormal];
    [relaodBtn setTkThemeTitleColor:@[COLOR_99, COLOR_99] forState:UIControlStateNormal];
    relaodBtn.titleLabel.font = FONTN(13);
    [relaodBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [relaodBtn addTarget:self action:@selector(getImgCodeAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:relaodBtn];
    [relaodBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imgCodeView.mas_bottom).offset(DWScale(4));
        make.leading.trailing.equalTo(self);
        make.height.mas_equalTo(DWScale(18));
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

#pragma mark - Action
- (void)getImgCodeAction {
    //重新获取图形验证码
    //重新获取图形验证码
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.loginName forKey:@"loginName"];
    [params setValue:@(self.verCodeType) forKey:@"type"];
                                
    WeakSelf
    [IMSDKManager authGetImgVerCodeWith:params 
                              onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        NSString *codeStr = (NSString *)data;
        weakSelf.imgCodeStr = codeStr;
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessage:LanguageToolMatch(@"图形验证码获取失败")];
    }];
}

#pragma mark - Lazy
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
        _imgCodeInput.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _imgCodeInput.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
        _imgCodeInput.font = FONTN(13);
        _imgCodeInput.placeholder = LanguageToolMatch(@"验证码");
        UIView * leftView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 10)];
        _imgCodeInput.leftView = leftView;
        _imgCodeInput.leftViewMode = UITextFieldViewModeAlways;
        [_imgCodeInput rounded:14 width:1 color:COLOR_A3C8FF];
    }
    return _imgCodeInput;
}

@end
