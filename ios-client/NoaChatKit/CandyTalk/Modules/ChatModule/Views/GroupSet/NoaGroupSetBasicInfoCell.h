//
//  NoaGroupSetBasicInfoCell.h
//  NoaKit
//
//  Created by Candy on 2026/11/7.
//

#import "NoaBaseCell.h"
#import "NoaBaseImageView.h"
#import "LingIMGroup.h"
NS_ASSUME_NONNULL_BEGIN

@interface NoaGroupSetBasicInfoCell : NoaBaseCell
@property (nonatomic, strong) UIButton * viewBg;
@property (nonatomic, strong) UILabel *lblTypeName;
@property (nonatomic, strong) NoaBaseImageView *ivGroup;
@property (nonatomic, strong) NoaBaseImageView *ivQrCode;
@property (nonatomic, strong) UILabel *lblGroupName;

- (void)cellConfigWithTitle:(NSString *)cellTitle model:(LingIMGroup *)model;
@end

NS_ASSUME_NONNULL_END
