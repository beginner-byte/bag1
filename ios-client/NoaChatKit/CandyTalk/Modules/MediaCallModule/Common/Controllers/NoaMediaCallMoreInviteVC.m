//
//  NoaMediaCallMoreInviteVC.m
//  NoaKit
//
//  Created by Candy on 2023/2/6.
//

#import "NoaMediaCallMoreInviteVC.h"
#import "NoaSearchView.h"
#import "NoaMediaCallMoreInviteCell.h"


@interface NoaMediaCallMoreInviteVC () <ZSearchViewDelegate, UITableViewDataSource, UITableViewDelegate, ZBaseCellDelegate>
@property (nonatomic, strong) NoaSearchView *viewSearch;//搜索控件
@property (nonatomic, strong) NSMutableArray *groupMemberList;//群成员列表
@property (nonatomic, strong) NSMutableArray *groupMemberShowList;//群成员展示列表
@property (nonatomic, strong) NSMutableArray *groupMemberSelectList;//选中成员id列表
@property (nonatomic, copy) NSString *searchStr;//搜索内容
@property (nonatomic, copy) NSString *groupMemberTabName;

@end

@implementation NoaMediaCallMoreInviteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _groupMemberList = [NSMutableArray array];
    _groupMemberShowList = [NSMutableArray array];
    _groupMemberSelectList = [NSMutableArray array];
    _searchStr = @"";
    _groupMemberTabName = [NSString stringWithFormat:@"CIMSDKDB_%@_GroupMemberTable",_groupID];
    [_groupMemberList addObjectsFromArray:[IMSDKManager imSdkGetAllGroupMemberWith:_groupID]];
    _groupMemberShowList = [_groupMemberList mutableCopy];
    
    [self setupNavUI];
    [self setupUI];
}
#pragma mark - 界面布局
- (void)setupNavUI {
    self.navTitleStr = LanguageToolMatch(@"选择成员");
    self.navBtnRight.hidden = NO;
    [self.navBtnRight setTitle:[NSString stringWithFormat:@"%@(%ld)",LanguageToolMatch(@"完成"), _currentRoomUser.count] forState:UIControlStateNormal];
    [self.navBtnRight setTitleColor:COLORWHITE forState:UIControlStateNormal];
    self.navBtnRight.tkThemebackgroundColors = @[COLOR_CCCCCC, COLOR_CCCCCC_DARK];
    self.navBtnRight.layer.cornerRadius = DWScale(12);
    self.navBtnRight.layer.masksToBounds = YES;
    CGRect textRect = [self.navBtnRight.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, DWScale(32)) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: FONTR(14)} context:nil];
    [self.navBtnRight mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.navTitleLabel);
        make.trailing.equalTo(self.navView).offset(-DWScale(20));
        make.height.mas_equalTo(DWScale(32));
        make.width.mas_equalTo(MIN(textRect.size.width + DWScale(28), 60));
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
    self.baseTableView.separatorColor = COLOR_CLEAR;
    [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-DHomeBarH);
        make.top.equalTo(_viewSearch.mas_bottom).offset(DWScale(6));
    }];
    
    [self.baseTableView registerClass:[NoaMediaCallMoreInviteCell class] forCellReuseIdentifier:[NoaMediaCallMoreInviteCell cellIdentifier]];
    self.baseTableView.delaysContentTouches = NO;
}
#pragma mark - 交互事件
- (void)navBtnRightClicked {

    if (_groupMemberSelectList.count > 0) {
        
        if (self.requestMore == 1) {
            //发起 群聊 音视频通话
            
            if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"0"]) {
                //LiveKit
                [self lkCallRequestForGroup];
            }else if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"1"]) {
                //即构
                [self zgCallRequestForGroup];
            }
            
        } else {
            //邀请加入 已创建好的群聊 音视频通话
            
            if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"0"]) {
                //LiveKit
                [self lkCallInviteForGroup];
            }else if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"1"]) {
                //即构
                [self zgCallInviteForGroup];
            }
        }
    }
}

