//
//  NoaSampleUserInfoView.m
//  NoaKit
//
//  Created by Candy on 2026/9/13.
//

#import "NoaSampleUserInfoView.h"
#import "NoaToolManager.h"
#import "NoaChatViewController.h"
#import "NoaToolManager.h"
@interface NoaSampleUserInfoView ()
@property (nonatomic, strong) UIScrollView *bgScrollView;//背景滑动视图

/// 背景图片
@property (nonatomic, strong) UIImageView *bgImgView;

/// 头像
@property (nonatomic, strong) NoaBaseImageView *ivHeader;

/// 用户角色名称
@property (nonatomic, strong) UILabel *lblUserRoleName;

/// 用户昵称
@property (nonatomic, strong) UILabel *lblNickname;

/// 用户账号
@property (nonatomic, strong) UILabel *lblAccount;

@property (nonatomic, strong) UIButton *btnCopy;

@property (nonatomic, strong) UIView * remarkBgView;//备注背景视图
@property (nonatomic, strong) UILabel * remarkLabel;//底部显示备注label

@property (nonatomic, strong) UIView * desBgView;//描述背景视图
@property (nonatomic, strong) UILabel * desLabel;//底部显示描述

@property (nonatomic, strong) UIView * inGroupNickBgView;//在本群昵称视图
@property (nonatomic, strong) UILabel * groupNickLabel;//底部显示在本群昵称

@end

@implementation NoaSampleUserInfoView

- (UIImageView *)bgImgView {
    if (!_bgImgView) {
        _bgImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _bgImgView.image = ImgNamed(@"icon_userInfo_bg");
    }
    return _bgImgView;
}

/// 备注背景视图
- (UIView *)remarkBgView {
    if (!_remarkBgView) {
        _remarkBgView = [[UIView alloc] init];
        _remarkBgView.tkThemebackgroundColors = @[COLORWHITE, HEXCOLOR(@"27292E")];
        _remarkBgView.layer.cornerRadius = 16;
        _remarkBgView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
        _remarkBgView.layer.masksToBounds = YES;
        
        UIButton *setRemarkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        setRemarkBtn.tkThemebackgroundColors =  @[COLORWHITE, COLOR_11];
        [setRemarkBtn setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_CCCCCC_DARK]] forState:UIControlStateSelected];
        [setRemarkBtn setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_CCCCCC_DARK]] forState:UIControlStateHighlighted];
        
        [setRemarkBtn addTarget:self action:@selector(setRemarkBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_remarkBgView addSubview:setRemarkBtn];
        [setRemarkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.mas_equalTo(_remarkBgView);
        }];
        
        // 备注
        UILabel * remarkTipLabel = [UILabel new];
        remarkTipLabel.text = LanguageToolMatch(@"备注：");
        remarkTipLabel.tkThemetextColors = @[COLOR_11, COLORWHITE];
        remarkTipLabel.font = FONTR(16);
        [_remarkBgView addSubview:remarkTipLabel];
        CGFloat remarkTipLabelWidth = [remarkTipLabel.text widthForFont:remarkTipLabel.font];
        [remarkTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@0);
            make.leading.equalTo(@15);
            make.width.equalTo(@(remarkTipLabelWidth));
            make.bottom.equalTo(_remarkBgView);
        }];
        
        // 右侧箭头
        NSString *imgName = @"";
        if (TKThemeManager.config.themeIndex != 0) {
            imgName = @"mine_btn_next";
        }else {
            imgName = @"c_arrow_right_gray";
        }
        UIImageView * ivArrow = [[UIImageView alloc] initWithImage:ImgNamed(imgName)];
        [_remarkBgView addSubview:ivArrow];
        [ivArrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(remarkTipLabel);
            make.trailing.equalTo(_remarkBgView).offset(-15);
            make.width.equalTo(@12);
            make.height.equalTo(@12);
        }];
        
        // 备注内容
        _remarkLabel = [UILabel new];
        _remarkLabel.text = LanguageToolMatch(@"未设置备注");
        _remarkLabel.tkThemetextColors = @[COLOR_11, COLORWHITE];
        _remarkLabel.font = FONTR(14);
        _remarkLabel.textAlignment = NSTextAlignmentRight;
        [_remarkBgView addSubview:_remarkLabel];
        [_remarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(remarkTipLabel);
            make.leading.equalTo(remarkTipLabel.mas_trailing).offset(10);
            make.trailing.equalTo(ivArrow.mas_leading).offset(-10);
            make.height.equalTo(remarkTipLabel);
        }];
    }
    return _remarkBgView;
}

