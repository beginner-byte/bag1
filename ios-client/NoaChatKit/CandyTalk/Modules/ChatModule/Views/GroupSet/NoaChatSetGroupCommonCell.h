//
//  NoaChatSetGroupCommonCell.h
//  NoaKit
//
//  Created by Candy on 2026/11/5.
//

// 群设置 - 通用Cell

#import "NoaBaseCell.h"
#import "LingIMGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaChatSetGroupCommonCell : NoaBaseCell
@property (nonatomic, strong) UIButton *viewBg;
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UILabel *lblContent;
@property (nonatomic, strong) UIImageView *ivArrow;
@property (nonatomic, strong) UIButton *btnAction;
@property (nonatomic, strong) UIButton *btnCenter;
@property (nonatomic, strong) UIView *viewLine;

- (void)cellConfigWithTitle:(NSString *)cellTitle model:(LingIMGroup *)model;
@end

NS_ASSUME_NONNULL_END
