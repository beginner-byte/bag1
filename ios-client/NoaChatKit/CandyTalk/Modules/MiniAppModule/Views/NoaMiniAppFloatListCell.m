//
//  NoaMiniAppFloatListCell.m
//  NoaKit
//
//  Created by Candy on 2023/7/19.
//

#import "NoaMiniAppFloatListCell.h"

@interface NoaMiniAppFloatListCell ()
@property (nonatomic, strong) UIImageView *ivLogo;
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UIButton *btnDelete;
@end

@implementation NoaMiniAppFloatListCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    self.contentView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    
    UIView *viewBg = [[UIView alloc] initWithFrame:CGRectMake(DWScale(18), DWScale(6), DScreenWidth - DWScale(36), DWScale(58))];
    viewBg.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
    viewBg.layer.cornerRadius = DWScale(12);
    viewBg.layer.masksToBounds = YES;
    [self.contentView addSubview:viewBg];
    
    self.baseContentButton.frame = CGRectMake(DWScale(12), 0, DScreenWidth - DWScale(24), DWScale(70));
    [self.contentView addSubview:self.baseContentButton];
    
    _ivLogo = [UIImageView new];
    _ivLogo.layer.cornerRadius = DWScale(22);
    _ivLogo.layer.masksToBounds = YES;
    [self.contentView addSubview:_ivLogo];
    [_ivLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(viewBg);
        make.leading.equalTo(viewBg).offset(DWScale(9));
        make.size.mas_equalTo(CGSizeMake(DWScale(44), DWScale(44)));
    }];
    
    _lblTitle = [UILabel new];
    _lblTitle.font = FONTR(12);
    _lblTitle.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _lblTitle.preferredMaxLayoutWidth = DScreenWidth - DWScale(151);
    [self.contentView addSubview:_lblTitle];
    [_lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(viewBg);
        make.leading.equalTo(_ivLogo.mas_trailing).offset(DWScale(12));
        make.trailing.equalTo(viewBg).offset(-DWScale(50));
    }];
    
    _btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnDelete setImage:ImgNamed(@"mini_app_delete") forState:UIControlStateNormal];
    [_btnDelete addTarget:self action:@selector(btnDeleteClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_btnDelete];
    [_btnDelete mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(viewBg);
        make.trailing.equalTo(viewBg).offset(-DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(22), 22));
    }];
    
    
}
#pragma mark - 界面赋值

-(void)setFloatMiniAppModel:(NoaFloatMiniAppModel *)floatMiniAppModel{
    if (floatMiniAppModel) {
        _floatMiniAppModel = floatMiniAppModel;
        __weak typeof(self) weakSelf = self;
        [_ivLogo sd_setImageWithURL:[floatMiniAppModel.headerUrl getImageFullUrl] placeholderImage:ImgNamed(@"mini_app_icon") options:SDWebImageAllowInvalidSSLCertificates completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!image) {
                strongSelf.ivLogo.image = ImgNamed(@"mini_app_icon");
            }
        }];
        _lblTitle.text = floatMiniAppModel.title;
    }
}

+ (CGFloat)defaultCellHeight {
    return DWScale(70);
}

#pragma mark - 交互事件
- (void)btnDeleteClick {
    if (_delegate && [_delegate respondsToSelector:@selector(miniAppDeleteWith:)]) {
        [_delegate miniAppDeleteWith:self.baseCellIndexPath];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
