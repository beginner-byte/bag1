//
//  NoaAuthPCloginViewController.m
//  NoaKit
//
//  Created by Candy on 2023/4/3.
//

#import "NoaAuthPCloginViewController.h"

@interface NoaAuthPCloginViewController ()

@end

@implementation NoaAuthPCloginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavUI];
    [self setupUI];
}

#pragma mark - 界面布局
- (void)setupNavUI {
    self.navTitleStr = LanguageToolMatch(@"登录确认");
    self.navLineView.hidden = YES;
}

- (void)setupUI {
    UIImageView *tipsImgView = [[UIImageView alloc] init];
    tipsImgView.image = ImgNamed(@"img_pc_auth_login");
    [self.view addSubview:tipsImgView];
    [tipsImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navView.mas_bottom).offset(DWScale(115));
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(DWScale(200));
        make.height.mas_equalTo(DWScale(200));
    }];
    
    NSString * st = [NSString stringWithFormat:LanguageToolMatch(@"登录%@ PC端"), [ZTOOL getAppName]];
    UILabel *tipsTitleLbl = [[UILabel alloc] init];
    tipsTitleLbl.text = st;
    tipsTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    tipsTitleLbl.font = FONTN(18);
    tipsTitleLbl.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipsTitleLbl];
    [tipsTitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipsImgView.mas_bottom).offset(DWScale(47));
        make.leading.equalTo(self.view).offset(DWScale(16));
        make.trailing.equalTo(self.view).offset(DWScale(-16));
        make.height.mas_equalTo(DWScale(25));
    }];
    
    //授权登录
    UIButton *authLoginBtn = [[UIButton alloc] init];
    [authLoginBtn setTitle:LanguageToolMatch(@"授权登录") forState:UIControlStateNormal];
    [authLoginBtn setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
    authLoginBtn.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    [authLoginBtn setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateSelected];
    [authLoginBtn setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateHighlighted];
    [authLoginBtn rounded:DWScale(14)];
    authLoginBtn.titleLabel.font = FONTN(16);
    authLoginBtn.clipsToBounds = YES;
    [authLoginBtn addTarget:self action:@selector(authAuthLoginClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:authLoginBtn];
    [authLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipsTitleLbl.mas_bottom).offset(DWScale(55));
        make.leading.equalTo(self.view).offset(DWScale(16));
        make.trailing.equalTo(self.view).offset(DWScale(-16));
        make.height.mas_equalTo(DWScale(50));
    }];
    
    //取消登录
    UIButton *cancelLoginBtn = [[UIButton alloc] init];
    [cancelLoginBtn setTitle:LanguageToolMatch(@"取消登录") forState:UIControlStateNormal];
    [cancelLoginBtn setTkThemeTitleColor:@[COLOR_99, COLOR_99_DARK] forState:UIControlStateNormal];
    cancelLoginBtn.clipsToBounds = YES;
    cancelLoginBtn.titleLabel.font = FONTN(14);
    [cancelLoginBtn addTarget:self action:@selector(cancelAuthLoginClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelLoginBtn];
    [cancelLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(authLoginBtn.mas_bottom).offset(DWScale(20));
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(DWScale(60));
        make.height.mas_equalTo(DWScale(25));
    }];
}

#pragma mark - Action
- (void)authAuthLoginClick {
    //step    扫码后操作类型 1:确认  2:取消
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObjectSafe:self.deviceUuidStr forKey:@"deviceUuid"];
    [params setObjectSafe:self.ewmKeyStr forKey:@"ewmKey"];
    [params setObjectSafe:[NSNumber numberWithInt:1] forKey:@"step"];
    [params setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];

    [IMSDKManager authScanQrCodeForPCLoginWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [ZTOOL doInMain:^{
            BOOL result = [data boolValue];
            if (result) {
                [HUD showMessage:LanguageToolMatch(@"授权成功")];
            } else {
                [HUD showMessage:LanguageToolMatch(@"二维码已过期")];
            }
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [ZTOOL doInMain:^{
            [HUD showMessageWithCode:code errorMsg:msg];
        }];
        
    }];
}

- (void)cancelAuthLoginClick {
    //step    扫码后操作类型 1:确认  2:取消
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObjectSafe:self.deviceUuidStr forKey:@"deviceUuid"];
    [params setObjectSafe:self.ewmKeyStr forKey:@"ewmKey"];
    [params setObjectSafe:[NSNumber numberWithInt:2] forKey:@"step"];
    [params setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    
    [IMSDKManager authScanQrCodeForPCLoginWith:params  onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [ZTOOL doInMain:^{
            [HUD showMessage:LanguageToolMatch(@"授权取消")];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [ZTOOL doInMain:^{
            [HUD showMessageWithCode:code errorMsg:msg];
        }];
        
    }];
}

#pragma mark - Super
- (void)navBtnBackClicked {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
