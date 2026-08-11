//
//  NoaTeamMemberCell.h
//  NoaKit
//
//  Created by Candy on 2023/7/20.
//

#import "NoaBaseCell.h"
#import "NoaTeamMemberModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaTeamMemberCell : NoaBaseCell
@property (nonatomic, strong) NoaTeamMemberModel *memberModel;
@property (nonatomic, copy) void(^tickoutCallback)(void);
@end

NS_ASSUME_NONNULL_END