//描述背景视图
- (UIView *)desBgView {
    if (!_desBgView) {
        _desBgView = [[UIView alloc] init];
        _desBgView.tkThemebackgroundColors = @[COLORWHITE, HEXCOLOR(@"27292E")];
        _desBgView.layer.cornerRadius = 16;
        _desBgView.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
        _desBgView.layer.masksToBounds = YES;
        
        UIButton *setDesBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        setDesBtn.tkThemebackgroundColors =  @[COLORWHITE, COLOR_11];
        [setDesBtn setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_CCCCCC_DARK]] forState:UIControlStateSelected];
        [setDesBtn setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_CCCCCC_DARK]] forState:UIControlStateHighlighted];
        [setDesBtn addTarget:self action:@selector(setDesBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_desBgView addSubview:setDesBtn];
        [setDesBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.mas_equalTo(_desBgView);
        }];
        
        UIView * lineView = [UIView new];
        lineView.tkThemebackgroundColors = @[HEXCOLOR(@"EEF1FA") , [HEXCOLOR(@"EEF1FA") colorWithAlphaComponent:0.2]];
        [_desBgView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@0);
            make.leading.equalTo(@16);
            make.trailing.equalTo(_desBgView).offset(-16);
            make.height.equalTo(@0.5);
        }];
        
        // 描述
        _desLabel = [UILabel new];
        _desLabel.tkThemetextColors = @[COLOR_11, COLORWHITE];
        _desLabel.font = FONTR(14);
        _desLabel.numberOfLines = 0;
        [_desBgView addSubview:_desLabel];
        [_desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lineView).offset(12);
            make.leading.equalTo(@15);
            make.trailing.equalTo(_desBgView).offset(-16);
            make.bottom.equalTo(_desBgView.mas_bottom).offset(-12);
        }];
    }
    return _desBgView;
}

//在本群昵称背景视图
- (UIView *)inGroupNickBgView {
    if (!_inGroupNickBgView) {
        _inGroupNickBgView = [[UIView alloc] init];
        _inGroupNickBgView.tkThemebackgroundColors = @[COLORWHITE, HEXCOLOR(@"27292E")];
        _inGroupNickBgView.layer.cornerRadius = 16;
        _inGroupNickBgView.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
        _inGroupNickBgView.layer.masksToBounds = YES;
        
        UIView * lineView = [UIView new];
        lineView.tkThemebackgroundColors = @[HEXCOLOR(@"EEF1FA") , [HEXCOLOR(@"EEF1FA") colorWithAlphaComponent:0.2]];
        [_inGroupNickBgView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@0);
            make.leading.equalTo(@16);
            make.trailing.equalTo(_inGroupNickBgView).offset(-16);
            make.height.equalTo(@0.5);
        }];
        
        UILabel * remarkTipLabel = [UILabel new];
        remarkTipLabel.text = LanguageToolMatch(@"在本群的昵称：");
        remarkTipLabel.tkThemetextColors = @[COLOR_11, COLORWHITE];
        remarkTipLabel.font = FONTR(16);
        [_inGroupNickBgView addSubview:remarkTipLabel];
        CGFloat remarkTipLabelWidth = [remarkTipLabel.text widthForFont:remarkTipLabel.font];
        [remarkTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@0);
            make.leading.equalTo(@15);
            make.width.equalTo(@(remarkTipLabelWidth));
            make.bottom.equalTo(_inGroupNickBgView);
        }];
        
        _groupNickLabel = [UILabel new];
        _groupNickLabel.text = LanguageToolMatch(@"未设置备注");
        _groupNickLabel.tkThemetextColors = @[COLOR_66, COLOR_66];
        _groupNickLabel.font = FONTR(14);
        _groupNickLabel.textAlignment = NSTextAlignmentRight;
        _groupNickLabel.numberOfLines = 0;
        [_inGroupNickBgView addSubview:_groupNickLabel];
        [_groupNickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(remarkTipLabel);
            make.leading.equalTo(remarkTipLabel.mas_trailing).offset(15);
            make.trailing.equalTo(_inGroupNickBgView).offset(-15);
            make.height.equalTo(remarkTipLabel);
        }];
    }
    return _inGroupNickBgView;
}

