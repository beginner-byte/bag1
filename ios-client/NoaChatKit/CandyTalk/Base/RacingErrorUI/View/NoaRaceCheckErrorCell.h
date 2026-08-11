//
//  NoaRaceCheckErrorCell.h
//  NoaKit
//
//  Created by Candy on 2024/5/11.
//

#import <UIKit/UIKit.h>
#import "NoaRaceCheckErrorModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaRaceCheckErrorCell : UITableViewCell

@property (nonatomic, assign)NSInteger cellIndex;
@property (nonatomic, strong)NoaRaceCheckErrorModel *model;

@end

NS_ASSUME_NONNULL_END
