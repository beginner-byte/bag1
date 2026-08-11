//
//  NoaChatMultiSelectHeaderView.m
//  NoaKit
//
//  Created by Candy on 2023/4/12.
//

#import "NoaChatMultiSelectHeaderView.h"

@interface NoaChatMultiSelectHeaderView ()

@property (nonatomic, strong) UILabel *lblSectionName;

@end

@implementation NoaChatMultiSelectHeaderView

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
    _lblSectionName = [UILabel new];
    _lblSectionName.font = FONTB(14);
    _lblSectionName.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [self.contentView addSubview:_lblSectionName];
    [_lblSectionName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(DWScale(16));
    }];
}

- (void)setSectionTitle:(NSString *)sectionTitle {
    _sectionTitle = sectionTitle;
    _lblSectionName.text = _sectionTitle;
}


@end
