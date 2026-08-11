//
//  NoaChatMultiSelectCell.m
//  NoaKit
//
//  Created by Candy on 2023/4/12.
//

#import "NoaChatMultiSelectCell.h"
#import "NoaBaseImageView.h"
//#import <YYText/YYText.h>

@interface NoaChatMultiSelectCell ()

@property (nonatomic, strong)UIImageView *checkBoxImgView;
@property (nonatomic, strong) NoaBaseImageView *ivHeader;//头像
@property (nonatomic, strong) UILabel *ivUserRoleName;//用户角色名称
@property (nonatomic, strong) YYLabel *lblName;//昵称、备注
@property (nonatomic, strong) id model;
@property (nonatomic, strong) NSIndexPath *cellIndex;
@property (nonatomic, copy) NSString *searchStr;

@end

@implementation NoaChatMultiSelectCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        self.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    _checkBoxImgView = [[UIImageView alloc] init];
    _checkBoxImgView.image = ImgNamed(@"checkbox_unselected");
    [self.contentView addSubview:_checkBoxImgView];
    [_checkBoxImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(18), DWScale(18)));
    }];
    
    _ivHeader = [NoaBaseImageView new];
    _ivHeader.layer.cornerRadius = DWScale(22);
    _ivHeader.layer.masksToBounds = YES;
    [self.contentView addSubview:_ivHeader];
    [_ivHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(_checkBoxImgView.mas_trailing).offset(DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(44), DWScale(44)));
    }];
    
    _ivUserRoleName = [UILabel new];
    _ivUserRoleName.text = @"";
    _ivUserRoleName.tkThemetextColors = @[COLORWHITE, COLORWHITE];
    _ivUserRoleName.font = FONTN(7);
    _ivUserRoleName.tkThemebackgroundColors = @[COLOR_EAB243, COLOR_EAB243_DARK];
    _ivUserRoleName.textAlignment = NSTextAlignmentCenter;
    [_ivUserRoleName rounded:DWScale(15.4)/2];
    _ivUserRoleName.hidden = YES;
    [self.contentView addSubview:_ivUserRoleName];
    [_ivUserRoleName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_ivHeader).offset(-DWScale(1));
        make.trailing.equalTo(_ivHeader).offset(DWScale(1));
        make.bottom.equalTo(_ivHeader);
        make.height.mas_equalTo(DWScale(15.4));
    }];
    
    _lblName = [YYLabel new];
    [self.contentView addSubview:_lblName];
    [_lblName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(_ivHeader.mas_trailing).offset(DWScale(10));
        make.trailing.equalTo(self.contentView).offset(-DWScale(16));
    }];
    
}

+ (CGFloat)defaultCellHeight {
    return DWScale(68);
}

- (void)configModelWith:(id)model indexPath:(NSIndexPath *)cellIndex searchStr:(NSString  * _Nullable )searchStr{
    if (model) {
        _model = model;
        _cellIndex = cellIndex;
        _searchStr = searchStr;
        if (searchStr.length <= 0) {
            if (cellIndex.section == 0) {
                //最近会话
                LingIMSessionModel *sessionModel = (LingIMSessionModel *)model;
                [self updateSessionUIWith:sessionModel];
            }
        } else {
            if (cellIndex.section == 0) {
                //联系人
                LingIMFriendModel *friendModel = (LingIMFriendModel *)model;
                [self updateContactUIWith:friendModel];
            } else if (cellIndex.section == 1) {
               //群聊
               LingIMGroupModel *groupModel = (LingIMGroupModel *)model;
               [self updateGroupUIWith:groupModel];
           }
        }
    }
}

