//
//  NoaTeamDetailVC.m
//  NoaKit
//
//  Created by Candy on 2023/7/20.
//

#import "NoaTeamDetailVC.h"
#import "NoaTeamMemberCell.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "NoaAlertTipView.h"
#import "NoaTeamMemberModel.h"
#import "NoaShareInviteViewController.h"
#import "NoaUserHomePageVC.h"
#import "NoaTeamUpdateNameView.h"

@interface NoaTeamDetailVC () <UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, ZBaseCellDelegate, ZTeamUpdateNameViewDelegate>

@property (nonatomic, strong) UILabel *lblTeamName;//团队名称
@property (nonatomic, strong) UILabel *lblTeamGroupNum;//团队名称
@property (nonatomic, strong) UILabel *lblTotalMember;//当前团队总人数
@property (nonatomic, strong) UILabel *lblInviteCode;//当前团队邀请码
@property (nonatomic, strong) UILabel *lblToday;//今日邀请
@property (nonatomic, strong) UILabel *lblYesterday;//昨日邀请
@property (nonatomic, strong) UILabel *lblMonth;//本月邀请

@property (nonatomic, strong) NSMutableArray *teamMemberList;
@property (nonatomic, assign) NSInteger pageNumber;
@property (nonatomic, strong) NoaTeamModel *teamDetailModel;

@end

@implementation NoaTeamDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _teamMemberList = [NSMutableArray array];
    _pageNumber = 1;
    
    [self configNavUI];
    [self setupUI];
    [self requestTeamDetailData];
    [self requestTeamMemberListData];
}

#pragma mark - 界面布局
- (void)configNavUI {
    self.navBtnRight.hidden = NO;
    if (self.teamModel.isDefaultTeam == 1) {
        self.navBtnRight.userInteractionEnabled = NO;
        [self.navBtnRight setTitle:LanguageToolMatch(@"默认团队") forState:UIControlStateNormal];
        [self.navBtnRight setTkThemeTitleColor:@[COLOR_66, COLOR_66_DARK] forState:UIControlStateNormal];
    } else {
        self.navBtnRight.userInteractionEnabled = YES;
        [self.navBtnRight setTitle:LanguageToolMatch(@"设置默认") forState:UIControlStateNormal];
        [self.navBtnRight setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateNormal];
    }
}

