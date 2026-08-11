//
//  NoaGroupMemberListCell.m
//  NoaKit
//
//  Created by Candy on 2026/11/9.
//

#import "NoaGroupMemberListCell.h"
//#import <YYText/YYText.h>
@interface NoaGroupMemberListCell ()

@property (nonatomic, strong) UILabel *groupRoleLabel;

@end

@implementation NoaGroupMemberListCell

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
    UIButton * _viewBg = [[UIButton alloc] init];
    _viewBg.frame = CGRectMake(0, 0, DScreenWidth , DWScale(68));
    _viewBg.tkThemebackgroundColors =  @[COLORWHITE, COLOR_11];
    [_viewBg setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE]] forState:UIControlStateSelected];
    [_viewBg setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE]] forState:UIControlStateHighlighted];
    [_viewBg addTarget:self action:@selector(cellTouchAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_viewBg];
    
    _ivHeader = [[NoaBaseImageView alloc] initWithImage:DefaultAvatar];
    _ivHeader.layer.cornerRadius = DWScale(22);
    _ivHeader.layer.masksToBounds = YES;
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
    [_lblUserRoleName rounded:8];
    _lblUserRoleName.hidden = YES;
    [self.contentView addSubview:_lblUserRoleName];
    [_lblUserRoleName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_ivHeader).offset(-DWScale(1));
        make.trailing.equalTo(_ivHeader).offset(DWScale(1));
        make.bottom.equalTo(_ivHeader);
        make.height.mas_equalTo(DWScale(16));
    }];
    
    _lblUserName = [UILabel new];
    _lblUserName.font = FONTR(16);
    _lblUserName.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [self.contentView addSubview:_lblUserName];
    [_lblUserName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(_ivHeader.mas_trailing).offset(DWScale(10));
        make.centerY.equalTo(_ivHeader);
        make.height.mas_equalTo(DWScale(22));
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(DWScale(-10));
    }];
    
    self.groupRoleLabel = [UILabel new];
    self.groupRoleLabel.textColor = COLORWHITE;
    [self.groupRoleLabel rounded:4];
    self.groupRoleLabel.text = @"";
    self.groupRoleLabel.font = FONTN(10);
    self.groupRoleLabel.tkThemebackgroundColors = @[COLOR_FF9C9C, COLOR_FF9C9C];
    self.groupRoleLabel.textAlignment = NSTextAlignmentCenter;
    self.groupRoleLabel.hidden = YES;
    
    [self.contentView addSubview:self.groupRoleLabel];
    [self.groupRoleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_ivHeader);
        make.width.mas_equalTo(DWScale(50));
        make.height.mas_equalTo(DWScale(16));
        make.trailing.equalTo(self.contentView).offset(DWScale(-16));
    }];
}

#pragma mark - 交互事件
- (void)cellTouchAction {
    if ([self.baseDelegate respondsToSelector:@selector(cellClickAction:)]) {
        [self.baseDelegate cellClickAction:self.baseCellIndexPath];
    }
}

+ (CGFloat)defaultCellHeight {
    return DWScale(68);
}

- (void)cellConfigWithmodel:(LingIMGroupMemberModel *)model searchStr:(NSString *)searchStr activityInfo:(NoaGroupActivityInfoModel *)activityInfo isActivityEnable:(NSInteger)isActivityEnable {
    [_ivHeader sd_setImageWithURL:[model.userAvatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
    __block NSMutableAttributedString *attStrName = [[NSMutableAttributedString alloc] initWithString:model.showName];
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
        NSRange rangeName = [model.showName rangeOfString:searchStr options:NSCaseInsensitiveSearch];//不区分大小写
        [attStrName yy_setFont:FONTR(16) range:rangeName];
        [attStrName yy_setColor:COLOR_5966F2 range:rangeName];
    }
    _lblUserName.attributedText = attStrName;
    
    if (activityInfo) {
        [self checkGroupActivityRoleShowStatus:isActivityEnable activityScore:model.activityScroe role:model.role activityInfo:activityInfo];
    } else {
        [self checkGroupRoleContentWithRole:model.role];
    }
   
    //角色名称
    NSString *roleName = [UserManager matchUserRoleConfigInfo:model.roleId disableStatus:model.disableStatus];
    if ([NSString isNil:roleName]) {
        _lblUserRoleName.hidden = YES;
    } else {
        _lblUserRoleName.hidden = NO;
        _lblUserRoleName.text = roleName;
    }
}

//计算是否显示我在本群的角色(0普通成员;1管理员;2群主)
- (void)checkGroupRoleContentWithRole:(NSInteger)role {
    if(role == 1) { //群管理
        self.groupRoleLabel.hidden = NO;
        self.groupRoleLabel.text = LanguageToolMatch(@"管理员");
        self.groupRoleLabel.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2];

        CGSize roleTextSize = [LanguageToolMatch(@"管理员") sizeWithFont:FONTR(10) constrainedToSize:CGSizeMake(10000, DWScale(16))];
        [self.groupRoleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_ivHeader);
            make.width.mas_equalTo(roleTextSize.width + DWScale(20));
            make.height.mas_equalTo(DWScale(16));
            make.trailing.equalTo(self.contentView).offset(DWScale(-16));
        }];
        
        [_lblUserName mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(_ivHeader.mas_trailing).offset(DWScale(10));
            make.centerY.equalTo(_ivHeader);
            make.height.mas_equalTo(DWScale(22));
            make.trailing.mas_equalTo(self.groupRoleLabel.mas_leading).offset(DWScale(-10));
        }];
    } else if(role == 2) { //群主
        self.groupRoleLabel.hidden = NO;
        self.groupRoleLabel.text = LanguageToolMatch(@"群主");
        self.groupRoleLabel.tkThemebackgroundColors = @[COLOR_FF9327, COLOR_FF9327];

        CGSize roleTextSize = [LanguageToolMatch(@"群主") sizeWithFont:FONTR(10) constrainedToSize:CGSizeMake(10000, DWScale(16))];
        [self.groupRoleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_ivHeader);
            make.width.mas_equalTo(roleTextSize.width + DWScale(20));
            make.height.mas_equalTo(DWScale(16));
            make.trailing.equalTo(self.contentView).offset(DWScale(-16));
        }];
        
        [_lblUserName mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(_ivHeader.mas_trailing).offset(DWScale(10));
            make.centerY.equalTo(_ivHeader);
            make.height.mas_equalTo(DWScale(22));
            make.trailing.mas_equalTo(self.groupRoleLabel.mas_leading).offset(DWScale(-10));
        }];
    } else { // 普通成员/机器人
        self.groupRoleLabel.hidden = YES;
        self.groupRoleLabel.tkThemebackgroundColors = @[COLOR_FF9C9C, COLOR_FF9C9C];

        [_lblUserName mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(_ivHeader.mas_trailing).offset(DWScale(10));
            make.centerY.equalTo(_ivHeader);
            make.height.mas_equalTo(DWScale(22));
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(DWScale(-10));
        }];
    }
}

