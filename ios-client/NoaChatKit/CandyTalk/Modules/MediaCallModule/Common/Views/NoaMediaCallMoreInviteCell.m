//
//  NoaMediaCallMoreInviteCell.m
//  NoaKit
//
//  Created by Candy on 2023/2/6.
//

#import "NoaMediaCallMoreInviteCell.h"
//#import <YYText/YYText.h>

@interface NoaMediaCallMoreInviteCell ()
@property (nonatomic, strong) UIImageView *ivCycle;
@property (nonatomic, strong) UIImageView *ivHeader;
@property (nonatomic, strong) UILabel *ivRoleName;//用户角色名称
@property (nonatomic, strong) UILabel *lblNickname;
@end

@implementation NoaMediaCallMoreInviteCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    self.contentView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    
    [self.contentView addSubview:self.baseContentButton];
    self.baseContentButton.frame = CGRectMake(0, 0, DScreenWidth, DWScale(68));
    
    //c_select_no c_select_unknow c_select_yes
    _ivCycle = [[UIImageView alloc] initWithImage:ImgNamed(@"c_select_no")];
    [self.contentView addSubview:_ivCycle];
    [_ivCycle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(18), DWScale(18)));
    }];
    
    _ivHeader = [[UIImageView alloc] initWithImage:DefaultAvatar];
    _ivHeader.layer.cornerRadius = DWScale(22);
    _ivHeader.layer.masksToBounds = YES;
    [self.contentView addSubview:_ivHeader];
    [_ivHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(_ivCycle.mas_trailing).offset(DWScale(16));
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

    
    _lblNickname = [UILabel new];
    _lblNickname.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _lblNickname.font = FONTR(16);
    [self.contentView addSubview:_lblNickname];
    [_lblNickname mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(_ivHeader.mas_trailing).offset(DWScale(16));
        make.trailing.equalTo(self.contentView).offset(-DWScale(16));
    }];
    
    
}
#pragma mark - 渲染赋值
- (void)configCellWith:(LingIMGroupMemberModel *)groupMemberModel searchString:(NSString *)searchStr selected:(ZMediaCallMoreInviteCellSelectedType)selectedType {
    if (!groupMemberModel) return;
    
    _groupMemberModel = groupMemberModel;
    _searchStr = searchStr;
    _selectedType = selectedType;
    
    switch (selectedType) {
        case ZMediaCallMoreInviteCellSelectedTypeDefault:
            _ivCycle.image = ImgNamed(@"c_select_unknow");
            break;
        case ZMediaCallMoreInviteCellSelectedTypeNo:
            _ivCycle.image = ImgNamed(@"c_select_no");
            break;
        case ZMediaCallMoreInviteCellSelectedTypeYes:
            _ivCycle.image = ImgNamed(@"c_select_yes");
            break;
            
        default:
            break;
    }
    
    [_ivHeader sd_setImageWithURL:[groupMemberModel.userAvatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
    if (groupMemberModel.disableStatus == 4) {
        _ivRoleName.hidden = YES;
    } else {
        //角色名称
        NSString *roleName = [UserManager matchUserRoleConfigInfo:groupMemberModel.roleId disableStatus:groupMemberModel.disableStatus];
        if ([NSString isNil:roleName]) {
            _ivRoleName.hidden = YES;
        } else {
            _ivRoleName.hidden = NO;
            _ivRoleName.text = roleName;
        }
    }
    
    __block NSMutableAttributedString *attStrName = [[NSMutableAttributedString alloc] initWithString:groupMemberModel.showName];
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
        NSRange rangeName = [groupMemberModel.showName rangeOfString:searchStr options:NSCaseInsensitiveSearch];//不区分大小写
        [attStrName yy_setFont:FONTR(16) range:rangeName];
        [attStrName yy_setColor:COLOR_5966F2 range:rangeName];
    }
    _lblNickname.attributedText = attStrName;
    
}

+ (CGFloat)defaultCellHeight {
    return DWScale(68);
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
