//
//  NoaMyMiniAppView.m
//  NoaKit
//
//  Created by Candy on 2023/7/18.
//

#import "NoaMyMiniAppView.h"
#import "NoaToolManager.h"
#import "NoaBaseCollectionView.h"
#import "NoaMyMiniAppItem.h"
#import <MJRefresh/MJRefresh.h>

#import "NoaMiniAppPasswordView.h"
#import "NoaConfigMiniAppView.h"
#import "NoaMiniAppWebVC.h"
#import "NoaMiniAppDeleteTipView.h"

const CGFloat kNoaMyMiniAppPanelHeight = 189.0;

@interface NoaMyMiniAppView () <UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ZBaseCollectionCellDelegate, ZMyMiniAppItemDelete, ZConfigMiniAppViewDelegate>

@property (nonatomic, assign) BOOL embeddedMode;

/// 内容视图
@property (nonatomic, strong) UIView *viewContent;

/// 阴影容器
@property (nonatomic, strong) UIView *shadowContainer;

/// 标题
@property (nonatomic, strong) UILabel *titleLabel;

/// 管理按钮
@property (nonatomic, strong) UIButton *managerBtn;

/// 连接内容展示
@property (nonatomic, strong) NoaBaseCollectionView *collection;

/// 连接数据
@property (nonatomic, strong) NSMutableArray *miniAppList;

/// 当前页数
@property (nonatomic, assign) NSInteger pageNumber;

@end

@implementation NoaMyMiniAppView

// MARK: dealloc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// MARK: get/set

- (NSMutableArray *)miniAppList {
    if (!_miniAppList) {
        _miniAppList = [NSMutableArray new];
    }
    return _miniAppList;
}

- (UIView *)shadowContainer {
    if (!_shadowContainer) {
        // 创建容器视图用于阴影
        _shadowContainer = [[UIView alloc] initWithFrame:CGRectZero];
        _shadowContainer.tkThemebackgroundColors = @[[UIColor clearColor], [UIColor clearColor]];
        _shadowContainer.layer.masksToBounds = NO;
        
        // 设置模糊
        _shadowContainer.layer.shadowColor = [UIColor blackColor].CGColor;
        _shadowContainer.layer.shadowOpacity = 0.1;
        _shadowContainer.layer.shadowRadius = 8; // 模糊半径 8px
        _shadowContainer.layer.shadowOffset = CGSizeMake(0, 4); // y偏移 4px，向下偏移
    }
    return _shadowContainer;
}

- (UIView *)viewContent {
    if (!_viewContent) {
        _viewContent = [[UIView alloc] initWithFrame:CGRectZero];
        _viewContent.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
        _viewContent.layer.masksToBounds = YES;
    }
    return _viewContent;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.text = LanguageToolMatch(@"我的应用");
        // 普通模式：深色文字（COLOR_00 黑色），暗黑模式：白色文字
        _titleLabel.tkThemetextColors = @[COLOR_00, COLORWHITE];
        _titleLabel.font = FONTR(16);
        _titleLabel.textAlignment =  NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIButton *)managerBtn {
    if (!_managerBtn) {
        _managerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_managerBtn setTitle:LanguageToolMatch(@"管理") forState:UIControlStateNormal];
        [_managerBtn setTitle:LanguageToolMatch(@"完成") forState:UIControlStateSelected];
        // 普通模式：深色文字（COLOR_00 黑色），暗黑模式：白色文字
        [_managerBtn setTkThemeTitleColor:@[COLOR_00, COLORWHITE] forState:UIControlStateNormal];
        _managerBtn.titleLabel.font = FONTR(14);
        _managerBtn.titleEdgeInsets = UIEdgeInsetsMake(3, 10, 3, 10);
    }
    return _managerBtn;
}

