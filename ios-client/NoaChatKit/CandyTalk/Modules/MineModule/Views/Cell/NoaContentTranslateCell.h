//
//  NoaContentTranslateCell.h
//  NoaKit
//
//  Created by Candy on 2023/9/14.
//

#import "NoaBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^SettingSwithcClick) (BOOL isOn);

@interface NoaContentTranslateCell : NoaBaseCell

@property (nonatomic, copy) NSString *contentStr;
@property (nonatomic, assign) BOOL switchIsOn;
@property (nonatomic, copy) SettingSwithcClick switchBlock;

/// cell右边视图展示
/// - Parameter cellIndexPath: 当前下标
- (void)configCellRightViewWith:(NSIndexPath *)cellIndexPath;

@end

NS_ASSUME_NONNULL_END
