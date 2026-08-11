//
//  NoaGroupNoticeListView.m
//  NoaKit
//
//  Created by phl on 2025/8/11.
//

#import "NoaGroupNoticeListView.h"
#import "NoaGroupNoticeListDataHandle.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "NoaGroupNoticeListCell.h"
#import "NoaGroupNoteLocalUserNameModel.h"

@interface NoaGroupNoticeListView()<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>

/// 下拉刷新
@property (nonatomic, strong) MJRefreshNormalHeader *refreshHeader;

/// 上拉加载
@property (nonatomic, strong) MJRefreshBackNormalFooter *refreshFooter;

/// 数据处理
@property (nonatomic, strong, readwrite) NoaGroupNoticeListDataHandle *dataHandle;

/// 列表
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation NoaGroupNoticeListView

- (void)dealloc {
    CIMLog(@"%@ dealloc", [self class]);
}

- (MJRefreshNormalHeader *)refreshHeader {
    if (!_refreshHeader) {
        @weakify(self)
        _refreshHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            @strongify(self)
            // 设置当前页数为第一页
            [self.dataHandle resumeDefaultConfigure];
            // 请求第一页下拉数据
            [self.dataHandle.requestListDataCommand execute:nil];
        }];
        
        _refreshHeader.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:14];
        _refreshHeader.lastUpdatedTimeLabel.hidden = YES;
        _refreshHeader.stateLabel.font = [UIFont systemFontOfSize:14];
        [_refreshHeader setTitle:LanguageToolMatch(@"下拉刷新") forState:MJRefreshStateIdle];
        [_refreshHeader setTitle:LanguageToolMatch(@"下拉刷新") forState:MJRefreshStatePulling];
        [_refreshHeader setTitle:LanguageToolMatch(@"正在加载...") forState:MJRefreshStateRefreshing];
        [_refreshHeader setTitle:LanguageToolMatch(@"正在加载...") forState:MJRefreshStateWillRefresh];
        
    }
    return _refreshHeader;
}
- (MJRefreshBackNormalFooter *)refreshFooter {
    if (!_refreshFooter) {
        @weakify(self)
        _refreshFooter = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            @strongify(self)
            [self.dataHandle requestMoreDataConfigure];
            [self.dataHandle.requestListDataCommand execute:nil];
        }];
        _refreshFooter.stateLabel.font = [UIFont systemFontOfSize:14];
        [_refreshFooter setTitle:LanguageToolMatch(@"上拉加载更多") forState:MJRefreshStateIdle];
        [_refreshFooter setTitle:LanguageToolMatch(@"上拉加载更多") forState:MJRefreshStatePulling];
        [_refreshFooter setTitle:LanguageToolMatch(@"正在加载...") forState:MJRefreshStateRefreshing];
        [_refreshFooter setTitle:LanguageToolMatch(@"正在加载...") forState:MJRefreshStateWillRefresh];
        [_refreshFooter setTitle:LanguageToolMatch(@"我是有底线的") forState:MJRefreshStateNoMoreData];
    }
    return _refreshFooter;
}

/// 展示我创建的团队
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.mj_header = self.refreshHeader;
        _tableView.mj_footer = self.refreshFooter;
        _tableView.emptyDataSetSource = self;
        _tableView.emptyDataSetDelegate = self;
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        if (@available(iOS 15.0, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        } else {
            // Fallback on earlier versions
        }
    }
    return _tableView;
}

- (instancetype)initWithFrame:(CGRect)frame
    GroupNoticeListDataHandle:(NoaGroupNoticeListDataHandle *)dataHandle {
    self = [super initWithFrame:frame];
    if (self) {
        self.dataHandle = dataHandle;
        [self setupUI];
        [self processData];
    }
    return self;
}

- (void)setupUI {
    // 我创建的团队
    self.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
    
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.leading.trailing.bottom.equalTo(self);
    }];
}

- (void)processData {
    @weakify(self)
    [self.dataHandle.requestListDataCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        BOOL isSuccess = [x boolValue];
        if (!isSuccess) {
            return;
        }
        [self.tableView reloadData];
    }];
    
    [self.dataHandle.requestNoticeDetailCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [HUD hideHUD];
        NoaGroupNoteModel *groupNoticeModel = x;
        if (!groupNoticeModel) {
            return;
        }
        [self.dataHandle.jumpEditSubject sendNext:groupNoticeModel];
    }];
    
    [self.dataHandle.deleteDataCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        BOOL isSuccess = [x boolValue];
        if (!isSuccess) {
            return;
        }
        // 重新获取
        [self reloadData];
    }];
    
    [self reloadData];
}

