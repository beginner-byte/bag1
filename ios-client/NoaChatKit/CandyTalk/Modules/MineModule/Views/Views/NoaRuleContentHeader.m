//
//  NoaRuleContentHeader.m
//  NoaKit
//
//  Created by Candy on 2024/12/26.
//

#import "NoaRuleContentHeader.h"

@interface NoaRuleContentHeader()

@property (nonatomic, strong) UILabel *ruleTipLabel;

@end

@implementation NoaRuleContentHeader

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
    self.ruleTipLabel = [[UILabel alloc] init];
    self.ruleTipLabel.numberOfLines = 0;
    self.ruleTipLabel.tkThemetextColors = @[COLOR_11, COLORWHITE];
    [self.contentView addSubview:self.ruleTipLabel];
    [self.ruleTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (void)setRuleContentAtt:(NSMutableAttributedString *)ruleContentAtt {
    _ruleContentAtt = ruleContentAtt;

    self.ruleTipLabel.attributedText = _ruleContentAtt;
}

@end
