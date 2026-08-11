//
//  NoaFriendGroupSectionHeaderView.h
//  NoaKit
//
//  Created by Candy on 2023/7/3.
//

#import <UIKit/UIKit.h>
#import "NoaFriendGroupModel.h"

NS_ASSUME_NONNULL_BEGIN
@protocol ZFriendGroupSectionHeaderViewDelegate <NSObject>
- (void)friendGroupSectionOpenWith:(NoaFriendGroupModel *)friendGroupModel;
- (void)friendGroupSectionLongPress;
@end

@interface NoaFriendGroupSectionHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) UIImageView *ivArrow;
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UILabel *lblNumber;
@property (nonatomic, weak) id <ZFriendGroupSectionHeaderViewDelegate> delegate;

@property (nonatomic, strong) NoaFriendGroupModel *friendGroupModel;

@end

NS_ASSUME_NONNULL_END
