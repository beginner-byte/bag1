//
//  NoaChatSetGroupInfoCell.m
//  NoaKit
//
//  Created by Candy on 2026/11/5.
//

#import "NoaChatSetGroupInfoCell.h"
#import "NoaBaseImageView.h"
#import "NoaGroupMemberHeaderCell.h"

@interface NoaChatSetGroupInfoCell () <UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, strong) NoaBaseImageView *ivGroup;
@property (nonatomic, strong) UILabel *lblGroupName;

@property (nonatomic, strong) UILabel *lblMemberCount;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *memberList;
@property (nonatomic, strong) UIImageView *ivArrowTop;

@end

@implementation NoaChatSetGroupInfoCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = UIColor.clearColor;
        self.backgroundColor = UIColor.clearColor;
        _memberList = [NSMutableArray array];
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    UIView *viewBg = [[UIView alloc] init];
    viewBg.tkThemebackgroundColors = @[COLORWHITE, COLOR_EEEEEE_DARK];
    viewBg.layer.cornerRadius = DWScale(14);
    viewBg.clipsToBounds = YES;
    [self.contentView addSubview:viewBg];
    [viewBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DScreenWidth - DWScale(32), DWScale(176)));
    }];
    
    UIButton *btnInfo = [UIButton buttonWithType:UIButtonTypeCustom];
    btnInfo.tkThemebackgroundColors =  @[COLORWHITE, COLOR_F5F6F9_DARK];
    [btnInfo setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE]] forState:UIControlStateSelected];
    [btnInfo setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE]] forState:UIControlStateHighlighted];
    [btnInfo addTarget:self action:@selector(btnInfoClick) forControlEvents:UIControlEventTouchUpInside];
    [viewBg addSubview:btnInfo];
    [btnInfo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(viewBg);
        make.height.mas_equalTo(DWScale(76));
    }];
    
    _ivGroup = [[NoaBaseImageView alloc] init];
    _ivGroup.layer.cornerRadius = DWScale(22);
    _ivGroup.layer.masksToBounds = YES;
    [viewBg addSubview:_ivGroup];
    [_ivGroup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(viewBg).offset(DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(44), DWScale(44)));
    }];
    
    _ivArrowTop = [[UIImageView alloc] initWithImage:ImgNamed(@"c_arrow_right_gray")];
    [viewBg addSubview:_ivArrowTop];
    [_ivArrowTop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_ivGroup);
        make.trailing.equalTo(viewBg).offset(-DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(8), DWScale(16)));
    }];
    
    _lblGroupName = [UILabel new];
    _lblGroupName.font = FONTR(16);
    _lblGroupName.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [viewBg addSubview:_lblGroupName];
    [_lblGroupName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_ivGroup);
        make.leading.equalTo(_ivGroup.mas_trailing).offset(DWScale(4));
        //make.width.mas_equalTo(DWScale(211));
        make.trailing.equalTo(_ivArrowTop.mas_leading).offset(-DWScale(10));
    }];
    
   
    
    /*
    UIImageView *ivQR = [[UIImageView alloc] initWithImage:ImgNamed(@"s_qr_logo")];
    [viewBg addSubview:ivQR];
    [ivQR mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_ivGroup);
        make.trailing.equalTo(ivArrowTop.mas_leading).offset(-DWScale(10));
        make.size.mas_equalTo(CGSizeMake(DWScale(16), DWScale(16)));
    }];
    */
    
    UIView *viewLine = [UIView new];
    viewLine.tkThemebackgroundColors = @[COLOR_EEEEEE, [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1]];
    [viewBg addSubview:viewLine];
    [viewLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewBg);
        make.top.equalTo(viewBg).offset(DWScale(75));
        make.size.mas_equalTo(CGSizeMake(DWScale(311), DWScale(1)));
    }];
    
    
    UIButton *btnMember = [UIButton buttonWithType:UIButtonTypeCustom];
    btnMember.tkThemebackgroundColors =  @[COLORWHITE, COLOR_F5F6F9_DARK];
    [btnMember setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE]] forState:UIControlStateSelected];
    [btnMember setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE]] forState:UIControlStateHighlighted];
    [btnMember addTarget:self action:@selector(btnMemberClick) forControlEvents:UIControlEventTouchUpInside];
    [viewBg addSubview:btnMember];
    [btnMember mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(btnInfo.mas_bottom);
        make.leading.mas_equalTo(viewBg);
        make.trailing.mas_equalTo(viewBg);
        make.height.mas_equalTo(DWScale(100));
    }];

    UILabel *lblMemberTip = [UILabel new];
    lblMemberTip.text = LanguageToolMatch(@"群成员");
    lblMemberTip.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    lblMemberTip.font = FONTR(14);
    [viewBg addSubview:lblMemberTip];
    [lblMemberTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(viewBg).offset(DWScale(16));
        make.top.equalTo(viewLine.mas_bottom).offset(DWScale(10));
        make.height.mas_equalTo(DWScale(20));
    }];
    
    UIImageView *ivArrowBottom = [[UIImageView alloc] initWithImage:ImgNamed(@"c_arrow_right_gray")];
    [viewBg addSubview:ivArrowBottom];
    [ivArrowBottom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(lblMemberTip);
        make.trailing.equalTo(viewBg).offset(-DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(8), DWScale(16)));
    }];
    
    _lblMemberCount = [UILabel new];
    _lblMemberCount.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    _lblMemberCount.font = FONTR(14);
    [viewBg addSubview:_lblMemberCount];
    [_lblMemberCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(lblMemberTip);
        make.trailing.equalTo(ivArrowBottom.mas_leading).offset(-DWScale(10));
    }];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemW = (DScreenWidth - DWScale(109)) / 6.0;
    layout.itemSize = CGSizeMake(itemW, itemW);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = DWScale(9);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.tkThemebackgroundColors = @[[UIColor clearColor],[UIColor clearColor]];
    [_collectionView registerClass:[NoaGroupMemberHeaderCell class] forCellWithReuseIdentifier:NSStringFromClass([NoaGroupMemberHeaderCell class])];
    [viewBg addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(viewBg).offset(DWScale(16));
        make.trailing.equalTo(viewBg).offset(-DWScale(16));
        make.top.equalTo(lblMemberTip.mas_bottom).offset(DWScale(10));
        make.height.mas_equalTo(itemW);
    }];
}
#pragma mark - 数据赋值
- (void)setGroupModel:(LingIMGroup *)groupModel {
    if (groupModel) {
        _groupModel = groupModel;
        [_ivGroup sd_setImageWithURL:[groupModel.groupAvatar getImageFullUrl] placeholderImage:DefaultGroup options:SDWebImageRetryFailed | SDWebImageAllowInvalidSSLCertificates];
        _lblGroupName.text = groupModel.groupName;
        _lblMemberCount.text = [NSString stringWithFormat:LanguageToolMatch(@"%ld人"),groupModel.memberCount];
        
        if (groupModel.userGroupRole == 0) {
            _ivArrowTop.hidden = YES;
            //群成员
            if (groupModel.groupMemberList.count >= 5) {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 5)];
                _memberList = [groupModel.groupMemberList objectsAtIndexes:indexSet].mutableCopy;
            }else {
                _memberList = groupModel.groupMemberList.mutableCopy;
            }
        }else if (groupModel.userGroupRole == 1 || groupModel.userGroupRole == 2) {
            //群主或管理员
            
            _ivArrowTop.hidden = NO;
            if (groupModel.groupMemberList.count >= 4) {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)];
                _memberList = [groupModel.groupMemberList objectsAtIndexes:indexSet].mutableCopy;
            }else {
                _memberList = groupModel.groupMemberList.mutableCopy;
            }
        }
        
        //仅允许群管理查看群人数（1=是，0=否）
        if ([UserManager.userRoleAuthInfo.showGroupPersonNum.configValue isEqualToString:@"true"]) {
            _lblMemberCount.hidden = NO;
        } else {
            if ([ZHostTool.appSysSetModel.onlyAllowAdminViewGroupPersonCount isEqualToString:@"1"]) {
                if (groupModel.userGroupRole == 0) {
                    //普通群成员
                    _lblMemberCount.hidden = YES;
                } else {
                    //群主或管理员
                    _lblMemberCount.hidden = NO;
                }
            } else {
                _lblMemberCount.hidden = NO;
            }
        }
        
        [_collectionView reloadData];
    }
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_groupModel.userGroupRole == 0) {
        //群成员 5 + 1；只能邀请群成员
        return _groupModel.groupMemberList.count > 5 ? 5 + 1 : _groupModel.groupMemberList.count + 1;
    }else if (_groupModel.userGroupRole == 1 || _groupModel.userGroupRole == 2) {
        //群主/管理员 4 + 2；可以删除和邀请群成员
        return _groupModel.groupMemberList.count > 4 ? 4 + 2 : _groupModel.groupMemberList.count + 2;
    } else {
        return 0;
    }
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NoaGroupMemberHeaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NoaGroupMemberHeaderCell class]) forIndexPath:indexPath];
    LingIMGroupMemberModel *memberModel = [_memberList objectAtIndexSafe:indexPath.row];
    if (memberModel) {
        [cell configCellWith:memberModel action:YES];
    }else {
        NSInteger totalRows = [collectionView numberOfItemsInSection:indexPath.section];
        if (_groupModel.userGroupRole == 0) {
            if (indexPath.row == totalRows - 1) {
                [cell configCellWith:nil action:YES];
            }
        }else if (_groupModel.userGroupRole == 1 || _groupModel.userGroupRole == 2) {
            if (indexPath.row == totalRows - 1) {
                [cell configCellWith:nil action:NO];
            }else if (indexPath.row == totalRows - 2) {
                [cell configCellWith:nil action:YES];
            }
        }
    }
    return cell;
}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LingIMGroupMemberModel *memberModel = [_memberList objectAtIndexSafe:indexPath.row];
    if (memberModel) {
        //点击群成员头像
    }else {
        NSInteger totalRows = [collectionView numberOfItemsInSection:indexPath.section];
        if (_groupModel.userGroupRole == 0) {
            if (indexPath.row == totalRows - 1) {
                if (self.tapInviteFriendBlock) {
                    self.tapInviteFriendBlock();
                }
            }
        }else if (_groupModel.userGroupRole == 1 || _groupModel.userGroupRole == 2) {
            if (indexPath.row == totalRows - 1) {
                //群主或管理员 删除群成员
                if (self.tapRemoveFriendBlock) {
                    self.tapRemoveFriendBlock();
                }
            }else if (indexPath.row == totalRows - 2) {
                //群主或管理员 邀请群成员
                if (self.tapInviteFriendBlock) {
                    self.tapInviteFriendBlock();
                }

            }
        }
    }
}

#pragma mark - 交互事件
- (void)btnInfoClick {
    if (_groupModel.userGroupRole == 0) {
        //普通群成员
        return;
    } else if (_groupModel.userGroupRole == 1 || _groupModel.userGroupRole == 2) {
        if (self.tapGroupInfoViewBlock) {
            self.tapGroupInfoViewBlock();
        }
    }
}

- (void)btnMemberClick {
    if (self.tapVisitGroupMemberBlock) {
        self.tapVisitGroupMemberBlock();
    }
}

+ (CGFloat)defaultCellHeight {
    return DWScale(176);
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
