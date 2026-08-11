//
//  NoaHistoryChoiceUseredTopView.m
//  NoaKit
//
//  Created by Candy on 2024/8/12.
//

#import "NoaHistoryChoiceUseredTopView.h"
#import "NoaBaseCollectionView.h"

@interface NoaHistoryChoiceUseredTopView () <UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) UILabel *titleLbl;
@property (nonatomic, strong) UICollectionView *collection;

@end

@implementation NoaHistoryChoiceUseredTopView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        [self setupUI];
    }
    return self;
}

#pragma mark - 界面布局
- (void)setupUI {
    _titleLbl = [[UILabel alloc] init];
    _titleLbl.text = LanguageToolMatch(@"已选择");
    _titleLbl.font = FONTB(14);
    _titleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [self addSubview:_titleLbl];
    [_titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(DWScale(16));
        make.top.equalTo(self);
        make.height.mas_equalTo(DWScale(18));
    }];
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(DWScale(56), DWScale(75));
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 10;
    
    _collection = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collection.dataSource = self;
    _collection.delegate = self;
    _collection.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    _collection.showsHorizontalScrollIndicator = NO;
    [_collection registerClass:[NoaHistoryChoiceUseredItem class] forCellWithReuseIdentifier:NSStringFromClass([NoaHistoryChoiceUseredItem class])];
    [self addSubview:_collection];
    [_collection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLbl.mas_bottom);
        make.leading.equalTo(self).offset(DWScale(7));
        make.trailing.bottom.equalTo(self);
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.choicedTopUserList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NoaHistoryChoiceUseredItem *cell = [_collection dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NoaHistoryChoiceUseredItem class]) forIndexPath:indexPath];
    NoaBaseUserModel *model = [self.choicedTopUserList objectAtIndexSafe:indexPath.row];
    cell.model = model;
    cell.baseCellIndexPath = indexPath;
    return cell;
}

#pragma mark - ZBaseCollectionCellDelegate
- (void)baseCellDidSelectedRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - 数据更新
- (void)setChoicedTopUserList:(NSMutableArray *)choicedTopUserList {
    _choicedTopUserList = choicedTopUserList;
    _titleLbl.hidden = !(self.choicedTopUserList.count > 0);
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [self.collection reloadData];
}

@end


@implementation NoaHistoryChoiceUseredItem

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = UIColor.clearColor;
        self.backgroundColor = UIColor.clearColor;
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    _ivHeader = [UIImageView new];
    [_ivHeader rounded:DWScale(22)];
    [self.contentView addSubview:_ivHeader];
    
    _lblName = [UILabel new];
    _lblName.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    _lblName.font = FONTR(12);
    _lblName.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_lblName];
    
    _deleteBtn = [[UIButton alloc] init];
    [_deleteBtn setImage:ImgNamed(@"history_user_delete") forState:UIControlStateNormal];
    [_deleteBtn addTarget:self action:@selector(deleteSelectedClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_deleteBtn];
    
    [_lblName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(DWScale(17));
    }];
    
    [_ivHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.bottom.equalTo(self.lblName.mas_top).offset(-DWScale(6));
        make.size.mas_equalTo(CGSizeMake(DWScale(44), DWScale(44)));
    }];
    
    [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_ivHeader).offset(DWScale(-3));
        make.trailing.equalTo(_ivHeader).offset(DWScale(3));
        make.width.mas_equalTo(DWScale(18));
        make.height.mas_equalTo(DWScale(18));
    }];
}

#pragma mark - 数据赋值
- (void)setModel:(NoaBaseUserModel *)model {
    if (model) {
        _model = model;
        _lblName.text = _model.name;
        [_ivHeader sd_setImageWithURL:[_model.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
    }
}

#pragma mark - Action
- (void)deleteSelectedClick {
    NSNumber *deleteNum = [NSNumber numberWithInteger:self.baseCellIndexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZChatHistoryChoiceUserDeleteActionNotification" object:deleteNum];
}

@end
