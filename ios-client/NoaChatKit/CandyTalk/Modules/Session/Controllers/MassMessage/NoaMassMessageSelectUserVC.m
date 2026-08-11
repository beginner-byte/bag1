//
//  NoaMassMessageSelectUserVC.m
//  NoaKit
//
//  Created by Candy on 2023/4/19.
//

#import "NoaMassMessageSelectUserVC.h"
#import "NoaNoDataView.h"
#import "NoaSearchView.h"
#import "NoaInviteFriendHeaderView.h"
#import "NoaInviteFriendCell.h"
#import "NoaMassMessageSelectModel.h"
#import "NoaExcursionSelectCell.h"
#import "NoaMassMessageGroupSelectedTopView.h"

@interface NoaMassMessageSelectUserVC () <ZSearchViewDelegate,UITableViewDataSource,UITableViewDelegate,ZBaseCellDelegate>
@property (nonatomic, strong) NoaSearchView *viewSearch;//搜索控件
@property (nonatomic, strong) NSMutableArray<NoaBaseUserModel *> *searchList;//搜索结果
@property (nonatomic, strong) NoaNoDataView *viewNoData;//无数据提示
@property (nonatomic, strong) NSMutableArray<NoaMassMessageSelectModel *> *selectModelList;//分组及子级

@property (nonatomic, copy) NSString *searchStr;

@property (nonatomic, strong) NoaMassMessageGroupSelectedTopView *groupSelectedTopView;//已选择的
@end

@implementation NoaMassMessageSelectUserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupNavUI];
    [self setupUI];
    [self setupLocalData];
    
    //顶部已选中有delete操作时，触发此通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupSelectedDeleteAction:) name:@"ZMassMessageSelectedGroupDeleteActionNotification" object:nil];
}

- (void)setupNavUI {
    self.navTitleStr = LanguageToolMatch(@"选择收信人");
    self.navBtnRight.hidden = NO;
    [self.navBtnRight setTitle:LanguageToolMatch(@"完成") forState:UIControlStateNormal];
    [self.navBtnRight setTitleColor:COLORWHITE forState:UIControlStateNormal];
    self.navBtnRight.tkThemebackgroundColors = @[COLOR_CCCCCC, COLOR_CCCCCC_DARK];
    self.navBtnRight.layer.cornerRadius = DWScale(12);
    self.navBtnRight.layer.masksToBounds = YES;
    self.navBtnRight.titleLabel.numberOfLines = 2;
    self.navBtnRight.enabled = NO;
    [self.navBtnRight mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.navTitleLabel);
        make.trailing.equalTo(self.navView).offset(-DWScale(16));
        make.height.mas_equalTo(DWScale(32));
        CGSize textSize = [self.navBtnRight.titleLabel.text sizeWithFont:FONTR(14) constrainedToSize:CGSizeMake(10000, DWScale(32))];
        make.width.mas_equalTo(MIN(textSize.width+DWScale(28), 60));
    }];
    
}

- (void)setupUI {
    _viewSearch = [[NoaSearchView alloc] initWithPlaceholder:LanguageToolMatch(@"搜索")];
    _viewSearch.currentViewSearch = YES;
    _viewSearch.showClearBtn = YES;
    _viewSearch.returnKeyType = UIReturnKeyDefault;
    _viewSearch.delegate = self;
    [self.view addSubview:_viewSearch];
    [_viewSearch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(DWScale(38));
        make.top.mas_equalTo(self.view).offset(DNavStatusBarH + DWScale(6));
    }];
    
    _groupSelectedTopView = [[NoaMassMessageGroupSelectedTopView alloc] init];
    _groupSelectedTopView.selectedTopUserList = self.selectedList;
    [self.view addSubview:_groupSelectedTopView];
    [_groupSelectedTopView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(self.selectedList.count > 0 ? DWScale(94) : 0);
        make.top.mas_equalTo(_viewSearch.mas_bottom).offset(DWScale(16));
    }];
    
    [self.view addSubview:self.viewNoData];
    [self.viewNoData mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(_groupSelectedTopView.mas_bottom).offset(DWScale(10));
        make.height.mas_equalTo(DWScale(60));
    }];
    
    [self.view addSubview:self.baseTableView];
    self.baseTableView.delegate = self;
    self.baseTableView.dataSource = self;
    self.baseTableView.delaysContentTouches = NO;
    [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-DHomeBarH);
        make.top.equalTo(_groupSelectedTopView.mas_bottom).offset(DWScale(10));
    }];
    
    [self.baseTableView registerClass:[NoaInviteFriendCell class] forCellReuseIdentifier:[NoaInviteFriendCell cellIdentifier]];
    [self.baseTableView registerClass:[NoaExcursionSelectCell class] forCellReuseIdentifier:[NoaExcursionSelectCell cellIdentifier]];
    [self.baseTableView registerClass:[NoaInviteFriendHeaderView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([NoaInviteFriendHeaderView class])];
}

