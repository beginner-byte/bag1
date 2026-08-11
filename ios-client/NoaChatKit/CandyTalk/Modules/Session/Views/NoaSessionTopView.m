//
//  NoaSessionTopView.m
//  NoaKit
//
//  Created by Candy on 2026/9/23.
//

#import "NoaSessionTopView.h"
#import "NoaBaseImageView.h"

#import "NoaSessionMoreView.h"
#import "NoaMyMiniAppView.h"

static const CGFloat kFirstRowTopMargin = 5.0;
static const CGFloat kFirstRowAvatarSize = 34.0;
static const CGFloat kFirstRowTitleHeight = 24.0;
static const CGFloat kMiniAppEntryHeight = 40.0;
static const CGFloat kMiniAppEntryTopMargin = 11.0;

@interface NoaSessionTopView () <ZSessionMoreViewDelegate>
@property (nonatomic, strong) NoaBaseImageView *ivHeader;//头像

@property (nonatomic, strong) UILabel *lblUser;//用户
@property (nonatomic, strong) UILabel *lblRequestState;//加载数据接口状态
@property (nonatomic, strong) UIButton *btnMiniEntry;//我的应用入口
@property (nonatomic, strong) UILabel *lblMiniAppTitle;
@property (nonatomic, strong) UIImageView *ivMiniArrow;
@property (nonatomic, strong) NoaMyMiniAppView *viewMyMiniApp;
@property (nonatomic, assign) BOOL miniAppExpanded;
@property (nonatomic, strong) UIButton *btnSearch;//搜索
@property (nonatomic, strong) UIButton *btnAdd;//添加
@end

@implementation NoaSessionTopView

+ (CGFloat)preferredFirstRowHeightIsHome:(BOOL)isHome {
    CGFloat height = DStatusBarH + DWScale(kFirstRowTopMargin);
    if (isHome) {
        height += kFirstRowAvatarSize;
    } else {
        height += DWScale(kFirstRowTitleHeight);
    }
    return height;
}

+ (CGFloat)preferredHeightForContact {
    return [self preferredFirstRowHeightIsHome:NO];
}

+ (CGFloat)preferredHeightForHome:(BOOL)miniAppExpanded {
    CGFloat height = [self preferredFirstRowHeightIsHome:YES]
        + DWScale(kMiniAppEntryTopMargin)
        + DWScale(kMiniAppEntryHeight);
    if (miniAppExpanded) {
        height += kNoaMyMiniAppPanelHeight;
    }
    return height;
}

- (instancetype)init {
    return [self initWithHome:NO];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithHome:NO];
}

- (instancetype)initWithHome:(BOOL)isHome {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _isHome = isHome;
        [self setupUI];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewAppearUpdateUI) name:@"MineUserInfoUpdate" object:nil];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    UIView *titleAnchorView = nil;
    if (_isHome == YES) {
        _ivHeader = [[NoaBaseImageView alloc] init];
        _ivHeader.layer.cornerRadius = DWScale(34)/2;
        _ivHeader.layer.masksToBounds = YES;
        [_ivHeader sd_setImageWithURL:[UserManager.userInfo.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
        [self addSubview:_ivHeader];
        [_ivHeader mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(DWScale(16));
            make.top.equalTo(self).offset(DWScale(5) + DStatusBarH);
            make.size.mas_equalTo(CGSizeMake(34, 34));
        }];
        _ivHeader.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAvatarTapped)];
        [_ivHeader addGestureRecognizer:tap];
        
        _lblUser = [UILabel new];
        _lblUser.text = UserManager.userInfo.nickname;
        _lblUser.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _lblUser.font = FONTB(16);
        [self addSubview:_lblUser];
        [_lblUser mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo( _ivHeader.mas_trailing).offset(DWScale(10));
            make.size.mas_equalTo(CGSizeMake(DWScale(200), DWScale(24)));
            make.centerY.mas_equalTo(_ivHeader);
        }];
        titleAnchorView = _ivHeader;
    } else {
        _lblUser = [UILabel new];
        _lblUser.text = LanguageToolMatch(@"通讯录");
        _lblUser.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _lblUser.font = FONTB(16);
        [self addSubview:_lblUser];
        [_lblUser mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(DWScale(10));
            make.size.mas_equalTo(CGSizeMake(DWScale(200), DWScale(24)));
            make.top.equalTo(self).offset(DWScale(5) + DStatusBarH);
        }];
        titleAnchorView = _lblUser;
    }
    
    
    
    _lblRequestState = [UILabel new];
    _lblRequestState.text = LanguageToolMatch(@"数据加载中...");
    _lblRequestState.font = FONTN(10);
    _lblRequestState.hidden = YES;
    _lblRequestState.tkThemetextColors = @[[COLOR_FFA500 colorWithAlphaComponent:0.6], [COLOR_FFA500 colorWithAlphaComponent:0.6]];
    [self addSubview:_lblRequestState];
    [_lblRequestState mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lblUser.mas_bottom);
        make.leading.equalTo(_lblUser);
        make.width.mas_equalTo(DWScale(300));
    }];
    
    _btnAdd = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnAdd setTkThemeImage:@[ImgNamed(@"acon_add"), ImgNamed(@"acon_add")] forState:UIControlStateNormal];
    [_btnAdd addTarget:self action:@selector(btnAddClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btnAdd];
    [_btnAdd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(DWScale(5) + DStatusBarH);
        make.trailing.equalTo(self).offset(-DWScale(10));
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    
    _btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnSearch setImage:ImgNamed(@"acon_search") forState:UIControlStateNormal];
    [_btnSearch addTarget:self action:@selector(searchViewClickAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btnSearch];
    [_btnSearch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_btnAdd);
        make.trailing.equalTo(_btnAdd.mas_leading).offset(-DWScale(20));
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    
    if (_isHome) {
        [self setupMiniAppEntryBelowView:titleAnchorView];
    }
}

- (void)setupMiniAppEntryBelowView:(UIView *)anchorView {
    _btnMiniEntry = [UIButton buttonWithType:UIButtonTypeCustom];
//    _btnMiniEntry.tkThemebackgroundColors = @[COLOR_EFEFF2, [COLOR_EFEFF2_DARK colorWithAlphaComponent:0.14]];
//    [_btnMiniEntry rounded:10.0];
    [_btnMiniEntry addTarget:self action:@selector(btnMiniEntryClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btnMiniEntry];
    [_btnMiniEntry mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(DWScale(12));
        make.trailing.equalTo(self).offset(-DWScale(12));
        make.top.equalTo(anchorView.mas_bottom).offset(DWScale(kMiniAppEntryTopMargin));
        make.height.mas_equalTo(DWScale(kMiniAppEntryHeight));
    }];
    
    _lblMiniAppTitle = [[UILabel alloc] init];
    _lblMiniAppTitle.text = LanguageToolMatch(@"我的应用");
    _lblMiniAppTitle.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _lblMiniAppTitle.font = FONTR(16);
    [_btnMiniEntry addSubview:_lblMiniAppTitle];
    
    _ivMiniArrow = [[UIImageView alloc] initWithImage:ImgNamed(@"c_more_arrow_down")];
    _ivMiniArrow.contentMode = UIViewContentModeScaleAspectFit;
    [_btnMiniEntry addSubview:_ivMiniArrow];
    
    [_lblMiniAppTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_btnMiniEntry).offset(DWScale(12));
        make.centerY.equalTo(_btnMiniEntry);
    }];
    [_ivMiniArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_lblMiniAppTitle.mas_trailing).offset(DWScale(6));
        make.centerY.equalTo(_btnMiniEntry);
        make.size.mas_equalTo(CGSizeMake(12, 12));
