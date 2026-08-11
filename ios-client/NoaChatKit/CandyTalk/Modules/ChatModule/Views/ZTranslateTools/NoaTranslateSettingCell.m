//
//  NoaTranslateSettingCell.m
//  NoaKit
//
//  Created by Candy on 2023/12/26.
//

#import "NoaTranslateSettingCell.h"

@interface NoaTranslateSettingCell ()

@property (nonatomic, strong)UIButton *backView;
@property (nonatomic, strong)UIButton *switchBtn;
@property (nonatomic, strong)UILabel *leftLbl;
@property (nonatomic, strong)UILabel *rightLbl;
@property (nonatomic, strong)UIImageView *arrowImgView;

@end

@implementation NoaTranslateSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = UIColor.clearColor;
        self.backgroundColor = UIColor.clearColor;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self.contentView addSubview:self.backView];
    [self.backView addSubview:self.switchBtn];
    [self.backView addSubview:self.leftLbl];
    [self.backView addSubview:self.rightLbl];
    [self.backView addSubview:self.arrowImgView];
    
    [self.arrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backView);
        make.trailing.equalTo(self.backView).offset(-DWScale(16));
        make.width.mas_equalTo(DWScale(8));
        make.height.mas_equalTo(DWScale(16));
    }];
    
    [self.switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backView);
        make.trailing.equalTo(self.backView).offset(-DWScale(16));
        make.width.mas_equalTo(DWScale(44));
        make.height.mas_equalTo(DWScale(44));
    }];
    
    [self.leftLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backView);
        make.leading.equalTo(self.backView).offset(DWScale(16));
        
        if ([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"俄语"]) {
            make.width.mas_equalTo(DWScale(DScreenWidth - 120));
        } else {
            make.width.mas_equalTo(DWScale(150));
        }
        make.height.mas_equalTo(DWScale(22));
    }];
    
    [self.rightLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backView);
        make.leading.equalTo(self.leftLbl.mas_trailing).offset(DWScale(10));
        make.trailing.equalTo(self.arrowImgView.mas_leading).offset(-DWScale(10));
        make.height.mas_equalTo(DWScale(20));
    }];
}

#pragma mark - Data
- (void)setLeftTitleStr:(NSString *)leftTitleStr {
    _leftTitleStr = leftTitleStr;
    self.leftLbl.text = _leftTitleStr;
    if ([leftTitleStr isEqualToString:LanguageToolMatch(@"接收消息翻译")]) {
        //消息翻译
        self.leftLbl.font = FONTB(16);
        self.leftLbl.hidden = NO;
        self.switchBtn.hidden = YES;
        self.rightLbl.hidden = YES;
        self.arrowImgView.hidden = YES;
    }
    if ([leftTitleStr isEqualToString:LanguageToolMatch(@"通道")]) {
        //渠道
        self.leftLbl.font = FONTN(16);
        self.leftLbl.hidden = NO;
        self.switchBtn.hidden = YES;
        self.rightLbl.hidden = NO;
        self.arrowImgView.hidden = NO;
    }
    if ([leftTitleStr isEqualToString:LanguageToolMatch(@"语种")]) {
        //语种
        self.leftLbl.font = FONTN(16);
        self.leftLbl.hidden = NO;
        self.switchBtn.hidden = YES;
        self.rightLbl.hidden = NO;
        self.arrowImgView.hidden = NO;
    }
    if ([leftTitleStr isEqualToString:LanguageToolMatch(@"自动翻译接收信息")]) {
        //自动翻译接收信息
        self.leftLbl.font = FONTN(16);
        self.leftLbl.hidden = NO;
        self.switchBtn.hidden = NO;
        self.rightLbl.hidden = YES;
        self.arrowImgView.hidden = YES;
    }
    if ([leftTitleStr isEqualToString:LanguageToolMatch(@"发送消息实时翻译")]) {
        //发送消息实时翻译
        self.leftLbl.font = FONTB(16);
        self.leftLbl.hidden = NO;
        self.switchBtn.hidden = YES;
        self.rightLbl.hidden = YES;
        self.arrowImgView.hidden = YES;
    }
    if ([leftTitleStr isEqualToString:LanguageToolMatch(@"实时翻译")]) {
        //实时翻译
        self.leftLbl.font = FONTN(16);
        self.leftLbl.hidden = NO;
        self.switchBtn.hidden = NO;
        self.rightLbl.hidden = YES;
        self.arrowImgView.hidden = YES;
    }
    if ([leftTitleStr isEqualToString:LanguageToolMatch(@"消息翻译默认值")]) {
        //实时翻译
        self.leftLbl.font = FONTB(16);
        self.leftLbl.hidden = NO;
        self.switchBtn.hidden = YES;
        self.rightLbl.hidden = YES;
        self.arrowImgView.hidden = YES;
    }
    if ([leftTitleStr isEqualToString:LanguageToolMatch(@"发送翻译默认值")]) {
        //实时翻译
        self.leftLbl.font = FONTB(16);
        self.leftLbl.hidden = NO;
        self.switchBtn.hidden = YES;
        self.rightLbl.hidden = YES;
        self.arrowImgView.hidden = YES;
    }
}