- (NoaBaseCollectionView *)collection {
    if (!_collection) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collection = [[NoaBaseCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collection.delaysContentTouches = NO;
        _collection.dataSource = self;
        _collection.delegate = self;
        _collection.tkThemebackgroundColors = @[COLOR_CLEAR, COLOR_CLEAR];
        _collection.showsVerticalScrollIndicator = NO;
        [_collection registerClass:[NoaMyMiniAppItem class] forCellWithReuseIdentifier:NSStringFromClass([NoaMyMiniAppItem class])];
    }
    return _collection;
}

+ (instancetype)embeddedMiniAppView {
    return [[self alloc] initWithFrame:CGRectZero embedded:YES];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame embedded:NO];
}

- (instancetype)initWithFrame:(CGRect)frame embedded:(BOOL)embedded {
    self = [super initWithFrame:frame];
    if (self) {
        _embeddedMode = embedded;
        self.tkThemebackgroundColors = @[COLOR_CLEAR, COLOR_CLEAR_DARK];
        
        if (!embedded) {
            self.frame = CGRectMake(0, 0, DScreenWidth, DScreenHeight);
            [CurrentWindow addSubview:self];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myMiniAppDismiss)];
            tap.delegate = self;
            [self addGestureRecognizer:tap];
        }
        
        self.pageNumber = 1;
        [self setupUI];
        [self requestMyMiniAppList];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(miniAppViewShow:) name:@"MiniAppSelectImage" object:nil];
    }
    return self;
}

#pragma mark - 通知监听
- (void)miniAppViewShow:(NSNotification *)notification {
    NSDictionary *userInfoDict = notification.userInfo;
    BOOL showMiniView = [[userInfoDict objectForKeySafe:@"OpenImagePicker"] boolValue];
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.hidden = showMiniView;
    });
}

#pragma mark - 界面布局
- (void)setupUI {
    [self addSubview:self.shadowContainer];
    [self.shadowContainer addSubview:self.viewContent];
    if (_embeddedMode) {
        [self.shadowContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    } else {
        [self.shadowContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(-kNoaMyMiniAppPanelHeight);
            make.leading.trailing.equalTo(self);
            make.height.equalTo(@(kNoaMyMiniAppPanelHeight));
        }];
    }
    
    [self.viewContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.bottom.equalTo(self.shadowContainer);
    }];
    
    UIBlurEffect *effectBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *viewEffect = [[UIVisualEffectView alloc] initWithEffect:effectBlur];
    viewEffect.alpha = 0.6;
    viewEffect.userInteractionEnabled = NO;
    [self.viewContent addSubview:viewEffect];
    [viewEffect mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.bottom.equalTo(self.viewContent);
    }];
    
    [self.viewContent addSubview:self.titleLabel];
    self.titleLabel.hidden = _embeddedMode;
    [self.viewContent addSubview:self.managerBtn];
    [self.viewContent addSubview:self.collection];
    
    if (_embeddedMode) {
        [self.managerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.viewContent).offset(DWScale(8));
            make.trailing.equalTo(self.viewContent).offset(-DWScale(12));
            make.width.greaterThanOrEqualTo(@50);
            make.height.equalTo(@20);
        }];
        [self.collection mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.managerBtn.mas_bottom).offset(DWScale(8));
            make.leading.equalTo(self.viewContent);
            make.trailing.equalTo(self.viewContent).offset(-DWScale(10));
            make.bottom.equalTo(self.viewContent);
        }];
    } else {
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.viewContent);
            make.top.equalTo(self.viewContent).offset(52.5);
            make.width.equalTo(self.viewContent).offset(-100);
            make.height.equalTo(@19);
        }];
        [self.managerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleLabel);
            make.trailing.equalTo(self.viewContent);
            make.width.greaterThanOrEqualTo(@50);
            make.height.equalTo(@20);
        }];
        [self.collection mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(14.5);
            make.leading.equalTo(self.viewContent);
            make.trailing.equalTo(self.viewContent).offset(-DWScale(10));
            make.bottom.equalTo(self.viewContent);
        }];
    }
    
    @weakify(self)
    [[self.managerBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        [self btnManagerClick];
    }];
    
    MJRefreshBackNormalFooter *refreshFooter = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        self.pageNumber++;
        [self requestMyMiniAppList];
    }];
    self.collection.mj_footer = refreshFooter;
}