- (void)updateSessionUIWith:(LingIMSessionModel *)sessionModel {
    //选中/未选中
    _checkBoxImgView.image = sessionModel.isSelected ? ImgNamed(@"checkbox_selected") : ImgNamed(@"checkbox_unselected");
    
    NSString *avatarUrl;
    NSString *nameTitle;
    if (sessionModel.sessionType == CIMSessionTypeSingle) {
        //单聊
        LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:sessionModel.sessionID];
        if (friendModel) {
            avatarUrl = [NSString loadAvatarWithUserStatus:friendModel.disableStatus avatarUri:friendModel.avatar];
            nameTitle = [NSString loadNickNameWithUserStatus:friendModel.disableStatus realNickName:sessionModel.sessionName];
            
            if ([friendModel.friendUserUID isEqualToString:@"100002"]) {
                //文件助手
                _ivUserRoleName.hidden = YES;
            } else {
                NSString *roleName = [UserManager matchUserRoleConfigInfo:friendModel.roleId disableStatus:friendModel.disableStatus];
                if ([NSString isNil:roleName]) {
                    _ivUserRoleName.hidden = YES;
                } else {
                    _ivUserRoleName.hidden = NO;
                    _ivUserRoleName.text = roleName;
                }
            }
        }else {
            avatarUrl = [NSString loadAvatarWithUserStatus:0 avatarUri:sessionModel.sessionAvatar];
            nameTitle = sessionModel.sessionName;
            
            if ([sessionModel.sessionID isEqualToString:@"100002"]) {
                //文件助手
                _ivUserRoleName.hidden = YES;
            } else {
                NSString *roleName = [UserManager matchUserRoleConfigInfo:sessionModel.roleId disableStatus:0];
                if ([NSString isNil:roleName]) {
                    _ivUserRoleName.hidden = YES;
                } else {
                    _ivUserRoleName.hidden = NO;
                    _ivUserRoleName.text = roleName;
                }
            }
        }
        if ([friendModel.friendUserUID isEqualToString:@"100002"]) {
            _ivHeader.image = ImgNamed(@"session_file_helper_logo");
        } else {
            [_ivHeader loadAvatarWithUserImgContent:avatarUrl defaultImg:DefaultAvatar];
        }
    } else if (sessionModel.sessionType == CIMSessionTypeGroup) {
        _ivUserRoleName.hidden = YES;
        avatarUrl = [NSString loadAvatarWithUserStatus:0 avatarUri:sessionModel.sessionAvatar];
        [_ivHeader loadAvatarWithUserImgContent:avatarUrl defaultImg:DefaultGroup];
        nameTitle = sessionModel.sessionName;
    }
    
    NSMutableAttributedString *attStrName = [[NSMutableAttributedString alloc] initWithString:nameTitle == nil ? @"" : nameTitle];
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
    _lblName.attributedText = attStrName;
}
- (void)updateContactUIWith:(LingIMFriendModel *)friendModel {
    //选中/未选中
    _checkBoxImgView.image = friendModel.isSelected ? ImgNamed(@"checkbox_selected") : ImgNamed(@"checkbox_unselected");
    
    //头像
    [_ivHeader sd_setImageWithURL:[friendModel.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
    
    //搜索
    __block NSMutableAttributedString *attStrName = [[NSMutableAttributedString alloc] initWithString:friendModel.nickname];
    NSRange rangeName = [friendModel.nickname rangeOfString:_searchStr options:NSCaseInsensitiveSearch];//不区分大小写
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
    
    [attStrName yy_setFont:FONTR(16) range:rangeName];
    [attStrName yy_setColor:COLOR_5966F2 range:rangeName];
    _lblName.attributedText = attStrName;
}

- (void)updateGroupUIWith:(LingIMGroupModel *)groupModel {
    //选中/未选中
    _checkBoxImgView.image = groupModel.isSelected ? ImgNamed(@"checkbox_selected") : ImgNamed(@"checkbox_unselected");
    //头像
    [_ivHeader sd_setImageWithURL:[groupModel.groupAvatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
    
    //搜索
    __block NSMutableAttributedString *attStrName = [[NSMutableAttributedString alloc] initWithString:groupModel.groupName];
    NSRange rangeName = [groupModel.groupName rangeOfString:_searchStr options:NSCaseInsensitiveSearch];//不区分大小写
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
    
    [attStrName yy_setFont:FONTR(16) range:rangeName];
    [attStrName yy_setColor:COLOR_5966F2 range:rangeName];
    _lblName.attributedText = attStrName;
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
