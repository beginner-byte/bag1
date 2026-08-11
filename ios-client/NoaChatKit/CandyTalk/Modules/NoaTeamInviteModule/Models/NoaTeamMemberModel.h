//
//  NoaTeamMemberModel.h
//  NoaKit
//
//  Created by Candy on 2023/7/24.
//

#import "NoaBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaTeamMemberModel : NoaBaseModel
@property (nonatomic, copy) NSString *userUid;//团队成员ID
@property (nonatomic, copy) NSString *avatar;//团队成员头像
@property (nonatomic, copy) NSString *nickname;//团队成员昵称
@property (nonatomic, copy) NSString *joinTime;//团队成员加入时间
@property (nonatomic, copy) NSString *lastLineTime;//最后在线时间
@property (nonatomic, assign) long latestOfflineTime;//最晚下线时间
@end

NS_ASSUME_NONNULL_END
