//
//  NoaSheetInputView.m
//  NoaKit
//
//  Created by Candy on 2023/1/28.
//

#import "NoaSheetInputView.h"
#import "NoaToolManager.h"
@interface NoaSheetInputView() <UITextFieldDelegate> {
    
    UILabel * desTipLabel;
}

@property (nonatomic, strong) UIView *viewBg;
@property (nonatomic, copy) NSString * titleStr; //名称
@property (nonatomic, copy) NSString * remarkStr; //备注
@property (nonatomic, copy) NSString * desStr; //描述
@property (nonatomic,strong)UILabel *lblTitle;  //标题
@property (nonatomic,strong)UIButton *btnCancel; //取消按钮

@property (nonatomic,strong)UIView * setRemarkBgView;//设置备注背景视图
@property (nonatomic,strong)UITextField * setRemarkTextField;//设置备注输入试图
@property (nonatomic,strong)UILabel * setRemarkNumberLabel;//设置备注计数试图

@property (nonatomic,strong)UIView * setDesBgView;//设置描述背景视图
@property (nonatomic,strong)UITextView * setDesTextView;//设置备注输入试图
@property (nonatomic,strong)UILabel * setDesNumberLabel;//设置描述计数试图
@property (nonatomic,strong)UILabel * textViewPlaceHolderLabel;//textview的placeholder
@property (nonatomic,assign)NSInteger textViewHeightChangeIndex;//textView高度变化次数
@property (nonatomic,assign)CGFloat curTextHeight;//记录当前text高度

@property (nonatomic,assign)CGFloat viewHeight;//当前视图高度

@property (nonatomic,strong)UIButton *saveBtn; //保存按钮
@end

@implementation NoaSheetInputView

