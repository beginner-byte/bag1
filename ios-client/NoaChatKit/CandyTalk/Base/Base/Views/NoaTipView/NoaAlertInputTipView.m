//
//  NoaAlertInputTipView.m
//  NoaKit
//
//  Created by Candy on 2023/5/4.
//

#import "NoaAlertInputTipView.h"
#import "NoaToolManager.h"

@interface NoaAlertInputTipView () <ZPlaceHolderTextViewDelegate>

@property (nonatomic, strong) UIView *viewBg;

@end

@implementation NoaAlertInputTipView

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
    self.backgroundColor = [COLOR_00 colorWithAlphaComponent:0.3];
    [CurrentWindow addSubview:self];
    
    _viewBg = [UIView new];
    _viewBg.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];;
    _viewBg.layer.cornerRadius = DWScale(15);
    _viewBg.layer.masksToBounds = YES;
    _viewBg.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN, CGFLOAT_MIN);
    [self addSubview:_viewBg];
    
    _lblTip = [UILabel new];
    _lblTip.tkThemetextColors = @[COLOR_11, COLOR_CCCCCC];
    _lblTip.font = FONTR(15);
    _lblTip.numberOfLines = 3;
    _lblTip.preferredMaxLayoutWidth = DWScale(257);
    [_viewBg addSubview:_lblTip];
    [_lblTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_viewBg);
        make.top.equalTo(_viewBg).offset(DWScale(30));
    }];
    
    _textView = [[NoaPlaceHolderTextView alloc] initWithFrame:CGRectZero hiddenMaxText:NO];
    _textView.textViewDelegate = self;
    [_textView rounded:8];
    _textView.font = FONTN(14);
    _textView.maxTextLength = 30;
    _textView.placeHolder = LanguageToolMatch(@"说明邀请理由");
    _textView.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _textView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
    _textView.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        UIColor *color = nil;
        if (themeIndex == 0) {
            color = COLOR_66;
        } else {
            color = COLOR_66_DARK;
        }
        [(NoaPlaceHolderTextView *)itself setPlaceHolderTextColor:color];
    };
    [_viewBg addSubview:_textView];
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewBg).offset(DWScale(18));
        make.trailing.equalTo(_viewBg).offset(DWScale(-18));
        make.top.equalTo(_lblTip.mas_bottom).offset(DWScale(20));
        make.height.mas_equalTo(DWScale(98));
    }];
    
    //取消按钮
    _btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    [_btnCancel setTkThemeTitleColor:@[COLOR_66, COLOR_66_DARK] forState:UIControlStateNormal];
    _btnCancel.tkThemebackgroundColors = @[COLOR_F6F6F6,COLOR_F6F6F6_DARK];
    [_btnCancel setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateSelected];
    [_btnCancel setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateHighlighted];
    _btnCancel.titleLabel.font = FONTN(17);
    [_btnCancel rounded:DWScale(22)];
    [_btnCancel addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_viewBg addSubview:_btnCancel];
    [_btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewBg).offset(DWScale(18));
        make.top.equalTo(_textView.mas_bottom).offset(DWScale(28));
        make.width.mas_equalTo(DWScale(99));
        make.height.mas_equalTo(DWScale(44));
    }];
    
    //确定按钮
    _btnSure = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnSure setTitle:LanguageToolMatch(@"发送") forState:UIControlStateNormal];
    [_btnSure setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
    _btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2];
    [_btnSure setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateSelected];
    [_btnSure setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateHighlighted];
    _btnSure.titleLabel.font = FONTN(17);
    [_btnSure rounded:DWScale(22)];
    [_btnSure addTarget:self action:@selector(sureBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_viewBg addSubview:_btnSure];
    [_btnSure mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_viewBg.mas_trailing).offset(DWScale(-20));
        make.top.equalTo(_textView.mas_bottom).offset(DWScale(28));
        make.width.mas_equalTo(DWScale(146));
        make.height.mas_equalTo(DWScale(44));
    }];
    
    [_viewBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_equalTo(DWScale(293));
        make.top.equalTo(_lblTip.mas_top).offset(-DWScale(30));
        make.bottom.equalTo(_btnSure.mas_bottom).offset(DWScale(30));
    }];
}

#pragma mark ZPlaceHolderTextViewDelegate
//当需要显示字数显示的时候，必须实现这个代理方法，虽然在这里可以什么都不用操作
- (void)refreshTextLimit {
}

//显示
- (void)alertTipViewShow {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewBg.transform = CGAffineTransformIdentity;
    }];
}

//消失
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

#pragma mark - 交互事件
- (void)sureBtnAction {
    if (self.sureBtnBlock) {
        self.sureBtnBlock(self.textView.text);
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
