//
//  NoaHistoryChoiceUserCell.h
//  NoaKit
//
//  Created by Candy on 2024/8/12.
//

#import "NoaBaseCell.h"
#import "NoaBaseUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaHistoryChoiceUserCell : NoaBaseCell

@property (nonatomic, assign) BOOL selectedUser;

- (void)cellConfigBaseUserWith:(NoaBaseUserModel *)model search:(NSString *)searchStr;

@end

NS_ASSUME_NONNULL_END
