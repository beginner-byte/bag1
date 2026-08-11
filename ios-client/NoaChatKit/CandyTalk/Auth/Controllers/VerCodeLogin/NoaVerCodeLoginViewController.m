//
//  NoaVerCodeLoginViewController.m
//  NoaChatKit
//
//  Created by phl on 2025/11/17.
//

#import "NoaVerCodeLoginViewController.h"
#import "NoaVerCodeLoginDataHandle.h"
#import "NoaVerCodeLoginView.h"
// 手机号选择区号页面
#import "NoaCountryCodeViewController.h"
// 图文验证码弹窗
#import "NoaGetImgVerCodeViewController.h"

@interface NoaVerCodeLoginViewController ()

/// UI
@property (nonatomic, strong) NoaVerCodeLoginView *verCodeLoginView;

/// 数据处理
@property (nonatomic, strong) NoaVerCodeLoginDataHandle *dataHandle;

@end

@implementation NoaVerCodeLoginViewController

// MARK: dealloc
- (void)dealloc {
    CIMLog(@"%@ dealloc", [self class]);
}

// MARK: set/get
- (NoaVerCodeLoginDataHandle *)dataHandle {
    if (!_dataHandle) {
        _dataHandle = [[NoaVerCodeLoginDataHandle alloc] initWithVerCodeLoginWay:self.currentVerCodeLoginType
                                                                      AreaCode:self.areaCode
                                                                  LoginAccount:self.loginAccount];
    }
    return _dataHandle;
}

- (NoaVerCodeLoginView *)verCodeLoginView {
    if (!_verCodeLoginView) {
        _verCodeLoginView = [[NoaVerCodeLoginView alloc] initWithFrame:CGRectZero
                                                             DataHandle:self.dataHandle];
    }
    return _verCodeLoginView;
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
    self.navTitleLabel.text = LanguageToolMatch(@"验证码登录");
    [self.view addSubview:self.verCodeLoginView];
    [self.verCodeLoginView mas_makeConstraints:^(MASConstraintMaker *make) {
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
            [self.verCodeLoginView refreshShowAreaCode];
        }];
    }];
    
    [self.dataHandle.showToastSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (![x isKindOfClass:[NSString class]]) {
            return;
        }
        
        NSString *msg = x;
        if ([NSString isNil:msg]) {
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
