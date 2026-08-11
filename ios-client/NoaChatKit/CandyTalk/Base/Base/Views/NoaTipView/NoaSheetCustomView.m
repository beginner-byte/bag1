//
//  NoaSheetCustomView.m
//  NoaKit
//
//  Created by Candy on 2026/11/16.
//

#import "NoaSheetCustomView.h"
#import "NoaToolManager.h"
@interface NoaSheetCustomView()

@property (nonatomic, strong) UIView *viewBg;
@property (nonatomic, copy) NSString * titleStr;
@property (nonatomic, strong) NSArray * itemArr;
@property (nonatomic,strong)UILabel *lblTitle;
@property (nonatomic,strong)UIButton *btnCancel;
@end

@implementation NoaSheetCustomView

- (instancetype)initWithFrame:(CGRect)frame titleStr:(NSString *)titleStr itemArr:(NSArray *)itemArr {
    self = [super initWithFrame:frame];
    if (self) {
        self.titleStr = titleStr;
        self.itemArr = itemArr;
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    self.frame = CGRectMake(0, 0, DScreenWidth, DScreenHeight);
    self.tkThemebackgroundColors = @[[COLOR_00 colorWithAlphaComponent:0.3], [COLOR_00 colorWithAlphaComponent:0.6]];
    [CurrentWindow addSubview:self];
    
    _viewBg = [UIView new];
    _viewBg.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    _viewBg.layer.cornerRadius = DWScale(14);
    _viewBg.layer.masksToBounds = YES;
    _viewBg.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 300);
    [self addSubview:_viewBg];
    
    [_viewBg mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self);
        make.bottom.equalTo(self.mas_bottom);
        make.width.mas_equalTo(DScreenWidth);
//        make.height.mas_equalTo(200);
    }];

    
//    DHomeBarH
    //标题
    _lblTitle = [UILabel new];
    _lblTitle.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _lblTitle.font = FONTR(18);
    _lblTitle.numberOfLines = 1;
    _lblTitle.preferredMaxLayoutWidth = DWScale(234);
    _lblTitle.textAlignment = NSTextAlignmentCenter;
    _lblTitle.text = self.titleStr;
    [_viewBg addSubview:_lblTitle];
    [_lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_viewBg);
        make.top.equalTo(_viewBg).offset(DWScale(17));
        make.height.mas_equalTo(DWScale(22));
    }];
    
    //取消按钮
    _btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    [_btnCancel setTkThemeImage:@[ImgNamed(@"g_arrow_down"), ImgNamed(@"g_arrow_down_dark")] forState:UIControlStateNormal];
    [_btnCancel addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_viewBg addSubview:_btnCancel];
    [_btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_lblTitle);
        make.trailing.equalTo(_viewBg.mas_trailing).offset(-DWScale(16));
        make.height.width.mas_equalTo(DWScale(20));
    }];
    
    for (int i = 0; i<self.itemArr.count; i++) {
        UIView * bgView = [[UIView alloc] init];
        bgView.tag = 10000+i;
        [bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectTapAction:)]];
        [_viewBg addSubview:bgView];
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(_viewBg);
            make.size.mas_equalTo(CGSizeMake(DScreenWidth, DWScale(54)));
            make.top.mas_equalTo(_lblTitle.mas_bottom).offset(DWScale(17)+DWScale(54)*i);
            if (i == self.itemArr.count-1) {
                make.bottom.equalTo(_viewBg.mas_bottom).offset(-DHomeBarH);
            }
        }];
        
        UILabel * itemLabel = [UILabel new];
        itemLabel.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        itemLabel.font = FONTR(16);
        itemLabel.numberOfLines = 1;
        itemLabel.preferredMaxLayoutWidth = DWScale(234);
        itemLabel.textAlignment = NSTextAlignmentCenter;
        itemLabel.text = self.itemArr[i];
        [bgView addSubview:itemLabel];
        [itemLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(bgView);
            make.top.equalTo(_viewBg).offset(DWScale(17));
            make.height.mas_equalTo(DWScale(22));
        }];
        if (i != self.itemArr.count-1) {
            //横线
            UIView *transverseLine = [[UIView alloc] init];
            transverseLine.tkThemebackgroundColors = @[[COLOR_3C3C43 colorWithAlphaComponent:0.3], [COLOR_3C3C43_DARK colorWithAlphaComponent:0.3]];
            [bgView addSubview:transverseLine];
            [transverseLine mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(bgView.mas_bottom).offset(DWScale(-0.5));
                make.leading.mas_equalTo(DWScale(16));
                make.trailing.mas_equalTo(bgView.mas_trailing).offset(DWScale(-16));
                make.height.mas_equalTo(0.5);
            }];
        }
    }

}

- (void)selectTapAction:(UITapGestureRecognizer *)tap{
    if (self.sureBtnBlock) {
        self.sureBtnBlock(tap.view.tag-10000);
    }
    [self customViewDismiss];
}
#pragma mark - 交互事件
- (void)customViewSHow {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewBg.transform = CGAffineTransformIdentity;
    }];
}
- (void)customViewDismiss {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewBg.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN, CGFLOAT_MIN);
    } completion:^(BOOL finished) {
        [weakSelf.viewBg removeFromSuperview];
        weakSelf.viewBg = nil;
        [weakSelf removeFromSuperview];
    }];
}

- (void)cancelBtnAction {
    if (self.cancelBtnBlock) {
        self.cancelBtnBlock();
    }
    [self customViewDismiss];
}
@end
