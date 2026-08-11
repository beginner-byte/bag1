//
//  NoaMiniAppDeleteTipView.m
//  NoaKit
//
//  Created by Candy on 2023/7/18.
//

#import "NoaMiniAppDeleteTipView.h"
#import "NoaToolManager.h"

@interface NoaMiniAppDeleteTipView ()

@property (nonatomic, strong) UIView *viewBg;
@property (nonatomic, strong) UILabel *lblTitle;    //标题
@property (nonatomic, strong) UILabel *lblContent;  //内容
@property (nonatomic, strong) UIButton *btnCancel;  //取消按钮
@property (nonatomic, strong) UIButton *btnSure;    //确定按钮

@end

@implementation NoaMiniAppDeleteTipView

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
    self.tkThemebackgroundColors = @[HEXACOLOR(@"000000", 0.3),HEXACOLOR(@"000000", 0.3)];
    [CurrentWindow addSubview:self];
    
    _viewBg = [[UIView alloc] initWithFrame:CGRectMake(DWScale(40), (DScreenHeight - DWScale(188)) / 2.0, DWScale(295), DWScale(188))];
    _viewBg.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    _viewBg.layer.cornerRadius = DWScale(15);
    _viewBg.layer.masksToBounds = YES;
    _viewBg.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN, CGFLOAT_MIN);
    [self addSubview:_viewBg];
    
    //标题
    _lblTitle = [UILabel new];
    _lblTitle.text = LanguageToolMatch(@"是否删除");
    _lblTitle.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _lblTitle.font = FONTB(18);
    _lblTitle.numberOfLines = 1;
    _lblTitle.preferredMaxLayoutWidth = DWScale(255);
    _lblTitle.textAlignment = NSTextAlignmentCenter;
    [_viewBg addSubview:_lblTitle];
    [_lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_viewBg);
        make.top.equalTo(_viewBg).offset(DWScale(22));
        make.height.mas_equalTo(DWScale(28));
    }];
    
    //内容
    _lblContent = [UILabel new];
    _lblContent.text = LanguageToolMatch(@"删除选择的小程序入口");
    _lblContent.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    _lblContent.font = FONTR(14);
    _lblContent.numberOfLines = 1;
    _lblContent.preferredMaxLayoutWidth = DWScale(255);
    _lblContent.textAlignment = NSTextAlignmentCenter;
    [_viewBg addSubview:_lblContent];
    [_lblContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_viewBg);
        make.top.equalTo(_lblTitle.mas_bottom).offset(DWScale(19));
        make.height.mas_equalTo(DWScale(28));
    }];
    
    //取消按钮
    _btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnCancel.layer.cornerRadius = DWScale(22);
    _btnCancel.layer.masksToBounds = YES;
    [_btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    [_btnCancel setTkThemeTitleColor:@[COLOR_66, COLOR_66] forState:UIControlStateNormal];
    _btnCancel.tkThemebackgroundColors = @[HEXCOLOR(@"F6F6F6"), HEXCOLOR(@"F6F6F6")];
    [_btnCancel setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateSelected];
    [_btnCancel setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateHighlighted];
    [_btnCancel addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_viewBg addSubview:_btnCancel];
    [_btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewBg).offset(DWScale(20));
        make.size.mas_equalTo(CGSizeMake(DWScale(99), DWScale(44)));
        make.bottom.equalTo(_viewBg).offset(-DWScale(18));
    }];
    
    //确定按钮
    _btnSure = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnSure.layer.cornerRadius = DWScale(22);
    _btnSure.layer.masksToBounds = YES;
    [_btnSure setTitle:LanguageToolMatch(@"确定") forState:UIControlStateNormal];
    [_btnSure setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
    _btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    [_btnSure setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateSelected];
    [_btnSure setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateHighlighted];
    [_btnSure addTarget:self action:@selector(sureBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_viewBg addSubview:_btnSure];
    [_btnSure mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_viewBg).offset(-DWScale(20));
        make.size.mas_equalTo(CGSizeMake(DWScale(146), DWScale(44)));
        make.bottom.equalTo(_viewBg).offset(-DWScale(18));
    }];
    
}
#pragma mark - 交互事件
- (void)tipViewSHow {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewBg.transform = CGAffineTransformIdentity;
    }];
}
- (void)tipViewDismiss {
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
    [self tipViewDismiss];
}

- (void)cancelBtnAction {
    if (self.cancelBtnBlock) {
        self.cancelBtnBlock();
    }
    [self tipViewDismiss];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
