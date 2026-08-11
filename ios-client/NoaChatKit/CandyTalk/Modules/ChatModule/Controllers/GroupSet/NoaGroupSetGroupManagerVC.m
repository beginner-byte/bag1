//
//  NoaGroupSetGroupManagerVC.m
//  NoaKit
//
//  Created by Candy on 2026/11/16.
//

#import "NoaGroupSetGroupManagerVC.h"
#import "NoaSearchView.h"
#import "NoaGroupInviteAndRemoveFriendCell.h"
#import "NoaChineseSort.h"
#import "UITableView+SCIndexView.h"
#import "NoaKnownTipView.h"
#import "NoaFriendListSectionHeaderView.h"
#import "LingIMGroup.h"
#import "NoaChatViewController.h"
#import "NoaSheetCustomView.h"
#import "NoaChatViewController.h"

@interface NoaGroupSetGroupManagerVC ()<ZSearchViewDelegate,UITableViewDataSource,UITableViewDelegate,ZBaseCellDelegate>

@property (nonatomic, strong) NoaSearchView *viewSearch;
@property (nonatomic, strong) NSMutableArray *reqFriendList;//从后台请求下来的数据集合
@property (nonatomic, strong) NSMutableArray *showFriendList;//展示的好友列表
@property (nonatomic, strong) NSMutableArray *selectedFriendList;//选中的好友id
@property (nonatomic, strong) NSMutableArray *selectedNicknameList;//选中的好友昵称
@property (nonatomic, copy) NSString *searchStr;
@property (nonatomic, copy) NSString * groupMemberTabName;

@end

@implementation NoaGroupSetGroupManagerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavUI];
    [self setupUI];
    
    _reqFriendList = [NSMutableArray array];
    _showFriendList = [NSMutableArray array];
    _selectedFriendList = [NSMutableArray array];
    _selectedNicknameList = [NSMutableArray array];
    
    //该群在本地存储群成员表的表名称
    self.groupMemberTabName = [NSString stringWithFormat:@"CIMSDKDB_%@_GroupMemberTable",self.groupInfoModel.groupId];
    //加载本地数据库换成的群成员表
    [self.reqFriendList addObjectsFromArray:[IMSDKManager imSdkGetGroupMemberExceptOwnerWith:self.groupInfoModel.groupId]];
    
    [self requestFriendList];
}

#pragma mark - 界面布局
- (void)setupNavUI {
    self.navTitleStr = LanguageToolMatch(@"设置管理员");
    self.navBtnRight.hidden = NO;
    [self.navBtnRight setTitle:LanguageToolMatch(@"完成") forState:UIControlStateNormal];
    [self.navBtnRight setTitleColor:COLORWHITE forState:UIControlStateNormal];
    self.navBtnRight.tkThemebackgroundColors = @[COLOR_CCCCCC, COLOR_CCCCCC_DARK];
    self.navBtnRight.layer.cornerRadius = DWScale(12);
    self.navBtnRight.layer.masksToBounds = YES;
    [self.navBtnRight mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.navTitleLabel);
        make.trailing.equalTo(self.navView).offset(-DWScale(20));
        make.height.mas_equalTo(DWScale(32));
        CGSize textSize = [self.navBtnRight.titleLabel.text sizeWithFont:FONTR(14) constrainedToSize:CGSizeMake(10000, DWScale(32))];
        make.width.mas_equalTo(MIN(textSize.width+DWScale(28), 60));
    }];
}

- (void)setupUI {
    _viewSearch = [[NoaSearchView alloc] initWithPlaceholder:LanguageToolMatch(@"搜索")];
    _viewSearch.frame = CGRectMake(0, DNavStatusBarH + DWScale(6), DScreenWidth, DWScale(38));
    _viewSearch.currentViewSearch = YES;
    _viewSearch.showClearBtn = YES;
    _viewSearch.returnKeyType = UIReturnKeyDefault;
    _viewSearch.delegate = self;
    [self.view addSubview:_viewSearch];
    
    [self.view addSubview:self.baseTableView];
    self.baseTableView.delegate = self;
    self.baseTableView.dataSource = self;
    self.baseTableView.delaysContentTouches = NO;
    [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-DHomeBarH);
        make.top.equalTo(_viewSearch.mas_bottom).offset(DWScale(6));
    }];
    
    [self.baseTableView registerClass:[NoaGroupInviteAndRemoveFriendCell class] forCellReuseIdentifier:[NoaGroupInviteAndRemoveFriendCell cellIdentifier]];
    [self.baseTableView registerClass:[NoaFriendListSectionHeaderView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([NoaFriendListSectionHeaderView class])];
    
    SCIndexViewConfiguration *configuration = [SCIndexViewConfiguration configurationWithIndexViewStyle:SCIndexViewStyleDefault];
    configuration.indexItemSelectedBackgroundColor = COLOR_5966F2;
    configuration.indexItemsSpace = DWScale(6);
    self.baseTableView.sc_indexViewConfiguration = configuration;
    self.baseTableView.sc_translucentForTableViewInNavigationBar = NO;
}

