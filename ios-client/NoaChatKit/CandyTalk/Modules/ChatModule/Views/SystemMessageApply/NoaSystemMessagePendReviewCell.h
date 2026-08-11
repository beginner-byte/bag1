//
//  NoaSystemMessagePendReviewCell.h
//  NoaKit
//
//  Created by Candy on 2023/5/10.
//

#import "NoaBaseCell.h"
#import "NoaSystemMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZSystemMessagePendReviewCellDelegate <NSObject>

@optional

- (void)systemMessageCellClickNickNameAction:(NSString *)userUid;

@end

@interface NoaSystemMessagePendReviewCell : NoaBaseCell

@property (nonatomic, assign) ZGroupHelperFormType fromType;
@property (nonatomic, strong) NoaSystemMessageModel *model;
@property (nonatomic, weak) id<ZSystemMessagePendReviewCellDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
