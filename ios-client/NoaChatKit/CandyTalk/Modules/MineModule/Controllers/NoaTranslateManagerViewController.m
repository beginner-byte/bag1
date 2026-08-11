//
//  NoaTranslateManagerViewController.m
//  NoaKit
//
//  Created by Candy on 2023/9/26.
//

#import "NoaTranslateManagerViewController.h"
//#import "ZContentTranslateViewController.h"//内容翻译
#import "NoaCharacterManagerViewController.h"//字符管理
#import "NoaTranslateManagerCell.h"

@interface NoaTranslateManagerViewController () <UITableViewDelegate, UITableViewDataSource, ZBaseCellDelegate>

@property (nonatomic, strong) NSArray *dataArr;

@end

@implementation NoaTranslateManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navTitleStr = LanguageToolMatch(@"翻译管理");
    [self setUpData];
    [self setupUI];
}

- (void)setUpData {
    self.dataArr = @[LanguageToolMatch(@"内容翻译"), LanguageToolMatch(@"字符管理")];

}

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
    
    [self.baseTableView registerClass:[NoaTranslateManagerCell class] forCellReuseIdentifier:NSStringFromClass([NoaTranslateManagerCell class])];
}

#pragma mark - UITableViewDelegate  UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DWScale(54);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return DWScale(16);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DWScale(16))];
    headerView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaTranslateManagerCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NoaTranslateManagerCell class]) forIndexPath:indexPath];
    NSString *itemTitle = (NSString *)[self.dataArr objectAtIndex:indexPath.row];
    cell.contentStr = itemTitle;
    [cell configCellRoundWithCellIndex:indexPath.row totalIndex:self.dataArr.count];
    cell.baseCellIndexPath = indexPath;
    cell.baseDelegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ZBaseCellDelegate
- (void)cellClickAction:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        //内容翻译
        //ZContentTranslateViewController *vc = [[ZContentTranslateViewController alloc] init];
        //[self.navigationController pushViewController:vc animated:YES];
    } else {
        //字符管理
        NoaCharacterManagerViewController *vc = [[NoaCharacterManagerViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
