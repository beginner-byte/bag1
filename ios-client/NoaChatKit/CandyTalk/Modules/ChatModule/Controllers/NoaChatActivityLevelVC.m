//
//  NoaChatActivityLevelVC.m
//  NoaKit
//
//  Created by Candy on 2025/2/19.
//

#import "NoaChatActivityLevelVC.h"
#import "NoaChatActivityLevelCell.h"
#import "NoaChatActivityLevelHeaderView.h"

@interface NoaChatActivityLevelVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)NSMutableArray *dataArr;

@end

@implementation NoaChatActivityLevelVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    [self setupUI];
    [self setupData];
}

#pragma mark - UI
- (void)setupUI {
    self.navTitleStr = LanguageToolMatch(@"我的群活跃等级");
    
    self.baseTableViewStyle = UITableViewStyleGrouped;
    self.baseTableView.delegate = self;
    self.baseTableView.dataSource = self;
    self.baseTableView.separatorColor = COLOR_CLEAR;
    self.baseTableView.delaysContentTouches = NO;
    self.baseTableView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    [self.view addSubview:self.baseTableView];
    [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.navView.mas_bottom);
        make.bottom.equalTo(self.view).offset(-DHomeBarH);
    }];
    [self.baseTableView registerClass:[NoaChatActivityLevelCell class] forCellReuseIdentifier:NSStringFromClass([NoaChatActivityLevelCell class])];
}

- (void)setupData {
    [self.dataArr addObjectsFromArray:UserManager.activityConfigInfo.levels];
    [self.baseTableView reloadData];
}

#pragma mark - Setter
- (void)setGroupInfo:(LingIMGroup *)groupInfo {
    _groupInfo = groupInfo;
}

#pragma mark - UITableViewDelegate  UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DWScale(48);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    // 获取表头视图
    UIView *headerView = [self tableView:tableView viewForHeaderInSection:section];
    // 强制更新布局
    [headerView setNeedsLayout];
    [headerView layoutIfNeeded];
    // 计算合适的大小
    CGSize size = [headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NoaChatActivityLevelHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"NoaChatActivityLevelHeaderView"];
    if (headerView == nil) {
        headerView = [[NoaChatActivityLevelHeaderView alloc] initWithReuseIdentifier:@"NoaChatActivityLevelHeaderView"];
    }
    LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:UserManager.userInfo.userUID groupID:self.groupInfo.groupId];
    if (groupMemberModel) {
        headerView.myLevelScroe = groupMemberModel.activityScroe;
    } else {
        headerView.myLevelScroe = 0;
    }
    headerView.activityInfoModel = UserManager.activityConfigInfo;
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaChatActivityLevelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoaChatActivityLevelCell"];
    if (cell == nil){
        cell = [[NoaChatActivityLevelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NoaChatActivityLevelCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.activityLevelModel = (NoaGroupActivityLevelModel *)[self.dataArr objectAtIndexSafe:indexPath.row];
    return cell;
}

#pragma mark - Lazy
- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc] init];
    }
    return _dataArr;
}


@end
