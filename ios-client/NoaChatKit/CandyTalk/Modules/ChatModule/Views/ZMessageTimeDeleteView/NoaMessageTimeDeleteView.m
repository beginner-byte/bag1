//
//  NoaMessageTimeDeleteView.m
//  NoaKit
//
//  Created by Candy on 2023/4/18.
//

#import "NoaMessageTimeDeleteView.h"
#import "NoaBaseTableView.h"
#import "NoaMessageTimeDeleteCell.h"
#import "NoaToolManager.h"

@interface NoaMessageTimeDeleteView () <UITableViewDataSource, UITableViewDelegate, ZBaseCellDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) NoaBaseTableView *tableView;
@property (nonatomic, strong) NSArray *dayList;
@property (nonatomic, assign) CGFloat viewH;
@end


@implementation NoaMessageTimeDeleteView
- (instancetype)initWithShowCloseView:(BOOL)showClose {
    self = [super init];
    if (self) {
        if (showClose) {
            _dayList = @[LanguageToolMatch(@"1天"), LanguageToolMatch(@"7天"), LanguageToolMatch(@"30天"), LanguageToolMatch(@"关闭自动删除")];
        }else {
            _dayList = @[LanguageToolMatch(@"1天"), LanguageToolMatch(@"7天"), LanguageToolMatch(@"30天")];
        }
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    self.frame = CGRectMake(0, 0, DScreenWidth, DScreenHeight);
    [CurrentWindow addSubview:self];
    
    _viewH = _dayList.count * DWScale(56) + DWScale(10) + DWScale(56) + DHomeBarH;
    _tableView = [[NoaBaseTableView alloc] initWithFrame:CGRectMake(0, DScreenHeight, DScreenWidth, _viewH) style:UITableViewStylePlain];
    _tableView.scrollEnabled = NO;
    [_tableView round:DWScale(16) RectCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
    [self addSubview:_tableView];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:[NoaMessageTimeDeleteCell class] forCellReuseIdentifier:[NoaMessageTimeDeleteCell cellIdentifier]];
    
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
            return _dayList.count;
            break;
            
        default:
            return 1;
            break;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaMessageTimeDeleteCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaMessageTimeDeleteCell cellIdentifier] forIndexPath:indexPath];
    cell.baseDelegate = self;
    cell.baseCellIndexPath = indexPath;
    if (indexPath.section == 0) {
        cell.lblContent.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        cell.lblContent.font = FONTR(16);
        cell.lblContent.text = [_dayList objectAtIndexSafe:indexPath.row];
        cell.viewLine.hidden = (indexPath.row == _dayList.count - 1) ? YES : NO;
    }else {
        cell.lblContent.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
        cell.lblContent.font = FONTR(17);
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
    return [NoaMessageTimeDeleteCell defaultCellHeight];
}
#pragma mark - ZBaseCellDelegate
- (void)cellClickAction:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (_delegate && [_delegate respondsToSelector:@selector(messageTimeDeleteType:)]) {
            switch (indexPath.row) {
                case 0:
                {
                    [_delegate messageTimeDeleteType:1];
                }
                    break;
                case 1:
                {
                    [_delegate messageTimeDeleteType:7];
                }
                    
                    break;
                case 2:
                {
                    [_delegate messageTimeDeleteType:30];
                }
                    
                    break;
                    
                default:
                {
                    [_delegate messageTimeDeleteType:0];
                }
                    break;
            }
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
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
