//
//  NoaFilePickerHeaderView.m
//  NoaKit
//
//  Created by Candy on 2023/1/4.
//

#import "NoaFilePickerHeaderView.h"

@interface NoaFilePickerHeaderView ()

@property (nonatomic, strong)UIView *backView;
@property (nonatomic, strong)UILabel *contentLbl;
@property (nonatomic, strong)UIImageView *arrowImgView;

@end

@implementation NoaFilePickerHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self.contentView addSubview:self.backView];
    [self.backView addSubview:self.contentLbl];
    [self.backView addSubview:self.arrowImgView];
    
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [self.arrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backView);
        make.trailing.equalTo(self.backView).offset(-16);
        make.width.mas_equalTo(DWScale(8));
        make.height.mas_equalTo(DWScale(16));
    }];
    
    [self.contentLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.backView).offset(16);
        make.centerY.equalTo(self.backView);
        make.trailing.equalTo(self.arrowImgView.mas_leading).offset(-15);
        make.height.mas_equalTo(DWScale(25));
    }];
    
    UITapGestureRecognizer *headerBackTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerBackClick)];
    [self.backView addGestureRecognizer:headerBackTap];
}

#pragma mark - Data
- (void)setContentStr:(NSString *)contentStr {
    _contentStr = contentStr;
    self.contentLbl.text = _contentStr;
}

- (void)setUnFlod:(BOOL)unFlod {
    _unFlod = unFlod;
    if (_unFlod) {
        //展开
        self.backView.tkThemebackgroundColors = @[COLOR_EEEEEE, COLOR_4E4E4E_DARK];
        self.arrowImgView.image = ImgNamed(@"c_arrow_down_darkgray");
        [self.arrowImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.backView);
            make.trailing.equalTo(self.backView).offset(-16);
            make.width.mas_equalTo(DWScale(16));
            make.height.mas_equalTo(DWScale(8));
        }];
    } else {
        //未展开
        self.backView.tkThemebackgroundColors = @[COLORWHITE, COLOR_F5F6F9_DARK];
        self.arrowImgView.image = ImgNamed(@"c_arrow_right_darkgray");
        [self.arrowImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.backView);
            make.trailing.equalTo(self.backView).offset(-16);
            make.width.mas_equalTo(DWScale(8));
            make.height.mas_equalTo(DWScale(16));
        }];
    }
}

#pragma mark - Tap Click
- (void)headerBackClick {
    if (self.ZFileHeaderClick) {
        self.ZFileHeaderClick();
    }
}

#pragma mark - Lazy
- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.tkThemebackgroundColors = @[COLORWHITE, COLOR_4E4E4E_DARK];
    }
    return _backView;
}

- (UIImageView *)arrowImgView {
    if (!_arrowImgView) {
        _arrowImgView = [[UIImageView alloc] init];
        _arrowImgView.image = ImgNamed(@"c_arrow_right_darkgray");
    }
    return _arrowImgView;
}

- (UILabel *)contentLbl {
    if (!_contentLbl) {
        _contentLbl = [[UILabel alloc] init];
        _contentLbl.text = @"";
        _contentLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _contentLbl.font = FONTN(16);
    }
    return _contentLbl;
}

@end
