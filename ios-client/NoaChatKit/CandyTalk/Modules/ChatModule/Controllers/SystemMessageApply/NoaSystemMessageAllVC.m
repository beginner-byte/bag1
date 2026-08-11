//
//  NoaSystemMessageAllVC.m
//  NoaKit
//
//  Created by Candy on 2023/5/10.
//

#import "NoaSystemMessageAllVC.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "NoaSystemMessageModel.h"
#import "NoaSystemMessageAllReviewCell.h"
#import "NoaUserHomePageVC.h"
#import "SyncMutableArray.h"
#import "NoaMessageAlertView.h"

@interface NoaSystemMessageAllVC () <UITableViewDataSource,UITableViewDelegate, DZNEmptyDataSetSource,DZNEmptyDataSetDelegate, ZSystemMessageAllReviewCellDelegate>

//全部通知列表
@property (nonatomic, strong) SyncMutableArray *systemRecordList;
//起始页
@property (nonatomic, assign) NSInteger pageNumber;

@end

@implementation NoaSystemMessageAllVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    self.navView.hidden = YES;
    [self setupUI];
    self.pageNumber = 1;
    
    //通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestListData) name:@"ZSystemMessageAllVCReloadListDataNotification" object:nil];
    
    [self requestListData];
}

- (void)setupUI {
    [self.view addSubview:self.baseTableView];
    self.baseTableView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    self.baseTableView.dataSource = self;
    self.baseTableView.delegate = self;
    self.baseTableView.emptyDataSetSource = self;
    self.baseTableView.emptyDataSetDelegate = self;
    self.baseTableView.separatorColor = COLOR_CLEAR;
    self.baseTableView.estimatedRowHeight = DWScale(146);
    self.baseTableView.rowHeight = UITableViewAutomaticDimension;//高度自适应
    [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    //添加上拉加载更多，分页
    self.baseTableView.mj_footer = self.refreshFooter;
    
    //cell
    [self.baseTableView registerClass:[NoaSystemMessageAllReviewCell class] forCellReuseIdentifier:NSStringFromClass([NoaSystemMessageAllReviewCell class])];
}

- (void)footerRefreshData {
    self.pageNumber += 1;
    [self requestListData];
}

#pragma mark - Net Working
- (void)requestListData {
    if (self.groupHelperType == ZGroupHelperFormTypeGroupManager) {
        [self requesJoinGroupApplyFormGropManager];
    }
    if (self.groupHelperType == ZGroupHelperFormTypeSessionList) {
        [self requesJoinGroupApplyFormSessionHelper];
    }
}
//从群管理进入，请求该群相关的入群申请
- (void)requesJoinGroupApplyFormGropManager {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:[NSNumber numberWithInteger:self.pageNumber] forKey:@"pageNumber"];
    [dict setObjectSafe:@(10) forKey:@"pageSize"];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    [dict setObjectSafe:self.groupId forKey:@"groupId"];
    
    [HUD showActivityMessage:@""];
    WeakSelf
    [IMSDKManager groupManagerApplyJoinGroupListWithData:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD hideHUD];
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDict = (NSDictionary *)data;
            NSInteger totalNum = [[dataDict objectForKey:@"total"] integerValue];
            NSArray *records = (NSArray *)[dataDict objectForKey:@"records"];
            if (weakSelf.pageNumber == 1) {
                [weakSelf.systemRecordList removeAllObjects];
            }
            NSArray *recordList = [NoaSystemMessageModel mj_objectArrayWithKeyValuesArray:records];
            [weakSelf.systemRecordList addObjectsFromArray:recordList];
            [weakSelf.baseTableView reloadData];
            if (weakSelf.systemRecordList.count == totalNum) {
                [weakSelf.baseTableView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [weakSelf.baseTableView.mj_footer endRefreshing];
            }
        }
        
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD hideHUD];
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

//从会话列表群助手进入，请求当前用户相关的群申请
- (void)requesJoinGroupApplyFormSessionHelper {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:[NSNumber numberWithInteger:self.pageNumber] forKey:@"pageNumber"];
    [dict setObjectSafe:@(10) forKey:@"pageSize"];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    
    [HUD showActivityMessage:@""];
    WeakSelf
    [IMSDKManager groupNotificationApplyJoinGroupListWithData:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD hideHUD];
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDict = (NSDictionary *)data;
            NSInteger totalNum = [[dataDict objectForKey:@"total"] integerValue];
            NSArray *records = (NSArray *)[dataDict objectForKey:@"records"];
            if (weakSelf.pageNumber == 1) {
                [weakSelf.systemRecordList removeAllObjects];
            }
            NSArray *recordList = [NoaSystemMessageModel mj_objectArrayWithKeyValuesArray:records];
            [weakSelf.systemRecordList addObjectsFromArray:recordList];
            [weakSelf.baseTableView reloadData];
            if (weakSelf.systemRecordList.count == totalNum) {
                [weakSelf.baseTableView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [weakSelf.baseTableView.mj_footer endRefreshing];
            }
        }
        
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD hideHUD];
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

//单条申请处理 通过/拒绝 （verfiyStatus 1:通过 2：拒绝）
- (void)requestHandleJoinGroupApplyWithStatus:(ZGroupApplyHandleStatus)handleStatus model:(NoaSystemMessageModel *)model {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:[NSNumber numberWithInteger:handleStatus] forKey:@"verfiyStatus"];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"verfiyUserId"];
    
    NSMutableDictionary *memreqParamsDic = [NSMutableDictionary dictionary];
    [memreqParamsDic setObjectSafe:model.groupId forKey:@"groupId"];
    [memreqParamsDic setObjectSafe:model.memreqUuid forKey:@"memreqUuid"];
    NSArray *memreqParamsArr = [NSArray arrayWithObject:memreqParamsDic];
    [dict setObjectSafe:memreqParamsArr forKey:@"memreqParams"];
    
    [HUD showActivityMessage:@""];
    WeakSelf
    [IMSDKManager groupJoinGroupApplyHandleWithData:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        NSArray *dataArr = (NSArray *)data;
        [weakSelf operationResultHandleWithModel:model resultArr:dataArr];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD hideHUD];
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

