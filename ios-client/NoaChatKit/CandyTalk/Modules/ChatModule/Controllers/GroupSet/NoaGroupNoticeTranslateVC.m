//
//  NoaGroupNoticeTranslateVC.m
//  NoaKit
//
//  Created by Candy on 2024/2/19.
//

#import "NoaGroupNoticeTranslateVC.h"
#import "NoaNoticeTranslateCell.h"
#import "NoaNoticeTranslateModel.h"
#import "NoaChatViewController.h"
#import "NoaGroupNoticeListVC.h"

@interface NoaGroupNoticeTranslateVC () <UITableViewDelegate, UITableViewDataSource, ZNoticeTranslateCellDelegate>

@property (nonatomic, strong)NSMutableArray *dataArr;

@end

@implementation NoaGroupNoticeTranslateVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupNavUI];
    [self setupUI];
    [self setupData];
}

- (void)setupNavUI {
    self.navTitleStr = LanguageToolMatch(@"群公告翻译");
    self.navBtnRight.hidden = NO;
    [self.navBtnRight setTitle:LanguageToolMatch(@"发布") forState:UIControlStateNormal];
    [self.navBtnRight setTitleColor:COLORWHITE forState:UIControlStateNormal];
    self.navBtnRight.tkThemebackgroundColors = @[COLOR_CCCCCC, COLOR_CCCCCC_DARK];
    [self.navBtnRight setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateSelected];
    [self.navBtnRight setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateHighlighted];
    self.navBtnRight.layer.cornerRadius = DWScale(12);
    self.navBtnRight.layer.masksToBounds = YES;
    self.navBtnRight.enabled = NO;
    [self.navBtnRight mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.navTitleLabel);
        make.trailing.equalTo(self.navView).offset(-DWScale(20));
        make.height.mas_equalTo(DWScale(32));
        CGSize textSize = [self.navBtnRight.titleLabel.text sizeWithFont:FONTR(14) constrainedToSize:CGSizeMake(10000, DWScale(32))];
        make.width.mas_equalTo(MIN(textSize.width+DWScale(28), 60));
    }];
}

- (void)setupUI {
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
    
    self.baseTableViewStyle = UITableViewStylePlain;
    self.baseTableView.delegate = self;
    self.baseTableView.dataSource = self;
    self.baseTableView.separatorColor = COLOR_CLEAR;
    self.baseTableView.delaysContentTouches = NO;
    self.baseTableView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    self.baseTableView.rowHeight = UITableViewAutomaticDimension;
    self.baseTableView.estimatedRowHeight = DWScale(124);
    [self.view addSubview:self.baseTableView];
    [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.navView.mas_bottom).offset(DWScale(10));
        make.bottom.equalTo(self.view).offset(-DHomeBarH);
    }];
}

- (void)setupData {
    //原文
    NoaNoticeTranslateModel *originModel = [[NoaNoticeTranslateModel alloc] init];
    originModel.originNotice = _originNoticeContent;
    originModel.languageName = LanguageToolMatch(@"原文");
    originModel.isOrigin = YES;
    [self.dataArr addObject:@[originModel]];
    //译文
    if (_languageCodeArr.count > 0) {
        NSMutableArray *translateContentArr = [NSMutableArray array];
        for(int i = 0; i< _languageCodeArr.count; i++) {
            NSString *languageCode = (NSString *)[_languageCodeArr objectAtIndexSafe:i];
            NSString *languageName = (NSString *)[_languageNameArr objectAtIndexSafe:i];
            NoaNoticeTranslateModel *translateModel = [[NoaNoticeTranslateModel alloc] init];
            translateModel.originNotice = _originNoticeContent;
            translateModel.translateNotice = @"";
            translateModel.isOrigin = NO;
            translateModel.channelCode = _channelCode;
            translateModel.languageCode = languageCode;
            translateModel.languageName = languageName;
            translateModel.translateStatus = 1; //翻译中
            translateModel.isTranslate = NO;
            
            [translateContentArr addObject:translateModel];
        }
        [self.dataArr addObject:translateContentArr];
    }
    [self.baseTableView reloadData];
}

