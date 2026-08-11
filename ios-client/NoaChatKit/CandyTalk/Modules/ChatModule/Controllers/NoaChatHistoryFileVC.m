//
//  NoaChatHistoryFileVC.m
//  NoaKit
//
//  Created by Candy on 2023/2/2.
//

#import "NoaChatHistoryFileVC.h"
#import "NoaSearchView.h"
#import "NoaChatHistoryFileCell.h"
#import "NoaMessageAlertView.h"
#import "NoaMessageModel.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "NoaChatFileDetailViewController.h"
#import "NoaChatHistoryHeaderView.h"
#import "NoaChatHistoryChoiceUserVC.h"

@interface NoaChatHistoryFileVC ()<ZSearchViewDelegate,UITableViewDelegate,UITableViewDataSource,MGSwipeTableCellDelegate,ZChatHistoryFileCellDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate, ZChatHistoryHeaderViewDelegate, ZChatHistoryChoiceUserDelegate>

@property (nonatomic, strong) NSMutableArray *reqHistoryList;//从后台请求下来的数据集合
@property (nonatomic, strong) NSMutableArray *showHistoryList;//展示的好友列表
@property (nonatomic, strong) NoaSearchView *viewSearch;
@property (nonatomic, copy) NSString *searchStr;
@property (nonatomic, strong) NoaChatHistoryHeaderView *selectHeadView;

@end

@implementation NoaChatHistoryFileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.reqHistoryList = [NSMutableArray array];
    _showHistoryList = [NSMutableArray array];

    self.navView.hidden = YES;
    self.searchStr = @"";
    [self setupUI];
    
    [self requestHistoryReq];
    [self refreshHeaderView];
}

#pragma mark - 界面布局
- (void)setupUI {
    _viewSearch = [[NoaSearchView alloc] initWithPlaceholder:LanguageToolMatch(@"搜索")];
    _viewSearch.frame = CGRectMake(0, DWScale(6), DScreenWidth, DWScale(38));
    _viewSearch.currentViewSearch = YES;
    _viewSearch.showClearBtn = YES;
    _viewSearch.returnKeyType = UIReturnKeyDefault;
    _viewSearch.delegate = self;
    [self.view addSubview:_viewSearch];
    
    self.selectHeadView = [[NoaChatHistoryHeaderView alloc] init];
    self.selectHeadView.delegate = self;
    [self.view addSubview:self.selectHeadView];
    [self.selectHeadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.viewSearch.mas_bottom);
        make.leading.trailing.equalTo(self.view);
        make.height.mas_equalTo(DWScale(38));
    }];
    
    [self.view addSubview:self.baseTableView];
    self.baseTableView.delegate = self;
    self.baseTableView.dataSource = self;
    self.baseTableView.emptyDataSetSource = self;
    self.baseTableView.emptyDataSetDelegate = self;
    self.baseTableView.delaysContentTouches = NO;
    [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.selectHeadView.mas_bottom).offset(DWScale(6));
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-DHomeBarH);
    }];
    
    [self.baseTableView registerClass:[NoaChatHistoryFileCell class] forCellReuseIdentifier:[NoaChatHistoryFileCell cellIdentifier]];
}

- (void)refreshHeaderView{
    if (self.chatType == CIMChatType_GroupChat) {
        self.selectHeadView.hidden = self.groupInfo.closeSearchUser;
        [self.selectHeadView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.groupInfo.closeSearchUser ? DWScale(0) : DWScale(38));
        }];
    }
}

#pragma mark - 数据请求
- (void)requestHistoryReq{
    //获取文件聊天记录
    [self.showHistoryList removeAllObjects];
    [self.reqHistoryList removeAllObjects];
    self.reqHistoryList = [IMSDKManager toolGetChatMessageHistoryWith:_sessionID offset:0 messageType:@[@(CIMChatMessageType_FileMessage)] textMessageLike:@"" userIdList:@[]].mutableCopy;
    [self.showHistoryList addObjectsFromArray:self.reqHistoryList];
}

#pragma mark - ZSearchViewDelegate
- (void)searchViewTextValueChanged:(NSString *)searchStr {
    _searchStr = [searchStr trimString];
    [self checkLocalDBData];
}

