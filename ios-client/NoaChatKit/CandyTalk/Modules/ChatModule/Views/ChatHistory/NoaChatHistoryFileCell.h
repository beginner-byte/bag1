//
//  NoaChatHistoryFileCell.h
//  NoaKit
//
//  Created by Candy on 2023/2/2.
//

#import "MGSwipeTableCell.h"
@protocol ZChatHistoryFileCellDelegate <NSObject>
//点击
- (void)cellClickAction:(NSIndexPath *_Nullable)indexPath;
@end

NS_ASSUME_NONNULL_BEGIN

@interface NoaChatHistoryFileCell : MGSwipeTableCell
@property (nonatomic, weak) id <ZChatHistoryFileCellDelegate> cellDelegate;
@property (nonatomic, strong) NSIndexPath *cellIndexPath;
+ (CGFloat)defaultCellHeight;
+(NSString *)cellIdentifier;
- (void)configCellWith:(NoaIMChatMessageModel *)chatMessageModel searchContent:(NSString *)searchStr;
@end

NS_ASSUME_NONNULL_END
