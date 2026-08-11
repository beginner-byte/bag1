//
//  NoaTeamCell.m
//  NoaKit
//
//  Created by Candy on 2023/7/20.
//

#import "NoaTeamCell.h"

@interface NoaTeamCell ()

@property (nonatomic, strong) UILabel *titleLbl;
@property (nonatomic, strong) UILabel *subTitleLbl;
@property (nonatomic, strong) UIImageView *tipImgView;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation NoaTeamCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        [self setupUI];
    }
    return self;
}

#pragma mark - 界面布局
- (void)setupUI {    
    _titleLbl = [UILabel new];
    _titleLbl.text = @"";
    _titleLbl.font = FONTN(12);
    _titleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [self.contentView addSubview:_titleLbl];
    [_titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(DWScale(16));
        make.centerY.equalTo(self.contentView);
    }];
    _titleLbl.numberOfLines = 2;

    _tipImgView = [UIImageView new];
    _tipImgView.image = ImgNamed(@"");
    _tipImgView.hidden = YES;
    [self.contentView addSubview:_tipImgView];
    [_tipImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView).offset(-DWScale(16));
        make.centerY.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(DWScale(0), DWScale(12)));
    }];
    
    _subTitleLbl = [UILabel new];
    _subTitleLbl.text = @"";
    _subTitleLbl.font = FONTB(14);
    _subTitleLbl.textAlignment = NSTextAlignmentRight;
    _subTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [self.contentView addSubview:_subTitleLbl];
    [_subTitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_tipImgView.mas_leading).offset(-DWScale(6));
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(DWScale(120));
        make.leading.equalTo(_titleLbl.mas_trailing).offset(DWScale(16));
    }];
    _subTitleLbl.numberOfLines = 2;

    _lineView = [UIView new];
    _lineView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
    [self.contentView addSubview:_lineView];
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(DWScale(16));
        make.trailing.equalTo(self.contentView).offset(-DWScale(16));
        make.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(1);
    }];
}

#pragma mark - 界面赋值
- (void)setTitleStr:(NSString *)titleStr {
    _titleStr = titleStr;
    
    _titleLbl.text = _titleStr;
    if ([_titleStr isEqualToString:LanguageToolMatch(@"团队名称")]) {
        _tipImgView.hidden = NO;
        _tipImgView.image = ImgNamed(@"team_arrow_gray");
        [_tipImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.contentView).offset(-DWScale(16));
            make.centerY.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(DWScale(12), DWScale(12)));
        }];
    } else if ([_titleStr isEqualToString:LanguageToolMatch(@"邀请码")]) {
        _tipImgView.hidden = NO;
        _tipImgView.image = ImgNamed(@"team_copy");
        [_tipImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.contentView).offset(-DWScale(16));
            make.centerY.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(DWScale(16), DWScale(16)));
        }];
    } else {
        _tipImgView.hidden = YES;
        _tipImgView.image = nil;
        [_tipImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.contentView).offset(-DWScale(16));
            make.centerY.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(DWScale(0), DWScale(0)));
        }];
    }
}

#pragma mark - Setter
- (void)setSubTitleStr:(NSString *)subTitleStr {
    _subTitleStr = subTitleStr;
    
    _subTitleLbl.text = _subTitleStr;
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
