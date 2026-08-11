//
//  NoaChatTextUrlListView.m
//  NoaKit
//
//  Created by Candy on 2023/7/23.
//

#import "NoaChatTextUrlListView.h"
#import "NoaBaseTableView.h"
#import "NoaChatTextUrlCell.h"
#import "NoaToolManager.h"

@interface NoaChatTextUrlListView () <UITableViewDataSource, UITableViewDelegate, ZBaseCellDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NoaBaseTableView *tableView;
@property (nonatomic, strong) NSArray *tagList;
@property (nonatomic, assign) CGFloat viewH;

@end

@implementation NoaChatTextUrlListView

- (instancetype)initWithDataList:(NSArray *)dataList {
    self = [super init];
    if (self) {
        _tagList = dataList;
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    self.frame = CGRectMake(0, 0, DScreenWidth, DScreenHeight);
    self.backgroundColor = [COLOR_00 colorWithAlphaComponent:0.3];
    [CurrentWindow addSubview:self];
    
    _viewH = _tagList.count * DWScale(56) + DWScale(10) + DWScale(56) + DHomeBarH;
    _tableView = [[NoaBaseTableView alloc] initWithFrame:CGRectMake(0, DScreenHeight, DScreenWidth, _viewH) style:UITableViewStylePlain];
    _tableView.scrollEnabled = NO;
    [_tableView round:DWScale(16) RectCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
    [self addSubview:_tableView];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    [_tableView registerClass:[NoaChatTextUrlCell class] forCellReuseIdentifier:[NoaChatTextUrlCell cellIdentifier]];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDismiss)];
    tapGes.delegate = self;
    [self addGestureRecognizer:tapGes];
    
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return _tagList.count;
            break;
            
        default:
            return 1;
            break;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaChatTextUrlCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaChatTextUrlCell cellIdentifier] forIndexPath:indexPath];
    cell.baseDelegate = self;
    cell.baseCellIndexPath = indexPath;
    if (indexPath.section == 0) {
        cell.lblContent.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        cell.lblContent.font = FONTR(16);
        cell.lblContent.text = [_tagList objectAtIndexSafe:indexPath.row];
        cell.viewLine.hidden = (indexPath.row == _tagList.count - 1) ? YES : NO;
    }else {
        cell.lblContent.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        cell.lblContent.font = FONTR(16);
        cell.lblContent.text = LanguageToolMatch(@"取消");
        cell.viewLine.hidden = YES;
    }
    return cell;
}
#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        UIView *viewFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DWScale(10))];
        viewFooter.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F6F6F6_DARK];
        return viewFooter;
    }
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return DWScale(10);
    }
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [NoaChatTextUrlCell defaultCellHeight];
}
#pragma mark - ZBaseCellDelegate
- (void)cellClickAction:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (self.textUrlClickBlock) {
            self.textUrlClickBlock(indexPath.row);
        }
    }
    //关闭
    [self viewDismiss];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:_tableView]) {
        return NO;
    }
    return YES;
}

#pragma mark - 交互事件
- (void)viewShow {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.tableView.y = DScreenHeight - weakSelf.viewH;
    }];
}
- (void)viewDismiss {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.tableView.y = DScreenHeight;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
        [weakSelf.tableView removeFromSuperview];
        weakSelf.tableView = nil;
    }];
}

@end
