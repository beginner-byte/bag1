//
//  NoaTeamVC.m
//  NoaKit
//
//  Created by Candy on 2023/7/19.
//

#import "CandyTalkTeamViewController.h"
#import "NoaTeamHomeHeaderView.h"
#import "NoaTeamTitleHeaderView.h"
#import "NoaTeamCell.h"
#import "NoaTeamModel.h"
#import "NoaTeamManagerVC.h"
#import "NoaTeamDetailVC.h"
#import "NoaShareInviteViewController.h"
#import "NoaAlertTipView.h"
#import "NoaTeamUpdateNameView.h"

@interface CandyTalkTeamViewController () <UITableViewDelegate, UITableViewDataSource, ZTeamHomeHeaderViewDelegate, ZTeamUpdateNameViewDelegate>

@property (nonatomic, strong) NSMutableArray *teamList;
@property (nonatomic, strong) NSMutableArray *defaultDataArr;
@property (nonatomic, strong) NoaTeamModel *defaultTeamModel;
@property (nonatomic, strong) UIButton *quickCreateBtn;

@end

@implementation CandyTalkTeamViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self performSelector:@selector(requestTeamHomeData) withObject:nil afterDelay:8];
    [self performSelector:@selector(requestTeamListData) withObject:nil afterDelay:8];
//    [self requestTeamHomeData];
//    [self requestTeamListData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _teamList = [NSMutableArray array];
    _defaultDataArr = [NSMutableArray array];
    
    [self configNavUI];
    [self setupUI];
    
    self.navBtnBack.hidden = YES;
    self.navView.frame = CGRectMake(0, 0, DScreenWidth, 1);
    self.navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, 1)];
    [self.view  addSubview:self.navView];
}

#pragma mark - 界面布局
- (void)configNavUI {
//    self.navTitleStr = LanguageToolMatch(@"团队邀请");
    self.navBtnRight.hidden = NO;
    [self.navBtnRight setTitle:LanguageToolMatch(@"分享默认") forState:UIControlStateNormal];
    [self.navBtnRight setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateNormal];
}

- (void)setupUI {
    
    self.view.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    
    self.baseTableViewStyle = UITableViewStylePlain;
    self.baseTableView.delegate = self;
    self.baseTableView.dataSource = self;
    self.baseTableView.separatorColor = COLOR_CLEAR;
    self.baseTableView.delaysContentTouches = NO;
    self.baseTableView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    [self.view addSubview:self.baseTableView];
    [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.navView.mas_bottom);
        make.bottom.equalTo(self.view).offset(-(DTabBarH + DWScale(25) + DWScale(44) + DWScale(25)));
    }];
    [self.baseTableView registerClass:[NoaTeamHomeHeaderView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([NoaTeamHomeHeaderView class])];
    [self.baseTableView registerClass:[NoaTeamTitleHeaderView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([NoaTeamTitleHeaderView class])];
    [self.baseTableView registerClass:[NoaTeamCell class] forCellReuseIdentifier:NSStringFromClass([NoaTeamCell class])];
    
    //一键建群
    self.quickCreateBtn = [UIButton new];
    [self.quickCreateBtn setTitle:LanguageToolMatch(@"一键建群") forState:UIControlStateNormal];
    [self.quickCreateBtn setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
    self.quickCreateBtn.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2];
    self.quickCreateBtn.titleLabel.font = FONTN(14);
    [self.quickCreateBtn rounded:DWScale(8)];
    [self.quickCreateBtn addTarget:self action:@selector(defaultTeamQuickCreateGroupClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.quickCreateBtn];
    [self.quickCreateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(DWScale(25));
        make.trailing.equalTo(self.view).offset(-DWScale(25));
        make.bottom.equalTo(self.view).offset(-(DTabBarH + DWScale(25)));
        make.height.mas_equalTo(DWScale(44));
    }];
}

#pragma mark - UITableViewDelegate  UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    } else {
        return self.defaultDataArr.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DWScale(50);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if (_teamList.count > 0) {
            return DWScale(140);
        } else {
            return 0;
        }
    } else {
        return DWScale(50);
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        NoaTeamHomeHeaderView *viewHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([NoaTeamHomeHeaderView class])];
        viewHeader.headerTeamList = self.teamList;
        viewHeader.delegate = self;
        return viewHeader;
    } else {
        NoaTeamTitleHeaderView *viewHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([NoaTeamTitleHeaderView class])];
        return viewHeader;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaTeamCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NoaTeamCell class]) forIndexPath:indexPath];
    NSDictionary *dict = [self.defaultDataArr objectAtIndex:indexPath.row];
    cell.titleStr = (NSString *)[dict objectForKeySafe:@"titleStr"];
    cell.subTitleStr = (NSString *)[dict objectForKeySafe:@"subTitleStr"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            //修改团队名称
            NoaTeamUpdateNameView *viewUpdate = [NoaTeamUpdateNameView new];
            viewUpdate.model = self.defaultTeamModel;
            viewUpdate.delegate = self;
            [viewUpdate updateViewShow];
        }
        if (indexPath.row == 1) {
            //复制团队邀请码
            if (![NSString isNil:_defaultTeamModel.inviteCode]) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = _defaultTeamModel.inviteCode;
                [HUD showMessage:LanguageToolMatch(@"复制成功")];
            }
        }
    }
}

