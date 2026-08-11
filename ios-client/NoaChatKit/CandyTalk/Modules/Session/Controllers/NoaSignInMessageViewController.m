//
//  NoaSignInViewController.m
//  NoaKit
//
//  Created by Apple on 2023/8/15.
//

#import "NoaSignInMessageViewController.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "NoaChatKit-Swift.h"
#import "SignInTableViewCell.h"
@interface NoaSignInMessageViewController ()<UITableViewDelegate,UITableViewDataSource,ZBaseCellDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
@property(nonatomic,strong) NSMutableArray * signHistoryList;
@end

@implementation NoaSignInMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navTitleStr = LanguageToolMatch(@"签到助手");
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
    [self setUpUI];
    [self requestSignHistoryList];
}
-(void)setUpUI{
    self.baseTableView.delegate = self;
    self.baseTableView.dataSource = self;
    self.baseTableView.bounces = YES;
    self.baseTableView.separatorColor = COLOR_CLEAR;
    self.baseTableView.delaysContentTouches = NO;
    self.baseTableView.emptyDataSetSource = self;
    self.baseTableView.emptyDataSetDelegate = self;
    [self.view addSubview:self.baseTableView];
    [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(DNavStatusBarH + DWScale(16));
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-DHomeBarH);
    }];
    [self.baseTableView registerClass:[SignInTableViewCell class] forCellReuseIdentifier:NSStringFromClass([SignInTableViewCell class])];
    
    //添加上拉加载
    self.baseTableView.mj_footer = self.refreshFooter;
}
-(NSMutableArray*)signHistoryList{
    if(_signHistoryList == nil){
        _signHistoryList = [[NSMutableArray alloc] init];
    }
    return _signHistoryList;
}
- (void)requestSignHistoryList {
    //展示本地数据库的签到提醒
    NSArray *localSiginMsgList = [[IMSDKManager messageGetSignInHistoryRecordWith:self.sessionID offset:0] mutableCopy];
    [self.signHistoryList addObjectsFromArray:localSiginMsgList];
    [self.baseTableView reloadData];
}

- (void)footerRefreshData {
    NSArray *localSiginMsgList = [[IMSDKManager messageGetSignInHistoryRecordWith:self.sessionID offset:self.signHistoryList.count] mutableCopy];
    if (localSiginMsgList.count > 0) {
        [self.baseTableView.mj_footer endRefreshing];
        [self.signHistoryList addObjectsFromArray:localSiginMsgList];
        [self.baseTableView reloadData];
    } else {
        [self.baseTableView.mj_footer endRefreshing];
        
        [self.baseTableView.mj_footer endRefreshingWithNoMoreData];
    }
}
#pragma mark - UITableViewDelegate  UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _signHistoryList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DWScale(155);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SignInTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SignInTableViewCell class]) forIndexPath:indexPath];
    NoaIMChatMessageModel *siginSecverMsg = [self.signHistoryList objectAtIndex:indexPath.row];
    cell.siginSecverTime = siginSecverMsg.sendTime;
    cell.baseCellIndexPath = indexPath;
    cell.baseDelegate = self;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - ZSessionCellDelegate cell点击事件
- (void)cellClickAction:(NSIndexPath *)indexPath{
    CoHereDailySignInViewController * signInVC = [[CoHereDailySignInViewController alloc] init];
    [self.navigationController pushViewController:signInVC animated:YES];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
