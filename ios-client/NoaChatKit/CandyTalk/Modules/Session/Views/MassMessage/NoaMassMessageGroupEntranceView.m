//
//  NoaMassMessageGroupEntranceView.m
//  NoaKit
//
//  Created by Candy on 2023/9/4.
//

#import "NoaMassMessageGroupEntranceView.h"

@implementation NoaMassMessageGroupEntranceView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    UIImageView *arrowImgView = [[UIImageView alloc] initWithImage:ImgNamed(@"c_arrow_right_gray")];
    [self addSubview:arrowImgView];
    [arrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-DWScale(25));
        make.centerY.equalTo(self);
        make.width.mas_equalTo(DWScale(8));
        make.height.mas_equalTo(DWScale(16));
    }];
    
    UILabel *titleLbl = [UILabel new];
    titleLbl.text = LanguageToolMatch(@"选择群聊");
    titleLbl.tkThemetextColors = @[COLOR_11, COLORWHITE];
    titleLbl.font = FONTN(16);
    [self addSubview:titleLbl];
    [titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(DWScale(16));
        make.centerY.equalTo(self);
        make.trailing.equalTo(arrowImgView.mas_leading).offset(-DWScale(15));
        make.height.mas_equalTo(DWScale(25));
    }];
    
    UIView *bottomLine = [UIView new];
    bottomLine.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F6F6F6_DARK];
    [self addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(DWScale(16));
        make.bottom.equalTo(self);
        make.trailing.equalTo(self).offset(-DWScale(16));
        make.height.mas_equalTo(DWScale(1));
    }];
    
    UIControl *clickAction = [[UIControl alloc] init];
    [clickAction addTarget:self action:@selector(entranceIntoAvtion) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:clickAction];
    [clickAction mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)entranceIntoAvtion {
    if (_delegate && [_delegate respondsToSelector:@selector(GroupEntranceAction)]) {
        [_delegate GroupEntranceAction];
    }
}

@end
