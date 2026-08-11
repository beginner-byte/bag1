//
//  NoaFriendGroupAddView.m
//  NoaKit
//
//  Created by Candy on 2023/7/4.
//

#import "NoaFriendGroupAddView.h"
#import "NoaToolManager.h"

@interface NoaFriendGroupAddView ()
@property (nonatomic, strong) UIView *viewBg;
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UITextField *tfFriendGroup;
@property (nonatomic, strong) UIButton *btnCancel;
@property (nonatomic, strong) UIButton *btnSure;
@end

@implementation NoaFriendGroupAddView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    self.frame = CGRectMake(0, 0, DScreenWidth, DScreenHeight);
    self.backgroundColor = [COLOR_00 colorWithAlphaComponent:0.3];
    [CurrentWindow addSubview:self];
    
    _viewBg = [UIView new];
    _viewBg.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];;
    _viewBg.layer.cornerRadius = DWScale(14);
    _viewBg.layer.masksToBounds = YES;
    _viewBg.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN, CGFLOAT_MIN);
    [self addSubview:_viewBg];
    [_viewBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(DWScale(295), DWScale(205)));
    }];
    
    _lblTitle = [UILabel new];
    _lblTitle.text = LanguageToolMatch(@"添加分组");
    _lblTitle.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _lblTitle.font = FONTR(18);
    [_viewBg addSubview:_lblTitle];
    [_lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewBg).offset(DWScale(20));
        make.top.equalTo(_viewBg).offset(DWScale(20));
        make.height.mas_equalTo(DWScale(28));
    }];
    
    UIView *tfBg = [UIView new];
    tfBg.layer.cornerRadius = DWScale(8);
    tfBg.layer.masksToBounds = YES;
    tfBg.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
    [_viewBg addSubview:tfBg];
    [tfBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lblTitle.mas_bottom).offset(DWScale(20));
        make.leading.equalTo(_viewBg).offset(DWScale(20));
        make.trailing.equalTo(_viewBg).offset(-DWScale(20));
        make.height.mas_equalTo(DWScale(38));
    }];
    
    _tfFriendGroup = [UITextField new];
    _tfFriendGroup.placeholder = LanguageToolMatch(@"请输入分组名");
    _tfFriendGroup.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _tfFriendGroup.font = FONTR(14);
    [_viewBg addSubview:_tfFriendGroup];
    [_tfFriendGroup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(tfBg);
        make.leading.equalTo(tfBg).offset(DWScale(10));
        make.trailing.equalTo(tfBg).offset(-DWScale(10));
    }];
    
    _btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    [_btnCancel setTkThemeTitleColor:@[COLOR_66, COLOR_66_DARK] forState:UIControlStateNormal];
    _btnCancel.titleLabel.font = FONTR(17);
    [_btnCancel setTkThemebackgroundColors:@[COLOR_F6F6F6, COLOR_F6F6F6_DARK]];
    _btnCancel.layer.cornerRadius = DWScale(22);
    _btnCancel.layer.masksToBounds = YES;
    [_btnCancel addTarget:self action:@selector(btnCancelClick) forControlEvents:UIControlEventTouchUpInside];
    [_viewBg addSubview:_btnCancel];
    [_btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewBg).offset(DWScale(20));
        make.bottom.equalTo(_viewBg).offset(-DWScale(30));
        make.size.mas_equalTo(CGSizeMake(DWScale(100), DWScale(44)));
    }];
    
    _btnSure = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnSure setTitle:LanguageToolMatch(@"确定") forState:UIControlStateNormal];
    [_btnSure setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
    _btnSure.titleLabel.font = FONTR(17);
    [_btnSure setTkThemebackgroundColors:@[COLOR_5966F2, COLOR_5966F2_DARK]];
    _btnSure.layer.cornerRadius = DWScale(22);
    _btnSure.layer.masksToBounds = YES;
    [_btnSure addTarget:self action:@selector(btnSureClick) forControlEvents:UIControlEventTouchUpInside];
    [_viewBg addSubview:_btnSure];
    [_btnSure mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_viewBg).offset(-DWScale(20));
        make.bottom.equalTo(_viewBg).offset(-DWScale(30));
        make.size.mas_equalTo(CGSizeMake(DWScale(145), DWScale(44)));
    }];

}

- (void)addViewShow {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewBg.transform = CGAffineTransformIdentity;
    }];
}

- (void)addViewDismiss {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewBg.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN, CGFLOAT_MIN);
    } completion:^(BOOL finished) {
        [weakSelf.viewBg removeFromSuperview];
        weakSelf.viewBg = nil;
        [weakSelf removeFromSuperview];
    }];
}

#pragma mark - 交互事件
- (void)btnCancelClick {
    [self addViewDismiss];
}
- (void)btnSureClick {
    NSString *friendGroupName = _tfFriendGroup.text;
    if (![NSString isNil:friendGroupName]) {
        WeakSelf
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
        [dict setValue:friendGroupName forKey:@"ugName"];
        [IMSDKManager createFriendGroupWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            [weakSelf addViewDismiss];
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            [HUD showMessageWithCode:code errorMsg:msg];
        }];
        
        
    }else {
        [HUD showMessage:LanguageToolMatch(@"请输入分组名")];
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
