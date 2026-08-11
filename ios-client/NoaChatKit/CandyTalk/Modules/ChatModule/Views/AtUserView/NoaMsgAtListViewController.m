//
//  NoaMsgAtListViewController.m
//  NoaKit
//
//  Created by Candy on 2026/12/5.
//

#import "NoaMsgAtListViewController.h"
#import "NoaToolManager.h"
#import "NoaSearchView.h"
#import "NoaAtUsetListCell.h"

#define Back_Max_Height        DWScale(560)
#define Back_Head_Height       DWScale(103)

@interface NoaMsgAtListViewController ()<ZSearchViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *reqAtList;    //从后台请求下来的数据集合
@property (nonatomic, strong) NSMutableArray *showAtList;   //展示的好友列表
//UI
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) NoaSearchView *viewSearch;
@property (nonatomic, copy) NSString *searchStr;
@property (nonatomic, copy) NSString *groupMemberTabName;
@property (nonatomic, assign) BOOL isShowKeyBoard;

@end

@implementation NoaMsgAtListViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //注册键盘出现通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    // 注册键盘隐藏通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 注销键盘出现通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    // 注销键盘隐藏通知
    [[NSNotificationCenter defaultCenter] removeObserver: self name:UIKeyboardWillHideNotification object: nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navView.hidden = YES;
    self.isShowKeyBoard = NO;
    [self setupUI];
    //该群在本地存储群成员表的表名称
    self.groupMemberTabName = [NSString stringWithFormat:@"CIMSDKDB_%@_GroupMemberTable",_sessionId];
    _reqAtList = [NSMutableArray array];
    _showAtList = [NSMutableArray array];
    
    //获取数据
    [self requestAtUserReq];
}

//展示
- (void)setupUI {
    self.view.tkThemebackgroundColors = @[[COLOR_00 colorWithAlphaComponent:0.3], [COLOR_00 colorWithAlphaComponent:0.6]];
    
    self.backView = [[UIView alloc] initWithFrame:CGRectZero];
    self.backView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    [self.backView rounded:20];
    [self.view addSubview:self.backView];
    
    UILabel *titleLbl = [[UILabel alloc] init];
    titleLbl.text = LanguageToolMatch(@"选择提醒的人");
    titleLbl.font = FONTN(18);
    titleLbl.tkThemetextColors = @[COLOR_11, COLORWHITE];
    titleLbl.textAlignment = NSTextAlignmentCenter;
    [self.backView addSubview:titleLbl];
    [titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backView).offset(DWScale(17));
        make.centerX.equalTo(self.backView);
        make.width.mas_equalTo(DWScale(180));
        make.height.mas_equalTo(DWScale(22));
    }];
    
    UIButton *closeBtn = [[UIButton alloc] init];
    [closeBtn setTkThemeImage:@[ImgNamed(@"g_arrow_down"), ImgNamed(@"g_arrow_down_dark")] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.backView).offset(DWScale(-17));
        make.centerY.equalTo(titleLbl);
        make.width.mas_equalTo(DWScale(30));
        make.height.mas_equalTo(DWScale(30));
    }];
            
    _viewSearch = [[NoaSearchView alloc] initWithPlaceholder:LanguageToolMatch(@"搜索")];
    _viewSearch.frame = CGRectMake(0, DWScale(55), DScreenWidth, DWScale(38));
    _viewSearch.currentViewSearch = YES;
    _viewSearch.showClearBtn = YES;
    _viewSearch.returnKeyType = UIReturnKeyDefault;
    _viewSearch.delegate = self;
    [self.backView addSubview:_viewSearch];
    
    self.baseTableView.delegate = self;
    self.baseTableView.dataSource = self;
    self.baseTableView.bounces = NO;
    self.baseTableView.tkThemeseparatorColors = @[COLORWHITE, COLOR_11];
    self.baseTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.backView addSubview:self.baseTableView];
    [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.backView);
        make.top.equalTo(_viewSearch.mas_bottom).offset(DWScale(10));
    }];
    [self.baseTableView registerClass:[NoaAtUsetListCell class] forCellReuseIdentifier:NSStringFromClass([NoaAtUsetListCell class])];
}