- (void)reloadData {
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - UITableViewDelegate  UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.dataHandle.topGroupNoteModelList.count;
    }else {
        return self.dataHandle.normalGroupNoteModelList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaGroupNoticeListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NoaGroupNoticeListCell class])];
    if (!cell) {
        cell = [[NoaGroupNoticeListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([NoaGroupNoticeListCell class])];
    }
    
    // 赋值
    cell.groupModel = [self.dataHandle obtainGroupModelWithIndexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaGroupNoteLocalUserNameModel *groupModel = [self.dataHandle obtainGroupModelWithIndexPath:indexPath];
    if (!groupModel) {
        return 0.0;
    }
    return [groupModel getCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaGroupNoteLocalUserNameModel *groupNoticeModel = [self.dataHandle obtainGroupModelWithIndexPath:indexPath];
    [self.dataHandle.jumpGroupInfoDetailSubject sendNext:groupNoticeModel];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 5.0;
    }
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 0.01;
    }
    return DHomeBarH > 0 ? DHomeBarH : 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    @weakify(self)
    // 1. 创建删除动作
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:nil handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        // 处理删除逻辑
        @strongify(self)
        [self.dataHandle.deleteDataCommand execute:indexPath];
        completionHandler(YES);
    }];
    
    // 自定义删除按钮样式
    UIImage *deleteImage = [self resizeImage:[UIImage imageNamed:@"g_notice_delete_action"] toSize:CGSizeMake(88, 88)];
    deleteAction.image = deleteImage;
    deleteAction.backgroundColor = COLOR_F5F6F9;
    
    // 2. 编辑动作
    UIContextualAction *editAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:nil handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        // 处理收藏逻辑
        @strongify(self)
        [HUD showActivityMessage:@"" inView:self];
        [self.dataHandle.requestNoticeDetailCommand execute:indexPath];
        completionHandler(YES);
    }];
    
    // 自定义收藏按钮样式
    UIImage *editImage = [self resizeImage:[UIImage imageNamed:@"g_notice_edit_action"] toSize:CGSizeMake(88, 88)];
    editAction.image = editImage;
    editAction.backgroundColor = COLOR_F5F6F9;
    
    // 4. 创建配置对象
    UISwipeActionsConfiguration *configuration;
    if (self.dataHandle.groupInfoModel.userGroupRole == 1 || self.dataHandle.groupInfoModel.userGroupRole == 2) {
        // 只有管理员跟群主能编辑、删除操作
        configuration = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction, editAction]];
    }else {
        // 普通用户无编辑、删除操作
        configuration = [UISwipeActionsConfiguration configurationWithActions:@[]];
    }
    
    
    configuration.performsFirstActionWithFullSwipe = NO; // 禁止全滑动自动执行第一个动作
    
    self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        if (themeIndex == 0) {
            deleteAction.backgroundColor = COLOR_F5F6F9;
            editAction.backgroundColor = COLOR_F5F6F9;
        }else {
            deleteAction.backgroundColor = COLOR_F5F6F9_DARK;
            editAction.backgroundColor = COLOR_F5F6F9_DARK;
        }
    };
    
    return configuration;
    
}

/// MARK: DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *string = LanguageToolMatch(@"暂无公告");
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    __block NSMutableAttributedString *accessAttributeString;
    self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        switch (themeIndex) {
            case 1: {
                //暗黑
                accessAttributeString  = [[NSMutableAttributedString alloc] initWithString:string attributes:@{
                    NSFontAttributeName:FONTR(16),
                    NSForegroundColorAttributeName:COLOR_99,
                    NSParagraphStyleAttributeName: paragraphStyle,
                }];
            }
                break;
                
            default: {
                accessAttributeString  = [[NSMutableAttributedString alloc] initWithString:string attributes:@{
                    NSFontAttributeName:FONTR(16),
                    NSForegroundColorAttributeName:COLOR_00,
                    NSParagraphStyleAttributeName: paragraphStyle,
                }];
            }
                break;
        }
    };
    return accessAttributeString;
}
/// 图片距离中心偏移量
- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return - 30;
}
/// 空态图片
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return ImgNamed(@"c_no_notice");
}

/// MARK:  DZNEmptyDataSetDelegate
/// 允许滑动
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}

- (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
