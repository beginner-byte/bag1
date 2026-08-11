//
//  NoaChatSingleSetInfoCell.h
//  NoaKit
//
//  Created by Candy on 2026/12/29.
//

#import "NoaBaseCell.h"
#import "NoaUserModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^TapSingleSetInfoViewBlock)(void);

@interface NoaChatSingleSetInfoCell : NoaBaseCell
- (void)cellConfigWithModel:(LingIMFriendModel *)model;

@property (nonatomic, copy)TapSingleSetInfoViewBlock tapSingleInfoAddBlock;

@property (nonatomic, copy)TapSingleSetInfoViewBlock tapHeaderBlock;
@end

NS_ASSUME_NONNULL_END
