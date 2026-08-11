//
//  NoaNoDataView.m
//  NoaKit
//
//  Created by Candy on 2026/9/15.
//

#import "NoaNoDataView.h"

@implementation NoaNoDataView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    _lblNoDataTip = [UILabel new];
    _lblNoDataTip.text = LanguageToolMatch(@"暂无数据");
    _lblNoDataTip.font = FONTR(16);
    _lblNoDataTip.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    [self addSubview:_lblNoDataTip];
    [_lblNoDataTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_lessThanOrEqualTo(DScreenWidth - DWScale(60));
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