- (instancetype)initWithFrame:(CGRect)frame titleStr:(NSString *)titleStr remarkStr:(NSString *)remarkStr desStr:(NSString *)desStr{
    self = [super initWithFrame:frame];
    if (self) {
        self.textViewHeightChangeIndex = 0;
        self.curTextHeight = 0.0;
        self.titleStr = titleStr;
        self.remarkStr = remarkStr;
        self.desStr = desStr;
    
        [self setupUI];

        
        //监听键盘，当键盘将要出现时
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        //当键盘将要退出时
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChange) name:UITextViewTextDidChangeNotification object:nil];
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
    if(DWScale(738) > DScreenHeight){
        self.viewHeight = DScreenHeight-DWScale(50);
    }else{
        self.viewHeight = DWScale(738);
    }
    _viewBg.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, self.viewHeight);
    [self addSubview:_viewBg];
    
    [_viewBg mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self);
        make.bottom.equalTo(self.mas_bottom);
        make.width.mas_equalTo(DScreenWidth);
        make.height.mas_equalTo(self.viewHeight);
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
        make.top.equalTo(_viewBg).offset(DWScale(16));
        make.height.mas_equalTo(DWScale(20));
    }];
    
    //取消按钮
    _btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnCancel setTitle:LanguageToolMatch(@"取消")  forState:UIControlStateNormal];
    _btnCancel.titleEdgeInsets = UIEdgeInsetsMake(0, -16, 0, 0);
    [_btnCancel setTkThemeTitleColor:@[COLOR_99,COLOR_99] forState:UIControlStateNormal];
    _btnCancel.titleLabel.font = FONTR(15);
    [_btnCancel addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_viewBg addSubview:_btnCancel];
    [_btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_lblTitle);
        make.leading.mas_equalTo(DWScale(16));
        make.height.mas_equalTo(DWScale(18));
        make.width.mas_equalTo(DWScale(40));
    }];
    
    //备注
    UILabel * remarkTipLabel = [UILabel new];
    remarkTipLabel.tkThemetextColors = @[COLOR_66, COLOR_CCCCCC];
    remarkTipLabel.font = FONTR(12);
    remarkTipLabel.text = LanguageToolMatch(@"设置备注");
    remarkTipLabel.textAlignment = NSTextAlignmentLeft;
    [_viewBg addSubview:remarkTipLabel];
    [remarkTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(DWScale(16));
        make.top.mas_equalTo(_btnCancel.mas_bottom).offset(DWScale(22));
        make.height.mas_equalTo(DWScale(16));
    }];
    
    _setRemarkBgView = [UIView new];
    _setRemarkBgView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
    _setRemarkBgView.layer.cornerRadius = DWScale(14);
    _setRemarkBgView.layer.masksToBounds = YES;
    [_viewBg addSubview:_setRemarkBgView];
    [_setRemarkBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(DWScale(16));
        make.top.mas_equalTo(remarkTipLabel.mas_bottom).offset(DWScale(4));
        make.trailing.mas_equalTo(_viewBg.mas_trailing).offset(-DWScale(16));
        make.height.mas_equalTo(DWScale(48));
    }];
    
    self.setRemarkNumberLabel = [UILabel new];
    self.setRemarkNumberLabel.tkThemetextColors = @[COLOR_99, COLOR_99];
    self.setRemarkNumberLabel.font = FONTB(12);
    self.setRemarkNumberLabel.textAlignment = NSTextAlignmentLeft;
    [_setRemarkBgView addSubview:self.setRemarkNumberLabel];


    _setRemarkTextField = [UITextField new];
    _setRemarkTextField.tkThemetextColors = @[COLOR_11, COLORWHITE];
    _setRemarkTextField.font = FONTR(16);
    _setRemarkTextField.text = self.remarkStr;
    _setRemarkTextField.delegate = self;
    NSMutableAttributedString * placeHolderAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"请填写备注") attributes:@{NSForegroundColorAttributeName: COLOR_99,NSFontAttributeName: FONTR(16)}];
    _setRemarkTextField.attributedPlaceholder = placeHolderAttStr;
    [_setRemarkBgView addSubview:_setRemarkTextField];
    [_setRemarkTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(DWScale(16));
        make.centerY.mas_equalTo(_setRemarkBgView);
        make.trailing.mas_equalTo(self.setRemarkNumberLabel.mas_leading).offset(-DWScale(5));
        make.height.mas_equalTo(DWScale(22));
    }];

    //描述
    desTipLabel = [UILabel new];
    desTipLabel.tkThemetextColors = @[COLOR_66, COLOR_CCCCCC];
    desTipLabel.font = FONTR(12);
    desTipLabel.text = LanguageToolMatch(@"描述");
    desTipLabel.textAlignment = NSTextAlignmentLeft;
    [_viewBg addSubview:desTipLabel];
    [desTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(DWScale(16));
        make.top.mas_equalTo(_setRemarkBgView.mas_bottom).offset(DWScale(17));
        make.height.mas_equalTo(DWScale(16));
    }];
    
    _setDesBgView = [UIView new];
    _setDesBgView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
    _setDesBgView.layer.cornerRadius = DWScale(14);
    _setDesBgView.layer.masksToBounds = YES;
    [_viewBg addSubview:_setDesBgView];
    [_setDesBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(DWScale(16));
        make.top.mas_equalTo(desTipLabel.mas_bottom).offset(DWScale(4));
        make.trailing.mas_equalTo(_viewBg.mas_trailing).offset(-DWScale(16));
        make.height.mas_equalTo(DWScale(115+45));
    }];
    
    self.setDesNumberLabel = [UILabel new];
    self.setDesNumberLabel.tkThemetextColors = @[COLOR_99, COLOR_99];
    self.setDesNumberLabel.font = FONTB(12);
    self.setDesNumberLabel.textAlignment = NSTextAlignmentLeft;
    [_setDesBgView addSubview:self.setDesNumberLabel];
    [self.setDesNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.setDesBgView.mas_trailing).offset(-DWScale(10));
        make.bottom.mas_equalTo(_setDesBgView.mas_bottom).offset(-DWScale(10));
        make.height.mas_equalTo(DWScale(17));
    }];

    _setDesTextView = [UITextView new];
    _setDesTextView.tkThemetextColors = @[COLOR_11, COLORWHITE];
    _setDesTextView.font = FONTR(16);
    _setDesTextView.textContainerInset = UIEdgeInsetsZero;
    _setDesTextView.textContainer.lineFragmentPadding = 0;
    _setDesTextView.text = self.desStr;
    [_setDesTextView setBackgroundColor:[UIColor clearColor]];
    [_setDesBgView addSubview:_setDesTextView];
    [_setDesTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(DWScale(16));
        make.trailing.mas_equalTo(-DWScale(16));
        make.top.mas_equalTo(DWScale(13));
        make.bottom.mas_equalTo(self.setDesNumberLabel.mas_top).offset(-DWScale(5));
    }];
    
    _textViewPlaceHolderLabel = [UILabel new];
    _textViewPlaceHolderLabel.tkThemetextColors = @[COLOR_99, COLOR_99];
    _textViewPlaceHolderLabel.font = FONTR(16);
    _textViewPlaceHolderLabel.text = LanguageToolMatch(@"添加描述");
    [_setDesBgView addSubview:_textViewPlaceHolderLabel];
    if(![NSString isNil:self.desStr]){
        _textViewPlaceHolderLabel.hidden = YES;
    }else{
        _textViewPlaceHolderLabel.hidden = NO;
    }
    [_textViewPlaceHolderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(DWScale(16));
        make.top.mas_equalTo(DWScale(13));
        make.height.mas_equalTo(DWScale(22));
    }];
    
    self.setRemarkNumberLabel.text = [NSString stringWithFormat:@"%ld/50",self.setRemarkTextField.text.length];
    [self.setRemarkNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.setRemarkBgView.mas_trailing).offset(-DWScale(10));
        make.centerY.mas_equalTo(_setRemarkBgView);
        make.height.mas_equalTo(DWScale(17));
        make.width.mas_equalTo(44);
    }];
    self.setDesNumberLabel.text = [NSString stringWithFormat:@"%ld/200",self.setDesTextView.text.length];
    
    _saveBtn = [[UIButton alloc] init];
    [_saveBtn setTitle:LanguageToolMatch(@"保存") forState:UIControlStateNormal];
    [_saveBtn setTitleColor:COLORWHITE forState:UIControlStateNormal];
    _saveBtn.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    [_saveBtn setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateSelected];
    [_saveBtn setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateHighlighted];
    [_saveBtn rounded:DWScale(14)];
    [_saveBtn shadow:COLOR_5966F2 opacity:0.15 radius:5 offset:CGSizeMake(0, 0)];
    _saveBtn.clipsToBounds = YES;
    [_saveBtn addTarget:self action:@selector(saveBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_viewBg addSubview:_saveBtn];
    [_saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(DWScale(16));
        make.trailing.mas_equalTo(-DWScale(16));
        make.top.mas_equalTo(self.setDesBgView.mas_bottom).offset(DWScale(16));
        make.height.mas_equalTo(DWScale(50));
    }];
}

