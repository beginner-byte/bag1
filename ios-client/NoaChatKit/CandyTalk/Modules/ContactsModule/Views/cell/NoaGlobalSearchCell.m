//
//  NoaGlobalSearchCell.m
//  NoaKit
//
//  Created by Candy on 2026/9/14.
//

#import "NoaGlobalSearchCell.h"
#import "NoaBaseImageView.h"
//#import <YYText/YYText.h>

@interface NoaGlobalSearchCell ()
@property (nonatomic, strong) NoaBaseImageView *ivHeader;
@property (nonatomic, strong) UILabel *lblUserRoleName;//用户角色名称
@property (nonatomic, strong) YYLabel *lblTitle;//主标题
@property (nonatomic, strong) YYLabel *lblTitleSub;//子标题

@property (nonatomic, strong) NSIndexPath *cellIndexPath;
@property (nonatomic, strong) id cellModel;
@property (nonatomic, copy) NSString *searchStr;
@end

@implementation NoaGlobalSearchCell
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
    _ivHeader = [[NoaBaseImageView alloc] initWithFrame:CGRectMake(DWScale(16), DWScale(12), DWScale(44), DWScale(44))];
    _ivHeader.layer.cornerRadius = DWScale(22);
    _ivHeader.layer.masksToBounds = YES;
    [self.contentView addSubview:_ivHeader];
    [_ivHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading).offset(DWScale(16));
        make.top.equalTo(self.mas_top).offset(DWScale(12));
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
    
    _lblTitle = [YYLabel new];
    _lblTitle.text = @"主标题";
    _lblTitle.font = FONTR(16);
    [self.contentView addSubview:_lblTitle];
    
    _lblTitleSub = [YYLabel new];
    _lblTitleSub.text = @"子标题";
    _lblTitleSub.font = FONTR(14);
    [self.contentView addSubview:_lblTitleSub];
    
    WeakSelf
    self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        
        switch (themeIndex) {
            case 1:
            {
                //暗黑
                weakSelf.lblTitle.textColor = COLOR_11_DARK;
                weakSelf.lblTitleSub.textColor = COLOR_66_DARK;
            }
                break;
                
            default:
            {
                //浅色
                weakSelf.lblTitle.textColor = COLOR_11;
                weakSelf.lblTitleSub.textColor = COLOR_66;
            }
                break;
        }
        
    };
}

