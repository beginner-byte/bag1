//
//  NoaChatSetGroupInfoCell.h
//  NoaKit
//
//  Created by Candy on 2026/11/5.
//

// 群设置 - 群信息Cell

#import "NoaBaseCell.h"
#import "LingIMGroup.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^TapGroupInfoViewBlock)(void);
@interface NoaChatSetGroupInfoCell : NoaBaseCell
//点击群组信息视图回调Block
@property (nonatomic, copy)TapGroupInfoViewBlock tapGroupInfoViewBlock;
//点击查看群组成员回调
@property (nonatomic, copy)TapGroupInfoViewBlock tapVisitGroupMemberBlock;
//点击增加成员回调
@property (nonatomic, copy)TapGroupInfoViewBlock tapInviteFriendBlock;
//移除成员回调
@property (nonatomic, copy)TapGroupInfoViewBlock tapRemoveFriendBlock;
@property (nonatomic, strong) LingIMGroup *groupModel;
@end

NS_ASSUME_NONNULL_END
