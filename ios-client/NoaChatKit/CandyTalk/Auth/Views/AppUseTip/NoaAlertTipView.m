//
//  NoaAlertTipView.m
//  NoaKit
//
//  Created by Candy on 2026/9/19.
//

#import "NoaAlertTipView.h"
#import "NoaToolManager.h"

@interface NoaAlertTipView()

@property (nonatomic, strong) UIView *viewBg;

@end


@implementation NoaAlertTipView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    self.frame = CGRectMake(0, 0, DScreenWidth, DScreenHeight);
    self.tkThemebackgroundColors = @[[COLOR_00 colorWithAlphaComponent:0.3],[COLOR_00 colorWithAlphaComponent:0.6]];
    [CurrentWindow addSubview:self];
    
    _viewBg = [UIView new];
    _viewBg.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    _viewBg.layer.cornerRadius = DWScale(14);
    _viewBg.layer.masksToBounds = YES;
    _viewBg.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN, CGFLOAT_MIN);
    [self addSubview:_viewBg];
    
    //标题
    _lblTitle = [UILabel new];
    _lblTitle.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _lblTitle.font = FONTR(18);
    _lblTitle.numberOfLines = 1;
    _lblTitle.preferredMaxLayoutWidth = DWScale(234);
    _lblTitle.textAlignment = NSTextAlignmentCenter;
    [_viewBg addSubview:_lblTitle];
    [_lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_viewBg);
        make.top.equalTo(_viewBg).offset(DWScale(32));
        make.height.mas_equalTo(DWScale(21));
    }];
    
    //内容
    _lblContent = [YYLabel new];
    WeakSelf
    self.viewBg.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        UIColor *color = nil;
        if (themeIndex == 0) {
            color = COLOR_22;
        } else {
            color = COLOR_22_DARK;
        }
        weakSelf.lblContent.textColor = color;
    };
    _lblContent.font = FONTR(16);
    _lblContent.numberOfLines = 3;
    _lblContent.userInteractionEnabled = YES;
    _lblContent.backgroundColor = COLOR_CLEAR;
    _lblContent.preferredMaxLayoutWidth = DWScale(234);
    _lblContent.textAlignment = [ZTOOL RTLTextAlignment:NSTextAlignmentCenter];
    [_lblContent sizeToFit];
    [_viewBg addSubview:_lblContent];
    [_lblContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_viewBg);
        make.top.equalTo(_lblTitle.mas_bottom).offset(DWScale(20));
    }];
    
    //横线
    UIView *transverseLine = [[UIView alloc] init];
    transverseLine.tkThemebackgroundColors = @[[COLOR_3C3C43 colorWithAlphaComponent:0.3], [COLOR_3C3C43_DARK colorWithAlphaComponent:0.3]];
    [_viewBg addSubview:transverseLine];
    [transverseLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lblContent.mas_bottom).offset(DWScale(35));
        make.leading.trailing.equalTo(_viewBg);
        make.height.mas_equalTo(0.5);
    }];
    
    //竖线
    UIView *verticalLine = [[UIView alloc] init];
    verticalLine.tkThemebackgroundColors = @[[COLOR_3C3C43 colorWithAlphaComponent:0.3], [COLOR_3C3C43_DARK colorWithAlphaComponent:0.3]];
    [_viewBg addSubview:verticalLine];
    [verticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(transverseLine.mas_bottom);
        make.bottom.equalTo(_viewBg);
        make.centerX.equalTo(_viewBg);
        make.width.mas_equalTo(0.5);
    }];
    
    //取消按钮
    _btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    [_btnCancel setTkThemeTitleColor:@[COLOR_858687, COLOR_858687_DARK] forState:UIControlStateNormal];
    [_btnCancel setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateSelected];
    [_btnCancel setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateHighlighted];
    _btnCancel.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    [_btnCancel addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_viewBg addSubview:_btnCancel];
    [_btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewBg);
        make.top.equalTo(transverseLine.mas_bottom);
        make.trailing.equalTo(verticalLine.mas_leading);
        make.height.mas_equalTo(DWScale(44));
        make.bottom.equalTo(_viewBg);
    }];
    
    //确定按钮
    _btnSure = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnSure setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
    [_btnSure setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateNormal];
    [_btnSure setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateSelected];
    [_btnSure setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateHighlighted];
    _btnSure.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    [_btnSure addTarget:self action:@selector(sureBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_viewBg addSubview:_btnSure];
    [_btnSure mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(verticalLine.mas_trailing);
        make.top.equalTo(transverseLine.mas_bottom);
        make.trailing.equalTo(_viewBg);
        make.height.mas_equalTo(DWScale(44));
        make.bottom.equalTo(_viewBg);
    }];
    
    [_viewBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_equalTo(DWScale(268));
        make.top.equalTo(_lblTitle.mas_top).offset(-DWScale(20));
        make.bottom.equalTo(_btnCancel.mas_bottom);
    }];
}
#pragma mark - 交互事件
- (void)alertTipViewSHow {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewBg.transform = CGAffineTransformIdentity;
    }];
}
- (void)alertTipViewDismiss {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewBg.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN, CGFLOAT_MIN);
    } completion:^(BOOL finished) {
        [weakSelf.viewBg removeFromSuperview];
        weakSelf.viewBg = nil;
        [weakSelf removeFromSuperview];
    }];
}

- (void)sureBtnAction {
    if (self.sureBtnBlock) {
        self.sureBtnBlock();
    }
    [self alertTipViewDismiss];
}

- (void)cancelBtnAction {
    if (self.cancelBtnBlock) {
        self.cancelBtnBlock();
    }
    [self alertTipViewDismiss];
}

@end
