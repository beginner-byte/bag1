//
//  NoaMassMessageUserCell.m
//  NoaKit
//
//  Created by Candy on 2023/4/19.
//

#import "NoaMassMessageUserCell.h"

@interface NoaMassMessageUserCell ()

@end

@implementation NoaMassMessageUserCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    _ivHeader = [[UIImageView alloc] initWithFrame:CGRectMake(DWScale(16), DWScale(12), DWScale(44), DWScale(44))];
    _ivHeader.layer.cornerRadius = DWScale(22);
    _ivHeader.layer.masksToBounds = YES;
    [self.contentView addSubview:_ivHeader];
    
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
    
    _lblNickname = [UILabel new];
    _lblNickname.font = FONTR(16);
    _lblNickname.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [self.contentView addSubview:_lblNickname];
    [_lblNickname mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_ivHeader);
        make.leading.equalTo(_ivHeader.mas_trailing).offset(DWScale(10));
        make.trailing.equalTo(self.contentView.mas_trailing).offset(DWScale(-10));
    }];
    
    _lblTip = [UILabel new];
    _lblTip.text = LanguageToolMatch(@"发送失败");
    _lblTip.font = FONTR(12);
    _lblTip.tkThemetextColors = @[COLOR_F93A2F, COLOR_F93A2F_DARK];
    [self.contentView addSubview:_lblTip];
    [_lblTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_ivHeader);
        make.trailing.equalTo(self.contentView).offset(-DWScale(26));
    }];
}

+ (CGFloat)defaultCellHeight {
    return DWScale(68);
}
#pragma mark - 界面赋值
- (void)setUserModel:(id)userModel {
    _userModel = userModel;
    if ([_userModel isKindOfClass:[NoaMassMessageUserModel class]]) {
        _lblTip.hidden = YES;
        NoaMassMessageUserModel *msgUserModel = (NoaMassMessageUserModel *)_userModel;
        if (msgUserModel.chatType == 0) {
            //单人
            LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:msgUserModel.memberUid];
            [_ivHeader sd_setImageWithURL:[friendModel.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
            _lblNickname.text = friendModel.showName;
            //角色名称
            NSString *roleName = [UserManager matchUserRoleConfigInfo:friendModel.roleId disableStatus:friendModel.disableStatus];
            if ([NSString isNil:roleName]) {
                _ivRoleName.hidden = YES;
            } else {
                _ivRoleName.hidden = NO;
                _ivRoleName.text = roleName;
            }
        }
        if (msgUserModel.chatType == 1) {
            //群
            LingIMGroupModel *groupModel = [IMSDKManager toolCheckMyGroupWith:msgUserModel.memberUid];
            [_ivHeader sd_setImageWithURL:[groupModel.groupAvatar getImageFullUrl] placeholderImage:DefaultGroup options:SDWebImageAllowInvalidSSLCertificates];
            _lblNickname.text = groupModel.groupName;
            _ivRoleName.hidden = YES;
        }
    }
    if ([_userModel isKindOfClass:[NoaMassMessageErrorUserModel class]]) {
        _lblTip.hidden = NO;
        NoaMassMessageErrorUserModel *errorUserModel = (NoaMassMessageErrorUserModel *)_userModel;
        if (errorUserModel.chatType == 0) {
            //单人
            LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:errorUserModel.errorUserUid];
            [_ivHeader sd_setImageWithURL:[friendModel.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
            _lblNickname.text = friendModel.showName;
            //角色名称
            NSString *roleName = [UserManager matchUserRoleConfigInfo:friendModel.roleId disableStatus:friendModel.disableStatus];
            if ([NSString isNil:roleName]) {
                _ivRoleName.hidden = YES;
            } else {
                _ivRoleName.hidden = NO;
                _ivRoleName.text = roleName;
            }
        }
        if (errorUserModel.chatType == 1) {
            //群
            LingIMGroupModel *groupModel = [IMSDKManager toolCheckMyGroupWith:errorUserModel.errorUserUid];
            [_ivHeader sd_setImageWithURL:[groupModel.groupAvatar getImageFullUrl] placeholderImage:DefaultGroup options:SDWebImageAllowInvalidSSLCertificates];
            _lblNickname.text = groupModel.groupName;
            _ivRoleName.hidden = YES;
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
