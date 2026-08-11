//
//  NoaTranslateManagerCell.h
//  NoaKit
//
//  Created by Candy on 2023/11/2.
//

#import "NoaBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaTranslateManagerCell : NoaBaseCell

@property (nonatomic, copy)NSString *contentStr;

- (void)configCellRoundWithCellIndex:(NSInteger)index totalIndex:(NSInteger)totalIndex;

@end

NS_ASSUME_NONNULL_END
