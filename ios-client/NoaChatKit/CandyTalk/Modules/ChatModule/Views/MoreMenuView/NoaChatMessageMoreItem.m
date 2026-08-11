//
//  NoaChatMessageMoreItem.m
//  NoaKit
//
//  Created by Candy on 2026/9/29.
//

#import "NoaChatMessageMoreItem.h"

@implementation NoaChatMessageMoreItem
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    _ivImage = [UIImageView new];
    [self.contentView addSubview:_ivImage];
    [_ivImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(DWScale(10));
        make.centerX.equalTo(self.contentView);
    }];
    
    _lblTitle = [UILabel new];
    _lblTitle.tkThemetextColors = @[COLORWHITE, COLORWHITE];
    _lblTitle.font = FONTR(12);
    _lblTitle.text = @"";
    _lblTitle.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_lblTitle];
    [_lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(-DWScale(10));
        make.width.mas_equalTo(DWScale(60));
    }];
}

@end
