//
//  NoaChatEmojiSearchView.m
//  NoaKit
//
//  Created by Candy on 2023/8/14.
//

#import "NoaChatEmojiSearchView.h"
#import "NoaToolManager.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "NoaChatEmojiSearchCell.h"
#import "NoaSearchView.h"
#import "NoaEmojiMenuPopView.h"

@interface NoaChatEmojiSearchView() <UICollectionViewDelegate, UICollectionViewDataSource, DZNEmptyDataSetSource,DZNEmptyDataSetDelegate, ZSearchViewDelegate, UIGestureRecognizerDelegate, ZChatEmojiSearchCellDelegate>

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) NoaSearchView *searchView;
@property (nonatomic, strong) NSMutableArray *searchResultList;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *moreEmojiBtn;
@property (nonatomic, copy) NSString *searchContent;
@property (nonatomic, assign) NSInteger pageNumber;//起始页
@property (nonatomic, strong) MJRefreshBackNormalFooter  *refreshFooter;//上拉加载

@end

@implementation NoaChatEmojiSearchView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.searchContent = @"";
    
    self.frame = CGRectMake(0, 0, DScreenWidth, DScreenHeight);
    self.backgroundColor = [COLOR_00 colorWithAlphaComponent:0.3];
    [CurrentVC.view addSubview:self];
    
    //背景点击手势-隐藏
    UITapGestureRecognizer *dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(emojiSearchViewDismiss)];
    dismissTap.delegate = self;
    [self addGestureRecognizer:dismissTap];
    
    _backView = [[UIView alloc] initWithFrame:CGRectMake(0, DScreenHeight, DScreenWidth, DScreenHeight - DWScale(196))];
    _backView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    [_backView round:DWScale(20) RectCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
    [self addSubview:_backView];

    UILabel *titleLbl = [[UILabel alloc] init];
    titleLbl.text = LanguageToolMatch(@"表情搜索");
    titleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    titleLbl.font = FONTN(16);
    titleLbl.textAlignment = NSTextAlignmentCenter;
    [_backView addSubview:titleLbl];
    [titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_backView).offset(DWScale(16));
        make.leading.mas_equalTo(_backView).offset(DWScale(16));
        make.trailing.mas_equalTo(_backView).offset(-DWScale(16));
        make.width.mas_equalTo(DWScale(100));
    }];
    
    _searchView = [[NoaSearchView alloc] initWithPlaceholder:LanguageToolMatch(@"搜索")];
    _searchView.frame = CGRectMake(0, DWScale(10) + DNavStatusBarH, DScreenWidth, DWScale(38));
    _searchView.showClearBtn = YES;
    _searchView.returnKeyType = UIReturnKeyDefault;
    _searchView.delegate = self;
    [_backView addSubview:_searchView];
    [_searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_backView.mas_left);
        make.right.mas_equalTo(_backView.mas_right);
        make.top.mas_equalTo(titleLbl.mas_bottom).offset(DWScale(9));
        make.height.mas_equalTo(DWScale(38));
    }];
    
    int itemW = (int)(DScreenWidth - DWScale(6)*2) / 4;
    int itemH = (int)itemW + DWScale(26);
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(itemW, itemH);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.emptyDataSetSource = self;
    _collectionView.emptyDataSetDelegate = self;
    _collectionView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    [_collectionView registerClass:[NoaChatEmojiSearchCell class] forCellWithReuseIdentifier:NSStringFromClass([NoaChatEmojiSearchCell class])];
    [_backView addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_searchView.mas_bottom).offset(DWScale(12));
        make.leading.equalTo(_backView).offset(DWScale(6));
        make.trailing.equalTo(_backView).offset(-DWScale(6));
        make.bottom.equalTo(_backView);
    }];
    
    _moreEmojiBtn = [[UIButton alloc] init];
    [_moreEmojiBtn setTitle:LanguageToolMatch(@"更多表情 >") forState:UIControlStateNormal];
    [_moreEmojiBtn setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2] forState:UIControlStateNormal];
    _moreEmojiBtn.titleLabel.font = FONTN(14);
    _moreEmojiBtn.hidden = NO;
    [_moreEmojiBtn addTarget:self action:@selector(moreEmojiClick) forControlEvents:UIControlEventTouchUpInside];
    [_backView addSubview:_moreEmojiBtn];
    [_moreEmojiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_searchView.mas_bottom).offset(DWScale(20));
        make.leading.mas_equalTo(_backView).offset(DWScale(16));
        make.trailing.mas_equalTo(_backView).offset(-DWScale(16));
    }];
}

