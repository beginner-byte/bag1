//
//  NoaCollectionMenuView.m
//  NoaKit
//
//  Created by Candy on 2024/8/2.
//

#import "NoaCollectionMenuView.h"

@interface NoaCollectionMenuView()

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, copy) NSString *menuTitle;
@property (nonatomic, assign) CGRect rect;

@end

@implementation NoaCollectionMenuView

- (instancetype)initWithMenuTitle:(NSString *)menuTitle rect:(CGRect)rect {
    self = [super init];
    if (self) {
        _menuTitle = menuTitle;
        _rect = rect;
    }
    return self;
}

- (void)show {
    _backView = [[UIView alloc] init];
    _backView.backgroundColor = COLOR_CLEAR;
    _backView.frame = CGRectMake(0, 0, DScreenWidth, DScreenHeight);
    [CurrentVC.view addSubview:_backView];
    
 
    
    self.frame = CGRectMake(_rect.origin.x + _rect.size.width/2, _rect.origin.y - _rect.size.height - DWScale(3), DWScale(64), DWScale(48) + DWScale(9.5));
    [_backView addSubview:self];
    
    UITapGestureRecognizer *backTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [_backView addGestureRecognizer:backTap];
    
    UIButton *menuBtn = [[UIButton alloc] init];
    [menuBtn setTitle:_menuTitle forState:UIControlStateNormal];
    [menuBtn setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
    [menuBtn setTkThemebackgroundColors:@[[COLOR_262728 colorWithAlphaComponent:0.8], [COLOR_262728 colorWithAlphaComponent:0.8]]];
    menuBtn.titleLabel.font = FONTN(12);
    [menuBtn rounded:14];
    [menuBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:menuBtn];
    [menuBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self);
        make.height.mas_equalTo(DWScale(48));
    }];
    
    UIImageView *arrowImgView = [[UIImageView alloc] init];
    arrowImgView.image = ImgNamed(@"collection_menu_arrow");
    [self addSubview:arrowImgView];
    [arrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(menuBtn.mas_bottom).offset(-0.5);
        make.centerX.equalTo(self);
        make.width.mas_equalTo(DWScale(18.5));
        make.height.mas_equalTo(DWScale(9.5));
    }];
}

- (void)dismiss {
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
    [self dismiss];
}

@end