- (UIButton *)btnCopy {
    if (!_btnCopy) {
        _btnCopy = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnCopy setTkThemeImage:@[ImgNamed(@"mine_btn_copy"), ImgNamed(@"mine_btn_copy_dark")] forState:UIControlStateNormal];
        [_btnCopy addTarget:self action:@selector(btnCopyClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnCopy;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    //    self = [[UIScrollView alloc] init];
    //    [self addSubview:self];
    //    [self mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.edges.equalTo(self);
    //    }];
    
    [self addSubview:self.bgImgView];
    [self.bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.leading.trailing.equalTo(self);
        make.height.equalTo(@251);
    }];
    
    // 头像
    _ivHeader = [[NoaBaseImageView alloc] init];
    [self addSubview:_ivHeader];
    
    [self.ivHeader rounded:45 width:6 color:COLORWHITE];
    
    [_ivHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(10.5);
        make.top.equalTo(@83.5);
        make.height.width.equalTo(@90);
    }];
    
    // 头像下方的用户角色
    _lblUserRoleName = [UILabel new];
    _lblUserRoleName.text = @"";
    _lblUserRoleName.tkThemetextColors = @[COLORWHITE, COLORWHITE];
    _lblUserRoleName.font = FONTR(15);
    _lblUserRoleName.tkThemebackgroundColors = @[HEXCOLOR(@"3BA55B"), HEXCOLOR(@"3BA55B")];
    _lblUserRoleName.textAlignment = NSTextAlignmentCenter;
    [_lblUserRoleName rounded:11];
    _lblUserRoleName.hidden = YES;
    [self addSubview:_lblUserRoleName];
    [_lblUserRoleName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.ivHeader);
        make.bottom.equalTo(self.ivHeader).offset(5);
        make.width.greaterThanOrEqualTo(@62);
        make.width.lessThanOrEqualTo(@100);
        make.height.equalTo(@22);
    }];
    
    // 昵称
    _lblNickname = [UILabel new];
    _lblNickname.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _lblNickname.font = FONTSB(18);
    [self addSubview:_lblNickname];
    [_lblNickname mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.ivHeader).offset(27);
        make.leading.equalTo(self.ivHeader.mas_trailing).offset(6);
        make.trailing.equalTo(self).offset(-16);
        make.height.equalTo(@22);
    }];
    
    // 账号
    _lblAccount = [UILabel new];
    _lblAccount.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _lblAccount.font = FONTR(14);
    [self addSubview:_lblAccount];
    [self addSubview:self.btnCopy];
    [_lblAccount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lblNickname.mas_bottom).offset(4);
        make.leading.equalTo(self.lblNickname);
        make.height.equalTo(@17);
    }];
    
    // 赋值按钮
    [_btnCopy mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_lblAccount);
        make.leading.equalTo(_lblAccount.mas_trailing).offset(4);
        make.size.mas_equalTo(CGSizeMake(14, 14));
    }];
    
    // 备注
    [self addSubview:self.remarkBgView];
    [self.remarkBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lblUserRoleName.mas_bottom).offset(20);
        make.leading.equalTo(@12);
        make.trailing.equalTo(self).offset(-12);
        make.height.equalTo(@0);
    }];
    
    // 描述
    [self addSubview:self.desBgView];
    [self.desBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.remarkBgView.mas_bottom).offset(0);
        make.leading.equalTo(@12);
        make.trailing.equalTo(self).offset(-12);
        make.height.equalTo(@0);
    }];
    
    [self addSubview:self.inGroupNickBgView];
    [self.inGroupNickBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.desBgView.mas_bottom).offset(0);
        make.leading.equalTo(@12);
        make.trailing.equalTo(self).offset(-12);
        make.height.equalTo(@0);
    }];
    
    self.remarkBgView.hidden = YES;
    self.desBgView.hidden = YES;
    self.inGroupNickBgView.hidden = YES;
    
    _viewOnline = [UIView new];
    _viewOnline.tkThemebackgroundColors = @[HEXCOLOR(@"01BC46"), HEXCOLOR(@"01BC46")];
    _viewOnline.layer.cornerRadius = DWScale(6);
    _viewOnline.layer.masksToBounds = YES;
    _viewOnline.layer.tkThemeborderColors = @[COLORWHITE, COLORWHITE_DARK];
    _viewOnline.layer.borderWidth = DWScale(1);
    _viewOnline.hidden = YES;
    [self addSubview:_viewOnline];
    [_viewOnline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_ivHeader);
        make.trailing.equalTo(_ivHeader).offset(-6);
        make.width.height.equalTo(@12);
    }];
}

