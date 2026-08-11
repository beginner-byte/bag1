//
//  NoaChatHistoryChoiceUserVC.m
//  NoaKit
//
//  Created by Candy on 2024/8/12.
//

#import "NoaChatHistoryChoiceUserVC.h"
#import "NoaSearchView.h"
#import "NoaHistoryChoiceUserCell.h"
#import "NoaHistoryChoiceUseredTopView.h"

@interface NoaChatHistoryChoiceUserVC () <ZSearchViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NoaSearchView *viewSearch;//搜索控件
@property (nonatomic, strong) NoaHistoryChoiceUseredTopView *choiceTopView;//已选择的
@property (nonatomic, strong) NSMutableArray<NoaBaseUserModel *> *showUserList;//显示在界面上的数据
@property (nonatomic, strong) NSMutableArray<NoaBaseUserModel *> *allUserModel;//所有数据
@property (nonatomic, copy) NSString *searchStr;
@property (nonatomic, copy) NSString *groupMemberTabName;

@end

@implementation NoaChatHistoryChoiceUserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavUI];
    [self setupUI];
    [self setupLocalData];
    
    //顶部已选中有delete操作时，触发此通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(choicedUserDeleteAction:) name:@"ZChatHistoryChoiceUserDeleteActionNotification" object:nil];
}

- (void)setupNavUI {
    self.navTitleStr = LanguageToolMatch(@"选择");
    
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
    
    _choiceTopView = [[NoaHistoryChoiceUseredTopView alloc] init];
    _choiceTopView.choicedTopUserList = self.choicedList;
    [self.view addSubview:_choiceTopView];
    [_choiceTopView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(self.choicedList.count > 0 ? DWScale(95) : 0);
        make.top.mas_equalTo(_viewSearch.mas_bottom).offset(self.choicedList.count > 0 ? DWScale(16) : 0);
    }];
    
    [self.view addSubview:self.baseTableView];
    self.baseTableView.delegate = self;
    self.baseTableView.dataSource = self;
    self.baseTableView.delaysContentTouches = NO;
    [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-DHomeBarH);
        make.top.equalTo(_choiceTopView.mas_bottom).offset(DWScale(10));
    }];
    
    [self.baseTableView registerClass:[NoaHistoryChoiceUserCell class] forCellReuseIdentifier:[NoaHistoryChoiceUserCell cellIdentifier]];
}

#pragma mark - 初始化数据
- (void)setupLocalData {
    //单聊：好友+自己
    if (self.chatType == CIMChatType_SingleChat) {
        //好友
        LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:self.sessionID];
        if (friendModel && friendModel.disableStatus != 4) {
            NoaBaseUserModel *userModel = [[NoaBaseUserModel alloc] init];
            userModel.userId = friendModel.friendUserUID;
            userModel.name = friendModel.showName;
            userModel.avatar = friendModel.avatar;
            userModel.roleId = friendModel.roleId;
            [self.allUserModel addObject:userModel];
        }
        
        //自己
        NoaBaseUserModel *mineUserModel = [[NoaBaseUserModel alloc] init];
        mineUserModel.userId = UserManager.userInfo.userUID;
        mineUserModel.name = UserManager.userInfo.showName;
        mineUserModel.avatar = UserManager.userInfo.avatar;
        mineUserModel.roleId = UserManager.userInfo.roleId;
        [self.allUserModel addObject:mineUserModel];
    }
    
    //群聊：所有群成员
    if (self.chatType == CIMChatType_GroupChat) {
        NSMutableArray *remberList = [NSMutableArray array];
        //该群在本地存储群成员表的表名称
        self.groupMemberTabName = [NSString stringWithFormat:@"CIMSDKDB_%@_GroupMemberTable", self.sessionID];
        //加载本地数据库换成的群成员表
        //群主
        LingIMGroupMemberModel *ownerModel = [IMSDKManager imSdkGetGroupOwnerWith:self.sessionID exceptUserId:@""];
        if (ownerModel != nil) {
            [remberList addObject:ownerModel];
        }
        //群管理
        NSArray *managerArr = [IMSDKManager imSdkGetGrouManagerWith:self.sessionID exceptUserId:@""];
        if (managerArr != nil && managerArr.count > 0) {
            [remberList addObjectsFromArray:managerArr];
        }
        //普通群成员
        NSArray *memberArr = [IMSDKManager imSdkGetGroupNomalMemberWith:self.sessionID exceptUserId:@""];
        if (memberArr != nil && memberArr.count > 0) {
            [remberList addObjectsFromArray:memberArr];
        }
        for (LingIMGroupMemberModel *memberModel in remberList) {
            NoaBaseUserModel *userModel = [[NoaBaseUserModel alloc] init];
            userModel.userId = memberModel.userUid;
            userModel.name = memberModel.showName;
            userModel.avatar = memberModel.userAvatar;
            userModel.roleId = memberModel.roleId;
            [self.allUserModel addObject:userModel];
        }
    }
    
    self.showUserList = [self.allUserModel mutableCopy];
    [self.baseTableView reloadData];
    [self navBtnRightRefresh];
}

