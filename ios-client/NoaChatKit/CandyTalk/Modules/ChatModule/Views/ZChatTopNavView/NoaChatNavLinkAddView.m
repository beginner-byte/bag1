//
//  NoaChatNavLinkAddView.m
//  NoaKit
//
//  Created by Candy on 2023/7/18.
//

#import "NoaChatNavLinkAddView.h"
#import "NoaToolManager.h"

@interface NoaChatNavLinkAddView ()

@property (nonatomic, strong) UIView *viewBg;
@property (nonatomic, strong) UILabel *viewTitleLbl;
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UITextField *linkTextField;

@end

@implementation NoaChatNavLinkAddView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

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
    _viewBg.layer.cornerRadius = DWScale(15);
    _viewBg.layer.masksToBounds = YES;
    _viewBg.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN, CGFLOAT_MIN);
    [self addSubview:_viewBg];
    
    //标题
    [_viewBg addSubview:self.viewTitleLbl];
    [self.viewTitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewBg).offset(DWScale(20));
        make.top.equalTo(_viewBg).offset(DWScale(30));
    }];
    
    UILabel *lblNameTitle = [UILabel new];
    lblNameTitle.text = LanguageToolMatch(@"名称");
    lblNameTitle.tkThemetextColors = @[COLOR_11, COLOR_CCCCCC];
    lblNameTitle.font = FONTN(14);
    lblNameTitle.preferredMaxLayoutWidth = DWScale(255);
    [_viewBg addSubview:lblNameTitle];
    [lblNameTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewBg).offset(DWScale(20));
        make.top.equalTo(self.viewTitleLbl.mas_bottom).offset(DWScale(16));
    }];
    
    [_viewBg addSubview:self.nameTextField];
    [self.nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewBg).offset(DWScale(20));
        make.trailing.equalTo(_viewBg).offset(-DWScale(20));
        make.top.equalTo(lblNameTitle.mas_bottom).offset(DWScale(8));
        make.height.mas_equalTo(DWScale(38));
    }];
    // 输入框的左侧view
    UIView *namePaddingLeftView = [[UIView alloc] init];
    CGRect namePaddingframe = self.nameTextField.frame;
    namePaddingframe.size.width = DWScale(12);
    namePaddingLeftView.frame = namePaddingframe;
    self.nameTextField.leftViewMode = UITextFieldViewModeAlways;
    self.nameTextField.leftView = namePaddingLeftView;

    
    UILabel *lblLinkTitle = [UILabel new];
    lblLinkTitle.text = LanguageToolMatch(@"链接地址");
    lblLinkTitle.tkThemetextColors = @[COLOR_11, COLOR_CCCCCC];
    lblLinkTitle.font = FONTN(14);
    lblLinkTitle.preferredMaxLayoutWidth = DWScale(255);
    [_viewBg addSubview:lblLinkTitle];
    [lblLinkTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewBg).offset(DWScale(20));
        make.top.equalTo(self.nameTextField.mas_bottom).offset(DWScale(16));
    }];
    
    [_viewBg addSubview:self.linkTextField];
    [self.linkTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewBg).offset(DWScale(20));
        make.trailing.equalTo(_viewBg).offset(-DWScale(20));
        make.top.equalTo(lblLinkTitle.mas_bottom).offset(DWScale(8));
        make.height.mas_equalTo(DWScale(38));
    }];
    // 输入框的左侧view
    UIView *linkPaddingLeftView = [[UIView alloc] init];
    CGRect linkPaddingframe = self.linkTextField.frame;
    linkPaddingframe.size.width = DWScale(12);
    linkPaddingLeftView.frame = linkPaddingframe;
    self.linkTextField.leftViewMode = UITextFieldViewModeAlways;
    self.linkTextField.leftView = linkPaddingLeftView;

    
    //取消按钮
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    [btnCancel setTkThemeTitleColor:@[COLOR_66, COLOR_66_DARK] forState:UIControlStateNormal];
    btnCancel.tkThemebackgroundColors = @[COLOR_F6F6F6,COLOR_F6F6F6_DARK];
    [btnCancel setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateSelected];
    [btnCancel setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateHighlighted];
    btnCancel.titleLabel.font = FONTN(17);
    [btnCancel rounded:DWScale(22)];
    [btnCancel addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_viewBg addSubview:btnCancel];
    [btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewBg).offset(DWScale(20));
        make.top.equalTo(self.linkTextField.mas_bottom).offset(DWScale(20));
        make.width.mas_equalTo(DWScale(99));
        make.height.mas_equalTo(DWScale(44));
    }];
    
    //确定按钮
    UIButton *btnSure = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSure setTitle:LanguageToolMatch(@"确定") forState:UIControlStateNormal];
    [btnSure setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
    btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2];
    [btnSure setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateSelected];
    [btnSure setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateHighlighted];
    btnSure.titleLabel.font = FONTN(17);
    [btnSure rounded:DWScale(22)];
    [btnSure addTarget:self action:@selector(sureBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_viewBg addSubview:btnSure];
    [btnSure mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_viewBg.mas_trailing).offset(DWScale(-20));
        make.top.equalTo(self.linkTextField.mas_bottom).offset(DWScale(20));
        make.width.mas_equalTo(DWScale(146));
        make.height.mas_equalTo(DWScale(44));
    }];
    
    [_viewBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_equalTo(DWScale(293));
        make.top.equalTo(self.viewTitleLbl.mas_top).offset(-DWScale(30));
        make.bottom.equalTo(btnSure.mas_bottom).offset(DWScale(30));
    }];
}

