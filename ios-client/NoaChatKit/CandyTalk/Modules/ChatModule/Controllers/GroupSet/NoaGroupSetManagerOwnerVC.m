//
//  NoaGroupSetManagerOwnerVC.m
//  NoaKit
//
//  Created by Candy on 2026/11/15.
//

#import "NoaGroupSetManagerOwnerVC.h"
#import "NoaGroupManageCommonCell.h"
#import "NoaGroupManageManagerCell.h"
#import "NoaGroupChangeOwnerVC.h"
#import "NoaGroupSetGroupManagerVC.h"
#import "NoaMessageAlertView.h"

@interface NoaGroupSetManagerOwnerVC ()<UITableViewDataSource,UITableViewDelegate,ZBaseCellDelegate>

@property (nonatomic,strong)NSMutableArray * managerListArr;//管理员列表
@property (nonatomic,strong)NSMutableArray * managerListIDArr;//管理员ID列表

@end

@implementation NoaGroupSetManagerOwnerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.managerListArr = [NSMutableArray array];
    self.managerListIDArr = [NSMutableArray array];
    self.navTitleStr = LanguageToolMatch(@"设置群主/管理员");
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getGroupManagerListReq];
}

#pragma mark - 界面布局
- (void)setupUI {
    [self defaultTableViewUI];
    self.baseTableView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    self.baseTableView.dataSource = self;
    self.baseTableView.delegate = self;
    self.baseTableView.delaysContentTouches = NO;
    [self.baseTableView registerClass:[NoaGroupManageCommonCell class] forCellReuseIdentifier:[NoaGroupManageCommonCell cellIdentifier]];
    [self.baseTableView registerClass:[NoaGroupManageManagerCell class] forCellReuseIdentifier:[NoaGroupManageManagerCell cellIdentifier]];
}

