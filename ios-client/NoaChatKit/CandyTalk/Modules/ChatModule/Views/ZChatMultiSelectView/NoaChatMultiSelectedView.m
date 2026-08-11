//
//  NoaChatMultiSelectedView.m
//  NoaKit
//
//  Created by Candy on 2023/4/12.
//

#import "NoaChatMultiSelectedView.h"
#import "NoaBaseCollectionView.h"
#import "NoaToolManager.h"

@interface NoaChatMultiSelectedView () <UICollectionViewDataSource,UICollectionViewDelegate,ZBaseCollectionCellDelegate>

@property (nonatomic, strong) UILabel *titleLbl;
@property (nonatomic, strong) UICollectionView *collection;

@end

@implementation NoaChatMultiSelectedView

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
        make.top.equalTo(self).offset(DWScale(16));
        make.width.mas_equalTo(DWScale(100));
        make.height.mas_equalTo(DWScale(18));
    }];
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(DWScale(64), DWScale(68));
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    _collection = [[NoaBaseCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collection.dataSource = self;
    _collection.delegate = self;
    _collection.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    [_collection registerClass:[NoaMultiSelectedHeaderItem class] forCellWithReuseIdentifier:NSStringFromClass([NoaMultiSelectedHeaderItem class])];
    [self addSubview:_collection];
    [_collection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLbl.mas_bottom).offset(DWScale(5));
        make.leading.equalTo(self).offset(DWScale(16));
        make.trailing.bottom.equalTo(self);
    }];
    _collection.delaysContentTouches = NO;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _selectedTopList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NoaMultiSelectedHeaderItem *cell = [_collection dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NoaMultiSelectedHeaderItem class]) forIndexPath:indexPath];
    id model = [_selectedTopList objectAtIndexSafe:indexPath.row];
    cell.model = model;
    
    cell.baseCellDelegate = self;
    cell.baseCellIndexPath = indexPath;
    return cell;
}

#pragma mark - ZBaseCollectionCellDelegate
- (void)baseCellDidSelectedRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - 数据更新
- (void)setSelectedTopList:(NSMutableArray *)selectedTopList {
    _selectedTopList = selectedTopList;
    WeakSelf
    dispatch_async(dispatch_get_main_queue(), ^ {
        [weakSelf.collection reloadData];
    });
}

@end