#pragma mark - ZSearchViewDelegate
//输入框文本变化
- (void)searchViewTextValueChanged:(NSString *)searchStr {
    if ([NSString isNil:searchStr]) {
        _searchStr = @"";
        _groupMemberShowList = [_groupMemberList mutableCopy];
        [self.baseTableView reloadData];
    }
}
//回车
- (void)searchViewReturnKeySearch:(NSString *)searchStr {
    if (![NSString isNil:searchStr]) {
        _searchStr = [searchStr trimString];
        [_groupMemberShowList removeAllObjects];
        [_groupMemberShowList addObjectsFromArray:[DBTOOL checkGroupMemberWithTabName:self.groupMemberTabName searchContent:_searchStr exceptUserId:@""]];
        [self.baseTableView reloadData];
    }
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _groupMemberShowList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaMediaCallMoreInviteCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaMediaCallMoreInviteCell cellIdentifier] forIndexPath:indexPath];
    cell.baseCellIndexPath = indexPath;
    cell.baseDelegate = self;
    
    LingIMGroupMemberModel *model = [_groupMemberShowList objectAtIndexSafe:indexPath.row];
    NSString *modelUserID = [NSString stringWithFormat:@"%@", model.userUid];//用户ID
    
    ZMediaCallMoreInviteCellSelectedType selectedType;
    
    if ([_currentRoomUser containsObject:modelUserID]) {
        selectedType = ZMediaCallMoreInviteCellSelectedTypeDefault;
    }else if ([_groupMemberSelectList containsObject:modelUserID]) {
        selectedType = ZMediaCallMoreInviteCellSelectedTypeYes;
    }else {
        selectedType = ZMediaCallMoreInviteCellSelectedTypeNo;
    }
    [cell configCellWith:model searchString:_searchStr selected:selectedType];
    
    return cell;
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [NoaMediaCallMoreInviteCell defaultCellHeight];
}
#pragma mark - ZBaseCellDelegate
- (void)cellClickAction:(NSIndexPath *)indexPath {
    LingIMGroupMemberModel *model = [_groupMemberShowList objectAtIndexSafe:indexPath.row];
    
    if (![model.userUid isEqualToString:UserManager.userInfo.userUID]) {
        
        if ([_groupMemberSelectList containsObject:model.userUid]) {
            [_groupMemberSelectList removeObject:model.userUid];
        }else {
            [_groupMemberSelectList addObjectIfNotNil:model.userUid];
        }
        
        [self.baseTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        [self.navBtnRight setTitle:[NSString stringWithFormat:@"%@(%ld)",LanguageToolMatch(@"完成"), _groupMemberSelectList.count + 1] forState:UIControlStateNormal];
        CGRect textRect = [self.navBtnRight.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, DWScale(32)) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: FONTR(14)} context:nil];
        [self.navBtnRight mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.navTitleLabel);
            make.trailing.equalTo(self.navView).offset(-DWScale(20));
            make.height.mas_equalTo(DWScale(32));
            make.width.mas_equalTo(MIN(textRect.size.width+DWScale(28), 60));
        }];
        
        if (_groupMemberSelectList.count > 0) {
            self.navBtnRight.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
        }else {
            self.navBtnRight.tkThemebackgroundColors = @[COLOR_CCCCCC, COLOR_CCCCCC_DARK];
        }
    }
}

#pragma mark - LiveKit 多人音视频通话 发起
- (void)lkCallRequestForGroup {
    if ([NSString isNil:_groupID]) return;
    if ([NoaMediaCallManager sharedManager].mediaCallState != ZMediaCallStateEnd) return;
    
    
    NoaMediaCallOptions *callOptions = [NoaMediaCallOptions new];
    callOptions.callRoomType = ZIMCallRoomTypeGroup;//多人通话
    callOptions.callType = _callType;//通话类型
    callOptions.callRoleType = LingIMCallRoleTypeRequest;//发起者
    callOptions.inviterUid = UserManager.userInfo.userUID;//发起者uid
    callOptions.inviteeUidList = _groupMemberSelectList;//多人通话被邀请者(不包含自己)
    callOptions.groupId = _groupID;
    callOptions.callMicState = LingIMCallMicrophoneMuteStateOff;//音频打开
    callOptions.callCameraState = LingIMCallCameraMuteStateOff;//视频打开
    [NoaMediaCallManager sharedManager].currentCallOptions = callOptions;
    
    [[NoaMediaCallManager sharedManager] mediaCallGroupRequestWith:callOptions onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [NoaMediaCallManager sharedManager].mediaCallState = ZMediaCallStateBegin;
        
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [NoaMediaCallManager sharedManager].mediaCallState = ZMediaCallStateEnd;
    }];
    
}

#pragma mark - LiveKit 多人音视频通话 邀请
- (void)lkCallInviteForGroup {
    if ([NSString isNil:_groupID]) return;
    if ([NoaMediaCallManager sharedManager].mediaCallState == ZMediaCallStateEnd) return;
    
    WeakSelf
    NoaMediaCallOptions *currentOptions = [NoaMediaCallManager sharedManager].currentCallOptions;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:currentOptions.callHashKey forKey:@"hash"];
    [dict setValue:_groupMemberSelectList forKey:@"user_id"];
    [[NoaMediaCallManager sharedManager] mediaCallGroupInviteWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD showSuccessMessage:LanguageToolMatch(@"操作成功")];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

#pragma mark - 即构 多人音视频通话 发起
- (void)zgCallRequestForGroup {
    if ([NSString isNil:_groupID]) return;
    if ([NoaCallManager sharedManager].callState != ZCallStateEnd) return;
    [[NoaCallManager sharedManager] requestGroupCallWith:_groupMemberSelectList group:_groupID callType:_callType];
}

#pragma mark - 即构 多人音视频通话 邀请
- (void)zgCallInviteForGroup {
    if ([NSString isNil:_groupID]) return;
    
    if ([NoaCallManager sharedManager].callState == ZCallStateEnd) return;
    
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[NoaCallManager sharedManager].currentCallOptions.zgCallOptions.callID forKey:@"callId"];
    [dict setValue:_groupMemberSelectList forKey:@"friendIds"];
    [[NoaCallManager sharedManager] callGroupInviteWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD showSuccessMessage:LanguageToolMatch(@"操作成功")];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
    
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
