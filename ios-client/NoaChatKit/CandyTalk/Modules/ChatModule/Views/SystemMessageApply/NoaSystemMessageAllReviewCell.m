//
//  NoaSystemMessageAllReviewCell.m
//  NoaKit
//
//  Created by Candy on 2023/5/10.
//

#import "NoaSystemMessageAllReviewCell.h"
//#import <YYText/NSAttributedString+YYText.h>
//#import <YYText/YYLabel.h>

@interface NoaSystemMessageAllReviewCell()

@property (nonatomic, strong)UIView *bgView;
@property (nonatomic, strong)UIImageView *profileImgView;
@property (nonatomic, strong)UILabel *userRoleName;//用户角色名称
@property (nonatomic, strong)YYLabel *contentLbl;
@property (nonatomic, strong)UILabel *groupInfoLbl;
@property (nonatomic, strong)UIView *postscriptBgView;
@property (nonatomic, strong)UILabel *postscriptLbl;
@property (nonatomic, strong)UIButton *refuseBtn;
@property (nonatomic, strong)UIButton *agreeBtn;
@property (nonatomic, strong)UILabel *statusLbl;

@end


@implementation NoaSystemMessageAllReviewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
        self.contentView.userInteractionEnabled = YES;
        [self setupUI];
    }
    return self;
}
#pragma mark - UI
- (void)setupUI {
    [self.contentView addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(DWScale(16));
        make.leading.equalTo(self.contentView).offset(DWScale(16));
        make.trailing.equalTo(self.contentView).offset(DWScale(-16));
        make.bottom.equalTo(self.contentView);
    }];
    
    [self.bgView addSubview:self.profileImgView];
    [self.profileImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(self.bgView).offset(DWScale(10));
        make.width.mas_equalTo(DWScale(40));
        make.height.mas_equalTo(DWScale(40));
    }];
    
    [self.bgView addSubview:self.userRoleName];
    [self.userRoleName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.profileImgView).offset(-DWScale(1));
        make.trailing.equalTo(self.profileImgView).offset(DWScale(1));
        make.bottom.equalTo(self.profileImgView);
        make.height.mas_equalTo(DWScale(14));
    }];
    
    [self.bgView addSubview:self.contentLbl];
    [self.contentLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView).offset(DWScale(7));
        make.leading.equalTo(self.profileImgView.mas_trailing).offset(DWScale(10));
        make.trailing.equalTo(self.bgView).offset(DWScale(-19));
    }];
    
    [self.bgView addSubview:self.groupInfoLbl];
    [self.groupInfoLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentLbl.mas_bottom).offset(DWScale(3));
        make.leading.trailing.equalTo(self.contentLbl);
    }];
    
    [self.bgView addSubview:self.postscriptBgView];
    [self.postscriptBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.profileImgView.mas_bottom).offset(DWScale(9));
        make.leading.equalTo(self.profileImgView);
        make.trailing.equalTo(self.contentLbl);
        make.bottom.equalTo(self.bgView).offset(DWScale(-51));
    }];
    
    [self.postscriptBgView addSubview:self.postscriptLbl];
    [self.postscriptLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.postscriptBgView).offset(DWScale(10));
        make.leading.equalTo(self.postscriptBgView).offset(DWScale(10));
        make.trailing.equalTo(self.postscriptBgView).offset(DWScale(-10));
        make.bottom.equalTo(self.postscriptBgView).offset(DWScale(-10));
    }];
    
    [self.bgView addSubview:self.statusLbl];
    [self.statusLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.bgView).offset(DWScale(-19));
        make.top.equalTo(self.postscriptBgView.mas_bottom).offset(DWScale(12));
        make.width.mas_equalTo(DWScale(44));
        make.height.mas_equalTo(DWScale(20));
    }];
    
    [self.bgView addSubview:self.agreeBtn];
    [self.agreeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.bgView).offset(DWScale(-19));
        make.top.equalTo(self.postscriptBgView.mas_bottom).offset(DWScale(13));
        make.width.mas_equalTo(DWScale(44));
        make.height.mas_equalTo(DWScale(25));
    }];
    
    [self.bgView addSubview:self.refuseBtn];
    [self.refuseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.agreeBtn.mas_leading).offset(DWScale(-12));
        make.centerY.equalTo(self.agreeBtn);
        make.width.mas_equalTo(DWScale(44));
        make.height.mas_equalTo(DWScale(25));
    }];
}

