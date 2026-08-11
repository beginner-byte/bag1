//
//  NoaMineUserInfoCell.h
//  NoaKit
//
//  Created by Candy on 2026/11/12.
//

#import "NoaBaseCell.h"

@protocol ZMineUserInfoCellDelegate <NSObject>

@optional
//点击
- (void)headerImageClickAction:(UIImage *_Nullable)image url:(NSString *_Nullable)url;

@end

NS_ASSUME_NONNULL_BEGIN

@interface NoaMineUserInfoCell : NoaBaseCell

@property (nonatomic, assign)NSInteger cellIndex;
@property (nonatomic, strong)UIImage *clipImage;
@property (nonatomic, weak) id <ZMineUserInfoCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
