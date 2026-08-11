//
//  NoaCountryCodeCell.m
//  NoaKit
//
//  Created by Candy on 2023/3/28.
//

#import "NoaCountryCodeCell.h"

@interface NoaCountryCodeCell()

@property (nonatomic, strong)UILabel *nameLbl;
@property (nonatomic, strong)UILabel *codeLbl;
@property (nonatomic, strong)UIView *bottomLine;

@end

@implementation NoaCountryCodeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        [self setupUI];
    }
    return self;
}

#pragma mark - 界面布局
- (void)setupUI {
    [self.contentView addSubview:self.codeLbl];
    [self.codeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(DWScale(-15));
        make.width.mas_equalTo(DWScale(60));
        make.height.mas_equalTo(DWScale(35));
    }];
    
    [self.contentView addSubview:self.nameLbl];
    [self.nameLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(DWScale(15));
        make.trailing.equalTo(self.codeLbl.mas_leading).offset(DWScale(-15));
        make.height.mas_equalTo(DWScale(35));
    }];
    
    [self.contentView addSubview:self.bottomLine];
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(DWScale(15));
        make.trailing.equalTo(self.contentView).offset(DWScale(-15));
        make.height.mas_equalTo(0.8);
    }];
}

- (void)setCountryDic:(NSDictionary *)countryDic {
    _countryDic = countryDic;
    self.nameLbl.text = (NSString *)[_countryDic objectForKey:ZLanguageTOOL.currentLanguage.languageAbbr];
    self.codeLbl.text = [NSString stringWithFormat:@"+%@",(NSString *)[_countryDic objectForKey:@"prefix"]];
}

#pragma mark - Lazy
- (UILabel *)nameLbl {
    if (!_nameLbl) {
        _nameLbl = [[UILabel alloc] init];
        _nameLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _nameLbl.font = FONTN(17);
        _nameLbl.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLbl;
}

- (UILabel *)codeLbl {
    if (!_codeLbl) {
        _codeLbl = [[UILabel alloc] init];
        _codeLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _codeLbl.font = FONTN(17);
        _codeLbl.textAlignment = NSTextAlignmentCenter;
    }
    return _codeLbl;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.tkThemebackgroundColors = @[COLOR_DFDFDF, COLOR_555555];
    }
    return _bottomLine;
}

#pragma mark - Other
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
