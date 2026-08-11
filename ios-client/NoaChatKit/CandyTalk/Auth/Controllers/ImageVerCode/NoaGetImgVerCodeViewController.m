//
//  NoaGetImgVerCodeViewController.m
//  NoaChatKit
//
//  Created by phl on 2025/11/14.
//

#import "NoaGetImgVerCodeViewController.h"
// 高斯模糊view
#import "NoaGetImgVerCodeBlurView.h"
// 数据处理
#import "NoaGetImgVerCodeBlurDataHandle.h"

@interface NoaGetImgVerCodeViewController ()

@property (nonatomic, strong) UIView *shadowView;

// 重新声明 blurView 为子类类型，覆盖父类的声明
@property (nonatomic, strong, readwrite) NoaGetImgVerCodeBlurView *blurView;

/// 数据处理
@property (nonatomic, strong, readwrite) NoaGetImgVerCodeBlurDataHandle *dataHandle;

@end

@implementation NoaGetImgVerCodeViewController

// MARK: dealloc
- (void)dealloc {
    CIMLog(@"%@ dealloc", [self class]);
}

// MARK: set/get
- (NoaGetImgVerCodeBlurView *)blurView {
    if (!_blurView) {
        _blurView = [[NoaGetImgVerCodeBlurView alloc] initWithFrame:CGRectZero
                                                     IsPopWindows:YES
                                                       DataHandle:self.dataHandle];
    }
    return _blurView;
}

- (NoaGetImgVerCodeBlurDataHandle *)dataHandle {
    if (!_dataHandle) {
        _dataHandle = [[NoaGetImgVerCodeBlurDataHandle alloc] init];
        _dataHandle.account = self.account;
        _dataHandle.verCodeType = self.verCodeType;
        _dataHandle.imgVerCode = self.imgVerCode;
    }
    return _dataHandle;
}

- (UIView *)shadowView {
    if (!_shadowView) {
        _shadowView = [[UIView alloc] initWithFrame:CGRectZero];
        _shadowView.tkThemebackgroundColors = @[
            [COLOR_00 colorWithAlphaComponent:0.5],
            [COLOR_00 colorWithAlphaComponent:0.5]
        ];
    }
    return _shadowView;
}

- (void)viewDidLoad {
    // 在 super viewDidLoad 之前设置背景色，确保透明背景生效
    self.view.tkThemebackgroundColors = @[UIColor.clearColor, UIColor.clearColor];
    // 设置 preferredContentSize，用于中心弹出时的布局计算
    self.preferredContentSize = CGSizeMake(335, 264);
    [super viewDidLoad];
    [self setupImgVerCodeNavBar];
    [self setupImgVerCodeUI];
    [self processData];
}

- (void)setupImgVerCodeNavBar {
    self.navBtnBack.hidden = YES;
    self.navBtnRight.hidden = YES;
    self.navTitleLabel.hidden = YES;
    self.navLineView.hidden = YES;
    self.navView.tkThemebackgroundColors = @[UIColor.clearColor, UIColor.clearColor];
}

- (void)setupImgVerCodeUI {
    self.view.tkThemebackgroundColors = @[UIColor.clearColor, UIColor.clearColor];
    [self.view addSubview:self.shadowView];
    [self.shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.leading.trailing.bottom.equalTo(self.view);
    }];
    
    [self.view addSubview:self.blurView];
    [self.blurView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.equalTo(@335);
        make.height.equalTo(@264);
    }];
}

- (void)processData {
    @weakify(self)
    [self.dataHandle.dismissSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (self.cancelInputImgVerCodeBlock) {
            self.cancelInputImgVerCodeBlock();
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [self.dataHandle.configureFinishSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        NSString *input = x;
        if (self.configureImgVerCodeSuccessBlock) {
            self.configureImgVerCodeSuccessBlock(input);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
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
}

- (void)show {
    // 使用自定义转场实现全屏透明背景 + 内容居中弹出
    self.modalPresentationStyle = UIModalPresentationCustom;
    NoaCenterAlertTransitioningDelegate *transDelegate = [[NoaCenterAlertTransitioningDelegate alloc] init];
    self.transitioningDelegate = transDelegate;
    self.transDelegate = transDelegate;
    [CurrentVC presentViewController:self animated:YES completion:nil];
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
