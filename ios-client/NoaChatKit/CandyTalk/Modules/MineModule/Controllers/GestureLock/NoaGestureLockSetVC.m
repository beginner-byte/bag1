//
//  NoaGestureLockSetVC.m
//  NoaKit
//
//  Created by Candy on 2023/4/24.
//

#import "NoaGestureLockSetVC.h"
#import "NoaGestureLockView.h"

@interface NoaGestureLockSetVC () <ZGestureLockViewDelegate>
@property (nonatomic, strong) UILabel *lblTitle;//标题
@property (nonatomic, strong) UIImageView *ivLogo;//logo
@property (nonatomic, strong) NoaGestureLockView *viewGesture;//手势图案
@property (nonatomic, strong) UIButton *btnCancel;//取消绘制
@property (nonatomic, copy) NSString *fistPassword;//首次密码
@end

@implementation NoaGestureLockSetVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

#pragma mark - 界面布局
- (void)setupUI {
    self.navView.hidden = YES;
    
    UIImageView *ivBg = [[UIImageView alloc] init];
    ivBg.image = [UIImage gradientColorImageFromColors:@[HEXCOLOR(@"2A54CA"), HEXCOLOR(@"719FDF")] gradientType:GradientColorTypeTopToBottom imageSize:CGSizeMake(DScreenWidth, DScreenHeight)];
    [self.view addSubview:ivBg];
    [ivBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    _lblTitle = [UILabel new];
    _lblTitle.text = LanguageToolMatch(@"请绘制新的解锁图案");
    _lblTitle.tkThemetextColors = @[COLORWHITE, COLORWHITE_DARK];
    _lblTitle.font = FONTR(18);
    [self.view addSubview:_lblTitle];
    [_lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(DWScale(55));
    }];
    
    _ivLogo = [[UIImageView alloc] initWithImage:ImgNamed(@"img_login_logo")];
    [self.view addSubview:_ivLogo];
    [_ivLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(_lblTitle.mas_bottom).offset(DWScale(33));
        make.size.mas_equalTo(CGSizeMake(DWScale(82), DWScale(82)));
    }];
    
    _viewGesture = [NoaGestureLockView new];
    _viewGesture.delegate = self;
    [self.view addSubview:_viewGesture];
    [_viewGesture mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(_ivLogo.mas_bottom).offset(DWScale(80));
        make.height.mas_equalTo(DScreenWidth);
    }];
    
    _btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnCancel setTitle:LanguageToolMatch(@"取消图案绘制") forState:UIControlStateNormal];
    [_btnCancel setTkThemeTitleColor:@[COLORWHITE, COLORWHITE_DARK] forState:UIControlStateNormal];
    _btnCancel.titleLabel.font = FONTR(14);
    [_btnCancel addTarget:self action:@selector(btnCancelClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnCancel];
    [_btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-DWScale(14) - DHomeBarH);
    }];
}
#pragma mark - 交互事件
- (void)btnCancelClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - ZGestureLockViewDelegate
- (void)gestureLockViewFinishWith:(NSMutableString *)gesturePassword {
    if (![NSString isNil:_fistPassword]) {
        //验证二次手势密码是否正确
        if ([gesturePassword isEqualToString:_fistPassword]) {
            
            NSString *userKey = [NSString stringWithFormat:@"%@-GesturePassword", UserManager.userInfo.userUID];
            NSDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:_fistPassword forKey:@"password"];//手势密码信息
            [dict setValue:@(0) forKey:@"checkNumber"];//验证手势密码次数
            [dict setValue:@(0) forKey:@"checkAccountPassword"];//验证用户密码次数
            [[MMKV defaultMMKV] setString:[dict mj_JSONString] forKey:userKey];
            
            
            [HUD showMessage:LanguageToolMatch(@"设置成功")];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UserSetGesturePassword" object:nil];
            
            WeakSelf
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC));
            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            });
            
        }else {
            
            [HUD showMessage:LanguageToolMatch(@"图案绘制的不同\n请重新输入手势密码")];
            
        }
    }else {
        _fistPassword = gesturePassword;
        _lblTitle.text = LanguageToolMatch(@"请绘制相同图案");
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