//检查发布公告按钮是否可点击
- (void)checkReleaseStatus {
    NSArray *translateArr = (NSArray *)[self.dataArr objectAtIndexSafe:1];
    if (translateArr != nil && translateArr.count > 0) {
        BOOL releaseEnable = YES;
        for (NoaNoticeTranslateModel *model in translateArr) {
            if (model.isTranslate == NO) {
                releaseEnable = NO;
                break;
            }
        }
        if (releaseEnable) {
            self.navBtnRight.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2];
            self.navBtnRight.enabled = YES;
        } else {
            self.navBtnRight.tkThemebackgroundColors = @[COLOR_CCCCCC, COLOR_CCCCCC_DARK];
            self.navBtnRight.enabled = NO;
        }
    }
}

//发布公告
- (void)navBtnRightClicked {
    NSString *translateContentStr = [self transfromNoticeTranslateContent];
    if ([translateContentStr isEqual:@"error"]) {
        return;
    }
    WeakSelf
    NoaPresentItem * sendToSessionItem= [NoaPresentItem creatPresentViewItemWithText:LanguageToolMatch(@"发送至会话") textColor:COLOR_11 font:FONTR(17) itemHeight:DWScale(54) backgroundColor:COLORWHITE];
    self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        if (themeIndex == 0) {
            sendToSessionItem.textColor = COLOR_11;
            sendToSessionItem.backgroundColor = COLORWHITE;
        }else {
            sendToSessionItem.textColor = COLORWHITE;
            sendToSessionItem.backgroundColor = COLOR_11;
        }
    };
    
    NoaPresentItem *displayTopSessionItem = [NoaPresentItem creatPresentViewItemWithText:LanguageToolMatch(@"在会话内置顶显示") textColor:COLOR_11 font:FONTR(17) itemHeight:DWScale(54) backgroundColor:COLORWHITE];
    self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        if (themeIndex == 0) {
            displayTopSessionItem.textColor = COLOR_11;
            displayTopSessionItem.backgroundColor = COLORWHITE;
        }else {
            displayTopSessionItem.textColor = COLORWHITE;
            displayTopSessionItem.backgroundColor = COLOR_11;
        }
    };
    
    NoaPresentItem *sendTOSessionTop = [NoaPresentItem creatPresentViewItemWithText:LanguageToolMatch(@"发送至会话并置顶") textColor:COLOR_11 font:FONTR(17) itemHeight:DWScale(54) backgroundColor:COLORWHITE];
    self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        if (themeIndex == 0) {
            sendTOSessionTop.textColor = COLOR_11;
            sendTOSessionTop.backgroundColor = COLORWHITE;
        }else {
            sendTOSessionTop.textColor = COLORWHITE;
            sendTOSessionTop.backgroundColor = COLOR_11;
        }
    };
    
    NoaPresentItem *cancelItem = [NoaPresentItem creatPresentViewItemWithText:LanguageToolMatch(@"取消") textColor:COLOR_99 font:FONTR(17) itemHeight:DWScale(54) backgroundColor:COLORWHITE];
    self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        if (themeIndex == 0) {
            cancelItem.textColor = COLOR_B3B3B3;
            cancelItem.backgroundColor = COLORWHITE;
        }else {
            cancelItem.textColor = COLOR_99;
            cancelItem.backgroundColor = COLOR_11;
        }
    };
    
    NoaPresentView *viewAlert = [[NoaPresentView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DScreenHeight) titleItem:nil selectItems:@[sendToSessionItem, displayTopSessionItem,sendTOSessionTop] cancleItem:cancelItem doneClick:^(NSInteger index) {
      
        if(index == 0){
            [weakSelf requestChangeGroupName:0 isSendMsg:1];
        }
        if(index == 1){
            [weakSelf requestChangeGroupName:1 isSendMsg:0];
        }
        if(index == 2){
            [weakSelf requestChangeGroupName:1 isSendMsg:1];
        }
    } cancleClick:^{
    }];
    [self.view addSubview:viewAlert];
    [viewAlert showPresentView];
}

