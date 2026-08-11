//
//  NoaChatSingleSetVC.m
//  NoaKit
//
//  Created by Candy on 2026/11/4.
//

#import "NoaChatSingleSetVC.h"
#import "NoaBaseImageView.h"
#import "NoaChatKit-Swift.h"
#import "NoaMessageAlertView.h"

#import "NoaChatHistoryVC.h"
#import "NoaMessageTools.h"
#import "NoaUserHomePageVC.h"
#import "NoaChatSingleSetInfoCell.h"
#import "NoaChatSingleSetCommonCell.h"
#import "NoaChatKit-Swift.h"//Swift 投诉与支持

@interface NoaChatSingleSetVC ()<UITableViewDelegate,UITableViewDataSource,ZBaseCellDelegate>

@property (nonatomic, strong) LingIMFriendModel *friendModel;

@end

@implementation NoaChatSingleSetVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.friendModel = [IMSDKManager toolCheckMyFriendWith:self.friendUid];
    if (!self.friendModel) {
        [self requestUserInfo];
    }
    
    self.navTitleStr = LanguageToolMatch(@"设置");
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    
    [self setupUI];
}

#pragma mark - 界面布局
- (void)setupUI {
    
    [self defaultTableViewUI];
    self.baseTableView.dataSource = self;
    self.baseTableView.delegate = self;
    self.baseTableView.delaysContentTouches = NO;
    [self.baseTableView registerClass:[NoaChatSingleSetInfoCell class] forCellReuseIdentifier:[NoaChatSingleSetInfoCell cellIdentifier]];
    [self.baseTableView registerClass:[NoaChatSingleSetCommonCell class] forCellReuseIdentifier:[NoaChatSingleSetCommonCell cellIdentifier]];
}

#pragma mark - 数据请求
- (void)requestUserInfo {
    WeakSelf
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    [params setValue:self.friendUid forKey:@"friendUserUid"];
    [IMSDKManager getFriendInfoWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDict = (NSDictionary *)data;

            LingIMFriendModel *friendModel = [LingIMFriendModel mj_objectWithKeyValues:dataDict];
            friendModel.showName = friendModel.remarks.length > 0 ? friendModel.remarks : friendModel.nickname;
            [DBTOOL insertModelToTable:NoaChatDBFriendTableName model:friendModel];
            weakSelf.friendModel = friendModel;
            
        }
        [weakSelf.baseTableView reloadData];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

//会话置顶
- (void)sessionTop {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    if (self.friendModel.msgTop) {
        //取消置顶的操作
        [dict setValue:@(0) forKey:@"status"];
    }else {
        //置顶操作
        [dict setValue:@(1) forKey:@"status"];
    }
    
    //单聊
    [dict setValue:self.friendUid forKey:@"friendUserUid"];
    WeakSelf;
    [[NoaIMSDKManager sharedTool] singleConversationTop:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        //更新操作，已放在SDK里，用户无感实现
        //更新数据
        weakSelf.friendModel.msgTop = !weakSelf.friendModel.msgTop;
        [weakSelf.baseTableView reloadData];
        
        //会话置顶状态发生改变
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SessionTopStateChange" object:nil];
        
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

//会话消息免打扰
- (void)sessionPromt {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    
    if (self.friendModel.msgNoPromt) {
        //取消免打扰的操作
        [dict setValue:@(0) forKey:@"status"];
    }else {
        //免打扰操作
        [dict setValue:@(1) forKey:@"status"];
    }
    
    //单聊
    [dict setValue:self.friendUid forKey:@"friendUserUid"];
    WeakSelf;
    [[NoaIMSDKManager sharedTool] singleConversationPromt:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        //更新操作，已放在SDK里，用户无感实现
        //更新数据
        weakSelf.friendModel.msgNoPromt = !weakSelf.friendModel.msgNoPromt;
        [weakSelf.baseTableView reloadData];
        
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

#pragma mark - 交互事件
//清空聊天记录
- (void)requestClearSingleHistory {
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_friendUid forKey:@"receiveId"];
    [dict setValue:@(0) forKey:@"chatType"];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    
    [[NoaIMSDKManager sharedTool] clearChatMessageHistory:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        
        [NoaMessageTools clearChatLocalImgAndVideoFromSessionId:weakSelf.friendUid];
        [HUD showMessage:LanguageToolMatch(@"清除成功")];
        
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0://信息
            return 1;
            break;
        case 1://查找聊天记录、消息置顶、消息免打扰
            return 3;
            break;
        case 2://清空聊天记录
            if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"]) {
                return 1;
            } else {
                return 0;
            }
            break;
        case 3://投诉
            return 1;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WeakSelf
    if (indexPath.section == 0) {
        //个人
        NoaChatSingleSetInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaChatSingleSetInfoCell cellIdentifier] forIndexPath:indexPath];
        [cell cellConfigWithModel:self.friendModel];
        [cell setTapSingleInfoAddBlock:^{
            CoHereInviteFriendViewController *vc = [CoHereInviteFriendViewController new];
            vc.maxNum = 200;
            vc.minNum = 1;
            vc.friendUid = weakSelf.friendUid;
            vc.friendNickname = weakSelf.friendModel.showName;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }];
        
        [cell setTapHeaderBlock:^{
            NoaUserHomePageVC *vc = [NoaUserHomePageVC new];
            vc.userUID = weakSelf.friendUid;
            vc.groupID = @"";
            [self.navigationController pushViewController:vc animated:YES];
        }];
        return cell;
    }else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                {
                    NoaChatSingleSetCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaChatSingleSetCommonCell cellIdentifier] forIndexPath:indexPath];
                    [cell cellConfigWith:ChatSingleSetCellTypeCommon itemStr:LanguageToolMatch(@"查看聊天记录") model:self.friendModel];
                    cell.baseDelegate = self;
                    cell.viewLine.hidden = NO;
                    cell.baseCellIndexPath = indexPath;
                    [cell setCornerRadiusWithIsShow:YES location:CornerRadiusLocationTop];
                    return cell;
                }
                break;
            case 1:
                {
                    NoaChatSingleSetCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaChatSingleSetCommonCell cellIdentifier] forIndexPath:indexPath];
                    [cell cellConfigWith:ChatSingleSetCellTypeSelect itemStr:LanguageToolMatch(@"消息置顶") model:self.friendModel];
                    cell.baseDelegate = self;
                    cell.viewLine.hidden = NO;
                    cell.baseCellIndexPath = indexPath;
                    [cell setCornerRadiusWithIsShow:NO location:CornerRadiusLocationAll];
                    return cell;
                }
                break;
            case 2:
                {
                    NoaChatSingleSetCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaChatSingleSetCommonCell cellIdentifier] forIndexPath:indexPath];
                    [cell cellConfigWith:ChatSingleSetCellTypeSelect itemStr:LanguageToolMatch(@"消息免打扰") model:self.friendModel];
                    cell.baseDelegate = self;
                    cell.viewLine.hidden = YES;
                    cell.baseCellIndexPath = indexPath;
                    [cell setCornerRadiusWithIsShow:YES location:CornerRadiusLocationBottom];
                    return cell;
                }
                break;
                
            default:
                return [UITableViewCell new];
                break;
        }
    }else if (indexPath.section == 2) {
        NoaChatSingleSetCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaChatSingleSetCommonCell cellIdentifier] forIndexPath:indexPath];
        [cell cellConfigWith:ChatSingleSetCellTypeCommon itemStr:LanguageToolMatch(@"清空聊天记录") model:self.friendModel];
        cell.viewLine.hidden = YES;
        cell.baseDelegate = self;
        cell.baseCellIndexPath = indexPath;
        [cell setCornerRadiusWithIsShow:YES location:CornerRadiusLocationAll];
        cell.ivArrow.hidden = YES;
        return cell;
    }else if (indexPath.section == 3) {
        NoaChatSingleSetCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaChatSingleSetCommonCell cellIdentifier] forIndexPath:indexPath];
        [cell cellConfigWith:ChatSingleSetCellTypeCommon itemStr:LanguageToolMatch(@"投诉与支持") model:self.friendModel];
        cell.baseDelegate = self;
        cell.viewLine.hidden = YES;
        cell.baseCellIndexPath = indexPath;
        [cell setCornerRadiusWithIsShow:YES location:CornerRadiusLocationAll];
        cell.ivArrow.hidden = NO;
        return cell;
    }else {
        return [UITableViewCell new];
    }
}

