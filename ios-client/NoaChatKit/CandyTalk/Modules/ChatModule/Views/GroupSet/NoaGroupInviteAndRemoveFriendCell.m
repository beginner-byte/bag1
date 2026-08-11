//
//  NoaGroupInviteAndRemoveFriendCell.m
//  NoaKit
//
//  Created by Candy on 2026/11/9.
//

#import "NoaGroupInviteAndRemoveFriendCell.h"
#import "NoaBaseImageView.h"
//#import <YYText/YYText.h>
@interface NoaGroupInviteAndRemoveFriendCell ()
@property (nonatomic,strong)UIButton * viewBg;//背景按钮
@property (nonatomic, strong) UIImageView *ivSelect;//选中
@property (nonatomic, strong) NoaBaseImageView *ivHeader;//头像
@property (nonatomic, strong) UILabel *lblUserRoleName;//用户角色名称
@property (nonatomic, strong) UILabel *lblName;//昵称、备注

@property (nonatomic, strong) LingIMGroupMemberModel *userFriendModel;
@end

@implementation NoaGroupInviteAndRemoveFriendCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
        self.contentView.backgroundColor = UIColor.clearColor;
        self.backgroundColor = UIColor.clearColor;
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    
    _viewBg = [[UIButton alloc] init];
    _viewBg.frame = CGRectMake(0, 0, DScreenWidth , DWScale(60));
    _viewBg.tkThemebackgroundColors =  @[COLORWHITE, COLOR_11];
    [_viewBg setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE]] forState:UIControlStateSelected];
    [_viewBg setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE]] forState:UIControlStateHighlighted];
    [_viewBg addTarget:self action:@selector(cellTouchAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_viewBg];
    
    _ivSelect = [[UIImageView alloc] initWithImage:ImgNamed(@"c_select_no")];
    [self.contentView addSubview:_ivSelect];
    [_ivSelect mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(18), DWScale(18)));
    }];
    
    _ivHeader = [[NoaBaseImageView alloc] initWithImage:DefaultAvatar];
    _ivHeader.layer.cornerRadius = DWScale(22);
    _ivHeader.layer.masksToBounds = YES;
    [self.contentView addSubview:_ivHeader];
    [_ivHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(_ivSelect.mas_trailing).offset(DWScale(16));
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
    
    _lblName = [UILabel new];
    _lblName.text = LanguageToolMatch(@"备注/昵称");
    _lblName.font = FONTR(16);
    _lblName.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [self.contentView addSubview:_lblName];
    [_lblName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(_ivHeader.mas_trailing).offset(DWScale(10));
        make.trailing.equalTo(self.contentView).offset(-DWScale(10));
    }];
    
}
+ (CGFloat)defaultCellHeight {
    return DWScale(60);
}
#pragma mark - 交互事件
- (void)cellTouchAction {
    if ([self.baseDelegate respondsToSelector:@selector(cellClickAction:)]) {
        [self.baseDelegate cellClickAction:self.baseCellIndexPath];
    }
}

#pragma mark - 数据赋值
- (void)cellConfigWith:(LingIMGroupMemberModel *)model search:(NSString *)searchStr {
    if (model) {
        _userFriendModel = model;
        
        [_ivHeader sd_setImageWithURL:[model.userAvatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
        //角色名称
        NSString *roleName = [UserManager matchUserRoleConfigInfo:model.roleId disableStatus:model.disableStatus];
        if ([NSString isNil:roleName]) {
            _lblUserRoleName.hidden = YES;
        } else {
            _lblUserRoleName.hidden = NO;
            _lblUserRoleName.text = roleName;
        }
        
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
        _lblName.attributedText = attStrName;
    }
}

- (void)setSelectedUser:(NSInteger)selectedUser {
    _selectedUser = selectedUser;
    switch (selectedUser) {
        case 1:
        {
            //已经在群组中，不可选择状态
            _ivSelect.image = ImgNamed(@"c_select_unknow");
            [_viewBg setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLORWHITE],[UIImage ImageForColor:COLOR_11]] forState:UIControlStateSelected];
            [_viewBg setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLORWHITE],[UIImage ImageForColor:COLOR_11]] forState:UIControlStateHighlighted];
        }
            break;
        case 2:
        {
            //选中状态
            _ivSelect.image = ImgNamed(@"c_select_yes");
            [_viewBg setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE]] forState:UIControlStateSelected];
            [_viewBg setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE]] forState:UIControlStateHighlighted];
        }
            break;
        case 3:
        {
            //未选中状态
            _ivSelect.image = ImgNamed(@"c_select_no");
            [_viewBg setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE]] forState:UIControlStateSelected];
            [_viewBg setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE]] forState:UIControlStateHighlighted];
        }
            break;
            
        default:
            break;
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
