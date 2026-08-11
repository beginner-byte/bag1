//
//  NoaFriendGroupManagerVC.m
//  NoaKit
//
//  Created by Candy on 2023/7/3.
//

#import "NoaFriendGroupManagerVC.h"
#import "NoaFriendGroupManagerCell.h"

#import "NoaFriendGroupAddView.h"
#import "NoaFriendGroupDeleteView.h"

@interface NoaFriendGroupManagerVC () <UITableViewDataSource, UITableViewDelegate, UITableViewDragDelegate, UITableViewDropDelegate, ZFriendGroupManagerCellDelegate, ZFriendGroupDeleteViewDelegate, ZBaseCellDelegate, NoaToolUserDelegate>
@property (nonatomic, strong) UIButton *btnFinish;
@property (nonatomic, strong) NSMutableArray *friendGroupList;
@end

@implementation NoaFriendGroupManagerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [IMSDKManager addUserDelegate:self];
    
    _friendGroupList = [IMSDKManager toolGetMyFriendGroupList].mutableCopy;
    
    [self setupNavUI];
    [self setupUI];
}
#pragma mark - 界面布局
- (void)setupNavUI {
    if (self.friendGroupCanEdit) {
        self.navBtnBack.hidden = YES;
        self.navTitleStr = LanguageToolMatch(@"分组管理");
        
        _btnFinish = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnFinish setTitle:LanguageToolMatch(@"完成") forState:UIControlStateNormal];
        _btnFinish.titleLabel.font = FONTR(18);
        [_btnFinish setTkThemeTitleColor:@[COLOR_CCCCCC, COLOR_CCCCCC_DARK] forState:UIControlStateNormal];
        [_btnFinish setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateSelected];
        _btnFinish.selected = NO;
        [_btnFinish addTarget:self action:@selector(navBtnBackClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.navView addSubview:_btnFinish];
        [_btnFinish mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.navTitleLabel);
            make.trailing.equalTo(self.navView).offset(-DWScale(16));
        }];
    }else {
        self.navTitleStr = LanguageToolMatch(@"移动分组");
    }
    
}
- (void)setupUI {
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_EEEEEE_DARK];
    
    UIView *viewAdd = [[UIView alloc] initWithFrame:CGRectMake(0, DNavStatusBarH + DWScale(16), DScreenWidth, DWScale(54))];
    viewAdd.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
    [self.view addSubview:viewAdd];
    
    UIButton *btnAdd = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAdd.frame = CGRectMake(0, 0, DScreenWidth, DWScale(54));
    btnAdd.tkThemebackgroundColors =  @[COLOR_CLEAR, COLOR_CLEAR];
    [btnAdd setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateHighlighted];
    [btnAdd addTarget:self action:@selector(btnAddClick) forControlEvents:UIControlEventTouchUpInside];
    [viewAdd addSubview:btnAdd];
    
    UIImageView *ivAdd = [[UIImageView alloc] initWithImage:ImgNamed(@"s_add_blue")];
    ivAdd.frame = CGRectMake(DWScale(16), DWScale(16), DWScale(22), DWScale(22));
    [viewAdd addSubview:ivAdd];
    
    UILabel *lblAdd = [UILabel new];
    lblAdd.text = LanguageToolMatch(@"添加分组");
    lblAdd.tkThemetextColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    lblAdd.font = FONTR(16);
    [viewAdd addSubview:lblAdd];
    [lblAdd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(ivAdd);
        make.leading.equalTo(ivAdd.mas_trailing).offset(DWScale(12));
    }];
    
    [self.view addSubview:self.baseTableView];
    self.baseTableView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_EEEEEE_DARK];
    self.baseTableView.dataSource = self;
    self.baseTableView.delegate = self;
    [self.baseTableView registerClass:[NoaFriendGroupManagerCell class] forCellReuseIdentifier:[NoaFriendGroupManagerCell cellIdentifier]];
    [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(viewAdd.mas_bottom).offset(DWScale(16));
        make.bottom.equalTo(self.view).offset(-DHomeBarH);
    }];
    
    if (self.friendGroupCanEdit) {
        self.baseTableView.dragDelegate = self;
        self.baseTableView.dropDelegate = self;
        self.baseTableView.dragInteractionEnabled = YES;
    }
}

