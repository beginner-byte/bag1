//
//  NoaTranslateSettingVC.m
//  NoaKit
//
//  Created by Candy on 2023/12/26.
//

#import "NoaTranslateSettingVC.h"
#import "NoaTranslateSettingCell.h"
#import "NoaTranslateSetFooterView.h"
#import "NoaTranslateChannelLanguageView.h"
#import "NoaTranslateDefaultModel.h"

@interface NoaTranslateSettingVC () <UITableViewDelegate, UITableViewDataSource, ZBaseCellDelegate, ZTranslateChannelLanguageViewDelegate, NoaToolUserDelegate>

@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NoaTranslateDefaultModel *defaultModel;

@end

@implementation NoaTranslateSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.navTitleStr = LanguageToolMatch(@"翻译设置");
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    [self setupDefaultData];
    [self setupUI];
    
    [IMSDKManager addUserDelegate:self];
    
    [self requestDefaultData];
}

- (void)setupDefaultData {
    [self.dataArr removeAllObjects];
    [self.dataArr addObject: @[LanguageToolMatch(@"接收消息翻译"), LanguageToolMatch(@"通道"), LanguageToolMatch(@"语种"), LanguageToolMatch(@"自动翻译接收信息")]];
    [self.dataArr addObject:@[LanguageToolMatch(@"发送消息实时翻译"), LanguageToolMatch(@"实时翻译"), LanguageToolMatch(@"通道"), LanguageToolMatch(@"语种")]];
}

- (void)setupUI {
    self.baseTableViewStyle = UITableViewStyleGrouped;
    self.baseTableView.delegate = self;
    self.baseTableView.dataSource = self;
    self.baseTableView.bounces = NO;
    self.baseTableView.delaysContentTouches = NO;
    self.baseTableView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    [self.view addSubview:self.baseTableView];
    [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(DNavStatusBarH);
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-DHomeBarH);
    }];
    
    [self.baseTableView registerClass:[NoaTranslateSettingCell class] forCellReuseIdentifier:NSStringFromClass([NoaTranslateSettingCell class])];
}

