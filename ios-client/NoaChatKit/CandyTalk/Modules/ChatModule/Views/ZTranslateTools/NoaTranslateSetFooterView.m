//
//  NoaTranslateSetFooterView.m
//  NoaKit
//
//  Created by Candy on 2023/12/27.
//

#import "NoaTranslateSetFooterView.h"

@interface NoaTranslateSetFooterView()

@property (nonatomic, strong)UIView *bgView;
@property (nonatomic, strong)UILabel *titleLbl;
@property (nonatomic, strong)UILabel *residueChartLbl;
@property (nonatomic, strong)UILabel *userdChartLbl;

@end

@implementation NoaTranslateSetFooterView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
        [self setupUI];
    }
    return self;
}

#pragma mark - 界面布局
- (void)setupUI {
    _bgView = [UIView new];
    _bgView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    [_bgView rounded:DWScale(12)];
    [self.contentView addSubview:_bgView];
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(self.contentView).offset(DWScale(16));
        make.trailing.equalTo(self.contentView).offset(-DWScale(16));
        make.bottom.equalTo(self.contentView);
    }];
    
    _titleLbl = [UILabel new];
    _titleLbl.text = LanguageToolMatch(@"翻译字符");
    _titleLbl.font = FONTB(16);
    _titleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [_bgView addSubview:_titleLbl];
    [_titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_bgView);
        make.leading.equalTo(_bgView).offset(DWScale(16));
        make.trailing.equalTo(_bgView).offset(-DWScale(16));
        make.height.mas_equalTo(DWScale(54));
    }];
    
    _residueChartLbl = [UILabel new];
    _residueChartLbl.font = FONTN(16);
    [_bgView addSubview:_residueChartLbl];
    [_residueChartLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLbl.mas_bottom);
        make.leading.trailing.equalTo(_titleLbl);
        make.height.mas_equalTo(DWScale(54));
    }];
    
    _userdChartLbl = [UILabel new];
    _userdChartLbl.font = FONTN(16);
    [_bgView addSubview:_userdChartLbl];
    [_userdChartLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_residueChartLbl.mas_bottom);
        make.leading.trailing.equalTo(_titleLbl);
        make.height.mas_equalTo(DWScale(54));
    }];
    
    UITapGestureRecognizer *footerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(footerTapAction)];
    [_bgView addGestureRecognizer:footerTap];
}

- (void)setIsBinded:(BOOL)isBinded {
    _isBinded = isBinded;
    if (_isBinded) {
        _userdChartLbl.hidden = NO;
    } else {
        _userdChartLbl.hidden = YES;
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"您还未绑定翻译账户，请完成绑定")];
        [attStr configAttStrLightColor:COLOR_99 darkColor:COLOR_99 range:NSMakeRange(0, attStr.length)];
        _residueChartLbl.attributedText = attStr;
    }
}

- (void)setResidueChartStr:(NSString *)residueChartStr {
    _residueChartStr = residueChartStr;
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"剩余字符：%@"), _residueChartStr]];
    [attStr configAttStrLightColor:COLOR_11 darkColor:COLOR_11_DARK range:NSMakeRange(0, attStr.length)];
    [attStr configAttStrLightColor:COLOR_99 darkColor:COLOR_99 range:NSMakeRange(attStr.length - _residueChartStr.length, _residueChartStr.length)];
    _residueChartLbl.attributedText = attStr;
}

- (void)setUserdChartStr:(NSString *)userdChartStr {
    _userdChartStr = userdChartStr;
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LanguageToolMatch(@"已使用余字符：%@"), _userdChartStr]];
    [attStr configAttStrLightColor:COLOR_11 darkColor:COLOR_11_DARK range:NSMakeRange(0, attStr.length)];
    [attStr configAttStrLightColor:COLOR_99 darkColor:COLOR_99 range:NSMakeRange(attStr.length - _userdChartStr.length, _userdChartStr.length)];
    _userdChartLbl.attributedText = attStr;
}

- (void)footerTapAction {
    if(_isBinded == NO) {
        if (self.footerViewClick) {
            self.footerViewClick();
        }
    }
}

@end
