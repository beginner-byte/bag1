//
//  NoaGroupApplyBottomView.m
//  NoaKit
//
//  Created by Candy on 2023/5/4.
//

#import "NoaGroupApplyBottomView.h"

@interface NoaGroupApplyBottomView()

@property (nonatomic, strong)UIView *topLineView;
@property (nonatomic, strong)UIButton *allSelectBtn;
@property (nonatomic, strong)UIButton *refuseBtn;
@property (nonatomic, strong)UIButton *agreeBtn;

@end

@implementation NoaGroupApplyBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        [self setupUI];
    }
    return self;
}

#pragma mark - UI
- (void)setupUI {
    [self addSubview:self.topLineView];
    [self addSubview:self.allSelectBtn];
    [self addSubview:self.refuseBtn];
    [self addSubview:self.agreeBtn];
    
    [self.topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(self);
        make.height.mas_equalTo(0.8);
    }];
    
    [self.allSelectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(DWScale(13));
        make.leading.equalTo(self).offset(DWScale(16));
        make.width.mas_equalTo(DWScale(100));
        make.height.mas_equalTo(DWScale(32));
    }];
    
    [self.agreeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(DWScale(13));
        make.trailing.equalTo(self).offset(DWScale(-16));
        make.width.mas_equalTo(DWScale(56));
        make.height.mas_equalTo(DWScale(32));
    }];
    
    [self.refuseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(DWScale(13));
        make.trailing.equalTo(self.agreeBtn.mas_leading).offset(DWScale(-16));
        make.width.mas_equalTo(DWScale(56));
        make.height.mas_equalTo(DWScale(32));
    }];
}

- (void)setAllSelected:(BOOL)allSelected {
    _allSelected = allSelected;
    
    self.allSelectBtn.selected = _allSelected;
}

#pragma mark - Action
//一键权限
- (void)allSelectBtnAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    
    if ([self.delegate respondsToSelector:@selector(allSelectButtonAction:)]) {
        [self.delegate allSelectButtonAction:btn.selected];
    }
}

//拒绝
- (void)refuseJoinApplyAction {
    if ([self.delegate respondsToSelector:@selector(refuseJoinApplyAction)]) {
        [self.delegate refuseJoinApplyAction];
    }
}

//同意
- (void)agreeJoinApplyAction {
    if ([self.delegate respondsToSelector:@selector(agreeJoinApplyAction)]) {
        [self.delegate agreeJoinApplyAction];
    }
}

#pragma amrk - Lazy
- (UIView *)topLineView {
    if (!_topLineView) {
        _topLineView = [[UIView alloc] init];
        _topLineView.tkThemebackgroundColors = @[COLOR_E6E6E6, COLOR_E6E6E6_DARK];
    }
    return _topLineView;
}

- (UIButton *)allSelectBtn {
    if (!_allSelectBtn) {
        _allSelectBtn = [[UIButton alloc] init];
        [_allSelectBtn setTitle:LanguageToolMatch(@"一键全选") forState:UIControlStateNormal];
        [_allSelectBtn setTkThemeTitleColor:@[COLOR_11, COLOR_11_DARK] forState:UIControlStateNormal];
        [_allSelectBtn setImage:ImgNamed(@"c_select_no") forState:UIControlStateNormal];
        [_allSelectBtn setImage:ImgNamed(@"c_select_yes") forState:UIControlStateSelected];
        [_allSelectBtn setBtnImageAlignmentType:ButtonImageAlignmentTypeLeft imageSpace:DWScale(9)];
        _allSelectBtn.selected = NO;
        _allSelectBtn.titleLabel.font = FONTN(16);
        [_allSelectBtn addTarget:self action:@selector(allSelectBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _allSelectBtn;
}

- (UIButton *)refuseBtn {
    if (!_refuseBtn) {
        _refuseBtn = [[UIButton alloc] init];
        [_refuseBtn setTitle:LanguageToolMatch(@"拒绝") forState:UIControlStateNormal];
        [_refuseBtn setTkThemeTitleColor:@[COLOR_66, COLOR_66_DARK] forState:UIControlStateNormal];
        _refuseBtn.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F6F6F6_DARK];
        [_refuseBtn rounded:12];
        _refuseBtn.titleLabel.font = FONTN(14);
        [_refuseBtn addTarget:self action:@selector(refuseJoinApplyAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refuseBtn;
}

- (UIButton *)agreeBtn {
    if (!_agreeBtn) {
        _agreeBtn = [[UIButton alloc] init];
        [_agreeBtn setTitle:LanguageToolMatch(@"同意") forState:UIControlStateNormal];
        [_agreeBtn setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
        _agreeBtn.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
        [_agreeBtn rounded:12];
        _agreeBtn.titleLabel.font = FONTN(14);
        [_agreeBtn addTarget:self action:@selector(agreeJoinApplyAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _agreeBtn;
}

@end
