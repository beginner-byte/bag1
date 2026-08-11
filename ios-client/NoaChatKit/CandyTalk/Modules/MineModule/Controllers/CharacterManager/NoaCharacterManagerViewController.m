//
//  NoaCharacterManagerViewController.m
//  NoaKit
//
//  Created by Apple on 2023/9/12.
//

#import "NoaCharacterManagerViewController.h"
#import "NoaCharacterRegisterViewController.h"//注册账户
#import "NoaCharacterBindViewController.h"//绑定账户
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface NoaCharacterManagerViewController ()
//未绑定
@property (nonatomic, strong) UIView *unBindBackView;

//已绑定
@property (nonatomic, strong) UIView *bindedBackView;
@property (nonatomic, strong) UILabel *nameContentLbl;
@property (nonatomic, strong) UILabel *accountTypeContentLbl;
@property (nonatomic, strong) UILabel *usedChartContentLbl;
@property (nonatomic, strong) UILabel *remainChartContentLbl;

@end

@implementation NoaCharacterManagerViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    self.navTitleStr = LanguageToolMatch(@"翻译管理");
    //初始化UI
    [self setupBindedUI];
    [self setupUnBindUI];
    [self addNotification];

    self.unBindBackView.hidden = YES;
    self.bindedBackView.hidden = YES;
    //获取绑定的阅译账号信息
    [self requestGetCharacterManagerInfo];
}

#pragma mark - UI
- (void)setupUnBindUI {
    [self.view addSubview:self.unBindBackView];
    [self.unBindBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UIImageView * characterImageView = [[UIImageView alloc] init];
    characterImageView.image = ImgNamed(@"character_user");
    [self.unBindBackView addSubview:characterImageView];
    [characterImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.unBindBackView);
        make.top.mas_equalTo(self.unBindBackView.mas_top).offset(DNavStatusBarH + DWScale(77));
        make.width.height.mas_equalTo(DWScale(124));
    }];
    
    UILabel * tipLabel = [[UILabel alloc] init];
    tipLabel.text = LanguageToolMatch(@"您还未绑定翻译账户，请完成绑定");
    tipLabel.font = FONTR(16);
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.numberOfLines = 0;
    tipLabel.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [self.unBindBackView addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.unBindBackView);
        make.trailing.mas_equalTo(self.unBindBackView);
        make.top.mas_equalTo(characterImageView.mas_bottom).offset(DWScale(20));
    }];
    
    UIButton *registerBtn = [[UIButton alloc] init];
    [registerBtn setTitle:LanguageToolMatch(@"注册账户") forState:UIControlStateNormal];
    [registerBtn setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
    registerBtn.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    registerBtn.titleLabel.font = FONTN(16);
    [registerBtn rounded:DWScale(14)];
    [registerBtn addTarget:self action:@selector(charactersManagetRegisterAction) forControlEvents:UIControlEventTouchUpInside];
    [self.unBindBackView addSubview:registerBtn];
    [registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.unBindBackView.mas_centerX).offset(-DWScale(5));
        make.top.mas_equalTo(tipLabel.mas_bottom).offset(DWScale(20));
        make.size.mas_equalTo(CGSizeMake(DWScale(124), DWScale(50)));
    }];
    
    UIButton *bindingBtn = [[UIButton alloc] init];
    [bindingBtn setTitle:LanguageToolMatch(@"绑定账户") forState:UIControlStateNormal];
    [bindingBtn setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
    bindingBtn.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    bindingBtn.titleLabel.font = FONTN(16);
    [bindingBtn rounded:DWScale(14)];
    [bindingBtn addTarget:self action:@selector(charactersManagetBindingAction) forControlEvents:UIControlEventTouchUpInside];
    [self.unBindBackView addSubview:bindingBtn];
    [bindingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.unBindBackView.mas_centerX).offset(DWScale(5));
        make.top.mas_equalTo(tipLabel.mas_bottom).offset(DWScale(20));
        make.size.mas_equalTo(CGSizeMake(DWScale(124), DWScale(50)));
    }];
}

