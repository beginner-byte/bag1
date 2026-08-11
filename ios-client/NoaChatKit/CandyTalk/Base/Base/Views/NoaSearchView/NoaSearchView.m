//
//  NoaSearchView.m
//  NoaKit
//
//  Created by Apple on 2026/9/3.
//

#import "NoaSearchView.h"

@interface NoaSearchView()
@property (nonatomic,copy) NSString * placeholder;
@property (nonatomic, strong) UIButton *btnClear;//清空输入框内容
@property (nonatomic, strong) UIButton *btnGoSearch;//跳转搜索
@end


@implementation NoaSearchView
- (instancetype)initWithPlaceholder:(NSString*)placeholder{
    if (self = [super init]) {
        self.tkThemebackgroundColors = @[COLORWHITE,COLOR_11];
        self.placeholder = placeholder;
        [self initUI];
    }
    return self;
}
- (void)initUI{
    
    UIView * searchView = [[UIView alloc] init];
    searchView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_EEEEEE_DARK];
    [searchView rounded:12.0];
    [self addSubview:searchView];
    
    UIButton * searchBtn = [[UIButton alloc] init];
    [searchBtn setImage:ImgNamed(@"cim_contacts_search_icon") forState:UIControlStateNormal];
    searchBtn.tkThemebackgroundColors = @[COLOR_EFEFF2, COLOR_5966F2_DARK];
    [searchBtn addTarget:self action:@selector(btnSearchClick) forControlEvents:UIControlEventTouchUpInside];
    [searchView addSubview:searchBtn];
    
    _tfSearch = [[UITextField alloc] init];
    NSMutableAttributedString * placeHolderAttStr = [[NSMutableAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName: COLOR_99}];
    if([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"法语"]){
        [placeHolderAttStr addAttributes:@{NSFontAttributeName:FONTN(10)} range:NSMakeRange(0, placeHolderAttStr.length)];
        _tfSearch.attributedPlaceholder = placeHolderAttStr;
        //_tfSearch.delegate = self;
        _tfSearch.font = FONTR(12);
    }else{
        _tfSearch.attributedPlaceholder = placeHolderAttStr;
        //_tfSearch.delegate = self;
        _tfSearch.font = FONTR(16);
    }

    _tfSearch.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _tfSearch.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_tfSearch addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [searchView addSubview:_tfSearch];
    
    _btnClear = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnClear setTkThemeImage:@[ImgNamed(@"c_close_white"), ImgNamed(@"c_close_white_dark")] forState:UIControlStateNormal];
    [_btnClear setBackgroundColor:COLOR_99];
    _btnClear.hidden = YES;//默认隐藏
    _btnClear.layer.cornerRadius = DWScale(10);
    _btnClear.layer.masksToBounds = YES;
    [_btnClear addTarget:self action:@selector(btnClearClick) forControlEvents:UIControlEventTouchUpInside];
    [searchView addSubview:_btnClear];
    
    [searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(DWScale(16));
        make.trailing.mas_equalTo(self.mas_trailing).offset(-DWScale(16));
        make.top.mas_equalTo(self);
        make.height.mas_equalTo(DWScale(38));
    }];
    
    [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(searchView.mas_trailing);
        make.centerY.mas_equalTo(searchView);
        make.width.mas_equalTo(DWScale(44));
        make.height.mas_equalTo(DWScale(38));
    }];
    
    [_btnClear mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(searchView);
        make.trailing.equalTo(searchBtn.mas_leading).offset(DWScale(-12));
        make.size.mas_equalTo(CGSizeMake(DWScale(20), DWScale(20)));
    }];
    
    [_tfSearch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(searchView.mas_leading).offset(DWScale(12));
        make.centerY.mas_equalTo(searchView);
        make.trailing.mas_equalTo(searchBtn.mas_leading).offset(DWScale(-10));
        make.height.mas_equalTo(DWScale(38));
    }];
    
    _btnGoSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnGoSearch addTarget:self action:@selector(btnGoSearchClick) forControlEvents:UIControlEventTouchUpInside];
    _btnGoSearch.hidden = YES;
    [searchView addSubview:_btnGoSearch];
    [_btnGoSearch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(searchView);
    }];
    
}
#pragma mark - 配置赋值
- (void)setShowClearBtn:(BOOL)showClearBtn {
    _showClearBtn = showClearBtn;
}
- (void)setCurrentViewSearch:(BOOL)currentViewSearch {
    _currentViewSearch = currentViewSearch;
    
    _tfSearch.userInteractionEnabled = currentViewSearch;
    _btnGoSearch.hidden = currentViewSearch;
}
- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType {
    _returnKeyType = returnKeyType;
    _tfSearch.returnKeyType = returnKeyType;
}
- (void)setShowKeyboard:(BOOL)showKeyboard {
    _showKeyboard = showKeyboard;
    if (_showKeyboard) {
        [_tfSearch becomeFirstResponder];
    }
}
#pragma mark - 实时监听输入框内容变化
- (void)textFieldValueChanged:(UITextField *)textField {
    
    _searchStr = textField.text;
    
    if (_delegate && [_delegate respondsToSelector:@selector(searchViewTextValueChanged:)]) {
        [_delegate searchViewTextValueChanged:_searchStr];
    }

    _btnClear.hidden = !(_showClearBtn && ![NSString isNil:_searchStr]);
}

/*
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (_delegate && [_delegate respondsToSelector:@selector(searchViewReturnKeySearch:)]) {
        [_delegate searchViewReturnKeySearch:textField.text];
    }
    return YES;
}
*/

#pragma mark - 交互事件
- (void)btnSearchClick  {
    if (_delegate && [_delegate respondsToSelector:@selector(searchViewReturnKeySearch:)]) {
        [_delegate searchViewReturnKeySearch:_tfSearch.text];
    }
}

- (void)btnClearClick {
    _tfSearch.text = @"";
    _btnClear.hidden = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(searchViewTextValueChanged:)]) {
        [_delegate searchViewTextValueChanged:@""];
    }
}
- (void)btnGoSearchClick {
    if (_delegate && [_delegate respondsToSelector:@selector(searchViewGoSearch)] && !_currentViewSearch) {
        [_delegate searchViewGoSearch];
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
