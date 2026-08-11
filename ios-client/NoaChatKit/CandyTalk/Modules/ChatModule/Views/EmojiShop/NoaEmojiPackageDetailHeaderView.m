//
//  NoaEmojiPackageDetailHeaderView.m
//  NoaKit
//
//  Created by Candy on 2023/10/25.
//

#import "NoaEmojiPackageDetailHeaderView.h"

@interface NoaEmojiPackageDetailHeaderView ()

@property (nonatomic, strong) UIImageView *packageCover;
@property (nonatomic, strong) UILabel *titleLbl;
@property (nonatomic, strong) UILabel *desTitleLbl;
@property (nonatomic, strong) UIButton *addPackageBtn;
  
@end


@implementation NoaEmojiPackageDetailHeaderView

-(id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setupUI];
  }
  return self;
}

- (void)setupUI {
    [self addSubview:self.packageCover];
    [self.packageCover mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self);
        make.height.mas_equalTo(DWScale(210));
    }];
    
    [self addSubview:self.addPackageBtn];
    [self.addPackageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-DWScale(16));
        make.top.equalTo(self.packageCover.mas_bottom).offset(DWScale(26));
        make.width.mas_equalTo(DWScale(72));
        make.height.mas_equalTo(DWScale(34));
    }];
    
    [self addSubview:self.titleLbl];
    [self.titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(DWScale(16));
        make.top.equalTo(self.packageCover.mas_bottom).offset(DWScale(20));
        make.trailing.equalTo(self.addPackageBtn.mas_leading).offset(-DWScale(16));
        make.height.mas_equalTo(DWScale(18));
    }];
    
    [self addSubview:self.desTitleLbl];
    [self.desTitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(DWScale(16));
        make.trailing.equalTo(self.addPackageBtn.mas_leading).offset(-DWScale(16));
        make.top.equalTo(self.titleLbl.mas_bottom).offset(DWScale(10));
        make.height.mas_equalTo(DWScale(18));
    }];
}

#pragma mark - Data
- (void)setModel:(NoaIMStickersPackageModel *)model {
    _model = model;
    if (_model) {
        [_packageCover sd_setImageWithURL:[_model.thumbUrl getImageFullUrl] placeholderImage:DefaultImage options:SDWebImageAllowInvalidSSLCertificates];
        _titleLbl.text = _model.name;
        _desTitleLbl.text = _model.stickersDes;
        if (_model.isDownLoad) {
            [_addPackageBtn setTitle:LanguageToolMatch(@"已添加") forState:UIControlStateNormal];
            _addPackageBtn.tkThemebackgroundColors = @[COLOR_99, COLOR_99_DARK];
            _addPackageBtn.enabled = NO;
        } else {
            [_addPackageBtn setTitle:LanguageToolMatch(@"添加") forState:UIControlStateNormal];
            _addPackageBtn.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2];
            _addPackageBtn.enabled = YES;
        }
    }
}

#pragma mark - Action
- (void)addEmojiPackageClick {
    if ([self.delegate respondsToSelector:@selector(addStrickersPackageAction)]) {
        [self.delegate addStrickersPackageAction];
    }
}

#pragma mark - Lazy
- (UIImageView *)packageCover {
    if (!_packageCover) {
        _packageCover = [[UIImageView alloc] init];
        _packageCover.frame = CGRectMake(0, 0, DScreenWidth, DWScale(210));
        _packageCover.contentMode = UIViewContentModeScaleAspectFill;
        _packageCover.clipsToBounds = YES;
    }
    return _packageCover;
}

- (UILabel *)titleLbl {
    if (!_titleLbl) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.text = @"--";
        _titleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _titleLbl.font = FONTR(16);
    }
    return _titleLbl;
}

- (UILabel *)desTitleLbl {
    if (!_desTitleLbl) {
        _desTitleLbl = [[UILabel alloc] init];
        _desTitleLbl.text = @"--";
        _desTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _desTitleLbl.font = FONTR(12);
    }
    return _desTitleLbl;
}

- (UIButton *)addPackageBtn {
    if (!_addPackageBtn) {
        _addPackageBtn = [[UIButton alloc] init];
        [_addPackageBtn setTitle:LanguageToolMatch(@"添加") forState:UIControlStateNormal];
        [_addPackageBtn setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
        _addPackageBtn.titleLabel.font = FONTN(14);
        _addPackageBtn.tkThemebackgroundColors = @[COLOR_99, COLOR_99_DARK];
        _addPackageBtn.enabled = NO;
        [_addPackageBtn rounded:DWScale(4)];
        [_addPackageBtn addTarget:self action:@selector(addEmojiPackageClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addPackageBtn;
}



@end
