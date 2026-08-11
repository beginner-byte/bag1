//
//  NoaEmojiShopPackageViewController.m
//  NoaKit
//
//  Created by Candy on 2023/10/25.
//

#import "NoaEmojiShopPackageViewController.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "NoaEmojiShopPackagCell.h"
#import "NoaEmojiShopPackageHeaderView.h"
#import "NoaEmojiPackageDetailViewController.h"//表情包详情

@interface NoaEmojiShopPackageViewController () <UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, ZEmojiShopPackagCellDelegate>

@property (nonatomic, strong)NSMutableArray *stickersPackageList;
//起始页
@property (nonatomic, assign) NSInteger pageNumber;

@end

@implementation NoaEmojiShopPackageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    self.navView.hidden = YES;
    [self setupUI];
    _pageNumber = 1;
    [self requestStickersPackageListData];
}

- (void)setupUI {
    [self.view addSubview:self.baseTableView];
    self.baseTableView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    self.baseTableView.dataSource = self;
    self.baseTableView.delegate = self;
    self.baseTableView.emptyDataSetSource = self;
    self.baseTableView.emptyDataSetDelegate = self;
    self.baseTableView.separatorColor = COLOR_CLEAR;
    self.baseTableView.mj_header = self.refreshHeader;
    self.baseTableView.mj_footer = self.refreshFooter;
    [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    //添加上拉加载更多，分页
    self.baseTableView.mj_footer = self.refreshFooter;
    
    //cell & header
    [self.baseTableView registerClass:[NoaEmojiShopPackageHeaderView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([NoaEmojiShopPackageHeaderView class])];
    [self.baseTableView registerClass:[NoaEmojiShopPackagCell class] forCellReuseIdentifier:NSStringFromClass([NoaEmojiShopPackagCell class])];
}

- (void)headerRefreshData {
    _pageNumber = 1;
    [self requestStickersPackageListData];
}
- (void)footerRefreshData {
    _pageNumber++;
    [self requestStickersPackageListData];
}


#pragma mark - Net Working
//获取表情包列表 - 用户未下载的表情包
- (void)requestStickersPackageListData {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:@(_pageNumber) forKey:@"pageNumber"];
    [dict setObjectSafe:@(10) forKey:@"pageSize"];
    [dict setObjectSafe:@((_pageNumber - 1) * 10) forKey:@"pageStart"];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    WeakSelf
    [IMSDKManager imSdkUserFindUnUsedStickersPackageList:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [weakSelf.baseTableView.mj_footer endRefreshing];
        [weakSelf.baseTableView.mj_header endRefreshing];
        
        if ([data isKindOfClass:[NSDictionary class]]) {
            //数据处理
            if (weakSelf.pageNumber == 1) {
                [weakSelf.stickersPackageList removeAllObjects];
            }
        
            NSDictionary *dataDict = (NSDictionary *)data;
            NSArray *rowList = (NSArray *)[dataDict objectForKeySafe:@"rows"];
            NSArray *tempPackageList = [NoaIMStickersPackageModel mj_objectArrayWithKeyValuesArray:rowList];
            [weakSelf.stickersPackageList addObjectsFromArray:tempPackageList];
                
            //分页处理
            NSInteger totalPage = [[dataDict objectForKeySafe:@"pages"] integerValue];
            if (weakSelf.pageNumber < totalPage) {
                if (!weakSelf.baseTableView.mj_footer) {
                    weakSelf.baseTableView.mj_footer = weakSelf.refreshFooter;
                }
            } else {
                weakSelf.baseTableView.mj_footer = nil;
            }
            [weakSelf.baseTableView reloadData];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
        [weakSelf.baseTableView.mj_footer endRefreshing];
        [weakSelf.baseTableView.mj_header endRefreshing];
    }];
}

//添加表情包
- (void)requestAddStickersPackageWithStickersSetId:(NSString *)stickersSetId withIndex:(NSInteger)index {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:stickersSetId forKey:@"stickersSetId"];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    WeakSelf
    [IMSDKManager imSdkUserAddStickersPackage:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        //删除已添加的表情包并刷新tableView
        [HUD showMessage:LanguageToolMatch(@"添加成功")];
        NoaIMStickersPackageModel *packageModel = (NoaIMStickersPackageModel *)[self.stickersPackageList objectAtIndexSafe:index];
        packageModel.isDownLoad = YES;
        [weakSelf.stickersPackageList replaceObjectAtIndex:index withObject:packageModel];
        [weakSelf.baseTableView reloadData];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
        [weakSelf.baseTableView.mj_footer endRefreshing];
        [weakSelf.baseTableView.mj_header endRefreshing];
    }];
}

#pragma mark - Tableview delegate dataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.stickersPackageList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DWScale(84);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return DWScale(47);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NoaEmojiShopPackageHeaderView *viewHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([NoaEmojiShopPackageHeaderView class])];
    viewHeader.isShow = self.stickersPackageList.count > 0 ? YES : NO;
    return viewHeader;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaEmojiShopPackagCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NoaEmojiShopPackagCell class]) forIndexPath:indexPath];
    cell.baseCellIndexPath = indexPath;
    cell.delegate = self;
    NoaIMStickersPackageModel *packageModel = (NoaIMStickersPackageModel *)[self.stickersPackageList objectAtIndexSafe:indexPath.row];
    cell.model = packageModel;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NoaIMStickersPackageModel *packageModel = (NoaIMStickersPackageModel *)[self.stickersPackageList objectAtIndexSafe:indexPath.row];
    
    NoaEmojiPackageDetailViewController *vc = [[NoaEmojiPackageDetailViewController alloc] init];
    vc.supIndex = indexPath.row;
    vc.stickersSetId = packageModel.packageId;
    [self.navigationController pushViewController:vc animated:YES];
    WeakSelf
    [vc setPackageAddClick:^(NSInteger index) {
        NoaIMStickersPackageModel *packageModel = (NoaIMStickersPackageModel *)[self.stickersPackageList objectAtIndexSafe:index];
        packageModel.isDownLoad = YES;
        [weakSelf.stickersPackageList replaceObjectAtIndex:index withObject:packageModel];
        [weakSelf.baseTableView reloadData];
    }];
}

#pragma mark - ZEmojiShopPackagCellDelegate
- (void)emojiPackageAddNewEmoji:(NSIndexPath *)cellIndexPath {
    NoaIMStickersPackageModel *addPackageModel = (NoaIMStickersPackageModel *)[self.stickersPackageList objectAtIndexSafe:cellIndexPath.row];
    [self requestAddStickersPackageWithStickersSetId:addPackageModel.packageId withIndex:cellIndexPath.row];
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
- (NSMutableArray *)stickersPackageList {
    if (!_stickersPackageList) {
        _stickersPackageList = [[NSMutableArray alloc] init];
    }
    return _stickersPackageList;
}



@end
