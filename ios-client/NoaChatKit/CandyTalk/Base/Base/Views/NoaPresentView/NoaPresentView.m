//
//  NoaPresentView.m
//  NoaKit
//
//  Created by Candy on 2026/9/3.
//

#import "NoaPresentView.h"

@interface NoaPresentView ()

@end

@implementation NoaPresentView

- (instancetype)initWithFrame:(CGRect)frame titleItem:(NoaPresentItem * _Nullable)titleItem selectItems:(NSArray <NoaPresentItem *>* _Nullable)selectItems cancleItem:(NoaPresentItem * _Nonnull)cancleItem doneClick:(DoneActionBlock _Nullable)doneClick cancleClick:(CancleActionBlock _Nullable)cancleClick {
    self = [super init];
    if (self) {
        self.frame = frame.size.width > 0 ? frame : CGRectZero;
        self.titleItem = titleItem;
        self.selectItems = selectItems;
        self.cancleItem = cancleItem;
        self.doneActionBlock = doneClick;
        self.cancleActionBlock = cancleClick;

        [self buildSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame custom:(UIView*)customView   doneClick:(DoneActionBlock _Nullable)doneClick cancleClick:(CancleActionBlock _Nullable)cancleClick{
    self = [super init];
    if (self) {
        self.frame = frame.size.width > 0 ? frame : CGRectZero;
        self.doneActionBlock = doneClick;
        self.cancleActionBlock = cancleClick;

        [self buildCustomSubviews];
    }
    return self;
}

- (void)buildCustomSubviews {
    [self configBaseUI];
    [self.presentView round:16 RectCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
}

- (void)buildSubviews {
    [self configBaseUI];
    [self buildPresentItems];
    [self.presentView round:16 RectCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
}

-(void)configBaseUI{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    self.alpha = 0;
    
    UIControl *control = [[UIControl alloc] initWithFrame:self.bounds];
    if (self.width == 0 || self.height == 0) {
        control.frame = CGRectMake(0, 0, DScreenWidth, DScreenHeight);
    }
    control.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [control addTarget:self action:@selector(dismissPresentView) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:control];
    self.control = control;
    
    UIView *presentView = [[UIView alloc] init];
    presentView.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
    self.presentView = presentView;
    [self addSubview:presentView];
}

- (void)buildPresentItems {
    //顶部区域
    UIView *titleView = [[UIView alloc] init];
    [self.presentView addSubview:titleView];
    titleView.backgroundColor = self.titleItem.backgroundColor;
 
    if (self.titleItem) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, DScreenWidth - 15*2, 0)];
        titleLabel.text = self.titleItem.text;
        titleLabel.font = self.titleItem.font;
        titleLabel.textColor = self.titleItem.textColor;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.numberOfLines = 0;
        [titleView addSubview:titleLabel];
        
        CGFloat titleLabelHeight = [self.titleItem.text heightForFont:self.titleItem.font width:titleLabel.width];
        titleLabel.height = titleLabelHeight;
        
        UIView *titleLineView = [[UIView alloc] init];
        titleLineView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
        titleLineView.frame = CGRectMake(0, titleLabel.bottom + 15 - 1, DScreenWidth, 1);
        if (self.titleItem.text.length > 0) {
            [titleView addSubview:titleLineView];
        }
        titleView.frame = CGRectMake(0, 0, DScreenWidth, titleLineView.bottom);
    } else {
        titleView.frame = CGRectMake(0, 0, DScreenWidth, 0);
    }
    
    //确定区域
    UIView *middleView = [[UIView alloc] init];
    middleView.frame = CGRectMake(0, titleView.bottom, DScreenWidth, 0);
    [self.presentView addSubview:middleView];
    if (self.selectItems.count > 0) {
        for (int i = 0; i < self.selectItems.count; i++) {
            NoaPresentItem *item = self.selectItems[i];
            UIButton *actionBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, middleView.height, middleView.width, item.itemHeight)];
            [actionBtn setTitle:item.text forState:UIControlStateNormal];
            [actionBtn setTitleColor:item.textColor forState:UIControlStateNormal];
            if (![NSString isNil:item.imageName]) {
                [actionBtn setImage:ImgNamed(item.imageName) forState:UIControlStateNormal];
                [actionBtn setBtnImageAlignmentType:item.imgageAlignment imageSpace:item.imageTitleSpace];
            }
            actionBtn.titleLabel.font = item.font;
            actionBtn.tag = i + 100;
            actionBtn.backgroundColor = item.backgroundColor;
            [actionBtn addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
            [middleView addSubview:actionBtn];
            
            //分割线
            UIView *doneLineView = [[UIView alloc] init];
            doneLineView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
            doneLineView.frame = CGRectMake(0, actionBtn.bottom - 1, DScreenWidth, 1);
            [middleView addSubview:doneLineView];
            middleView.height += item.itemHeight;
        }
    }
    
    //取消区域
    UIView *cancleView = [[UIView alloc] init];
    cancleView.frame = CGRectMake(0, middleView.bottom, DScreenWidth, self.cancleItem.itemHeight + 8 + DHomeBarH);
    if ([self.currentNavigationViewController.topViewController isKindOfClass:[UITabBarController class]]) {
        cancleView.frame = CGRectMake(0, middleView.bottom, DScreenWidth, self.cancleItem.itemHeight + 8);
    }
    cancleView.backgroundColor = self.cancleItem.backgroundColor;
    [self.presentView addSubview:cancleView];
    
    //取消按钮上面的浅灰色分割View
    UIView *spaceView = [[UIView alloc] init];
    spaceView.frame = CGRectMake(0, middleView.bottom, DScreenWidth, 8);
    spaceView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
    [self.presentView addSubview:spaceView];
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 8, middleView.width, self.cancleItem.itemHeight)];
    [cancelBtn setTitle:self.cancleItem.text forState:UIControlStateNormal];
    [cancelBtn setTitleColor:self.cancleItem.textColor forState:UIControlStateNormal];
    if (![NSString isNil:self.cancleItem.imageName]) {
        [cancelBtn setImage:ImgNamed(self.cancleItem.imageName) forState:UIControlStateNormal];
        [cancelBtn setBtnImageAlignmentType:self.cancleItem.imgageAlignment imageSpace:self.cancleItem.imageTitleSpace];
    }
    cancelBtn.titleLabel.font = self.cancleItem.font;
    cancelBtn.backgroundColor = self.cancleItem.backgroundColor;
    [cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [cancleView addSubview:cancelBtn];

    self.presentView.frame = CGRectMake(0, DScreenHeight, DScreenWidth, cancleView.bottom);
}

- (void)showPresentView {
    self.alpha = 1;
    [UIView animateWithDuration:0.3 animations:^{
        self.control.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        UIViewController*topVC = self.currentNavigationViewController.visibleViewController;
        if ([topVC isKindOfClass:[UITabBarController class]]) {
            self.presentView.transform = CGAffineTransformMakeTranslation(0, - self.presentView.height);
        } else {
            self.presentView.transform = CGAffineTransformMakeTranslation(0, - self.presentView.height);
        }
    } completion:^(BOOL finished) {
    }];
}

- (void)dismissPresentView {
    [UIView animateWithDuration:0.3 animations:^{
        self.control.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        self.presentView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.alpha = 0;
    }];
}

#pragma mark - Action
- (void)doneAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSInteger index = btn.tag - 100;
    if (self.doneActionBlock) {
        self.doneActionBlock(index);
    }
    [self dismissPresentView];
}

- (void)cancelAction:(id)sender {
    if (self.cancleActionBlock) {
        self.cancleActionBlock();
    }
    [self dismissPresentView];
}

@end
