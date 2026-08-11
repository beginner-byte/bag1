//
//  NoaChatHistoryTextVC.m
//  NoaKit
//
//  Created by Candy on 2026/11/11.
//

#import "NoaChatHistoryTextVC.h"
#import "NoaSearchView.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "NoaChatHistoryHeaderView.h"
#import "NoaChatHistoryTextCell.h"
#import "NoaChatHistoryChoiceUserVC.h"

@interface NoaChatHistoryTextVC () <ZSearchViewDelegate,UITableViewDataSource,UITableViewDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate,ZBaseCellDelegate, ZChatHistoryHeaderViewDelegate, ZChatHistoryChoiceUserDelegate>

@property (nonatomic, strong) NoaChatHistoryHeaderView *selectHeadView;
@property (nonatomic, strong) NSMutableArray *historyList;
@property (nonatomic, copy) NSString *searchStr;

@end

@implementation NoaChatHistoryTextVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navView.hidden = YES;
    _historyList = [NSMutableArray array];
    _searchStr = @"";
    
    [self setupUI];
    [self refreshHeaderView];
}

#pragma mark - 界面布局
- (void)setupUI {
    NoaSearchView *viewSearch = [[NoaSearchView alloc] initWithPlaceholder:LanguageToolMatch(@"搜索")];
    viewSearch.frame = CGRectMake(0, DWScale(6), DScreenWidth, DWScale(38));
    viewSearch.currentViewSearch = YES;
    viewSearch.delegate = self;
    viewSearch.returnKeyType = UIReturnKeyDefault;
    [self.view addSubview:viewSearch];
    
    self.selectHeadView = [[NoaChatHistoryHeaderView alloc] init];
    self.selectHeadView.delegate = self;
    [self.view addSubview:self.selectHeadView];
    [self.selectHeadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewSearch.mas_bottom);
        make.leading.trailing.equalTo(self.view);
        make.height.mas_equalTo(DWScale(38));
    }];
    
    [self.view addSubview:self.baseTableView];
    self.baseTableView.dataSource = self;
    self.baseTableView.delegate = self;
    self.baseTableView.emptyDataSetSource = self;
    self.baseTableView.emptyDataSetDelegate = self;
    self.baseTableView.delaysContentTouches = NO;
    [self.baseTableView registerClass:[NoaChatHistoryTextCell class] forCellReuseIdentifier:[NoaChatHistoryTextCell cellIdentifier]];
    [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.selectHeadView.mas_bottom).offset(DWScale(6));
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-DHomeBarH);
    }];
}


- (void)refreshHeaderView{
    if (self.chatType == CIMChatType_GroupChat) {
        self.selectHeadView.hidden = self.groupInfo.closeSearchUser;
        [self.selectHeadView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.groupInfo.closeSearchUser ? DWScale(0) : DWScale(38));
        }];
    }
}


#pragma mark - 返回到指定VC
- (void)popToVC {
    WeakSelf
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //返回到聊天界面
        if ([NSStringFromClass([obj class]) isEqualToString:@"NoaChatViewController"]) {
            [weakSelf.navigationController popToViewController:obj animated:YES];
            *stop = YES;
        }
        //返回到文件助手界面
        if ([NSStringFromClass([obj class]) isEqualToString:@"CoHereFileHelperViewController"]) {
            [weakSelf.navigationController popToViewController:obj animated:YES];
            *stop = YES;
        }
    }];
}

#pragma mark - ZSearchViewDelegate
- (void)searchViewReturnKeySearch:(NSString *)searchStr {
    if (![NSString isNil:[searchStr trimString]] && ![NSString isNil:_sessionID]) {
        _searchStr = [searchStr trimString];
        [self checkLocalDBData];
        [self.view endEditing:YES];
    }
}

- (void)searchViewTextValueChanged:(NSString *)searchStr {
    if ([NSString isNil:searchStr]) {
        _searchStr = @"";
        if(self.selectHeadView.userInfoList.count <= 0) {
            //清空搜索内容
            [_historyList removeAllObjects];
            [self.baseTableView reloadData];
        } else {
            [self checkLocalDBData];
        }
    }
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
        [_historyList removeAllObjects];
        [self.baseTableView reloadData];
    } else {
        [self checkLocalDBData];
    }
}

#pragma mark - ZChatHistoryChoiceUserDelegate
- (void)chatHistoryChoicedUserList:(NSArray<NoaBaseUserModel *> *)selectedUserList {
    self.selectHeadView.userInfoList = [selectedUserList mutableCopy];
    if(self.selectHeadView.userInfoList.count <= 0 && [NSString isNil:self.searchStr]) {
        [_historyList removeAllObjects];
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
    _historyList = [IMSDKManager toolGetChatMessageHistoryWith:_sessionID offset:0 messageType:@[@(CIMChatMessageType_TextMessage),@(CIMChatMessageType_AtMessage)] textMessageLike:_searchStr userIdList:userIdList].mutableCopy;
    [self.baseTableView reloadData];
}

#pragma mark - ZBaseCellDelegate
- (void)cellClickAction:(NSIndexPath *)indexPath {
    NoaIMChatMessageModel *model = [_historyList objectAtIndexSafe:indexPath.row];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:model.msgID forKey:@"selectMessageID"];
    [dict setValue:@(model.sendTime) forKey:@"selectMessageSendTime"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChatHistorySelectMessage" object:nil userInfo:dict];
    
    [self performSelector:@selector(popToVC) withObject:self afterDelay:0.5];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _historyList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaChatHistoryTextCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaChatHistoryTextCell cellIdentifier] forIndexPath:indexPath];
    cell.baseCellIndexPath = indexPath;
    cell.baseDelegate = self;
    NoaIMChatMessageModel *model = [_historyList objectAtIndexSafe:indexPath.row];
    [cell configCellWith:model searchContent:_searchStr];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [NoaChatHistoryTextCell defaultCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    if (![NSString isNil:_searchStr]) {
        NSString *string = LanguageToolMatch(@"换个关键词试试吧～");
        NSMutableAttributedString *accessAttributeString  = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName:FONTR(16),NSForegroundColorAttributeName:COLOR_5966F2}];
        return accessAttributeString;
    }else {
        NSString *string = @" ";
        NSMutableAttributedString *accessAttributeString  = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName:FONTR(16),NSForegroundColorAttributeName:COLOR_5966F2}];
        return accessAttributeString;
    }
}

#pragma mark - DZNEmptyDataSetDelegate
//允许滑动
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}

@end