#pragma mark - Model && Setter
- (void)setFromType:(ZGroupHelperFormType)fromType {
    _fromType = fromType;
    if (_fromType == ZGroupHelperFormTypeSessionList) {
        [self.contentLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bgView).offset(DWScale(7));
            make.leading.equalTo(self.profileImgView.mas_trailing).offset(DWScale(10));
            make.trailing.equalTo(self.bgView).offset(DWScale(-19));
        }];
    
        [self.groupInfoLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentLbl.mas_bottom).offset(DWScale(3));
            make.leading.trailing.equalTo(self.contentLbl);
        }];
    }
    if (_fromType == ZGroupHelperFormTypeGroupManager) {
        [self.contentLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.profileImgView);
            make.leading.equalTo(self.profileImgView.mas_trailing).offset(DWScale(10));
            make.trailing.equalTo(self.bgView).offset(DWScale(-19));
        }];
        
        [self.groupInfoLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentLbl.mas_bottom);
            make.leading.trailing.equalTo(self.contentLbl);
            make.height.mas_equalTo(0);
        }];
    }
}
- (void)setModel:(NoaSystemMessageModel *)model {
    _model = model;
    
    //头像
    [self.profileImgView sd_setImageWithURL:[_model.beUserAvatarFileName getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];    
    NSString *roleName = [UserManager matchUserRoleConfigInfo:model.roleId disableStatus:0];
    if ([NSString isNil:roleName]) {
        self.userRoleName.hidden = YES;
    } else {
        self.userRoleName.hidden = NO;
        self.userRoleName.text = roleName;
    }
    
    //xxx邀请xxx进群
    WeakSelf
    NSString *applyUserNick = _model.beInviteNickname;
    NSString *applyedUserNick = _model.userNickName;
    NSString *contentText = [NSString stringWithFormat:LanguageToolMatch(@"%@邀请%@进群"), applyUserNick, applyedUserNick];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:contentText];
    [text configAttStrLightColor:COLOR_11 darkColor:COLOR_11_DARK range:NSMakeRange(0, contentText.length)];
    //适配暗黑模式
    UIColor *color;
    if ([TKThemeManager config].themeIndex == 0) {
        color = COLOR_11;
    } else {
        color = COLOR_11_DARK;
    }
    [text yy_setTextHighlightRange:[contentText rangeOfString:applyUserNick] color:color backgroundColor:COLOR_CLEAR tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        //跳转到邀请用户个人主页
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(systemMessageCellClickNickNameAction:)]) {
            [weakSelf.delegate systemMessageCellClickNickNameAction:weakSelf.model.beInviteUserId];
        }
    }];
    [text yy_setTextHighlightRange:[contentText rangeOfString:applyedUserNick] color:COLOR_5966F2 backgroundColor:COLOR_CLEAR tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        //跳转到被邀请用户个人主页
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(systemMessageCellClickNickNameAction:)]) {
            [weakSelf.delegate systemMessageCellClickNickNameAction:weakSelf.model.userUid];
        }
    }];
    [text addAttribute:NSFontAttributeName value:FONTN(16) range:NSMakeRange(0, contentText.length)];
    self.contentLbl.attributedText = text;
    
    //群名信息
    if (self.fromType == ZGroupHelperFormTypeSessionList) {
        NSString *groupName = _model.groupId;
        LingIMGroupModel *groupInfoModel = [IMSDKManager toolCheckMyGroupWith:_model.groupId];
        if (groupInfoModel) {
            groupName = groupInfoModel.groupName;
        }
        NSString *groupInfoContent = [NSString stringWithFormat:LanguageToolMatch(@"申请加入%@"), groupName];
        NSMutableAttributedString *groupInfoAtt = [[NSMutableAttributedString alloc] initWithString:groupInfoContent];
        groupInfoAtt.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
            UIColor *color = nil;
            if (themeIndex == 0) {
                color = COLOR_11;
            } else {
                color = COLOR_11_DARK;
            }
            [(NSMutableAttributedString *)itself addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, groupInfoContent.length)];
        };
        [groupInfoAtt configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 fullStr:groupInfoContent appointStr:groupName];
        self.groupInfoLbl.attributedText = groupInfoAtt;
    }
    //附言
    if ([NSString isNil:_model.beDesc]) {
        self.postscriptBgView.hidden = YES;
        [self.postscriptLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.postscriptBgView).offset(DWScale(10));
            make.leading.equalTo(self.postscriptBgView).offset(DWScale(10));
            make.trailing.equalTo(self.postscriptBgView).offset(DWScale(-10));
            make.bottom.equalTo(self.postscriptBgView).offset(DWScale(-10));
            make.height.mas_equalTo(0);
        }];
    } else {
        self.postscriptBgView.hidden = NO;
        [self.postscriptLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.postscriptBgView).offset(DWScale(10));
            make.leading.equalTo(self.postscriptBgView).offset(DWScale(10));
            make.trailing.equalTo(self.postscriptBgView).offset(DWScale(-10));
            make.bottom.equalTo(self.postscriptBgView).offset(DWScale(-10));
        }];
        self.postscriptLbl.text = [NSString stringWithFormat:LanguageToolMatch(@"附言:%@"), ![NSString isNil:_model.beDesc] ? _model.beDesc : @""];
    }
    
    //状态  1：申请  4:已进群  5:已拒绝
    switch (_model.beStatus) {
        case 1: //申请
        {
            self.statusLbl.hidden = YES;
            self.refuseBtn.hidden = NO;
            self.agreeBtn.hidden = NO;
        }
            break;
        case 4: //已进群（已同意）
        {
            self.statusLbl.hidden = NO;
            self.statusLbl.text = LanguageToolMatch(@"已同意");
            self.statusLbl.tkThemetextColors = @[COLOR_5966F2, COLOR_5966F2];
            self.refuseBtn.hidden = YES;
            self.agreeBtn.hidden = YES;
        }
            break;
        case 5: //已拒绝
        {
            self.statusLbl.hidden = NO;
            self.statusLbl.text = LanguageToolMatch(@"已拒绝");
            self.statusLbl.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
            self.refuseBtn.hidden = YES;
            self.agreeBtn.hidden = YES;
        }
            break;
            
        default:
            //未知
            self.statusLbl.hidden = NO;
            self.statusLbl.text = LanguageToolMatch(@"未知");
            self.statusLbl.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
            self.refuseBtn.hidden = YES;
            self.agreeBtn.hidden = YES;
            break;
    }
}

