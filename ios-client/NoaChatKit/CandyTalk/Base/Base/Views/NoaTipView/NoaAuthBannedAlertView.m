//
//  NoaAuthBannedAlertView.m
//  NoaKit
//
//  Created by Candy on 2023/12/28.
//

#import "NoaAuthBannedAlertView.h"

@interface NoaAuthBannedAlertView()

@property (nonatomic, assign) ZAuthBannedAlertType alertType;
@property (nonatomic, strong) UIView *viewBg;
@property (nonatomic, strong) UIWindow *alertWindow; // 高层级窗口，确保提示框始终在最上层
@property (nonatomic, assign) BOOL isDismissing; // 标记是否正在关闭，防止重复关闭

@end

@implementation NoaAuthBannedAlertView
// 静态变量，用于跟踪当前显示的提示框，防止重复创建
static NoaAuthBannedAlertView *_currentAlertView = nil;


- (instancetype)initWithAlertType:(ZAuthBannedAlertType)alertType {
    self = [super init];
    if (self) {
        _alertType = alertType;
        _isDismissing = NO;
        // 如果已有提示框在显示，先关闭它
        if (_currentAlertView && _currentAlertView != self) {
            [_currentAlertView alertTipViewDismiss];
        }
        _currentAlertView = self;

        [self setupUI];
    }
    return self;
}

#pragma mark - 界面布局
- (void)setupUI {
    // 创建高层级窗口，确保提示框始终显示在最上层，不会被其他页面遮盖
    self.alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.alertWindow.windowLevel = UIWindowLevelAlert;
    self.alertWindow.backgroundColor = [UIColor clearColor];
    
    // iOS 13+ 支持 Scene
    if (@available(iOS 13.0, *)) {
        NSArray *scenes = [[[UIApplication sharedApplication] connectedScenes] allObjects];
        if (scenes.count > 0) {
            UIWindowScene *windowScene = (UIWindowScene *)scenes.firstObject;
            if (windowScene) {
                self.alertWindow.windowScene = windowScene;
            }
        }
    }
    
    self.alertWindow.hidden = NO;
    
    // 创建根视图控制器
    UIViewController *rootVC = [[UIViewController alloc] init];
    rootVC.view.backgroundColor = [UIColor clearColor];
    self.alertWindow.rootViewController = rootVC;

    self.frame = CGRectMake(0, 0, DScreenWidth, DScreenHeight);
    self.tkThemebackgroundColors = @[[COLOR_00 colorWithAlphaComponent:0.3],[COLOR_00 colorWithAlphaComponent:0.6]];
    [rootVC.view addSubview:self];

    _viewBg = [UIView new];
    _viewBg.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    _viewBg.layer.cornerRadius = DWScale(8);
    _viewBg.layer.masksToBounds = YES;
    _viewBg.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN, CGFLOAT_MIN);
    [self addSubview:_viewBg];
    
    //标题
    _lblTitle = [UILabel new];
    _lblTitle.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _lblTitle.font = FONTR(16);
    _lblTitle.numberOfLines = 1;
    _lblTitle.preferredMaxLayoutWidth = DWScale(255);
    _lblTitle.textAlignment = NSTextAlignmentCenter;
    [_viewBg addSubview:_lblTitle];
    [_lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_viewBg);
        make.top.equalTo(_viewBg).offset(DWScale(26));
        make.height.mas_equalTo(DWScale(22));
    }];
    
    //内容
    _lblContent = [UILabel new];
    _lblContent.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    _lblContent.font = FONTR(14);
    _lblContent.numberOfLines = 3;
    _lblContent.userInteractionEnabled = YES;
    _lblContent.backgroundColor = COLOR_CLEAR;
    _lblContent.preferredMaxLayoutWidth = DWScale(255);
    _lblContent.textAlignment = [ZTOOL RTLTextAlignment:NSTextAlignmentCenter];
    [_lblContent sizeToFit];
    [_viewBg addSubview:_lblContent];
    [_lblContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_viewBg);
        make.top.equalTo(_lblTitle.mas_bottom).offset(DWScale(16));
    }];
    
    //横线
    UIView *transverseLine = [[UIView alloc] init];
    transverseLine.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F6F6F6_DARK];
    [_viewBg addSubview:transverseLine];
    [transverseLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lblContent.mas_bottom).offset(DWScale(26));
        make.leading.trailing.equalTo(_viewBg);
        make.height.mas_equalTo(0.5);
    }];
    
    if (_alertType == ZAuthBannedAlertTypeTwoBtn) {
        //竖线
        UIView *verticalLine = [[UIView alloc] init];
        verticalLine.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F6F6F6_DARK];
        [_viewBg addSubview:verticalLine];
        [verticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(transverseLine.mas_bottom);
            make.bottom.equalTo(_viewBg);
            make.centerX.equalTo(_viewBg);
            make.width.mas_equalTo(0.5);
        }];
        
        //退出登录
        _btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnCancel setTitle:LanguageToolMatch(@"退出登录") forState:UIControlStateNormal];
        [_btnCancel setTkThemeTitleColor:@[COLOR_11, COLOR_11_DARK] forState:UIControlStateNormal];
        [_btnCancel setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateSelected];
        [_btnCancel setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateHighlighted];
        _btnCancel.titleLabel.font = FONTN(12);
        _btnCancel.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        [_btnCancel addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_viewBg addSubview:_btnCancel];
        [_btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_viewBg);
            make.top.equalTo(transverseLine.mas_bottom);
            make.trailing.equalTo(verticalLine.mas_leading);
            make.height.mas_equalTo(DWScale(48));
            make.bottom.equalTo(_viewBg);
        }];
        
        //申请解封
        _btnSure = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnSure setTitle:LanguageToolMatch(@"申请解封") forState:UIControlStateNormal];
        [_btnSure setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateNormal];
        [_btnSure setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateSelected];
        [_btnSure setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateHighlighted];
        _btnSure.titleLabel.font = FONTN(12);
        _btnSure.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        [_btnSure addTarget:self action:@selector(sureBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_viewBg addSubview:_btnSure];
        [_btnSure mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(verticalLine.mas_trailing);
            make.top.equalTo(transverseLine.mas_bottom);
            make.trailing.equalTo(_viewBg);
            make.height.mas_equalTo(DWScale(48));
            make.bottom.equalTo(_viewBg);
        }];
        
        [_viewBg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.mas_equalTo(DWScale(295));
            make.top.equalTo(_lblTitle.mas_top).offset(-DWScale(26));
            make.bottom.equalTo(_btnCancel.mas_bottom);
        }];
    } else {
        //取消按钮
        _btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnCancel setTitle:LanguageToolMatch(@"退出登录") forState:UIControlStateNormal];
        [_btnCancel setTkThemeTitleColor:@[COLOR_11, COLOR_11_DARK] forState:UIControlStateNormal];
        [_btnCancel setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateSelected];
        [_btnCancel setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateHighlighted];
        _btnCancel.titleLabel.font = FONTN(12);
        _btnCancel.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        [_btnCancel addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_viewBg addSubview:_btnCancel];
        [_btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(_viewBg);
            make.top.equalTo(transverseLine.mas_bottom);
            make.height.mas_equalTo(DWScale(48));
            make.bottom.equalTo(_viewBg);
        }];
        
        [_viewBg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.mas_equalTo(DWScale(295));
            make.top.equalTo(_lblTitle.mas_top).offset(-DWScale(26));
            make.bottom.equalTo(_btnCancel.mas_bottom);
        }];
    }
}

