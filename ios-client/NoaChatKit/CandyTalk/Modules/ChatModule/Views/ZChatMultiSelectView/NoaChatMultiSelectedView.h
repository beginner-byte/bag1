//
//  NoaChatMultiSelectedView.h
//  NoaKit
//
//  Created by Candy on 2023/4/12.
//

#import <UIKit/UIKit.h>
#import "NoaBaseImageView.h"
#import "NoaBaseCollectionCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaChatMultiSelectedView : UIView

@property (nonatomic, strong) NSMutableArray *selectedTopList;

@end


@interface NoaMultiSelectedHeaderItem : NoaBaseCollectionCell

@property (nonatomic, strong) NoaBaseImageView *ivHeader;
@property (nonatomic, strong) UILabel *ivRoleName;//用户角色名称
@property (nonatomic, strong) UILabel *lblName;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) id model;

@end

NS_ASSUME_NONNULL_END
