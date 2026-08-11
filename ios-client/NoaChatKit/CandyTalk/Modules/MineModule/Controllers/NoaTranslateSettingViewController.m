//
//  NoaTranslateSettingViewController.m
//  NoaKit
//
//  Created by Candy on 2024/2/18.
//

#import "NoaTranslateSettingViewController.h"
#import "NoaSystemSettingCell.h"
#import "NoaCharacterManagerViewController.h"
#import "NoaChatKit-Swift.h"

@interface NoaTranslateSettingViewController ()<UITableViewDelegate, UITableViewDataSource, ZBaseCellDelegate>
@property (nonatomic, strong)NSArray *dataArr;
@end

@implementation NoaTranslateSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navTitleStr = LanguageToolMatch(@"翻译管理");
    [self setUpData];
    [self setupUI];
}

- (void)setUpData {
    self.dataArr = @[LanguageToolMatch(@"翻译设置默认值"), LanguageToolMatch(@"翻译账户信息")];
}

- (void)setupUI {
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    self.baseTableView.delegate = self;
    self.baseTableView.dataSource = self;
    self.baseTableView.bounces = NO;
    self.baseTableView.delaysContentTouches = NO;
    self.baseTableView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    [self.view addSubview:self.baseTableView];
    [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(DNavStatusBarH + 16);
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-DHomeBarH);
    }];
    
    [self.baseTableView registerClass:[NoaSystemSettingCell class] forCellReuseIdentifier:NSStringFromClass([NoaSystemSettingCell class])];
}

#pragma mark - UITableViewDelegate  UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DWScale(54);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaSystemSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NoaSystemSettingCell class]) forIndexPath:indexPath];
    cell.baseCellIndexPath = indexPath;
    cell.baseDelegate = self;
    cell.leftTitleStr = (NSString *)[self.dataArr objectAtIndex:indexPath.row];
    [cell configCellRoundWithCellIndex:indexPath.row totalIndex:self.dataArr.count];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Action
- (void)cellClickAction:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        //内容翻译
        CoHereTranslateSetDefaultViewController *vc = [[CoHereTranslateSetDefaultViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        //字符管理
        NoaCharacterManagerViewController *vc = [[NoaCharacterManagerViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