- (void)updateUIShowSubTitle:(BOOL)showSubTitle {
    _lblTitleSub.hidden = !showSubTitle;
    if (showSubTitle) {
        [_lblTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_ivHeader);
            make.leading.equalTo(_ivHeader.mas_trailing).offset(DWScale(10));
            make.trailing.equalTo(self).offset(-DWScale(16));
        }];
        
        [_lblTitleSub mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_ivHeader);
            make.leading.trailing.equalTo(_lblTitle);
        }];
    }else {
        [_lblTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_ivHeader.mas_trailing).offset(DWScale(10));
            make.trailing.equalTo(self).offset(-DWScale(16));
            make.centerY.equalTo(_ivHeader);
        }];
        
    }
    
}
+ (CGFloat)defaultCellHeight {
    return DWScale(68);
}
#pragma mark - 数据赋值
- (void)globalSearchConfigWith:(NSIndexPath *)cellIndex model:(id)model search:(NSString *)searchStr{
    _cellIndexPath = cellIndex;
    _cellModel = model;
    _searchStr = searchStr;
    
    //联系人
    if (cellIndex.section == 0 && [model isKindOfClass:[LingIMFriendModel class]]) {
        [self updateFriendUI];
    }
    //群聊
    if (cellIndex.section == 1 && [model isKindOfClass:[LingIMGroupModel class]]) {
        [self updateGroupUI];
    }
    //聊天记录
    if (cellIndex.section == 2 && [model isKindOfClass:[NoaIMChatMessageModel class]]) {
        [self updateHistoryMessageUI];
    }
    
    
}
- (void)updateFriendUI {
    [self updateUIShowSubTitle:YES];
    
    LingIMFriendModel *friendModel = (LingIMFriendModel *)_cellModel;
    
    if (friendModel.disableStatus == 4) {
        //已注销
        NSString *avatarUrl = [NSString loadAvatarWithUserStatus:friendModel.disableStatus avatarUri:friendModel.avatar];
        [_ivHeader loadAvatarWithUserImgContent:avatarUrl defaultImg:DefaultAvatar];
        _lblTitle.text = LanguageToolMatch(@"账号已注销");
        _lblTitleSub.text =  [NSString stringWithFormat:@"%@%@",LanguageToolMatch(@"账号："), @"-"];
        _lblUserRoleName.hidden = YES;
    } else {
        [_ivHeader sd_setImageWithURL:[friendModel.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
        //角色名称
        NSString *roleName = [UserManager matchUserRoleConfigInfo:friendModel.roleId disableStatus:friendModel.disableStatus];
        if ([NSString isNil:roleName]) {
            _lblUserRoleName.hidden = YES;
        } else {
            _lblUserRoleName.hidden = NO;
            _lblUserRoleName.text = roleName;
        }
        
        NSString *titleContent;
        if(![NSString isNil:friendModel.remarks]){
            titleContent = [NSString stringWithFormat:LanguageToolMatch(@"%@ (%@)"), friendModel.remarks, friendModel.nickname];
        }else{
            titleContent = friendModel.nickname;
        }
        
        __block NSMutableAttributedString *attStrName = [[NSMutableAttributedString alloc] initWithString:titleContent];

        //NSRange rangeName = [titleContent rangeOfString:_searchStr options:NSCaseInsensitiveSearch];//不区分大小写
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
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:_searchStr options:0 error:nil];
        NSArray *matches = [regex matchesInString:titleContent options:0 range:NSMakeRange(0,titleContent.length)];
        for(NSTextCheckingResult *result in [matches objectEnumerator]) {
            NSRange matchRange = [result range];
            [attStrName yy_setFont:FONTR(16) range:matchRange];
            [attStrName yy_setColor:COLOR_5966F2 range:matchRange];
        }
        _lblTitle.attributedText = attStrName;
        
        NSString *subContent = [NSString stringWithFormat:LanguageToolMatch(@"账号：%@"),friendModel.userName];
        __block NSMutableAttributedString *subAttStrName = [[NSMutableAttributedString alloc] initWithString:subContent];

        NSRange subRangeName = [subContent rangeOfString:_searchStr options:NSCaseInsensitiveSearch];//不区分大小写
        subAttStrName.yy_font = FONTR(14);
        self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
            switch (themeIndex) {
                case 1:
                {
                    //暗黑
                    subAttStrName.yy_color = COLOR_66_DARK;
                }
                    break;
                    
                default:
                {
                    //浅色
                    subAttStrName.yy_color = COLOR_66;
                }
                    break;
            }
        };
        
        [subAttStrName yy_setFont:FONTR(14) range:subRangeName];
        [subAttStrName yy_setColor:COLOR_5966F2 range:subRangeName];
        _lblTitleSub.attributedText = subAttStrName;
    }
}

- (void)updateGroupUI {
    [self updateUIShowSubTitle:NO];
    
    LingIMGroupModel *groupModel = (LingIMGroupModel *)_cellModel;
    [_ivHeader sd_setImageWithURL:[groupModel.groupAvatar getImageFullUrl] placeholderImage:DefaultGroup options:SDWebImageAllowInvalidSSLCertificates];
    _lblUserRoleName.hidden = YES;
    
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
    _lblTitle.attributedText = attStrName;
}