- (void)setupUI {
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
    
    //顶部控件
    UIView *viewTeamTop = [[UIView alloc] init];
    viewTeamTop.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
    viewTeamTop.layer.cornerRadius = DWScale(12);
    viewTeamTop.layer.masksToBounds = YES;
    [self.view addSubview:viewTeamTop];
    [viewTeamTop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(DWScale(16));
        make.trailing.equalTo(self.view).offset(-DWScale(16));
        make.top.equalTo(self.view).offset(DNavStatusBarH + DWScale(20));
        make.height.mas_equalTo(DWScale(86));
    }];
    
    UIButton *btnEdit = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnEdit setImage:ImgNamed(@"icon_link_edit") forState:UIControlStateNormal];
    [btnEdit addTarget:self action:@selector(btnEditClick) forControlEvents:UIControlEventTouchUpInside];
    [viewTeamTop addSubview:btnEdit];
    [btnEdit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(viewTeamTop).offset(-DWScale(14));
        make.top.equalTo(viewTeamTop).offset(DWScale(10));
        make.size.mas_equalTo(CGSizeMake(DWScale(30), DWScale(30)));
    }];
    
    _lblTeamName = [UILabel new];
    if (self.teamModel.isSystemCreate == 1) {
        _lblTeamName.text = LanguageToolMatch(@"默认团队");
    } else {
        _lblTeamName.text = LanguageToolMatch(_teamModel.teamName);
    }
    _lblTeamName.font = FONTB(14);
    _lblTeamName.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [viewTeamTop addSubview:_lblTeamName];
    [_lblTeamName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(viewTeamTop).offset(DWScale(14));
        make.trailing.equalTo(btnEdit.mas_leading).offset(-DWScale(14));
        make.top.equalTo(viewTeamTop).offset(DWScale(15));
        make.height.mas_equalTo(DWScale(20));
    }];
    
    UILabel *lblTeamGroupTitle = [UILabel new];
    lblTeamGroupTitle.text = LanguageToolMatch(@"团队关联群聊数");
    lblTeamGroupTitle.font = FONTR(12);
    lblTeamGroupTitle.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    [viewTeamTop addSubview:lblTeamGroupTitle];
    [lblTeamGroupTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(viewTeamTop).offset(-DWScale(15));
        make.leading.equalTo(_lblTeamName);
        make.height.mas_equalTo(DWScale(20));
    }];
    
    _lblTeamGroupNum = [UILabel new];
    _lblTeamGroupNum.text = @"0";
    _lblTeamGroupNum.font = FONTB(18);
    _lblTeamGroupNum.textAlignment = NSTextAlignmentRight;
    _lblTeamGroupNum.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [viewTeamTop addSubview:_lblTeamGroupNum];
    [_lblTeamGroupNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(lblTeamGroupTitle);
        make.trailing.equalTo(viewTeamTop).offset(-DWScale(18));
        make.height.mas_equalTo(DWScale(20));
    }];
    
    //中间控件
    UIView *viewTeamCenter = [[UIView alloc] init];
    viewTeamCenter.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
    viewTeamCenter.layer.cornerRadius = DWScale(12);
    viewTeamCenter.layer.masksToBounds = YES;
    [self.view addSubview:viewTeamCenter];
    [viewTeamCenter mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(DWScale(16));
        make.trailing.equalTo(self.view).offset(-DWScale(16));
        make.top.equalTo(self.view).offset(DNavStatusBarH + DWScale(20) + DWScale(86) + DWScale(10));
        make.height.mas_equalTo(DWScale(76));
    }];
    
    UILabel *lblTotalMemberTip = [UILabel new];
    lblTotalMemberTip.text = LanguageToolMatch(@"团队总人数");
    lblTotalMemberTip.font = FONTB(14);
    lblTotalMemberTip.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [viewTeamCenter addSubview:lblTotalMemberTip];
    [lblTotalMemberTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(viewTeamCenter).offset(DWScale(14));
        make.top.equalTo(viewTeamCenter).offset(DWScale(10));
        make.height.mas_equalTo(DWScale(20));
    }];
    
    _lblTotalMember = [UILabel new];
    _lblTotalMember.text = @"0";
    _lblTotalMember.font = FONTB(18);
    _lblTotalMember.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [viewTeamCenter addSubview:_lblTotalMember];
    [_lblTotalMember mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(viewTeamCenter).offset(DWScale(14));
        make.bottom.equalTo(viewTeamCenter).offset(-DWScale(14));
        make.height.mas_equalTo(DWScale(25));
    }];
    
    UIButton *btnShare = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnShare setTitle:LanguageToolMatch(@"分享") forState:UIControlStateNormal];
    [btnShare setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
    btnShare.titleLabel.font = FONTR(14);
    [btnShare setTkThemebackgroundColors:@[COLOR_5966F2, COLOR_5966F2_DARK]];
    [btnShare addTarget:self action:@selector(btnShareClick) forControlEvents:UIControlEventTouchUpInside];
    [btnShare rounded: DWScale(9)];
    [viewTeamCenter addSubview:btnShare];
    [btnShare mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(lblTotalMemberTip);
        make.trailing.equalTo(viewTeamCenter).offset(-DWScale(14));
        make.size.mas_equalTo(CGSizeMake(DWScale(50), DWScale(25)));
    }];
    
    if([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"俄语"]){
        btnShare.titleLabel.font = FONTR(10);
        btnShare.titleLabel.numberOfLines = 2;
    }
    
    
    UIButton *btnCopy = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCopy setImage:ImgNamed(@"team_copy") forState:UIControlStateNormal];
    [btnCopy addTarget:self action:@selector(btnCopyClick) forControlEvents:UIControlEventTouchUpInside];
    [viewTeamCenter addSubview:btnCopy];
    [btnCopy mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_lblTotalMember);
        make.trailing.equalTo(viewTeamCenter).offset(-DWScale(14));
        make.size.mas_equalTo(CGSizeMake(DWScale(18), DWScale(18)));
    }];
    
    _lblInviteCode = [UILabel new];
    _lblInviteCode.font = FONTR(12);
    _lblInviteCode.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _lblInviteCode.text = ![NSString isNil:self.teamModel.inviteCode] ? self.teamModel.inviteCode : LanguageToolMatch(@"暂无");
    [viewTeamCenter addSubview:_lblInviteCode];
    [_lblInviteCode mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_lblTotalMember);
        make.trailing.equalTo(btnCopy.mas_leading).offset(-DWScale(5));
    }];
    
    UILabel *lblInviteCodeTip = [UILabel new];
    lblInviteCodeTip.font = FONTR(12);
    lblInviteCodeTip.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    lblInviteCodeTip.text = LanguageToolMatch(@"邀请码");
    [viewTeamCenter addSubview:lblInviteCodeTip];
    [lblInviteCodeTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_lblTotalMember);
        make.trailing.equalTo(_lblInviteCode.mas_leading).offset(-DWScale(11));
    }];
    
    CGFloat viewTodayH = DWScale(65);
    if ([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"英语"]){
        viewTodayH = DWScale(85);
    }
    
    //今日邀请
    UIView *viewToday = [[UIView alloc] init];
    viewToday.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
    viewToday.layer.cornerRadius = DWScale(12);
    viewToday.layer.masksToBounds = YES;
    [self.view addSubview:viewToday];
    [viewToday mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(DWScale(16));
        make.top.equalTo(self.view).offset(DNavStatusBarH + DWScale(20 + 76 + 12 + 86 + 10));
        make.size.mas_equalTo(CGSizeMake((DScreenWidth - 16 - 16 - 16 - 16)/3, viewTodayH));
    }];
    
    _lblToday = [UILabel new];
    _lblToday.text = @"0";
    _lblToday.font = FONTR(18);
    _lblToday.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [viewToday addSubview:_lblToday];
    [_lblToday mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewToday);
        make.top.equalTo(viewToday).offset(DWScale(4));
    }];
    
    /*
    UIView *viewLineToday = [UIView new];
    viewLineToday.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
    [viewToday addSubview:viewLineToday];
    [viewLineToday mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewToday);
        make.top.equalTo(_lblToday.mas_bottom).offset(DWScale(4));
        make.size.mas_equalTo(CGSizeMake(DWScale(93), 1));
    }];
    */
    
    UILabel *lblTodayTip = [UILabel new];
    lblTodayTip.text = LanguageToolMatch(@"今日邀请");
    lblTodayTip.font = FONTR(14);
    lblTodayTip.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    lblTodayTip.preferredMaxLayoutWidth = DWScale(103);
    lblTodayTip.numberOfLines = 2;
    [viewToday addSubview:lblTodayTip];
    [lblTodayTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewToday);
        make.bottom.equalTo(viewToday).offset(-DWScale(4));
    }];
    
    //昨日邀请
    UIView *viewYesterday = [[UIView alloc] init];
    viewYesterday.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
    viewYesterday.layer.cornerRadius = DWScale(12);
    viewYesterday.layer.masksToBounds = YES;
    [self.view addSubview:viewYesterday];
    [viewYesterday mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(viewToday.mas_trailing).offset(DWScale(16));
        make.top.equalTo(self.view).offset(DNavStatusBarH + DWScale(20 + 76 + 12 + 86 + 10));
        make.size.mas_equalTo(viewToday);
    }];
    
    _lblYesterday = [UILabel new];
    _lblYesterday.text = @"0";
    _lblYesterday.font = FONTR(18);
    _lblYesterday.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [viewYesterday addSubview:_lblYesterday];
    [_lblYesterday mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewYesterday);
        make.top.equalTo(viewYesterday).offset(DWScale(4));
    }];
    
    /*
    UIView *viewLineYesterday = [UIView new];
    viewLineYesterday.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
    [viewYesterday addSubview:viewLineYesterday];
    [viewLineYesterday mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewYesterday);
        make.top.equalTo(_lblYesterday.mas_bottom).offset(DWScale(4));
        make.size.mas_equalTo(CGSizeMake(DWScale(93), 1));
    }];
    */
    
    UILabel *lblYesterdayTip = [UILabel new];
    lblYesterdayTip.text = LanguageToolMatch(@"昨日邀请");
    lblYesterdayTip.font = FONTR(14);
    lblYesterdayTip.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    lblYesterdayTip.preferredMaxLayoutWidth = DWScale(103);
    lblYesterdayTip.numberOfLines = 2;
    [viewYesterday addSubview:lblYesterdayTip];
    [lblYesterdayTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewYesterday);
        make.bottom.equalTo(viewYesterday).offset(-DWScale(4));
    }];
    
    //本月邀请
    UIView *viewMonth = [[UIView alloc] init];
    viewMonth.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
    viewMonth.layer.cornerRadius = DWScale(12);
    viewMonth.layer.masksToBounds = YES;
    [self.view addSubview:viewMonth];
    [viewMonth mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(viewYesterday.mas_trailing).offset(DWScale(16));
        make.top.equalTo(self.view).offset(DNavStatusBarH + DWScale(20 + 76 + 12 + 86 + 10));
        make.size.mas_equalTo(viewToday);
    }];
    
    _lblMonth = [UILabel new];
    _lblMonth.text = @"0";
    _lblMonth.font = FONTR(18);
    _lblMonth.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [viewMonth addSubview:_lblMonth];
    [_lblMonth mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewMonth);
        make.top.equalTo(viewMonth).offset(DWScale(4));
    }];
    
    /*
    UIView *viewLineMonth = [UIView new];
    viewLineMonth.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
    [viewMonth addSubview:viewLineMonth];
    [viewLineMonth mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewMonth);
        make.top.equalTo(_lblMonth.mas_bottom).offset(DWScale(4));
        make.size.mas_equalTo(CGSizeMake(DWScale(93), 1));
    }];
    */
    
    UILabel *lblMonthTip = [UILabel new];
    lblMonthTip.text = LanguageToolMatch(@"本月邀请");
    lblMonthTip.font = FONTR(14);
    lblMonthTip.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    lblMonthTip.preferredMaxLayoutWidth = DWScale(103);
    lblMonthTip.numberOfLines = 2;
    [viewMonth addSubview:lblMonthTip];
    [lblMonthTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewMonth);
        make.bottom.equalTo(viewMonth).offset(-DWScale(4));
    }];
    
    //团队成员列表
    self.baseTableView.delaysContentTouches = NO;
    self.baseTableView.dataSource = self;
    self.baseTableView.delegate = self;
    self.baseTableView.emptyDataSetSource = self;
    self.baseTableView.emptyDataSetDelegate = self;
    [self.baseTableView registerClass:[NoaTeamMemberCell class] forCellReuseIdentifier:[NoaTeamMemberCell cellIdentifier]];
    [self.view addSubview:self.baseTableView];
    [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(viewToday.mas_bottom).offset(DWScale(12));
        make.bottom.equalTo(self.view).offset(-DHomeBarH - DWScale(58));
    }];
    self.baseTableView.mj_header = self.refreshHeader;
    self.baseTableView.mj_footer = self.refreshFooter;
    
    //一键建群
    UIView *viewBottom = [[UIView alloc] init];
    viewBottom.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
    [self.view addSubview:viewBottom];
    [viewBottom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.view).offset(DScreenHeight - DWScale(52) - DHomeBarH);
        make.size.mas_equalTo(CGSizeMake(DScreenWidth, DWScale(52) + DHomeBarH));
    }];
    
    UIButton *btnGroup = [UIButton buttonWithType:UIButtonTypeCustom];
    btnGroup.frame = CGRectMake(0, 0, DScreenWidth, DWScale(52));
    [btnGroup setTitle:LanguageToolMatch(@"一键建群") forState:UIControlStateNormal];
    [btnGroup setTkThemeTitleColor:@[COLOR_11, COLOR_11_DARK] forState:UIControlStateNormal];
    btnGroup.titleLabel.font = FONTR(14);
    [btnGroup addTarget:self action:@selector(btnGroupClick) forControlEvents:UIControlEventTouchUpInside];
    [viewBottom addSubview:btnGroup];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _teamMemberList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaTeamMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaTeamMemberCell cellIdentifier] forIndexPath:indexPath];
    cell.baseDelegate = self;
    cell.baseCellIndexPath = indexPath;
    NoaTeamMemberModel *memberModel = [_teamMemberList objectAtIndexSafe:indexPath.row];
    cell.memberModel = memberModel;
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [NoaTeamMemberCell defaultCellHeight];
}