- (void)reloadInviteUI {
    if (![NSString isNil:_searchStr]) {
        self.baseTableView.hidden = !(self.searchList.count > 0);
        self.viewNoData.lblNoDataTip.text = self.searchList.count > 0 ? @"" : LanguageToolMatch(@"无搜索结果");
    }else {
        self.baseTableView.hidden = NO;
        self.viewNoData.lblNoDataTip.text = @"";
    }
    
}

#pragma mark - 初始化数据
- (void)setupLocalData {
    //最近联系人
    NSMutableArray *recentContactList = [NSMutableArray array];
    NSArray *localSessionArr = [IMSDKManager toolGetMySessionListWithOffServer];
    for (LingIMSessionModel *obj in localSessionArr) {
        if (obj.sessionType == CIMSessionTypeSingle) {
            LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:obj.sessionID];
            if (friendModel.userType == 1) {
                //此处过滤处理
            } else {
                if (friendModel && friendModel.disableStatus != 4) {
                    NoaBaseUserModel *baseUserModel = [[NoaBaseUserModel alloc] init];
                    baseUserModel.userId = obj.sessionID;
                    baseUserModel.name = obj.sessionName;
                    baseUserModel.avatar = obj.sessionAvatar;
                    baseUserModel.roleId = friendModel.roleId;
                    baseUserModel.showRole = YES;
                    baseUserModel.isGroup = obj.sessionType == CIMSessionTypeGroup;
                    [recentContactList addObject:baseUserModel];
                }
            }
        }
        if (obj.sessionType == CIMSessionTypeGroup) {
            NoaBaseUserModel *baseUserModel = [[NoaBaseUserModel alloc] init];
            baseUserModel.userId = obj.sessionID;
            baseUserModel.name = obj.sessionName;
            baseUserModel.avatar = obj.sessionAvatar;
            baseUserModel.roleId = obj.roleId;
            baseUserModel.isGroup = obj.sessionType == CIMSessionTypeGroup;
            [recentContactList addObject:baseUserModel];
        }
    
        if (recentContactList.count >= 50) {
            break;
        }
    }
    NSString *recentTitle = [NSString stringWithFormat:@"%@(%ld)",LanguageToolMatch(@"最近会话"), recentContactList.count];
    NoaMassMessageSelectModel *model = [NoaMassMessageSelectModel new];
    model.title = recentTitle;
    model.list = recentContactList;
    model.isOpen = YES;
    model.isAllSelect = NO;
    [self.selectModelList addObject:model];
    
    //群组
    //我的所有群聊
    NSMutableArray *groupList = [NSMutableArray array];
    NSArray *groupArr = [[IMSDKManager toolGetMyGroupList] mutableCopy];
    for (LingIMGroupModel *obj in groupArr) {
        NoaBaseUserModel *baseUserModel = [[NoaBaseUserModel alloc] init];
        baseUserModel.userId = obj.groupId;
        baseUserModel.name = obj.groupName;
        baseUserModel.avatar = obj.groupAvatar;
        baseUserModel.roleId = 0;
        baseUserModel.disableStatus = obj.groupStatus;
        baseUserModel.isGroup = YES;
        [groupList addObject:baseUserModel];
    }
    NSString *groupTitle = [NSString stringWithFormat:@"%@(%ld)",LanguageToolMatch(@"群聊"), groupList.count];
    NoaMassMessageSelectModel *groupModel = [NoaMassMessageSelectModel new];
    groupModel.title = groupTitle;
    groupModel.list = groupList;
    groupModel.isOpen = NO;
    groupModel.isAllSelect = NO;
    [self.selectModelList addObject:groupModel];
    
    //分组
    NSArray *localFriendGroupAr = [IMSDKManager toolGetMyFriendGroupList];
    for (LingIMFriendGroupModel *friendGroupModel in localFriendGroupAr) {
        //获取某个 好友分组 下的 好友列表(所有的，不包含已注销账号)
        NSString *friendGroupID = friendGroupModel.ugUuid;
        //找到该好友分组下的好友列表
        NSMutableArray *friendListForGroup = [NSMutableArray array];
        if (friendGroupModel.ugType == -1) {
            //默认分组
            NSArray *friendListTempY = [IMSDKManager toolGetMyFriendGroupFriendsWith:friendGroupID];
            NSArray *friendListTempN = [IMSDKManager toolGetMyFriendGroupFriendsWith:@""];
            [friendListForGroup addObjectsFromArray:friendListTempY];
            [friendListForGroup addObjectsFromArray:friendListTempN];
        }else {
            //用户自定义分组
            NSArray *friendListTemp = [IMSDKManager toolGetMyFriendGroupFriendsWith:friendGroupID];
            [friendListForGroup addObjectsFromArray:friendListTemp];
        }
        
        NSMutableArray *friendInGroupArr = [NSMutableArray array];
        for (LingIMFriendModel *tempFriend in friendListForGroup) {
            if (tempFriend.userType != 1 && tempFriend.disableStatus != 4) {//过滤系统级账户和已注销账户
                NoaBaseUserModel *baseUserModel = [[NoaBaseUserModel alloc] init];
                baseUserModel.userId = tempFriend.friendUserUID;
                baseUserModel.name = tempFriend.showName;
                baseUserModel.avatar = tempFriend.avatar;
                baseUserModel.roleId = tempFriend.roleId;
                baseUserModel.showRole = YES;
                baseUserModel.disableStatus = tempFriend.disableStatus;
                baseUserModel.isGroup = NO;
                [friendInGroupArr addObject:baseUserModel];
            }
        }
        NSString *groupFriendName = friendGroupModel.ugType == -1 ? (![NSString isNil:friendGroupModel.ugName] ? friendGroupModel.ugName : LanguageToolMatch(@"默认分组")) : friendGroupModel.ugName;
        NSString *groupFriendTitle = [NSString stringWithFormat:LanguageToolMatch(@"%@(%ld)"), groupFriendName, friendInGroupArr.count];
        NoaMassMessageSelectModel *model = [NoaMassMessageSelectModel new];
        model.title = groupFriendTitle;
        model.list = friendInGroupArr;
        model.isOpen = NO;
        model.isAllSelect = NO;
        [self.selectModelList addObject:model];
    }
    [self checkSelectModelIsAllSelected];
    [self.baseTableView reloadData];
    [self navBtnRightRefresh];
    [self groupSelectedTopViewRefresh];
}