- (void)navBtnRightClicked {
    WeakSelf;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:self.groupInfoModel.groupId forKey:@"groupId"];
    [dict setObjectSafe:self.selectedFriendList forKey:@"groupMemberUidList"];
    [dict setObjectSafe:@"1" forKey:@"operationType"];
    if (![NSString isNil:UserManager.userInfo.userUID]) {
        [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    }
    [IMSDKManager groupSetGroupManagerWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if (data) {
            for (NSString *managerUid in weakSelf.selectedFriendList) {
                LingIMGroupMemberModel *newManagerMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:managerUid groupID:weakSelf.groupInfoModel.groupId];
                newManagerMemberModel.role = 1;
                [IMSDKManager imSdkInsertOrUpdateGroupMember:newManagerMemberModel groupID:weakSelf.groupInfoModel.groupId];
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
            [HUD showMessage:LanguageToolMatch(@"设置群管理员成功")];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

- (void)requestFriendList {
    
    [self.showFriendList removeAllObjects];
    if (![NSString isNil:_searchStr]) {
        //搜索联系人
        [self.showFriendList removeAllObjects];
        [self.showFriendList addObjectsFromArray:[DBTOOL checkGroupMemberWithTabName:self.groupMemberTabName searchContent:_searchStr exceptUserId:@""]];
    }else {
        //群组成员
        [self.showFriendList addObjectsFromArray:self.reqFriendList];
    }
    [self.baseTableView reloadData];
}

#pragma mark - ZSearchViewDelegate
- (void)searchViewTextValueChanged:(NSString *)searchStr {
    _searchStr = [searchStr trimString];
    [self requestFriendList];
}

#pragma mark - ZBaseCellDelegate
- (void)cellClickAction:(NSIndexPath *)indexPath {
    LingIMGroupMemberModel *model = [self.showFriendList objectAtIndexSafe:indexPath.row];
    if (model.isGroupMember) {
        return;
    }
    if ([_selectedFriendList containsObject:model.userUid]) {
        [_selectedFriendList removeObject:model.userUid];
        [_selectedNicknameList removeObject:model.userNickname];
    }else {
        [_selectedFriendList addObjectIfNotNil:model.userUid];
        [_selectedNicknameList addObjectIfNotNil:model.userNickname];
    }
    
    [self.baseTableView reloadData];
    
    self.navBtnRight.tkThemebackgroundColors = @[COLOR_CCCCCC, COLOR_CCCCCC_DARK];
    if (_selectedFriendList.count > 0) {
        [self.navBtnRight setTitle:[NSString stringWithFormat:LanguageToolMatch(@"完成(%ld)"),_selectedFriendList.count] forState:UIControlStateNormal];
        self.navBtnRight.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    }else {
        [self.navBtnRight setTitle:LanguageToolMatch(@"完成") forState:UIControlStateNormal];
    }
    [self.navBtnRight mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.navTitleLabel);
        make.trailing.equalTo(self.navView).offset(-DWScale(20));
        make.height.mas_equalTo(DWScale(32));
        CGSize textSize = [self.navBtnRight.titleLabel.text sizeWithFont:FONTR(14) constrainedToSize:CGSizeMake(10000, DWScale(32))];
        make.width.mas_equalTo(MIN(textSize.width+DWScale(28), 60));
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _showFriendList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaGroupInviteAndRemoveFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupInviteAndRemoveFriendCell cellIdentifier] forIndexPath:indexPath];
    cell.baseDelegate = self;
    cell.baseCellIndexPath = indexPath;
    LingIMGroupMemberModel *model = [_showFriendList objectAtIndexSafe:indexPath.row];
    [cell cellConfigWith:model search:_searchStr];
    if (model.isGroupMember) {
        cell.selectedUser = 1;
    } else {
        if ([_selectedFriendList containsObject:model.userUid]) {
            cell.selectedUser = 2;
        }else {
            cell.selectedUser = 3;
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [NoaGroupInviteAndRemoveFriendCell defaultCellHeight];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * view = [UIView new];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