#pragma mark - ZChatHistoryHeaderViewDelegate
- (void)headerClickAction {
    NoaChatHistoryChoiceUserVC *vc = [[NoaChatHistoryChoiceUserVC alloc] init];
    vc.choicedList = self.selectHeadView.userInfoList;
    vc.chatType = self.chatType;
    vc.sessionID = self.sessionID;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)headerResetAction {
    if([NSString isNil:self.searchStr]) {
        [self.showHistoryList removeAllObjects];
        [self.showHistoryList addObjectsFromArray:self.reqHistoryList];
        [self.baseTableView reloadData];
    } else {
        [self checkLocalDBData];
    }
}

#pragma mark - ZChatHistoryChoiceUserDelegate
- (void)chatHistoryChoicedUserList:(NSArray<NoaBaseUserModel *> *)selectedUserList {
    self.selectHeadView.userInfoList = [selectedUserList mutableCopy];
    if(self.selectHeadView.userInfoList.count <= 0 && [NSString isNil:self.searchStr]) {
        [self.showHistoryList removeAllObjects];
        [self.showHistoryList addObjectsFromArray:self.reqHistoryList];
        [self.baseTableView reloadData];
    } else {
        [self checkLocalDBData];
    }
}

#pragma mark - 搜索数据库
- (void)checkLocalDBData {
    NSMutableArray *userIdList = [NSMutableArray array];
    for (NoaBaseUserModel *userModel in self.selectHeadView.userInfoList) {
        [userIdList addObject:userModel.userId];
    }
    [self.showHistoryList removeAllObjects];
    self.showHistoryList = [IMSDKManager toolGetChatMessageHistoryWith:_sessionID offset:0 messageType:@[@(CIMChatMessageType_FileMessage)] textMessageLike:_searchStr userIdList:userIdList].mutableCopy;
    [self.baseTableView reloadData];
}

#pragma mark - DZNEmptyDataSetSource
//图片距离中心偏移量
- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return DWScale(-150);
}

//空态图片
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return ImgNamed(@"c_no_history_chat");
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *string = LanguageToolMatch(@"快去发送文件吧");
    NSMutableAttributedString *accessAttributeString  = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName:FONTR(16),NSForegroundColorAttributeName:COLOR_5966F2}];
    return accessAttributeString;
}

#pragma mark - MGSwipeTableCellDelegate
- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell canSwipe:(MGSwipeDirection)direction fromPoint:(CGPoint)point {
    return YES;
}

- (NSArray<UIView *> *)swipeTableCell:(MGSwipeTableCell *)cell swipeButtonsForDirection:(MGSwipeDirection)direction swipeSettings:(MGSwipeSettings *)swipeSettings expansionSettings:(MGSwipeExpansionSettings *)expansionSettings {
    
    swipeSettings.transition = MGSwipeTransitionBorder;//动画效果
    swipeSettings.enableSwipeBounces = NO;
    swipeSettings.allowsButtonsWithDifferentWidth = YES;
    
    expansionSettings.buttonIndex = -1;//可展开按钮索引，即滑动自动触发按钮下标
    expansionSettings.fillOnTrigger = NO;//是否填充
    expansionSettings.threshold = 1.0;//触发阈值
    
    NSIndexPath *cellIndex = [self.baseTableView indexPathForCell:cell];
    
    NoaIMChatMessageModel *model = [_showHistoryList objectAtIndexSafe:cellIndex.row];
    NoaMessageModel *newMsgModel = [[NoaMessageModel alloc] initWithMessageModel:model];
    WeakSelf
    if (direction == MGSwipeDirectionRightToLeft) {
        
//        MGSwipeButton *btnDelete = [MGSwipeButton buttonWithTitle:LanguageToolMatch(@"删除") icon:ImgNamed(@"s_session_delete") backgroundColor:HEXCOLOR(@"FF504E") callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
//            [weakSelf messageDeleteActionWithMsg:newMsgModel];
//            return NO;
//        }];
//        btnDelete.titleLabel.font = FONTR(12);
//        btnDelete.buttonWidth = DWScale(86);
//        [btnDelete setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:DWScale(6)];
//
//        return @[btnDelete];
        
        return nil;
        
    }else{
        return nil;;
    }
}