- (void)updateShadowPathForContainer:(UIView *)container {
    if (!container) {
        return;
    }
    // 设置阴影路径，确保与圆角匹配
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:container.bounds
                                                      byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                            cornerRadii:CGSizeMake(24, 24)];
    container.layer.shadowPath = shadowPath.CGPath;
}

- (void)myMiniAppShow {
    if (_embeddedMode) {
        self.hidden = NO;
        return;
    }
    [self layoutIfNeeded];
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        [self.shadowContainer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
        }];
        [self layoutIfNeeded];
    } completion:nil];
}

- (void)myMiniAppDismiss {
    if (_embeddedMode) {
        if (self.onEmbeddedDismiss) {
            self.onEmbeddedDismiss();
        }
        return;
    }
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        if (self.shadowContainer) {
            [self.shadowContainer mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self).offset(-kNoaMyMiniAppPanelHeight);
            }];
            [self layoutIfNeeded];
        }
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!CGRectIsEmpty(self.shadowContainer.frame)) {
        [self updateShadowPathForContainer:self.shadowContainer];
    }
    
    if (!CGRectIsEmpty(self.viewContent.frame)) {
        [self.viewContent round:24 RectCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.miniAppList.count + 1; // 默认无数据展示添加，有数据最后展示添加
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NoaMyMiniAppItem *cell = [_collection dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NoaMyMiniAppItem class]) forIndexPath:indexPath];
    LingIMMiniAppModel *model;
    if (indexPath.row < _miniAppList.count) {
        model = [_miniAppList objectAtIndexSafe:indexPath.row];
    }
    [cell configItemWith:model manage:_managerBtn.isSelected];
    cell.baseCellDelegate = self;
    cell.baseCellIndexPath = indexPath;
    cell.delegate = self;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = DScreenWidth / 6.0; // 一行展示6个
    CGFloat height = width / 0.9;
    return CGSizeMake(width, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self baseCellDidSelectedRowAtIndexPath:indexPath];
}

