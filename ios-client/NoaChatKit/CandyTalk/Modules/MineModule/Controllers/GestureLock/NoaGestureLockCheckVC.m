//
//  NoaGestureLockCheckVC.m
//  NoaKit
//
//  Created by Candy on 2023/4/24.
//

#import "NoaGestureLockCheckVC.h"
#import "NoaGestureLockView.h"
#import "NoaGestureLockCheckAccountPasswordView.h"
#import "NoaToolManager.h"

@interface NoaGestureLockCheckVC () <ZGestureLockViewDelegate, ZGestureLockCheckAccountPasswordDelegate>
@property (nonatomic, strong) UILabel *lblTitle;//标题
@property (nonatomic, strong) UIImageView *ivLogo;//logo
@property (nonatomic, strong) NoaGestureLockView *viewGesture;//手势图案
@property (nonatomic, strong) UIButton *btnCancel;//取消绘制
@property (nonatomic, copy) NSString *gesturePassword;//手势密码
@property (nonatomic, assign) NSInteger checkNumber;//密码验证次数
@property (nonatomic, assign) BOOL isVerifiedSuccess;//是否验证成功，只有验证成功才能关闭
@end

@implementation NoaGestureLockCheckVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _isVerifiedSuccess = NO;
    [self setupUI];
    
    NSString *userKey = [NSString stringWithFormat:@"%@-GesturePassword", UserManager.userInfo.userUID];
    NSString *jsonStr = [[MMKV defaultMMKV] getStringForKey:userKey];
    
    if (![NSString isNil:jsonStr]) {
        
        NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if (!error) {
            _gesturePassword = [dict objectForKeySafe:@"password"];
            _checkNumber = [[dict objectForKeySafe:@"checkNumber"] integerValue];
            if (_checkNumber >= 5) {
                NoaGestureLockCheckAccountPasswordView *viewCheckAccount = [NoaGestureLockCheckAccountPasswordView new];
                viewCheckAccount.delegate = self;
                [self.view addSubview:viewCheckAccount];
            }
        }
        
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 确保手势锁控制器始终显示在最前面
    // 如果当前控制器不是最顶层的，说明可能被其他逻辑影响了
    if (!_isVerifiedSuccess && _checkType == GestureLockCheckTypeNormal) {
        // 延迟检查，确保视图层级已经稳定
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 检查当前顶层控制器是否是手势锁控制器
            UIViewController *currentTopVC = CurrentVC;
            // 如果当前顶层控制器不是手势锁控制器，且本控制器已经被移除了，需要重新 present
            if (currentTopVC && currentTopVC != self && ![currentTopVC isKindOfClass:[NoaGestureLockCheckVC class]]) {
                // 检查本控制器是否还在视图层级中
                if (!self.presentingViewController || !self.view.window) {
                    // 如果本控制器已经被移除了，需要重新 present
                    if (!currentTopVC.presentedViewController && !self.isVerifiedSuccess) {
                        NoaGestureLockCheckVC *vc = [NoaGestureLockCheckVC new];
                        vc.delegate = self.delegate;
                        vc.modalPresentationStyle = UIModalPresentationFullScreen;
                        vc.checkType = self.checkType;
                        [currentTopVC presentViewController:vc animated:NO completion:nil];
                    }
                }
            }
        });
    }
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
    _lblTitle.text = LanguageToolMatch(@"请绘制解锁图案");
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
    
    _btnCancel.hidden = _checkType == GestureLockCheckTypeNormal;
}
#pragma mark - 交互事件
- (void)btnCancelClick {
    // 只有在非普通验证模式下（修改或关闭）才允许取消
    if (_checkType != GestureLockCheckTypeNormal) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

// 重写 dismiss 方法，防止在普通验证模式下被意外关闭
- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    // 如果是普通验证模式且未验证成功，不允许关闭
    if (_checkType == GestureLockCheckTypeNormal && !_isVerifiedSuccess) {
        // 不允许关闭，直接返回
        if (completion) {
            completion();
        }
        return;
    }
    
    [super dismissViewControllerAnimated:flag completion:completion];
}
#pragma mark - ZGestureLockViewDelegate
- (void)gestureLockViewFinishWith:(NSMutableString *)gesturePassword {
    
    if (_checkNumber >= 5) return;
    
    if ([gesturePassword isEqualToString:_gesturePassword]) {
        //手势密码验证成功
        _isVerifiedSuccess = YES; // 标记验证成功，允许关闭
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:_gesturePassword forKey:@"password"];
        [dict setValue:@(0) forKey:@"checkNumber"];
        [dict setValue:@(0) forKey:@"checkAccountPassword"];
        NSString *userKey = [NSString stringWithFormat:@"%@-GesturePassword", UserManager.userInfo.userUID];
        [[MMKV defaultMMKV] setString:[dict mj_JSONString] forKey:userKey];
        
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        if (_delegate && [_delegate respondsToSelector:@selector(gestureLockCheckResultType:checkType:)]) {
            [_delegate gestureLockCheckResultType:GestureLockCheckResultTypeRight checkType:_checkType];
        }
    }else {
        
        //手势密码验证失败
        _checkNumber++;
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:_gesturePassword forKey:@"password"];
        [dict setValue:@(_checkNumber) forKey:@"checkNumber"];
        [dict setValue:@(0) forKey:@"checkAccountPassword"];
        NSString *userKey = [NSString stringWithFormat:@"%@-GesturePassword", UserManager.userInfo.userUID];
        [[MMKV defaultMMKV] setString:[dict mj_JSONString] forKey:userKey];
        
        
        if (_checkNumber >= 5) {
            [HUD showMessage:LanguageToolMatch(@"账户被锁定\n请输入账户密码")];
            
            if (_delegate && [_delegate respondsToSelector:@selector(gestureLockCheckResultType:checkType:)]) {
                [_delegate gestureLockCheckResultType:GestureLockCheckResultTypeLock checkType:_checkType];
            }
            
            NoaGestureLockCheckAccountPasswordView *viewCheckAccount = [NoaGestureLockCheckAccountPasswordView new];
            viewCheckAccount.delegate = self;
            [self.view addSubview:viewCheckAccount];
            
        }else {
            [HUD showMessage:LanguageToolMatch(@"密码错误")];
            if (_delegate && [_delegate respondsToSelector:@selector(gestureLockCheckResultType:checkType:)]) {
                [_delegate gestureLockCheckResultType:GestureLockCheckResultTypeError checkType:_checkType];
            }
        }
        
        
    }

}

