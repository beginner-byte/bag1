//
//  NoaGroupManageMemberCell.m
//  NoaKit
//
//  Created by Candy on 2026/11/14.
//

#import "NoaGroupManageMemberCell.h"
#import "NSDate+Addition.h"
@interface NoaGroupManageMemberCell ()
//@property (nonatomic, strong) NSArray *titleArr;
@property (nonatomic, strong) NoaGroupNotalkMemberModel *model;
@end

@implementation NoaGroupManageMemberCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        self.contentView.backgroundColor = UIColor.clearColor;
//        self.backgroundColor = UIColor.clearColor;
        
        self.contentView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
        self.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    
    _viewBg = [[UIView alloc] initWithFrame:CGRectMake(DWScale(16), 0, DScreenWidth - DWScale(32), [NoaGroupManageMemberCell defaultCellHeight])];
    _viewBg.tkThemebackgroundColors = @[COLORWHITE, COLOR_EEEEEE_DARK];
    [self.contentView addSubview:_viewBg];
    
    _ivHeader = [[NoaBaseImageView alloc] initWithImage:DefaultAvatar];
    _ivHeader.layer.cornerRadius = DWScale(22);
    _ivHeader.layer.masksToBounds = YES;
    [_viewBg addSubview:_ivHeader];
    [_ivHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_viewBg);
        make.leading.equalTo(_viewBg.mas_leading).offset(DWScale(16));
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
    [_viewBg addSubview:_lblUserRoleName];
    [_lblUserRoleName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_ivHeader).offset(-DWScale(1));
        make.trailing.equalTo(_ivHeader).offset(DWScale(1));
        make.bottom.equalTo(_ivHeader);
        make.height.mas_equalTo(DWScale(15.4));
    }];
    
    _lblUserName = [UILabel new];
    _lblUserName.font = FONTR(16);
    _lblUserName.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [_viewBg addSubview:_lblUserName];
    [_lblUserName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(_ivHeader.mas_trailing).offset(DWScale(10));
        make.top.mas_equalTo(_ivHeader.mas_top);
        make.height.mas_equalTo(DWScale(22));
    }];
    
    _lblTime = [UILabel new];
    _lblTime.font = FONTR(12);
    _lblTime.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    [_viewBg addSubview:_lblTime];
    [_lblTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(_ivHeader.mas_trailing).offset(DWScale(10));
        make.top.mas_equalTo(_lblUserName.mas_bottom).offset(DWScale(2));
        make.height.mas_equalTo(DWScale(18));
    }];
    
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelBtn setTitle:LanguageToolMatch(@"解除禁言") forState:UIControlStateNormal];
    [_cancelBtn setTitleColor:HEXCOLOR(@"4791FF") forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(cancelBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    _cancelBtn.titleLabel.font = FONTR(16);
    [_viewBg addSubview:_cancelBtn];
    [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_viewBg);
        make.trailing.mas_equalTo(_viewBg.mas_trailing).offset(DWScale(-16));
        make.height.mas_equalTo(DWScale(20));
    }];
    
    _viewLine = [UIView new];
    _viewLine.tkThemebackgroundColors = @[COLOR_EEEEEE, [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1]];
    [_viewBg addSubview:_viewLine];
    [_viewLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewBg).offset(DWScale(16));
        make.trailing.equalTo(_viewBg).offset(-DWScale(16));
        make.bottom.equalTo(_viewBg);
        make.height.mas_equalTo(DWScale(1));
    }];
}

- (void)setCornerRadiusWithIsShow:(BOOL)isShow location:(CornerRadiusLocationType)locationType{
    if (isShow) {
        WeakSelf;
            UIBezierPath *path;
            if (locationType == CornerRadiusLocationAll) {
                path = [UIBezierPath bezierPathWithRoundedRect:weakSelf.viewBg.bounds  byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight|UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(DWScale(12), DWScale(12))];
            }else if (locationType == CornerRadiusLocationTop){
                path = [UIBezierPath bezierPathWithRoundedRect:weakSelf.viewBg.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(DWScale(12), DWScale(12))];
            }else{
                path = [UIBezierPath bezierPathWithRoundedRect:weakSelf.viewBg.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(DWScale(12), DWScale(12))];
            }

            CAShapeLayer *layer1 = [[CAShapeLayer alloc]init];
            layer1.frame = weakSelf.viewBg.bounds;
            layer1.path = path.CGPath;
            weakSelf.viewBg.layer.mask = layer1;
    }else{
        WeakSelf;
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:weakSelf.viewBg.bounds byRoundingCorners:nil cornerRadii:CGSizeZero];;

            CAShapeLayer *layer1 = [[CAShapeLayer alloc]init];
            layer1.frame = weakSelf.viewBg.bounds;
            layer1.path = path.CGPath;
            weakSelf.viewBg.layer.mask = layer1;
    }
}
#pragma mark - 交互事件

+ (CGFloat)defaultCellHeight {
    return DWScale(68);
}

- (void)cancelBtnAction:(UIButton *)btn{
    if (self.tapCancelNotalkBlock) {
        self.tapCancelNotalkBlock(self.model);
    }
}

- (void)cellConfigWithmodel:(NoaGroupNotalkMemberModel *)model{
    self.model = model;
    
    LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:model.forbidUserUid groupID:model.groupId];
    if (groupMemberModel) {
        [_ivHeader sd_setImageWithURL:[groupMemberModel.userAvatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
        _lblUserName.text = groupMemberModel.showName;
        //角色名称
        NSString *roleName = [UserManager matchUserRoleConfigInfo:groupMemberModel.roleId disableStatus:groupMemberModel.disableStatus];
        if ([NSString isNil:roleName]) {
            _lblUserRoleName.hidden = YES;
        } else {
            _lblUserRoleName.hidden = NO;
            _lblUserRoleName.text = roleName;
        }
    } else {
        [_ivHeader sd_setImageWithURL:[model.forbidUserIcon getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
        _lblUserName.text = model.forbidUserNickName;
        //角色名称
        NSString *roleName = [UserManager matchUserRoleConfigInfo:model.roleId disableStatus:0];
        if ([NSString isNil:roleName]) {
            _lblUserRoleName.hidden = YES;
        } else {
            _lblUserRoleName.hidden = NO;
            _lblUserRoleName.text = roleName;
        }
    }
    
    NSInteger time = [NSDate getTimeDifferenceWithStartTime:model.updateTime andEndTime:model.expireTime timeFormatter:@"yyyy-MM-dd HH:mm:ss"];
    NSString * timeStr = [NSDate getOvertime:[NSString stringWithFormat:@"%ld",time] isShowSecondStr:NO];
    NSString * showStr;
    if ([timeStr isEqualToString:LanguageToolMatch(@"禁言")]) {
        showStr = LanguageToolMatch(@"永久禁言");
    }else{
        showStr = [NSString stringWithFormat:LanguageToolMatch(@"约%@后解除禁言"),timeStr];
    }
    _lblTime.text = showStr;
}

@end