#pragma mark - Request
- (void)requestDefaultData {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (![NSString isNil:UserManager.userInfo.userUID]) {
        [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    }
    WeakSelf
    [[NoaIMSDKManager sharedTool] userTranslateDefaultWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if (data) {
            weakSelf.defaultModel = [NoaTranslateDefaultModel mj_objectWithKeyValues:data];
            if ([NSString isNil:weakSelf.sessionModel.sendTranslateChannel]) {
                weakSelf.sessionModel.sendTranslateChannel = weakSelf.defaultModel.sendChannel;
                weakSelf.sessionModel.sendTranslateChannelName = weakSelf.defaultModel.sendChannelName;
            }
            if ([NSString isNil:weakSelf.sessionModel.sendTranslateLanguage]) {
                weakSelf.sessionModel.sendTranslateLanguage = weakSelf.defaultModel.sendTargetLang;
                weakSelf.sessionModel.sendTranslateLanguageName = weakSelf.defaultModel.sendTargetLangName;
            }
            if ([NSString isNil:weakSelf.sessionModel.receiveTranslateChannel]) {
                weakSelf.sessionModel.receiveTranslateChannel = weakSelf.defaultModel.receiveChannel;
                weakSelf.sessionModel.receiveTranslateChannelName = weakSelf.defaultModel.receiveChannelName;
            }
            if ([NSString isNil:weakSelf.sessionModel.receiveTranslateLanguage]) {
                weakSelf.sessionModel.receiveTranslateLanguage = weakSelf.defaultModel.receiveTargetLang;
                weakSelf.sessionModel.receiveTranslateLanguageName = weakSelf.defaultModel.receiveTargetLangName;
            }
            [weakSelf.baseTableView reloadData];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

- (void)requestUploadTranslateSetting {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:self.sessionModel.sessionID forKey:@"dialogId"];
    [dict setObjectSafe:self.sessionModel.translateConfigId forKey:@"id"];
    [dict setObjectSafe:@(1) forKey:@"level"];      //级别：0：用户全局配置；1:会话级别
    [dict setObjectSafe:![NSString isNil:self.sessionModel.sendTranslateChannel] ? self.sessionModel.sendTranslateChannel : @"" forKey:@"channel"];
    [dict setObjectSafe:![NSString isNil:self.sessionModel.sendTranslateChannelName] ? self.sessionModel.sendTranslateChannelName : @"" forKey:@"channelName"];
    [dict setObjectSafe:![NSString isNil:self.sessionModel.sendTranslateLanguage] ? self.sessionModel.sendTranslateLanguage : @"" forKey:@"targetLang"];
    [dict setObjectSafe:![NSString isNil:self.sessionModel.sendTranslateLanguageName] ? self.sessionModel.sendTranslateLanguageName : @"" forKey:@"targetLangName"];
    [dict setObjectSafe:@(self.sessionModel.isSendAutoTranslate) forKey:@"translateSwitch"];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    [dict setObjectSafe:![NSString isNil:self.sessionModel.receiveTranslateChannel] ? self.sessionModel.receiveTranslateChannel : @"" forKey:@"receiveChannel"];
    [dict setObjectSafe:![NSString isNil:self.sessionModel.receiveTranslateChannelName] ? self.sessionModel.receiveTranslateChannelName : @"" forKey:@"receiveChannelName"];
    [dict setObjectSafe:![NSString isNil:self.sessionModel.receiveTranslateLanguage] ? self.sessionModel.receiveTranslateLanguage : @"" forKey:@"receiveTargetLang"];
    [dict setObjectSafe:![NSString isNil:self.sessionModel.receiveTranslateLanguageName] ? self.sessionModel.receiveTranslateLanguageName : @"" forKey:@"receiveTargetLangName"];
    [dict setObjectSafe:@(self.sessionModel.isReceiveAutoTranslate) forKey:@"receiveTranslateSwitch"];
    
    [IMSDKManager imSdkTranslateUploadNewTranslateConfig:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
       
    }];
}

#pragma mark - CIMToolUserDelegate
/// 其他登录端更新了翻译配置信息
- (void)imsdkUserUpdateTranslateConfigInfo:(UserTranslateConfigUploadMessage *)translateConfig {
    if (![translateConfig.dialogId isEqualToString:@"0"]) {
        //如果是当前会话翻译配置信息发生修改同步
        if ([_sessionModel.sessionID isEqualToString:translateConfig.dialogId]) {
            _sessionModel.isSendAutoTranslate = translateConfig.translateSwitch;
            _sessionModel.sendTranslateChannel = translateConfig.channel;
            _sessionModel.sendTranslateChannelName = translateConfig.channelName;
            _sessionModel.sendTranslateLanguage = translateConfig.targetLang;
            _sessionModel.sendTranslateLanguageName = translateConfig.targetLangName;
            _sessionModel.isReceiveAutoTranslate = translateConfig.receiveTranslateSwitch;
            _sessionModel.receiveTranslateChannel = translateConfig.receiveChannel;
            _sessionModel.receiveTranslateChannelName = translateConfig.receiveChannelName;
            _sessionModel.receiveTranslateLanguage = translateConfig.receiveTargetLang;
            _sessionModel.receiveTranslateLanguageName = translateConfig.receiveTargetLangName;
            _sessionModel.translateConfigId = [NSString stringWithFormat:@"%lld", translateConfig.id_p];
            
            //更新到本地
            [DBTOOL insertOrUpdateSessionModelWith:_sessionModel];
            [self.baseTableView reloadData];
        }
    }
}

#pragma mark - ZTranslateChannelLanguageViewDelegate
- (void)selectActionFinishWithSessionModel:(LingIMSessionModel *)sessionModel translateType:(ZMsgTranslateType)translateType {
    self.sessionModel = sessionModel;
    [self.baseTableView reloadData];
    //调用接口
    [self requestUploadTranslateSetting];
}

#pragma mark - UITableViewDelegate  UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *itemArr = (NSArray *)[self.dataArr objectAtIndex:section];
    return itemArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DWScale(54);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return DWScale(16);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DWScale(16))];
    headerView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaTranslateSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NoaTranslateSettingCell class]) forIndexPath:indexPath];
    NSArray *itemArr = (NSArray *)[self.dataArr objectAtIndex:indexPath.section];
    if (indexPath.section == 0) {
        cell.leftTitleStr = (NSString *)[itemArr objectAtIndex:indexPath.row];
        if (indexPath.row == 1) {
            cell.rightTitleStr = ![NSString isNil:self.sessionModel.receiveTranslateChannel] ? self.sessionModel.receiveTranslateChannelName : LanguageToolMatch(@"请选择");
        }
        if (indexPath.row == 2) {
            cell.rightTitleStr = ![NSString isNil:self.sessionModel.receiveTranslateLanguage] ? self.sessionModel.receiveTranslateLanguageName : LanguageToolMatch(@"请选择");
        }
        if (indexPath.row == 3) {
            cell.switchIsOn = self.sessionModel.isReceiveAutoTranslate == 0 ? NO : YES;
        }
    }
    if (indexPath.section == 1) {
        cell.leftTitleStr = (NSString *)[itemArr objectAtIndex:indexPath.row];
        if (indexPath.row == 1) {
            cell.switchIsOn = self.sessionModel.isSendAutoTranslate == 0 ? NO : YES;
        }
        if (indexPath.row == 2) {
            cell.rightTitleStr = ![NSString isNil:self.sessionModel.sendTranslateChannel] ? (![NSString isNil:self.sessionModel.sendTranslateChannelName] ? self.sessionModel.sendTranslateChannelName : self.sessionModel.sendTranslateChannel) : LanguageToolMatch(@"请选择");
        }
        if (indexPath.row == 3) {
            cell.rightTitleStr = ![NSString isNil:self.sessionModel.sendTranslateLanguage] ? (![NSString isNil:self.sessionModel.sendTranslateLanguageName] ? self.sessionModel.sendTranslateLanguageName : self.sessionModel.sendTranslateLanguage) : LanguageToolMatch(@"请选择");
        }
    }
    [cell configCellRoundWithCellIndex:indexPath.row totalIndex:itemArr.count];
    cell.baseCellIndexPath = indexPath;
    cell.baseDelegate = self;
    WeakSelf
    cell.switchBlock = ^(BOOL isOn) {
        [weakSelf settingCellSwitch:isOn indexPath:indexPath];
    };
    return cell;
}