- (void)setupBindedUI {
    [self.view addSubview:self.bindedBackView];
    [self.bindedBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UIView *accountBackView = [[UIView alloc] init];
    accountBackView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    [self.bindedBackView addSubview:accountBackView];
    [accountBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.bindedBackView);
        make.top.equalTo(self.bindedBackView).offset(DNavStatusBarH+DWScale(16));
        make.height.mas_equalTo(DWScale(195));
    }];
    
    //阅译账户信息
    UILabel *accountBackTitleLbl = [UILabel new];
    accountBackTitleLbl.text = LanguageToolMatch(@"翻译账户信息");
    accountBackTitleLbl.font = FONTB(16);
    accountBackTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [accountBackView addSubview:accountBackTitleLbl];
    [accountBackTitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(accountBackView).offset(DWScale(20));
        make.top.equalTo(accountBackView).offset(DWScale(10));
        make.width.mas_equalTo(DWScale(100));
        make.height.mas_equalTo(DWScale(24));
    }];
    
    //换绑
    UIButton *changeBindBtn = [[UIButton alloc] init];
    [changeBindBtn setTitle:LanguageToolMatch(@"换绑") forState:UIControlStateNormal];
    [changeBindBtn setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateNormal];
    changeBindBtn.titleLabel.font = FONTN(12);
    changeBindBtn.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
    [changeBindBtn rounded:DWScale(6) width:1 color:COLOR_5966F2];
    [changeBindBtn addTarget:self action:@selector(changeBindAction) forControlEvents:UIControlEventTouchUpInside];
    [accountBackView addSubview:changeBindBtn];
    [changeBindBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(accountBackTitleLbl.mas_trailing).offset(DWScale(20));
        make.centerY.equalTo(accountBackTitleLbl);
        make.width.mas_equalTo(DWScale(56));
        make.height.mas_equalTo(DWScale(28));
    }];
    
    //增加字符
    UIButton *addChartBtn = [[UIButton alloc] init];
    [addChartBtn setTitle:LanguageToolMatch(@"增加字符") forState:UIControlStateNormal];
    [addChartBtn setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
    addChartBtn.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    [addChartBtn rounded:DWScale(6)];
    addChartBtn.titleLabel.font = FONTN(12);
    [addChartBtn addTarget:self action:@selector(addChartAction) forControlEvents:UIControlEventTouchUpInside];
    [accountBackView addSubview:addChartBtn];
    [addChartBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(changeBindBtn.mas_trailing).offset(DWScale(10));
        make.centerY.equalTo(accountBackTitleLbl);
        make.width.mas_equalTo(DWScale(80));
        make.height.mas_equalTo(DWScale(28));
    }];
    
    //用户名称title
    UILabel *nameTitleLab = [UILabel new];
    nameTitleLab.text = LanguageToolMatch(@"用户名称：");
    nameTitleLab.font = FONTN(14);
    nameTitleLab.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [accountBackView addSubview:nameTitleLab];
    [nameTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(accountBackView).offset(DWScale(20));
        make.top.equalTo(accountBackTitleLbl.mas_bottom).offset(DWScale(16));
        make.width.mas_equalTo(DWScale(75));
        make.height.mas_equalTo(DWScale(20));
    }];
    
    //用户名称content
    _nameContentLbl = [UILabel new];
    _nameContentLbl.text = @"--";
    _nameContentLbl.font = FONTN(14);
    _nameContentLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [accountBackView addSubview:_nameContentLbl];
    [_nameContentLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(nameTitleLab.mas_trailing);
        make.trailing.equalTo(accountBackView).offset(-DWScale(20));
        make.centerY.equalTo(nameTitleLab);
        make.height.mas_equalTo(DWScale(20));
    }];
    
    //账号类型title
    UILabel *accountTypeTitleLab = [UILabel new];
    accountTypeTitleLab.text = LanguageToolMatch(@"账号类型：");
    accountTypeTitleLab.font = FONTN(14);
    accountTypeTitleLab.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [accountBackView addSubview:accountTypeTitleLab];
    [accountTypeTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(accountBackView).offset(DWScale(20));
        make.top.equalTo(nameTitleLab.mas_bottom).offset(DWScale(10));
        make.width.mas_equalTo(DWScale(75));
        make.height.mas_equalTo(DWScale(20));
    }];
    
    //账号类型content
    _accountTypeContentLbl = [UILabel new];
    _accountTypeContentLbl.text = LanguageToolMatch(@"普通账号");
    _accountTypeContentLbl.font = FONTN(14);
    _accountTypeContentLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [accountBackView addSubview:_accountTypeContentLbl];
    [_accountTypeContentLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(accountTypeTitleLab.mas_trailing);
        make.trailing.equalTo(accountBackView).offset(-DWScale(20));
        make.centerY.equalTo(accountTypeTitleLab);
        make.height.mas_equalTo(DWScale(20));
    }];
    
    //已用字符BackImgView
    UIImageView *usedCharBackView = [[UIImageView alloc] init];
    usedCharBackView.image = ImgNamed(@"img_char_used_back");
    [accountBackView addSubview:usedCharBackView];
    [usedCharBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(accountBackView).offset(DWScale(20));
        make.top.equalTo(accountTypeTitleLab.mas_bottom).offset(DWScale(14));
        make.width.mas_equalTo(DWScale(157));
        make.height.mas_equalTo(DWScale(69));
    }];
    
    //已用字符title
    UILabel *usedChartTitleLbl = [UILabel new];
    usedChartTitleLbl.text = LanguageToolMatch(@"已用字符");
    usedChartTitleLbl.font = FONTN(14);
    usedChartTitleLbl.textAlignment = NSTextAlignmentCenter;
    usedChartTitleLbl.tkThemetextColors = @[COLORWHITE, COLOR_11];
    [usedCharBackView addSubview:usedChartTitleLbl];
    [usedChartTitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(usedCharBackView).offset(DWScale(15));
        make.trailing.equalTo(usedCharBackView).offset(-DWScale(15));
        make.top.equalTo(usedCharBackView).offset(DWScale(9));
        make.height.mas_equalTo(DWScale(20));
    }];
    
    //已用字符content
    _usedChartContentLbl = [UILabel new];
    _usedChartContentLbl.text = @"0";
    _usedChartContentLbl.font = FONTB(20);
    _usedChartContentLbl.textAlignment = NSTextAlignmentCenter;
    _usedChartContentLbl.tkThemetextColors = @[COLORWHITE, COLOR_11];
    [usedCharBackView addSubview:_usedChartContentLbl];
    [_usedChartContentLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(usedCharBackView).offset(DWScale(10));
        make.trailing.equalTo(usedCharBackView).offset(-DWScale(10));
        make.top.equalTo(usedChartTitleLbl.mas_bottom).offset(DWScale(4));
        make.height.mas_equalTo(DWScale(28));
    }];
    
    //剩余字符BackImgView
    UIImageView *remainCharBackView = [[UIImageView alloc] init];
    remainCharBackView.image = ImgNamed(@"img_char_remain_back");
    [accountBackView addSubview:remainCharBackView];
    [remainCharBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(accountBackView).offset(-DWScale(20));
        make.top.equalTo(accountTypeTitleLab.mas_bottom).offset(DWScale(14));
        make.width.mas_equalTo(DWScale(157));
        make.height.mas_equalTo(DWScale(69));
    }];
    
    //已用字符title
    UILabel *remainChartTitleLbl = [UILabel new];
    remainChartTitleLbl.text = LanguageToolMatch(@"剩余字符");
    remainChartTitleLbl.font = FONTN(14);
    remainChartTitleLbl.textAlignment = NSTextAlignmentCenter;
    remainChartTitleLbl.tkThemetextColors = @[COLORWHITE, COLOR_11];
    [remainCharBackView addSubview:remainChartTitleLbl];
    [remainChartTitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(remainCharBackView).offset(DWScale(15));
        make.trailing.equalTo(remainCharBackView).offset(-DWScale(15));
        make.top.equalTo(remainCharBackView).offset(DWScale(9));
        make.height.mas_equalTo(DWScale(20));
    }];
    
    //已用字符content
    _remainChartContentLbl = [UILabel new];
    _remainChartContentLbl.text = @"0";
    _remainChartContentLbl.font = FONTB(20);
    _remainChartContentLbl.textAlignment = NSTextAlignmentCenter;
    _remainChartContentLbl.tkThemetextColors = @[COLORWHITE, COLOR_11];
    [remainCharBackView addSubview:_remainChartContentLbl];
    [_remainChartContentLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(remainCharBackView).offset(DWScale(10));
        make.trailing.equalTo(remainCharBackView).offset(-DWScale(10));
        make.top.equalTo(remainChartTitleLbl.mas_bottom).offset(DWScale(4));
        make.height.mas_equalTo(DWScale(28));
    }];
}

