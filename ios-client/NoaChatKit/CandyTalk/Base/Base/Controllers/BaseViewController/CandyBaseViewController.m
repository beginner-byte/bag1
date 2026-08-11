//
//  CandyBaseViewController.m
//  NoaKit
//
//  Created by Candy on 2026/8/30.
//

#import "CandyBaseViewController.h"

@interface CandyBaseViewController () <UIGestureRecognizerDelegate>

@end

@implementation CandyBaseViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //全局隐藏导系统的航栏，使用自定义的navbar
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.view bringSubviewToFront:self.navView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.tkThemebackgroundColors = @[COLOR_F8F9FB,COLOR_F8F9FB_DARK];
    //解决自定义返回，隐藏导航栏 侧滑返回的问题
    //self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    //自定义导航栏
    [self setupNavView];
}

#pragma mark - 自定义导航栏
- (void)setupNavView{
    _navView = [[UIView alloc] init];
    _navView.tkThemebackgroundColors = @[COLOR_CLEAR,COLOR_CLEAR];
    [self.view addSubview:_navView];
    [_navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.view);
        make.height.mas_equalTo(DNavStatusBarH);
    }];
    
  
    
    _navLineView = [[UIView alloc] initWithFrame:CGRectMake(0, DNavStatusBarH - 0.5, DScreenWidth, 0.8)];
    _navLineView.tkThemebackgroundColors = @[COLOR_E6E6E6, COLOR_E6E6E6_DARK];
    _navLineView.hidden = YES;
    [_navView addSubview:_navLineView];
    [_navLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(_navView);
        make.bottom.equalTo(_navView).offset(-DWScale(0.5));
        make.height.mas_equalTo(0.8);
    }];
    
    _navBtnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    _navBtnBack.adjustsImageWhenHighlighted = NO;
    _navBtnBack.exclusiveTouch = YES;
    [_navBtnBack setTkThemeImage:@[ImgNamed(@"icon_nav_back"), ImgNamed(@"icon_nav_back_dark")] forState:UIControlStateNormal];
    [_navBtnBack addTarget:self action:@selector(navBtnBackClicked) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:_navBtnBack];
    [_navBtnBack setEnlargeEdge:DWScale(10)];
    [_navBtnBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_navView).offset(DWScale(10));
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.top.equalTo(_navView).offset(DWScale(DStatusBarH + 7));
    }];
    
    _navBtnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    [_navBtnRight addTarget:self action:@selector(navBtnRightClicked) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:_navBtnRight];
    [_navBtnRight mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_navBtnBack);
        make.trailing.equalTo(_navView).offset(-15);
        make.height.mas_equalTo(30);
        make.width.mas_lessThanOrEqualTo(100);
    }];
    [_navBtnRight setEnlargeEdge:DWScale(10)];
    _navBtnRight.titleLabel.numberOfLines = 2;
    _navBtnRight.hidden = YES;
    
    _navTitleLabel = [[UILabel alloc] init];
    _navTitleLabel.textAlignment = NSTextAlignmentCenter;
    _navTitleLabel.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    
    _navTitleLabel.numberOfLines = 2;
    [_navView addSubview:_navTitleLabel];
    [_navTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(_navView);
        make.centerY.equalTo(_navBtnBack);
        make.bottom.equalTo(_navView);
        make.leading.equalTo(_navBtnBack.mas_trailing).offset(8);
    }];
    if([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"简体中文"] ||
       [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"繁體中文"] ){
        _navTitleLabel.font = FONTM(16);
        _navBtnRight.titleLabel.font = FONTM(14);
    }else{
        _navTitleLabel.font = FONTSB(14);
        _navBtnRight.titleLabel.font = FONTM(12);
    }
}
-(void)showAppVersion{
    UILabel *versionLab = [[UILabel alloc] init];
    versionLab.text = [NSString stringWithFormat:@"V%@ %@", [ZTOOL getCurretnVersion], [ZTOOL getBuildVersion]];
    versionLab.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    versionLab.font = FONTN(14);
    [self.view addSubview:versionLab];
    [versionLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-DHomeBarH);
        make.centerX.equalTo(self.view);
    }];
}
// 增加一个方法，只显示返回按钮，不显示导航栏、标题、rightBtn
- (void)onlyShowNavBackBtn {
    _navView.backgroundColor = COLOR_CLEAR;
    _navTitleLabel.hidden = YES;
    _navLineView.hidden = YES;
    _navBtnBack.hidden = NO;
    _navBtnRight.hidden = YES;
}

#pragma mark - title赋值
- (void)setNavTitleStr:(NSString *)navTitleStr {
    _navTitleStr = navTitleStr;
    _navTitleLabel.text = navTitleStr;
}

#pragma mark - 导航栏按钮交互事件
- (void)navBtnBackClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)navBtnRightClicked {
}
#pragma mark - 刷新数据
- (void)headerRefreshData {
    //子类实现
}
- (void)footerRefreshData {
    //子类实现
}
#pragma MARK - 默认列表布局约束
- (void)defaultTableViewUI {
    [self.view addSubview:self.baseTableView];
    [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-DHomeBarH);
        make.top.equalTo(self.navView.mas_bottom);
    }];
}
#pragma mark - 懒加载
- (UITableViewStyle)baseTableViewStyle {
    if (_baseTableViewStyle) {
        return _baseTableViewStyle;
    }
    return UITableViewStylePlain;
}
- (NoaBaseTableView *)baseTableView {
    if (!_baseTableView) {
        _baseTableView = [[NoaBaseTableView alloc] initWithFrame:CGRectZero style:_baseTableViewStyle];
    }
    return _baseTableView;
}
- (MJRefreshNormalHeader *)refreshHeader {
    if (!_refreshHeader) {
        WeakSelf
        _refreshHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [weakSelf headerRefreshData];
        }];
        
        _refreshHeader.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:14];
        _refreshHeader.lastUpdatedTimeLabel.hidden = YES;
        _refreshHeader.stateLabel.font = [UIFont systemFontOfSize:14];
        [_refreshHeader setTitle:LanguageToolMatch(@"下拉刷新") forState:MJRefreshStateIdle];
        [_refreshHeader setTitle:LanguageToolMatch(@"下拉刷新") forState:MJRefreshStatePulling];
        [_refreshHeader setTitle:LanguageToolMatch(@"正在加载...") forState:MJRefreshStateRefreshing];
        [_refreshHeader setTitle:LanguageToolMatch(@"正在加载...") forState:MJRefreshStateWillRefresh];
        
    }
    return _refreshHeader;
}
- (MJRefreshBackNormalFooter *)refreshFooter {
    if (!_refreshFooter) {
        WeakSelf
        _refreshFooter = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            [weakSelf footerRefreshData];
        }];
        _refreshFooter.stateLabel.font = [UIFont systemFontOfSize:14];
        [_refreshFooter setTitle:LanguageToolMatch(@"上拉加载更多") forState:MJRefreshStateIdle];
        [_refreshFooter setTitle:LanguageToolMatch(@"上拉加载更多") forState:MJRefreshStatePulling];
        [_refreshFooter setTitle:LanguageToolMatch(@"正在加载...") forState:MJRefreshStateRefreshing];
        [_refreshFooter setTitle:LanguageToolMatch(@"正在加载...") forState:MJRefreshStateWillRefresh];
        [_refreshFooter setTitle:LanguageToolMatch(@"我是有底线的") forState:MJRefreshStateNoMoreData];
    }
    return _refreshFooter;
}
#pragma mark - LiftCycle
- (void)dealloc{
    [self.view endEditing:YES];
}

@end
