//
//  NoaGroupManageMemberCell.h
//  NoaKit
//
//  Created by Candy on 2026/11/14.
//

#import "NoaBaseCell.h"
#import "NoaBaseImageView.h"
#import "NoaGroupNotalkMemberModel.h"
#import "NoaGroupManageCommonCell.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^TapCancelNotalkBlock)(NoaGroupNotalkMemberModel * model);

@interface NoaGroupManageMemberCell : NoaBaseCell
@property (nonatomic, strong) UIView *viewBg;
@property (nonatomic, strong) UILabel *lblUserName;
@property (nonatomic, strong) NoaBaseImageView *ivHeader;
@property (nonatomic, strong) UILabel *lblUserRoleName;//用户角色名称
@property (nonatomic, strong) UILabel *lblTime;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIView *viewLine;
//点击解除禁言回调Block
@property (nonatomic, copy)TapCancelNotalkBlock tapCancelNotalkBlock;

- (void)setCornerRadiusWithIsShow:(BOOL)isShow location:(CornerRadiusLocationType)locationType;
- (void)cellConfigWithmodel:(NoaGroupNotalkMemberModel *)model;
@end

NS_ASSUME_NONNULL_END
