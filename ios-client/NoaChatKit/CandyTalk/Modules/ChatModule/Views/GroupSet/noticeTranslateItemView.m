//
//  noticeTranslateItemView.m
//  NoaKit
//
//  Created by Candy on 2024/2/18.
//

#import "noticeTranslateItemView.h"

@interface noticeTranslateItemView()

@property(nonatomic, strong)UITextField *contentText;

@end

@implementation noticeTranslateItemView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self rounded:DWScale(4) width:1 color:COLOR_E6E6E6];
    
    UIImageView *arrowImgView = [[UIImageView alloc] init];
    arrowImgView.image = ImgNamed(@"icon_group_drop_arrow");
    [self addSubview:arrowImgView];
    [arrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-DWScale(12));
        make.centerY.equalTo(self);
        make.width.height.mas_equalTo(DWScale(16));
    }];
    
    [self addSubview:self.contentText];
    [self.contentText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(DWScale(12));
        make.top.bottom.equalTo(self);
        make.trailing.equalTo(arrowImgView.mas_leading).offset(-DWScale(10));
    }];
    
    UITapGestureRecognizer *clickTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentClick)];
    [self addGestureRecognizer:clickTap];
}

#pragma mark - Setter
- (void)setContentStr:(NSString *)contentStr {
    _contentStr = contentStr;
    
    self.contentText.text = _contentStr;
}

#pragma mark - Action
- (void)contentClick {
    if (self.textInputClick) {
        self.textInputClick();
    }
}

#pragma mark - Lazy
- (UITextField *)contentText {
    if (!_contentText) {
        _contentText = [[UITextField alloc] init];
        _contentText.placeholder = LanguageToolMatch(@"请选择");
        _contentText.font = FONTN(14);
        _contentText.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _contentText.enabled = NO;
    }
    return _contentText;
}

@end