#pragma mark - 交互事件
- (void)btnAddClick {
    NoaFriendGroupAddView *viewAdd = [NoaFriendGroupAddView new];
    [viewAdd addViewShow];
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _friendGroupList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LingIMFriendGroupModel *friendGroupModel = [_friendGroupList objectAtIndexSafe:indexPath.row];
    
    NoaFriendGroupManagerCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaFriendGroupManagerCell cellIdentifier] forIndexPath:indexPath];
    cell.delegate = self;
    cell.baseDelegate = self;
    cell.baseCellIndexPath = indexPath;
    [cell configCellWith:friendGroupModel canEdit:_friendGroupCanEdit];
    cell.viewLine.hidden = (indexPath.row == _friendGroupList.count - 1) ? YES : NO;
    if (!self.friendGroupCanEdit) {
        if ([_currentFriendGroupModel.ugUuid isEqualToString:friendGroupModel.ugUuid]) {
            cell.ivSelect.hidden = NO;
        }else {
            cell.ivSelect.hidden = YES;
        }
    }
    
    return cell;
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [NoaFriendGroupManagerCell defaultCellHeight];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    DLog(@"本次移动的Cell位置:%ld--->将要移动到的位置:%ld", sourceIndexPath.row, destinationIndexPath.row);
    //原分组
    LingIMFriendGroupModel *sourceFriendGroupModel = [_friendGroupList objectAtIndexSafe:sourceIndexPath.row];
    //目标分组
    LingIMFriendGroupModel *destinationFriendGroupModel = [_friendGroupList objectAtIndexSafe:destinationIndexPath.row];

    //接口调用
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    [dict setValue:sourceFriendGroupModel.ugUuid forKey:@"ugUuid"];
    [dict setValue:@(destinationFriendGroupModel.ugOrder) forKey:@"ugOrder"];
    WeakSelf
    [IMSDKManager updateFriendGroupWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        weakSelf.btnFinish.selected = YES;
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [weakSelf.baseTableView reloadData];
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

#pragma mark - UITableViewDragDelegate 拖拽
- (NSArray<UIDragItem *> *)tableView:(UITableView *)tableView itemsForBeginningDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath {
    return nil;
}
//确保拖拽在本程序中
- (BOOL)tableView:(UITableView *)tableView dragSessionIsRestrictedToDraggingApplication:(id<UIDragSession>)session {
    return YES;
}

#pragma mark - UITableViewDropDelegate 松开拖拽
- (void)tableView:(UITableView *)tableView performDropWithCoordinator:(id<UITableViewDropCoordinator>)coordinator {
}

#pragma mark - ZBaseCellDelegate
- (void)cellClickAction:(NSIndexPath *)indexPath {
    LingIMFriendGroupModel *friendGroupModel = [_friendGroupList objectAtIndexSafe:indexPath.row];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    [dict setValue:_friendID forKey:@"uguUserUid"];
    [dict setValue:friendGroupModel.ugUuid forKey:@"uguUgUuid"];
    WeakSelf
    [IMSDKManager updateFriendForFriendGroupWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        weakSelf.currentFriendGroupModel = friendGroupModel;
        [weakSelf.baseTableView reloadData];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

#pragma mark - ZFriendGroupManagerCellDelegate
- (void)friendGroupManagerDelete:(LingIMFriendGroupModel *)friendGroupModel {
    NoaFriendGroupDeleteView *viewDelete = [NoaFriendGroupDeleteView new];
    viewDelete.friendGroupModel = friendGroupModel;
    viewDelete.delegate = self;
    [viewDelete deleteViewShow];
}

- (void)friendGroupManagerChangeName:(LingIMFriendGroupModel *)friendGroupModel newFriendGroupName:(nonnull NSString *)friendGroupName{
    if (![NSString isNil:friendGroupName]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
        [dict setValue:friendGroupModel.ugUuid forKey:@"ugUuid"];
        [dict setValue:friendGroupName forKey:@"ugName"];
        WeakSelf
        [IMSDKManager updateFriendGroupWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            friendGroupModel.ugName = friendGroupName;
            [weakSelf.baseTableView reloadData];
            weakSelf.btnFinish.selected = YES;
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            [weakSelf.baseTableView reloadData];
            [HUD showMessageWithCode:code errorMsg:msg];
        }];
    }else {
        [HUD showMessage:LanguageToolMatch(@"请输入分组名")];
        [self.baseTableView reloadData];
    }
}

#pragma mark - ZFriendGroupDeleteViewDelegate
- (void)friendGroupDelete:(LingIMFriendGroupModel *)friendGroupDelete {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    [dict setValue:friendGroupDelete.ugUuid forKey:@"ugUuid"];
    WeakSelf
    [IMSDKManager deleteFriendGroupWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        
        [weakSelf.friendGroupList enumerateObjectsUsingBlock:^(LingIMFriendGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.ugUuid isEqualToString:friendGroupDelete.ugUuid]) {
                [weakSelf.friendGroupList removeObjectAtIndexSafe:idx];
                *stop = YES;
            }
        }];
        
        [weakSelf.baseTableView reloadData];
        weakSelf.btnFinish.selected = YES;
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
    
}

#pragma mark - CIMToolUserDelegate
- (void)imSdkUserFriendGroupChange {
    //延迟一会
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.friendGroupList = [IMSDKManager toolGetMyFriendGroupList].mutableCopy;
        [weakSelf.baseTableView reloadData];
    });
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
