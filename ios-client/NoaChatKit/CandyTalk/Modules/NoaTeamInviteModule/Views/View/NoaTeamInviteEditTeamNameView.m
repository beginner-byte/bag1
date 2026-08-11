//
//  NoaTeamInviteEditTeamNameView.m
//  NoaKit
//
//  Created by phl on 2025/7/25.
//

#import "NoaTeamInviteEditTeamNameView.h"
#import "NoaTeamInviteEditTeamNameDataHandle.h"
#import "NoaTeamInviteCustomTextField.h"

@interface NoaTeamInviteEditTeamNameView()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) UIButton *saveButton;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) NoaTeamInviteCustomTextField *teamNameTextField;

@property (nonatomic, strong) NoaTeamInviteEditTeamNameDataHandle *editTeamNameDataHandle;

@end

@implementation NoaTeamInviteEditTeamNameView

- (void)dealloc {
    CIMLog(@"%@ dealloc", [self class]);
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _titleLabel.font = FONTM(16);
        _titleLabel.text = LanguageToolMatch(@"团队名称");
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
        _backButton.titleLabel.font = FONTR(15);
        _backButton.titleLabel.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _backButton.titleEdgeInsets = UIEdgeInsetsMake(16, 16, 16, 16);
    }
    return _backButton;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveButton setTitle:LanguageToolMatch(@"保存") forState:UIControlStateNormal];
        _saveButton.titleLabel.font = FONTM(15);
        _saveButton.titleLabel.tkThemetextColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
        _saveButton.titleEdgeInsets = UIEdgeInsetsMake(16, 16, 16, 16);
    }
    return _saveButton;
}

- (NoaTeamInviteCustomTextField *)teamNameTextField {
    if (!_teamNameTextField) {
        _teamNameTextField = [NoaTeamInviteCustomTextField new];
        _teamNameTextField.textField.font = FONTR(14);
        _teamNameTextField.textField.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _teamNameTextField.textField.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
        _teamNameTextField.isShowClearButton = YES;
        // 为了适配rtl（阿拉伯、波斯语布局，只能用NSMutableAttributedString）
        NSMutableAttributedString *placeHolderAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"请输入团队名称") attributes:@{
            NSForegroundColorAttributeName: COLOR_99
        }];
        _teamNameTextField.textField.attributedPlaceholder = placeHolderAttStr;
        // 获取当前首选语言，判断是否为阿拉伯语(ar)或波斯语(fa)
        NSString *preferredLanguage = [NSLocale preferredLanguages].firstObject;
        BOOL isArabic = [preferredLanguage hasPrefix:@"ar"]; // 阿拉伯语代码以"ar"开头
        BOOL isPersian = [preferredLanguage hasPrefix:@"fa"]; // 波斯语代码以"fa"开头
        
        if (isArabic || isPersian) {
            _teamNameTextField.textField.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
            _teamNameTextField.textField.rightViewMode = UITextFieldViewModeAlways;
        }else {
            // 左侧占用12个单位像素(阿拉伯语语波斯语在右侧)
            if ([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"阿拉伯语"] ||
                [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"波斯语"]) {
                _teamNameTextField.textField.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
                _teamNameTextField.textField.rightViewMode = UITextFieldViewModeAlways;
            }   else {
                _teamNameTextField.textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
                _teamNameTextField.textField.leftViewMode = UITextFieldViewModeAlways;
            }
        }
    }
    return _teamNameTextField;
}

- (instancetype)initWithFrame:(CGRect)frame editTeamNameDataHandle:(NoaTeamInviteEditTeamNameDataHandle *)dataHandle {
    self = [super initWithFrame:frame];
    if (self) {
        self.editTeamNameDataHandle = dataHandle;
        [self setupUI];
        [self processData];
    }
    return self;
}

