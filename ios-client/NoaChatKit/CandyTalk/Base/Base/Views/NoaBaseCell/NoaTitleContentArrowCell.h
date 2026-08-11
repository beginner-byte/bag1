//
//  NoaTitleContentArrowCell.h
//  NoaKit
//
//  Created by Candy on 2026/9/13.
//

// 通用的 标题 内容 箭头 - Cell

#import "NoaBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaTitleContentArrowCell : NoaBaseCell
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UILabel *lblContent;
@property (nonatomic, strong) UIImageView *ivArrow;
@property (nonatomic, strong) UIView *viewLine;
@end

NS_ASSUME_NONNULL_END
