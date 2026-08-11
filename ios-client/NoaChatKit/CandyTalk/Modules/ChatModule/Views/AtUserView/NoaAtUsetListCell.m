//
//  NoaAtUsetListCell.m
//  NoaKit
//
//  Created by Candy on 2026/12/5.
//

#import "NoaAtUsetListCell.h"
#import "NoaBaseImageView.h"
//#import <YYText/YYText.h>

@interface NoaAtUsetListCell()

@property (nonatomic, strong) UILabel *lblUserName;
@property (nonatomic, strong) NoaBaseImageView *ivHeader;
@property (nonatomic, strong) UILabel *lblUserRoleName;//用户角色名称

@end

@implementation NoaAtUsetListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    _ivHeader = [[NoaBaseImageView alloc] initWithImage:DefaultAvatar];
    [_ivHeader rounded:DWScale(22)];
    [self.contentView addSubview:_ivHeader];
    [_ivHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.contentView.mas_leading).offset(DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(44), DWScale(44)));
    }];
    
    _lblUserRoleName = [UILabel new];
    _lblUserRoleName.text = @"";
    _lblUserRoleName.tkThemetextColors = @[COLORWHITE, COLORWHITE];
    _lblUserRoleName.font = FONTN(7);
    _lblUserRoleName.tkThemebackgroundColors = @[COLOR_EAB243, COLOR_EAB243_DARK];
    _lblUserRoleName.textAlignment = NSTextAlignmentCenter;
    [_lblUserRoleName rounded:DWScale(15.4)/2];
    _lblUserRoleName.hidden = YES;
    [self.contentView addSubview:_lblUserRoleName];
    [_lblUserRoleName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_ivHeader).offset(-DWScale(1));
        make.trailing.equalTo(_ivHeader).offset(DWScale(1));
        make.bottom.equalTo(_ivHeader);
        make.height.mas_equalTo(DWScale(15.4));
    }];
    
    _lblUserName = [UILabel new];
    _lblUserName.font = FONTR(16);
    _lblUserName.tkThemetextColors = @[COLOR_11, COLORWHITE];
    [self.contentView addSubview:_lblUserName];
    [_lblUserName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(_ivHeader.mas_trailing).offset(DWScale(10));
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(DWScale(-10));
        make.centerY.equalTo(_ivHeader);
        make.height.mas_equalTo(DWScale(22));
    }];
}

- (void)cellConfigWithmodel:(id)model searchStr:(NSString *)searchStr{
    if ([model isKindOfClass:[NoaUserModel class]]) {
        NoaUserModel *userModel = (NoaUserModel *)model;
        [_ivHeader sd_setImageWithURL:[userModel.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
        //角色名称
        NSString *roleName = [UserManager matchUserRoleConfigInfo:userModel.roleId disableStatus:userModel.disableStatus];
        if ([NSString isNil:roleName]) {
            _lblUserRoleName.hidden = YES;
        } else {
            _lblUserRoleName.hidden = NO;
            _lblUserRoleName.text = roleName;
        }
        
        __block NSMutableAttributedString *attStrName = [[NSMutableAttributedString alloc] initWithString:![NSString isNil:userModel.remarks] ? userModel.remarks : userModel.nickname];
        attStrName.yy_font = FONTR(16);
        self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
            switch (themeIndex) {
                case 1:
                {
                    //暗黑
                    attStrName.yy_color = COLORWHITE;
                }
                    break;
                    
                default:
                {
                    //浅色
                    attStrName.yy_color = COLOR_11;
                }
                    break;
            }
        };
        if (![NSString isNil:searchStr]) {
            NSRange rangeName = [userModel.showName rangeOfString:searchStr options:NSCaseInsensitiveSearch];//不区分大小写
            [attStrName yy_setFont:FONTR(16) range:rangeName];
            [attStrName yy_setColor:COLOR_5966F2 range:rangeName];
        }
        _lblUserName.attributedText = attStrName;
    }
    if ([model isKindOfClass:[LingIMGroupMemberModel class]]) {
        LingIMGroupMemberModel *groupMemeberModel = (LingIMGroupMemberModel *)model;
        
        if ([groupMemeberModel.userAvatar isEqualToString:@"c_msg_at_all"]) {
            //@所有人
            _lblUserRoleName.hidden = YES;
            [_ivHeader setImage:ImgNamed(groupMemeberModel.userAvatar)];
        } else {
            [_ivHeader sd_setImageWithURL:[groupMemeberModel.userAvatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
            
            //角色名称
            NSString *roleName = [UserManager matchUserRoleConfigInfo:groupMemeberModel.roleId disableStatus:groupMemeberModel.disableStatus];
            if ([NSString isNil:roleName]) {
                _lblUserRoleName.hidden = YES;
            } else {
                _lblUserRoleName.hidden = NO;
                _lblUserRoleName.text = roleName;
            }
        }
        
        __block NSMutableAttributedString *attStrName = [[NSMutableAttributedString alloc] initWithString:groupMemeberModel.showName];
        attStrName.yy_font = FONTR(16);
        self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
            switch (themeIndex) {
                case 1:
                {
                    //暗黑
                    attStrName.yy_color = COLORWHITE;
                }
                    break;
                    
                default:
                {
                    //浅色
                    attStrName.yy_color = COLOR_11;
                }
                    break;
            }
        };
        if (![NSString isNil:searchStr]) {
            NSRange rangeName = [groupMemeberModel.showName rangeOfString:searchStr options:NSCaseInsensitiveSearch];//不区分大小写
            [attStrName yy_setFont:FONTR(16) range:rangeName];
            [attStrName yy_setColor:COLOR_5966F2 range:rangeName];
        }
        _lblUserName.attributedText = attStrName;
    }
}

@end