#pragma mark - Action
- (void)beInviteUserAvatarTap {
    if (self.delegate && [self.delegate respondsToSelector:@selector(systemMessageCellClickNickNameAction:)]) {
        [self.delegate systemMessageCellClickNickNameAction:self.model.beInviteUserId];
    }
}

- (void)refuseBtnAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(refuseSystemMessageAllReviewAction:)]) {
        [self.delegate refuseSystemMessageAllReviewAction:self.baseCellIndexPath];
    }
}

- (void)agreeBtnAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(agreeSystemMessageAllReviewAgreeAction:)]) {
        [self.delegate agreeSystemMessageAllReviewAgreeAction:self.baseCellIndexPath];
    }
}

#pragma amrk - Lazy
- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
        _bgView.userInteractionEnabled = YES;
        [_bgView rounded:14];
    }
    return _bgView;
}

- (UIImageView *)profileImgView {
    if (!_profileImgView) {
        _profileImgView = [[UIImageView alloc] init];
        _profileImgView.userInteractionEnabled = YES;
        _profileImgView.image = DefaultAvatar;
        [_profileImgView rounded:DWScale(20)];
        
        UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beInviteUserAvatarTap)];
        [_profileImgView addGestureRecognizer:avatarTap];
    }
    return _profileImgView;
}

