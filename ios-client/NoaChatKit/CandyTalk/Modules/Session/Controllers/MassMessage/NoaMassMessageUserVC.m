//
//  NoaMassMessageUserVC.m
//  NoaKit
//
//  Created by Candy on 2023/4/19.
//

#import "NoaMassMessageUserVC.h"
#import "NoaMassMessageUserCell.h"
#import "NoaMassMessageUserModel.h"
#import "NoaMassMessageErrorUserModel.h"

@interface NoaMassMessageUserVC () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign) NSInteger pageNumber;
@property (nonatomic, strong) NSMutableArray *userList;
@end

@implementation NoaMassMessageUserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navTitleStr = LanguageToolMatch(@"群发助手");
    
    _userList = [NSMutableArray array];
    
    [self setupUI];
}
#pragma mark - 界面布局
- (void)setupUI {
    [self.view addSubview:self.baseTableView];
    [self defaultTableViewUI];
    self.baseTableView.dataSource = self;
    self.baseTableView.delegate = self;
    [self.baseTableView registerClass:[NoaMassMessageUserCell class] forCellReuseIdentifier:[NoaMassMessageUserCell cellIdentifier]];
    self.baseTableView.mj_header = self.refreshHeader;
    self.baseTableView.mj_footer = self.refreshFooter;
    [self.baseTableView.mj_header beginRefreshing];
}
#pragma mark - 数据请求
- (void)headerRefreshData {
    _pageNumber = 1;
    [self requestUserListData];
}
- (void)footerRefreshData {
    _pageNumber++;
    [self requestUserListData];
}
- (void)requestUserListData {
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_messageModel.labelId forKey:@"labelId"];
    [dict setValue:_messageModel.taskId forKey:@"taskId"];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    [dict setValue:@((_pageNumber - 1) * 15) forKey:@"pageStart"];
    [dict setValue:@(15) forKey:@"pageSize"];
    [dict setValue:@(_pageNumber) forKey:@"pageNumber"];
    if (_allUsers) {
        [IMSDKManager GroupHairGetGroupHairUserListWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dataDict = (NSDictionary *)data;
                
                NSInteger totalCount = [[dataDict objectForKeySafe:@"total"] integerValue];
                NSArray *recordsArr = [dataDict objectForKeySafe:@"records"];
                if (weakSelf.pageNumber == 1) {
                    [weakSelf.userList removeAllObjects];
                }
                [recordsArr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NoaMassMessageUserModel *model = [NoaMassMessageUserModel mj_objectWithKeyValues:obj];
                    [weakSelf.userList addObjectIfNotNil:model];
                }];
                [weakSelf.baseTableView reloadData];
                if (weakSelf.userList.count >= totalCount) {
                    weakSelf.baseTableView.mj_footer = nil;
                }else {
                    if (!weakSelf.baseTableView.mj_footer) {
                        weakSelf.baseTableView.mj_footer = weakSelf.refreshFooter;
                    }
                }
            }
            
            [weakSelf.baseTableView.mj_header endRefreshing];
            [weakSelf.baseTableView.mj_footer endRefreshing];
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            [HUD showMessageWithCode:code errorMsg:msg];
            [weakSelf.baseTableView.mj_header endRefreshing];
            [weakSelf.baseTableView.mj_footer endRefreshing];
        }];
    }else {
        [IMSDKManager GroupHairGetGroupHairErrorUserListWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dataDict = (NSDictionary *)data;
                
                NSInteger totalCount = [[dataDict objectForKeySafe:@"total"] integerValue];
                NSArray *recordsArr = [dataDict objectForKeySafe:@"records"];
                if (weakSelf.pageNumber == 1) {
                    [weakSelf.userList removeAllObjects];
                }
                [recordsArr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NoaMassMessageErrorUserModel *model = [NoaMassMessageErrorUserModel mj_objectWithKeyValues:obj];
                    [weakSelf.userList addObjectIfNotNil:model];
                }];
                [weakSelf.baseTableView reloadData];
                if (weakSelf.userList.count >= totalCount) {
                    weakSelf.baseTableView.mj_footer = nil;
                }else {
                    if (!weakSelf.baseTableView.mj_footer) {
                        weakSelf.baseTableView.mj_footer = weakSelf.refreshFooter;
                    }
                }
            }
            
            
            [weakSelf.baseTableView.mj_header endRefreshing];
            [weakSelf.baseTableView.mj_footer endRefreshing];
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            [HUD showMessageWithCode:code errorMsg:msg];
            [weakSelf.baseTableView.mj_header endRefreshing];
            [weakSelf.baseTableView.mj_footer endRefreshing];
        }];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _userList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaMassMessageUserCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaMassMessageUserCell cellIdentifier] forIndexPath:indexPath];
    cell.userModel = [_userList objectAtIndexSafe:indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [NoaMassMessageUserCell defaultCellHeight];
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