@implementation NoaMultiSelectedHeaderItem

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
//    [self.contentView addSubview:self.baseContentButton];
//    self.baseContentButton.frame = CGRectMake(0, 0, DScreenWidth / 5.0, DWScale(73));
    
    _ivHeader = [NoaBaseImageView new];
    _ivHeader.layer.cornerRadius = DWScale(22);
    _ivHeader.layer.masksToBounds = YES;
    [self.contentView addSubview:_ivHeader];
    [_ivHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(DWScale(5));
        make.size.mas_equalTo(CGSizeMake(DWScale(44), DWScale(44)));
    }];
    
    _ivRoleName = [UILabel new];
    _ivRoleName.text = @"";
    _ivRoleName.tkThemetextColors = @[COLORWHITE, COLORWHITE];
    _ivRoleName.font = FONTN(7);
    _ivRoleName.tkThemebackgroundColors = @[COLOR_EAB243, COLOR_EAB243_DARK];
    _ivRoleName.textAlignment = NSTextAlignmentCenter;
    [_ivRoleName rounded:DWScale(15.4)/2];
    _ivRoleName.hidden = YES;
    [self.contentView addSubview:_ivRoleName];
    [_ivRoleName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_ivHeader).offset(-DWScale(1));
        make.trailing.equalTo(_ivHeader).offset(DWScale(1));
        make.bottom.equalTo(_ivHeader);
        make.height.mas_equalTo(DWScale(15.4));
    }];
    
    _lblName = [UILabel new];
    _lblName.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    _lblName.font = FONTR(12);
    _lblName.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_lblName];
    [_lblName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(_ivHeader.mas_bottom).offset(DWScale(6));
        make.width.mas_equalTo(DScreenWidth / 5.0 - DWScale(10));
    }];
    
    _deleteBtn = [[UIButton alloc] init];
    [_deleteBtn setImage:ImgNamed(@"c_delete_blue_icon") forState:UIControlStateNormal];
    [_deleteBtn addTarget:self action:@selector(deleteSelectedClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_deleteBtn];
    [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_ivHeader.mas_top).offset(-DWScale(3));
        make.trailing.equalTo(_ivHeader.mas_trailing).offset(DWScale(3));
        make.width.mas_equalTo(DWScale(18));
        make.height.mas_equalTo(DWScale(18));
    }];
    
}
#pragma mark - 数据赋值
- (void)setModel:(id)model {
    if (model) {
        _model = model;
        if ([_model isKindOfClass:[LingIMSessionModel class]]) {
            //会话
            NSString *avatarUrl;
            LingIMSessionModel *sessionModel = (LingIMSessionModel *)model;
            if (sessionModel.sessionType == CIMSessionTypeSingle) {
                LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:sessionModel.sessionID];
                avatarUrl = [NSString loadAvatarWithUserStatus:friendModel.disableStatus avatarUri:friendModel.avatar];
                //单聊
                if ([friendModel.friendUserUID isEqualToString:@"100002"]) {
                    _ivHeader.image = ImgNamed(@"session_file_helper_logo");
                } else {
                    [_ivHeader loadAvatarWithUserImgContent:avatarUrl defaultImg:DefaultAvatar];
                }
                _lblName.text = [NSString loadNickNameWithUserStatus:friendModel.disableStatus realNickName:friendModel.showName];
                //角色名称
                if ([friendModel.friendUserUID isEqualToString:@"100002"]) {
                    //文件助手
                    _ivRoleName.hidden = YES;
                } else {
                    NSString *roleName = [UserManager matchUserRoleConfigInfo:friendModel.roleId disableStatus:friendModel.disableStatus];
                    if ([NSString isNil:roleName]) {
                        _ivRoleName.hidden = YES;
                    } else {
                        _ivRoleName.hidden = NO;
                        _ivRoleName.text = roleName;
                    }
                }
            }else {
                //群聊
                avatarUrl = [NSString loadAvatarWithUserStatus:0 avatarUri:sessionModel.sessionAvatar];
                [_ivHeader loadAvatarWithUserImgContent:avatarUrl defaultImg:DefaultGroup];
                _lblName.text = sessionModel.sessionName;
                _ivRoleName.hidden = YES;
            }
        }
        if ([_model isKindOfClass:[LingIMFriendModel class]]) {
            //联系人
            LingIMFriendModel *friendModel = (LingIMFriendModel *)model;
            _lblName.text = friendModel.nickname;
            if ([friendModel.friendUserUID isEqualToString:@"100002"]) {
                _ivHeader.image = ImgNamed(@"session_file_helper_logo");
            } else {
                [_ivHeader sd_setImageWithURL:[friendModel.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
            }
            //角色名称
            if ([friendModel.friendUserUID isEqualToString:@"100002"]) {
                //文件助手
                _ivRoleName.hidden = YES;
            } else {
                
                NSString *roleName = [UserManager matchUserRoleConfigInfo:friendModel.roleId disableStatus:friendModel.disableStatus];
                if ([NSString isNil:roleName]) {
                    _ivRoleName.hidden = YES;
                } else {
                    _ivRoleName.hidden = NO;
                    _ivRoleName.text = roleName;
                }
            }
        }
        if ([_model isKindOfClass:[LingIMGroupModel class]]) {
            //群组
            LingIMGroupModel *groupModel = (LingIMGroupModel *)model;
            _lblName.text = groupModel.groupName;
            [_ivHeader sd_setImageWithURL:[groupModel.groupAvatar getImageFullUrl] placeholderImage:DefaultGroup options:SDWebImageAllowInvalidSSLCertificates];
            _ivRoleName.hidden = YES;
        }
    }
}

#pragma mark - Action
- (void)deleteSelectedClick {
    NSNumber *deleteNum = [NSNumber numberWithInteger:self.baseCellIndexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MultiSelectHeadDeleteActionNotification" object:deleteNum];
}


#pragma mark - life cycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
