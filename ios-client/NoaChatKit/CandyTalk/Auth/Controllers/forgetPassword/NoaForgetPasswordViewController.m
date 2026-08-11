//
//  NoaForgetPasswordViewController.m
//  NoaChatKit
//
//  Created by phl on 2025/11/17.
//

#import "NoaForgetPasswordViewController.h"
#import "NoaForgetPasswordDataHandle.h"
#import "NoaForgetPasswordView.h"
// 手机号选择区号页面
#import "NoaCountryCodeViewController.h"
// 图文验证码弹窗
#import "NoaGetImgVerCodeViewController.h"

@interface NoaForgetPasswordViewController ()

/// UI
@property (nonatomic, strong) NoaForgetPasswordView *resetPasswordView;

/// 数据处理
@property (nonatomic, strong) NoaForgetPasswordDataHandle *dataHandle;

@end

@implementation NoaForgetPasswordViewController

// MARK: dealloc
- (void)dealloc {
    CIMLog(@"%@ dealloc", [self class]);
}

// MARK: set/get
- (NoaForgetPasswordDataHandle *)dataHandle {
    if (!_dataHandle) {
        _dataHandle = [[NoaForgetPasswordDataHandle alloc] initWithResetPasswordWay:self.currentResetPasswordType
                                                                         AreaCode:self.areaCode
                                                                     ResetAccount:self.resetAccount];
    }
    return _dataHandle;
}

- (NoaForgetPasswordView *)resetPasswordView {
    if (!_resetPasswordView) {
        _resetPasswordView = [[NoaForgetPasswordView alloc] initWithFrame:CGRectZero
                                                             DataHandle:self.dataHandle];
    }
    return _resetPasswordView;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // 清理原因:将登录方式重置为系统设置，而非后期设置的图文验证码
    [self.dataHandle resetSDKCaptchaChannel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    [self processData];
}

- (void)setUpUI {
    self.navTitleLabel.text = LanguageToolMatch(@"忘记密码");
    [self.view addSubview:self.resetPasswordView];
    [self.resetPasswordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navView.mas_bottom).offset(25);
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

- (void)processData {
    @weakify(self)
    [self.dataHandle.jumpChangeAreaCodeSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        NoaCountryCodeViewController *countryCodeVC = [[NoaCountryCodeViewController alloc] init];
        [self.navigationController pushViewController:countryCodeVC animated:YES];
        [countryCodeVC setSelecgCountryCodeBlock:^(NSDictionary * _Nonnull dic) {
            @strongify(self)
            NSNumber *areaCode = [dic objectForKey:@"prefix"];
            NSString *newAreaCode = [NSString stringWithFormat:@"+%@", areaCode];
            [self.dataHandle changeAreaCode:newAreaCode];
            [self.resetPasswordView refreshShowAreaCode];
        }];
    }];
    
    [self.dataHandle.showToastSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (![x isKindOfClass:[NSString class]]) {
            return;
        }
        
        NSString *msg = x;
        if (![x isKindOfClass:[NSString class]]) {
            return;
        }
        
        [ZTOOL doInMain:^{
            [HUD showMessage:msg inView:self.view];
        }];
    }];
    
    [self.dataHandle.showImgVerCodeSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (![x isKindOfClass:[NSDictionary class]]) {
            return;
        }
        NSDictionary *imgVerCodeDic = x;
        
        NSString *imgVerCode = [imgVerCodeDic objectForKey:@"code"];
        int verCodeType = [[imgVerCodeDic objectForKey:@"verCodeType"] intValue];
        
        // 账号
        NSString *account = [self.dataHandle getAccountText];
        
        NoaGetImgVerCodeViewController *imgVerCodeVC = [[NoaGetImgVerCodeViewController alloc] init];
        imgVerCodeVC.account = account;
        imgVerCodeVC.imgVerCode = imgVerCode;
        imgVerCodeVC.verCodeType = verCodeType;
        [imgVerCodeVC show];
        imgVerCodeVC.configureImgVerCodeSuccessBlock = ^(NSString * _Nonnull imgVerCodeStr) {
            @strongify(self)
            // 用户点击确认，调用发送验证码接口
            NSDictionary *paramDic = [self.dataHandle getVerCodeParamWithImgCode:imgVerCodeStr
                                                                          Ticket:@""
                                                                         Randstr:@""
                                                              CaptchaVerifyParam:@""];
            [self.dataHandle.getVerCommand execute:paramDic];
            // 恢复验证配置
            [self.dataHandle resetSDKCaptchaChannel];
        };
        
        imgVerCodeVC.cancelInputImgVerCodeBlock = ^{
            @strongify(self)
            // 恢复验证配置
            [self.dataHandle resetSDKCaptchaChannel];
        };
    }];
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