- (void)getGroupManagerListReq{
    WeakSelf;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:self.groupInfoModel.groupId forKey:@"groupId"];
    if (![NSString isNil:UserManager.userInfo.userUID]) {
        [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    }
    [IMSDKManager groupGetManagerListWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [weakSelf.managerListArr removeAllObjects];
        [weakSelf.managerListIDArr removeAllObjects];
        if (data) {
            for (NSDictionary *groupMemberDic in data) {
                LingIMGroupMemberModel *groupMemberModel = [LingIMGroupMemberModel mj_objectWithKeyValues:groupMemberDic];
                [weakSelf.managerListArr addObject:groupMemberModel];
                [weakSelf.managerListIDArr addObject:groupMemberModel.userUid];
            }
            [weakSelf.baseTableView reloadData];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

- (void)cancelGroupManagerReq:(LingIMGroupMemberModel *)model{
    WeakSelf;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:self.groupInfoModel.groupId forKey:@"groupId"];
    [dict setObjectSafe:@[model.userUid] forKey:@"groupMemberUidList"];
    [dict setObjectSafe:@"2" forKey:@"operationType"];
    if (![NSString isNil:UserManager.userInfo.userUID]) {
        [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    }
    [IMSDKManager groupSetGroupManagerWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if (data) {
            LingIMGroupMemberModel *oldManagerMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:model.userUid groupID:weakSelf.groupInfoModel.groupId];
            oldManagerMemberModel.role = 0;
            [IMSDKManager imSdkInsertOrUpdateGroupMember:oldManagerMemberModel groupID:weakSelf.groupInfoModel.groupId];
            
            [HUD showMessage:LanguageToolMatch(@"取消群管理员成功")];
            [weakSelf getGroupManagerListReq];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

#pragma mark - ZBaseCellDelegate
- (void)cellClickAction:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            NoaGroupChangeOwnerVC * vc = [NoaGroupChangeOwnerVC new];
            vc.groupInfoModel = self.groupInfoModel;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            if (indexPath.row == 0) {
                NoaGroupSetGroupManagerVC * vc = [NoaGroupSetGroupManagerVC new];
                vc.groupInfoModel = self.groupInfoModel;
                vc.mangerIdArr = self.managerListIDArr;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return self.managerListArr.count+1;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            NoaGroupManageCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageCommonCell cellIdentifier] forIndexPath:indexPath];
            [cell cellConfigWith:GroupManageCellCommon itemStr:LanguageToolMatch(@"移交群主") model:self.groupInfoModel];
            [cell setCornerRadiusWithIsShow:YES location:CornerRadiusLocationAll];
            cell.baseCellIndexPath = indexPath;
            cell.baseDelegate = self;
            cell.viewLine.hidden = YES;
            return cell;
        }
            break;
        case 1:
        {
            if (indexPath.row == 0) {
                NoaGroupManageCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageCommonCell cellIdentifier] forIndexPath:indexPath];
                [cell cellConfigWith:GroupManageCellCommon itemStr:LanguageToolMatch(@"管理员") model:self.groupInfoModel];
                if (self.managerListArr.count > 0) {
                    [cell setCornerRadiusWithIsShow:YES location:CornerRadiusLocationTop];
                    cell.viewLine.hidden = NO;
                }else{
                    [cell setCornerRadiusWithIsShow:YES location:CornerRadiusLocationAll];
                    cell.viewLine.hidden = YES;
                }
                cell.baseCellIndexPath = indexPath;
                cell.baseDelegate = self;
                return cell;
            }else{
                WeakSelf;
                NoaGroupManageManagerCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageManagerCell cellIdentifier] forIndexPath:indexPath];
                if ((indexPath.row-1+1) == self.managerListArr.count) {
                    cell.viewLine.hidden = YES;
                    [cell setCornerRadiusWithIsShow:YES location:CornerRadiusLocationBottom];
                }else{
                    cell.viewLine.hidden = NO;
                    [cell setCornerRadiusWithIsShow:NO location:CornerRadiusLocationBottom];
                }
                [cell setTapCancelManagerBlock:^(LingIMGroupMemberModel * _Nonnull model) {
                    NoaMessageAlertView *msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeTitle supView:nil];
                    msgAlertView.lblTitle.text = LanguageToolMatch(@"取消管理员设置");
                    msgAlertView.lblContent.text = [NSString stringWithFormat:LanguageToolMatch(@"您正在取消 “%@” 的管理权限。"),model.nicknameInGroup];
                    msgAlertView.lblContent.textAlignment = NSTextAlignmentLeft;
                    [msgAlertView.btnSure setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
//                    [msgAlertView.btnSure setTkThemeTitleColor:@[COLOR_FF3333, COLOR_FF3333_DARK] forState:UIControlStateNormal];
//                    msgAlertView.btnSure.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F6F6F6_DARK];
                    [msgAlertView.btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
//                    [msgAlertView.btnCancel setTkThemeTitleColor:@[COLORWHITE, COLORWHITE_DARK] forState:UIControlStateNormal];
//                    msgAlertView.btnCancel.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
                    [msgAlertView alertShow];
                    msgAlertView.sureBtnBlock = ^(BOOL isCheckBox) {
                        [weakSelf cancelGroupManagerReq:model];
                    };
                }];
                [cell cellConfigWithmodel:self.managerListArr[indexPath.row-1]];
                return cell;
            }
        }
            break;
        default:
            return [UITableViewCell new];
            break;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            return [NoaGroupManageCommonCell defaultCellHeight];
        }
            break;
        case 1:
        {
            if (indexPath.row == 0) {
                return [NoaGroupManageCommonCell defaultCellHeight];
            }else{
                return [NoaGroupManageManagerCell defaultCellHeight];
            }
        }
            break;
        default:
            return [NoaGroupManageCommonCell defaultCellHeight];
            break;
    }
    return [NoaGroupManageCommonCell defaultCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DWScale(16))];
    viewHeader.backgroundColor = UIColor.clearColor;
    return viewHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return DWScale(16);
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
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