#pragma mark - 添加Notification
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCharacterManagerInfo) name:@"NSNotificationReloadCharacterManagerInfo" object:nil];
}

#pragma mark - Setter
- (void)setIsBinded:(BOOL)isBinded {
    _isBinded = isBinded;
    if (_isBinded) {
        self.unBindBackView.hidden = YES;
        self.bindedBackView.hidden = NO;
    } else {
        self.unBindBackView.hidden = NO;
        self.bindedBackView.hidden = YES;
    }
}

#pragma mark - Request
- (void)requestGetCharacterManagerInfo {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    
    WeakSelf
    [HUD showActivityMessage:@""];
    [IMSDKManager imSdkTranslateGetYuueeAccountInfo:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD hideHUD];
        weakSelf.isBinded = YES;
        NSDictionary *dataDic = [NSString jsonStringToDic:(NSString *)data];
        NSString *nameStr = (NSString *)[dataDic objectForKeySafe:@"username"];
        NSString *accountTypeStr = [weakSelf transitionAccountTypeWithGrade:[[dataDic objectForKeySafe:@"grade"] integerValue]];
        NSInteger termUsedStr = [[dataDic objectForKeySafe:@"term_used"] integerValue];
        NSInteger termStr = [[dataDic objectForKeySafe:@"term"] integerValue];
        //UI赋值
        weakSelf.nameContentLbl.text = nameStr;
        weakSelf.accountTypeContentLbl.text = accountTypeStr;
        weakSelf.usedChartContentLbl.text = [NSString stringWithFormat:@"%ld", (long)termUsedStr];
        weakSelf.remainChartContentLbl.text = [NSString stringWithFormat:@"%ld", (long)termStr];
        //将yuuee账号存储到本地
        NoaUserModel *userModel = [NoaUserModel getUserInfo];
        userModel.yuueeAccount = nameStr;
        [userModel saveUserInfo];
        [UserManager setUserInfo:userModel];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD hideHUD];
        if (code == Translate_yuuee_unbind_error_code) {
            weakSelf.isBinded = NO;
        } else {
            weakSelf.isBinded = NO;
            [HUD showMessageWithCode:code errorMsg:msg];
        }
    }];
}

