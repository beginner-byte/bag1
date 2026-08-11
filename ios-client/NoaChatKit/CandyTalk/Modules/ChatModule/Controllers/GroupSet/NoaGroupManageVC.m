//
//  NoaGroupManageVC.m
//  NoaKit
//
//  Created by Candy on 2026/11/14.
//

#import "NoaGroupManageVC.h"
#import "NoaGroupManageCommonCell.h"
#import "NoaGroupManageMemberCell.h"
#import "NoaGroupManageContentCell.h"
#import "NoaChatSetGroupCommonCell.h"
#import "NoaGroupSetManagerOwnerVC.h"
#import "NoaGroupSetNotalkMemberVC.h"
#import "NoaMessageAlertView.h"
#import "NoaGroupNotalkMemberModel.h"
#import "NoaMessageTools.h"
#import "NoaSystemMessageVC.h"
#import "NoaRobotListViewController.h"

@interface NoaGroupManageVC ()<UITableViewDataSource,UITableViewDelegate,ZBaseCellDelegate>

@property (nonatomic,assign)BOOL isOpenAllMenmberNotalk;//是否开启全员禁言
@property (nonatomic,strong)NSMutableArray * notalkListArr;//禁言列表
@property (nonatomic,strong)NSMutableArray * notaklListIdArr;//禁言成员ID列表

@end

@implementation NoaGroupManageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.notalkListArr = [NSMutableArray array];
    self.notaklListIdArr = [NSMutableArray array];
    self.navTitleStr = LanguageToolMatch(@"群管理");
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    
    [self setupUI];
    
    [self requestRobotCount];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requsetGroupNotalkState];
}