- (void)emojiSearchViewShow {
    WeakSelf
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.backView.frame = CGRectMake(0, DWScale(196), DScreenWidth, DScreenHeight - DWScale(196));
    }];
}

- (void)emojiSearchViewDismiss {
    WeakSelf
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.backView.frame = CGRectMake(0, DScreenHeight, DScreenWidth, DScreenHeight - DWScale(196));
    } completion:^(BOOL finished) {
        NSArray *subViews = [weakSelf.backView subviews];
        if([subViews count] != 0) {
            [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        [weakSelf.backView removeFromSuperview];
        weakSelf.backView = nil;
        [weakSelf removeFromSuperview];
    }];
}

//上拉加载更多
- (void)footerRefreshData {
    _pageNumber++;
    [self requestFindStickersForSearchContent];
}

#pragma mark - Request
//根据搜索内容返回搜索表情结果
- (void)requestFindStickersForSearchContent {
    if ([NSString isNil:self.searchContent]) {
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:@(_pageNumber) forKey:@"pageNumber"];
    [dict setObjectSafe:@(20) forKey:@"pageSize"];
    [dict setObjectSafe:@((_pageNumber - 1) * 20) forKey:@"pageStart"];
    [dict setObjectSafe:self.searchContent forKey:@"name"];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    WeakSelf
    [IMSDKManager imSdkUserFindStickersForName:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [weakSelf.collectionView.mj_footer endRefreshing];
        
        if ([data isKindOfClass:[NSDictionary class]]) {
            //数据处理
            if (weakSelf.pageNumber == 1) {
                [weakSelf.searchResultList removeAllObjects];
            }
            NSDictionary *dataDict = (NSDictionary *)data;
            NSArray *recordsList = (NSArray *)[dataDict objectForKeySafe:@"records"];
            NSArray *tempStickersList = [NoaIMStickersModel mj_objectArrayWithKeyValuesArray:recordsList];
            [weakSelf.searchResultList addObjectsFromArray:tempStickersList];
                
            //分页处理
            NSInteger totalPage = [[dataDict objectForKeySafe:@"pages"] integerValue];
            if (weakSelf.pageNumber < totalPage) {
                if (!weakSelf.collectionView.mj_footer) {
                    weakSelf.collectionView.mj_footer = weakSelf.refreshFooter;
                }
            } else {
                weakSelf.collectionView.mj_footer = nil;
            }
            [weakSelf.collectionView reloadData];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
        [weakSelf.collectionView.mj_footer endRefreshing];
    }];
}
//添加表情图片到表情收藏
- (void)requestAddStickersToCollectionWithDic:(NSMutableDictionary *)dict {
    WeakSelf
    [IMSDKManager imSdkUserAddStickersToCollectList:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD showMessage:LanguageToolMatch(@"收藏成功")];
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(collectionStickerFromSearchResult)]) {
            [weakSelf.delegate collectionStickerFromSearchResult];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    UIView *touchView = (UIView *)touch.view;
    int itemW = (int)(DScreenWidth - DWScale(6)*2) / 4;
    int itemH = (int)itemW + DWScale(26);
    if (touchView.width == itemW && touchView.height == itemH) {
        return NO;
    }
    return YES;
}

#pragma mark - Action
- (void)moreEmojiClick {
    //更多表情
    [self emojiSearchViewDismiss];
    if (_delegate && [_delegate respondsToSelector:@selector(moreEmojiAction)]) {
        [_delegate moreEmojiAction];
    }
}

