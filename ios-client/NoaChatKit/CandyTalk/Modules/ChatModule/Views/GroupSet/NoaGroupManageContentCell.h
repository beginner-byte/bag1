//
//  NoaGroupManageContentCell.h
//  NoaKit
//
//  Created by Candy on 2023/4/25.
//

// 群管理 标题+描述+开关 Cell

#import "NoaBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaGroupManageContentCell : NoaBaseCell
@property (nonatomic, strong) UIButton *viewContent;
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UILabel *lblContent;
@property (nonatomic, strong) UIButton *btnSwitch;
@property (nonatomic, strong) UIView *viewLine;

- (void)updateCellUIWith:(NSInteger)currentRow totalRow:(NSInteger)totalRow;
@end

NS_ASSUME_NONNULL_END
