//
//  NoaHistoryChoiceUseredTopView.h
//  NoaKit
//
//  Created by Candy on 2024/8/12.
//

#import <UIKit/UIKit.h>
#import "NoaBaseCollectionCell.h"
#import "NoaBaseUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaHistoryChoiceUseredTopView : UIView

@property (nonatomic, strong) NSMutableArray *choicedTopUserList;

@end


@interface NoaHistoryChoiceUseredItem : NoaBaseCollectionCell

@property (nonatomic, strong) UIImageView *ivHeader;
@property (nonatomic, strong) UILabel *lblName;
@property (nonatomic, strong) UIButton *deleteBtn;

@property (nonatomic, strong) NoaBaseUserModel *model;

@end

NS_ASSUME_NONNULL_END
