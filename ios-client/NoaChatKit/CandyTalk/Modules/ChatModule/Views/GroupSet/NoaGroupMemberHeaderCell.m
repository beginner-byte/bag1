//
//  NoaGroupMemberHeaderCell.m
//  NoaKit
//
//  Created by Candy on 2026/11/5.
//

#import "NoaGroupMemberHeaderCell.h"
#import "NoaBaseImageView.h"

@interface NoaGroupMemberHeaderCell ()
@property (nonatomic, strong) NoaBaseImageView *ivHeader;
@property (nonatomic, strong) UILabel *lblUserRoleName;//用户角色名称
@property (nonatomic, strong) LingIMGroupMemberModel *model;
@end

@implementation NoaGroupMemberHeaderCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    _ivHeader = [[NoaBaseImageView alloc] initWithImage:ImgNamed(@"s_add_member")];
    _ivHeader.layer.cornerRadius = (self.contentView.height-2) / 2.0;
    _ivHeader.layer.masksToBounds = YES;
    [self.contentView addSubview:_ivHeader];
    [_ivHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(self.contentView.height-2, self.contentView.height-2));
    }];
    
    _lblUserRoleName = [UILabel new];
    _lblUserRoleName.text = @"";
    _lblUserRoleName.tkThemetextColors = @[COLORWHITE, COLORWHITE];
    _lblUserRoleName.font = FONTN(7);
    _lblUserRoleName.tkThemebackgroundColors = @[COLOR_EAB243, COLOR_EAB243_DARK];
    _lblUserRoleName.textAlignment = NSTextAlignmentCenter;
    [_lblUserRoleName rounded:((self.contentView.height-2)*0.35)/2];
    _lblUserRoleName.hidden = YES;
    [self.contentView addSubview:_lblUserRoleName];
    [_lblUserRoleName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_ivHeader).offset(-DWScale(1));
        make.trailing.equalTo(_ivHeader).offset(DWScale(1));
        make.bottom.equalTo(_ivHeader);
        make.height.mas_equalTo((self.contentView.height-2)*0.35);
    }];
    
}
- (void)configCellWith:(LingIMGroupMemberModel *)memberModel action:(BOOL)addMember {
    if (memberModel) {
        _model = memberModel;
        [_ivHeader sd_setImageWithURL:[memberModel.userAvatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageRetryFailed | SDWebImageAllowInvalidSSLCertificates];
        //角色名称
        NSString *roleName = [UserManager matchUserRoleConfigInfo:memberModel.roleId disableStatus:memberModel.disableStatus];
        if ([NSString isNil:roleName]) {
            _lblUserRoleName.hidden = YES;
        } else {
            _lblUserRoleName.hidden = NO;
            _lblUserRoleName.text = roleName;
        }
    }else {
        _ivHeader.image = addMember ? ImgNamed(@"s_add_member") : ImgNamed(@"s_reduce_member");
        _addMember = addMember;
        _lblUserRoleName.hidden = YES;
    }
}
@end
