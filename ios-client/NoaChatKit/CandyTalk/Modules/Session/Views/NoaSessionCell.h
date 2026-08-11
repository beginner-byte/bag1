//
//  NoaSessionCell.h
//  NoaKit
//
//  Created by Candy on 2026/9/23.
//

// 会话列表 Cell

#import "MGSwipeTableCell.h"

@protocol ZSessionCellDelegate <NSObject>
//点击
- (void)cellClickAction:(NSIndexPath *_Nullable)indexPath;
@end

NS_ASSUME_NONNULL_BEGIN

@interface NoaSessionCell : MGSwipeTableCell
@property (nonatomic, strong) LingIMSessionModel *model;
@property (nonatomic, strong) NSIndexPath *cellIndexPath;
@property (nonatomic, weak) id <ZSessionCellDelegate> cellDelegate;
@property (nonatomic, copy) void(^clearSessionBlock)(void);
@end

NS_ASSUME_NONNULL_END
