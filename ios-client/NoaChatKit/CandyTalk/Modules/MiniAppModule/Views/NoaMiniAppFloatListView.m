//
//  NoaMiniAppFloatListView.m
//  NoaKit
//
//  Created by Candy on 2023/7/19.
//

#import "NoaMiniAppFloatListView.h"
#import "NoaToolManager.h"
#import "NoaBaseTableView.h"
#import "NoaMiniAppFloatListCell.h"

#import "NoaMiniAppWebVC.h"

@interface NoaMiniAppFloatListView () <UITableViewDelegate, UITableViewDataSource, ZBaseCellDelegate, ZMiniAppFloatListCellDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NoaBaseTableView *miniAppTableView;
@property (nonatomic, strong) UIButton *btnDeleteAll;//清空
@property (nonatomic, strong) NSMutableArray *miniAppList;

@end

@implementation NoaMiniAppFloatListView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _miniAppList = [NSMutableArray array];
        
        [self setupUI];
        [self requestMiniAppFloatList];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    self.frame = CGRectMake(0, 0, DScreenWidth, DScreenHeight);
    self.tkThemebackgroundColors = @[COLOR_CLEAR, COLOR_CLEAR_DARK];
    [CurrentWindow addSubview:self];
    
    _miniAppTableView = [[NoaBaseTableView alloc] initWithFrame:CGRectMake(DScreenWidth, 0, DScreenWidth, DScreenHeight) style:UITableViewStyleGrouped];
    _miniAppTableView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    _miniAppTableView.delegate = self;
    _miniAppTableView.dataSource = self;
    [self addSubview:_miniAppTableView];
    
    UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DNavStatusBarH)];
    viewHeader.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    _miniAppTableView.tableHeaderView = viewHeader;
    
    UIView *viewFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DHomeBarH)];
    viewFooter.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    _miniAppTableView.tableFooterView = viewFooter;
    
    [_miniAppTableView registerClass:[NoaMiniAppFloatListCell class] forCellReuseIdentifier:[NoaMiniAppFloatListCell cellIdentifier]];
    
    UILabel *lblTip = [UILabel new];
    lblTip.text = LanguageToolMatch(@"链接");
    lblTip.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    lblTip.font = FONTR(14);
    [viewHeader addSubview:lblTip];
    [lblTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(viewHeader).offset(DWScale(22));
        make.bottom.equalTo(viewHeader).offset(-DWScale(10));
        make.height.mas_equalTo(DWScale(21));
    }];
    
    _btnDeleteAll = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnDeleteAll setTitle:LanguageToolMatch(@"清空") forState:UIControlStateNormal];
    [_btnDeleteAll setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateNormal];
    [_btnDeleteAll setTitle:LanguageToolMatch(@"清空全部") forState:UIControlStateSelected];
    [_btnDeleteAll setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateSelected];
    [_btnDeleteAll addTarget:self action:@selector(btnDeleteAllClick) forControlEvents:UIControlEventTouchUpInside];
    _btnDeleteAll.titleLabel.font = FONTR(14);
    [viewHeader addSubview:_btnDeleteAll];
    [_btnDeleteAll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(lblTip);
        make.trailing.equalTo(viewHeader).offset(-DWScale(26));
        make.height.mas_equalTo(DWScale(21));
    }];
    
    //点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(miniAppFloatListDismiss)];
    tap.delegate = self;
    [_miniAppTableView addGestureRecognizer:tap];
    
    //右滑手势
    UISwipeGestureRecognizer *rightGes = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(miniAppFloatListDismiss)];
    rightGes.direction = UISwipeGestureRecognizerDirectionRight;
    [_miniAppTableView addGestureRecognizer:rightGes];
}
#pragma mark - 数据请求
- (void)requestMiniAppFloatList {
    _miniAppList = [IMSDKManager imSdkGetMyFloatMiniAppList].mutableCopy;
    [_miniAppTableView reloadData];
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _miniAppList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaMiniAppFloatListCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaMiniAppFloatListCell cellIdentifier] forIndexPath:indexPath];
    NoaFloatMiniAppModel *model = [_miniAppList objectAtIndexSafe:indexPath.row];
    cell.floatMiniAppModel = model;
    cell.baseDelegate = self;
    cell.baseCellIndexPath = indexPath;
    cell.delegate = self;
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [NoaMiniAppFloatListCell defaultCellHeight];
}
#pragma mark - ZBaseCellDelegate
- (void)cellClickAction:(NSIndexPath *)indexPath {
    NoaFloatMiniAppModel * floadModel = [_miniAppList objectAtIndexSafe:indexPath.row];
    
    if ([CurrentVC isKindOfClass:[NoaMiniAppWebVC class]]) {
        NoaMiniAppWebVC *currentVC = (NoaMiniAppWebVC *)CurrentVC;
        if ([currentVC.floatMiniAppModel.floladId isEqualToString:floadModel.floladId]) {
            [self miniAppFloatListDismiss];
        } else {
            [CurrentVC.navigationController popViewControllerAnimated:YES];
            [self navToNewMiniWebVC:floadModel];
        }
    } else {
        [self navToNewMiniWebVC:floadModel];
    }
}

