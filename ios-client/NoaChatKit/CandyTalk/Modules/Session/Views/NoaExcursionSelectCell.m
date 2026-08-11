//
//  NoaExcursionSelectCell.m
//  NoaKit
//
//  Created by Candy on 2024/1/12.
//

#import "NoaExcursionSelectCell.h"
#import "NoaBaseImageView.h"

@interface NoaExcursionSelectCell()
@property (nonatomic, strong) UIImageView *ivSelect;//选中
@property (nonatomic, strong) NoaBaseImageView *ivHeader;//头像
@property (nonatomic, strong) UILabel *ivRoleName;//用户角色名称
@property (nonatomic, strong) UILabel *lblName;//昵称、备注

//@property (nonatomic, strong) LingIMFriendModel *userFriendModel;
//@property (nonatomic, strong) LingIMGroupModel *userGroupModel;
@property (nonatomic, strong) NoaBaseUserModel *baseUserModel;

@end

@implementation NoaExcursionSelectCell

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
    
    _ivSelect = [[UIImageView alloc] initWithImage:ImgNamed(@"c_select_no")];
    [self.contentView addSubview:_ivSelect];
    [_ivSelect mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(DWScale(48));
        make.size.mas_equalTo(CGSizeMake(DWScale(18), DWScale(18)));
    }];
    
    _ivHeader = [[NoaBaseImageView alloc] initWithImage:DefaultAvatar];
    _ivHeader.layer.cornerRadius = DWScale(17);
    _ivHeader.layer.masksToBounds = YES;
    [self.contentView addSubview:_ivHeader];
    [_ivHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(_ivSelect.mas_trailing).offset(DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(34), DWScale(34)));
    }];
    
    _ivRoleName = [UILabel new];
    _ivRoleName.text = @"";
    _ivRoleName.tkThemetextColors = @[COLORWHITE, COLORWHITE];
    _ivRoleName.font = FONTR(6);
    _ivRoleName.tkThemebackgroundColors = @[COLOR_EAB243, COLOR_EAB243_DARK];
    _ivRoleName.textAlignment = NSTextAlignmentCenter;
    [_ivRoleName rounded:DWScale(14)/2];
    _ivRoleName.hidden = YES;
    [self.contentView addSubview:_ivRoleName];
    [_ivRoleName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_ivHeader).offset(-DWScale(2));
        make.trailing.equalTo(_ivHeader).offset(DWScale(2));
        make.bottom.equalTo(_ivHeader).offset(DWScale(2));
        make.height.mas_equalTo(DWScale(14));
    }];
    
    _lblName = [UILabel new];
    _lblName.text = @"";
    _lblName.font = FONTR(16);
    _lblName.numberOfLines = 1;
    _lblName.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [self.contentView addSubview:_lblName];
    [_lblName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(_ivHeader.mas_trailing).offset(DWScale(10));
        make.trailing.equalTo(self.contentView).offset(-DWScale(16));
    }];
}


+ (CGFloat)defaultCellHeight {
    return DWScale(50);
}

#pragma mark - 数据赋值
- (void)cellConfigBaseUserWith:(NoaBaseUserModel *)model search:(NSString *)searchStr {
    if (model) {
        _baseUserModel = model;
             
        [_ivHeader sd_setImageWithURL:[model.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
        //角色名称
        if (_baseUserModel.showRole) {
            NSString *roleName = [UserManager matchUserRoleConfigInfo:_baseUserModel.roleId disableStatus:_baseUserModel.disableStatus];
            if ([NSString isNil:roleName]) {
                _ivRoleName.hidden = YES;
            } else {
                _ivRoleName.hidden = NO;
                _ivRoleName.text = roleName;
            }
        } else {
            _ivRoleName.hidden = YES;
        }
        
        __block NSMutableAttributedString *attStrName = [[NSMutableAttributedString alloc] initWithString:![NSString isNil:model.name] ? model.name : @""];
        attStrName.yy_font = FONTR(16);
        self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
            switch (themeIndex) {
                case 1:
                {
                    //暗黑
                    attStrName.yy_color = COLOR_11_DARK;
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
            NSRange rangeName = [model.name rangeOfString:searchStr options:NSCaseInsensitiveSearch];//不区分大小写
            [attStrName yy_setFont:FONTR(16) range:rangeName];
            [attStrName yy_setColor:COLOR_5966F2 range:rangeName];
        }
        _lblName.attributedText = attStrName;
    }
}

- (void)setSelectedUser:(BOOL)selectedUser {
    _selectedUser = selectedUser;
    if (self.baseUserModel.isExistGroup) {
        _ivSelect.image = ImgNamed(@"c_select_unknow");
    } else {
        if (selectedUser) {
            _ivSelect.image = ImgNamed(@"c_select_yes");
        }else {
            _ivSelect.image = ImgNamed(@"c_select_no");
        }
    }
}

@end