#pragma mark - ZBaseCellDelegate
- (void)cellClickAction:(NSIndexPath *)indexPath {
    NoaTeamMemberModel *memberModel = [_teamMemberList objectAtIndexSafe:indexPath.row];
    if (memberModel) {
        NoaUserHomePageVC *vc = [NoaUserHomePageVC new];
        vc.userUID = memberModel.userUid;
        vc.groupID = @"";
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *string = LanguageToolMatch(@"暂无数据");
    __block NSMutableAttributedString *accessAttributeString;
    self.view.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        switch (themeIndex) {
            case 1:
            {
                //暗黑
                accessAttributeString  = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName:FONTR(14),NSForegroundColorAttributeName:COLOR_99}];
            }
                break;
                
            default:
            {
                accessAttributeString  = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName:FONTR(14),NSForegroundColorAttributeName:COLOR_00}];
            }
                break;
        }
    };
    
    return accessAttributeString;
}
//图片距离中心偏移量
- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return -DWScale(30);
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

#pragma mark - ZTeamUpdateNameViewDelegate
- (void)teamUpdateNameAction:(NSString *)newName {
    self.teamModel.teamName = newName;
    if (self.teamModel.isSystemCreate == 1) {
        self.lblTeamName.text = LanguageToolMatch(@"默认团队");
    } else {
        self.lblTeamName.text = LanguageToolMatch(self.teamModel.teamName);
    }
    //更新团队列表里团队的新名称
    if (_delegate && [_delegate respondsToSelector:@selector(updateTeamName:index:)]) {
        [_delegate updateTeamName:newName index:_listIndex];
    }
}

