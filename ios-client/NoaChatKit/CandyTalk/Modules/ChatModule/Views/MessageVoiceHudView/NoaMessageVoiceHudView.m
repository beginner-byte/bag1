//
//  NoaMessageVoiceHudView.m
//  NoaKit
//
//  Created by Candy on 2024/3/6.
//

#import "NoaMessageVoiceHudView.h"

@implementation NoaMessageVoiceHudView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    self.tkThemebackgroundColors = @[[HEXCOLOR(@"000000") colorWithAlphaComponent:0.6], [HEXCOLOR(@"000000") colorWithAlphaComponent:0.6]];
    self.layer.cornerRadius = 10;
    self.layer.tkThemeshadowColors = @[[HEXCOLOR(@"000000") colorWithAlphaComponent:0.25], [HEXCOLOR(@"000000") colorWithAlphaComponent:0.25]];
    self.layer.shadowOffset = CGSizeMake(4, 4);
    UILabel *content = [UILabel new];
    content.text = LanguageToolMatch(@"当前听筒播放");
    content.tkThemetextColors = @[HEXCOLOR(@"ffffff"), HEXCOLOR(@"ffffff")];
    content.font = FONTR(16);
    
    [self addSubview:content];
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(DWScale(24));
        make.centerX.mas_equalTo(self);
        make.leading.mas_equalTo(self).offset(DWScale(32));
        make.trailing.mas_equalTo(self).offset(DWScale(-32));
        make.top.mas_equalTo(self).offset(DWScale(10));
        make.bottom.mas_equalTo(self).offset(DWScale(-10));
    }];
    
}

@end
