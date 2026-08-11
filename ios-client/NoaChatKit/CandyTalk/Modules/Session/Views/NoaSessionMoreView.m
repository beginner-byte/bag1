//
//  NoaSessionMoreView.m
//  NoaKit
//
//  Created by Candy on 2026/9/23.
//

#import "NoaSessionMoreView.h"
#import "NoaToolManager.h"
#import "NoaBaseTableView.h"
#import "NoaImageTitleContentArrowCell.h"

@interface NoaSessionMoreView () <UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate,ZBaseCellDelegate>
@property (nonatomic, strong) UIView *tabLayerBgView;
@property (nonatomic, strong) NoaBaseTableView *tableView;
@end

@implementation NoaSessionMoreView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSDictionary *addFriendDic = @{
            @"actionTitle" : LanguageToolMatch(@"添加好友"),
            @"actionImage" : @"cim_contacts_add",
            @"actionImage_dark" : @"cim_contacts_add_dark",
            @"actionType"  : @(ZSessionMoreActionTypeAddFriend)
        };
        NSDictionary *creatGroupDic = @{
            @"actionTitle" : LanguageToolMatch(@"创建群聊"),
            @"actionImage" : @"s_group_chat",
            @"actionImage_dark" : @"s_group_chat_dark",
            @"actionType"  : @(ZSessionMoreActionTypeCreateGroup)
        };
        NSDictionary *scanQrCodeDic = @{
            @"actionTitle" : LanguageToolMatch(@"扫一扫"),
            @"actionImage" : @"cim_qrcode_scan",
            @"actionImage_dark" : @"cim_qrcode_scan_dark",
            @"actionType"  : @(ZSessionMoreActionTypeSacnQRcode)
        };
        NSDictionary *boardHelperDic = @{
            @"actionTitle" : LanguageToolMatch(@"群发助手"),
            @"actionImage" : @"cim_board_helper",
            @"actionImage_dark" : @"cim_board_helper_dark",
            @"actionType"  : @(ZSessionMoreActionTypeMassMessage)

        };
        
        _actionList = [NSMutableArray array];
        if ([UserManager.userRoleAuthInfo.allowAddFriend.configValue isEqualToString:@"true"]) {
            [_actionList addObject:addFriendDic];
        }
        if ([UserManager.userRoleAuthInfo.createGroup.configValue isEqualToString:@"true"]) {
            [_actionList addObject:creatGroupDic];
        }
        [_actionList addObject:scanQrCodeDic];
        if ([UserManager.userRoleAuthInfo.groupHairAssistant.configValue isEqualToString:@"true"]) {
            [_actionList addObject:boardHelperDic];
        }
        
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    self.frame = CGRectMake(0, 0, DScreenWidth, DScreenHeight);
    self.backgroundColor = [UIColor clearColor];
    [CurrentWindow addSubview:self];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDismiss)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    //取巧设计
    //获取 群发助手 文本宽度
    CGFloat textW = [LanguageToolMatch(@"群发助手") widthForFont:FONTR(14)];
    CGFloat tableW = textW + DWScale(70);

    
    
    _tabLayerBgView = [[UIView alloc] initWithFrame:CGRectMake(DScreenWidth - tableW - DWScale(15), DNavStatusBarH, tableW, 0)];
    _tabLayerBgView.backgroundColor = [UIColor clearColor];
    _tabLayerBgView.layer.shadowColor = [UIColor blackColor].CGColor;
    _tabLayerBgView.layer.shadowOffset = CGSizeMake(0, 0); // 阴影偏移量，默认（0,0）
    _tabLayerBgView.layer.shadowOpacity = 0.1; // 不透明度
    _tabLayerBgView.layer.shadowRadius = 5;
    [self addSubview:_tabLayerBgView];
    [_tabLayerBgView resetFrameToFitRTL];
    
    _tableView = [[NoaBaseTableView alloc] initWithFrame:CGRectMake(0, 0, tableW, 0) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.bounces = NO;
    [_tableView registerClass:[NoaImageTitleContentArrowCell class] forCellReuseIdentifier:[NoaImageTitleContentArrowCell cellIdentifier]];
    [_tabLayerBgView addSubview:_tableView];
    _tableView.layer.cornerRadius = DWScale(8);
    _tableView.layer.masksToBounds = YES;
    _tableView.delaysContentTouches = NO;
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
    return _actionList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaImageTitleContentArrowCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaImageTitleContentArrowCell cellIdentifier] forIndexPath:indexPath];
    cell.lblContent.hidden = YES;
    cell.ivArrow.hidden = YES;
    NSDictionary *actionDict = [_actionList objectAtIndexSafe:indexPath.row];
    cell.ivLogo.tkThemeimages = @[ImgNamed(actionDict[@"actionImage"]), ImgNamed(actionDict[@"actionImage_dark"])];
    cell.lblTitle.text = actionDict[@"actionTitle"];
    
    cell.baseDelegate = self;
    cell.baseCellIndexPath = indexPath;
    
    return cell;
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DWScale(50);
}
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self viewDismiss];
//    if (_delegate && [_delegate respondsToSelector:@selector(moreViewDelegateWithAction:)]) {
//        [_delegate moreViewDelegateWithAction:indexPath.row + 1];
//    }
//    
//}
#pragma mark - ZBaseCellDelegate
- (void)cellClickAction:(NSIndexPath *)indexPath {
    [self viewDismiss];
    NSDictionary *actionDic = (NSDictionary *)[_actionList objectAtIndexSafe:indexPath.row];
    ZSessionMoreActionType actionType = [[actionDic objectForKeySafe:@"actionType"] integerValue];
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewDelegateWithAction:)]) {
        [_delegate moreViewDelegateWithAction:actionType];
    }
}
#pragma mark - 交互事件
- (void)viewShow {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.tabLayerBgView.height = weakSelf.actionList.count > 4 ? DWScale(200) : weakSelf.actionList.count * DWScale(50);
        weakSelf.tableView.height = weakSelf.actionList.count > 4 ? DWScale(200) : weakSelf.actionList.count * DWScale(50);
    }];
}

- (void)viewDismiss {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.tabLayerBgView.height = 0;
        weakSelf.tableView.height = 0;
    } completion:^(BOOL finished) {
        [weakSelf.tabLayerBgView removeFromSuperview];
        weakSelf.tabLayerBgView = nil;
        [weakSelf.tableView removeFromSuperview];
        weakSelf.tableView = nil;
        [weakSelf removeFromSuperview];
    }];
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewDelegateWithAction:)]) {
        [_delegate moreViewDelegateWithAction:0];
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
