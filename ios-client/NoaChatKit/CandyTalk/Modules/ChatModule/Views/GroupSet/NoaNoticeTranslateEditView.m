//
//  NoaNoticeTranslateEditView.m
//  NoaKit
//
//  Created by Candy on 2024/2/21.
//

#import "NoaNoticeTranslateEditView.h"

@interface NoaNoticeTranslateEditView ()

@property (nonatomic, strong) UIView *viewBg;
@property (nonatomic, strong) UILabel *editTitleLbl;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIView *contentBgView;
@property (nonatomic, strong) UITextView *contentTextView;
@property (nonatomic, strong) UILabel *contentNumLbl;
@property (nonatomic, strong) UIButton *saveButton;

@end


@implementation NoaNoticeTranslateEditView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupUI];
        
        //监听键盘，当键盘将要出现时
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        //当键盘将要退出时
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChange) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

#pragma mark - UI
- (void)setupUI {
    self.frame = CGRectMake(0, 0, DScreenWidth, DScreenHeight);
    self.backgroundColor = [COLOR_00 colorWithAlphaComponent:0.3];
    [CurrentWindow addSubview:self];
    
    _viewBg = [UIView new];
    _viewBg.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    [_viewBg rounded:DWScale(14)];
    _viewBg.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN, CGFLOAT_MIN);
    [self addSubview:_viewBg];
    [_viewBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(DWScale(125));
        make.centerX.equalTo(self);
        make.width.mas_equalTo(DWScale(296));
        make.height.mas_equalTo(DWScale(386));
    }];
    
    _editTitleLbl = [UILabel new];
    _editTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _editTitleLbl.font = FONTR(16);
    _editTitleLbl.textAlignment = NSTextAlignmentCenter;
    [_viewBg addSubview:_editTitleLbl];
    [_editTitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewBg).offset(DWScale(46));
        make.trailing.equalTo(_viewBg).offset(-DWScale(46));
        make.top.equalTo(_viewBg).offset(DWScale(16));
        make.height.mas_equalTo(DWScale(22));
    }];
    
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeButton setImage:ImgNamed(@"icon_sso_help_close") forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_viewBg addSubview:_closeButton];
    [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_editTitleLbl);
        make.trailing.equalTo(_viewBg).offset(-DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(20), DWScale(20)));
    }];
   
    _contentBgView = [UIView new];
    _contentBgView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    [_contentBgView rounded:DWScale(8) width:1 color:COLOR_E6E6E6];
    [_viewBg addSubview:_contentBgView];
    [_contentBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_editTitleLbl.mas_bottom).offset(DWScale(16));
        make.leading.equalTo(_viewBg).offset(DWScale(16));
        make.trailing.equalTo(_viewBg).offset(-DWScale(16));
        make.height.mas_equalTo(DWScale(252));
    }];
    
    _contentTextView = [UITextView new];
    _contentTextView.font = FONTR(16);
    _contentTextView.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    _contentTextView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    [_contentBgView addSubview:_contentTextView];
    [_contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(_contentBgView).offset(DWScale(10));
        make.trailing.equalTo(_contentBgView).offset(-DWScale(10));
        make.bottom.equalTo(_contentBgView).offset(-DWScale(44));
    }];
        
    _contentNumLbl = [UILabel new];
    _contentNumLbl.text = [NSString stringWithFormat:@"%ld/%ld",_contentTextView.text.length, (long)_maxContentNum];
    _contentNumLbl.tkThemetextColors = @[COLOR_99, COLOR_99];
    _contentNumLbl.font = FONTR(14);
    _contentNumLbl.textAlignment = NSTextAlignmentRight;
    [_contentBgView addSubview:_contentNumLbl];
    [_contentNumLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_contentBgView).offset(-DWScale(10));
        make.leading.equalTo(_contentBgView).offset(DWScale(10));
        make.trailing.equalTo(_contentBgView).offset(-DWScale(10));
        make.height.mas_equalTo(DWScale(22));
    }];
    
    _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_saveButton setTitle:LanguageToolMatch(@"保存") forState:UIControlStateNormal];
    [_saveButton setTitleColor:COLORWHITE forState:UIControlStateNormal];
    [_saveButton rounded:DWScale(22)];
    [_saveButton setBackgroundColor:COLOR_5966F2];
    [_saveButton setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateHighlighted];
    [_saveButton addTarget:self action:@selector(saveBtnClicl) forControlEvents:UIControlEventTouchUpInside];
    [_viewBg addSubview:_saveButton];
    [_saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_viewBg);
        make.top.equalTo(_contentBgView.mas_bottom).offset(DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(160), DWScale(44)));
    }];
}

#pragma mark - Setter
- (void)setEditTitelStr:(NSString *)editTitelStr {
    _editTitelStr = editTitelStr;
    
    _editTitleLbl.text = _editTitelStr;
}

- (void)setEditContentStr:(NSString *)editContentStr {
    _editContentStr = editContentStr;
    
    _contentTextView.text = _editContentStr;
    _contentNumLbl.text = [NSString stringWithFormat:@"%ld/%ld",_contentTextView.text.length, (long)_maxContentNum];
}

- (void)setMaxContentNum:(NSInteger)maxContentNum {
    _maxContentNum = maxContentNum;
    
    _contentNumLbl.text = [NSString stringWithFormat:@"%ld/%ld",_contentTextView.text.length, (long)_maxContentNum];
}

#pragma mark - show & dismiss
- (void)editViewShow {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewBg.transform = CGAffineTransformIdentity;
    }];
}
- (void)editViewDismiss {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewBg.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN, CGFLOAT_MIN);
    } completion:^(BOOL finished) {
        [weakSelf.viewBg removeFromSuperview];
        weakSelf.viewBg = nil;
        [weakSelf removeFromSuperview];
    }];
}

#pragma mark - Action
- (void)closeBtnClick {
    [self editViewDismiss];
}

- (void)saveBtnClicl {
    if (self.delegate && [self.delegate respondsToSelector:@selector(editContentFinish:)]) {
        [self.delegate editContentFinish:_contentTextView.text];
    }
    [self editViewDismiss];
}

#pragma mark - Notification
//当键盘出现
-(void)keyboardWillShow:(NSNotification *)notification{
    _contentNumLbl.text = [NSString stringWithFormat:@"%ld/%ld",_contentTextView.text.length, (long)_maxContentNum];
}
 
//当键盘退出
-(void)keyboardWillHide:(NSNotification *)notification{
    _contentNumLbl.text = [NSString stringWithFormat:@"%ld/%ld",_contentTextView.text.length, (long)_maxContentNum];
}

- (void)textViewDidChange {
     // 判断是否存在高亮字符，如果有，则不进行字数统计和字符串截断
     UITextRange *selectedRange = _contentTextView.markedTextRange;
     UITextPosition *position = [_contentTextView positionFromPosition:selectedRange.start offset:0];
     if (position) {
         return;
     }
    
     // 判断是否超过最大字数限制，如果超过就截断
     if (_contentTextView.text.length > _maxContentNum) {
         _contentTextView.text = [_contentTextView.text substringToIndex:_maxContentNum];
     }
    
    //剩余字数显示 UI 更新
    _contentNumLbl.text = [NSString stringWithFormat:@"%ld/%ld",_contentTextView.text.length, (long)_maxContentNum];
}

#pragma mark - Other
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
