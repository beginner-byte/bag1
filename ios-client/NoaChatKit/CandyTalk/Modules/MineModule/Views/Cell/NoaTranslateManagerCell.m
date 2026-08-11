//
//  NoaTranslateManagerCell.m
//  NoaKit
//
//  Created by Candy on 2023/11/2.
//

#import "NoaTranslateManagerCell.h"

@interface NoaTranslateManagerCell ()

@property (nonatomic, strong)UIButton *backView;
@property (nonatomic, strong)UILabel *contentLbl;
@property (nonatomic, strong)UIImageView *arrowImgView;
@property (nonatomic, strong)UIView *lineView;

@end

@implementation NoaTranslateManagerCell

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
    [self.backView addSubview:self.contentLbl];
    [self.backView addSubview:self.arrowImgView];
    [self.backView addSubview:self.lineView];
    
    [self.arrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backView);
        make.trailing.equalTo(self.backView).offset(-16);
        make.width.mas_equalTo(DWScale(8));
        make.height.mas_equalTo(DWScale(16));
    }];
    
    [self.contentLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backView);
        make.leading.equalTo(self.backView).offset(16);
        make.trailing.equalTo(self.arrowImgView.mas_leading).offset(-16);
        make.height.mas_equalTo(DWScale(22));
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.backView);
        make.leading.equalTo(self.backView).offset(16);
        make.trailing.equalTo(self.backView).offset(-16);
        make.height.mas_equalTo(0.8);
    }];
}

#pragma mark - Data
- (void)setContentStr:(NSString *)contentStr {
    _contentStr = contentStr;
    self.contentLbl.text = _contentStr;
}

- (void)configCellRoundWithCellIndex:(NSInteger)index totalIndex:(NSInteger)totalIndex {
    if (index == 0 && totalIndex == 1) {
        [self.backView round:12 RectCorners:UIRectCornerAllCorners];
        self.lineView.hidden = YES;
    } else {
        if (index == 0) {
            [self.backView round:12 RectCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
            self.lineView.hidden = NO;
        } else if (index == totalIndex - 1) {
            [self.backView round:12 RectCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight];
            self.lineView.hidden = YES;
        } else {
            [self.backView round:0 RectCorners:UIRectCornerAllCorners];
            self.lineView.hidden = NO;
        }
    }
}

#pragma mark - Action
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

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.tkThemebackgroundColors = @[COLOR_EEEEEE, [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1]];
    }
    return _lineView;
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
