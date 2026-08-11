//
//  NoaChatLinkCollectCell.m
//  NoaKit
//
//  Created by Candy on 2023/7/18.
//

#import "NoaChatLinkCollectCell.h"

@interface NoaChatLinkCollectCell ()

@property (nonatomic, strong) UIImageView *contentIcon;
@property (nonatomic, strong) UIButton *contentBtn;

@end

@implementation NoaChatLinkCollectCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    [self.contentView addSubview:self.contentIcon];
    [self.contentIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(DWScale(6));
        make.centerY.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(DWScale(18), DWScale(18)));
    }];
    
    [self.contentView addSubview:self.contentBtn];
    [self.contentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentIcon.mas_trailing).offset(DWScale(3));
        make.top.bottom.trailing.equalTo(self.contentView);
    }];
}

#pragma mark - Setter
- (void)setTagModel:(NoaChatTagModel *)tagModel {
    _tagModel = tagModel;
    
    [self.contentIcon sd_setImageWithURL:[_tagModel.tagIcon getImageFullUrl] placeholderImage:ImgNamed(@"mini_app_icon") options:SDWebImageAllowInvalidSSLCertificates];
    [self.contentBtn setTitle:_tagModel.tagName forState:UIControlStateNormal];
}

#pragma mark - Lazy
- (UIImageView *)contentIcon  {
    if (!_contentIcon) {
        _contentIcon = [[UIImageView alloc] init];
        _contentIcon.image = ImgNamed(@"mini_app_icon");
        [_contentIcon rounded:DWScale(18)/2];
    }
    return _contentIcon;
}

- (UIButton *)contentBtn {
    if (!_contentBtn) {
        _contentBtn = [[UIButton alloc] init];
        [_contentBtn setTitle:@"" forState:UIControlStateNormal];
        [_contentBtn setTkThemeTitleColor:@[COLOR_11, COLORWHITE] forState:UIControlStateNormal];
        _contentBtn.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        _contentBtn.titleLabel.font = FONTN(14);
        _contentBtn.userInteractionEnabled = NO;
    }
    return _contentBtn;
}

@end
