//
//  NoaGroupListCell.m
//  NoaKit
//
//  Created by Candy on 2026/9/14.
//

#import "NoaGroupListCell.h"
#import "NoaBaseImageView.h"

@interface NoaGroupListCell ()
@property (nonatomic, strong) NoaBaseImageView *ivHeader;
@property (nonatomic, strong) UILabel *lblGroupName;
@end

@implementation NoaGroupListCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
        self.contentView.tkThemebackgroundColors = @[COLORWHITE,COLOR_CLEAR_DARK];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    [self.contentView addSubview:self.baseContentButton];
    self.baseContentButton.frame = CGRectMake(0, 0, DScreenWidth, DWScale(68));
    
    _ivHeader = [[NoaBaseImageView alloc] initWithImage:DefaultGroup];
    _ivHeader.layer.cornerRadius = DWScale(16);
    _ivHeader.layer.masksToBounds = YES;
    [self.contentView addSubview:_ivHeader];
    
    [_ivHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(DWScale(16));
        make.top.mas_equalTo(self.contentView.mas_top).offset(DWScale(12));
        make.size.mas_equalTo(CGSizeMake(DWScale(40), DWScale(40)));

    }];
    
    _lblGroupName = [UILabel new];
    _lblGroupName.text = @"";
    _lblGroupName.font = FONTR(16);
    _lblGroupName.numberOfLines = 1;
    _lblGroupName.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [self.contentView addSubview:_lblGroupName];
    [_lblGroupName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_ivHeader.mas_trailing).offset(DWScale(10));
        make.centerY.equalTo(_ivHeader);
        make.trailing.equalTo(self.contentView).offset(-DWScale(16));
    }];
    
    UIView *line = [UIView new];
    line.tkThemebackgroundColors = @[COLOR_EEF1FA, COLOR_EEF1FA_DARK];
    [self.contentView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(DWScale(0.5));
        make.leading.mas_equalTo(_lblGroupName);
    }];
}
+ (CGFloat)defaultCellHeight {
    return DWScale(68);
}
#pragma mark - 数据赋值
- (void)setGroupModel:(LingIMGroupModel *)groupModel {
    if (groupModel) {
        _groupModel = groupModel;
        _lblGroupName.text = groupModel.groupName;
        
        [_ivHeader sd_setImageWithURL:[groupModel.groupAvatar getImageFullUrl] placeholderImage:DefaultGroup options:SDWebImageAllowInvalidSSLCertificates];
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