#pragma mark - 获取搜索数据
- (void)checkSearchList {
    //搜索
    if (![NSString isNil:self.searchStr]) {
        if (self.chatType == CIMChatType_SingleChat) {
            for (NoaBaseUserModel *model in self.allUserModel) {
                if ([model.name containsString:self.searchStr]) {
                    [self.showUserList addObject:model];
                }
            }
        }
        if (self.chatType == CIMChatType_GroupChat) {
            NSArray *searchList = [DBTOOL checkGroupMemberWithTabName:self.groupMemberTabName searchContent:_searchStr exceptUserId:@""];
            for (LingIMGroupMemberModel *memberModel in searchList) {
                NoaBaseUserModel *userModel = [[NoaBaseUserModel alloc] init];
                userModel.userId = memberModel.userUid;
                userModel.name = memberModel.showName;
                userModel.avatar = memberModel.userAvatar;
                userModel.roleId = memberModel.roleId;
                [self.showUserList addObject:userModel];
            }
        }
    } else {
        self.showUserList = [self.allUserModel mutableCopy];
    }
    
    [self.baseTableView reloadData];
}
#pragma mark - ZSearchViewDelegate
- (void)searchViewTextValueChanged:(NSString *)searchStr {
    _searchStr = [searchStr trimString];
    [self.showUserList removeAllObjects];
    [self checkSearchList];
}

#pragma mark - UI
- (void)navBtnRightRefresh {
    self.navBtnRight.tkThemebackgroundColors = @[COLOR_CCCCCC, COLOR_CCCCCC_DARK];
    if (self.choicedList.count > 0) {
        [self.navBtnRight setTitle:[NSString stringWithFormat:LanguageToolMatch(@"完成(%ld)"),self.choicedList.count] forState:UIControlStateNormal];
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

- (void)chatHistoryTopViewRefresh {
    [_choiceTopView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.choicedList.count > 0 ? DWScale(95) : 0);
        make.top.mas_equalTo(_viewSearch.mas_bottom).offset(self.choicedList.count > 0 ? DWScale(16) : 0);
    }];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    _choiceTopView.choicedTopUserList = self.choicedList;
}

#pragma mark - UITableViewDelegate UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.showUserList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [NoaHistoryChoiceUserCell defaultCellHeight];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaHistoryChoiceUserCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaHistoryChoiceUserCell cellIdentifier] forIndexPath:indexPath];
    NoaBaseUserModel *model = self.showUserList[indexPath.row];
    [cell cellConfigBaseUserWith:model search:_searchStr];
    cell.selectedUser = [self.choicedList containsObject:model];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NoaBaseUserModel *model = self.showUserList[indexPath.row];
    if ([self.choicedList containsObject:model]) {
        [self.choicedList removeObject:model];
    } else {
        [self.choicedList addObject:model];
    }
    
    [self.baseTableView reloadData];
    [self navBtnRightRefresh];
    [self chatHistoryTopViewRefresh];
}
#pragma mark - Action
- (void)navBtnRightClicked {
    if (self.choicedList.count < 1) return;
    
    if (_delegate && [_delegate respondsToSelector:@selector(chatHistoryChoicedUserList:)]) {
        [_delegate chatHistoryChoicedUserList:self.choicedList];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)choicedUserDeleteAction:(NSNotification *)sender{
    //更新list
    NSNumber *deleteNum = sender.object;
    [self.choicedList removeObjectAtIndex:[deleteNum integerValue]];
    [self.baseTableView reloadData];
    [self navBtnRightRefresh];
    [self chatHistoryTopViewRefresh];
}

#pragma mark - life cycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 懒加载
- (NSMutableArray<NoaBaseUserModel *> *)showUserList {
    if (_showUserList == nil) {
        _showUserList = [NSMutableArray array];
    }
    return _showUserList;
}

- (NSMutableArray<NoaBaseUserModel *> *)allUserModel {
    if (_allUserModel == nil) {
        _allUserModel = [[NSMutableArray alloc] init];
    }
    return _allUserModel;
}

- (NSMutableArray<NoaBaseUserModel *> *)choicedList {
    if (_choicedList == nil) {
        _choicedList = [NSMutableArray array];
    }
    return _choicedList;
}



@end
