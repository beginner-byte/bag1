//
//  NoaFileSourceView.m
//  NoaKit
//
//  Created by Candy on 2023/1/4.
//

#import "NoaFileSourceView.h"
#import "NoaToolManager.h"

#define SOURCE_FIRST_BTN_TAG        101
#define SOURCE_SECOND_BTN_TAG       102

@interface NoaFileSourceView()

@property (nonatomic, strong)UIView *backView;

@end

@implementation NoaFileSourceView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI {
    self.frame = CGRectMake(0, DNavStatusBarH, DScreenWidth, DScreenHeight - DNavStatusBarH);
    self.backgroundColor = COLOR_CLEAR;
    [CurrentVC.view addSubview:self];
    
    //背景点击关闭事件
    UIControl *backAction = [[UIControl alloc] initWithFrame:self.bounds];
    [backAction addTarget:self action:@selector(dismissSourceView) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backAction];
    
    self.backView.frame = CGRectMake(0, -DWScale(108), DScreenWidth, DWScale(108));
    [self addSubview:self.backView];
    
    //第一个按钮
    NSString * st = [NSString stringWithFormat:LanguageToolMatch(@"%@中的文件"), [ZTOOL getAppName]];
    UIButton *firstBtn = [[UIButton alloc] init];
    firstBtn.frame = CGRectMake(0, 0, DScreenWidth, DWScale(54));
    [firstBtn setTitle:st forState:UIControlStateNormal];
    [firstBtn setTkThemeTitleColor:@[COLOR_11, COLOR_11_DARK] forState:UIControlStateNormal];
    firstBtn.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    firstBtn.titleLabel.font = FONTN(16);
    firstBtn.tag = SOURCE_FIRST_BTN_TAG;
    [firstBtn addTarget:self action:@selector(btnClickDown:) forControlEvents:UIControlEventTouchDown];
    [firstBtn addTarget:self action:@selector(btnClickUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.backView addSubview:firstBtn];
    
    //第二个按钮
    UIButton *secondBtn = [[UIButton alloc] init];
    secondBtn.frame = CGRectMake(0, DWScale(54), DScreenWidth, DWScale(54));
    [secondBtn setTitle:LanguageToolMatch(@"手机储存") forState:UIControlStateNormal];
    [secondBtn setTkThemeTitleColor:@[COLOR_11, COLOR_11_DARK] forState:UIControlStateNormal];
    secondBtn.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    secondBtn.titleLabel.font = FONTN(16);
    secondBtn.tag = SOURCE_SECOND_BTN_TAG;
    [secondBtn addTarget:self action:@selector(btnClickDown:) forControlEvents:UIControlEventTouchDown];
    [secondBtn addTarget:self action:@selector(btnClickUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.backView addSubview:secondBtn];
    
    //顶部分割线
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, 0.6)];
    topLine.backgroundColor = [COLOR_00 colorWithAlphaComponent:0.25];
    [self.backView addSubview:topLine];
    
    //中间分割线
    UIView *centerLine = [[UIView alloc] initWithFrame:CGRectMake(0, DWScale(54), DScreenWidth, 0.6)];
    centerLine.backgroundColor = [COLOR_00 colorWithAlphaComponent:0.25];
    [self.backView addSubview:centerLine];
    
}

//显示
- (void)showSourceView {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    self.backView.frame = CGRectMake(0, 0, DScreenWidth, 0);
    WeakSelf
    [UIView animateWithDuration:0.15 animations:^{
        weakSelf.backView.frame = CGRectMake(0, 0, DScreenWidth, DWScale(108));
    }];
}

//关闭
- (void)dismissSourceView {
    if (self.dismissClick) {
        self.dismissClick();
    }
    [self removeFromSuperview];
}

#pragma mark - Action
- (void)btnClickDown:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.tkThemebackgroundColors = @[COLOR_EEEEEE, COLOR_66];
}

- (void)btnClickUpInside:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    if (self.selectClick) {
        self.selectClick(btn.tag - 100);
    }
    [self dismissSourceView];
}

#pragma mark - Lazy
- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.frame = CGRectMake(0, -DWScale(108), DScreenWidth, DWScale(108));
        [_backView round:12 RectCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight];
        _backView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    }
    return _backView;
}



@end