#pragma mark - 获取搜索数据
- (void)requestSearchList {
    //搜索
    if (![NSString isNil:self.searchStr]) {
        NSArray *showFriendList = [[IMSDKManager toolSearchMyFriendWith:_searchStr] mutableCopy];
        for (LingIMFriendModel *tempFriend in showFriendList) {
            if (tempFriend.userType == 1) {
                //此处过滤处理
            } else {
                NoaBaseUserModel *baseUserModel = [[NoaBaseUserModel alloc] init];
                baseUserModel.userId = tempFriend.friendUserUID;
                baseUserModel.name = tempFriend.showName;
                baseUserModel.avatar = tempFriend.avatar;
                baseUserModel.roleId = tempFriend.roleId;
                baseUserModel.disableStatus = tempFriend.disableStatus;
                baseUserModel.isGroup = NO;
                [self.searchList addObject:baseUserModel];
            }
        }
        
        NSArray *showGroupList = [[IMSDKManager toolSearchMyGroupWith:_searchStr] mutableCopy];
        for (LingIMGroupModel *tempGroup in showGroupList) {
            NoaBaseUserModel *baseUserModel = [[NoaBaseUserModel alloc] init];
            baseUserModel.userId = tempGroup.groupId;
            baseUserModel.name = tempGroup.groupName;
            baseUserModel.avatar = tempGroup.groupAvatar;
            baseUserModel.roleId = 0;
            baseUserModel.disableStatus = tempGroup.groupStatus;
            baseUserModel.isGroup = YES;
            [self.searchList addObject:baseUserModel];
        }
    }
    [self reloadInviteUI];
    [self.baseTableView reloadData];
}
#pragma mark - ZSearchViewDelegate
- (void)searchViewTextValueChanged:(NSString *)searchStr {
    _searchStr = [searchStr trimString];
    [self.searchList removeAllObjects];
    [self requestSearchList];
}

