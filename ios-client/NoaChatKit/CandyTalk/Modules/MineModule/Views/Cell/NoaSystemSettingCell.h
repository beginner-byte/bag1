//
//  NoaSystemSettingCell.h
//  NoaKit
//
//  Created by Candy on 2026/11/13.
//

#import "NoaBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^SettingSwithcClick) (BOOL isOn);

@interface NoaSystemSettingCell : NoaBaseCell

@property (nonatomic, copy)NSString *leftTitleStr;
@property (nonatomic, copy)NSString *centerTitleStr;
@property (nonatomic, copy)NSString *rightTitleStr;
@property (nonatomic, assign)BOOL switchIsOn;
@property (nonatomic, copy) SettingSwithcClick switchBlock;

- (void)configCellRoundWithCellIndex:(NSInteger)index totalIndex:(NSInteger)totalIndex;

@end

NS_ASSUME_NONNULL_END