#pragma mark - ZChatEmojiSearchCellDelegate
- (void)searchStickerResultLongTapAction:(NSIndexPath *)indexPath {
    NoaChatEmojiSearchCell *longTapCell = (NoaChatEmojiSearchCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    //计算消息的坐标位置,确定菜单弹窗弹出的位置的坐标
    CGRect targetRect = [self.collectionView convertRect:longTapCell.frame toView:CurrentVC.view];
    
    NoaEmojiMenuPopView *menuPopView = [[NoaEmojiMenuPopView alloc] initWithMenuTitle:LanguageToolMatch(@"存表情") targetRect:targetRect];
    [menuPopView ZEmojiMenuShow];
    WeakSelf
    [menuPopView setMenuClickBlock:^(void) {
        NoaIMStickersModel *model = (NoaIMStickersModel *)[self.searchResultList objectAtIndex:indexPath.row];
        //组装接口数据
        NSMutableDictionary *stickersDic = [NSMutableDictionary dictionary];
        [stickersDic setObjectSafe:model.contentUrl forKey:@"contentUrl"];
        [stickersDic setObjectSafe:@(model.height) forKey:@"height"];
        [stickersDic setObjectSafe:@(model.size) forKey:@"size"];
        [stickersDic setObjectSafe:model.stickersId forKey:@"stickersKey"];
        [stickersDic setObjectSafe:model.thumbUrl forKey:@"thumbUrl"];
        [stickersDic setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
        [stickersDic setObjectSafe:@(model.width) forKey:@"width"];
        //调用接口
        [weakSelf requestAddStickersToCollectionWithDic:stickersDic];
    }];
}

#pragma mark - ZSearchViewDelegate
- (void)searchViewTextValueChanged:(NSString *)searchStr {
    self.searchContent = [searchStr trimString];
    if (self.searchContent.length <= 0) {
        [self.searchResultList removeAllObjects];
        [self.collectionView reloadData];
    }
}

- (void)searchViewReturnKeySearch:(NSString *)searchStr {
    [_searchView.tfSearch resignFirstResponder];
    _pageNumber = 1;
    [self requestFindStickersForSearchContent];
}

#pragma mark - UICollectionViewDelegate UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    _moreEmojiBtn.hidden = self.searchResultList.count > 0 ? YES : NO;
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.searchResultList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NoaChatEmojiSearchCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NoaChatEmojiSearchCell class]) forIndexPath:indexPath];
    cell.delegate = self;
    cell.cellIndexPath = indexPath;
    NoaIMStickersModel *model = (NoaIMStickersModel *)[self.searchResultList objectAtIndex:indexPath.row];
    cell.stickersModel = model;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //发送表情包里的某个表情
    [self emojiSearchViewDismiss];
    
    NoaIMStickersModel *model = (NoaIMStickersModel *)[self.searchResultList objectAtIndex:indexPath.row];
    if (_delegate && [_delegate respondsToSelector:@selector(sendSearchStickersForModel:)]) {
        [_delegate sendSearchStickersForModel:model];
    }
}

#pragma mark - DZNEmptyDataSetSource
//图片距离中心偏移量
- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return DWScale(-80);
}

//空态图片
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    if (![NSString isNil:self.searchContent]) {
        return nil;
    } else {
        return ImgNamed(@"emoji_search_no_data");
    }
}

//空态文本
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *desStr;
    if (![NSString isNil:self.searchContent]) {
        desStr = LanguageToolMatch(@"暂无数据");
    } else {
        desStr = LanguageToolMatch(@"请在上方输入搜索词条，找到那个能表达您真情实感的GIF。");
    }
    NSMutableAttributedString *desAttri = [[NSMutableAttributedString alloc] initWithString:desStr];
    [desAttri addAttribute:NSFontAttributeName value:FONTN(12) range:NSMakeRange(0, desStr.length)];
    [desAttri configAttStrLightColor:COLOR_66 darkColor:COLOR_66_DARK range:NSMakeRange(0, desStr.length)];
    return desAttri;
}

- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView {
    return DWScale(30);
}

#pragma mark - DZNEmptyDataSetDelegate
//允许滑动
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}

#pragma mark - Lazy
- (NSMutableArray *)searchResultList {
    if (!_searchResultList) {
        _searchResultList = [[NSMutableArray alloc] init];
    }
    return _searchResultList;
}

@end