//显示
- (void)linkAddViewShow {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewBg.transform = CGAffineTransformIdentity;
    }];
}

//消失
- (void)linkAddViewDismiss {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewBg.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN, CGFLOAT_MIN);
    } completion:^(BOOL finished) {
        [weakSelf.viewBg removeFromSuperview];
        weakSelf.viewBg = nil;
        [weakSelf removeFromSuperview];
    }];
}

#pragma mark - Setter
- (void)setViewType:(ChatLinkAddViewType)viewType {
    _viewType = viewType;
    if (_viewType == ChatLinkAddViewTypeAdd) {
        self.viewTitleLbl.text = LanguageToolMatch(@"添加链接");
    } else {
        self.viewTitleLbl.text = LanguageToolMatch(@"编辑链接");
    }
}

- (void)setEditTagModel:(NoaChatTagModel *)editTagModel {
    _editTagModel = editTagModel;
    
    self.nameTextField.text = _editTagModel.tagName;
    self.linkTextField.text = _editTagModel.tagUrl;
}

- (void)setDefaultUrlStr:(NSString *)defaultUrlStr {
    _defaultUrlStr = defaultUrlStr;

    self.linkTextField.text = _defaultUrlStr;
}

#pragma mark - 交互事件
- (void)sureBtnAction {
    NSString *tagName = self.nameTextField.text;
    NSString *tagUrl = self.linkTextField.text;
    
    if ([NSString isNil:tagName]) {
        [HUD showMessage:LanguageToolMatch(@"名称不可为空")];
        return;
    }
    if ([NSString isNil:tagUrl]) {
        [HUD showMessage:LanguageToolMatch(@"链接地址不可为空")];
        return;
    }
    if (![tagUrl checkStringIsUrl]) {
        [HUD showMessage:LanguageToolMatch(@"链接地址无效")];
        return;        
    }
    //添加
    NSInteger tagId = (self.viewType == ChatLinkAddViewTypeAdd ? 0 : self.editTagModel.tagId);
    
    NSString *finialTagUrl;
    if (![tagUrl containsString:@"https://"] && ![tagUrl containsString:@"http://"] && ![tagUrl containsString:@"ftp://"]) {
        finialTagUrl = [NSString stringWithFormat:@"http://%@", tagUrl];
    } else {
        finialTagUrl = tagUrl;
    }
    if (self.newTagFinsihBlock) {
        self.newTagFinsihBlock(tagId, tagName, finialTagUrl, self.updateIndex);
    }
    [self linkAddViewDismiss];
}

- (void)cancelBtnAction {
    [self linkAddViewDismiss];
}

#pragma mark - UITextField
- (void)textFieldDidChange:(UITextField *)textField {
    if (textField == self.nameTextField) {
        // 判断是否存在高亮字符，如果有，则不进行字数统计和字符串截断
        UITextRange *selectedRange = textField.markedTextRange;
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (position) {
            return;
        }

        // 判断是否超过最大字数限制，如果超过就截断
        if (textField.text.length > 8) {
            textField.text = [textField.text substringToIndex:8];
        }
    }
}

#pragma mark - Lazy
- (UILabel *)viewTitleLbl {
    if (!_viewTitleLbl) {
        _viewTitleLbl = [[UILabel alloc] init];
        _viewTitleLbl.text = @"";
        _viewTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_CCCCCC];
        _viewTitleLbl.font = FONTB(18);
        _viewTitleLbl.preferredMaxLayoutWidth = DWScale(255);
    }
    return _viewTitleLbl;
}

- (UITextField *)nameTextField {
    if (!_nameTextField) {
        _nameTextField = [[UITextField alloc] init];
        _nameTextField.placeholder = LanguageToolMatch(@"请输入名称");
        _nameTextField.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _nameTextField.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
        _nameTextField.font = FONTN(14);
        [_nameTextField rounded:DWScale(8)];
        [_nameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _nameTextField;
}

- (UITextField *)linkTextField {
    if (!_linkTextField) {
        _linkTextField = [[UITextField alloc] init];
        _linkTextField.placeholder = LanguageToolMatch(@"请输入链接地址");
        _linkTextField.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _linkTextField.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
        _linkTextField.font = FONTN(14);
        [_linkTextField rounded:DWScale(8)];
    }
    return _linkTextField;
}

@end
