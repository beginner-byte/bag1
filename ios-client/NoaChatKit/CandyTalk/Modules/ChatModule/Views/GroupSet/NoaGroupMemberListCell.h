//
//  NoaGroupMemberListCell.h
//  NoaKit
//
//  Created by Candy on 2026/11/9.
//

#import "NoaBaseCell.h"
#import "NoaBaseImageView.h"
#import <NoaChatCore/LingIMGroupMemberModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaGroupMemberListCell : NoaBaseCell
@property (nonatomic, strong) UILabel *lblUserName;
@property (nonatomic, strong) NoaBaseImageView *ivHeader;
@property (nonatomic, strong) UILabel *lblUserRoleName;//用户角色名称

- (void)cellConfigWithmodel:(LingIMGroupMemberModel *)model searchStr:(NSString *)searchStr activityInfo:(NoaGroupActivityInfoModel * _Nullable )activityInfo isActivityEnable:(NSInteger)isActivityEnable;
@end

NS_ASSUME_NONNULL_END
