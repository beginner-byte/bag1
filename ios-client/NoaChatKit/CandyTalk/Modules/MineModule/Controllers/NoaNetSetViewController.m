//
//  NoaNetSetViewController.m
//  NoaKit
//
//  Created by 小梦雯 on 2025/4/16.
//

#import "NoaNetSetViewController.h"
#import "NoaProxySettings.h"
#import "NoaCustomProxyTableViewCell.h"
#import "NoaProxyInputView.h"


@interface NoaNetSetViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, assign) ProxyType currentType;
@end

@implementation NoaNetSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentType = [[MMKV defaultMMKV] getInt32ForKey:PROXY_CURRENT_TYPE];
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    self.navTitleStr = LanguageToolMatch(@"网络设置");
    [self setUpNavUI];
    [self setupUI];
    [self.baseTableView reloadData];
    
}
- (void)setUpNavUI {
    self.navBtnRight.hidden = NO;
    [self.navBtnRight setTitle:LanguageToolMatch(@"完成") forState:UIControlStateNormal];
    [self.navBtnRight setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
    self.navBtnRight.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2];
    [self.navBtnRight rounded:DWScale(12)];
    [self.navBtnRight mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.navTitleLabel);
        make.trailing.equalTo(self.navView).offset(-DWScale(20));
        make.height.mas_equalTo(DWScale(32));
        make.width.mas_equalTo(DWScale(60));
    }];
    
    self.navBtnBack.hidden = YES;
    
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancleBtn setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    [cancleBtn setTkThemeTitleColor:@[COLOR_11, COLORWHITE] forState:UIControlStateNormal];
    cancleBtn.titleLabel.font = FONTR(16);
    [cancleBtn addTarget:self action:@selector(cancleBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navView addSubview:cancleBtn];
    [cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.navView.mas_leading).offset(DWScale(22));
        make.centerY.equalTo(self.navBtnRight);
        make.height.mas_equalTo(DWScale(30));
    }];
    [cancleBtn setEnlargeEdge:DWScale(10)];
    
    [self.navTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.navBtnBack);
        make.bottom.equalTo(self.navView);
        make.leading.equalTo(cancleBtn.mas_trailing).offset(8);
    }];
}

- (void)setupUI {
    self.baseTableView.delegate = self;
    self.baseTableView.dataSource = self;
    self.baseTableView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    [self.view addSubview:self.baseTableView];
    [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(DNavStatusBarH + DWScale(12));
        make.leading.equalTo(self.view).offset(DWScale(16));
        make.trailing.equalTo(self.view).offset(DWScale(-16));
        make.height.mas_equalTo(DWScale(52 * 3));
    }];
    
    [self.baseTableView rounded:DWScale(14)];
    self.baseTableView.bounces = NO;
    
    [self.baseTableView registerClass:[NoaCustomProxyTableViewCell class] forCellReuseIdentifier:NSStringFromClass([NoaCustomProxyTableViewCell class])];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaCustomProxyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NoaCustomProxyTableViewCell class]) forIndexPath:indexPath];
    
    NSString *title = @"";
    BOOL isSelected = NO;
    BOOL showArrow = NO;
    BOOL showLine =  NO;
    switch (indexPath.row) {
        case ProxyTypeSystem:
            title = LanguageToolMatch(@"使用系统代理");
            isSelected = (self.currentType == ProxyTypeSystem);
            showArrow = NO; // 系统代理永远不显示箭头
            showLine = YES;
            break;
        case ProxyTypeHTTP:
            title = LanguageToolMatch(@"使用HTTP代理");
            isSelected = (self.currentType== ProxyTypeHTTP);
            showArrow = YES; // 未选中时显示箭头
            showLine = YES;
            break;
        case ProxyTypeSOCKS5:
            title = @"SOCKS5";
            isSelected = (self.currentType == ProxyTypeSOCKS5);
            showArrow = YES; // 未选中时显示箭头
            showLine = NO;
            break;
    }
    [cell configureWithTitle:title isSelected:isSelected showArrow:showArrow showLine:showLine];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DWScale(52);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ProxyType selectedType = indexPath.row;
    self.currentType = selectedType;
    if (selectedType == ProxyTypeSystem) {
        
    } else {
        // HTTP/SOCKS5：弹出输入框（无论是否已选中）
        NoaProxyInputView *input = [NoaProxyInputView new];
        input.currentType = selectedType;
        [input show];
        [input setCancleCallback:^{
            self.currentType = [[MMKV defaultMMKV] getInt32ForKey:PROXY_CURRENT_TYPE];
            [self.baseTableView reloadData];
        }];
    }
    [self.baseTableView reloadData];
}

- (void)cancleBtnClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Action
- (void)navBtnRightClicked {
    [[MMKV defaultMMKV] setInt32:self.currentType forKey:PROXY_CURRENT_TYPE];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
