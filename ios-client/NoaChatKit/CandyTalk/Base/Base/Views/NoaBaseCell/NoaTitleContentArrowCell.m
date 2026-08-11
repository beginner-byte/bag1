//
//  NoaTitleContentArrowCell.m
//  NoaKit
//
//  Created by Candy on 2026/9/13.
//

#import "NoaTitleContentArrowCell.h"

@implementation NoaTitleContentArrowCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    [self.contentView addSubview:self.baseContentButton];
    [self.baseContentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    _lblTitle = [UILabel new];
    //_lblTitle.text = @"标题";
    _lblTitle.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _lblTitle.font = FONTR(16);
    [self.contentView addSubview:_lblTitle];
    [_lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(DWScale(16));
        make.top.equalTo(self.contentView).offset(DWScale(16));
        make.bottom.equalTo(self.contentView).offset(-DWScale(16));
        make.width.mas_lessThanOrEqualTo(DWScale(150));
        make.height.mas_greaterThanOrEqualTo(DWScale(22));
    }];
    
    _lblContent = [UILabel new];
    //_lblContent.text = @"内容";
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
    
    _viewLine = [UIView new];
    _viewLine.hidden = YES;
    _viewLine.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11_DARK];
    [self.contentView addSubview:_viewLine];
    [_viewLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.equalTo(self.contentView);
        make.height.mas_equalTo(1);
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
