//
//  NoaChatSingleSetInfoCell.m
//  NoaKit
//
//  Created by Candy on 2026/12/29.
//

#import "NoaChatSingleSetInfoCell.h"
#import "NoaBaseImageView.h"

@interface NoaChatSingleSetInfoCell ()
//@property (nonatomic, strong) NSArray *titleArr;
@property (nonatomic, strong) NoaBaseImageView *ivHeader;
@property (nonatomic, strong) UILabel *ivRoleName;//用户角色名称
@property (nonatomic, strong) UILabel *lblNickname;
@property (nonatomic, strong) UIButton *addButton;
@end


@implementation NoaChatSingleSetInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = UIColor.clearColor;
        self.backgroundColor = UIColor.clearColor;
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    //用户信息
    UIView *viewUser = [[UIView alloc] initWithFrame:CGRectMake(DWScale(16), 0, DScreenWidth - DWScale(32), DWScale(76))];
    viewUser.tkThemebackgroundColors = @[COLORWHITE, COLOR_F5F6F9_DARK];
    viewUser.layer.cornerRadius = DWScale(12);
    viewUser.layer.masksToBounds = YES;
    [self.contentView addSubview:viewUser];
    
    _ivHeader = [[NoaBaseImageView alloc] init];
    _ivHeader.layer.cornerRadius = DWScale(22);
    _ivHeader.layer.masksToBounds = YES;
    _ivHeader.userInteractionEnabled = YES;
    [_ivHeader addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerClick)]];
    [viewUser addSubview:_ivHeader];
    [_ivHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(viewUser).offset(DWScale(16));
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    
    _ivRoleName = [UILabel new];
    _ivRoleName.text = @"";
    _ivRoleName.tkThemetextColors = @[COLORWHITE, COLORWHITE];
    _ivRoleName.font = FONTN(7);
    _ivRoleName.tkThemebackgroundColors = @[COLOR_EAB243, COLOR_EAB243_DARK];
    _ivRoleName.textAlignment = NSTextAlignmentCenter;
    [_ivRoleName rounded:DWScale(15.4)/2];
    _ivRoleName.hidden = YES;
    [viewUser addSubview:_ivRoleName];
    [_ivRoleName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_ivHeader).offset(-DWScale(1));
        make.trailing.equalTo(_ivHeader).offset(DWScale(1));
        make.bottom.equalTo(_ivHeader);
        make.height.mas_equalTo(DWScale(15.4));
    }];

    UIButton *btnAdd = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnAdd setImage:ImgNamed(@"s_add_member") forState:UIControlStateNormal];
    [btnAdd addTarget:self action:@selector(btnAddClick) forControlEvents:UIControlEventTouchUpInside];
    [viewUser addSubview:btnAdd];
    self.addButton = btnAdd;
    [btnAdd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_ivHeader);
        make.size.equalTo(_ivHeader);
        make.trailing.equalTo(viewUser).offset(-DWScale(16));
    }];
    
    _lblNickname = [UILabel new];
    _lblNickname.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _lblNickname.font = FONTR(16);
    [viewUser addSubview:_lblNickname];
    [_lblNickname mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_ivHeader);
        make.leading.equalTo(_ivHeader.mas_trailing).offset(DWScale(6));
        make.trailing.equalTo(btnAdd.mas_leading).offset(DWScale(-6));
    }];
}

- (void)btnAddClick{
    if (self.tapSingleInfoAddBlock) {
        self.tapSingleInfoAddBlock();
    }
}

- (void)headerClick {
    if (self.tapHeaderBlock) {
        self.tapHeaderBlock();
    }
}

#pragma mark - 界面赋值更新
- (void)cellConfigWithModel:(LingIMFriendModel *)model{
    if (model) {
        if (model.disableStatus == 4) {
            self.addButton.hidden = YES;
            NSString *imgUrl = [NSString loadAvatarWithUserStatus:model.disableStatus avatarUri:model.avatar];
            [_ivHeader loadAvatarWithUserImgContent:imgUrl defaultImg:DefaultAvatar];
            _lblNickname.text = [NSString loadNickNameWithUserStatus:model.disableStatus realNickName:model.showName];
            _ivRoleName.hidden = YES;
        } else {
            self.addButton.hidden = NO;
            [_ivHeader sd_setImageWithURL:[model.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
            _lblNickname.text = model.showName;
            //角色名称
            NSString *roleName = [UserManager matchUserRoleConfigInfo:model.roleId disableStatus:model.disableStatus];
            if ([NSString isNil:roleName]) {
                _ivRoleName.hidden = YES;
            } else {
                _ivRoleName.hidden = NO;
                _ivRoleName.text = roleName;
            }
        }
    }
}


+ (CGFloat)defaultCellHeight {
    return DWScale(76);
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