#pragma NSNotification
- (void)reloadCharacterManagerInfo {
    //重新请求info
    [self requestGetCharacterManagerInfo];
}

#pragma mark - Action
//未绑定Action
- (void)charactersManagetRegisterAction {
    //注册账户
    NoaCharacterRegisterViewController *vc = [[NoaCharacterRegisterViewController alloc] init];
    vc.isBinded = NO;
    vc.isFromBind = NO;
    [self.navigationController pushViewController:vc animated:YES];
    WeakSelf
    [vc setChartManageBindResult:^(BOOL result) {
        weakSelf.isBinded = YES;
        //重新请求info
        [weakSelf requestGetCharacterManagerInfo];
    }];
}

- (void)charactersManagetBindingAction {
    //绑定账户
    NoaCharacterBindViewController *vc = [[NoaCharacterBindViewController alloc] init];
    vc.isBinded = NO;
    [self.navigationController pushViewController:vc animated:YES];
    WeakSelf
    [vc setChartManageBindResult:^(BOOL result) {
        weakSelf.isBinded = YES;
        //重新请求info
        [weakSelf requestGetCharacterManagerInfo];
    }];
}

/// 已绑定Action
//换绑
- (void)changeBindAction {
    NoaCharacterBindViewController *vc = [[NoaCharacterBindViewController alloc] init];
    vc.isBinded = YES;
    vc.account = self.nameContentLbl.text;
    [self.navigationController pushViewController:vc animated:YES];
    WeakSelf
    [vc setChartManageBindResult:^(BOOL result) {
        weakSelf.isBinded = YES;
        //重新请求info
        [weakSelf requestGetCharacterManagerInfo];
    }];
}

//增加字符
- (void)addChartAction {
    [HUD showMessage:LanguageToolMatch(@"请联系客服")];
}

#pragma mark - Tools
- (NSString *)transitionAccountTypeWithGrade:(NSInteger)grade {
    switch (grade) {
        case 1:
            return LanguageToolMatch(@"普通账号");
            break;
        case 2:
            return LanguageToolMatch(@"企业账号");
            break;
        case 3:
            return LanguageToolMatch(@"企业子账号");
            break;
            
        default:
            return LanguageToolMatch(@"未知");;
            break;
    }
}

#pragma mark - Lazy
- (UIView *)unBindBackView {
    if (!_unBindBackView) {
        _unBindBackView = [UIView new];
        _unBindBackView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    }
    return _unBindBackView;
}

- (UIView *)bindedBackView {
    if (!_bindedBackView) {
        _bindedBackView = [UIView new];
        _bindedBackView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    }
    return _bindedBackView;
}

#pragma mark - Other
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