#pragma mark - ZGestureLockCheckAccountPasswordDelegate
- (void)gestureLockCheckAccountPasswordSuccess {
    //手势密码验证成功
    _isVerifiedSuccess = YES; // 标记验证成功，允许关闭
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_gesturePassword forKey:@"password"];
    [dict setValue:@(0) forKey:@"checkNumber"];
    [dict setValue:@(0) forKey:@"checkAccountPassword"];
    NSString *userKey = [NSString stringWithFormat:@"%@-GesturePassword", UserManager.userInfo.userUID];
    [[MMKV defaultMMKV] setString:[dict mj_JSONString] forKey:userKey];
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (_delegate && [_delegate respondsToSelector:@selector(gestureLockCheckResultType:checkType:)]) {
        [_delegate gestureLockCheckResultType:GestureLockCheckResultTypeRight checkType:_checkType];
    }
}
- (void)gestureLockCheckAccountPasswordFail {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_gesturePassword forKey:@"password"];
    [dict setValue:@(0) forKey:@"checkNumber"];
    [dict setValue:@(0) forKey:@"checkAccountPassword"];
    NSString *userKey = [NSString stringWithFormat:@"%@-GesturePassword", UserManager.userInfo.userUID];
    [[MMKV defaultMMKV] setString:[dict mj_JSONString] forKey:userKey];
    
    
    //五次手势密码错误，5次账号密码错误，进行重新登录操作
    [ZTOOL setupLoginUI];
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
