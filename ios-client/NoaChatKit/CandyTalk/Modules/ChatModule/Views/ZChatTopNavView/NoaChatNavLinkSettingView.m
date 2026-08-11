//
//  NoaChatNavLinkSettingView.m
//  NoaKit
//
//  Created by Candy on 2023/7/18.
//

#import "NoaChatNavLinkSettingView.h"
#import "NoaToolManager.h"
#import "NoaChatLinkSetViewCell.h"
#import "NoaChatTagModel.h"

@interface NoaChatNavLinkSettingView () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, ZChatLinkSetViewCellDelegate>

@property (nonatomic, strong)UIView *viewBg;
@property (nonatomic, strong)SyncMutableArray *linkList;
@property (nonatomic, strong)UITableView *tableView;

@end


@implementation NoaChatNavLinkSettingView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.frame = CGRectMake(0, 0, DScreenWidth, DScreenHeight);
    self.backgroundColor = COLOR_CLEAR;
    
    UITapGestureRecognizer *backTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(linkSettingViewDismiss)];
    backTap.delegate = self;
    [self addGestureRecognizer:backTap];
    
    CGFloat viewBg_Height = 10 * 2 + (self.linkList.count > 5 ? 5 : self.linkList.count) * DWScale(45);
    _viewBg = [UIView new];
    _viewBg.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];;
    [_viewBg rounded:DWScale(14)];
    _viewBg.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN, CGFLOAT_MIN);
    [self addSubview:_viewBg];
    [_viewBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(DStatusBarH + 44 + DWScale(40) + DWScale(6));
        make.leading.equalTo(self).offset(DWScale(16));
        make.trailing.equalTo(self).offset(-DWScale(16));
        make.height.mas_equalTo(viewBg_Height);
    }];
    
    [_viewBg addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_viewBg);
    }];
    [self.tableView registerClass:[NoaChatLinkSetViewCell class] forCellReuseIdentifier:NSStringFromClass([NoaChatLinkSetViewCell class])];
}

- (void)linkSettingViewShow {
    [CurrentWindow addSubview:self];
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewBg.transform = CGAffineTransformIdentity;
    }];
}

- (void)linkSettingViewDismiss {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewBg.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN, CGFLOAT_MIN);
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

#pragma mark - config data
- (void)configLinkListData:(NSMutableArray *)dataList {
    [self.linkList removeAllObjects];
    [self.linkList addObjectsFromArray:dataList];
    
    CGFloat viewBg_Height = 10 * 2 + (self.linkList.count > 5 ? 5 : self.linkList.count) * DWScale(45);
    [_viewBg mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(viewBg_Height);
    }];
    [self.tableView reloadData];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:_tableView]) {
        return NO;
    }
    return YES;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _linkList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaChatLinkSetViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoaChatLinkSetViewCell"];
    if (cell == nil){
        cell = [[NoaChatLinkSetViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NoaChatLinkSetViewCell"];
    }
    cell.delegate = self;
    cell.cellaPath = indexPath;
    NoaChatTagModel *tempTagModel = (NoaChatTagModel *)[_linkList objectAtIndex:indexPath.row];
    cell.tagModel = tempTagModel;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [UIView new];
    headerView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [UIView new];
    footerView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    return footerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - ZChatLinkSetViewCellDelegate
- (void)deleteChatLinkAction:(NSInteger)cellIndex {
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteAction:)]) {
        [self.delegate deleteAction:cellIndex];
    }
}

- (void)editChatLinkAction:(NSInteger)cellIndex {
    if (self.delegate && [self.delegate respondsToSelector:@selector(editAction:)]) {
        [self.delegate editAction:cellIndex];
    }
}

#pragma mark - Lazy
- (SyncMutableArray *)linkList {
    if (!_linkList) {
        _linkList = [[SyncMutableArray alloc] init];
    }
    return _linkList;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.bounces = NO;
        _tableView.separatorColor = COLOR_CLEAR;
        _tableView.delaysContentTouches = NO;
        _tableView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    }
    return _tableView;
}
@end