#pragma mark - 交互事件
- (void)alertTipViewSHow {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewBg.transform = CGAffineTransformIdentity;
    }];
}
- (void)alertTipViewDismiss {
    // 防止重复调用
    if (self.isDismissing) {
        return;
    }
    self.isDismissing = YES;
    
    // 立即禁用所有按钮，防止重复点击
    self.btnCancel.enabled = NO;
    if (self.btnSure) {
        self.btnSure.enabled = NO;
    }

    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewBg.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN, CGFLOAT_MIN);
    } completion:^(BOOL finished) {
        [weakSelf.viewBg removeFromSuperview];
        weakSelf.viewBg = nil;
        [weakSelf removeFromSuperview];
        // 隐藏并释放高层级窗口
        if (weakSelf.alertWindow) {
            weakSelf.alertWindow.hidden = YES;
            weakSelf.alertWindow.rootViewController = nil;
            weakSelf.alertWindow = nil;
        }
        // 清除静态引用
        if (_currentAlertView == weakSelf) {
            _currentAlertView = nil;
        }

    }];
}

- (void)sureBtnAction {
    // 防止重复点击
    if (self.isDismissing) {
        return;

    }
    // 保存 block，因为 dismiss 后可能会被清理
    void(^sureBlock)(void) = self.sureBtnBlock;
    // 先关闭提示框，再执行 block（避免 block 中可能创建新的提示框导致叠加）

    [self alertTipViewDismiss];
    // 延迟执行 block，确保提示框先关闭
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (sureBlock) {
            sureBlock();
        }
    });

}

- (void)cancelBtnAction {
    // 防止重复点击
    if (self.isDismissing) {
        return;

    }
    // 保存 block，因为 dismiss 后可能会被清理
    void(^cancelBlock)(void) = self.cancelBtnBlock;
    // 先关闭提示框，再执行 block（避免 block 中可能创建新的提示框导致叠加）

    [self alertTipViewDismiss];
    // 延迟执行 block，确保提示框先关闭
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (cancelBlock) {
            cancelBlock();
        }
    });

}


@end
