//
//  AppUseTipView.m
//  NoaKit
//
//  Created by Candy on 2023/6/19.
//

#import "AppUseTipView.h"
#import "NoaToolManager.h"
@interface AppUseTipView ()
@property (nonatomic, strong) UIView *viewContent;
@property (nonatomic, strong) UIScrollView *viewScrollView;
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UILabel *lblContent;
@property (nonatomic, strong) YYLabel *lblAction;
@property (nonatomic, strong) UIButton *btnDisagree;
@property (nonatomic, strong) UIButton *btnAgree;
@end

@implementation AppUseTipView

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
    self.tkThemebackgroundColors = @[[COLOR_00 colorWithAlphaComponent:0.3], [COLOR_00_DARK colorWithAlphaComponent:0.3]];
    [CurrentWindow addSubview:self];
    
    _viewContent = [UIView new];
    _viewContent.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];;
    _viewContent.layer.cornerRadius = DWScale(15);
    _viewContent.layer.masksToBounds = YES;
    _viewContent.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN, CGFLOAT_MIN);
    [self addSubview:_viewContent];
    [_viewContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(DWScale(295), DWScale(350)));
    }];
    
    _lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(DWScale(15), DWScale(15), DWScale(265), DWScale(20))];
    _lblTitle.text = LanguageToolMatch(@"温馨提示");
    _lblTitle.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _lblTitle.font = FONTM(16);
    [_viewContent addSubview:_lblTitle];
    [_lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(_viewContent).offset(DWScale(15));
        make.height.mas_equalTo(DWScale(20));
    }];
    
    _viewScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(DWScale(15), DWScale(45), DWScale(265), DWScale(200))];
    _viewScrollView.contentSize = CGSizeMake(DWScale(265), DWScale(300));
    _viewScrollView.scrollEnabled = YES;
    _viewScrollView.showsVerticalScrollIndicator = NO;
    _viewScrollView.showsHorizontalScrollIndicator = NO;
    [_viewContent addSubview:_viewScrollView];
    
    _lblContent = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DWScale(265), DWScale(200))];
    _lblContent.preferredMaxLayoutWidth = DWScale(265);
    _lblContent.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    _lblContent.numberOfLines = 0;
    _lblContent.font = FONTR(14);
    _lblContent.text = LanguageToolMatch(@"1、为了保证产品服务的正常运行，更好的提供文字聊天、发送语音、添加好友等沟通交流功能，我们会遵循用户协议和隐私政策，收集您的部分必要信息。 \n2、上述服务可能涉及到设备信息、麦克风、相册等个人敏感信息，您有权拒绝或者撤回授权。 \n3、我们不会向第三方共享、提供、转让或者从第三方获取您的个人信息。");
    //[_lblContent sizeToFit];
    [_viewScrollView addSubview:_lblContent];

    
    _lblAction = [YYLabel new];
    _lblAction.numberOfLines = 2;
    _lblAction.preferredMaxLayoutWidth = DWScale(265);
    _lblAction.userInteractionEnabled = YES;
    _lblAction.backgroundColor = COLOR_CLEAR;
    NSString *serveText = LanguageToolMatch(@"服务协议");
    NSString *privateText = LanguageToolMatch(@"隐私政策");
    NSString *contentText = [NSString stringWithFormat:LanguageToolMatch(@"您可以阅读完整版%@和%@"), serveText, privateText];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:contentText];
    [text configAttStrLightColor:COLOR_66 darkColor:COLOR_66_DARK range:NSMakeRange(0, contentText.length)];
    
    [text yy_setTextHighlightRange:[contentText rangeOfString:serveText] color:COLOR_5966F2 backgroundColor:COLOR_CLEAR tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        //服务协议
        [ZTOOL setupServeAgreement];
    }];
    [text yy_setTextHighlightRange:[contentText rangeOfString:privateText] color:COLOR_5966F2 backgroundColor:COLOR_CLEAR tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        //隐私政策
        [ZTOOL setupPrivePolicy];
    }];
    [text addAttribute:NSFontAttributeName value:FONTR(14) range:NSMakeRange(0, contentText.length)];
    _lblAction.attributedText = text;
    [_viewContent addSubview:_lblAction];
    [_lblAction mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewContent).offset(DWScale(15));
        make.top.equalTo(_viewScrollView.mas_bottom).offset(DWScale(5));
        make.width.mas_equalTo(DWScale(265));
    }];
    
    _btnDisagree = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnDisagree.layer.cornerRadius = DWScale(20);
    _btnDisagree.layer.masksToBounds = YES;
    [_btnDisagree setTitle:LanguageToolMatch(@"拒绝") forState:UIControlStateNormal];
    [_btnDisagree setTkThemeTitleColor:@[COLOR_11, COLOR_11_DARK] forState:UIControlStateNormal];
    _btnDisagree.titleLabel.font = FONTR(14);
    [_btnDisagree setTkThemebackgroundColors:@[COLOR_F6F6F6, COLOR_F6F6F6_DARK]];
    [_btnDisagree addTarget:self action:@selector(btnDisagreeClick) forControlEvents:UIControlEventTouchUpInside];
    [_viewContent addSubview:_btnDisagree];
    [_btnDisagree mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_viewContent).offset(-DWScale(15));
        make.leading.equalTo(_viewContent).offset(DWScale(15));
        make.size.mas_equalTo(CGSizeMake(DWScale(115), DWScale(40)));
    }];
    
    _btnAgree = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnAgree.layer.cornerRadius = DWScale(20);
    _btnAgree.layer.masksToBounds = YES;
    [_btnAgree setTitle:LanguageToolMatch(@"同意") forState:UIControlStateNormal];
    [_btnAgree setTkThemeTitleColor:@[COLORWHITE, COLORWHITE_DARK] forState:UIControlStateNormal];
    _btnAgree.titleLabel.font = FONTR(14);
    [_btnAgree setTkThemebackgroundColors:@[COLOR_5966F2, COLOR_5966F2_DARK]];
    [_btnAgree addTarget:self action:@selector(btnAgreeClick) forControlEvents:UIControlEventTouchUpInside];
    [_viewContent addSubview:_btnAgree];
    [_btnAgree mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.trailing.equalTo(_viewContent).offset(-DWScale(15));
        make.size.mas_equalTo(CGSizeMake(DWScale(115), DWScale(40)));
    }];
}

- (void)showAppUserAgreement {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewContent.transform = CGAffineTransformIdentity;
    }];
}

- (void)dismissAppUserAgreement {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewContent.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN, CGFLOAT_MIN);
    } completion:^(BOOL finished) {
        [weakSelf.viewContent removeFromSuperview];
        weakSelf.viewContent = nil;
        [weakSelf removeFromSuperview];
    }];
}

#pragma mark - 交互事件
//不同意
- (void)btnDisagreeClick {
    //相当于按了Home键
    [[UIApplication sharedApplication] performSelector:@selector(suspend)];
}
//同意
- (void)btnAgreeClick {
    [[MMKV defaultMMKV] setBool:YES forKey:@"AgreeUserAgreement"];
    //关闭弹窗
    [self dismissAppUserAgreement];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