#pragma mark - 数据请求
//请求单聊的At好友列表
- (void)requestAtUserReq{
    //at用户列表
    if (_chatType == CIMChatType_SingleChat) {  //单聊
        LingIMFriendModel *friendUserModel = [IMSDKManager toolCheckMyFriendWith:self.sessionId];
        if (friendUserModel) {
            //对方
            NoaUserModel *friendModel = [[NoaUserModel alloc] init];
            friendModel.nickname = friendUserModel.nickname;
            friendModel.remarks = friendUserModel.remarks;
            friendModel.userUID = friendUserModel.friendUserUID;
            friendModel.avatar = friendUserModel.avatar;
            friendModel.roleId = friendUserModel.roleId;
            [self.reqAtList addObject:friendModel];
            //自己
            [self.reqAtList addObject:UserManager.userInfo];
            
            [self.showAtList removeAllObjects];
            [self.showAtList addObjectsFromArray:self.reqAtList];
            [self requestMemberListList];
        } else {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:self.sessionId forKey:@"userUid"];
            WeakSelf;
            [IMSDKManager getUserInfoWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                if ([data isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *userDict = (NSDictionary *)data;
                    //对方
                    NoaUserModel *friendModel = [[NoaUserModel alloc] init];
                    friendModel.nickname = [userDict objectForKeySafe:@"nickname"];
                    friendModel.userUID = [userDict objectForKeySafe:@"userUid"];
                    friendModel.avatar = [userDict objectForKeySafe:@"avatar"];
                    friendModel.roleId = [[userDict objectForKeySafe:@"roleId"] integerValue];
                    [weakSelf.reqAtList addObject:friendModel];
                    //自己
                    [weakSelf.reqAtList addObject:UserManager.userInfo];
                    
                    [weakSelf.showAtList removeAllObjects];
                    [weakSelf.showAtList addObjectsFromArray:weakSelf.reqAtList];
                    [weakSelf requestMemberListList];
                }
            } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                [weakSelf dismiss];
                [HUD showMessageWithCode:code errorMsg:msg];
                if (weakSelf.AtUserSelectClick) {
                    weakSelf.AtUserSelectClick(nil);
                }
            }];
        }
    } else {
        //加载本地数据库换成的群成员表
        [self.reqAtList addObjectsFromArray:[IMSDKManager imSdkGetAllGroupMemberWith:self.sessionId]];
        if (self.reqAtList.count > 0) {
            //所有数据获取后，在数据列表最前方添加 “所有人”
            //@所有人
            LingIMGroupMemberModel *allUser = [[LingIMGroupMemberModel alloc] init];
            allUser.userNickname = LanguageToolMatch(@"所有人");
            allUser.showName = LanguageToolMatch(@"所有人");
            allUser.nicknameInGroup = LanguageToolMatch(@"所有人");
            allUser.remarks = LanguageToolMatch(@"所有人");
            allUser.userUid = @"-1";
            allUser.userAvatar = @"c_msg_at_all";
            [self.reqAtList insertObject:allUser atIndex:0];
            
            [self requestMemberListList];
        } else {
            if (self.AtUserSelectClick) {
                self.AtUserSelectClick(nil);
            }
            [self dismiss];
        }
    }
}

#pragma mark - Keyboard Notification
-(void)keyboardWillShow:(NSNotification *) notification{
    self.isShowKeyBoard = YES;
    [self reloadAtUserTableShowKeyBoard];
}

-(void)keyboardWillHide: (NSNotification *) notification{
    self.isShowKeyBoard = NO;
    [self reloadAtUserTable];
}

//更新UI
- (void)reloadAtUserTableShowKeyBoard {
    self.backView.frame = CGRectMake(0, DScreenHeight - Back_Max_Height, DScreenWidth, Back_Max_Height);
    [self.view setNeedsLayout];
    
    [self.baseTableView reloadData];
}

- (void)reloadAtUserTable {
    //计算 @用户列表的高度，最高不超过 DWScale(560)
    CGFloat currentHeight = Back_Head_Height + DWScale(68) * _showAtList.count;
    CGFloat realityHeight = 0;
    if (currentHeight > Back_Max_Height) {
        realityHeight = Back_Max_Height;
    } else {
        realityHeight = currentHeight;
    }
    
    self.backView.frame = CGRectMake(0, DScreenHeight - realityHeight, DScreenWidth, realityHeight);
    [self.view setNeedsLayout];
    
    [self.baseTableView reloadData];
}

- (void)requestMemberListList {
    [self.showAtList removeAllObjects];
    if (![NSString isNil:_searchStr]) {
        //搜索联系人
        [self.showAtList removeAllObjects];
        if (_chatType == CIMChatType_SingleChat) {  //单聊
            for (NoaUserModel *userModel in self.reqAtList) {
                if ([userModel.nickname containsString:_searchStr] || [userModel.remarks containsString:_searchStr]) {
                    [self.showAtList addObject:userModel];
                }
            }
        } else {
            [self.showAtList addObjectsFromArray:[DBTOOL checkGroupMemberWithTabName:self.groupMemberTabName searchContent:_searchStr exceptUserId:@""]];
        }
    } else {
        //未搜索显示全部
        [self.showAtList addObjectsFromArray:self.reqAtList];
    }
    if (self.isShowKeyBoard) {
        [self reloadAtUserTableShowKeyBoard];
    } else {
        [self reloadAtUserTable];
    }
}

#pragma mark - ZSearchViewDelegate
- (void)searchViewTextValueChanged:(NSString *)searchStr {
    _searchStr = [searchStr trimString];
    [self requestMemberListList];
}

//回车
- (void)searchViewReturnKeySearch:(NSString *)searchStr {
    if (![NSString isNil:searchStr]) {
        _searchStr = [searchStr trimString];
        //搜索联系人
        [self.showAtList removeAllObjects];
        [self.showAtList addObjectsFromArray:[DBTOOL checkGroupMemberWithTabName:self.groupMemberTabName searchContent:_searchStr exceptUserId:@""]];
        
        if (self.isShowKeyBoard) {
            [self reloadAtUserTableShowKeyBoard];
        } else {
            [self reloadAtUserTable];
        }
    }
    [_viewSearch.tfSearch resignFirstResponder];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _showAtList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaAtUsetListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NoaAtUsetListCell class]) forIndexPath:indexPath];
   
    id cellModel = [_showAtList objectAtIndex:indexPath.row];
    [cell cellConfigWithmodel:cellModel searchStr:_searchStr];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DWScale(68);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    id clickModel = [_showAtList objectAtIndex:indexPath.row];
    if (_chatType == CIMChatType_SingleChat) {
        NoaUserModel *clickModel = (NoaUserModel *)clickModel;
    }
    if (_chatType == CIMChatType_GroupChat) {
        LingIMGroupMemberModel *clickModel = (LingIMGroupMemberModel *)clickModel;
    }
    if (self.AtUserSelectClick) {
        self.AtUserSelectClick(clickModel);
    }
    [self dismiss];
}

- (void)closeBtnAction{
    if (self.AtUserSelectClick) {
        self.AtUserSelectClick(nil);
    }
    [self dismiss];
}

//关闭
- (void)dismiss {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

@end