- (void)updateHistoryMessageUI {
    [self updateUIShowSubTitle:YES];
    
    NoaIMChatMessageModel *historyMsgModel = (NoaIMChatMessageModel *)_cellModel;
    
    NSString *contentStr;
    if (historyMsgModel.chatType == CIMChatType_SingleChat) {
        if (historyMsgModel.messageType == CIMChatMessageType_FileMessage) {
            contentStr = historyMsgModel.showFileName;
        } else {
            contentStr = historyMsgModel.textContent;
        }
    }
    if (historyMsgModel.chatType == CIMChatType_GroupChat) {
        LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:historyMsgModel.fromID groupID:historyMsgModel.toID];
        
        if (historyMsgModel.messageType == CIMChatMessageType_FileMessage) {
            contentStr = [NSString stringWithFormat:@"%@: %@", [NSString loadNickNameWithUserStatus:groupMemberModel.disableStatus realNickName:historyMsgModel.fromNickname], historyMsgModel.showFileName];
        } else {
            contentStr = [NSString stringWithFormat:@"%@: %@", [NSString loadNickNameWithUserStatus:groupMemberModel.disableStatus realNickName:historyMsgModel.fromNickname], historyMsgModel.textContent];
        }
    }
    __block NSMutableAttributedString *attStrName = attStrName = [[NSMutableAttributedString alloc] initWithString:contentStr];
    
    NSRange rangeName = [contentStr rangeOfString:_searchStr options:NSCaseInsensitiveSearch];//不区分大小写
    attStrName.yy_font = FONTR(14);
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
    
    [attStrName yy_setFont:FONTR(14) range:rangeName];
    [attStrName yy_setColor:COLOR_5966F2 range:rangeName];
    _lblTitleSub.attributedText = attStrName;
    
    if (historyMsgModel.chatType == CIMChatType_SingleChat) {
        if ([historyMsgModel.toID isEqualToString:UserManager.userInfo.userUID]) {
            LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:historyMsgModel.fromID];
            if (friendModel.disableStatus == 4) {
                //已注销
                _lblTitle.text = [NSString loadNickNameWithUserStatus:friendModel.disableStatus realNickName:historyMsgModel.fromNickname];
                NSString *avatarUrl = [NSString loadAvatarWithUserStatus:friendModel.disableStatus avatarUri:friendModel.avatar];
                [_ivHeader loadAvatarWithUserImgContent:avatarUrl defaultImg:DefaultAvatar];
                _lblUserRoleName.hidden = YES;
            } else {
                _lblTitle.text = historyMsgModel.fromNickname;
                [_ivHeader sd_setImageWithURL:[historyMsgModel.fromIcon getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
                //角色名称
                NSString *roleName = [UserManager matchUserRoleConfigInfo:friendModel.roleId disableStatus:friendModel.disableStatus];
                if ([NSString isNil:roleName]) {
                    _lblUserRoleName.hidden = YES;
                } else {
                    _lblUserRoleName.hidden = NO;
                    _lblUserRoleName.text = roleName;
                }
            }
        } else {
            _lblTitle.text = historyMsgModel.fromNickname;
            [_ivHeader sd_setImageWithURL:[historyMsgModel.fromIcon getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
            //角色名称
            NSString *roleName = [UserManager matchUserRoleConfigInfo:UserManager.userInfo.roleId disableStatus:UserManager.userInfo.disableStatus];
            if ([NSString isNil:roleName]) {
                _lblUserRoleName.hidden = YES;
            } else {
                _lblUserRoleName.hidden = NO;
                _lblUserRoleName.text = roleName;
            }
        }
    }
    if (historyMsgModel.chatType == CIMChatType_GroupChat) {
        LingIMSessionModel *sessionModel = [IMSDKManager toolCheckMySessionWith:historyMsgModel.toID];
        _lblTitle.text = sessionModel.sessionName;
        [_ivHeader sd_setImageWithURL:[sessionModel.sessionAvatar getImageFullUrl] placeholderImage:DefaultGroup options:SDWebImageAllowInvalidSSLCertificates];
        _lblUserRoleName.hidden = YES;
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
