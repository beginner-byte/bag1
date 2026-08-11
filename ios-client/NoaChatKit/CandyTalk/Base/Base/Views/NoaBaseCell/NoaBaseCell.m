//
//  NoaBaseCell.m
//  NoaKit
//
//  Created by Candy on 2026/9/9.
//

#import "NoaBaseCell.h"
#import "NoaToolManager.h"

@implementation NoaBaseCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

+ (CGFloat)defaultCellHeight {
    return CGFLOAT_MIN;
}

+ (NSString *)cellIdentifier {
    return NSStringFromClass(self);
}
#pragma mark - 交互事件
- (void)baseContentButtonClick {
//    self.baseContentButton.selected = YES;
    
    if (_baseDelegate && [_baseDelegate respondsToSelector:@selector(cellClickAction:)]) {
        [_baseDelegate cellClickAction:self.baseCellIndexPath];
    }
    
//    WeakSelf
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [ZTOOL doInMain:^{
//            weakSelf.baseContentButton.selected = NO;
//        }];
//    });
    
}
#pragma mark - 懒加载
- (UIButton *)baseContentButton {
    if (!_baseContentButton) {
        _baseContentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _baseContentButton.selected = NO;
        _baseContentButton.tkThemebackgroundColors =  @[COLOR_CLEAR, COLOR_CLEAR];
        [_baseContentButton setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateSelected];
        [_baseContentButton setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateHighlighted];
        [_baseContentButton addTarget:self action:@selector(baseContentButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _baseContentButton;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