- (void)swipeTableCell:(MGSwipeTableCell *)cell didChangeSwipeState:(MGSwipeState)state gestureIsActive:(BOOL)gestureIsActive {
    NSString * str;
    switch (state) {
        case MGSwipeStateNone: str = @"None"; break;
        case MGSwipeStateSwippingLeftToRight: str = @"右滑"; break;
        case MGSwipeStateSwippingRightToLeft: str = @"左滑"; break;
        case MGSwipeStateExpandingLeftToRight: str = @"右滑展开"; break;
        case MGSwipeStateExpandingRightToLeft: str = @"左滑展开"; break;
    }
    DLog(@"手势状态:%@------%@",str, gestureIsActive ? @"开始" : @"结束");
}

#pragma mark - ZBaseCellDelegate
- (void)cellClickAction:(NSIndexPath *)indexPath {
    NoaIMChatMessageModel *model = [_showHistoryList objectAtIndexSafe:indexPath.row];
    NoaMessageModel *fileMsgModel = [[NoaMessageModel alloc] initWithMessageModel:model];
    //文件消息-文件详情
    NSString *foldPath = [NSString getFileDiectoryWithCustomPath:[NSString stringWithFormat:@"%@-%@",UserManager.userInfo.userUID, self.sessionID]];
    NSString *fileFullPath = [NSString stringWithFormat:@"%@/%@", foldPath, model.fileName];
    
    NoaChatFileDetailViewController *fileDetailVC = [[NoaChatFileDetailViewController alloc] init];
    fileDetailVC.fileMsgModel = fileMsgModel;
    fileDetailVC.fromSessionId = self.sessionID;
    fileDetailVC.localFilePath = fileFullPath;
    fileDetailVC.isShowRightBtn = YES;
    fileDetailVC.isFromCollcet = NO;
    [self.navigationController pushViewController:fileDetailVC animated:YES];
}

//删除
- (void)messageDeleteActionWithMsg:(NoaMessageModel *)msgModel {
    WeakSelf
    NoaMessageAlertView *msgAlertView;
    
    if (!self.groupInfo) {  //单聊
        msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeCheckBox supView:nil];
        msgAlertView.checkboxLblContent.text = LanguageToolMatch(@"从我和当前好友的设备删除");
    } else {    //群聊
        //1管理员;2群主
        if (self.groupInfo.userGroupRole == 2 || self.groupInfo.userGroupRole == 1) {
            msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeCheckBox supView:nil];
            msgAlertView.checkboxLblContent.text = LanguageToolMatch(@"从所有人设备中删除");
        } else if (self.groupInfo.userGroupRole == 0) { //自己只能删除自己，单向删除
            msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeNomal supView:nil];
        }
    }
    msgAlertView.lblContent.text = LanguageToolMatch(@"文件删除后将不会出现在您的聊天记录里，确认删除吗？");
    [msgAlertView.btnSure setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
    [msgAlertView.btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    [msgAlertView alertShow];
    msgAlertView.sureBtnBlock = ^(BOOL isCheckBox) {
        [weakSelf messageDeleteWithMsg:msgModel withDeleteType:isCheckBox ? ZMsgDeleteTypeBothWay : ZMsgDeleteTypeOneWay];
    };
}

//删除消息(单向/双向)
- (void)messageDeleteWithMsg:(NoaMessageModel *)msgModel withDeleteType:(ZMsgDeleteType)deleteType {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithInteger:msgModel.message.chatType],@"chatType",
                    msgModel.message.msgID,@"msgId",
                    [NSNumber numberWithInteger:deleteType],@"operationStatus",
                    self.sessionID,@"receiveId",
                    UserManager.userInfo.userUID,@"userUid",
                    msgModel.message.serviceMsgID,@"sMsgId",nil];

    WeakSelf
    [[NoaIMSDKManager sharedTool] deleteMessage:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        //接口成功后，删除本地
        BOOL isDelete = [IMSDKManager toolDeleteChatMessageWith:msgModel.message];
        if (isDelete) {
            //更新当前页面
            [weakSelf checkLocalDBData];
    
            //发送通知通知聊天页面刷新UI
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HistoryVCDeleteFileNotification" object:msgModel userInfo:@{@"deleteType": @(deleteType)}];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessage:LanguageToolMatch(@"消息删除失败")];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _showHistoryList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaChatHistoryFileCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaChatHistoryFileCell cellIdentifier] forIndexPath:indexPath];
    cell.delegate = self;
    cell.cellDelegate = self;
    cell.cellIndexPath = indexPath;
    [cell configCellWith:_showHistoryList[indexPath.row] searchContent:_searchStr];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [NoaChatHistoryFileCell defaultCellHeight];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}


@end
