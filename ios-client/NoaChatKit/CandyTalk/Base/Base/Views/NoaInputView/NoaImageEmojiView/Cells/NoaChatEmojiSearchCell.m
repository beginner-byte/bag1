//
//  NoaChatEmojiSearchCell.m
//  NoaKit
//
//  Created by Candy on 2023/10/25.
//

#import "NoaChatEmojiSearchCell.h"

@interface NoaChatEmojiSearchCell()

@property (nonatomic, strong) UIImageView *emojiItemImgView;
@property (nonatomic, strong) UILabel *emojiNameLbl;

@end

@implementation NoaChatEmojiSearchCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        self.contentView.userInteractionEnabled = YES;
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    _emojiItemImgView = [[UIImageView alloc] init];
    [_emojiItemImgView rounded:DWScale(8)];
    _emojiItemImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_emojiItemImgView];
    [_emojiItemImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(DWScale(10));
        make.trailing.equalTo(self.contentView).offset(-DWScale(10));
        make.top.equalTo(self.contentView).offset(DWScale(8));
        make.bottom.equalTo(self.contentView).offset(-(DWScale(26)+DWScale(12)));
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
    
    UILongPressGestureRecognizer *stickersLongTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(stickersLongTapClick:)];
    [self.contentView addGestureRecognizer:stickersLongTap];
}

#pragma mark - Model
- (void)setStickersModel:(NoaIMStickersModel *)stickersModel {
    _stickersModel = stickersModel;
    
    [_emojiItemImgView sd_setImageWithURL:[_stickersModel.thumbUrl getImageFullUrl] placeholderImage:DefaultImage options:SDWebImageAllowInvalidSSLCertificates];
    _emojiNameLbl.text = _stickersModel.name;
}

#pragma mark - Action
- (void)stickersLongTapClick:(UILongPressGestureRecognizer *)longPressGesture {
    if (longPressGesture.state == UIGestureRecognizerStateBegan){
        if ([self.delegate respondsToSelector:@selector(searchStickerResultLongTapAction:)]) {
            [self.delegate searchStickerResultLongTapAction:self.cellIndexPath];
        }
    }
}

@end
