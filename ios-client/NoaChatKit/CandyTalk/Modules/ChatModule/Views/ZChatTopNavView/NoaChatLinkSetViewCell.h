//
//  NoaChatLinkSetViewCell.h
//  NoaKit
//
//  Created by Candy on 2023/7/18.
//

#import <UIKit/UIKit.h>
#import "NoaChatTagModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZChatLinkSetViewCellDelegate <NSObject>

- (void)deleteChatLinkAction:(NSInteger)cellIndex;
- (void)editChatLinkAction:(NSInteger)cellIndex;

@end

@interface NoaChatLinkSetViewCell : UITableViewCell

@property (nonatomic, weak) id<ZChatLinkSetViewCellDelegate>delegate;
@property (nonatomic, strong) NSIndexPath *cellaPath;
@property (nonatomic, strong) NoaChatTagModel *tagModel;

@end

NS_ASSUME_NONNULL_END
