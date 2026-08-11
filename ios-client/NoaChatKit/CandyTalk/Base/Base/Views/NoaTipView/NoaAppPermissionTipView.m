//
//  NoaAppPermissionTipView.m
//  NoaKit
//
//  Created by Candy on 2023/1/6.
//

#import "NoaAppPermissionTipView.h"
#import "NoaToolManager.h"

@interface NoaAppPermissionTipView ()
@property (nonatomic, strong) UIView *viewBg;
@end

@implementation NoaAppPermissionTipView

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
    
    _lblTitle = [UILabel new];
    _lblTitle.text = LanguageToolMatch(@"需要获取麦克风和相机权限");
    _lblTitle.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _lblTitle.font = FONTM(16);
    _lblTitle.textAlignment = NSTextAlignmentCenter;
    _lblTitle.numberOfLines = 2;
    _lblTitle.preferredMaxLayoutWidth = DWScale(255);
    [_viewBg addSubview:_lblTitle];
    [_lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_viewBg);
        make.top.equalTo(_viewBg).offset(DWScale(30));
    }];
    
    _lblTip = [UILabel new];
    _lblTip.text = LanguageToolMatch(@"打开麦克风和相机使用权限后可使用语音和视频通话，请在设置中打开。");
    _lblTip.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _lblTip.font = FONTR(16);
    _lblTip.numberOfLines = 3;
    _lblTip.preferredMaxLayoutWidth = DWScale(263);
    [_viewBg addSubview:_lblTip];
    [_lblTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_viewBg);
        make.top.equalTo(_lblTitle.mas_bottom).offset(DWScale(17));
    }];
    
    _btnOpen = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnOpen setTitle:LanguageToolMatch(@"打开") forState:UIControlStateNormal];
    [_btnOpen setTitleColor:COLORWHITE forState:UIControlStateNormal];
    _btnOpen.titleLabel.font = FONTR(17);
    _btnOpen.layer.cornerRadius = DWScale(22);
    _btnOpen.layer.masksToBounds = YES;
    [_btnOpen setBackgroundColor:COLOR_5966F2];
    [_btnOpen setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateHighlighted];
    [_btnOpen addTarget:self action:@selector(btnOpenClick) forControlEvents:UIControlEventTouchUpInside];
    [_viewBg addSubview:_btnOpen];
    [_btnOpen mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lblTip.mas_bottom).offset(DWScale(20));
        make.trailing.equalTo(_viewBg).offset(-DWScale(20));
        make.size.mas_equalTo(CGSizeMake(DWScale(146), DWScale(44)));
    }];
    
    _btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    [_btnCancel setTitleColor:COLOR_66 forState:UIControlStateNormal];
    _btnCancel.titleLabel.font = FONTR(17);
    _btnCancel.layer.cornerRadius = DWScale(22);
    _btnCancel.layer.masksToBounds = YES;
    [_btnCancel setTkThemebackgroundColors:@[COLOR_F5F6F9, COLOR_F5F6F9_DARK]];
    [_btnCancel setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateHighlighted];
    [_btnCancel addTarget:self action:@selector(permissionTipViewDismiss) forControlEvents:UIControlEventTouchUpInside];
    [_viewBg addSubview:_btnCancel];
    [_btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_btnOpen);
        make.leading.equalTo(_viewBg).offset(DWScale(20));
        make.size.mas_equalTo(CGSizeMake(DWScale(99), DWScale(44)));
    }];
    
    [_viewBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_equalTo(DWScale(295));
        make.top.equalTo(_lblTitle.mas_top).offset(-DWScale(30));
        make.bottom.equalTo(_btnOpen.mas_bottom).offset(DWScale(30));
    }];
    
}
#pragma mark - 交互事件
- (void)permissionTipViewSHow {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewBg.transform = CGAffineTransformIdentity;
    }];
}
- (void)permissionTipViewDismiss {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewBg.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN, CGFLOAT_MIN);
    } completion:^(BOOL finished) {
        [weakSelf.viewBg removeFromSuperview];
        weakSelf.viewBg = nil;
        [weakSelf removeFromSuperview];
    }];
}
- (void)btnOpenClick {
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    }else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];        
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
