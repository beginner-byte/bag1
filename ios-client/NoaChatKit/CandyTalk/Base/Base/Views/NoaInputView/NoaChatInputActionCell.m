//
//  NoaChatInputActionCell.m
//  NoaKit
//
//  Created by Candy on 2023/6/27.
//

#import "NoaChatInputActionCell.h"

@implementation NoaChatInputActionCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    _ivAction = [UIImageView new];
    [self.contentView addSubview:_ivAction];
    [_ivAction mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
        //make.size.mas_equalTo(CGSizeMake(DWScale(44), DWScale(44)));
    }];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (void)setCellIndex:(NSIndexPath *)cellIndex {
    _cellIndex = cellIndex;
}

#pragma mark - 交互事件
- (void)btnClick:(id)sender {
    UIButton *button = (UIButton *)sender;
    //防连续点击事件
    button.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        button.enabled = YES;
    });
    
    if (_delegate && [_delegate respondsToSelector:@selector(actionCellSelected:)] && _cellIndex) {
        [_delegate actionCellSelected:_cellIndex];
    }
}

@end
