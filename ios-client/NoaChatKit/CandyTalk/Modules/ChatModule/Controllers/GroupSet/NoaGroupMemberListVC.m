//
//  NoaGroupMemberListVC.m
//  NoaKit
//
//  Created by Candy on 2026/11/9.
//

#import "NoaGroupMemberListVC.h"
#import "NoaSearchView.h"
#import "NoaGroupMemberListCell.h"
#import "NoaChineseSort.h"
#import "UITableView+SCIndexView.h"
#import "NoaKnownTipView.h"
#import "NoaFriendListSectionHeaderView.h"
#import "LingIMGroup.h"
#import "NoaChatViewController.h"
#import "NoaUserHomePageVC.h"

@interface NoaGroupMemberListVC ()<ZSearchViewDelegate,UITableViewDataSource,UITableViewDelegate,ZBaseCellDelegate>

@property (nonatomic, strong) NSMutableArray *reqFriendList;//从后台请求下来的数据集合
@property (nonatomic, strong) NSMutableArray *showFriendList;//展示的好友列表
@property (nonatomic, strong) NoaSearchView *viewSearch;
@property (nonatomic, copy) NSString *searchStr;
@property (nonatomic, copy) NSString * groupMemberTabName;

@end

@implementation NoaGroupMemberListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.reqFriendList = [NSMutableArray array];
    _showFriendList = [NSMutableArray array];
    
    [self setupNavUI];
    [self setupUI];
    
    //群内禁止私聊状态更新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupNoChatStatusChange:) name:@"GroupNoChatStatusChange" object:nil];
}

#pragma mark - 界面布局
- (void)setupNavUI {
    self.navTitleStr = LanguageToolMatch(@"群成员");
    self.navBtnRight.hidden = YES;
}

- (void)setGroupInfoModel:(LingIMGroup *)groupInfoModel {
    _groupInfoModel = groupInfoModel;
    //该群在本地存储群成员表的表名称
    self.groupMemberTabName = [NSString stringWithFormat:@"CIMSDKDB_%@_GroupMemberTable",self.groupInfoModel.groupId];
    LingIMGroupModel *localGroupModel = [IMSDKManager toolCheckMyGroupWith:self.groupInfoModel.groupId];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.groupInfoModel.groupId forKey:@"groupId"];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    [dict setValue:@(localGroupModel.lastSyncMemberTime) forKey:@"lastSyncTime"];
    
    __weak typeof(self) weakSelf = self;
    [IMSDKManager syncGroupMemberListWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSArray class]]) {
            NSArray *groupMemberDicArr = (NSArray *)data;
            
            for (NSDictionary *groupMemberDic in groupMemberDicArr) {
                LingIMGroupMemberModel *groupMemberModel = [LingIMGroupMemberModel mj_objectWithKeyValues:groupMemberDic];
                if (groupMemberModel.isDel) {
                    [DBTOOL deleteGroupMemberWithTabName:self.groupMemberTabName memberId:groupMemberModel.userUid];
                } else {
                    if(groupMemberModel.remarks == nil || [groupMemberModel.remarks isEqualToString:@""]){
                        if(![groupMemberModel.nicknameInGroup isEqualToString:@""] && groupMemberModel.nicknameInGroup){
                            groupMemberModel.showName = groupMemberModel.nicknameInGroup;
                        } else {
                            groupMemberModel.showName = groupMemberModel.userNickname;
                        }
                    } else{
                        groupMemberModel.showName = groupMemberModel.remarks;
                    }
                    if ( groupMemberModel.showName.length <= 0) {
                        groupMemberModel.showName = groupMemberModel.userNickname;
                    }
                    [DBTOOL insertOrUpdateGroupMemberModelWithTabName:self.groupMemberTabName memberModel:groupMemberModel];
                }
            }
            
            if (groupMemberDicArr.count > 0) {
                NSDictionary *groupMemberDic = (NSDictionary *)[groupMemberDicArr firstObject];
                long long latestUpdateTime = [[groupMemberDic objectForKey:@"latestUpdateTime"] longLongValue];
                localGroupModel.lastSyncMemberTime = latestUpdateTime;
                [IMSDKManager toolInsertOrUpdateGroupModelWith:localGroupModel];
            }
            
            [weakSelf setMemberListData];

        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessage:LanguageToolMatch(@"操作失败")];
    }];
}