#pragma mark - event
- (void)cellClickAction:(NSIndexPath *)indexPath {
    if ([NSString isNil:self.searchStr]) {
        NoaBaseUserModel *model = self.selectModelList[indexPath.section].list[indexPath.row];
        if ([self.selectedList containsObject:model]) {
            [self.selectedList removeObject:model];
        } else {
            [self.selectedList addObject:model];
        }
        
    } else {
        NoaBaseUserModel *model = self.searchList[indexPath.row];
        if ([self.selectedList containsObject:model]) {
            [self.selectedList removeObject:model];
        } else {
            [self.selectedList addObject:model];
        }
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self checkSelectModelIsAllSelected];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.baseTableView reloadData];
            [self navBtnRightRefresh];
            [self groupSelectedTopViewRefresh];
        });
    });

}

- (void)checkSelectModelIsAllSelected {
    for (int i = 0; i < self.selectModelList.count; i++) {
        NoaMassMessageSelectModel *selectModel = self.selectModelList[i];
        selectModel.isAllSelect = YES;
        for (int j = 0; j < selectModel.list.count; j++) {
            NoaBaseUserModel *userModel = selectModel.list[j];
            if (![self.selectedList containsObject:userModel]) {
                selectModel.isAllSelect = NO;
                break;
            }
        }
    }
}

- (void)groupSelectedDeleteAction:(NSNotification *)sender{
    //更新list
    NSNumber *deleteNum = sender.object;
    [self.selectedList removeObjectAtIndex:[deleteNum integerValue]];
    [self checkSelectModelIsAllSelected];
    [self.baseTableView reloadData];
    [self navBtnRightRefresh];
    [self groupSelectedTopViewRefresh];
}

- (void)groupSelectedTopViewRefresh {
    [_groupSelectedTopView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(self.selectedList.count > 0 ? DWScale(94) : 0);
        make.top.mas_equalTo(_viewSearch.mas_bottom).offset(DWScale(16));
    }];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    _groupSelectedTopView.selectedTopUserList = self.selectedList;
}