#pragma mark - ZBaseCellDelegate
- (void)cellClickAction:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            break;
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    //查看聊天记录
                    NoaChatHistoryVC *vc = [NoaChatHistoryVC new];
                    vc.chatType = CIMChatType_SingleChat;
                    vc.sessionID = _friendUid;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 1:
                {
                    //消息置顶
                    [self sessionTop];
                }
                    break;
                case 2:
                {
                    //消息免打扰
                    [self sessionPromt];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 2:
        {
            //清空聊天记录
            if (![NSString isNil:_friendUid]) {
                NoaMessageAlertView *msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeNomal supView:nil];
                msgAlertView.lblContent.text = LanguageToolMatch(@"清空聊天记录");
                [msgAlertView.btnSure setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
                [msgAlertView.btnSure setTkThemeTitleColor:@[COLOR_FF3333,COLOR_FF3333] forState:UIControlStateNormal];
                msgAlertView.btnSure.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_66];
                [msgAlertView.btnSure setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateSelected];
                [msgAlertView.btnSure setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateHighlighted];
                
                [msgAlertView.btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
                [msgAlertView.btnCancel setTkThemeTitleColor:@[COLORWHITE,COLORWHITE] forState:UIControlStateNormal];
                msgAlertView.btnCancel.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2];
                [msgAlertView.btnCancel setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateSelected];
                [msgAlertView.btnCancel setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateHighlighted];
                [msgAlertView alertShow];
                WeakSelf
                msgAlertView.sureBtnBlock = ^(BOOL isCheckBox) {
                    [weakSelf requestClearSingleHistory];
                };
            }
        }
            break;
        case 3:
        {
            //投诉与支持(单聊，投诉好友)
            CoHereComplainViewController *vc = [CoHereComplainViewController new];
            vc.complainID = self.friendUid;
            vc.complainType = CIMChatType_SingleChat;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return [NoaChatSingleSetInfoCell defaultCellHeight];
            break;
        case 1:
        case 2:
        case 3:
            return [NoaChatSingleSetCommonCell defaultCellHeight];
            break;
        default:
            return CGFLOAT_MIN;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 2) {
        if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"]) {
            UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DWScale(16))];
            viewHeader.backgroundColor = UIColor.clearColor;
            return viewHeader;
        } else {
            return nil;
        }
    } else {
        UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DWScale(16))];
        viewHeader.backgroundColor = UIColor.clearColor;
        return viewHeader;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 2) {
        if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"true"]) {
            return DWScale(16);
        } else {
            return CGFLOAT_MIN;
        }
    } else {
        return DWScale(16);
    }
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
