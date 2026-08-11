//
//  NoaContactListTableCell.m
//  NoaKit
//
//  Created by Candy on 2026/9/9.
//

#import "NoaContactListTableCell.h"
#import "NoaToolManager.h"

@interface NoaContactListTableCell()

@property (nonatomic, strong)UIImageView *headImgView;
@property (nonatomic, strong) UILabel *userRoleName;//用户角色名称
@property (nonatomic, strong)UILabel *nickNameLabel;
@property (nonatomic, strong) UIButton *tempBtn;
@end

@implementation NoaContactListTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        self.tkThemebackgroundColors = @[COLOR_F8F9FB, COLOR_F8F9FB_DARK];
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    [self.contentView addSubview:self.baseContentButton];
    self.baseContentButton.frame = CGRectMake(0, 0, DScreenWidth, DWScale(68));
    
    self.headImgView = [[UIImageView alloc] init];
    [self.headImgView rounded:20 width:1 color:HEXCOLOR(@"D8D9FF")];
    [self.contentView addSubview:self.headImgView];
    [self.headImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(15);
        make.centerY.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    
    self.userRoleName = [UILabel new];
    self.userRoleName.text = @"";
    self.userRoleName.tkThemetextColors = @[COLORWHITE, COLORWHITE];
    self.userRoleName.font = FONTN(7);
    self.userRoleName.tkThemebackgroundColors = @[COLOR_EAB243, COLOR_EAB243_DARK];
    self.userRoleName.textAlignment = NSTextAlignmentCenter;
    [self.userRoleName rounded:DWScale(15.4)/2];
    self.userRoleName.hidden = YES;
    [self.contentView addSubview:self.userRoleName];
    [self.userRoleName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.headImgView).offset(-DWScale(1));
        make.trailing.equalTo(self.headImgView).offset(DWScale(1));
        make.bottom.equalTo(self.headImgView);
        make.height.mas_equalTo(DWScale(15.4));
    }];
    
    self.nickNameLabel = [[UILabel alloc] init];
    self.nickNameLabel.text = @"";
    self.nickNameLabel.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    self.nickNameLabel.font = FONTN(16);
    self.nickNameLabel.textAlignment = NSTextAlignmentLeft;
    self.nickNameLabel.numberOfLines = 1;
    [self.contentView addSubview:self.nickNameLabel];
    [self.nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.headImgView.mas_trailing).offset(DWScale(15));
        make.centerY.mas_equalTo(self.headImgView);
        make.trailing.mas_equalTo(self.contentView).offset(-DWScale(15));
    }];
    
    [self.nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.headImgView.mas_trailing).offset(10);
        make.centerY.equalTo(self.headImgView);
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-40);
    }];
    
    _viewOnline = [UIView new];
    _viewOnline.tkThemebackgroundColors = @[HEXCOLOR(@"01BC46"), HEXCOLOR(@"01BC46")];
    _viewOnline.layer.cornerRadius = DWScale(3);
    _viewOnline.layer.masksToBounds = YES;
    _viewOnline.hidden = YES;
    [self.contentView addSubview:_viewOnline];
    [_viewOnline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.equalTo(self.headImgView);
        make.size.mas_equalTo(CGSizeMake(DWScale(6), DWScale(6)));
    }];
    
    UIView *line = [UIView new];
    line.tkThemebackgroundColors = @[COLOR_EEF1FA, COLOR_EEF1FA_DARK];
    [self.contentView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(DWScale(0.5));
        make.leading.mas_equalTo(self.nickNameLabel);
    }];
}
#pragma mark - 数据赋值
- (void)setFriendModel:(LingIMFriendModel *)friendModel {
    if (friendModel) {
        _friendModel = friendModel;
        
        NSString *imgUrl = [NSString loadAvatarWithUserStatus:_friendModel.disableStatus avatarUri:friendModel.avatar];
        [self.headImgView loadAvatarWithUserImgContent:imgUrl defaultImg:DefaultAvatar];
        self.nickNameLabel.text = [NSString loadNickNameWithUserStatus:friendModel.disableStatus realNickName:friendModel.showName];
        //角色名称
        NSString *roleName = [UserManager matchUserRoleConfigInfo:_friendModel.roleId disableStatus:_friendModel.disableStatus];
        if ([NSString isNil:roleName]) {
            self.userRoleName.hidden = YES;
        } else {
            self.userRoleName.hidden = NO;
            self.userRoleName.text = roleName;
        }
    }
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