#pragma mark - ZBaseCollectionCellDelegate
- (void)baseCellDidSelectedRowAtIndexPath:(NSIndexPath *)indexPath {
    
    __block LingIMMiniAppModel *model = [_miniAppList objectAtIndexSafe:indexPath.row];
    if (model) {
        if (model.qaPwdOpen) {
            //开启了密码验证
            NoaMiniAppPasswordView *viewPassword = [NoaMiniAppPasswordView new];
            viewPassword.miniAppModel = model;
            [viewPassword miniAppPasswordShow];
            @weakify(self)
            viewPassword.sureBtnBlock = ^{
                @strongify(self)
                [self viewOrManageMyMiniAppWith:model];
            };
        }else {
            [self viewOrManageMyMiniAppWith:model];
        }
    } else {
        //新增小程序
        NoaConfigMiniAppView *viewConfig = [[NoaConfigMiniAppView alloc] initMiniAppWith:ZConfigMiniAppTypeAdd];
        viewConfig.delegate = self;
        [viewConfig configMiniAppShow];
        if (_managerBtn.isSelected) {
            _managerBtn.selected = NO;
            [_collection reloadData];
        }
    }
}
//查看或管理小程序
- (void)viewOrManageMyMiniAppWith:(LingIMMiniAppModel *)miniAppModel {
    if (_managerBtn.isSelected) {
        //管理小程序
        if(miniAppModel.appType == 0){
            return;
        }
        NoaConfigMiniAppView *viewConfig = [[NoaConfigMiniAppView alloc] initMiniAppWith:ZConfigMiniAppTypeEdit];
        viewConfig.miniAppModel = miniAppModel;
        viewConfig.delegate = self;
        [viewConfig configMiniAppShow];
    }else {
        //跳转小程序
        [self myMiniAppDismiss];
        
        NoaFloatMiniAppModel * floadModel = [[NoaFloatMiniAppModel alloc] init];
        floadModel.url = miniAppModel.qaAppUrl;
        floadModel.floladId = miniAppModel.qaUuid;
        floadModel.title = miniAppModel.qaName;
        floadModel.headerUrl = miniAppModel.qaAppPic;
        
        NoaMiniAppWebVC *vc = [[NoaMiniAppWebVC alloc] init];
        vc.webViewUrl = miniAppModel.qaAppUrl;
        vc.webType = ZMiniAppWebVCTypeMiniApp;
        vc.floatMiniAppModel = floadModel;

        [CurrentVC.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - ZMyMiniAppItemDelete
- (void)myMiniAppDelete:(NSIndexPath *)indexPath {
    
    LingIMMiniAppModel *miniAppModel = [_miniAppList objectAtIndexSafe:indexPath.row];
    if (miniAppModel) {
        WeakSelf
        NoaMiniAppDeleteTipView *viewTip = [NoaMiniAppDeleteTipView new];
        [viewTip tipViewSHow];
        viewTip.sureBtnBlock = ^{
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObjectSafe:miniAppModel.qaUuid forKey:@"qaUuid"];
            [dict setObjectSafe:@(miniAppModel.appType) forKey:@"appType"];
            [IMSDKManager imMiniAppDeleteWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                [weakSelf.miniAppList removeObjectAtIndexSafe:indexPath.row];
                [weakSelf.collection reloadData];
                [HUD showMessage:LanguageToolMatch(@"删除成功")];
            } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                [HUD showMessageWithCode:code errorMsg:msg];
            }];
        };
        
    }
    
}
#pragma mark - ZConfigMiniAppViewDelegate
- (void)configMiniAppCreateWith:(LingIMMiniAppModel *)miniApp {
    [_miniAppList addObjectIfNotNil:miniApp];
    [_collection reloadData];
}
- (void)configMiniAppEditWith:(LingIMMiniAppModel *)miniApp {
    [_collection reloadData];
}
#pragma mark - 交互事件
- (void)btnManagerClick {
    _managerBtn.selected = !_managerBtn.selected;
    [_collection reloadData];
}

#pragma mark - 数据请求
- (void)requestMyMiniAppList {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    [dict setObjectSafe:@(_pageNumber) forKey:@"pageNumber"];
    [dict setObjectSafe:@(50) forKey:@"pageSize"];
    [dict setObjectSafe:@((_pageNumber - 1) * 50) forKey:@"pageStart"];
    
    @weakify(self)
    [IMSDKManager imMiniAppListWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        @strongify(self)
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDict = data;
            if (self.pageNumber == 1) {
                [self.miniAppList removeAllObjects];
            }
            //小程序列表
            NSArray *miniAppArr = [dataDict objectForKeySafe:@"items"];
            if (miniAppArr) {
                [miniAppArr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    LingIMMiniAppModel *model = [LingIMMiniAppModel mj_objectWithKeyValues:obj];
                    [self.miniAppList addObjectIfNotNil:model];
                }];
            }
            [self.collection reloadData];
            
            // 结束刷新
            [self.collection.mj_footer endRefreshing];
            
            //数据是否加载完毕
            NSInteger totalPage = [[dataDict objectForKeySafe:@"pages"] integerValue];
            if (self.pageNumber >= totalPage) {
                // 没有更多数据
                [self.collection.mj_footer endRefreshingWithNoMoreData];
            }
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        // 请求失败恢复pageNumber，但同时要保证最小为1
        self.pageNumber -= 1;
        self.pageNumber = MAX(1, self.pageNumber);
        // 结束刷新
        [self.collection.mj_footer endRefreshing];
        
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {

    // 避免和 CollectionView Cell 冲突
    if ([touch.view isDescendantOfView:self.collection]) {
        return NO;
    }
    return YES;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
