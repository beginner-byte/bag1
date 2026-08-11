//
//  NoaTeamHomeHeaderView.m
//  NoaKit
//
//  Created by Candy on 2023/9/7.
//

#import "NoaTeamHomeHeaderView.h"
#import "NoaTeamHeaderCollectCell.h"

@interface NoaTeamHomeHeaderView () <UICollectionViewDataSource, UICollectionViewDelegate, ZTeamHeaderCollectCellDelegate>

@property (nonatomic, strong) UIImageView *teamListTipImg;
@property (nonatomic, strong) UILabel *teamListTitleLbl;
@property (nonatomic, strong) UIImageView *teamListArrowImg;
@property (nonatomic, strong) UICollectionView *teamListCollection;
@property (nonatomic, strong) UIButton *teamListBtn;

@end

@implementation NoaTeamHomeHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    //团队列表-标题
    _teamListTipImg = [UIImageView new];
    _teamListTipImg.image = ImgNamed(@"img_team_tip");
    [self addSubview:_teamListTipImg];
    [_teamListTipImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(DWScale(16));
        make.top.equalTo(self).offset(DWScale(10));
        make.size.mas_equalTo(CGSizeMake(DWScale(22), DWScale(22)));
    }];
    
    _teamListArrowImg = [UIImageView new];
    _teamListArrowImg.image = ImgNamed(@"team_arrow_gray");
    [self addSubview:_teamListArrowImg];
    [_teamListArrowImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-DWScale(16));
        make.centerY.equalTo(_teamListTipImg);
        make.size.mas_equalTo(CGSizeMake(DWScale(12), DWScale(12)));
    }];
    
    _teamListTitleLbl = [UILabel new];
    _teamListTitleLbl.text = LanguageToolMatch(@"团队列表");
    _teamListTitleLbl.font = FONTR(14);
    _teamListTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [self addSubview:_teamListTitleLbl];
    [_teamListTitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_teamListTipImg);
        make.leading.equalTo(_teamListTipImg.mas_trailing).offset(DWScale(10));
        make.trailing.equalTo(_teamListArrowImg.mas_leading).offset(-DWScale(16));
        make.height.mas_equalTo(DWScale(22));
    }];
    
    _teamListBtn = [UIButton new];
    _teamListBtn.backgroundColor = COLOR_CLEAR;
    [_teamListBtn addTarget:self action:@selector(teamListClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_teamListBtn];
    [_teamListBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(DWScale(10));
        make.leading.trailing.equalTo(self);
        make.height.mas_equalTo(DWScale(35));
    }];
    
    //团队列表-collectionView
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(DWScale(184), DWScale(93));
    layout.minimumLineSpacing = DWScale(10);
    layout.minimumInteritemSpacing = 0;
    
    _teamListCollection = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _teamListCollection.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    _teamListCollection.showsHorizontalScrollIndicator = NO;
    _teamListCollection.delegate = self;
    _teamListCollection.dataSource = self;
    [_teamListCollection registerClass:[NoaTeamHeaderCollectCell class] forCellWithReuseIdentifier:NSStringFromClass([NoaTeamHeaderCollectCell class])];
    _teamListCollection.showsVerticalScrollIndicator = NO;
    [self addSubview:_teamListCollection];
    [_teamListCollection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(DWScale(16));
        make.trailing.equalTo(self).offset(-DWScale(16));
        make.top.equalTo(_teamListTipImg.mas_bottom).offset(DWScale(15));
        make.height.mas_equalTo(DWScale(93));
    }];
}

#pragma mark - 界面赋值
- (void)setHeaderTeamList:(NSArray *)headerTeamList {
    if(_headerTeamList == nil){
        WeakSelf
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf scrollPositionBottom];
        });
    }
    _headerTeamList = headerTeamList;
    [self scrollPositionBottom];
    
}
#pragma mark  - 滑到最底部
- (void)scrollPositionBottom{
    [self.teamListCollection reloadData];
    [self.teamListCollection layoutIfNeeded];
    NSInteger section = [self.teamListCollection numberOfSections];  //有多少组
    if (section<1) return;  //无数据时不执行 要不会crash
    NSInteger row = [self.teamListCollection numberOfItemsInSection:section-1]; //最后一组有多少行
    if (row<1) return;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section-1];  //取最后一行数据
    if(ZLanguageTOOL.isRTL){
        [self.teamListCollection scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionRight animated:YES];//滚动到最后一行
    }else{
        [self.teamListCollection scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];//滚动到最后一行
    }
    
}


#pragma mark - UICollectionViewDelegate
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _headerTeamList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NoaTeamHeaderCollectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NoaTeamHeaderCollectCell class]) forIndexPath:indexPath];
    NoaTeamModel *model = [_headerTeamList objectAtIndexSafe:indexPath.row];
    cell.teamModel = model;
    cell.delegate = self;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NoaTeamModel *model = [_headerTeamList objectAtIndexSafe:indexPath.row];
    if (_delegate && [_delegate respondsToSelector:@selector(headerTeamItemAction:)]) {
        [_delegate headerTeamItemAction:model];
    }
}

#pragma mark - ZTeamHeaderCollectCellDelegate
- (void)selectedTeamForDefaultAction:(NoaTeamModel *)teamModel {
   //设置为默认
    if (_delegate && [_delegate respondsToSelector:@selector(headerSetDefaultTeamAction:)]) {
        [_delegate headerSetDefaultTeamAction:teamModel];
    }
}

#pragma mark - Action
- (void)teamListClick {
    //团队列表-点击
    if (_delegate && [_delegate respondsToSelector:@selector(headerTeamListTitleAction)]) {
        [_delegate headerTeamListTitleAction];
    }
}

@end