#pragma mark - ZTeamHomeHeaderViewDelegate
- (void)headerTeamListTitleAction {
    //团队列表
    NoaTeamManagerVC *vc = [[NoaTeamManagerVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)headerTeamItemAction:(NoaTeamModel *)teamModel {
    //团队详情
    if (![NSString isNil:teamModel.teamId]) {
        NoaTeamDetailVC *vc = [NoaTeamDetailVC new];
        vc.teamModel = teamModel;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)headerSetDefaultTeamAction:(NoaTeamModel *)model {
    //设置为默认
    [self requestSetDefaultTeam:model];
}

#pragma mark - ZTeamUpdateNameViewDelegate
- (void)teamUpdateNameAction:(NSString *)newName {
    [self requestTeamHomeData];
    [self requestTeamListData];
}

#pragma mark - Action
//一键建群
- (void)defaultTeamQuickCreateGroupClick {
    if (_defaultTeamModel.totalInviteNum >= 3) {
        WeakSelf
        NoaAlertTipView *alertView = [NoaAlertTipView new];
        alertView.lblTitle.text = LanguageToolMatch(@"提示");
        alertView.lblTitle.font = FONTB(16);
        alertView.lblContent.text = LanguageToolMatch(@"建群时只会拉取你的好友");
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
            [weakSelf requestTeamCreateGroup];
        };
    } else {
        [HUD showMessage:LanguageToolMatch(@"人数不足三人，无法创建群聊")];
    }
}

#pragma mark - 数据请求
- (void)requestTeamHomeData {
    WeakSelf
    [HUD showSuccessMessage:@"团队8"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    [IMSDKManager imTeamHomeWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDic = (NSDictionary *)data;
            weakSelf.defaultTeamModel = [NoaTeamModel mj_objectWithKeyValues:dataDic];
            weakSelf.defaultTeamModel.teamName = LanguageToolMatch(weakSelf.defaultTeamModel.teamName);
            [weakSelf updateDataAndUI];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

- (void)requestTeamListData {
    [HUD showSuccessMessage:@"团队9"];
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:@(1) forKey:@"pageNumber"];
    [dict setObjectSafe:@(20) forKey:@"pageSize"];
    [dict setObjectSafe:@(0) forKey:@"pageStart"];
    [IMSDKManager imTeamListWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            //数据处理
            [weakSelf.teamList removeAllObjects];
            NSDictionary *dataDict = (NSDictionary *)data;
            NSArray *teamListTemp = (NSArray *)[dataDict objectForKeySafe:@"records"];
            [teamListTemp enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NoaTeamModel *model = [NoaTeamModel mj_objectWithKeyValues:obj];
                if([model.teamName isEqualToString:@"默认团队"]){
                    model.teamName = LanguageToolMatch(@"默认团队");
                }
                [weakSelf.teamList addObjectIfNotNil:model];
            }];
            
            [weakSelf.baseTableView reloadData];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

//设置为默认
- (void)requestSetDefaultTeam:(NoaTeamModel *)teamModel {
    if (teamModel && teamModel.isDefaultTeam != 1) {
        //设置为默认团队
        WeakSelf
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObjectSafe:teamModel.teamId forKey:@"teamId"];
        [dict setObjectSafe:@(1) forKey:@"isDefaultTeam"];
        [IMSDKManager imTeamEditWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            teamModel.isDefaultTeam = 1;
            [HUD showMessage:LanguageToolMatch(@"设置成功")];
            [weakSelf requestTeamHomeData];
            [weakSelf requestTeamListData];
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            [HUD showMessageWithCode:code errorMsg:msg];
        }];
    }
}

//一键建群
- (void)requestTeamCreateGroup {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:self.defaultTeamModel.teamId forKey:@"teamId"];
    [IMSDKManager imTeamCreateGroupWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD showMessage:LanguageToolMatch(@"操作成功")];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}


- (void)updateDataAndUI {
    if (_defaultTeamModel) {
        [_defaultDataArr removeAllObjects];
        
        [_defaultDataArr addObject:@{@"titleStr":LanguageToolMatch(@"团队名称"), @"subTitleStr":_defaultTeamModel.teamName}];
        [_defaultDataArr addObject:@{@"titleStr":LanguageToolMatch(@"邀请码"), @"subTitleStr":_defaultTeamModel.inviteCode}];
        
        [_defaultDataArr addObject:@{@"titleStr":LanguageToolMatch(@"团队总人数"), @"subTitleStr":[NSString stringWithFormat:@"%ld", (long)_defaultTeamModel.totalInviteNum]}];
        
        [_defaultDataArr addObject:@{@"titleStr":LanguageToolMatch(@"团队关联群聊数"), @"subTitleStr":[NSString stringWithFormat:@"%ld", (long)_defaultTeamModel.groupNum]}];
        
        [_defaultDataArr addObject:@{@"titleStr":LanguageToolMatch(@"昨日邀请"), @"subTitleStr":[NSString stringWithFormat:@"%ld", (long)_defaultTeamModel.yesterdayInviteNum]}];
        
        [_defaultDataArr addObject:@{@"titleStr":LanguageToolMatch(@"今日邀请"), @"subTitleStr":[NSString stringWithFormat:@"%ld", (long)_defaultTeamModel.todayInviteNum]}];
        
        [_defaultDataArr addObject:@{@"titleStr":LanguageToolMatch(@"本月邀请"), @"subTitleStr":[NSString stringWithFormat:@"%ld", (long)_defaultTeamModel.mouthInviteCount]}];
       
        [self.baseTableView reloadData];
    }
}
#pragma mark - 交互事件
- (void)navBtnRightClicked {
    
        NoaShareInviteViewController *vc = [NoaShareInviteViewController new];
    if (![NSString isNil:_defaultTeamModel.teamId]) {
        vc.teamID = _defaultTeamModel.teamId;
    } else {
        vc.teamID = @"0";
    }
        [self.navigationController pushViewController:vc animated:YES];
    
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
