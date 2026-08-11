//
//  NoaMassMessageGroupSelectedTopView.h
//  NoaKit
//
//  Created by Candy on 2023/9/4.
//

#import <UIKit/UIKit.h>
#import "NoaBaseImageView.h"
#import "NoaBaseCollectionCell.h"
#import "NoaBaseUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaMassMessageGroupSelectedTopView : UIView

@property (nonatomic, strong) NSMutableArray *selectedTopUserList;

@end

@interface NoaMassMessageGroupSelectItem : NoaBaseCollectionCell

@property (nonatomic, strong) NoaBaseImageView *ivHeader;
@property (nonatomic, strong) UILabel *ivRoleName;//用户角色名称
@property (nonatomic, strong) UILabel *lblName;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) NoaBaseUserModel *model;

@end

NS_ASSUME_NONNULL_END