#pragma mark - 界面赋值
- (void)configUserInfoWith:(NSString *)userUid groupId:(NSString *)groupId {
    
    //先获取是否是好友
    LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:userUid];
    if (friendModel) {
        if (friendModel.disableStatus == 4) {
            //账号已注销
            _lblUserRoleName.hidden = YES;
            [_ivHeader setImage:DefaultAccountDelete];
            _lblNickname.text = LanguageToolMatch(@"已注销");
            _lblAccount.text = [NSString stringWithFormat:@"%@%@",LanguageToolMatch(@"账号："), @"-"];
        }else {
            [_ivHeader sd_setImageWithURL:[friendModel.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
            _lblAccount.text = [NSString stringWithFormat:@"%@%@",LanguageToolMatch(@"账号："),friendModel.userName];
            //角色名称
            NSString *roleName = [UserManager matchUserRoleConfigInfo:friendModel.roleId disableStatus:friendModel.disableStatus];
            if ([NSString isNil:roleName]) {
                _lblUserRoleName.hidden = YES;
            } else {
                _lblUserRoleName.hidden = NO;
                _lblUserRoleName.text = roleName;
            }
            
            if (![NSString isNil:friendModel.remarks]) {
                _lblNickname.text = [NSString stringWithFormat:@"%@%@",LanguageToolMatch(@"昵称："),friendModel.nickname];
            }else {
                _lblNickname.text = friendModel.nickname;
            }
        }
        
    }else {
        if (![NSString isNil:groupId]) {
            //获取群成员信息
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:userUid groupID:groupId];
            if (groupMemberModel) {
                if (groupMemberModel.disableStatus == 4) {
                    
                    //账号已注销
                    _lblUserRoleName.hidden = YES;
                    [_ivHeader setImage:DefaultAccountDelete];
                    _lblNickname.text = LanguageToolMatch(@"已注销");
                    _lblAccount.text = [NSString stringWithFormat:@"%@%@",LanguageToolMatch(@"账号："), @"-"];
                    
                }else {
                    [_ivHeader sd_setImageWithURL:[groupMemberModel.userAvatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
                    _lblAccount.text = [NSString stringWithFormat:@"%@%@",LanguageToolMatch(@"账号："),groupMemberModel.userName];
                    //角色名称
                    NSString *roleName = [UserManager matchUserRoleConfigInfo:groupMemberModel.roleId disableStatus:groupMemberModel.disableStatus];
                    if ([NSString isNil:roleName]) {
                        _lblUserRoleName.hidden = YES;
                    } else {
                        _lblUserRoleName.hidden = NO;
                        _lblUserRoleName.text = roleName;
                    }
                    if (![NSString isNil:groupMemberModel.nicknameInGroup] && ![groupMemberModel.nicknameInGroup isEqualToString:groupMemberModel.userNickname]) {
                        _lblNickname.text = [NSString stringWithFormat:@"%@%@",LanguageToolMatch(@"昵称："),groupMemberModel.userNickname];
                    }else {
                        _lblNickname.text = groupMemberModel.userNickname;
                    }
                }
            }
        }
    }
}

- (void)setDesBtnClick{
    if(self.setDesBtnBlock){
        self.setDesBtnBlock();
    }
}

- (void)setRemarkBtnClick{
    if(self.setRemarkBtnBlock){
        self.setRemarkBtnBlock();
    }
}

- (void)updateUIWithUserModel:(NoaUserModel *)userModel isMyFriend:(BOOL)isMyFriend inGroupUserName:(NSString *)inGroupUserName {
    if (userModel.disableStatus == 4) {
        //已注销
        _remarkBgView.hidden = YES;
        _desBgView.hidden = YES;
        _inGroupNickBgView.hidden = YES;
        
        [_ivHeader setImage:DefaultAccountDelete];
        _lblNickname.text = LanguageToolMatch(@"已注销");
        _lblAccount.text = [NSString stringWithFormat:@"%@%@",LanguageToolMatch(@"账号："), @"-"];
    } else {
        _remarkBgView.hidden = NO;
        _desBgView.hidden = NO;
        _inGroupNickBgView.hidden = NO;
        
        
        //如果不是好友，备注、描述、在本群昵称都不显示
        if(!isMyFriend){
            [_remarkBgView removeFromSuperview];
            _remarkBgView = nil;
            [_desBgView removeFromSuperview];
            _desBgView = nil;
            [_inGroupNickBgView removeFromSuperview];
            _inGroupNickBgView = nil;
        }
        
        //inGroupUserName如果为空，则不是从群组查看好友信息
        if (![NSString isNil:inGroupUserName]) {
            if(!_inGroupNickBgView){
                [self addSubview:self.inGroupNickBgView];
            }
            _groupNickLabel.text = inGroupUserName;
        }else{
            [_inGroupNickBgView removeFromSuperview];
            _inGroupNickBgView = nil;
        }
        
        //根据结果判断是否显示描述
        if (![NSString isNil:userModel.descRemark]) {
            if(!_desBgView){
                [self addSubview:self.desBgView];
            }
            _desLabel.text = [NSString stringWithFormat:@"%@%@", LanguageToolMatch(@"描述："), userModel.descRemark];
        }else{
            [_desBgView removeFromSuperview];
            _desBgView = nil;
        }
        
        //根据是否显示重新布局视图
        BOOL isShowRemarkBgView = NO;
        if(_remarkBgView && _remarkBgView.superview){
            isShowRemarkBgView = YES;
            [self.remarkBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.lblUserRoleName.mas_bottom).offset(20);
                make.leading.equalTo(@12);
                make.trailing.equalTo(self).offset(-12);
                make.height.equalTo(@54);
            }];
        }
        
        BOOL isShowDesBgView = NO;
        if(_desBgView && _desBgView.superview){
            isShowDesBgView = YES;
            [self.desBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
                if (isShowRemarkBgView) {
                    make.top.equalTo(_remarkBgView.mas_bottom).offset(0);
                }else {
                    make.top.equalTo(self.lblUserRoleName.mas_bottom).offset(20);
                }
                make.leading.equalTo(@12);
                make.trailing.equalTo(self).offset(-12);
                make.height.greaterThanOrEqualTo(@54);
            }];
        }
        
        BOOL isShowGroupNickBgView = NO;
        if(_inGroupNickBgView && _inGroupNickBgView.superview){
            isShowGroupNickBgView = YES;
            [self.inGroupNickBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
                if (isShowDesBgView) {
                    make.top.equalTo(_desBgView.mas_bottom).offset(0);
                }else {
                    if (isShowRemarkBgView) {
                        make.top.equalTo(_remarkBgView.mas_bottom).offset(0);
                    }else {
                        make.top.equalTo(self.lblUserRoleName.mas_bottom).offset(20);
                    }
                }
                make.leading.equalTo(@12);
                make.trailing.equalTo(self).offset(-12);
                make.height.equalTo(@54);
            }];
        }
        
        // 处理圆角
        if (isShowRemarkBgView) {
            if (isShowDesBgView || isShowGroupNickBgView) {
                // 描述、群昵称展示，备注底部无需切圆角
                _remarkBgView.layer.cornerRadius = 16;
                _remarkBgView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
                _remarkBgView.layer.masksToBounds = YES;
            }else {
                // 描述、群昵称不展示，备注底部需切圆角
                _remarkBgView.layer.cornerRadius = 16;
                _remarkBgView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
                _remarkBgView.layer.masksToBounds = YES;
            }
        }
        
        if (isShowDesBgView) {
            if (isShowRemarkBgView && isShowGroupNickBgView) {
                // 上下都有view展示，故无需切圆角
                _desBgView.layer.cornerRadius = 0;
                _desBgView.layer.maskedCorners = 0;
                _desBgView.layer.masksToBounds = NO;
            }
            
            if (isShowRemarkBgView && !isShowGroupNickBgView) {
                // 上方备注展示、下方群昵称不展示，描述上面不需切圆角，底部需切圆角
                _desBgView.layer.cornerRadius = 16;
                _desBgView.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
                _desBgView.layer.masksToBounds = YES;
            }
            
            if (!isShowRemarkBgView && isShowGroupNickBgView) {
                // 上方备注不展示、下方群昵称展示，描述上面需切圆角，底部不需切圆角
                _desBgView.layer.cornerRadius = 16;
                _desBgView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
                _desBgView.layer.masksToBounds = YES;
            }
            
            if (!isShowRemarkBgView && !isShowGroupNickBgView) {
                // 上方备注不展示、下方群昵称不展示，四个角都需切圆角
                _desBgView.layer.cornerRadius = 16;
                _desBgView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
                _desBgView.layer.masksToBounds = YES;
            }
        }
        
        if (isShowGroupNickBgView) {
            if (isShowRemarkBgView || isShowDesBgView) {
                // 上方备注展示或者上方描述展示，只有底部需要切圆角
                _inGroupNickBgView.layer.cornerRadius = 16;
                _inGroupNickBgView.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
                _inGroupNickBgView.layer.masksToBounds = YES;
            }else {
                // 上方无任何组件，四个角都需要切圆角
                _inGroupNickBgView.layer.cornerRadius = 16;
                _inGroupNickBgView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
                _inGroupNickBgView.layer.masksToBounds = YES;
            }
        }
        
        
        //头像赋值
        [_ivHeader sd_setImageWithURL:[userModel.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
        
        if(![NSString isNil:userModel.remarks] || (![NSString isNil:inGroupUserName] && ![userModel.nickname isEqualToString:inGroupUserName])){
            _remarkLabel.text = [NSString stringWithFormat:@"%@",![NSString isNil:userModel.remarks] ? userModel.remarks : LanguageToolMatch(@"未设置备注")];
            _lblNickname.text = [NSString stringWithFormat:@"%@%@",LanguageToolMatch(@"昵称："), [NSString isNil:userModel.nickname] ? @"" : userModel.nickname];
            _lblAccount.text = [NSString stringWithFormat:@"%@%@",LanguageToolMatch(@"账号："), [NSString isNil:userModel.userName] ? @"" : userModel.userName];
        }else{
            _remarkLabel.text = LanguageToolMatch(@"未设置备注");
            _lblNickname.text = [NSString stringWithFormat:@"%@", [NSString isNil:userModel.nickname] ? @"" : userModel.nickname];
            _lblAccount.text = [NSString stringWithFormat:@"%@%@",LanguageToolMatch(@"账号："), [NSString isNil:userModel.userName] ? @"" : userModel.userName];
        }
        
        //更新数据库
        LingIMFriendModel *myFriend = [IMSDKManager toolCheckMyFriendWith:userModel.userUID];
        if (myFriend) {
            NSString *myFriendStr = [NSString stringWithFormat:@"%@-%@-%@-%@-%@", myFriend.avatar, myFriend.nickname, myFriend.userName, myFriend.remarks, myFriend.descRemark];
            NSString *userModelStr = [NSString stringWithFormat:@"%@-%@-%@-%@-%@", userModel.avatar, userModel.nickname, userModel.userName, userModel.remarks, userModel.descRemark];
            if (![myFriendStr isEqualToString:userModelStr]) {
                //需要更新好友信息，进行一次数据库的更新
                myFriend.avatar = userModel.avatar;//头像
                myFriend.nickname = userModel.nickname;//昵称
                myFriend.userName = userModel.userName;//账号
                myFriend.remarks = userModel.remarks;//备注
                myFriend.descRemark = userModel.descRemark;//描述
                if([userModel.remarks isEqualToString:@""] || !userModel.remarks){
                    myFriend.showName = userModel.nickname;
                }else{
                    myFriend.showName = userModel.remarks;
                }
                [IMSDKManager toolUpdateMyFriendWith:myFriend];
                
                //修改 会话 相关信息
                LingIMSessionModel *sessionModel = [IMSDKManager toolCheckMySessionWith:userModel.userUID];
                sessionModel.sessionName = myFriend.showName;
                sessionModel.sessionAvatar = myFriend.avatar;
                [IMSDKManager toolUpdateSessionWith:sessionModel];
            }
        }
        
        
        //更新名称显示
        //[ZTOOL reloadChatAndSessionVC];
        //刷新聊天和会话列表
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadChatAndSessionVC" object:nil];
    }
}

- (void)btnCopyClick {
    if (![NSString isNil:_lblAccount.text]) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = _lblAccount.text;
        [HUD showMessage:LanguageToolMatch(@"复制成功")];
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
