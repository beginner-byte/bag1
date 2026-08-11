//
//  NoaTranslateSettingCell.h
//  NoaKit
//
//  Created by Candy on 2023/12/26.
//

#import "NoaBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^SettingSwithcClick) (BOOL isOn);

@interface NoaTranslateSettingCell : NoaBaseCell

@property (nonatomic, copy)NSString *leftTitleStr;
@property (nonatomic, copy)NSString *rightTitleStr;
@property (nonatomic, assign)BOOL switchIsOn;
@property (nonatomic, copy) SettingSwithcClick switchBlock;

- (void)configCellRoundWithCellIndex:(NSInteger)index totalIndex:(NSInteger)totalIndex;

@end

NS_ASSUME_NONNULL_END
