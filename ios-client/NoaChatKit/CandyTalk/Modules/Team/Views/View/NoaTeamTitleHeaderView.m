//
//  NoaTeamTitleHeaderView.m
//  NoaKit
//
//  Created by Candy on 2023/9/8.
//

#import "NoaTeamTitleHeaderView.h"

@interface NoaTeamTitleHeaderView ()

@end

@implementation NoaTeamTitleHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    //默认团队-标题
    UIImageView *defaultTeamTipImg = [UIImageView new];
    defaultTeamTipImg.image = ImgNamed(@"img_team_tip");
    [self addSubview:defaultTeamTipImg];
    [defaultTeamTipImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(DWScale(16));
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(DWScale(22), DWScale(22)));
    }];
    
    UILabel *defaultTeamTitleLbl = [UILabel new];
    defaultTeamTitleLbl.text = LanguageToolMatch(@"默认团队");
    defaultTeamTitleLbl.font = FONTR(14);
    defaultTeamTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [self addSubview:defaultTeamTitleLbl];
    [defaultTeamTitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(defaultTeamTipImg);
        make.leading.equalTo(defaultTeamTipImg.mas_trailing).offset(DWScale(10));
        make.trailing.equalTo(self.mas_trailing).offset(DWScale(-16));
    }];
    defaultTeamTitleLbl.numberOfLines = 2;
}

@end