- (void)setRightTitleStr:(NSString *)rightTitleStr {
    _rightTitleStr = rightTitleStr;
    self.rightLbl.text = _rightTitleStr;
}

- (void)setSwitchIsOn:(BOOL)switchIsOn {
    _switchIsOn = switchIsOn;
    self.switchBtn.selected = _switchIsOn;
}

- (void)configCellRoundWithCellIndex:(NSInteger)index totalIndex:(NSInteger)totalIndex {
    if (index == 0 && totalIndex == 1) {
        [self.backView round:12 RectCorners:UIRectCornerAllCorners];
    } else {
        if (index == 0) {
            [self.backView round:12 RectCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
        } else if (index == totalIndex - 1) {
            [self.backView round:12 RectCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight];
        } else {
            [self.backView round:0 RectCorners:UIRectCornerAllCorners];
        }
    }
}

#pragma mark - Action
- (void)switchBtnAction {
    if (self.switchBlock) {
        self.switchBlock(!_switchBtn.selected);
    }
}

- (void)cellTouchAction {
    if ([self.baseDelegate respondsToSelector:@selector(cellClickAction:)]) {
        [self.baseDelegate cellClickAction:self.baseCellIndexPath];
    }
}

#pragma mark - Lazy
- (UIButton *)backView {
    if (!_backView) {
        _backView = [[UIButton alloc] init];
        _backView.frame = CGRectMake(16, 0, DScreenWidth - 16*2, DWScale(54));
        _backView.tkThemebackgroundColors = @[COLORWHITE, COLOR_F5F6F9_DARK];
        [_backView setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateSelected];
        [_backView setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateHighlighted];
        [_backView addTarget:self action:@selector(cellTouchAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backView;
}

- (UIButton *)switchBtn {
    if (!_switchBtn) {
        _switchBtn = [[UIButton alloc] init];
        [_switchBtn setImage:ImgNamed(@"c_switch_off") forState:UIControlStateNormal];
        [_switchBtn setImage:ImgNamed(@"c_switch_on") forState:UIControlStateSelected];
        [_switchBtn addTarget:self action:@selector(switchBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchBtn;
}

- (UILabel *)leftLbl {
    if (!_leftLbl) {
        _leftLbl = [[UILabel alloc] init];
        _leftLbl.text = @"";
        _leftLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _leftLbl.font = FONTN(16);
    }
    return _leftLbl;
}

- (UILabel *)rightLbl {
    if (!_rightLbl) {
        _rightLbl = [[UILabel alloc] init];
        _rightLbl.text = @"";
        _rightLbl.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
        _rightLbl.font = FONTN(14);
        _rightLbl.textAlignment = NSTextAlignmentRight;
    }
    return _rightLbl;
}

- (UIImageView *)arrowImgView {
    if (!_arrowImgView) {
        _arrowImgView = [[UIImageView alloc] init];
        _arrowImgView.image = ImgNamed(@"c_arrow_right_gray");
    }
    return _arrowImgView;
}

#pragma mark - Other
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
