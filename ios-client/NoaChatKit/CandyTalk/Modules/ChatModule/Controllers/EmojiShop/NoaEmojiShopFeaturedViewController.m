//
//  NoaEmojiShopFeaturedViewController.m
//  NoaKit
//
//  Created by Candy on 2023/10/25.
//

#import "NoaEmojiShopFeaturedViewController.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "NoaEmojiShopFeaturedHeaderView.h"
#import "NoaEmojiShopFeaturedCell.h"
#import "NoaEmojiMenuPopView.h"

@interface NoaEmojiShopFeaturedViewController () <UICollectionViewDelegate, UICollectionViewDataSource, DZNEmptyDataSetSource,DZNEmptyDataSetDelegate, ZEmojiShopFeaturedCellDelegate>

@property (nonatomic, strong) NSMutableArray *featuredStickersList;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger pageNumber;//起始页

@end

@implementation NoaEmojiShopFeaturedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    self.navView.hidden = YES;
    [self setupUI];
    _pageNumber = 1;
    [self requestFindStickersForName];
}

- (void)setupUI {
    int itemW = (int)(DScreenWidth - DWScale(6)*2) / 4;
    int itemH = (int)itemW + DWScale(6) + DWScale(20);
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(itemW, itemH);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.showsHorizontalScrollIndicator = YES;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.emptyDataSetSource = self;
    _collectionView.emptyDataSetDelegate = self;
    _collectionView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    _collectionView.mj_header = self.refreshHeader;
    _collectionView.mj_footer = self.refreshFooter;
    [self.view addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [_collectionView registerClass:[NoaEmojiShopFeaturedHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([NoaEmojiShopFeaturedHeaderView class])];
    [_collectionView registerClass:[NoaEmojiShopFeaturedCell class] forCellWithReuseIdentifier:NSStringFromClass([NoaEmojiShopFeaturedCell class])];
}

- (void)headerRefreshData {
    _pageNumber = 1;
    [self requestFindStickersForName];
}
- (void)footerRefreshData {
    _pageNumber++;
    [self requestFindStickersForName];
}

#pragma mark - Request
//根据表情名称获取表情列表
- (void)requestFindStickersForName {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:@(_pageNumber) forKey:@"pageNumber"];
    [dict setObjectSafe:@(20) forKey:@"pageSize"];
    [dict setObjectSafe:@((_pageNumber - 1) * 20) forKey:@"pageStart"];
    [dict setObjectSafe:@"" forKey:@"name"];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    WeakSelf
    [IMSDKManager imSdkUserFindStickersForName:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [weakSelf.collectionView.mj_footer endRefreshing];
        [weakSelf.collectionView.mj_header endRefreshing];
        
        if ([data isKindOfClass:[NSDictionary class]]) {
            //数据处理
            if (weakSelf.pageNumber == 1) {
                [weakSelf.featuredStickersList removeAllObjects];
            }
            NSDictionary *dataDict = (NSDictionary *)data;
            NSArray *recordsList = (NSArray *)[dataDict objectForKeySafe:@"records"];
            NSArray *tempStickersList = [NoaIMStickersModel mj_objectArrayWithKeyValuesArray:recordsList];
            [weakSelf.featuredStickersList addObjectsFromArray:tempStickersList];
                
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
        [weakSelf.collectionView.mj_header endRefreshing];
    }];
}

//添加表情收藏
- (void)requestAddAStickersToCollectWithModel:(NoaIMStickersModel *)strickersModel {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:strickersModel.contentUrl forKey:@"contentUrl"];
    [dict setObjectSafe:@(strickersModel.height) forKey:@"height"];
    [dict setObjectSafe:@(strickersModel.width) forKey:@"width"];
    [dict setObjectSafe:@(strickersModel.size) forKey:@"size"];
    [dict setObjectSafe:strickersModel.stickersId forKey:@"stickersKey"];
    [dict setObjectSafe:strickersModel.thumbUrl forKey:@"thumbUrl"];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    
    [IMSDKManager imSdkUserAddStickersToCollectList:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD showMessage:LanguageToolMatch(@"收藏成功")];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

#pragma mark - UICollectionViewDelegate UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.featuredStickersList.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    return CGSizeMake(DScreenWidth, DWScale(47));
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        NoaEmojiShopFeaturedHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([NoaEmojiShopFeaturedHeaderView class]) forIndexPath:indexPath];
        return headerView;
    }
    return nil;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NoaEmojiShopFeaturedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NoaEmojiShopFeaturedCell class]) forIndexPath:indexPath];
    cell.cellIndexPath = indexPath;
    cell.delegate = self;
    NoaIMStickersModel *tempStickersModel = (NoaIMStickersModel *)[self.featuredStickersList objectAtIndex:indexPath.row];
    cell.model = tempStickersModel;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - ZEmojiPackageDetailCellDelegate
- (void)shopFeaturedStickerLongTapAction:(NSIndexPath *)indexPath {
    NoaEmojiShopFeaturedCell *longTapCell = (NoaEmojiShopFeaturedCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    //计算消息的坐标位置,确定菜单弹窗弹出的位置的坐标
    CGRect targetRect = [self.collectionView convertRect:longTapCell.frame toView:CurrentVC.view];
    
    WeakSelf
    NoaEmojiMenuPopView *menuPopView = [[NoaEmojiMenuPopView alloc] initWithMenuTitle:LanguageToolMatch(@"存表情") targetRect:targetRect];
    [menuPopView ZEmojiMenuShow];
    [menuPopView setMenuClickBlock:^(void) {
        NoaIMStickersModel *addStickersModel = (NoaIMStickersModel *)[self.featuredStickersList objectAtIndex:indexPath.row];
        [weakSelf requestAddAStickersToCollectWithModel:addStickersModel];
    }];
}

#pragma mark - DZNEmptyDataSetSource
//图片距离中心偏移量
- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return DWScale(-120);
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

#pragma mark - Lazy
- (NSMutableArray *)featuredStickersList {
    if (!_featuredStickersList) {
        _featuredStickersList = [[NSMutableArray alloc] init];
    }
    return _featuredStickersList;
}

@end
