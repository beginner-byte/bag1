//
//  NoaKnownTipView.m
//  NoaKit
//
//  Created by Candy on 2026/9/13.
//

#import "NoaKnownTipView.h"
#import "NoaToolManager.h"

@interface NoaKnownTipView ()
@property (nonatomic, strong) UIView *viewBg;
@end

@implementation NoaKnownTipView
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
    _viewBg.layer.cornerRadius = DWScale(14);
    _viewBg.layer.masksToBounds = YES;
    _viewBg.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN, CGFLOAT_MIN);
    [self addSubview:_viewBg];
    
    _lblTip = [UILabel new];
    _lblTip.tkThemetextColors = @[COLOR_11, COLOR_CCCCCC];
    _lblTip.font = FONTR(16);
    _lblTip.numberOfLines = 3;
    _lblTip.preferredMaxLayoutWidth = DWScale(263);
    [_viewBg addSubview:_lblTip];
    [_lblTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_viewBg);
        make.top.equalTo(_viewBg).offset(DWScale(34));
    }];
    
    _btnKnown = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnKnown setTitle:LanguageToolMatch(@"我知道了") forState:UIControlStateNormal];
    [_btnKnown setTitleColor:COLORWHITE forState:UIControlStateNormal];
    _btnKnown.layer.cornerRadius = DWScale(18);
    _btnKnown.layer.masksToBounds = YES;
    [_btnKnown setBackgroundColor:COLOR_5966F2];
    [_btnKnown setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateHighlighted];
    [_btnKnown addTarget:self action:@selector(knownTipViewDismiss) forControlEvents:UIControlEventTouchUpInside];
    [_viewBg addSubview:_btnKnown];
    [_btnKnown mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_viewBg);
        make.top.equalTo(_lblTip.mas_bottom).offset(DWScale(24));
        make.size.mas_equalTo(CGSizeMake(DWScale(106), DWScale(36)));
        make.bottom.equalTo(_viewBg.mas_bottom).offset(-DWScale(34));
    }];
    
    [_viewBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_equalTo(DWScale(311));
        make.top.equalTo(_lblTip.mas_top).offset(-DWScale(34));
        make.bottom.equalTo(_btnKnown.mas_bottom).offset(DWScale(34));
    }];
}
#pragma mark - 交互事件
- (void)knownTipViewSHow {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewBg.transform = CGAffineTransformIdentity;
    }];
}
- (void)knownTipViewDismiss {
    if (self.btnKnownBlock) {
        self.btnKnownBlock();
    }
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewBg.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN, CGFLOAT_MIN);
    } completion:^(BOOL finished) {
        [weakSelf.viewBg removeFromSuperview];
        weakSelf.viewBg = nil;
        [weakSelf removeFromSuperview];
    }];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