#pragma mark - 交互事件
- (void)navBtnRightClicked {
    if (_teamDetailModel && _teamDetailModel.isDefaultTeam != 1) {
        //设置为默认团队
        WeakSelf
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObjectSafe:self.teamModel.teamId forKey:@"teamId"];
        [dict setObjectSafe:@(1) forKey:@"isDefaultTeam"];
        [IMSDKManager imTeamEditWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            weakSelf.teamDetailModel.isDefaultTeam = 1;
            weakSelf.navBtnRight.userInteractionEnabled = NO;
            [weakSelf.navBtnRight setTitle:LanguageToolMatch(@"默认团队") forState:UIControlStateNormal];
            [weakSelf.navBtnRight setTkThemeTitleColor:@[COLOR_66, COLOR_66_DARK] forState:UIControlStateNormal];
            [HUD showMessage:LanguageToolMatch(@"设置成功")];
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            [HUD showMessageWithCode:code errorMsg:msg];
        }];
    }
}

- (void)btnEditClick {
    //修改团队名称
    NoaTeamUpdateNameView *viewUpdate = [NoaTeamUpdateNameView new];
    viewUpdate.model = self.teamModel;
    viewUpdate.delegate = self;
    [viewUpdate updateViewShow];
}

- (void)btnShareClick {
    NoaShareInviteViewController *vc = [NoaShareInviteViewController new];
    vc.teamID = self.teamModel.teamId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)btnCopyClick {
    if (![NSString isNil:_teamDetailModel.inviteCode]) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = _teamDetailModel.inviteCode;
        [HUD showMessage:LanguageToolMatch(@"复制成功")];
    }
}
- (void)btnGroupClick {
    if (_teamMemberList.count >= 3) {
        WeakSelf
        NoaAlertTipView *alertView = [NoaAlertTipView new];
        alertView.lblTitle.text = LanguageToolMatch(@"提示");
        alertView.lblTitle.font = FONTB(16);
        alertView.lblContent.text = LanguageToolMatch(@"建群时只会拉取你的好友");
        alertView.lblContent.font = FONTN(15);
        self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
            UIColor *color = nil;
            if (themeIndex == 0) {
                color = COLOR_66;
            } else {
                color = COLOR_66_DARK;
            }
           alertView.lblContent.textColor = color;
        };
        [alertView.btnSure setTitle:LanguageToolMatch(@"确定") forState:UIControlStateNormal];
        [alertView.btnSure setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateNormal];
        [alertView.btnCancel setTkThemeTitleColor:@[COLOR_11, COLOR_11_DARK] forState:UIControlStateNormal];
        [alertView alertTipViewSHow];
        alertView.sureBtnBlock = ^{
            [weakSelf teamCreateGroup];
        };
    } else {
        [HUD showMessage:LanguageToolMatch(@"人数不足三人，无法创建群聊")];
    }
}
//一键建群
- (void)teamCreateGroup {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:self.teamModel.teamId forKey:@"teamId"];
    [IMSDKManager imTeamCreateGroupWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD showMessage:LanguageToolMatch(@"操作成功")];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}