//        make.mas_equalTo(CGSizeMake(DWScale(12), DWScale(12));
    }];
    
    _viewMyMiniApp = [NoaMyMiniAppView embeddedMiniAppView];
    _viewMyMiniApp.hidden = YES;
    WeakSelf
    _viewMyMiniApp.onEmbeddedDismiss = ^{
        [weakSelf setMiniAppExpanded:NO animated:YES];
    };
    [self addSubview:_viewMyMiniApp];
    [_viewMyMiniApp mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.top.equalTo(_btnMiniEntry.mas_bottom);
        make.height.mas_equalTo(0);
    }];
}

#pragma mark - Avatar Tap
- (void)onAvatarTapped {
    if (self.avatarTapBlock) {
        self.avatarTapBlock();
    }
}
#pragma mark - 界面数据更新
- (void)viewAppearUpdateUI {
    if (!_isHome) {
        return;
    }
    [_ivHeader sd_setImageWithURL:[UserManager.userInfo.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
    _lblUser.text = UserManager.userInfo.nickname;
}

- (void)setShowLoading:(BOOL)showLoading {
    _showLoading = showLoading;
    
    _lblRequestState.hidden = !_showLoading;
}

#pragma mark - 我的应用展开/收起
- (void)btnMiniEntryClick {
    [self setMiniAppExpanded:!_miniAppExpanded animated:YES];
}

- (void)setMiniAppExpanded:(BOOL)expanded animated:(BOOL)animated {
    if (_miniAppExpanded == expanded) {
        return;
    }
    _miniAppExpanded = expanded;
    
    _ivMiniArrow.image = expanded ? ImgNamed(@"c_more_arrow_up") : ImgNamed(@"c_more_arrow_down");
    [_viewMyMiniApp mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(expanded ? kNoaMyMiniAppPanelHeight : 0);
    }];
    _viewMyMiniApp.hidden = !expanded;
    if (expanded) {
        [_viewMyMiniApp myMiniAppShow];
    }
    
    CGFloat height = _isHome ? [NoaSessionTopView preferredHeightForHome:expanded] : [NoaSessionTopView preferredHeightForContact];
    void (^applyLayout)(void) = ^{
        if (self.layoutHeightDidChangeBlock) {
            self.layoutHeightDidChangeBlock(height);
        }
        [self.superview layoutIfNeeded];
    };
    if (animated) {
        [UIView animateWithDuration:0.25 animations:applyLayout];
    } else {
        applyLayout();
    }
}

#pragma mark - 交互事件

#pragma mark - SearchClickAction
- (void)searchViewClickAction {
    if (self.searchBlock) {
        self.searchBlock();
    }
}

- (void)btnAddClick {
    if (_isHome == NO){
        if (self.addBlock) {
            self.addBlock(ZSessionMoreActionTypeCreateGroup);
        }
        return;
    }
    
    [self showMoreView];
    
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.btnAdd.transform = CGAffineTransformMakeRotation(M_PI_4);
    } completion:^(BOOL finished) {}];
    
}
- (void)showMoreView {
    NoaSessionMoreView *viewMore = [NoaSessionMoreView new];
    viewMore.delegate = self;
    [viewMore viewShow];
}
#pragma mark - ZSessionMoreViewDelegate
- (void)moreViewDelegateWithAction:(ZSessionMoreActionType)actionType {
    //直接恢复原状态，交互不好看
    //_btnAdd.transform = CGAffineTransformIdentity;
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.btnAdd.transform = CGAffineTransformMakeRotation(0);
    } completion:^(BOOL finished) {
        if (weakSelf.addBlock && finished) {
            weakSelf.addBlock(actionType);
        }
    }];
    
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
