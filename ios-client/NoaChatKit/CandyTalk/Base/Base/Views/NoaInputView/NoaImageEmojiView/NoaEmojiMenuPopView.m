//
//  NoaEmojiMenuPopView.m
//  NoaKit
//
//  Created by Candy on 2023/8/15.
//

#import "NoaEmojiMenuPopView.h"

@interface NoaEmojiMenuPopView()

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, copy) NSString *menuTitle;
@property (nonatomic, assign) CGRect targetRect;

@end

@implementation NoaEmojiMenuPopView

- (instancetype)initWithMenuTitle:(NSString *)menuTitle targetRect:(CGRect)targetRect {
    self = [super init];
    if (self) {
        _menuTitle = menuTitle;
        _targetRect = targetRect;
    }
    return self;
}

- (void)ZEmojiMenuShow {
    _backView = [[UIView alloc] init];
    _backView.backgroundColor = COLOR_CLEAR;
    _backView.frame = CGRectMake(0, 0, DScreenWidth, DScreenHeight);
    [CurrentVC.view addSubview:_backView];
    
    CGFloat menuTitleWidth = [_menuTitle widthForFont:FONTN(12)];
    self.frame = CGRectMake(_targetRect.origin.x+_targetRect.size.width/2 - (menuTitleWidth + DWScale(24))/2, _targetRect.origin.y - DWScale(28) + DWScale(3), menuTitleWidth + DWScale(24), DWScale(28));
    [_backView addSubview:self];
    
    UITapGestureRecognizer *backTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ZEmojiMenuDismiss)];
    [_backView addGestureRecognizer:backTap];
    
    UIImageView *bgImgView = [[UIImageView alloc] init];
    bgImgView.tkThemebackgroundColors = @[COLOR_484F65, COLOR_484F65_DARK];
    [bgImgView rounded:DWScale(6)];
    [self addSubview:bgImgView];
    [bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(self);
        make.height.mas_equalTo(DWScale(23));
    }];
    
    UIImageView *arrowImgView = [[UIImageView alloc] init];
    arrowImgView.image = ImgNamed(@"c_more_arrow_down");
    [self addSubview:arrowImgView];
    [arrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bgImgView.mas_bottom).offset(-0.5);
        make.centerX.equalTo(self);
        make.width.mas_equalTo(DWScale(12));
        make.height.mas_equalTo(DWScale(6));
    }];
    

    UIButton *menuBtn = [[UIButton alloc] init];
    [menuBtn setTitle:_menuTitle forState:UIControlStateNormal];
    [menuBtn setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
    menuBtn.titleLabel.font = FONTN(12);
    [menuBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:menuBtn];
    [menuBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(bgImgView);
    }];
}

- (void)ZEmojiMenuDismiss {
    [_backView removeFromSuperview];
    _backView = nil;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self removeFromSuperview];
}

#pragma mark - Button Action
- (void)buttonClick:(id)sender {
    if (self.menuClickBlock) {
        self.menuClickBlock();
    }
    [self ZEmojiMenuDismiss];
}

@end
