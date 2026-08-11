//
//  NoaMineUserInfoCell.m
//  NoaKit
//
//  Created by Candy on 2026/11/12.
//

#import "NoaMineUserInfoCell.h"

@interface NoaMineUserInfoCell ()

@property (nonatomic, strong)UIButton *backView;
@property (nonatomic, strong)UIImageView *headImgView;
@property (nonatomic, strong)UILabel *titleLbl;
@property (nonatomic, strong)UILabel *subTitleLbl;
@property (nonatomic, strong)UIImageView *arrowImgView;

@end

@implementation NoaMineUserInfoCell

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
    [self.backView addSubview:self.headImgView];
    [self.backView addSubview:self.titleLbl];
    [self.backView addSubview:self.subTitleLbl];
    [self.backView addSubview:self.arrowImgView];
    
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(16.f);
        make.trailing.equalTo(self.contentView).offset(-16.f);
        make.top.equalTo(self.contentView).offset(DWScale(16));
        make.bottom.equalTo(self.contentView);
    }];
    
    [self.titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backView);
        make.leading.equalTo(self.backView).offset(16);
        make.width.mas_equalTo(DWScale(80));
        make.height.mas_equalTo(DWScale(22));
    }];
    
    [self.arrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backView);
        make.trailing.equalTo(self.backView).offset(-16);
        make.width.mas_equalTo(DWScale(8));
        make.height.mas_equalTo(DWScale(16));
    }];
    
    [self.headImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backView);
        make.trailing.equalTo(self.arrowImgView.mas_leading).offset(-4);
        make.top.equalTo(self.backView).offset(DWScale(10));
        make.bottom.equalTo(self.backView).offset(DWScale(-10));
        make.width.equalTo(self.headImgView.mas_height);
    }];
    
    [self.subTitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backView);
        make.leading.equalTo(self.titleLbl.mas_trailing).offset(15);
        make.trailing.equalTo(self.arrowImgView.mas_leading).offset(-4);
        make.height.mas_equalTo(DWScale(20));
    }];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImgViewClick:)];
    self.headImgView.userInteractionEnabled = true;
    [self.headImgView addGestureRecognizer:tapGesture];
}

#pragma mark - Data
- (void)setCellIndex:(NSInteger)cellIndex {
    _cellIndex = cellIndex;
    switch (_cellIndex) {
        case 0:
        {
            self.titleLbl.text = LanguageToolMatch(@"头像");
            self.headImgView.hidden = NO;
            self.subTitleLbl.hidden = YES;
            self.arrowImgView.hidden = NO;
            
            [self.headImgView sd_setImageWithURL:[UserManager.userInfo.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
        }
            break;
        case 1:
        {
            self.titleLbl.text = LanguageToolMatch(@"昵称");
            self.headImgView.hidden = YES;
            self.subTitleLbl.hidden = NO;
            self.arrowImgView.hidden = NO;
            self.subTitleLbl.text = UserManager.userInfo.nickname;
        }
            break;
        case 2:
        {
            self.titleLbl.text = LanguageToolMatch(@"账号");
            self.headImgView.hidden = YES;
            self.subTitleLbl.hidden = NO;
            self.arrowImgView.hidden = YES;
            self.subTitleLbl.text = UserManager.userInfo.userName;
        }
            break;
            
        default:
            break;
    }
}

- (void)setClipImage:(UIImage *)clipImage {
    _clipImage = clipImage;
    
    self.headImgView.hidden = NO;
    self.subTitleLbl.hidden = YES;
    self.headImgView.image = clipImage;
}

#pragma mark - Action
- (void)cellTouchAction {
    if ([self.baseDelegate respondsToSelector:@selector(cellClickAction:)]) {
        [self.baseDelegate cellClickAction:self.baseCellIndexPath];
    }
}

- (void)headImgViewClick:(UIGestureRecognizer *)sender {
    
    UIImageView *imageview = (UIImageView *)sender.view;
    if ([self.delegate respondsToSelector:@selector(headerImageClickAction:url:)]) {
        [self.delegate headerImageClickAction:imageview.image url:[[UserManager.userInfo.avatar getImageFullUrl] absoluteString]];
    }
}

#pragma mark - Lazy
- (UIButton *)backView {
    if (!_backView) {
        _backView = [[UIButton alloc] init];
//        _backView.frame = CGRectMake(16, DWScale(16), DScreenWidth - 16*2, DWScale(54));
        _backView.tkThemebackgroundColors = @[COLORWHITE, COLOR_F5F6F9_DARK];
        [_backView setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateSelected];
        [_backView setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateHighlighted];
        [_backView rounded:12];
        [_backView addTarget:self action:@selector(cellTouchAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backView;
}

- (UIImageView *)headImgView {
    if (!_headImgView) {
        _headImgView = [[UIImageView alloc] init];
        _headImgView.image = DefaultAvatar;
        [_headImgView rounded:DWScale(20)];
    }
    return _headImgView;
}

- (UILabel *)titleLbl {
    if (!_titleLbl) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.text = @"";
        _titleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _titleLbl.font = FONTN(16);
    }
    return _titleLbl;
}

- (UILabel *)subTitleLbl {
    if (!_subTitleLbl) {
        _subTitleLbl = [[UILabel alloc] init];
        _subTitleLbl.text = @"";
        _subTitleLbl.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
        _subTitleLbl.font = FONTN(14);
        _subTitleLbl.textAlignment = NSTextAlignmentRight;
    }
    return _subTitleLbl;
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

