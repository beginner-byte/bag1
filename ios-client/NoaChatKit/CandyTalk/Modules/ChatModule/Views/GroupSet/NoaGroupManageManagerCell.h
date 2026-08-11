//
//  NoaGroupManageManagerCell.h
//  NoaKit
//
//  Created by Candy on 2026/11/15.
//

#import "NoaBaseCell.h"
#import "NoaBaseImageView.h"
#import <NoaChatCore/LingIMGroupMemberModel.h>
#import "NoaGroupManageCommonCell.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^TapCancelManagerBlock)(LingIMGroupMemberModel * model);
@interface NoaGroupManageManagerCell : NoaBaseCell
@property (nonatomic, strong) UIView *viewBg;
@property (nonatomic, strong) UILabel *lblUserName;
@property (nonatomic, strong) NoaBaseImageView *ivHeader;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIView *viewLine;
@property (nonatomic, copy)TapCancelManagerBlock tapCancelManagerBlock;

- (void)cellConfigWithmodel:(LingIMGroupMemberModel *)model;
- (void)setCornerRadiusWithIsShow:(BOOL)isShow location:(CornerRadiusLocationType)locationType;
@end

NS_ASSUME_NONNULL_END