#pragma mark - Request
- (void)requestChangeGroupName:(NSInteger)topStatus isSendMsg:(NSInteger)isShowMsg{
    //判断如果没有群公告，先创建
    WeakSelf
    if (![NSString isNil:self.groupInfoModel.groupNotice.noticeId]) {
        if (![NSString isNil:_originNoticeContent]){
            //更新群公告
            NSString *translateContentStr = [self transfromNoticeTranslateContent];
            if ([translateContentStr isEqual:@"error"]) {
                return;
            }
            if ([translateContentStr isEqual:@"none"]) {
                translateContentStr = @"";
            }
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:self.groupInfoModel.groupId forKey:@"groupId"];
            [dict setValue:[NSString stringWithFormat:@"%@",_originNoticeContent] forKey:@"noticeContent"];
            [dict setValue:[NSString stringWithFormat:@"%ld",(long)topStatus] forKey:@"isTop"];
            [dict setValue:[NSString stringWithFormat:@"%ld",(long)isShowMsg] forKey:@"isSendMsg"];
            [dict setValue:[NSString stringWithFormat:@"%@",self.groupInfoModel.groupNotice.noticeId] forKey:@"noticeId"];
            [dict setValue:translateContentStr forKey:@"translateContent"];
            if (![NSString isNil:UserManager.userInfo.userUID]) {
                [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
            }
            [IMSDKManager groupChangeGroupNoticeWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                [weakSelf backAction];
                [HUD showMessage:LanguageToolMatch(@"编辑成功")];
            } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                [HUD showMessageWithCode:code errorMsg:msg];
            }];
        } else {
            //删除群公告
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:self.groupInfoModel.groupId forKey:@"groupId"];
            [dict setValue:[NSString stringWithFormat:@"%@",self.groupInfoModel.groupNotice.noticeId] forKey:@"noticeId"];
            if (![NSString isNil:UserManager.userInfo.userUID]) {
                [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
            }
            [IMSDKManager groupDeleteGroupNoticeWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                [weakSelf backAction];
                [HUD showMessage:LanguageToolMatch(@"群公告移除成功")];
            } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                [HUD showMessageWithCode:code errorMsg:msg];
            }];
        }
    } else {
        if (![NSString isNil:_originNoticeContent]) {
            //创建群公告
            NSString *translateContentStr = [self transfromNoticeTranslateContent];
            if ([translateContentStr isEqual:@"error"]) {
                return;
            }
            if ([translateContentStr isEqual:@"none"]) {
                translateContentStr = @"";
            }
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:self.groupInfoModel.groupId forKey:@"groupId"];
            [dict setValue:[NSString stringWithFormat:@"%@",_originNoticeContent] forKey:@"noticeContent"];
            [dict setValue:[NSString stringWithFormat:@"%ld",(long)topStatus] forKey:@"isTop"];
            [dict setValue:[NSString stringWithFormat:@"%ld",(long)isShowMsg] forKey:@"isSendMsg"];
            [dict setValue:translateContentStr forKey:@"translateContent"];
            if (![NSString isNil:UserManager.userInfo.userUID]) {
                [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
            }
            [IMSDKManager groupCreateGroupNoticeWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                [weakSelf backAction];
                [HUD showMessage:LanguageToolMatch(@"发布成功")];
            } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                [HUD showMessageWithCode:code errorMsg:msg];
            }];
        } else {
            //删除群公告
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:self.groupInfoModel.groupId forKey:@"groupId"];
            [dict setValue:[NSString stringWithFormat:@"%@",self.groupInfoModel.groupNotice.noticeId] forKey:@"noticeId"];
            if (![NSString isNil:UserManager.userInfo.userUID]) {
                [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
            }
            [IMSDKManager groupDeleteGroupNoticeWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                [weakSelf backAction];
                [HUD showMessage:LanguageToolMatch(@"群公告移除成功")];
            } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                [HUD showMessageWithCode:code errorMsg:msg];
            }];
        }
    }
}

/// 返回按钮事件，如果找到群公告列表页面，则返回列表页面；如果找到聊天界面，则返回聊天界面
- (void)backAction {
    NSArray *viewControllers = self.navigationController.viewControllers;
    [viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj isKindOfClass:[NoaChatViewController class]]){
            NoaChatViewController *chatCtrl = (NoaChatViewController *)obj;
            [self.navigationController popToViewController:chatCtrl animated:YES];
            *stop = YES;
        }else if ([obj isKindOfClass:[NoaGroupNoticeListVC class]]) {
            NoaGroupNoticeListVC *noticeList = (NoaGroupNoticeListVC *)obj;
            // 刷新
            [noticeList reloadData];
            [self.navigationController popToViewController:noticeList animated:YES];
            *stop = YES;
        }
    }];
}