- (void)navBtnRightRefresh {
    self.navBtnRight.tkThemebackgroundColors = @[COLOR_CCCCCC, COLOR_CCCCCC_DARK];
    if (self.selectedList.count > 0) {
        [self.navBtnRight setTitle:[NSString stringWithFormat:LanguageToolMatch(@"完成(%ld)"),self.selectedList.count] forState:UIControlStateNormal];
        self.navBtnRight.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
        self.navBtnRight.enabled = YES;
    }else {
        [self.navBtnRight setTitle:LanguageToolMatch(@"完成") forState:UIControlStateNormal];
        self.navBtnRight.enabled = NO;
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([NSString isNil:self.searchStr]) {
        return self.selectModelList.count;
    }
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([NSString isNil:self.searchStr]) {
        return self.selectModelList[section].isOpen ? self.selectModelList[section].list.count : 0;
    }
    return self.searchList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([NSString isNil:self.searchStr]) {
        NoaExcursionSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaExcursionSelectCell cellIdentifier] forIndexPath:indexPath];
        NoaBaseUserModel *model = self.selectModelList[indexPath.section].list[indexPath.row];
        [cell cellConfigBaseUserWith:model search:_searchStr];
        cell.selectedUser = [self.selectedList containsObject:model];
        return cell;
    } else {
        NoaInviteFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaInviteFriendCell cellIdentifier] forIndexPath:indexPath];
        NoaBaseUserModel *model = self.searchList[indexPath.row];
        [cell cellConfigBaseUserWith:model search:_searchStr];
        cell.selectedUser = [self.selectedList containsObject:model];
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([NSString isNil:self.searchStr]) {
        return [NoaExcursionSelectCell defaultCellHeight];
    }
    return [NoaInviteFriendCell defaultCellHeight];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if ([NSString isNil:self.searchStr]) {
        NoaInviteFriendHeaderView *viewHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([NoaInviteFriendHeaderView class])];
        viewHeader.contentStr = self.selectModelList[section].title;
        viewHeader.isOpen = self.selectModelList[section].isOpen;
        viewHeader.isSelected = self.selectModelList[section].isAllSelect;
        WeakSelf
        [viewHeader setOpenCallback:^(bool isOpen) {
            weakSelf.selectModelList[section].isOpen = isOpen;
            [weakSelf.baseTableView reloadData];
        }];
        [viewHeader setSelectAllCallback:^(bool isAll) {
            if (isAll) {
                [HUD showActivityMessage:@""];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    for (NoaBaseUserModel *obj in weakSelf.selectModelList[section].list) {
                        if (![weakSelf.selectedList containsObject:obj]) {
                            [weakSelf.selectedList addObject:obj];
                        }
                    }
                    [weakSelf checkSelectModelIsAllSelected];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.selectModelList[section].isAllSelect = YES;
                        [weakSelf.baseTableView reloadData];
                        [weakSelf navBtnRightRefresh];
                        [weakSelf groupSelectedTopViewRefresh];
                        [HUD hideHUD];
                    });
                });
                
                
            } else {
                [HUD showActivityMessage:@""];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    weakSelf.selectModelList[section].isAllSelect = NO;
                    for (NoaBaseUserModel *obj in weakSelf.selectModelList[section].list)  {
                        if ([weakSelf.selectedList containsObject:obj]) {
                            [weakSelf.selectedList removeObject:obj];
                            
                        }
                    }
                    [weakSelf checkSelectModelIsAllSelected];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.baseTableView reloadData];
                        [weakSelf navBtnRightRefresh];
                        [weakSelf groupSelectedTopViewRefresh];
                        [HUD hideHUD];
                    });
                });
                
            }
        }];
        
        return viewHeader;
    } else {
        return [UIView new];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([NSString isNil:self.searchStr]) {
        return DWScale(46);
    }
    return DWScale(0.01);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self cellClickAction:indexPath];
}


#pragma mark - 交互事件

- (void)navBtnRightClicked {
    if (_selectedList.count < 1) return;
    
    if (_delegate && [_delegate respondsToSelector:@selector(massMessageSelectedUserList:)]) {
        [_delegate massMessageSelectedUserList:_selectedList];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)reloadBtnStateUI {
    if (_selectedList.count > 0) {
        [self.navBtnRight setTitle:[NSString stringWithFormat:LanguageToolMatch(@"完成(%ld)"),_selectedList.count] forState:UIControlStateNormal];
        self.navBtnRight.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
        
    }else {
        [self.navBtnRight setTitle:LanguageToolMatch(@"完成") forState:UIControlStateNormal];
        self.navBtnRight.tkThemebackgroundColors = @[COLOR_CCCCCC, COLOR_CCCCCC_DARK];
    }
    
    CGRect btnTextRect = [self.navBtnRight.titleLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, DWScale(32)) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: FONTR(14)} context:nil];
    [self.navBtnRight mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.navTitleLabel);
        make.trailing.equalTo(self.navView).offset(-DWScale(20));
        make.height.mas_equalTo(DWScale(32));
        make.width.mas_equalTo(MIN(btnTextRect.size.width + DWScale(28), 60));
    }];
}

#pragma mark - life cycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 懒加载

- (NoaNoDataView *)viewNoData {
    if (!_viewNoData) {
        _viewNoData = [[NoaNoDataView alloc] init];
        _viewNoData.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    }
    return _viewNoData;
}

- (NSMutableArray<NoaBaseUserModel *> *)searchList {
    if (_searchList == nil) {
        _searchList = [NSMutableArray array];
    }
    return _searchList;
}

- (NSMutableArray<NoaMassMessageSelectModel *> *)selectModelList {
    if (_selectModelList == nil) {
        _selectModelList = [[NSMutableArray alloc] init];
    }
    return _selectModelList;
}

- (NSMutableArray<NoaBaseUserModel *> *)selectedList {
    if (_selectedList == nil) {
        _selectedList = [NSMutableArray array];
    }
    return _selectedList;
}


@end
