//
//  NoaBaseCell.h
//  NoaKit
//
//  Created by Candy on 2026/9/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZBaseCellDelegate <NSObject>

//点击
- (void)cellClickAction:(NSIndexPath *)indexPath;

@end

@interface NoaBaseCell : UITableViewCell

@property (nonatomic, strong) NSIndexPath *baseCellIndexPath;
@property (nonatomic, weak) id <ZBaseCellDelegate> baseDelegate;
@property (nonatomic, strong) UIButton *baseContentButton;//可视化交互背景按钮

//cell高度
+ (CGFloat)defaultCellHeight;

//重用标识
+ (NSString *)cellIdentifier;

@end

NS_ASSUME_NONNULL_END