- (void)saveBtnAction{
    if (_setRemarkTextField.text.length > 0 && [_setRemarkTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
        [HUD showMessage:LanguageToolMatch(@"备注不能为空格")];
    } else {
        if (self.saveBtnBlock) {
            self.saveBtnBlock(_setRemarkTextField.text, _setDesTextView.text);
        }
        [self inputViewDismiss];
    }
}

- (void)cancelBtnAction {
    if (self.cancelBtnBlock) {
        self.cancelBtnBlock();
    }
    [self inputViewDismiss];
}


//当键盘出现
-(void)keyboardWillShow:(NSNotification *)notification{
    if ([self.setRemarkTextField isFirstResponder]) {
        
    }else{
        //    self.numberLabel.hidden = NO;
        self.setDesNumberLabel.text = [NSString stringWithFormat:@"%ld/200",self.setDesTextView.text.length];
        
        self.textViewPlaceHolderLabel.hidden = YES;
    }
}
 
 
//当键盘退出
-(void)keyboardWillHide:(NSNotification *)notification{
//    self.numberLabel.hidden = YES;
    self.setDesNumberLabel.text = [NSString stringWithFormat:@"%ld/200",self.setDesTextView.text.length];
    
    if (![NSString isNil:self.setDesTextView.text]) {
        self.textViewPlaceHolderLabel.hidden = YES;
    }else{
        self.textViewPlaceHolderLabel.hidden = NO;
    }
}

- (void)textViewDidChange {
    UITextRange *selectedRange = self.setDesTextView.markedTextRange;
    UITextPosition *position = [self.setDesTextView positionFromPosition:selectedRange.start offset:0];
    if (position) {
        return;
    }

    // 判断是否超过最大字数限制，如果超过就截断
    if (self.setDesTextView.text.length > 200) {
        self.setDesTextView.text = [self.setDesTextView.text substringToIndex:200];
    }
    
    CGSize textSize = [self.setDesTextView sizeThatFits:CGSizeMake(DScreenWidth-DWScale(16)*4, MAXFLOAT)];
    DLog(@"textSize.height->>>%.2f，_setDesTextView.height->>>%.2f，_setDesBgView.height->>>%.2f，",textSize.height,_setDesTextView.height,_setDesBgView.height);
    if(textSize.height<DWScale(115)){
        self.textViewHeightChangeIndex = 0;
        self.curTextHeight =0.0;
        [_setDesBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(DWScale(16));
            make.top.mas_equalTo(desTipLabel.mas_bottom).offset(DWScale(4));
            make.trailing.mas_equalTo(_viewBg.mas_trailing).offset(-DWScale(16));
            make.height.mas_equalTo(DWScale(115+45));
        }];
    }else{
        if(textSize.height>self.curTextHeight){

            self.textViewHeightChangeIndex++;
        }
        if(textSize.height<self.curTextHeight){

            self.textViewHeightChangeIndex--;
        }
        self.curTextHeight = textSize.height;
        [_setDesBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(DWScale(16));
            make.top.mas_equalTo(desTipLabel.mas_bottom).offset(DWScale(4));
            make.trailing.mas_equalTo(_viewBg.mas_trailing).offset(-DWScale(16));
            make.height.mas_equalTo(DWScale(textSize.height+45-15-3*self.textViewHeightChangeIndex));
        }];
    }

   self.setDesNumberLabel.text = [NSString stringWithFormat:@"%ld/200",self.setDesTextView.text.length];
    // 剩余字数显示 UI 更新
}

