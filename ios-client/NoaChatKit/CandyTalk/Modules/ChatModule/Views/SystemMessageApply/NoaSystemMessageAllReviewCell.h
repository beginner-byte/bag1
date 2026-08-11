//
//  NoaSystemMessageAllReviewCell.h
//  NoaKit
//
//  Created by Candy on 2023/5/10.
//

#import "NoaBaseCell.h"
#import "NoaSystemMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZSystemMessageAllReviewCellDelegate <NSObject>

@optional

- (void)systemMessageCellClickNickNameAction:(NSString *)userUid;
- (void)refuseSystemMessageAllReviewAction:(NSIndexPath *)indexPath;
- (void)agreeSystemMessageAllReviewAgreeAction:(NSIndexPath *)indexPath;

@end

@interface NoaSystemMessageAllReviewCell : NoaBaseCell

@property (nonatomic, assign) ZGroupHelperFormType fromType;
@property (nonatomic, strong) NoaSystemMessageModel *model;
@property (nonatomic, weak) id<ZSystemMessageAllReviewCellDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
