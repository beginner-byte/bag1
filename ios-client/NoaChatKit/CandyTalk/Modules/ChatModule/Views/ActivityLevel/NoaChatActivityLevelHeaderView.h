//
//  NoaChatActivityLevelHeaderView.h
//  NoaKit
//
//  Created by Candy on 2025/2/19.
//

#import <UIKit/UIKit.h>
#import "NoaGroupActivityInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaChatActivityLevelHeaderView : UITableViewHeaderFooterView

@property(nonatomic, assign)NSInteger myLevelScroe;
@property(nonatomic, strong)NoaGroupActivityInfoModel *activityInfoModel;

@end

NS_ASSUME_NONNULL_END
