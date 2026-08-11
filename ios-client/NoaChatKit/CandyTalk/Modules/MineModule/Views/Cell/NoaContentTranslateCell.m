//
//  NoaContentTranslateCell.m
//  NoaKit
//
//  Created by Candy on 2023/9/14.
//

#import "NoaContentTranslateCell.h"

@interface NoaContentTranslateCell ()

@property (nonatomic, strong) UIButton *backView;
@property (nonatomic, strong) UILabel *contentLbl;
@property (nonatomic, strong) UIButton *switchBtn;
@property (nonatomic, strong) UIImageView *arrowImgView;

@end

@implementation NoaContentTranslateCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self.contentView addSubview:self.backView];
    [self.backView addSubview:self.switchBtn];
    [self.backView addSubview:self.contentLbl];
    [self.backView addSubview:self.arrowImgView];
    
    
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(self.contentView).offset(DWScale(16));
        make.trailing.equalTo(self.contentView).offset(-DWScale(16));
        make.height.mas_equalTo(DWScale(54));
    }];
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
    
    [self.contentLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backView);
        make.leading.equalTo(self.backView).offset(DWScale(16));
        make.trailing.equalTo(self.switchBtn.mas_leading).offset(-DWScale(16));
        make.height.mas_equalTo(DWScale(25));
    }];
}

#pragma mark - Data
- (void)setContentStr:(NSString *)contentStr {
    _contentStr = contentStr;
    
    self.contentLbl.text = _contentStr;
}

- (void)configCellRightViewWith:(NSIndexPath *)cellIndexPath {
    if (cellIndexPath.row == 1) {
        //自动翻译聊天中的消息
        self.arrowImgView.hidden = YES;
        self.switchBtn.hidden = NO;
    }else {
        self.arrowImgView.hidden = NO;
        self.switchBtn.hidden = YES;
    }
}

- (void)setSwitchIsOn:(BOOL)switchIsOn {
    _switchIsOn = switchIsOn;
    
    self.switchBtn.selected = _switchIsOn;
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
        _backView.tkThemebackgroundColors = @[COLORWHITE, COLOR_EEEEEE_DARK];
        [_backView setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateSelected];
        [_backView setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateHighlighted];
        [_backView rounded:DWScale(12)];
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

- (UILabel *)contentLbl {
    if (!_contentLbl) {
        _contentLbl = [[UILabel alloc] init];
        _contentLbl.text = @"";
        _contentLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _contentLbl.font = FONTN(16);
    }
    return _contentLbl;
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