- (UILabel *)userRoleName {
    if (!_userRoleName) {
        _userRoleName = [UILabel new];
        _userRoleName.text = @"";
        _userRoleName.tkThemetextColors = @[COLORWHITE, COLORWHITE];
        _userRoleName.font = FONTN(7);
        _userRoleName.tkThemebackgroundColors = @[COLOR_EAB243, COLOR_EAB243_DARK];
        _userRoleName.textAlignment = NSTextAlignmentCenter;
        [_userRoleName rounded:DWScale(14)/2];
        _userRoleName.hidden = YES;

    }
    return _userRoleName;
}

- (YYLabel *)contentLbl {
    if (!_contentLbl) {
        _contentLbl = [[YYLabel alloc] init];
        _contentLbl.font = FONTN(14);
        _contentLbl.userInteractionEnabled = YES;
        _contentLbl.numberOfLines = 0;
        _contentLbl.lineBreakMode = NSLineBreakByCharWrapping;
        _contentLbl.preferredMaxLayoutWidth = DWScale(264);
    }
    return _contentLbl;
}

- (UILabel *)groupInfoLbl {
    if (!_groupInfoLbl) {
        _groupInfoLbl = [[UILabel alloc] init];
        _groupInfoLbl.font = FONTN(12);
        _groupInfoLbl.numberOfLines = 0;
        _groupInfoLbl.lineBreakMode = NSLineBreakByCharWrapping;
        _groupInfoLbl.preferredMaxLayoutWidth = DWScale(264);
    }
    return _groupInfoLbl;
}

- (UIView *)postscriptBgView {
    if (!_postscriptBgView) {
        _postscriptBgView = [[UIView alloc] init];
        _postscriptBgView.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
        [_postscriptBgView rounded:4 width:0.8 color:COLOR_EEEEEE];
    }
    return _postscriptBgView;
}

- (UILabel *)postscriptLbl {
    if (!_postscriptLbl) {
        _postscriptLbl = [[UILabel alloc] init];
        _postscriptLbl.text = @"";
        _postscriptLbl.font = FONTN(12);
        _postscriptLbl.numberOfLines = 0;
        _postscriptLbl.lineBreakMode = NSLineBreakByCharWrapping;
        _postscriptLbl.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    }
    return _postscriptLbl;
}

- (UILabel *)statusLbl {
    if (!_statusLbl) {
        _statusLbl = [[UILabel alloc] init];
        _statusLbl.text = @"";
        _statusLbl.font = FONTN(12);
        _statusLbl.textAlignment = NSTextAlignmentCenter;
        _statusLbl.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    }
    return _statusLbl;
}

- (UIButton *)refuseBtn {
    if (!_refuseBtn) {
        _refuseBtn = [[UIButton alloc] init];
        [_refuseBtn setTitle:LanguageToolMatch(@"拒绝") forState:UIControlStateNormal];
        [_refuseBtn setTkThemeTitleColor:@[COLOR_99, COLOR_99_DARK] forState:UIControlStateNormal];
        _refuseBtn.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
        UIColor *boardColor;
        if ([TKThemeManager config].themeIndex == 0) {
            boardColor = COLOR_99;
        } else {
            boardColor = COLOR_99_DARK;
        }
        [_refuseBtn rounded:DWScale(25)/2 width:1 color:boardColor];
        _refuseBtn.titleLabel.font = FONTN(12);
        [_refuseBtn addTarget:self action:@selector(refuseBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refuseBtn;
}

- (UIButton *)agreeBtn {
    if (!_agreeBtn) {
        _agreeBtn = [[UIButton alloc] init];
        [_agreeBtn setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
        [_agreeBtn setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
        _agreeBtn.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
        [_agreeBtn rounded:DWScale(25)/2];
        _agreeBtn.titleLabel.font = FONTN(12);
        [_agreeBtn addTarget:self action:@selector(agreeBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _agreeBtn;
}

#pragma mark - Other
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
