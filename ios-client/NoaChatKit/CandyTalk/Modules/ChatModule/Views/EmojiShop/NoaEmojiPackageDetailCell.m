//
//  NoaEmojiPackageDetailCell.m
//  NoaKit
//
//  Created by Candy on 2023/10/25.
//

#import "NoaEmojiPackageDetailCell.h"

@interface NoaEmojiPackageDetailCell()

@property (nonatomic, strong) UIImageView *emojiItemImgView;
@property (nonatomic, strong) UILabel *emojiNameLbl;

@end

@implementation NoaEmojiPackageDetailCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    _emojiItemImgView = [[UIImageView alloc] init];
    _emojiItemImgView.contentMode = UIViewContentModeScaleAspectFit;
    [_emojiItemImgView rounded:DWScale(8)];
    [self.contentView addSubview:_emojiItemImgView];
    [_emojiItemImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(DWScale(10));
        make.trailing.equalTo(self.contentView).offset(-DWScale(10));
        make.width.height.mas_equalTo(DWScale(70));
    }];
    
    _emojiNameLbl = [[UILabel alloc] init];
    _emojiNameLbl.text = @"";
    _emojiNameLbl.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    _emojiNameLbl.font = FONTN(14);
    _emojiNameLbl.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_emojiNameLbl];
    [_emojiNameLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(DWScale(10));
        make.trailing.equalTo(self.contentView).offset(-DWScale(10));
        make.top.equalTo(_emojiItemImgView.mas_bottom).offset(DWScale(6));
        make.height.mas_equalTo(DWScale(20));
    }];
}

#pragma mark - Model
- (void)setModel:(NoaIMStickersModel *)model {
    _model = model;
    
    [_emojiItemImgView sd_setImageWithURL:[_model.thumbUrl getImageFullUrl] placeholderImage:DefaultImage options:SDWebImageAllowInvalidSSLCertificates];
    _emojiNameLbl.text = _model.name;
}


@end