#pragma mark - 请求团队详情数据
- (void)requestTeamDetailData {
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:self.teamModel.teamId forKey:@"teamId"];
    [IMSDKManager imTeamDetailWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDict = (NSDictionary *)data;
            weakSelf.teamDetailModel = [NoaTeamModel mj_objectWithKeyValues:dataDict];
            [weakSelf updateUI];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

- (void)updateUI {
    if (_teamDetailModel) {
        _lblTotalMember.text = [NSString stringWithFormat:@"%ld", _teamDetailModel.totalInviteNum];
        _lblInviteCode.text = _teamDetailModel.inviteCode;
        _lblToday.text = [NSString stringWithFormat:@"%ld", _teamDetailModel.todayInviteNum];
        _lblYesterday.text = [NSString stringWithFormat:@"%ld", _teamDetailModel.yesterdayInviteNum];
        _lblMonth.text = [NSString stringWithFormat:@"%ld", _teamDetailModel.mouthInviteCount];
        
        if (_teamDetailModel.isDefaultTeam == 1) {
            [self.navBtnRight setTitle:LanguageToolMatch(@"默认团队") forState:UIControlStateNormal];
            [self.navBtnRight setTkThemeTitleColor:@[COLOR_CCCCCC, COLOR_CCCCCC_DARK] forState:UIControlStateNormal];
            self.navBtnRight.userInteractionEnabled = NO;
        }else {
            [self.navBtnRight setTitle:LanguageToolMatch(@"设置默认") forState:UIControlStateNormal];
            [self.navBtnRight setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateNormal];
            self.navBtnRight.userInteractionEnabled = YES;
        }
    }
}

- (void)requestTeamMemberListData {
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:self.teamModel.teamId forKey:@"teamId"];
    [dict setObjectSafe:@(_pageNumber) forKey:@"pageNumber"];
    [dict setObjectSafe:@(50) forKey:@"pageSize"];
    [dict setObjectSafe:@((_pageNumber - 1) * 50) forKey:@"pageStart"];
    [IMSDKManager imTeamMemberListWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDict = (NSDictionary *)data;
            //数据处理
            if (weakSelf.pageNumber == 1) {
                [weakSelf.teamMemberList removeAllObjects];
            }
            NSArray *teamMemberListTemp = (NSArray *)[dataDict objectForKeySafe:@"records"];
            [teamMemberListTemp enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NoaTeamMemberModel *memberModel = [NoaTeamMemberModel mj_objectWithKeyValues:obj];
                [weakSelf.teamMemberList addObjectIfNotNil:memberModel];
            }];
            [weakSelf.baseTableView reloadData];
            
            //分页处理
            NSInteger totalPage = [[dataDict objectForKeySafe:@"pages"] integerValue];
            if (weakSelf.pageNumber < totalPage) {
                if (!weakSelf.baseTableView.mj_footer) {
                    weakSelf.baseTableView.mj_footer = weakSelf.refreshFooter;
                }
            }else {
                weakSelf.baseTableView.mj_footer = nil;
            }
        }
        
        [weakSelf.baseTableView.mj_header endRefreshing];
        [weakSelf.baseTableView.mj_footer endRefreshing];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
        [weakSelf.baseTableView.mj_header endRefreshing];
        [weakSelf.baseTableView.mj_footer endRefreshing];
    }];
    
}
- (void)headerRefreshData {
    _pageNumber = 1;
    [self requestTeamMemberListData];
}
- (void)footerRefreshData {
    _pageNumber++;
    [self requestTeamMemberListData];
}


@end
