//
//  NoaImageTitleContentArrowCell.m
//  NoaKit
//
//  Created by Candy on 2026/9/23.
//

#import "NoaImageTitleContentArrowCell.h"

@implementation NoaImageTitleContentArrowCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.tkThemebackgroundColors = @[COLORWHITE, COLOR_22];
        self.tkThemebackgroundColors = @[COLORWHITE, COLOR_22];
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    [self.contentView addSubview:self.baseContentButton];
    self.baseContentButton.frame = CGRectMake(0, 0, self.contentView.width, DWScale(54));
    
    _ivLogo = [UIImageView new];
    [self.contentView addSubview:_ivLogo];
    [_ivLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(20), DWScale(20)));
    }];
    
    _lblTitle = [UILabel new];
    _lblTitle.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _lblTitle.numberOfLines = 2;
    _lblTitle.font = FONTR(16);
    [self.contentView addSubview:_lblTitle];
    [_lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_ivLogo.mas_trailing).offset(DWScale(10));
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView);
    }];
    
    _lblContent = [UILabel new];
    _lblContent.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    _lblContent.font = FONTR(14);
    [self.contentView addSubview:_lblContent];
    
    _ivArrow = [[UIImageView alloc] initWithImage:ImgNamed(@"c_arrow_right_gray")];
    [self.contentView addSubview:_ivArrow];
    [_ivArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(8), DWScale(16)));
    }];
    
    [_lblContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(_ivArrow.mas_leading).offset(-DWScale(10));
        make.width.mas_lessThanOrEqualTo(DWScale(150));
    }];
}

+ (CGFloat)defaultCellHeight {
    return DWScale(54);
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
