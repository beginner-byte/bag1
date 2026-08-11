//
//  NoaTeamManagerVC.m
//  NoaKit
//
//  Created by Candy on 2023/7/20.
//

#import "NoaTeamManagerVC.h"
#import "NoaTeamModel.h"
#import "NoaTeamManagerCell.h"
#import "NoaTeamCreateVC.h"
#import "NoaTeamDetailVC.h"
#import "NoaAlertTipView.h"

@interface NoaTeamManagerVC () <UITableViewDataSource, UITableViewDelegate, ZTeamManagerCellDelegate, ZTeamDetailVCDelegate>

@property (nonatomic, assign) ZTeamManagerType managerType;//管理类型
@property (nonatomic, strong) UIButton *btnEdit;//编辑
@property (nonatomic, strong) UIButton *btnCreate;//新建团队
@property (nonatomic, strong) NSMutableArray *teamList;
@property (nonatomic, assign) NSInteger pageNumber;

@end

@implementation NoaTeamManagerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navTitleStr = LanguageToolMatch(@"团队列表");
    _managerType = ZTeamManagerTypeNone;
    _teamList = [NSMutableArray array];
    _pageNumber = 1;
    
    [self setupUI];
    [self requestTeamListData];
}

#pragma mark - 界面布局
- (void)setupUI {
    //新建团队
    _btnCreate = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnCreate setTitle:LanguageToolMatch(@"新建") forState:UIControlStateNormal];
    [_btnCreate setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateNormal];
    _btnCreate.titleLabel.font = FONTR(12);
    [_btnCreate addTarget:self action:@selector(btnCreateClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navView addSubview:_btnCreate];
    [_btnCreate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.navBtnBack);
        make.trailing.equalTo(self.navView).offset(-DWScale(8));
        make.height.mas_equalTo(DWScale(18));
        make.width.mas_equalTo(DWScale(60));

    }];
    
    //编辑
    _btnEdit = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnEdit setTitle:LanguageToolMatch(@"编辑") forState:UIControlStateNormal];
    [_btnEdit setTitle:LanguageToolMatch(@"取消") forState:UIControlStateSelected];
    [_btnEdit setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateNormal];
    _btnEdit.titleLabel.font = FONTR(12);
    [_btnEdit addTarget:self action:@selector(btnEditClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navView addSubview:_btnEdit];
    [_btnEdit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.navBtnBack);
        make.trailing.equalTo(_btnCreate.mas_leading).offset(-DWScale(4));
        make.height.mas_equalTo(DWScale(18));
        make.width.mas_equalTo(DWScale(40));
    }];
    _btnEdit.titleLabel.numberOfLines = 2;
    
    //TableView
    self.baseTableViewStyle = UITableViewStylePlain;
    self.baseTableView.dataSource = self;
    self.baseTableView.delegate = self;
    self.baseTableView.tkThemeseparatorColors = @[COLOR_CLEAR, COLOR_CLEAR];
    self.baseTableView.delaysContentTouches = NO;
    self.baseTableView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    self.baseTableView.mj_header = self.refreshHeader;
    self.baseTableView.mj_footer = self.refreshFooter;
    [self.view addSubview:self.baseTableView];
    [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.navView.mas_bottom);
        make.bottom.equalTo(self.view).offset(-DHomeBarH);
    }];
}