//查询群机器人数量
-(void)requestRobotCount {
    WeakSelf
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.groupInfoModel.groupId forKey:@"groupId"];
    [[NoaIMSDKManager sharedTool] groupGetRobotCountWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        DLog(@"查询群机器人数量===%@",data);
        NSString *robotCount = [NSString stringWithFormat:@"%@",data];
        if([robotCount integerValue] >= 0){
            weakSelf.groupInfoModel.robotCount = [robotCount integerValue];
            [weakSelf.baseTableView reloadData];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

//请求单人禁言列表
- (void)requsetGroupNotalkState{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.groupInfoModel.groupId forKey:@"groupId"];
    if (![NSString isNil:UserManager.userInfo.userUID]) {
        [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    }
    WeakSelf;
    [IMSDKManager groupGetUserNotalkStateWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        weakSelf.isOpenAllMenmberNotalk = [[data objectForKeySafe:@"isGroupChat"] boolValue];
        if (![NSString isNil:UserManager.userInfo.userUID]) {
            [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
        }
        [IMSDKManager groupGetNotalkListWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            [weakSelf.notalkListArr removeAllObjects];
            [weakSelf.notaklListIdArr removeAllObjects];
            for (NSDictionary * notalkMemberDic in data) {
                NoaGroupNotalkMemberModel *model = [NoaGroupNotalkMemberModel mj_objectWithKeyValues:notalkMemberDic];
                model.groupId = weakSelf.groupInfoModel.groupId;
                [weakSelf.notalkListArr addObject:model];
                [weakSelf.notaklListIdArr addObject:model.forbidUserUid];
            }
            [weakSelf.baseTableView reloadData];
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            [HUD showMessageWithCode:code errorMsg:msg];
        }];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

- (void)cancelNotalkReq:(NoaGroupNotalkMemberModel *)model{
    WeakSelf;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:@"1" forKey:@"expireTime"];
    [dict setObjectSafe:@[model.forbidUserUid] forKey:@"forbidUidList"];
    [dict setObjectSafe:self.groupInfoModel.groupId forKey:@"groupId"];
    [dict setObjectSafe:@"0" forKey:@"operationType"];
    if (![NSString isNil:UserManager.userInfo.userUID]) {
        [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    }
    [IMSDKManager groupSetNotalkMemberWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if (data) {
            [weakSelf requsetGroupNotalkState];
            [HUD showMessage:LanguageToolMatch(@"成员解除禁言成功")];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

- (void)openAllNoTalkReq{
    WeakSelf;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:self.groupInfoModel.groupId forKey:@"groupId"];
    [dict setObjectSafe:self.isOpenAllMenmberNotalk ?@"0" :@"1" forKey:@"operationType"];
    if (![NSString isNil:UserManager.userInfo.userUID]) {
        [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    }
    [IMSDKManager groupSetNotalkAllWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if (data) {
            [HUD showMessage:self.isOpenAllMenmberNotalk ?LanguageToolMatch(@"关闭全员禁言") :LanguageToolMatch(@"开启全员禁言")];
            [weakSelf requsetGroupNotalkState];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

- (void)dissolutionGroupReq{
    LingIMSessionModel *model = [IMSDKManager toolCheckMySessionWith:self.groupInfoModel.groupId];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.groupInfoModel.groupId forKey:@"groupId"];
    if (![NSString isNil:UserManager.userInfo.userUID]) {
        [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    }
    WeakSelf;
    [IMSDKManager groupDissolutionGroupWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if (data) {
            [weakSelf deleteSessionAndChatMessage:model];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

//删除会话 + 清空聊天内容
- (void)deleteSessionAndChatMessage:(LingIMSessionModel *)model {
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.groupInfoModel.groupId forKey:@"peerUid"];
    //群聊
    [dict setValue:@(1) forKey:@"dialogType"];
    if (![NSString isNil:UserManager.userInfo.userUID]) {
        [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    }
    
    [[NoaIMSDKManager sharedTool] deleteServerConversation:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        //删除本地聊天记录 删除本地会话
        [IMSDKManager toolDeleteSessionModelWith:model andDeleteAllChatModel:YES];
        //清除缓存
        [NoaMessageTools clearChatLocalImgAndVideoFromSessionId:weakSelf.groupInfoModel.groupId];
        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        [HUD showMessage:LanguageToolMatch(@"群组解散成功")];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

//群新成员可查看历史记录 关闭/开启 开关操作
- (void)changeGroupNewMemberCheckHistoryStatus {
    //群新成员可查看历史记录(1:开启,0:关闭)
    NSInteger isShowHistoryStatus;
    if (self.groupInfoModel.isShowHistory == 1) {
        isShowHistoryStatus = 0;//关闭
    } else {
        isShowHistoryStatus = 1;//开启
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:[NSNumber numberWithInteger:isShowHistoryStatus] forKey:@"status"];
    //群聊
    [dict setObjectSafe:self.groupInfoModel.groupId forKey:@"groupId"];
    if (![NSString isNil:UserManager.userInfo.userUID]) {
        [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    }
    WeakSelf
    [[NoaIMSDKManager sharedTool] groupNewMemberCheckHistoryStatusWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        BOOL isResult = [data boolValue];
        if (isResult) {
            weakSelf.groupInfoModel.isShowHistory = isShowHistoryStatus;
            [weakSelf.baseTableView reloadData];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

//群提示 关闭/开启 开关操作
- (void)changeGroupRemindSwitchStatus {
    //是否开启群提示开关(1:开启,0:关闭)
    NSInteger newGroupRemindStatus;
    if (self.groupInfoModel.isMessageInform == 1) {
        newGroupRemindStatus = 0;//关闭，显示提示消息
    } else {
        newGroupRemindStatus = 1;//开启，隐藏提示消息
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:[NSNumber numberWithInteger:newGroupRemindStatus] forKey:@"status"];
    //群聊
    [dict setObjectSafe:self.groupInfoModel.groupId forKey:@"groupId"];
    if (![NSString isNil:UserManager.userInfo.userUID]) {
        [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    }
    WeakSelf
    [[NoaIMSDKManager sharedTool] groupUpdateGroupRemindSwitchStatusWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        BOOL isResult = [data boolValue];
        if (isResult) {
            weakSelf.groupInfoModel.isMessageInform = newGroupRemindStatus;
            [weakSelf.baseTableView reloadData];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

//群二维码 关闭/开启 开关操作
- (void)changeGroupQRCodeSwitchStatus {
    //是否开启群提示开关(1:开启,0:关闭)
    NSInteger newGroupQRCodeStatus;
    if (self.groupInfoModel.isShowQrCode) {
        newGroupQRCodeStatus = 0;//关闭
    } else {
        newGroupQRCodeStatus = 1;//开启
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:[NSNumber numberWithInteger:newGroupQRCodeStatus] forKey:@"isShowQrCode"];
    //群聊
    [dict setObjectSafe:self.groupInfoModel.groupId forKey:@"groupId"];
    if (![NSString isNil:UserManager.userInfo.userUID]) {
        [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    }
    WeakSelf
    [[NoaIMSDKManager sharedTool] groupUpdateIsShowQrCodeWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        BOOL isResult = [data boolValue];
        if (isResult) {
            weakSelf.groupInfoModel.isShowQrCode = newGroupQRCodeStatus == 0 ? NO : YES;
            [weakSelf.baseTableView reloadData];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

//音视频通话 开关操作
- (void)changeAudioAndVideoCallEnableStatus {
    //是否开启全员禁止拨打音视频(1:开启,0:关闭)
    NSInteger newNetCallStatus;
    if (self.groupInfoModel.isNetCall) {
        newNetCallStatus = 0;//关闭禁止开关
    } else {
        newNetCallStatus = 1;//开启禁止开关
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:[NSNumber numberWithInteger:newNetCallStatus] forKey:@"status"];
    //群聊
    [dict setObjectSafe:self.groupInfoModel.groupId forKey:@"groupId"];
    if (![NSString isNil:UserManager.userInfo.userUID]) {
        [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    }
    WeakSelf
    [[NoaIMSDKManager sharedTool] groupUpdateAudioAndVideoCallStatusWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        BOOL isResult = [data boolValue];
        if (isResult) {
            if (newNetCallStatus == 0) {
                //开关未开启，未开启全员静止拨打音视频，可以拨打音视频
                weakSelf.groupInfoModel.isNetCall = NO;
            } else {
                //开关开启，开启全员静止拨打音视频，不可以拨打音视频
                weakSelf.groupInfoModel.isNetCall = YES;
            }
            [weakSelf.baseTableView reloadData];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

//群活跃等级 开关操作
- (void)changeActivityLevelEnableStatus {
    //是否开启群活跃等级(1:开启,0:关闭)
    NSInteger isActivityEnable;
    if (self.groupInfoModel.isActiveEnabled == 1) {
        isActivityEnable = 0;//关闭群活跃等级
    } else {
        isActivityEnable = 1;//开启群活跃等级
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:[NSNumber numberWithInteger:isActivityEnable] forKey:@"isActiveEnabled"];
    [dict setObjectSafe:self.groupInfoModel.groupId forKey:@"groupId"];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
 
    WeakSelf
    [[NoaIMSDKManager sharedTool] groupUpdateActivityLevelEnableStatusWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        BOOL isResult = [data boolValue];
        if (isResult) {
            weakSelf.groupInfoModel.isActiveEnabled = isActivityEnable;
            [weakSelf.baseTableView reloadData];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}


#pragma mark - 界面布局
- (void)setupUI {
    [self defaultTableViewUI];
    self.baseTableView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    self.baseTableView.dataSource = self;
    self.baseTableView.delegate = self;
    self.baseTableView.delaysContentTouches = NO;
    [self.baseTableView registerClass:[NoaGroupManageCommonCell class] forCellReuseIdentifier:[NoaGroupManageCommonCell cellIdentifier]];
    [self.baseTableView registerClass:[NoaGroupManageMemberCell class] forCellReuseIdentifier:[NoaGroupManageMemberCell cellIdentifier]];
    [self.baseTableView registerClass:[NoaGroupManageContentCell class] forCellReuseIdentifier:[NoaGroupManageContentCell cellIdentifier]];
    [self.baseTableView registerClass:[NoaChatSetGroupCommonCell class] forCellReuseIdentifier:[NoaChatSetGroupCommonCell cellIdentifier]];
}

#pragma mark - ZBaseCellDelegate
- (void)cellClickAction:(NSIndexPath *)indexPath {
    if (self.groupInfoModel.userGroupRole == 1) {
        //管理员
        if (indexPath.section == 0) {
            //群机器人
            NoaRobotListViewController * robotVc = [NoaRobotListViewController new];
            robotVc.groupInfoModel = self.groupInfoModel;
            [self.navigationController pushViewController:robotVc animated:YES];
        } else if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                //全员禁言操作
                [self openAllNoTalkReq];
            }else if (indexPath.row == 1) {
                //单人禁言操作
                NoaGroupSetNotalkMemberVC * vc = [NoaGroupSetNotalkMemberVC new];
                vc.groupInfoModel = self.groupInfoModel;
                vc.notalkFriendIDArr = [NSArray arrayWithArray:self.notaklListIdArr];
                [self.navigationController pushViewController:vc animated:YES];
            }
        } else if (indexPath.section == 2) {
            //群活跃等级
            [self changeActivityLevelEnableStatus];
        } else if (indexPath.section == 3) {
            if (indexPath.row == 0) {
                //群私密操作
                [self changeGroupPrivateChat];
            } else if (indexPath.row == 1) {
                //群聊邀请确认操作
                [self changeGroupInviteConfirm];
            } else {
                if (self.groupInfoModel.isNeedVerify) {
                    if (indexPath.row == 2) {
                        //邀请进群申请列表
                        [self navToJoinGroupApplyList];
                    } else {
                        //新成员可查看历史记录
                        [self changeGroupNewMemberCheckHistoryStatus];
                    }
                } else {
                    //新成员可查看历史记录
                    [self changeGroupNewMemberCheckHistoryStatus];
                }
                
            }
        } else {
            if (indexPath.row == 0) {
                //关闭/开启 群提示
                [self changeGroupRemindSwitchStatus];
            } else {
                if ([ZHostTool.appSysSetModel.enableAudioAndVideoCalls isEqualToString:@"1"]) {
                    if (indexPath.row == 1) {
                        //是否开启全员禁止拨打音视频
                        [self changeAudioAndVideoCallEnableStatus];
                    } else {
                        //群二维码
                        [self changeGroupQRCodeSwitchStatus];
                    }
                } else {
                    //群二维码
                    [self changeGroupQRCodeSwitchStatus];
                }
            }
            
        }
                
    } else if (self.groupInfoModel.userGroupRole == 2) {
        if ([ZHostTool.appSysSetModel.enableAudioAndVideoCalls isEqualToString:@"1"]) {
            //群主
            if (indexPath.section == 0) {
                //设置群主/管理员操作
                NoaGroupSetManagerOwnerVC * vc = [NoaGroupSetManagerOwnerVC new];
                vc.groupInfoModel = self.groupInfoModel;
                [self.navigationController pushViewController:vc animated:YES];
            } else if (indexPath.section == 1) {
                //群机器人
                NoaRobotListViewController * robotVc = [NoaRobotListViewController new];
                robotVc.groupInfoModel = self.groupInfoModel;
                [self.navigationController pushViewController:robotVc animated:YES];
            } else if (indexPath.section == 2) {
                if (indexPath.row == 0) {
                    //全员禁言操作
                    [self openAllNoTalkReq];
                }else if (indexPath.row == 1) {
                    //单人禁言操作
                    NoaGroupSetNotalkMemberVC * vc = [NoaGroupSetNotalkMemberVC new];
                    vc.groupInfoModel = self.groupInfoModel;
                    vc.notalkFriendIDArr = [NSArray arrayWithArray:self.notaklListIdArr];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            } else if (indexPath.section == 3) {
                //群活跃等级
                [self changeActivityLevelEnableStatus];
            } else if (indexPath.section == 4) {
                if (indexPath.row == 0) {
                    //群私密操作
                    [self changeGroupPrivateChat];
                }else if (indexPath.row == 1) {
                    //群聊邀请确认操作
                    [self changeGroupInviteConfirm];
                }else {
                    if (self.groupInfoModel.isNeedVerify) {
                        if (indexPath.row == 2) {
                            //邀请进群申请列表
                            [self navToJoinGroupApplyList];
                        } else {
                            //新成员可查看历史记录
                            [self changeGroupNewMemberCheckHistoryStatus];
                        }
                    } else {
                        //新成员可查看历史记录
                        [self changeGroupNewMemberCheckHistoryStatus];
                    }
                    
                }
            } else if (indexPath.section == 5) {
                if (indexPath.row == 0) {
                    //关闭/开启 群提示
                    [self changeGroupRemindSwitchStatus];
                } else if (indexPath.row == 1) {
                    //是否开启全员禁止拨打音视频
                    [self changeAudioAndVideoCallEnableStatus];
                } else {
                    //修改群二维码
                    [self changeGroupQRCodeSwitchStatus];
                }
                
            } else {
                //解散群聊弹窗
                WeakSelf
                NoaMessageAlertView *msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeTitle supView:nil];
                msgAlertView.lblTitle.text = LanguageToolMatch(@"解散群聊");
                msgAlertView.lblContent.text = LanguageToolMatch(@"无感解散当前群聊并清空群内聊天记录？");
                msgAlertView.lblContent.textAlignment = NSTextAlignmentLeft;
                [msgAlertView.btnSure setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
                [msgAlertView.btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
                [msgAlertView alertShow];
                msgAlertView.sureBtnBlock = ^(BOOL isCheckBox) {
                    [weakSelf dissolutionGroupReq];
                };
            }
        } else {
            //群主
            if (indexPath.section == 0) {
                //设置群主/管理员操作
                NoaGroupSetManagerOwnerVC * vc = [NoaGroupSetManagerOwnerVC new];
                vc.groupInfoModel = self.groupInfoModel;
                [self.navigationController pushViewController:vc animated:YES];
            } else  if (indexPath.section == 1) {
                //群机器人
                NoaRobotListViewController * robotVc = [NoaRobotListViewController new];
                robotVc.groupInfoModel = self.groupInfoModel;
                [self.navigationController pushViewController:robotVc animated:YES];
            } else if (indexPath.section == 2) {
                if (indexPath.row == 0) {
                    //全员禁言操作
                    [self openAllNoTalkReq];
                } else if (indexPath.row == 1) {
                    //单人禁言操作
                    NoaGroupSetNotalkMemberVC * vc = [NoaGroupSetNotalkMemberVC new];
                    vc.groupInfoModel = self.groupInfoModel;
                    vc.notalkFriendIDArr = [NSArray arrayWithArray:self.notaklListIdArr];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            } else if (indexPath.section == 3) {
                //群活跃等级
                [self changeActivityLevelEnableStatus];
            } else if (indexPath.section == 4) {
                if (indexPath.row == 0) {
                    //群私密操作
                    [self changeGroupPrivateChat];
                }else if (indexPath.row == 1) {
                    //群聊邀请确认操作
                    [self changeGroupInviteConfirm];
                }else {
                    if (self.groupInfoModel.isNeedVerify) {
                        if (indexPath.row == 2) {
                            //邀请进群申请列表
                            [self navToJoinGroupApplyList];
                        } else {
                            //新成员可查看历史记录
                            [self changeGroupNewMemberCheckHistoryStatus];
                        }
                    } else {
                        //新成员可查看历史记录
                        [self changeGroupNewMemberCheckHistoryStatus];
                    }
                }
            } else if (indexPath.section == 5) {
                if (indexPath.row == 0) {
                    //关闭/开启 群提示
                    [self changeGroupRemindSwitchStatus];
                } else {
                    //修改群二维码
                    [self changeGroupQRCodeSwitchStatus];
                }
            } else {
                //解散群聊弹窗
                WeakSelf
                NoaMessageAlertView *msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeTitle supView:nil];
                msgAlertView.lblTitle.text = LanguageToolMatch(@"解散群聊");
                msgAlertView.lblContent.text = LanguageToolMatch(@"解散当前群聊并清空群内聊天记录");
                msgAlertView.lblContent.textAlignment = NSTextAlignmentLeft;
                [msgAlertView.btnSure setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
                [msgAlertView.btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
                [msgAlertView alertShow];
                msgAlertView.sureBtnBlock = ^(BOOL isCheckBox) {
                    [weakSelf dissolutionGroupReq];
                };
            }
        }
    }
}

- (void)navToJoinGroupApplyList {
    NoaSystemMessageVC *joinApplyVC = [[NoaSystemMessageVC alloc] init];
    joinApplyVC.groupHelperType = ZGroupHelperFormTypeGroupManager;
    joinApplyVC.groupId = self.groupInfoModel.groupId;
    [self.navigationController pushViewController:joinApplyVC animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    if (self.groupInfoModel.userGroupRole == 1) {
        //管理员
        return 5;
    }else{
        //群主
        return 7;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.groupInfoModel.userGroupRole == 1) {
        //管理员
        if (section == 0) {
            return 1;
        } else if (section == 1) {
            return self.notalkListArr.count+2;
        } else if (section == 2) {
            return 1;//群活跃等级
        } else if (section == 3) {
            if (_groupInfoModel.isNeedVerify) {
                //开启邀请确认
                return 4;
            }else {
                //未开启邀请确认
                return 3;
            }
        } else if (section == 4) {
            //关闭群提示&音视频&群二维码
            if ([ZHostTool.appSysSetModel.enableAudioAndVideoCalls isEqualToString:@"1"]) {
                return 3;
            } else {
                return 2;
            }
        }
        
    } else if (self.groupInfoModel.userGroupRole == 2) {
        //群主
        switch (section) {
            case 0:
                return 1;
                break;
            case 1:
                return 1;
                break;
            case 2:
                return self.notalkListArr.count+2;
                break;
            case 3://群活跃等级
                return 1;
            case 4:
            {
                if (_groupInfoModel.isNeedVerify) {
                    //开启邀请确认
                    return 4;
                }else {
                    //未开启邀请确认
                    return 3;
                }
            }
                break;
            case 5:
                //关闭群提示&音视频&群二维码
                if ([ZHostTool.appSysSetModel.enableAudioAndVideoCalls isEqualToString:@"1"]) {
                    return 3;
                } else {
                    return 2;
                }
                break;
            case 6:
                //解散群组
                return 1;
                break;
            default:
                return 0;
                break;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.groupInfoModel.userGroupRole == 1) {
        //管理员
        if (indexPath.section == 0) {
            //群机器人
            NoaChatSetGroupCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaChatSetGroupCommonCell cellIdentifier] forIndexPath:indexPath];
            cell.baseCellIndexPath = indexPath;
            cell.baseDelegate = self;
            [cell cellConfigWithTitle:LanguageToolMatch(@"群机器人") model:_groupInfoModel];
            return cell;

        } else if (indexPath.section == 1) {
            
            if (indexPath.row == 0) {
                
                NoaGroupManageCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageCommonCell cellIdentifier] forIndexPath:indexPath];
                [cell cellConfigWith:GroupManageCellSelect itemStr:LanguageToolMatch(@"全员禁言") model:self.groupInfoModel];
                cell.viewLine.hidden = NO;
                cell.baseCellIndexPath = indexPath;
                cell.baseDelegate = self;
                [cell setCornerRadiusWithIsShow:YES location:CornerRadiusLocationTop];
                cell.btnAction.selected = self.isOpenAllMenmberNotalk;
                return cell;
                
            }else if (indexPath.row == 1){
                
                NoaGroupManageCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageCommonCell cellIdentifier] forIndexPath:indexPath];
                cell.baseCellIndexPath = indexPath;
                cell.baseDelegate = self;
                [cell cellConfigWith:GroupManageCellCommon itemStr:LanguageToolMatch(@"单人禁言") model:self.groupInfoModel];
                if (self.notalkListArr.count>0) {
                    [cell setCornerRadiusWithIsShow:NO location:CornerRadiusLocationBottom];
                    cell.viewLine.hidden = NO;
                }else{
                    [cell setCornerRadiusWithIsShow:YES location:CornerRadiusLocationBottom];
                    cell.viewLine.hidden = YES;
                }
                return cell;
                
            }else{
                
                WeakSelf;
                NoaGroupManageMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageMemberCell cellIdentifier] forIndexPath:indexPath];
                [cell cellConfigWithmodel:self.notalkListArr[indexPath.row-2]];
                if ((indexPath.row-2+1) == self.notalkListArr.count) {
                    cell.viewLine.hidden = YES;
                    [cell setCornerRadiusWithIsShow:YES location:CornerRadiusLocationBottom];
                }else{
                    cell.viewLine.hidden = NO;
                    [cell setCornerRadiusWithIsShow:NO location:CornerRadiusLocationBottom];
                }
                [cell setTapCancelNotalkBlock:^(NoaGroupNotalkMemberModel * _Nonnull model) {
                    [weakSelf cancelNotalkReq:model];
                }];
                return cell;
            }
            
        } else if (indexPath.section == 2) {
            //群活跃等级
            NoaGroupManageCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageCommonCell cellIdentifier] forIndexPath:indexPath];
            [cell cellConfigWith:GroupManageCellSelect itemStr:LanguageToolMatch(@"群活跃等级") model:self.groupInfoModel];
            cell.viewLine.hidden = YES;
            cell.baseCellIndexPath = indexPath;
            cell.baseDelegate = self;
            [cell setCornerRadiusWithIsShow:YES location:CornerRadiusLocationAll];
            cell.btnAction.selected = _groupInfoModel.isActiveEnabled;
            return cell;
        } else if (indexPath.section == 3) {
            
            if (indexPath.row == 0) {
                //群私密，禁止群内私聊
                NoaGroupManageContentCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageContentCell cellIdentifier] forIndexPath:indexPath];
                [cell updateCellUIWith:indexPath.row totalRow:_groupInfoModel.isNeedVerify ? 4 : 3];
                cell.baseCellIndexPath = indexPath;
                cell.baseDelegate = self;
                cell.viewLine.hidden = NO;
                cell.btnSwitch.selected = _groupInfoModel.isPrivateChat;
                return cell;
            }else if (indexPath.row == 1) {
                //开启邀请确认
                NoaGroupManageContentCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageContentCell cellIdentifier] forIndexPath:indexPath];
                [cell updateCellUIWith:indexPath.row totalRow:_groupInfoModel.isNeedVerify ? 4 : 3];
                cell.baseCellIndexPath = indexPath;
                cell.baseDelegate = self;
                cell.btnSwitch.selected = _groupInfoModel.isNeedVerify;
                cell.viewLine.hidden = NO;
                return cell;
            } else {
                if (self.groupInfoModel.isNeedVerify) {
                    if (indexPath.row == 2) {
                        //邀请进群申请
                        NoaGroupManageCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageCommonCell cellIdentifier] forIndexPath:indexPath];
                        cell.baseCellIndexPath = indexPath;
                        cell.baseDelegate = self;
                        [cell setCornerRadiusWithIsShow:NO location:CornerRadiusLocationBottom];
                        [cell cellConfigWith:GroupManageCellCommon itemStr:LanguageToolMatch(@"邀请进群申请") model:self.groupInfoModel];
                        cell.viewLine.hidden = NO;
                        return cell;
                    } else {
                        //新成员可查看历史记录
                        NoaGroupManageCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageCommonCell cellIdentifier] forIndexPath:indexPath];
                        [cell cellConfigWith:GroupManageCellSelect itemStr:LanguageToolMatch(@"新成员可查看历史记录") model:self.groupInfoModel];
                        cell.baseCellIndexPath = indexPath;
                        cell.baseDelegate = self;
                        [cell setCornerRadiusWithIsShow:YES location:CornerRadiusLocationBottom];
                        cell.btnAction.selected = _groupInfoModel.isShowHistory;
                        cell.viewLine.hidden = YES;
                        return cell;
                    }
                } else {
                    //新成员可查看历史记录
                    NoaGroupManageCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageCommonCell cellIdentifier] forIndexPath:indexPath];
                    [cell cellConfigWith:GroupManageCellSelect itemStr:LanguageToolMatch(@"新成员可查看历史记录") model:self.groupInfoModel];
                    cell.baseCellIndexPath = indexPath;
                    cell.baseDelegate = self;
                    [cell setCornerRadiusWithIsShow:YES location:CornerRadiusLocationBottom];
                    cell.btnAction.selected = _groupInfoModel.isShowHistory;
                    cell.viewLine.hidden = YES;
                    return cell;
                }
                
            }
        } else {
            if (indexPath.row == 0) {
                //关闭群提示
                NoaGroupManageCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageCommonCell cellIdentifier] forIndexPath:indexPath];
                [cell cellConfigWith:GroupManageCellSelect itemStr:LanguageToolMatch(@"关闭群提示") model:self.groupInfoModel];
                cell.viewLine.hidden = NO;
                cell.baseCellIndexPath = indexPath;
                cell.baseDelegate = self;
                [cell setCornerRadiusWithIsShow:YES location:CornerRadiusLocationTop];
                cell.btnAction.selected = _groupInfoModel.isMessageInform;
                return cell;
            }
            if ([ZHostTool.appSysSetModel.enableAudioAndVideoCalls isEqualToString:@"1"]) {
                if (indexPath.row == 1) {
                    //关闭音视频
                    NoaGroupManageCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageCommonCell cellIdentifier] forIndexPath:indexPath];
                    [cell cellConfigWith:GroupManageCellSelect itemStr:LanguageToolMatch(@"关闭音视频") model:self.groupInfoModel];
                    cell.viewLine.hidden = NO;
                    cell.baseCellIndexPath = indexPath;
                    cell.baseDelegate = self;
                    [cell setCornerRadiusWithIsShow:NO location:CornerRadiusLocationBottom];
                    cell.btnAction.selected = _groupInfoModel.isNetCall;
                    return cell;
                } else {
                    //关闭群二维码
                    NoaGroupManageCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageCommonCell cellIdentifier] forIndexPath:indexPath];
                    [cell cellConfigWith:GroupManageCellSelect itemStr:LanguageToolMatch(@"关闭群二维码") model:self.groupInfoModel];
                    cell.viewLine.hidden = YES;
                    cell.baseCellIndexPath = indexPath;
                    cell.baseDelegate = self;
                    [cell setCornerRadiusWithIsShow:YES location:CornerRadiusLocationBottom];
                    cell.btnAction.selected = !_groupInfoModel.isShowQrCode;
                    return cell;
                }
                
            } else {
                //关闭群二维码
                NoaGroupManageCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageCommonCell cellIdentifier] forIndexPath:indexPath];
                [cell cellConfigWith:GroupManageCellSelect itemStr:LanguageToolMatch(@"关闭群二维码") model:self.groupInfoModel];
                cell.viewLine.hidden = YES;
                cell.baseCellIndexPath = indexPath;
                cell.baseDelegate = self;
                [cell setCornerRadiusWithIsShow:YES location:CornerRadiusLocationBottom];
                cell.btnAction.selected = !_groupInfoModel.isShowQrCode;
                return cell;
            }
            
        }
    } else {
        //群主
            switch (indexPath.section) {
                case 0:
                {
                    NoaGroupManageCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageCommonCell cellIdentifier] forIndexPath:indexPath];
                    cell.baseCellIndexPath = indexPath;
                    cell.baseDelegate = self;
                    [cell cellConfigWith:GroupManageCellCommon itemStr:LanguageToolMatch(@"设置群主/管理员") model:self.groupInfoModel];
                    [cell setCornerRadiusWithIsShow:YES location:CornerRadiusLocationAll];
                    cell.viewLine.hidden = YES;
                    return cell;
                }
                    break;
                case 1:
                {
                    //群机器人
                    NoaChatSetGroupCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaChatSetGroupCommonCell cellIdentifier] forIndexPath:indexPath];
                    cell.baseCellIndexPath = indexPath;
                    cell.baseDelegate = self;
                    [cell cellConfigWithTitle:LanguageToolMatch(@"群机器人") model:_groupInfoModel];
                    return cell;
                }
                    break;
                case 2:
                {
                    if (indexPath.row == 0) {
                        NoaGroupManageCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageCommonCell cellIdentifier] forIndexPath:indexPath];
                        cell.baseCellIndexPath = indexPath;
                        cell.baseDelegate = self;
                        [cell cellConfigWith:GroupManageCellSelect itemStr:LanguageToolMatch(@"全员禁言") model:self.groupInfoModel];
                        [cell setCornerRadiusWithIsShow:YES location:CornerRadiusLocationTop];
                        cell.viewLine.hidden = NO;
                        cell.btnAction.selected = self.isOpenAllMenmberNotalk;
                        return cell;
                    }else if(indexPath.row == 1){
                        NoaGroupManageCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageCommonCell cellIdentifier] forIndexPath:indexPath];
                        cell.baseCellIndexPath = indexPath;
                        cell.baseDelegate = self;
                        [cell cellConfigWith:GroupManageCellCommon itemStr:LanguageToolMatch(@"单人禁言") model:self.groupInfoModel];
                        if (self.notalkListArr.count>0) {
                            [cell setCornerRadiusWithIsShow:NO location:CornerRadiusLocationBottom];
                            cell.viewLine.hidden = NO;
                        }else{
                            [cell setCornerRadiusWithIsShow:YES location:CornerRadiusLocationBottom];
                            cell.viewLine.hidden = YES;
                        }
                        return cell;
                    }else{
                        WeakSelf;
                        NoaGroupManageMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageMemberCell cellIdentifier] forIndexPath:indexPath];
                        [cell cellConfigWithmodel:self.notalkListArr[indexPath.row-2]];
                        if ((indexPath.row-2+1) == self.notalkListArr.count) {
                            cell.viewLine.hidden = YES;
                            [cell setCornerRadiusWithIsShow:YES location:CornerRadiusLocationBottom];
                        }else{
                            cell.viewLine.hidden = NO;
                            [cell setCornerRadiusWithIsShow:NO location:CornerRadiusLocationBottom];
                        }
                        [cell setTapCancelNotalkBlock:^(NoaGroupNotalkMemberModel * _Nonnull model) {
                            [weakSelf cancelNotalkReq:model];
                        }];
                        return cell;
                    }
                }
                    break;
                case 3:
                {
                    //群活跃等级
                    NoaGroupManageCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageCommonCell cellIdentifier] forIndexPath:indexPath];
                    [cell cellConfigWith:GroupManageCellSelect itemStr:LanguageToolMatch(@"群活跃等级") model:self.groupInfoModel];
                    cell.viewLine.hidden = YES;
                    cell.baseCellIndexPath = indexPath;
                    cell.baseDelegate = self;
                    [cell setCornerRadiusWithIsShow:YES location:CornerRadiusLocationAll];
                    cell.btnAction.selected = _groupInfoModel.isActiveEnabled;
                    return cell;
                }
                case 4:
                {
                    if (indexPath.row == 0) {
                        //群私密，禁止群内私聊
                        NoaGroupManageContentCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageContentCell cellIdentifier] forIndexPath:indexPath];
                        [cell updateCellUIWith:indexPath.row totalRow:_groupInfoModel.isNeedVerify ? 4 : 3];
                        cell.baseCellIndexPath = indexPath;
                        cell.baseDelegate = self;
                        cell.viewLine.hidden = NO;
                        cell.btnSwitch.selected = _groupInfoModel.isPrivateChat;
                        return cell;
                    } else if (indexPath.row == 1) {
                        //开启邀请确认
                        NoaGroupManageContentCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageContentCell cellIdentifier] forIndexPath:indexPath];
                        [cell updateCellUIWith:indexPath.row totalRow:_groupInfoModel.isNeedVerify ? 4 : 3];
                        cell.baseCellIndexPath = indexPath;
                        cell.baseDelegate = self;
                        cell.btnSwitch.selected = _groupInfoModel.isNeedVerify;
                        cell.viewLine.hidden = NO;
                        return cell;
                    }else {
                        if (self.groupInfoModel.isNeedVerify) {
                            if (indexPath.row == 2) {
                                //邀请进群申请
                                NoaGroupManageCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageCommonCell cellIdentifier] forIndexPath:indexPath];
                                cell.baseCellIndexPath = indexPath;
                                cell.baseDelegate = self;
                                [cell setCornerRadiusWithIsShow:NO location:CornerRadiusLocationBottom];
                                [cell cellConfigWith:GroupManageCellCommon itemStr:LanguageToolMatch(@"邀请进群申请") model:self.groupInfoModel];
                                cell.viewLine.hidden = NO;
                                return cell;
                            } else {
                                //新成员可查看历史记录
                                NoaGroupManageCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageCommonCell cellIdentifier] forIndexPath:indexPath];
                                [cell cellConfigWith:GroupManageCellSelect itemStr:LanguageToolMatch(@"新成员可查看历史记录") model:self.groupInfoModel];
                                cell.baseCellIndexPath = indexPath;
                                cell.baseDelegate = self;
                                [cell setCornerRadiusWithIsShow:YES location:CornerRadiusLocationBottom];
                                cell.btnAction.selected = _groupInfoModel.isShowHistory;
                                cell.viewLine.hidden = YES;
                                return cell;
                            }
                        } else {
                            //新成员可查看历史记录
                            NoaGroupManageCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageCommonCell cellIdentifier] forIndexPath:indexPath];
                            [cell cellConfigWith:GroupManageCellSelect itemStr:LanguageToolMatch(@"新成员可查看历史记录") model:self.groupInfoModel];
                            cell.baseCellIndexPath = indexPath;
                            cell.baseDelegate = self;
                            [cell setCornerRadiusWithIsShow:YES location:CornerRadiusLocationBottom];
                            cell.btnAction.selected = _groupInfoModel.isShowHistory;
                            cell.viewLine.hidden = YES;
                            return cell;
                        }
                        
                    }
                }
                    break;
                case 5:
                {
                    if (indexPath.row == 0) {
                        //关闭群提示
                        NoaGroupManageCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageCommonCell cellIdentifier] forIndexPath:indexPath];
                        [cell cellConfigWith:GroupManageCellSelect itemStr:LanguageToolMatch(@"关闭群提示") model:self.groupInfoModel];
                        cell.viewLine.hidden = NO;
                        cell.baseCellIndexPath = indexPath;
                        cell.baseDelegate = self;
                        [cell setCornerRadiusWithIsShow:YES location:CornerRadiusLocationTop];
                        cell.btnAction.selected = _groupInfoModel.isMessageInform;
                        return cell;
                    }
                    if ([ZHostTool.appSysSetModel.enableAudioAndVideoCalls isEqualToString:@"1"]) {
                        if (indexPath.row == 1) {
                            //关闭音视频
                            NoaGroupManageCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageCommonCell cellIdentifier] forIndexPath:indexPath];
                            [cell cellConfigWith:GroupManageCellSelect itemStr:LanguageToolMatch(@"关闭音视频") model:self.groupInfoModel];
                            cell.viewLine.hidden = NO;
                            cell.baseCellIndexPath = indexPath;
                            cell.baseDelegate = self;
                            [cell setCornerRadiusWithIsShow:NO location:CornerRadiusLocationBottom];
                            cell.btnAction.selected = _groupInfoModel.isNetCall;
                            return cell;
                        } else {
                            //关闭群二维码
                            NoaGroupManageCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageCommonCell cellIdentifier] forIndexPath:indexPath];
                            [cell cellConfigWith:GroupManageCellSelect itemStr:LanguageToolMatch(@"关闭群二维码") model:self.groupInfoModel];
                            cell.viewLine.hidden = YES;
                            cell.baseCellIndexPath = indexPath;
                            cell.baseDelegate = self;
                            [cell setCornerRadiusWithIsShow:YES location:CornerRadiusLocationBottom];
                            cell.btnAction.selected = !_groupInfoModel.isShowQrCode;
                            return cell;
                        }
                    } else {
                        //关闭群二维码
                        NoaGroupManageCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageCommonCell cellIdentifier] forIndexPath:indexPath];
                        [cell cellConfigWith:GroupManageCellSelect itemStr:LanguageToolMatch(@"关闭群二维码") model:self.groupInfoModel];
                        cell.viewLine.hidden = YES;
                        cell.baseCellIndexPath = indexPath;
                        cell.baseDelegate = self;
                        [cell setCornerRadiusWithIsShow:YES location:CornerRadiusLocationBottom];
                        cell.btnAction.selected = !_groupInfoModel.isShowQrCode;
                        return cell;
                    }
                    break;
                case 6:
                {
                    NoaGroupManageCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupManageCommonCell cellIdentifier] forIndexPath:indexPath];
                    cell.baseCellIndexPath = indexPath;
                    cell.baseDelegate = self;
                    [cell cellConfigWith:GroupManageCellButton itemStr:LanguageToolMatch(@"解散群组") model:self.groupInfoModel];
                    [cell setCornerRadiusWithIsShow:YES location:CornerRadiusLocationAll];
                    cell.viewLine.hidden = YES;
                    return cell;
                }
                    break;
                default:
                    return [UITableViewCell new];
                    break;
            }
        }
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.groupInfoModel.userGroupRole == 1) {
        //管理员
        if (indexPath.section == 0) {
            return [NoaChatSetGroupCommonCell defaultCellHeight];
        } else if (indexPath.section == 1) {
            
            if (indexPath.row > 1) {
                return [NoaGroupManageMemberCell defaultCellHeight];
            }else{
                return [NoaGroupManageCommonCell defaultCellHeight];
            }
            
        } else if (indexPath.section == 2) {
            return [NoaGroupManageCommonCell defaultCellHeight];
        } else if (indexPath.section == 3) {
            
            if (indexPath.row == 0) {
                return DWScale(80);
            }else if (indexPath.row == 1) {
                return DWScale(80);
            }else {
                return [NoaGroupManageCommonCell defaultCellHeight];
            }
        } else {
            return [NoaGroupManageCommonCell defaultCellHeight];
        }
        
    } else if (self.groupInfoModel.userGroupRole == 2) {
        //群主
        if (indexPath.section == 0) {
            return [NoaGroupManageCommonCell defaultCellHeight];
        } else if (indexPath.section == 1) {
            return [NoaChatSetGroupCommonCell defaultCellHeight];
        }else if (indexPath.section == 2) {
            if (indexPath.row > 1) {
                return [NoaGroupManageMemberCell defaultCellHeight];
            }else{
                return [NoaGroupManageCommonCell defaultCellHeight];
            }
        } else if (indexPath.section == 3) {
            return [NoaGroupManageCommonCell defaultCellHeight];
        } else if (indexPath.section == 4) {
            if (indexPath.row == 0) {
                return DWScale(80);
            }else if (indexPath.row == 1) {
                return DWScale(80);
            }else {
                return [NoaGroupManageCommonCell defaultCellHeight];
            }
        } else {
            return [NoaGroupManageCommonCell defaultCellHeight];
        }
    }
    
    return 0;
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

