//
//  NoaFriendGroupDeleteView.m
//  NoaKit
//
//  Created by Candy on 2023/7/4.
//

#import "NoaFriendGroupDeleteView.h"
#import "NoaToolManager.h"

@interface NoaFriendGroupDeleteView ()
@property (nonatomic, strong) UIView *viewBg;
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UILabel *lblTip;
@property (nonatomic, strong) UIButton *btnCancel;
@property (nonatomic, strong) UIButton *btnDelete;
@end

@implementation NoaFriendGroupDeleteView

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
    _lblTitle.text = LanguageToolMatch(@"删除分组");
    _lblTitle.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _lblTitle.font = FONTR(18);
    [_viewBg addSubview:_lblTitle];
    [_lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewBg).offset(DWScale(20));
        make.top.equalTo(_viewBg).offset(DWScale(20));
        make.height.mas_equalTo(DWScale(28));
    }];
    
    _lblTip = [UILabel new];
    _lblTip.preferredMaxLayoutWidth = DWScale(255);
    _lblTip.numberOfLines = 3;
    _lblTip.text = LanguageToolMatch(@"删除后，分组中的好友将自动移动到默认分组，是否继续");
    _lblTip.textAlignment = NSTextAlignmentCenter;
    _lblTip.font = FONTR(14);
    _lblTip.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [_viewBg addSubview:_lblTip];
    [_lblTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewBg).offset(DWScale(20));
        make.trailing.equalTo(_viewBg).offset(-DWScale(20));
        make.top.equalTo(_lblTitle.mas_bottom).offset(DWScale(20));
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
    
    _btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnDelete setTitle:LanguageToolMatch(@"删除") forState:UIControlStateNormal];
    [_btnDelete setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
    _btnDelete.titleLabel.font = FONTR(17);
    [_btnDelete setTkThemebackgroundColors:@[COLOR_5966F2, COLOR_5966F2_DARK]];
    _btnDelete.layer.cornerRadius = DWScale(22);
    _btnDelete.layer.masksToBounds = YES;
    [_btnDelete addTarget:self action:@selector(btnDeleteClick) forControlEvents:UIControlEventTouchUpInside];
    [_viewBg addSubview:_btnDelete];
    [_btnDelete mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_viewBg).offset(-DWScale(20));
        make.bottom.equalTo(_viewBg).offset(-DWScale(30));
        make.size.mas_equalTo(CGSizeMake(DWScale(145), DWScale(44)));
    }];

}
#pragma mark - 界面赋值
- (void)setFriendGroupModel:(LingIMFriendGroupModel *)friendGroupModel {
    _friendGroupModel = friendGroupModel;
}
- (void)deleteViewShow {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewBg.transform = CGAffineTransformIdentity;
    }];
}

- (void)deleteViewDismiss {
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
    [self deleteViewDismiss];
}

- (void)btnDeleteClick {
    
    if (_delegate && [_delegate respondsToSelector:@selector(friendGroupDelete:)]) {
        [_delegate friendGroupDelete:_friendGroupModel];
    }
    
    [self deleteViewDismiss];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