- (void)setupUI {
    // 背景颜色
    self.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
    
    // 计算按钮宽度
    CGFloat backButtonWidth = [self calculateButtonWidthForText:self.backButton.titleLabel.text font:FONTR(15)];
    CGFloat saveButtonWidth = [self calculateButtonWidthForText:self.saveButton.titleLabel.text font:FONTM(15)];

   // 返回按钮
    [self addSubview:self.backButton];
    // 团队名称
    [self addSubview:self.titleLabel];
    // 保存按钮
    [self addSubview:self.saveButton];
    // 团队名称
    [self addSubview:self.teamNameTextField];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@0);
        make.top.equalTo(@8);
        make.height.greaterThanOrEqualTo(@56);
        make.width.equalTo(@(backButtonWidth));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backButton);
        make.centerX.equalTo(self);
        make.height.equalTo(@16);
    }];
    
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self);
        make.top.equalTo(@8);
        make.height.greaterThanOrEqualTo(@56);
        make.width.equalTo(@(saveButtonWidth));
    }];
    
    [self.teamNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(24);
        make.leading.equalTo(@16);
        make.trailing.equalTo(self).offset(-16);
        make.height.equalTo(@44);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 切圆角
        CAShapeLayer *teamNameTFLayer = [self configCornerRect:UIRectCornerAllCorners radius:8.0 rect:self.teamNameTextField.bounds];
        [self.teamNameTextField.layer addSublayer:teamNameTFLayer];
    });
    
    @weakify(self)
    [[self.backButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        [self.editTeamNameDataHandle.backSubject sendNext:@""];
    }];
    
    [[self.saveButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        if ([NSString isNil:self.teamNameTextField.textField.text]) {
            [HUD showMessage:LanguageToolMatch(@"团队名称不能为空")];
            return;
        }
        [self.editTeamNameDataHandle.editTeamDetailInfoCommand execute:self.teamNameTextField.textField.text];
    }];
    
    self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        @strongify(self)
        if (themeIndex == 0) {
            [self.backButton setTitleColor:COLOR_11 forState:UIControlStateNormal];
            [self.saveButton setTitleColor:COLOR_5966F2 forState:UIControlStateNormal];
        } else {
            [self.backButton setTitleColor:COLOR_11_DARK forState:UIControlStateNormal];
            [self.saveButton setTitleColor:COLOR_5966F2_DARK forState:UIControlStateNormal];
        }
    };
}

- (void)processData {
    self.teamNameTextField.textField.text = [NSString isNil:self.editTeamNameDataHandle.currentTeamModel.teamName] ? @"" : self.editTeamNameDataHandle.currentTeamModel.teamName;
    
    @weakify(self)
    [self.editTeamNameDataHandle.editTeamDetailInfoCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        BOOL isSuccess = [x boolValue];
        if (!isSuccess) {
            return;
        }
        [self.editTeamNameDataHandle.backSubject sendNext:self.teamNameTextField.textField.text];
    }];
    
    // 添加RAC信号处理输入长度限制
    // throttle:用于限制信号发送的频率。在这里，0.1表示信号在0.1秒内最多发送一次
    [[self.teamNameTextField.textField.rac_textSignal throttle:0.1] subscribeNext:^(NSString *text) {
        @strongify(self)
        if (text.length > 50) {
            self.teamNameTextField.textField.text = [text substringToIndex:50];
        }
    }];
}

/// 将控件画圆角
/// - Parameters:
///   - corners: 哪个角绘制圆角
///   - cornerRadius: 半径
///   - rect: 控件的frame
- (CAShapeLayer *)configCornerRect:(UIRectCorner)corners
                            radius:(CGFloat)cornerRadius
                              rect:(CGRect)rect {
    //  创建圆角路径
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = rect;
    maskLayer.path = maskPath.CGPath;
    
    // 边框相关设置
    maskLayer.lineWidth = 1;
    maskLayer.strokeColor = COLOR_5966F2.CGColor;
    maskLayer.fillColor = UIColor.clearColor.CGColor;
    @weakify(maskLayer)
    maskLayer.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        @strongify(maskLayer)
        if (themeIndex == 0) {
            maskLayer.strokeColor = COLOR_5966F2.CGColor;
        } else {
            maskLayer.strokeColor = COLOR_5966F2_DARK.CGColor;
        }
    };
    
    return maskLayer;
}

// 计算文本宽度的方法
- (CGFloat)calculateButtonWidthForText:(NSString *)text font:(UIFont *)font {
    NSDictionary *attributes = @{NSFontAttributeName: font};
    CGSize size = [text sizeWithAttributes:attributes];
    CGFloat textWidth = size.width + 35; // 左右各16的内边距,多余出来一点
    return MIN(textWidth, 150); // 最大不超过150
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
