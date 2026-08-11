//
//  NoaCompanyConfigSetVC.m
//  NoaKit
//
//  Created by Candy on 2023/6/25.
//

#import "NoaCompanyConfigSetVC.h"
#import "NoaTitleContentArrowCell.h"
#import "NoaChatKit-Swift.h"//多语言

@interface NoaCompanyConfigSetVC () <UITableViewDelegate, UITableViewDataSource, ZBaseCellDelegate>
@property (nonatomic, strong) NSArray *setList;
@end

@implementation NoaCompanyConfigSetVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navTitleStr = LanguageToolMatch(@"设置");
    _setList = @[LanguageToolMatch(@"语言"), LanguageToolMatch(@"关于我们")];
    
    [self setupUI];
}

#pragma mark - 界面布局
- (void)setupUI {
    self.baseTableView.delegate = self;
    self.baseTableView.dataSource = self;
    self.baseTableView.bounces = NO;
    self.baseTableView.delaysContentTouches = NO;
    self.baseTableView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    [self.view addSubview:self.baseTableView];
    [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(DNavStatusBarH);
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-DHomeBarH);
    }];
    
    [self.baseTableView registerClass:[NoaTitleContentArrowCell class] forCellReuseIdentifier:NSStringFromClass([NoaTitleContentArrowCell class])];
}

#pragma mark - UITableViewDelegate  UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _setList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaTitleContentArrowCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NoaTitleContentArrowCell class]) forIndexPath:indexPath];
    cell.lblTitle.text = [_setList objectAtIndexSafe:indexPath.row];
    cell.lblTitle.font = FONTR(14);
    cell.baseCellIndexPath = indexPath;
    cell.baseDelegate = self;
    cell.viewLine.hidden = indexPath.row == 0 ? NO : YES;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DWScale(52);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return DWScale(16);
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DWScale(16))];
    headerView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

#pragma mark - ZBaseCellDelegate
- (void)cellClickAction:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        //多语言
        CoHereLanguageSettingViewController *languageSetVC = [[CoHereLanguageSettingViewController alloc] init];
        languageSetVC.changeType = CoHereLanguageChangeUITypeLogin;
        [self.navigationController pushViewController:languageSetVC animated:YES];
    }else if (indexPath.row == 1) {
        //关于我们
        CoHereAboutUsViewController *aboutUsVC = [[CoHereAboutUsViewController alloc] init];
        [self.navigationController pushViewController:aboutUsVC animated:YES];
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
