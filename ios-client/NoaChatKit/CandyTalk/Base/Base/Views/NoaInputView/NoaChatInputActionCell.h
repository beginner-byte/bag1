//
//  NoaChatInputActionCell.h
//  NoaKit
//
//  Created by Candy on 2023/6/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ZChatInputActionCellDelegate <NSObject>
- (void)actionCellSelected:(NSIndexPath *)cellIndex;
@end

@interface NoaChatInputActionCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *ivAction;
@property (nonatomic, strong) NSIndexPath *cellIndex;

@property (nonatomic, weak) id <ZChatInputActionCellDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
