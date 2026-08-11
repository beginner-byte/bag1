//
//  NoaGlobalSearchSectionHeaderView.m
//  NoaKit
//
//  Created by Candy on 2026/9/15.
//

#import "NoaGlobalSearchSectionHeaderView.h"

@interface NoaGlobalSearchSectionHeaderView ()
@property (nonatomic, strong) UILabel *lblTitle;
@end

@implementation NoaGlobalSearchSectionHeaderView
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
    _lblTitle = [UILabel new];
    _lblTitle.font = FONTR(12);
    _lblTitle.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    [self.contentView addSubview:_lblTitle];
    [_lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(DWScale(16));
    }];
    
}
#pragma mark - 界面赋值
- (void)setHeaderSection:(NSInteger)headerSection {
    _headerSection = headerSection;
    
    if (headerSection == 0) {
        _lblTitle.text = LanguageToolMatch(@"联系人");
    }else if (headerSection == 1) {
        _lblTitle.text = LanguageToolMatch(@"群聊");
    }else if (headerSection == 2) {
        _lblTitle.text = LanguageToolMatch(@"聊天记录");
    }else {
        _lblTitle.text = @"";
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