//将翻译后的群公告译文转换成json字符串
- (NSString *)transfromNoticeTranslateContent {
    NSString *translateDictStr = @"none";
    NSArray *translateArr = (NSArray *)[self.dataArr objectAtIndexSafe:1];
    if (translateArr != nil && translateArr.count > 0) {
        NSMutableDictionary *noticeTranslateDict = [NSMutableDictionary dictionary];
        for (NoaNoticeTranslateModel *model in translateArr) {
            if ([model.languageCode isEqual:@"en"] && model.translateNotice.length <= 0) {
                [HUD showMessage:LanguageToolMatch(@"英文内容不可为空")];
                return translateDictStr = @"error";
                break;
            } else {
                [noticeTranslateDict setObjectSafe:model.translateNotice forKey:model.languageCode];
            }
        }
        [noticeTranslateDict setObjectSafe:_channelCode forKey:@"channelId"];//通道id
        translateDictStr = [NSString jsonStringFromDic:noticeTranslateDict];
    }
    return translateDictStr;
}

#pragma mark - UITableViewDelegate  UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *contentArr = (NSArray *)[self.dataArr objectAtIndexSafe:section];
    return contentArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return DWScale(16);
    } else {
        return DWScale(40);
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DWScale(16))];
    viewHeader.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    
    if (section == 1) {
        UILabel *sectionTitleLbl = [[UILabel alloc] initWithFrame:CGRectMake(DWScale(16), DWScale(16), DScreenWidth - DWScale(16)*2, DWScale(22))];
        sectionTitleLbl.text = LanguageToolMatch(@"译文");
        sectionTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        sectionTitleLbl.font = FONTN(16);
        [viewHeader addSubview:sectionTitleLbl];
    }
    return viewHeader;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //每个cell都有一个唯一标识
    NSString *cellIdentifier = [NSString stringWithFormat:@"cell%ld%ld", indexPath.section, indexPath.row];
    //保证cell不进行复用
    NoaNoticeTranslateCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[NoaNoticeTranslateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.delegate = self;
    cell.baseCellIndexPath = indexPath;
    NSArray *contentArr = (NSArray *)[self.dataArr objectAtIndexSafe:indexPath.section];
    NoaNoticeTranslateModel *model = (NoaNoticeTranslateModel *)[contentArr objectAtIndexSafe:indexPath.row];
    cell.model = model;
    return cell;
}

#pragma mark - ZNoticeTranslateCellDelegate
- (void)noticeTranslateSuccess:(NoaNoticeTranslateModel *)model indexPath:(NSIndexPath *)indexPath {
    //翻译成功
    NSMutableArray *tempContentArr = [[self.dataArr objectAtIndexSafe:indexPath.section] mutableCopy];
    [tempContentArr replaceObjectAtIndex:indexPath.row withObject:model];
    [self.dataArr replaceObjectAtIndex:indexPath.section withObject:tempContentArr];
    [self.baseTableView reloadData];
    //检查发布按钮是否可点击
    [self checkReleaseStatus];
}

- (void)noticeTranslateFail:(NoaNoticeTranslateModel *)model indexPath:(NSIndexPath *)indexPath {
    //翻译失败
    NSMutableArray *tempContentArr = [[self.dataArr objectAtIndexSafe:indexPath.section] mutableCopy];
    [tempContentArr replaceObjectAtIndex:indexPath.row withObject:model];
    [self.dataArr replaceObjectAtIndex:indexPath.section withObject:tempContentArr];
    [self.baseTableView reloadData];
    //检查发布按钮是否可点击
    [self checkReleaseStatus];
}

- (void)noticeTranslateEdit:(NoaNoticeTranslateModel *)model indexPath:(NSIndexPath *)indexPath {
    //编辑后保存
    NSMutableArray *tempContentArr = [[self.dataArr objectAtIndexSafe:indexPath.section] mutableCopy];
    [tempContentArr replaceObjectAtIndex:indexPath.row withObject:model];
    [self.dataArr replaceObjectAtIndex:indexPath.section withObject:tempContentArr];
    [self.baseTableView reloadData];
}

#pragma mark - Lazy
- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

@end
