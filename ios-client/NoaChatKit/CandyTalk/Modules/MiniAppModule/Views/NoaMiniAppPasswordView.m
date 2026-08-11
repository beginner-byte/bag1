//
//  NoaMiniAppPasswordView.m
//  NoaKit
//
//  Created by Candy on 2023/7/19.
//

#import "NoaMiniAppPasswordView.h"
#import "NoaToolManager.h"

@interface NoaMiniAppPasswordView ()

@property (nonatomic, strong) UIView *viewContent;
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UITextField *tfPassword;
@property (nonatomic, strong) UIButton *btnCancel;
@property (nonatomic, strong) UIButton *btnSure;

@end

@implementation NoaMiniAppPasswordView

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
    
    _viewContent = [[UIView alloc] initWithFrame:CGRectMake(DWScale(40), (DScreenHeight - DWScale(188)) / 2.0, DWScale(295), DWScale(188))];
    _viewContent.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    _viewContent.layer.cornerRadius = DWScale(15);
    _viewContent.layer.masksToBounds = YES;
    _viewContent.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN, CGFLOAT_MIN);
    [self addSubview:_viewContent];
    
    //标题
    _lblTitle = [UILabel new];
    _lblTitle.text = LanguageToolMatch(@"访问密码");
    _lblTitle.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _lblTitle.font = FONTB(18);
    _lblTitle.numberOfLines = 1;
    _lblTitle.preferredMaxLayoutWidth = DWScale(255);
    _lblTitle.textAlignment = NSTextAlignmentCenter;
    [_viewContent addSubview:_lblTitle];
    [_lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewContent).offset(DWScale(20));
        make.top.equalTo(_viewContent).offset(DWScale(26));
        make.height.mas_equalTo(DWScale(28));
    }];
    
    //输入密码
    UIView *viewPassword = [UIView new];
    viewPassword.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
    viewPassword.layer.cornerRadius = DWScale(8);
    viewPassword.layer.masksToBounds = YES;
    [_viewContent addSubview:viewPassword];
    [viewPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewContent).offset(DWScale(20));
        make.trailing.equalTo(_viewContent).offset(-DWScale(20));
        make.top.equalTo(_lblTitle.mas_bottom).offset(DWScale(14));
        make.height.mas_equalTo(DWScale(38));
    }];
    
    _tfPassword = [UITextField new];
    _tfPassword.placeholder = LanguageToolMatch(@"请输入访问密码");
    _tfPassword.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _tfPassword.font = FONTR(14);
    [viewPassword addSubview:_tfPassword];
    [_tfPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(viewPassword).offset(DWScale(10));
        make.trailing.equalTo(viewPassword).offset(-DWScale(10));
        make.centerY.equalTo(viewPassword);
        make.height.mas_equalTo(DWScale(30));
    }];
    
    //取消按钮
    _btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnCancel.layer.cornerRadius = DWScale(22);
    _btnCancel.layer.masksToBounds = YES;
    [_btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    [_btnCancel setTkThemeTitleColor:@[COLOR_66, COLOR_66_DARK] forState:UIControlStateNormal];
    _btnCancel.tkThemebackgroundColors = @[HEXCOLOR(@"F6F6F6"), HEXCOLOR(@"F6F6F6")];
    [_btnCancel setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateSelected];
    [_btnCancel setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateHighlighted];
    [_btnCancel addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_viewContent addSubview:_btnCancel];
    [_btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewContent).offset(DWScale(20));
        make.size.mas_equalTo(CGSizeMake(DWScale(99), DWScale(44)));
        make.bottom.equalTo(_viewContent).offset(-DWScale(18));
    }];
    
    //确定按钮
    _btnSure = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnSure.layer.cornerRadius = DWScale(22);
    _btnSure.layer.masksToBounds = YES;
    [_btnSure setTitle:LanguageToolMatch(@"确定") forState:UIControlStateNormal];
    [_btnSure setTkThemeTitleColor:@[COLORWHITE, COLORWHITE_DARK] forState:UIControlStateNormal];
    _btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    [_btnSure setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateSelected];
    [_btnSure setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateHighlighted];
    [_btnSure addTarget:self action:@selector(sureBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_viewContent addSubview:_btnSure];
    [_btnSure mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_viewContent).offset(-DWScale(20));
        make.size.mas_equalTo(CGSizeMake(DWScale(146), DWScale(44)));
        make.bottom.equalTo(_viewContent).offset(-DWScale(18));
    }];
    
}
#pragma mark - 交互事件
- (void)miniAppPasswordShow {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewContent.transform = CGAffineTransformIdentity;
    }];
}

- (void)miniAppPasswordDismiss {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewContent.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN, CGFLOAT_MIN);
    } completion:^(BOOL finished) {
        [weakSelf.viewContent removeFromSuperview];
        weakSelf.viewContent = nil;
        [weakSelf removeFromSuperview];
    }];
}

- (void)sureBtnAction {
    if (_miniAppModel) {
        
        NSString *password = [_tfPassword.text trimString];
        
        if (![NSString isNil:password]) {
            WeakSelf
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObjectSafe:password forKey:@"qaPwd"];
            [dict setObjectSafe:_miniAppModel.qaUuid forKey:@"qaUuid"];
            [IMSDKManager imMiniAppDetailWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                if ([data isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dataDict = (NSDictionary *)data;
                    LingIMMiniAppModel *tempMiniApp = [LingIMMiniAppModel mj_objectWithKeyValues:dataDict];
                    weakSelf.miniAppModel.qaPwd = tempMiniApp.qaPwd;
                    weakSelf.miniAppModel.qaAppUrl = tempMiniApp.qaAppUrl;
                    
                    if (weakSelf.sureBtnBlock) {
                        weakSelf.sureBtnBlock();
                    }
                }
                [weakSelf miniAppPasswordDismiss];
            } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                [HUD showMessageWithCode:code errorMsg:msg];
            }];
            
            
        }else {
            [HUD showMessage:LanguageToolMatch(@"请输入访问密码")];
        }
    }
}

- (void)cancelBtnAction {
    if (self.cancelBtnBlock) {
        self.cancelBtnBlock();
    }
    [self miniAppPasswordDismiss];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