- (void)navToNewMiniWebVC:(NoaFloatMiniAppModel *)floadModel {
    NoaMiniAppWebVC *oldVC = [ZWebCachesTOOL.caches objectForKey:floadModel.floladId];
    if (oldVC) {
        [CurrentVC.navigationController pushViewController:oldVC animated:YES];
    } else {
        NoaMiniAppWebVC *vc = [[NoaMiniAppWebVC alloc] init];
        vc.webViewUrl = floadModel.url;
        vc.floatMiniAppModel = floadModel;
        vc.webType = ZMiniAppWebVCTypeMiniApp;
        [CurrentVC.navigationController pushViewController:vc animated:YES];
    }
    [self miniAppFloatListDismiss];
}

#pragma mark - ZMiniAppFloatListCellDelegate
- (void)miniAppDeleteWith:(NSIndexPath *)cellIndex {
    
    NoaFloatMiniAppModel *model = [_miniAppList objectAtIndexSafe:cellIndex.row];
    [IMSDKManager imSdkDeleteFloatMiniAppWith:model.floladId];
    
    [ZWebCachesTOOL.caches removeObjectForKey:model.floladId];
    
    [_miniAppList removeObjectAtIndexSafe:cellIndex.row];
    
    if (_miniAppList.count > 0) {
        [_miniAppTableView reloadData];
    }else {
        [self miniAppFloatListDismiss];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MyMiniAppFloatRemove" object:nil];
    }
    
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    NSString *touchViewClass = NSStringFromClass([touch.view class]);
    
    if (![touchViewClass isEqualToString:@"NoaBaseTableView"]) {
        return NO;
    }

    return YES;
}
#pragma mark - 动画效果
- (void)miniAppFloatListShow {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.miniAppTableView.left = 0;
    }];
}
- (void)miniAppFloatListDismiss {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.miniAppTableView.left = DScreenWidth;
        weakSelf.miniAppTableView.alpha = 0;
    } completion:^(BOOL finished) {
        [weakSelf.miniAppTableView removeFromSuperview];
        weakSelf.miniAppTableView = nil;
        
        [weakSelf removeFromSuperview];
    }];
}
#pragma mark - 交互事件
- (void)btnDeleteAllClick {
    if (_btnDeleteAll.isSelected) {
        //清空全部
        [IMSDKManager imSdkDeleteAllFloatMiniApp];
        [ZWebCachesTOOL.caches removeAllObject];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MyMiniAppFloatRemove" object:nil];
        [self miniAppFloatListDismiss];
    }else {
        _btnDeleteAll.selected = YES;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
