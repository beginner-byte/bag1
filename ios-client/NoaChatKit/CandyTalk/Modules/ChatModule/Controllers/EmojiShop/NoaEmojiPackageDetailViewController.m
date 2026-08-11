//
//  NoaEmojiPackageDetailViewController.m
//  NoaKit
//
//  Created by Candy on 2023/10/25.
//

#import "NoaEmojiPackageDetailViewController.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "NoaEmojiPackageDetailHeaderView.h"
#import "NoaEmojiPackageDetailCell.h"

@interface NoaEmojiPackageDetailViewController () <UICollectionViewDelegate, UICollectionViewDataSource, DZNEmptyDataSetSource,DZNEmptyDataSetDelegate, ZEmojiPackageDetailHeaderViewDelegate>

@property (nonatomic, strong) NSMutableArray *packageStrickerslList;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NoaIMStickersPackageModel *packageDetailModel;

@end

@implementation NoaEmojiPackageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navTitleStr = LanguageToolMatch(@"表情包详情");
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    _packageStrickerslList = [NSMutableArray array];
    [self setupUI];
    [self setupData];
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
    _collectionView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    [self.view addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navView.mas_bottom);
        make.leading.bottom.trailing.equalTo(self.view);
    }];
    
    [_collectionView registerClass:[NoaEmojiPackageDetailHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([NoaEmojiPackageDetailHeaderView class])];
    [_collectionView registerClass:[NoaEmojiPackageDetailCell class] forCellWithReuseIdentifier:NSStringFromClass([NoaEmojiPackageDetailCell class])];
}

- (void)setupData {
    if (![NSString isNil:_stickersSetId]) {
        //通过 表情包ID 查询表情包详情
        [self requestStickersPackageDetailWithStickersSetId];
    } else {
        //通过 表情ID 查询表情包详情
        [self requestGetStickersPackageDetailWithStickersId];
    }
}

#pragma mark - Net Working
//获取表情包表情详情
- (void)requestStickersPackageDetailWithStickersSetId {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:_stickersSetId forKey:@"stickersSetId"];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    WeakSelf
    [IMSDKManager imSdkUserGetStickersPackageDetail:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            //数据处理
            [weakSelf.packageStrickerslList removeAllObjects];
            NSDictionary *dataDict = (NSDictionary *)data;
            weakSelf.packageDetailModel = [NoaIMStickersPackageModel mj_objectWithKeyValues:dataDict];
            
            //表情列表
            NSArray *tempStickersList = [dataDict objectForKeySafe:@"stickersList"];
            NSArray *resultStickersList = [NoaIMStickersModel mj_objectArrayWithKeyValuesArray:tempStickersList];
            
            weakSelf.packageDetailModel.stickersList = resultStickersList;
            [weakSelf.packageStrickerslList addObjectsFromArray:resultStickersList];
            [weakSelf.collectionView reloadData];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

//通过表情ID查询表情包详情
- (void)requestGetStickersPackageDetailWithStickersId {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:_stickersId forKey:@"stickersId"];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    WeakSelf
    [HUD showActivityMessage:@""];
    [IMSDKManager imSdkUserGetPackageFromStickersId:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD hideHUD];
        if ([data isKindOfClass:[NSDictionary class]]) {
            //数据处理
            [weakSelf.packageStrickerslList removeAllObjects];
            NSDictionary *dataDict = (NSDictionary *)data;
            weakSelf.packageDetailModel = [NoaIMStickersPackageModel mj_objectWithKeyValues:dataDict];
            //表情列表
            NSArray *tempStickersList = [dataDict objectForKeySafe:@"stickersList"];
            NSArray *resultStickersList = [NoaIMStickersModel mj_objectArrayWithKeyValuesArray:tempStickersList];
            
            weakSelf.packageDetailModel.stickersList = resultStickersList;
            [weakSelf.packageStrickerslList addObjectsFromArray:resultStickersList];
            [weakSelf.collectionView reloadData];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD hideHUD];
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

//添加表情包
- (void)requestAddStickersPackage {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:_packageDetailModel.packageId forKey:@"stickersSetId"];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    WeakSelf
    [IMSDKManager imSdkUserAddStickersPackage:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        //删除已添加的表情包并刷新tableView
        [HUD showMessage:LanguageToolMatch(@"添加成功")];
        [weakSelf setupData];
        if (weakSelf.packageAddClick) {
            weakSelf.packageAddClick(weakSelf.supIndex);
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
        [weakSelf.collectionView.mj_footer endRefreshing];
        [weakSelf.collectionView.mj_header endRefreshing];
    }];
}

#pragma mark - UICollectionViewDelegate UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _packageStrickerslList.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    return CGSizeMake(DScreenWidth,  DWScale(210) + DWScale(86));
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        NoaEmojiPackageDetailHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([NoaEmojiPackageDetailHeaderView class]) forIndexPath:indexPath];
        headerView.delegate = self;
        headerView.model = _packageDetailModel;
        return headerView;
    }
    return nil;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NoaEmojiPackageDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NoaEmojiPackageDetailCell class]) forIndexPath:indexPath];
    NoaIMStickersModel *tempStrickersModel = (NoaIMStickersModel *)[_packageStrickerslList objectAtIndex:indexPath.row];
    cell.model = tempStrickersModel;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - ZEmojiPackageDetailHeaderViewDelegate
- (void)addStrickersPackageAction {
    [self requestAddStickersPackage];
}

#pragma mark - DZNEmptyDataSetSource
//图片距离中心偏移量
- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return DWScale(100);
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

@end
