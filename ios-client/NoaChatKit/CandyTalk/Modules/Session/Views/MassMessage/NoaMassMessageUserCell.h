//
//  NoaMassMessageUserCell.h
//  NoaKit
//
//  Created by Candy on 2023/4/19.
//

#import "NoaBaseCell.h"
#import "NoaMassMessageUserModel.h"
#import "NoaMassMessageErrorUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaMassMessageUserCell : NoaBaseCell
@property (nonatomic, strong) id userModel;

@property (nonatomic, strong) UIImageView *ivHeader;
@property (nonatomic, strong) UILabel *ivRoleName;//用户角色名称
@property (nonatomic, strong) UILabel *lblNickname;
@property (nonatomic, strong) UILabel *lblTip;
@end

NS_ASSUME_NONNULL_END