#pragma mark - 群内禁止私聊、群聊邀请确认接口
//修改禁止群内私聊状态
- (void)changeGroupPrivateChat {
    if (!_groupInfoModel) return;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_groupInfoModel.groupId forKey:@"groupId"];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    if (_groupInfoModel.isPrivateChat) {
        //关闭
        [dict setValue:@"0" forKey:@"status"];
    }else {
        //打开
        [dict setValue:@"1" forKey:@"status"];
    }
    WeakSelf
    [IMSDKManager groupSetPrivateChatStatusWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        NSString *actionStatus = [NSString stringWithFormat:@"%@", [dict objectForKeySafe:@"status"]];
        if ([actionStatus isEqualToString:@"1"]) {
            weakSelf.groupInfoModel.isPrivateChat = YES;
        }else {
            weakSelf.groupInfoModel.isPrivateChat = NO;
        }
        [weakSelf.baseTableView reloadData];
        
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}
//修改群聊邀请确认状态
- (void)changeGroupInviteConfirm {
    if (!_groupInfoModel) return;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_groupInfoModel.groupId forKey:@"groupId"];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    if (_groupInfoModel.isNeedVerify) {
        //关闭
        [dict setValue:@"0" forKey:@"status"];
    }else {
        //打开
        [dict setValue:@"1" forKey:@"status"];
    }
    WeakSelf
    [IMSDKManager groupSetJoinGroupStatusWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        NSString *actionStatus = [NSString stringWithFormat:@"%@", [dict objectForKeySafe:@"status"]];
        if ([actionStatus isEqualToString:@"1"]) {
            weakSelf.groupInfoModel.isNeedVerify = YES;
        }else {
            weakSelf.groupInfoModel.isNeedVerify = NO;
        }
        [weakSelf.baseTableView reloadData];
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
