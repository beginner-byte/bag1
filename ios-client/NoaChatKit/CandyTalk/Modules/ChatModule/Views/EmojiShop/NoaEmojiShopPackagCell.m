//
//  NoaEmojiShopPackagCell.m
//  NoaKit
//
//  Created by Candy on 2023/10/25.
//

#import "NoaEmojiShopPackagCell.h"

@interface NoaEmojiShopPackagCell()

@property (nonatomic, strong) UIImageView *packageImgView;
@property (nonatomic, strong) UILabel *packageNameLbl;
@property (nonatomic, strong) UIButton *packageAddBtn;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation NoaEmojiShopPackagCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = UIColor.clearColor;
        self.backgroundColor = UIColor.clearColor;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self.contentView addSubview:self.packageImgView];
    [self.contentView addSubview:self.packageNameLbl];
    [self.contentView addSubview:self.packageAddBtn];
    [self.contentView addSubview:self.lineView];
    
    [self.packageImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(DWScale(16));
        make.width.height.mas_equalTo(DWScale(70));
    }];
    
    [self.packageAddBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-DWScale(16));
        make.width.mas_equalTo(DWScale(72));
        make.height.mas_equalTo(DWScale(34));
    }];
    
    [self.packageNameLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.packageImgView.mas_trailing).offset(DWScale(10));
        make.trailing.equalTo(self.packageAddBtn.mas_leading).offset(DWScale(-15));
        make.height.mas_equalTo(DWScale(22));
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(16);
        make.trailing.equalTo(self.contentView).offset(-16);
        make.height.mas_equalTo(0.8);
    }];
}

#pragma mark - Data
- (void)setModel:(NoaIMStickersPackageModel *)model {
    _model = model;
    
    [_packageImgView sd_setImageWithURL:[_model.thumbUrl getImageFullUrl] placeholderImage:DefaultImage options:SDWebImageAllowInvalidSSLCertificates];
    _packageNameLbl.text = _model.name;
    if (_model.isDownLoad) {
        [_packageAddBtn setTitle:LanguageToolMatch(@"已添加") forState:UIControlStateNormal];
        _packageAddBtn.tkThemebackgroundColors = @[COLOR_99, COLOR_99_DARK];
        _packageAddBtn.enabled = NO;
    } else {
        [_packageAddBtn setTitle:LanguageToolMatch(@"添加") forState:UIControlStateNormal];
        _packageAddBtn.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2];
        _packageAddBtn.enabled = YES;
    }
}

#pragma mark - Action
- (void)addEmojiPackageClick {
    if (self.delegate && [self.delegate respondsToSelector:@selector(emojiPackageAddNewEmoji:)]) {
        [self.delegate emojiPackageAddNewEmoji:self.baseCellIndexPath];
    }
}

#pragma mark - Lazy
- (UIImageView *)packageImgView {
    if (!_packageImgView) {
        _packageImgView = [[UIImageView alloc] init];
        _packageImgView.contentMode = UIViewContentModeScaleAspectFit;
        [_packageImgView rounded:DWScale(4)];
    }
    return _packageImgView;
}

- (UILabel *)packageNameLbl {
    if (!_packageNameLbl) {
        _packageNameLbl = [[UILabel alloc] init];
        _packageNameLbl.text = LanguageToolMatch(@"表情包名称");
        _packageNameLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _packageNameLbl.font = FONTN(14);
        [_packageNameLbl sizeToFit];
    }
    return _packageNameLbl;
}

- (UIButton *)packageAddBtn {
    if (!_packageAddBtn) {
        _packageAddBtn = [[UIButton alloc] init];
        [_packageAddBtn setTitle:LanguageToolMatch(@"添加") forState:UIControlStateNormal];
        [_packageAddBtn setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
        _packageAddBtn.titleLabel.font = FONTN(14);
        _packageAddBtn.tkThemebackgroundColors = @[COLOR_99, COLOR_99_DARK];
        _packageAddBtn.enabled = NO;
        [_packageAddBtn rounded:DWScale(4)];
        [_packageAddBtn addTarget:self action:@selector(addEmojiPackageClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _packageAddBtn;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.tkThemebackgroundColors = @[COLOR_EEEEEE, COLOR_EEEEEE_DARK];
    }
    return _lineView;
}

@end