- (void)headerRefreshData {
    _pageNumber = 1;
    [self requestTeamListData];
}
- (void)footerRefreshData {
    _pageNumber++;
    [self requestTeamListData];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _teamList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DWScale(84);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaTeamManagerCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaTeamManagerCell cellIdentifier]];
    if (cell == nil) {
        cell = [[NoaTeamManagerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NoaTeamManagerCell cellIdentifier]];
    }
    NoaTeamModel *model = [_teamList objectAtIndexSafe:indexPath.row];
    [cell configCell:_managerType model:model];
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_managerType == ZTeamManagerTypeNone) {
        //团队详情
        NoaTeamModel *clickTeamModel = (NoaTeamModel *)[_teamList objectAtIndex:indexPath.row];
        if (![NSString isNil:clickTeamModel.teamId]) {
            NoaTeamDetailVC *vc = [NoaTeamDetailVC new];
            vc.delegate = self;
            vc.teamModel = clickTeamModel;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - ZTeamManagerCellDelegate
- (void)teamManagerOperator:(NSIndexPath *)cellIndex {
    if (_managerType == ZTeamManagerTypeNone) {
        //选为默认
        [self requestSetDefaultTeamWithIndex:cellIndex.row];
    } else {
        //删除
        [self teamManagerDeleteTipWithDeleteIndex:cellIndex.row];
    }
}

#pragma mark - ZTeamDetailVCDelegate
//更新团队名称
- (void)updateTeamName:(NSString *)name index:(NSInteger)index {
    NoaTeamModel *model = (NoaTeamModel *)[_teamList objectAtIndexSafe:index];
    model.teamName = name;
    [_teamList replaceObjectAtIndex:index withObject:model];
    [self.baseTableView reloadData];
}

#pragma mark - Action
//编辑
- (void)btnEditClick {
    _btnEdit.selected = !_btnEdit.selected;
    if (_btnEdit.isSelected) {
        _managerType = ZTeamManagerTypeEdit;
    }else {
        _managerType = ZTeamManagerTypeNone;
    }
    [self.baseTableView reloadData];
}

//新建团队
- (void)btnCreateClick {
    NoaTeamCreateVC *vc = [[NoaTeamCreateVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

//删除(弹窗)
- (void)teamManagerDeleteTipWithDeleteIndex:(NSInteger)deleteIndex {
    WeakSelf
    NoaAlertTipView *alertView = [NoaAlertTipView new];
    alertView.lblTitle.text = LanguageToolMatch(@"删除团队");
    alertView.lblTitle.font = FONTB(16);
    alertView.lblContent.text = LanguageToolMatch(@"是否删除该团队");
    alertView.lblContent.font = FONTN(15);
    self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        UIColor *color = nil;
        if (themeIndex == 0) {
            color = COLOR_66;
        } else {
            color = COLOR_66_DARK;
        }
       alertView.lblContent.textColor = color;
    };
    [alertView.btnSure setTitle:LanguageToolMatch(@"确定") forState:UIControlStateNormal];
    [alertView.btnSure setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateNormal];
    [alertView.btnCancel setTkThemeTitleColor:@[COLOR_11, COLOR_11_DARK] forState:UIControlStateNormal];
    [alertView alertTipViewSHow];
    alertView.sureBtnBlock = ^{
        [weakSelf requestTeamDeleteWithIndex:deleteIndex];
    };
}

#pragma mark - 数据请求
//请求团队列表
- (void)requestTeamListData {
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:@(_pageNumber) forKey:@"pageNumber"];
    [dict setObjectSafe:@(20) forKey:@"pageSize"];
    [dict setObjectSafe:@((_pageNumber - 1) * 20) forKey:@"pageStart"];
    [IMSDKManager imTeamListWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            //数据处理
            if (weakSelf.pageNumber == 1) {
                [weakSelf.teamList removeAllObjects];
            }
            NSDictionary *dataDict = (NSDictionary *)data;
            NSArray *teamListTemp = (NSArray *)[dataDict objectForKeySafe:@"records"];
            [teamListTemp enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NoaTeamModel *model = [NoaTeamModel mj_objectWithKeyValues:obj];
                [weakSelf.teamList addObjectIfNotNil:model];
            }];
            [weakSelf.baseTableView reloadData];
            
            //分页处理
            NSInteger totalPage = [[dataDict objectForKeySafe:@"pages"] integerValue];
            if (weakSelf.pageNumber < totalPage) {
                if (!weakSelf.baseTableView.mj_footer) {
                    weakSelf.baseTableView.mj_footer = weakSelf.refreshFooter;
                }
            }else {
                weakSelf.baseTableView.mj_footer = nil;
            }
        }
        [weakSelf.baseTableView.mj_footer endRefreshing];
        [weakSelf.baseTableView.mj_header endRefreshing];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
        [weakSelf.baseTableView.mj_footer endRefreshing];
        [weakSelf.baseTableView.mj_header endRefreshing];
    }];
}

//设置为默认
- (void)requestSetDefaultTeamWithIndex:(NSInteger)index {
    NoaTeamModel *model = (NoaTeamModel *)[_teamList objectAtIndex:index];
    if (model && model.isDefaultTeam != 1) {
        //设置为默认团队
        WeakSelf
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObjectSafe:model.teamId forKey:@"teamId"];
        [dict setObjectSafe:@(1) forKey:@"isDefaultTeam"];
        [IMSDKManager imTeamEditWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            model.isDefaultTeam = 1;
            [HUD showMessage:LanguageToolMatch(@"设置成功")];
            [weakSelf headerRefreshData];
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            [HUD showMessageWithCode:code errorMsg:msg];
        }];
    }
}

//团队删除
- (void)requestTeamDeleteWithIndex:(NSInteger)index {
    NoaTeamModel *model = (NoaTeamModel *)[_teamList objectAtIndex:index];
    if (![NSString isNil:model.teamId]) {
        WeakSelf
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObjectSafe:@[model.teamId] forKey:@"teamIds"];
        [IMSDKManager imTeamDeleteWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            [HUD showMessage:LanguageToolMatch(@"删除成功")];
            [weakSelf.teamList removeObjectAtIndex:index];
            [weakSelf.baseTableView reloadData];
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            [HUD showMessageWithCode:code errorMsg:msg];
        }];
    }
}

@end