- (void)textFieldDidChange{
    // 判断是否存在高亮字符，如果有，则不进行字数统计和字符串截断
    UITextRange *selectedRange = self.setRemarkTextField.markedTextRange;
    UITextPosition *position = [self.setRemarkTextField positionFromPosition:selectedRange.start offset:0];
    if (position) {
        return;
    }

    // 判断是否超过最大字数限制，如果超过就截断
    if (self.setRemarkTextField.text.length > 50) {
        self.setRemarkTextField.text = [self.setRemarkTextField.text substringToIndex:50];
    }
    // 剩余字数显示 UI 更新
   self.setRemarkNumberLabel.text = [NSString stringWithFormat:@"%ld/50",self.setRemarkTextField.text.length];
}

#pragma mark - UITextFieldDelegate
// 用户输入时调用的方法
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.setRemarkTextField) {
        if ([string isEqualToString:@"'"]) {
            [self textFieldDidChange];
            return NO;
        } else {
            [self textFieldDidChange];
            return YES;
        }
    }
    [self textFieldDidChange];
    return YES;
}

// 检查并移除字符串中的逗号
- (NSString *)removeCommasFromString:(NSString *)string {
    return [string stringByReplacingOccurrencesOfString:@"'" withString:@""];
}

#pragma mark - 交互事件
- (void)inputViewSHow {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewBg.transform = CGAffineTransformIdentity;
    }];
}
- (void)inputViewDismiss {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewBg.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN, CGFLOAT_MIN);
    } completion:^(BOOL finished) {
        [weakSelf.viewBg removeFromSuperview];
        weakSelf.viewBg = nil;
        [weakSelf removeFromSuperview];
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