#pragma mark - ZBaseCellDelegate
- (void)cellClickAction:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NoaTranslateChannelLanguageView *selectedView;
        if (indexPath.row == 1) {
            //接收消息翻译通道
            selectedView = [[NoaTranslateChannelLanguageView alloc] initWithTranslateType:ZReceiveMsgTranslateTypeChannel sessionModel:self.sessionModel];
            selectedView.delegate = self;
            [selectedView channelLanguageViewShow];
        }
        if (indexPath.row == 2) {
            //接收消息翻译语种
            if (![NSString isNil:self.sessionModel.receiveTranslateChannel]) {
                selectedView = [[NoaTranslateChannelLanguageView alloc] initWithTranslateType:ZReceiveMsgTranslateTypeLanguage sessionModel:self.sessionModel];
                selectedView.delegate = self;
                [selectedView channelLanguageViewShow];
            } else {
                //请先选择通道
                [HUD showMessage:LanguageToolMatch(@"请先选择消息翻译的通道")];
                selectedView = [[NoaTranslateChannelLanguageView alloc] initWithTranslateType:ZReceiveMsgTranslateTypeChannel sessionModel:self.sessionModel];
                selectedView.delegate = self;
                [selectedView channelLanguageViewShow];
            }
        }
    }
    
    if (indexPath.section == 1) {
        NoaTranslateChannelLanguageView *selectedView;
        if (indexPath.row == 2) {
            //发送消息翻译通道
            selectedView = [[NoaTranslateChannelLanguageView alloc] initWithTranslateType:ZSendMsgTranslateTypeChannel sessionModel:self.sessionModel];
            selectedView.delegate = self;
            [selectedView channelLanguageViewShow];
        }
        if (indexPath.row == 3) {
            //发送消息翻译语种
            if (![NSString isNil:self.sessionModel.sendTranslateChannel]) {
                selectedView = [[NoaTranslateChannelLanguageView alloc] initWithTranslateType:ZSendMsgTranslateTypeLanguage sessionModel:self.sessionModel];
                selectedView.delegate = self;
                [selectedView channelLanguageViewShow];
            } else {
                //请先选择通道
                [HUD showMessage:LanguageToolMatch(@"请先选择发送翻译的通道")];
                selectedView = [[NoaTranslateChannelLanguageView alloc] initWithTranslateType:ZSendMsgTranslateTypeChannel sessionModel:self.sessionModel];
                selectedView.delegate = self;
                [selectedView channelLanguageViewShow];
            }
        }
    }
}

