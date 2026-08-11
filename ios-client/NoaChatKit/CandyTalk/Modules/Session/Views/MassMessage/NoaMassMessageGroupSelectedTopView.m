//
//  NoaMassMessageGroupSelectedTopView.m
//  NoaKit
//
//  Created by Candy on 2023/9/4.
//

#import "NoaMassMessageGroupSelectedTopView.h"
#import "NoaBaseCollectionView.h"

@interface NoaMassMessageGroupSelectedTopView () <UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) UILabel *titleLbl;
@property (nonatomic, strong) UICollectionView *collection;

@end

@implementation NoaMassMessageGroupSelectedTopView

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
    [_collection registerClass:[NoaMassMessageGroupSelectItem class] forCellWithReuseIdentifier:NSStringFromClass([NoaMassMessageGroupSelectItem class])];
    [self addSubview:_collection];
    [_collection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLbl.mas_bottom);
        make.leading.equalTo(self).offset(DWScale(7));
        make.trailing.bottom.equalTo(self);
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _selectedTopUserList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NoaMassMessageGroupSelectItem *cell = [_collection dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NoaMassMessageGroupSelectItem class]) forIndexPath:indexPath];
    NoaBaseUserModel *model = [_selectedTopUserList objectAtIndexSafe:indexPath.row];
    cell.model = model;
    cell.baseCellIndexPath = indexPath;
    return cell;
}

#pragma mark - ZBaseCollectionCellDelegate
- (void)baseCellDidSelectedRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - 数据更新
- (void)setSelectedTopUserList:(NSMutableArray *)selectedTopUserList {
    _selectedTopUserList = selectedTopUserList;
    _titleLbl.hidden = !(selectedTopUserList.count > 0);
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [self.collection reloadData];
}

@end


@implementation NoaMassMessageGroupSelectItem

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
    _ivHeader = [NoaBaseImageView new];
    _ivHeader.layer.cornerRadius = DWScale(19);
    _ivHeader.layer.masksToBounds = YES;
    [self.contentView addSubview:_ivHeader];
    
    _ivRoleName = [UILabel new];
    _ivRoleName.text = @"";
    _ivRoleName.tkThemetextColors = @[COLORWHITE, COLORWHITE];
    _ivRoleName.font = FONTN(6);
    _ivRoleName.tkThemebackgroundColors = @[COLOR_EAB243, COLOR_EAB243_DARK];
    _ivRoleName.textAlignment = NSTextAlignmentCenter;
    [_ivRoleName rounded:DWScale(14)/2];
    _ivRoleName.hidden = YES;
    [self.contentView addSubview:_ivRoleName];
    
    _lblName = [UILabel new];
    _lblName.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    _lblName.font = FONTR(12);
    _lblName.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_lblName];
    
    _deleteBtn = [[UIButton alloc] init];
    [_deleteBtn setImage:ImgNamed(@"c_delete_blue_icon") forState:UIControlStateNormal];
    [_deleteBtn addTarget:self action:@selector(deleteSelectedClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_deleteBtn];
    
    
    [_lblName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(DWScale(14));
    }];
    
    [_ivHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.bottom.equalTo(self.lblName.mas_top).offset(-DWScale(8));
        make.size.mas_equalTo(CGSizeMake(DWScale(38), DWScale(38)));
    }];
    
    [_ivRoleName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_ivHeader).offset(-DWScale(2));
        make.trailing.equalTo(_ivHeader).offset(DWScale(2));
        make.bottom.equalTo(_ivHeader).offset(DWScale(2));
        make.height.mas_equalTo(DWScale(14));
    }];

    

    [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.equalTo(_ivHeader);
        make.width.mas_equalTo(DWScale(12));
        make.height.mas_equalTo(DWScale(12));
    }];
}

#pragma mark - 数据赋值
- (void)setModel:(NoaBaseUserModel *)model {
    if (model) {
        _model = model;
        _lblName.text = _model.name;
        [_ivHeader sd_setImageWithURL:[_model.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
        //角色名称
        NSString *roleName = [UserManager matchUserRoleConfigInfo:_model.roleId disableStatus:_model.disableStatus];
        if ([NSString isNil:roleName]) {
            _ivRoleName.hidden = YES;
        } else {
            _ivRoleName.hidden = NO;
            _ivRoleName.text = roleName;
        }
    }
}

#pragma mark - Action
- (void)deleteSelectedClick {
    NSNumber *deleteNum = [NSNumber numberWithInteger:self.baseCellIndexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZMassMessageSelectedGroupDeleteActionNotification" object:deleteNum];
}

@end