#pragma mark - request result handle
- (void)operationResultHandleWithModel:(NoaSystemMessageModel *)model resultArr:(NSArray *)resultArr {
    if (resultArr.count > 0) {
        NSDictionary *resultDict = (NSDictionary *)[resultArr firstObject];
        BOOL result = [[resultDict objectForKey:model.memreqUuid] boolValue];
        NSInteger beStatus = [[resultDict objectForKey:@"beStatus"] integerValue];
        if (result) {
            WeakSelf
            [self.systemRecordList.safeArray enumerateObjectsUsingBlock:^(NoaSystemMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.memreqUuid isEqualToString:model.memreqUuid]) {
                    obj.beStatus = beStatus;
                    [weakSelf.systemRecordList replaceObjectAtIndex:idx withObject:obj];
                }
            }];
            [HUD hideHUD];
            [self.baseTableView reloadData];
        } else {
            [HUD showMessage:LanguageToolMatch(@"操作失败")];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ZSystemMessagePendReviewVCReloadListDataNotification"
                                                            object:self];
    }
}

#pragma mark - Tableview delegate dataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.systemRecordList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //model
    NoaSystemMessageModel *model = (NoaSystemMessageModel *)[self.systemRecordList objectAtIndex:indexPath.row];
    //cell
    NoaSystemMessageAllReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NoaSystemMessageAllReviewCell class]) forIndexPath:indexPath];
    cell.baseCellIndexPath = indexPath;
    cell.fromType = self.groupHelperType;
    cell.delegate = self;//设置代理
    cell.model = model;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - ZGroupJoinApplyCellDelegate
//点击用户昵称或者头像跳转到个人资料详情页
- (void)systemMessageCellClickNickNameAction:(NSString *)userUid {
    NoaUserHomePageVC *vc = [NoaUserHomePageVC new];
    vc.userUID = userUid;
    vc.groupID = @"";
    [self.navigationController pushViewController:vc animated:YES];
}

//拒绝
- (void)refuseSystemMessageAllReviewAction:(NSIndexPath *)indexPath {
    NoaMessageAlertView *msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeNomal supView:nil];
    msgAlertView.lblContent.text = LanguageToolMatch(@"是否拒绝?");
    [msgAlertView.btnSure setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
    [msgAlertView.btnSure setTkThemeTitleColor:@[COLORWHITE,COLORWHITE] forState:UIControlStateNormal];
    msgAlertView.btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2];
    [msgAlertView.btnSure setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateSelected];
    [msgAlertView.btnSure setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateHighlighted];
    
    [msgAlertView.btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    [msgAlertView.btnCancel setTkThemeTitleColor:@[COLOR_66,COLORWHITE] forState:UIControlStateNormal];
    msgAlertView.btnCancel.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F5F6F9_DARK];
    [msgAlertView.btnCancel setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateSelected];
    [msgAlertView.btnCancel setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateHighlighted];
    [msgAlertView alertShow];
    WeakSelf
    msgAlertView.sureBtnBlock = ^(BOOL isCheckBox) {
        NoaSystemMessageModel *model = (NoaSystemMessageModel *)[self.systemRecordList objectAtIndex:indexPath.row];
        [weakSelf requestHandleJoinGroupApplyWithStatus:ZGroupApplyHandleStatusRefuse model:model];
    };
   
}

//同意
- (void)agreeSystemMessageAllReviewAgreeAction:(NSIndexPath *)indexPath {
    NoaMessageAlertView *msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeNomal supView:nil];
    msgAlertView.lblContent.text = LanguageToolMatch(@"是否同意?");
    [msgAlertView.btnSure setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
    [msgAlertView.btnSure setTkThemeTitleColor:@[COLORWHITE,COLORWHITE] forState:UIControlStateNormal];
    msgAlertView.btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2];
    [msgAlertView.btnSure setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateSelected];
    [msgAlertView.btnSure setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateHighlighted];
    
    [msgAlertView.btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    [msgAlertView.btnCancel setTkThemeTitleColor:@[COLOR_66,COLORWHITE] forState:UIControlStateNormal];
    msgAlertView.btnCancel.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F5F6F9_DARK];
    [msgAlertView.btnCancel setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateSelected];
    [msgAlertView.btnCancel setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateHighlighted];
    [msgAlertView alertShow];
    WeakSelf
    msgAlertView.sureBtnBlock = ^(BOOL isCheckBox) {
        NoaSystemMessageModel *model = (NoaSystemMessageModel *)[self.systemRecordList objectAtIndex:indexPath.row];
        [self requestHandleJoinGroupApplyWithStatus:ZGroupApplyHandleStatusAgree model:model];
    };
}

#pragma mark - DZNEmptyDataSetSource
//图片距离中心偏移量
- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return DWScale(-120);
}

//空态图片
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return ImgNamed(@"c_no_history_chat");
}

#pragma mark - DZNEmptyDataSetDelegate
//允许滑动
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}

#pragma mark - Lazy
- (SyncMutableArray *)systemRecordList {
    if (!_systemRecordList) {
        _systemRecordList = [[SyncMutableArray alloc] init];
    }
    return _systemRecordList;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
