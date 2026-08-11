//
//  NoaRuleRewardHeader.m
//  NoaKit
//
//  Created by Candy on 2024/12/26.
//

#import "NoaRuleRewardHeader.h"

@implementation NoaRuleRewardHeader

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    UIView *topLine = [[UIView alloc] init];
    topLine.tkThemebackgroundColors = @[COLOR_99, COLOR_99];
    [self.contentView addSubview:topLine];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(self.contentView);
        make.height.mas_equalTo(1);
    }];
    
    UIView *leftLine = [[UIView alloc] init];
    leftLine.tkThemebackgroundColors = @[COLOR_99, COLOR_99];
    [self.contentView addSubview:leftLine];
    [leftLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.equalTo(self.contentView);
        make.width.mas_equalTo(1);
    }];
    
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.tkThemebackgroundColors = @[COLOR_99, COLOR_99];
    [self.contentView addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.equalTo(self.contentView);
        make.height.mas_equalTo(1);
    }];
    
    UIView *rightLine = [[UIView alloc] init];
    rightLine.tkThemebackgroundColors = @[COLOR_99, COLOR_99];
    [self.contentView addSubview:rightLine];
    [rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.top.bottom.equalTo(self.contentView);
        make.width.mas_equalTo(1);
    }];
    
    UILabel *leftLabel = [[UILabel alloc] init];
    leftLabel.text = LanguageToolMatch(@"当月连续签到成功天数");
    leftLabel.tkThemetextColors = @[COLOR_11, COLORWHITE];
    leftLabel.font = FONTN(14);
    leftLabel.numberOfLines = 2;
    leftLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:leftLabel];
    [leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(leftLine.mas_trailing);
        make.top.equalTo(topLine.mas_bottom);
        make.bottom.equalTo(bottomLine.mas_top);
        make.width.mas_equalTo((DScreenWidth - DWScale(16) * 2) * 0.6);
    }];
    
    UILabel *rightLabel = [[UILabel alloc] init];
    rightLabel.text = LanguageToolMatch(@"奖励积分");
    rightLabel.tkThemetextColors = @[COLOR_11, COLORWHITE];
    rightLabel.font = FONTN(14);
    rightLabel.numberOfLines = 2;
    rightLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:rightLabel];
    [rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topLine.mas_bottom);
        make.trailing.equalTo(rightLine.mas_leading);
        make.bottom.equalTo(bottomLine.mas_top);
        make.leading.equalTo(leftLabel.mas_trailing);
    }];
    
    UIView *centerLine = [[UIView alloc] init];
    centerLine.tkThemebackgroundColors = @[COLOR_99, COLOR_99];
    [self.contentView addSubview:centerLine];
    [centerLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.contentView);
        make.leading.equalTo(leftLabel.mas_trailing);
        make.width.mas_equalTo(1);
    }];
}

@end
