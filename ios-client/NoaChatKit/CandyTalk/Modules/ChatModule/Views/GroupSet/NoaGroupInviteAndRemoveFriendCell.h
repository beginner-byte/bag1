//
//  NoaGroupInviteAndRemoveFriendCell.h
//  NoaKit
//
//  Created by Candy on 2026/11/9.
//

#import "NoaBaseCell.h"
#import <NoaChatCore/LingIMGroupMemberModel.h>
NS_ASSUME_NONNULL_BEGIN

@interface NoaGroupInviteAndRemoveFriendCell : NoaBaseCell
@property (nonatomic, assign) NSInteger selectedUser;
- (void)cellConfigWith:(LingIMGroupMemberModel *)model search:(NSString *)searchStr;
@end

NS_ASSUME_NONNULL_END
