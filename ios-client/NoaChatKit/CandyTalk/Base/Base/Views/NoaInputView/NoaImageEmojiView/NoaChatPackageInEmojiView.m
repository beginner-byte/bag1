//
//  NoaChatPackageInEmojiView.m
//  NoaKit
//
//  Created by Candy on 2023/8/14.
//

#import "NoaChatPackageInEmojiView.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "NoaChatPackageEmojiItemCell.h"

@interface NoaChatPackageInEmojiView() <UICollectionViewDelegate, UICollectionViewDataSource, DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>

@property (nonatomic, strong) UIButton *leftBtn;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation NoaChatPackageInEmojiView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
        [self setupUI];
        
    }
    return self;
}

- (void)setupUI {
    _leftBtn = [[UIButton alloc] init];
    [_leftBtn setTitle:@"" forState:UIControlStateNormal];
    [_leftBtn setTkThemeTitleColor:@[COLOR_11, COLOR_11_DARK] forState:UIControlStateNormal];
    [_leftBtn setImage:ImgNamed(@"") forState:UIControlStateNormal];
    _leftBtn.titleLabel.font = FONTN(12);
    [_leftBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self addSubview:_leftBtn];
    [_leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(DWScale(14));
        make.leading.equalTo(self).offset(DWScale(16));
        make.width.mas_equalTo(DWScale(120));
        make.height.mas_equalTo(DWScale(20));
    }];
    
    _rightBtn = [[UIButton alloc] init];
    [_rightBtn setTitle:LanguageToolMatch(@"删除") forState:UIControlStateNormal];
    [_rightBtn setTkThemeTitleColor:@[COLOR_99, COLOR_99_DARK] forState:UIControlStateNormal];
    _rightBtn.titleLabel.font = FONTN(12);
    [_rightBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [_rightBtn addTarget:self action:@selector(rightBtnClickAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_rightBtn];
    [_rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_leftBtn);
        make.trailing.equalTo(self).offset(-DWScale(16));
        make.width.mas_equalTo(DWScale(120));
        make.height.mas_equalTo(DWScale(20));
    }];
    
    int itemW = (int)(DScreenWidth - DWScale(6)*2) / 4;
    int itemH = (int)itemW;
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
    _collectionView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    [_collectionView registerClass:[NoaChatPackageEmojiItemCell class] forCellWithReuseIdentifier:NSStringFromClass([NoaChatPackageEmojiItemCell class])];
    [self addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_leftBtn.mas_bottom).offset(DWScale(10));
        make.leading.equalTo(self).offset(DWScale(5));
        make.trailing.equalTo(self).offset(-DWScale(5));
        make.bottom.equalTo(self);
    }];
}

- (void)setStickersList:(NSMutableArray *)stickersList {
    _stickersList = stickersList;
    [_collectionView reloadData];
}

#pragma mark - UICollectionViewDelegate UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.stickersList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NoaChatPackageEmojiItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NoaChatPackageEmojiItemCell class]) forIndexPath:indexPath];
    NoaIMStickersModel *tempModel = (NoaIMStickersModel *)[self.stickersList objectAtIndex:indexPath.row];
    cell.stickerModel = tempModel;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //发送表情包里的某个表情
    NoaIMStickersModel *model = (NoaIMStickersModel *)[self.stickersList objectAtIndex:indexPath.row];
    if (_delegate && [_delegate respondsToSelector:@selector(stickerPackageItemSelected:)]) {
        [_delegate stickerPackageItemSelected:model];
    }
}

#pragma mark - DZNEmptyDataSetSource
//图片距离中心偏移量
- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return 0;
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


#pragma mark - Setter
- (void)setPackageNameStr:(NSString *)packageNameStr {
    _packageNameStr = packageNameStr;
    [_leftBtn setTitle:_packageNameStr forState:UIControlStateNormal];
}

- (void)rightBtnClickAction {
    //删除已添加的表情包
    if (_delegate && [_delegate respondsToSelector:@selector(deleteStickersPackageWithStickersSetId:)]) {
        [_delegate deleteStickersPackageWithStickersSetId:self.stickersId];
    }
}


@end
