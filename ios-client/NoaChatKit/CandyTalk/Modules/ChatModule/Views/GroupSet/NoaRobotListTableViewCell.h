//
//  NoaRobotListTableViewCell.h
//  NoaKit
//
//  Created by Apple on 2023/9/25.
//

#import "NoaBaseCell.h"
#import "NoaBaseImageView.h"
#import "NoaRobotModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface NoaRobotListTableViewCell : NoaBaseCell
@property (nonatomic, strong) NoaBaseImageView *ivHeader;
- (void)cellConfigWithModel:(NoaRobotModel *)model;
@end

NS_ASSUME_NONNULL_END