//计算是否需要显示活跃等级(是否启用群活跃功能（0：关闭，1：开启）)、等级值、是否显示我在本群的角色(0普通成员;1管理员;2群主)
- (void)checkGroupActivityRoleShowStatus:(NSInteger)isActivityLevel activityScore:(NSInteger)activityScore role:(NSInteger)role activityInfo:(NoaGroupActivityInfoModel *)activityInfo {
    
    NSString *groupRoleLabelStr;
    NSString *roleContent = @"";
    if (role == 2) {
        roleContent =  LanguageToolMatch(@"群主");
        self.groupRoleLabel.tkThemebackgroundColors = @[COLOR_FF9327, COLOR_FF9327];
    } else if (role == 1) {
        roleContent =  LanguageToolMatch(@"管理员");
        self.groupRoleLabel.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2];
    } else {
        roleContent = @"";
        self.groupRoleLabel.tkThemebackgroundColors = @[COLOR_FF9C9C, COLOR_FF9C9C];
    }
    
    if (isActivityLevel == 1) {
        //开启-显示群活跃等级
        NSString *levelStr = @"";
        if (role == 3) {
            groupRoleLabelStr = @"";
            self.groupRoleLabel.hidden = YES;
        } else {
            for (NoaGroupActivityLevelModel *levelConfigInfo in activityInfo.sortLevels) {
                if (activityScore >= levelConfigInfo.minScore) {
                    levelStr = [NSString isNil:levelConfigInfo.alias] ? levelConfigInfo.level : levelConfigInfo.alias;
                }
            }
            self.groupRoleLabel.hidden = NO;
            groupRoleLabelStr = [NSString stringWithFormat:@"%@%@", levelStr, roleContent];
        }
    } else {
        //关闭-隐藏群活跃等级
        groupRoleLabelStr = roleContent;
        if (role == 1 || role == 2) {
            self.groupRoleLabel.hidden = NO;
        } else {
            self.groupRoleLabel.hidden = YES;
        }
    }
    
    if (![NSString isNil:groupRoleLabelStr]) {
        self.groupRoleLabel.text = groupRoleLabelStr;
        CGSize roleTextSize = [groupRoleLabelStr sizeWithFont:FONTR(10) constrainedToSize:CGSizeMake(10000, DWScale(16))];
        [self.groupRoleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_ivHeader);
            make.width.mas_equalTo(roleTextSize.width + DWScale(20));
            make.height.mas_equalTo(DWScale(16));
            make.trailing.equalTo(self.contentView).offset(DWScale(-16));
        }];
        
        [_lblUserName mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(_ivHeader.mas_trailing).offset(DWScale(10));
            make.centerY.equalTo(_ivHeader);
            make.height.mas_equalTo(DWScale(22));
            make.trailing.mas_equalTo(self.groupRoleLabel.mas_leading).offset(DWScale(-10));
        }];
    } else {
        [_lblUserName mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(_ivHeader.mas_trailing).offset(DWScale(10));
            make.centerY.equalTo(_ivHeader);
            make.height.mas_equalTo(DWScale(22));
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(DWScale(-10));
        }];
    }
}

@end
