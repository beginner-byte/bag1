//
//  NoaBaseCollectionCell.m
//  NoaKit
//
//  Created by Candy on 2023/1/10.
//

#import "NoaBaseCollectionCell.h"

@implementation NoaBaseCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = UIColor.clearColor;
        self.backgroundColor = UIColor.clearColor;
    }
    return self;
}

+ (CGSize)defaultCellSize {
    return CGSizeZero;
}

+ (NSString *)cellIdentifier {
    return NSStringFromClass(self);
}

#pragma mark - 交互事件
- (void)baseContentButtonClick {
    if (_baseCellDelegate && [_baseCellDelegate respondsToSelector:@selector(baseCellDidSelectedRowAtIndexPath:)]) {
        [_baseCellDelegate baseCellDidSelectedRowAtIndexPath:self.baseCellIndexPath];
    }
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

@end