- (void)settingCellSwitch:(BOOL)isOn indexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 3) {
        //接受消息自动翻译
        if (isOn) {
            if ([NSString isNil:self.sessionModel.receiveTranslateChannel] || [NSString isNil:self.sessionModel.receiveTranslateLanguage]) {
                [HUD showMessage:LanguageToolMatch(@"请选择消息翻译的通道和语种")];
                if ([NSString isNil:self.sessionModel.receiveTranslateChannel]) {
                    NoaTranslateChannelLanguageView *selectedView = [[NoaTranslateChannelLanguageView alloc] initWithTranslateType:ZReceiveMsgTranslateTypeChannel sessionModel:self.sessionModel];
                    selectedView.delegate = self;
                    [selectedView channelLanguageViewShow];
                    return;
                }
                if ([NSString isNil:self.sessionModel.receiveTranslateLanguage]) {
                    NoaTranslateChannelLanguageView *selectedView = [[NoaTranslateChannelLanguageView alloc] initWithTranslateType:ZReceiveMsgTranslateTypeLanguage sessionModel:self.sessionModel];
                    selectedView.delegate = self;
                    [selectedView channelLanguageViewShow];
                    return;
                }
                return;
            }
        }
        
        self.sessionModel.isReceiveAutoTranslate = isOn ? 1 : 0;
        //缓存到本地
        [DBTOOL insertOrUpdateSessionModelWith:self.sessionModel];
    }
    if (indexPath.section == 1 && indexPath.row == 1) {
        //发送消息自动翻译
        if (isOn) {
            if ([NSString isNil:self.sessionModel.sendTranslateChannel] || [NSString isNil:self.sessionModel.sendTranslateLanguage]) {
                [HUD showMessage:LanguageToolMatch(@"请选择发送翻译的通道和语种")];
                if ([NSString isNil:self.sessionModel.sendTranslateChannel]) {
                    NoaTranslateChannelLanguageView *selectedView = [[NoaTranslateChannelLanguageView alloc] initWithTranslateType:ZSendMsgTranslateTypeChannel sessionModel:self.sessionModel];
                    selectedView.delegate = self;
                    [selectedView channelLanguageViewShow];
                    return;
                }
                if ([NSString isNil:self.sessionModel.sendTranslateLanguage]) {
                    NoaTranslateChannelLanguageView *selectedView = [[NoaTranslateChannelLanguageView alloc] initWithTranslateType:ZSendMsgTranslateTypeLanguage sessionModel:self.sessionModel];
                    selectedView.delegate = self;
                    [selectedView channelLanguageViewShow];
                    return;
                }
                return;
            }
        }
        self.sessionModel.isSendAutoTranslate = isOn ? 1 : 0;
        //缓存到本地
        [DBTOOL insertOrUpdateSessionModelWith:self.sessionModel];
        //调用接口
        [self requestUploadTranslateSetting];
    }
    [self.baseTableView reloadData];
}

#pragma mark - Lazy
- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (NoaTranslateDefaultModel *)defaultModel {
    if (_defaultModel == nil) {
        _defaultModel = [[NoaTranslateDefaultModel alloc] init];
    }
    return _defaultModel;
}

@end
