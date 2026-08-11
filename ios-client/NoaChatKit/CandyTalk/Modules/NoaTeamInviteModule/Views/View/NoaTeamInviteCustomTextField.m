//
//  NoaTeamInviteCustomTextField.m
//  NoaKit
//
//  Created by phl on 2025/8/3.
//

#import "NoaTeamInviteCustomTextField.h"

@interface NoaTeamInviteCustomTextField()

/// 输入框
@property (nonatomic, strong, readwrite) UITextField *textField;

@property (nonatomic, strong, readwrite) UIButton *clearButton;

@end

@implementation NoaTeamInviteCustomTextField

- (UITextField *)textField {
    if (!_textField) {
        _textField = [UITextField new];
    }
    return _textField;
}

- (UIButton *)clearButton {
    if (!_clearButton) {
        _clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clearButton setImage:ImgNamed(@"icon_text_clear") forState:UIControlStateNormal];
        [_clearButton addTarget:self action:@selector(inputTextClearAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clearButton;
}

- (void)setIsShowClearButton:(BOOL)isShowClearButton {
    _isShowClearButton = isShowClearButton;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
    }
    return self;
}

- (void)setUpUI {
    [self addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)configureClearButton {
    // 左侧占用12个单位像素(阿拉伯语语波斯语在右侧)
    self.textField.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, self.height)];
    self.textField.rightViewMode = UITextFieldViewModeWhileEditing;
    
    [self.textField.rightView addSubview:self.clearButton];
    [self.clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@5);
        make.trailing.equalTo(self.textField.rightView).offset(-12);
        make.width.height.equalTo(@18);
        make.centerY.equalTo(self.textField.rightView);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }
    if (_isShowClearButton && !_clearButton) {
        [self configureClearButton];
    }
}

//输入框一键清除
- (void)inputTextClearAction {
    self.textField.text = @"";
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