- (void)setupUI {
    _viewSearch = [[NoaSearchView alloc] initWithPlaceholder:LanguageToolMatch(@"搜索群成员")];
    _viewSearch.frame = CGRectMake(0, DNavStatusBarH + DWScale(6), DScreenWidth, DWScale(38));
    _viewSearch.currentViewSearch = YES;
    _viewSearch.showClearBtn = YES;
    _viewSearch.returnKeyType = UIReturnKeyDefault;
    _viewSearch.delegate = self;
    [self.view addSubview:_viewSearch];
    
    [self.view addSubview:self.baseTableView];
    self.baseTableView.delegate = self;
    self.baseTableView.dataSource = self;
    self.baseTableView.mj_header = self.refreshHeader;
//    self.baseTableView.mj_footer = self.refreshFooter;
    self.baseTableView.delaysContentTouches = NO;
    [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-DHomeBarH);
        make.top.equalTo(_viewSearch.mas_bottom).offset(DWScale(6));
    }];
    
    [self.baseTableView registerClass:[NoaGroupMemberListCell class] forCellReuseIdentifier:[NoaGroupMemberListCell cellIdentifier]];
    [self.baseTableView registerClass:[NoaFriendListSectionHeaderView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([NoaFriendListSectionHeaderView class])];
    
    SCIndexViewConfiguration *configuration = [SCIndexViewConfiguration configurationWithIndexViewStyle:SCIndexViewStyleDefault];
    configuration.indexItemSelectedBackgroundColor = COLOR_5966F2;
    configuration.indexItemsSpace = DWScale(6);
    self.baseTableView.sc_indexViewConfiguration = configuration;
    self.baseTableView.sc_translucentForTableViewInNavigationBar = NO;
}

- (void)setMemberListData {
    //加载本地数据库换成的群成员表
    //群主
    LingIMGroupMemberModel *ownerModel = [IMSDKManager imSdkGetGroupOwnerWith:self.groupInfoModel.groupId exceptUserId:@""];
    if (ownerModel != nil) {
        [self.reqFriendList addObject:ownerModel];
    }
    //群管理
    NSArray *managerArr = [IMSDKManager imSdkGetGrouManagerWith:self.groupInfoModel.groupId exceptUserId:@""];
    if (managerArr != nil && managerArr.count > 0) {
        [self.reqFriendList addObjectsFromArray:managerArr];
    }
    //普通群成员
    NSArray *memberArr = [IMSDKManager imSdkGetGroupNomalMemberWith:self.groupInfoModel.groupId exceptUserId:@""];
    if (memberArr != nil && memberArr.count > 0) {
        [self.reqFriendList addObjectsFromArray:memberArr];
    }
    [self requestMemberListList];
}

- (void)requestMemberListList {
    [self.showFriendList removeAllObjects];
    if (![NSString isNil:_searchStr]) {
        //搜索联系人
        [self.showFriendList removeAllObjects];
        [self.showFriendList addObjectsFromArray:[DBTOOL checkGroupMemberWithTabName:self.groupMemberTabName searchContent:_searchStr exceptUserId:@""]];
    } else {
        //群组成员
        [self.showFriendList addObjectsFromArray:self.reqFriendList];
    }
    [self.baseTableView reloadData];
}

#pragma mark - ZSearchViewDelegate
- (void)searchViewTextValueChanged:(NSString *)searchStr {
    _searchStr = [searchStr trimString];
    [self requestMemberListList];
}

#pragma mark - ZBaseCellDelegate
- (void)cellClickAction:(NSIndexPath *)indexPath {
    
    //防止获取群信息接口失败，可以进行用户头像点击跳转
    if (!_groupInfoModel) return;
    
    LingIMGroupMemberModel *groupMemberModel = [self.showFriendList objectAtIndexSafe:indexPath.row];
    //机器人
    if (groupMemberModel.role == 3) return;
    
    if ([UserManager.userRoleAuthInfo.groupSecurity.configValue isEqualToString:@"true"]) {
        NoaUserHomePageVC *vc = [NoaUserHomePageVC new];
        vc.userUID = groupMemberModel.userUid;
        vc.groupID = self.groupInfoModel.groupId;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        //群开启了群内禁止私聊，普通群成员不可以进行用户头像点击跳转
        if (_groupInfoModel.isPrivateChat && _groupInfoModel.userGroupRole == 0) return;
        
        NoaUserHomePageVC *vc = [NoaUserHomePageVC new];
        vc.userUID = groupMemberModel.userUid;
        vc.groupID = self.groupInfoModel.groupId;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _showFriendList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaGroupMemberListCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupMemberListCell cellIdentifier] forIndexPath:indexPath];
    cell.baseDelegate = self;
    cell.baseCellIndexPath = indexPath;
    [cell cellConfigWithmodel:_showFriendList[indexPath.row] searchStr:_searchStr activityInfo:UserManager.activityConfigInfo isActivityEnable:self.groupInfoModel.isActiveEnabled];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [NoaGroupMemberListCell defaultCellHeight];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - 通知方法处理
//群内禁止私聊状态更新
- (void)groupNoChatStatusChange:(NSNotification *)sender {
    NSDictionary *groupNoChatDict = sender.userInfo;
    NSString *groupID = [groupNoChatDict objectForKeySafe:@"gid"];
    if ([groupID isEqualToString:_groupInfoModel.groupId]) {
        //当前群的 群内禁止私聊状态更新
        NSInteger status = [[groupNoChatDict objectForKeySafe:@"status"] integerValue];
        _groupInfoModel.isPrivateChat = status == 1 ? YES : NO;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
