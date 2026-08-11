//
//  NoaMassMessageUserHeaderCell.m
//  NoaKit
//
//  Created by Candy on 2023/4/20.
//

#import "NoaMassMessageUserHeaderCell.h"
#import "NoaBaseUserModel.h"
@implementation NoaMassMessageUserHeaderCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    _ivHeader = [[UIImageView alloc] initWithImage:ImgNamed(@"s_add_member")];
    _ivHeader.layer.cornerRadius = DWScale(22);
    _ivHeader.layer.masksToBounds = YES;
    [self.contentView addSubview:_ivHeader];
    [_ivHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
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
    
    _viewMask = [UIView new];
    _viewMask.tkThemebackgroundColors = @[HEXACOLOR(@"171717", 0.8), HEXACOLOR(@"171717", 0.8)];
    _viewMask.layer.cornerRadius = DWScale(22);
    _viewMask.layer.masksToBounds = YES;
    _viewMask.hidden = YES;
    [self.contentView addSubview:_viewMask];
    [_viewMask mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(DWScale(44), DWScale(44)));
    }];
    
    _lblNumber = [UILabel new];
    _lblNumber.tkThemetextColors = @[COLORWHITE, COLORWHITE_DARK];
    _lblNumber.font = FONTR(10);
    _lblNumber.textAlignment = NSTextAlignmentCenter;
    [_viewMask addSubview:_lblNumber];
    [_lblNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_viewMask);
        make.leading.trailing.equalTo(_viewMask);
    }];
    
}

- (void)setModel:(id)model {
    if (model != nil) {
        _model = model;
        if ([_model isKindOfClass:[NoaBaseUserModel class]]) {
            //联系人
            NoaBaseUserModel *model = (NoaBaseUserModel *)_model;
            if (model.isGroup) {
                [_ivHeader sd_setImageWithURL:[model.avatar getImageFullUrl] placeholderImage:DefaultGroup options:SDWebImageAllowInvalidSSLCertificates];
                _ivRoleName.hidden = YES;
            } else {
                [_ivHeader sd_setImageWithURL:[model.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
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
        if ([_model isKindOfClass:[NSString class]]) {
            NSString *reviceId = (NSString *)model;
            LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:reviceId]; //联系人
            LingIMGroupModel *groupModel = [IMSDKManager toolCheckMyGroupWith:reviceId];    //群组
            if (friendModel)  {
                [_ivHeader sd_setImageWithURL:[friendModel.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
                //角色名称
                NSString *roleName = [UserManager matchUserRoleConfigInfo:friendModel.roleId disableStatus:friendModel.disableStatus];
                if ([NSString isNil:roleName]) {
                    _ivRoleName.hidden = YES;
                } else {
                    _ivRoleName.hidden = NO;
                    _ivRoleName.text = roleName;
                }
            } else if (groupModel) {
                [_ivHeader sd_setImageWithURL:[groupModel.groupAvatar getImageFullUrl] placeholderImage:DefaultGroup options:SDWebImageAllowInvalidSSLCertificates];
                _ivRoleName.hidden = YES;
            } else {
                _viewMask.hidden = YES;
                _ivHeader.image = ImgNamed(@"DefaultGroup");
                _ivRoleName.hidden = YES;
            }
        }
    } else {
        _viewMask.hidden = YES;
        _ivHeader.image = ImgNamed(@"s_add_member");
        _ivRoleName.hidden = YES;
    }
}

@end
