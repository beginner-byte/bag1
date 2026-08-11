//
//  NoaMassMessageUserHeaderCell.h
//  NoaKit
//
//  Created by Candy on 2023/4/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaMassMessageUserHeaderCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *ivHeader;
@property (nonatomic, strong) UILabel *ivRoleName;//用户角色名称
@property (nonatomic, strong) UIView *viewMask;
@property (nonatomic, strong) UILabel *lblNumber;

@property (nonatomic, strong) id model;
@end

NS_ASSUME_NONNULL_END
