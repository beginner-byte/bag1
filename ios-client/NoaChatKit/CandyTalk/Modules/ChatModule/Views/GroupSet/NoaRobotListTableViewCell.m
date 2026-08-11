//
//  NoaRobotListTableViewCell.m
//  NoaKit
//
//  Created by Apple on 2023/9/25.
//

#import "NoaRobotListTableViewCell.h"
@interface NoaRobotListTableViewCell ()
@property (nonatomic, strong) UILabel  *robotTitle;
@property (nonatomic, strong) UILabel  *robotContent;
@end
@implementation NoaRobotListTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = UIColor.clearColor;
        self.backgroundColor = UIColor.clearColor;
        [self setupUI];
    }
    return self;
}
-(void)setupUI{
    UIButton * _viewBg = [[UIButton alloc] init];
    _viewBg.frame = CGRectMake(0, 0, DScreenWidth , DWScale(62));
    _viewBg.tkThemebackgroundColors =  @[COLORWHITE, COLOR_11];
    [_viewBg setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE]] forState:UIControlStateSelected];
    [_viewBg setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE]] forState:UIControlStateHighlighted];
    
    _ivHeader = [[NoaBaseImageView alloc] initWithImage:DefaultAvatar];
    _ivHeader.layer.cornerRadius = DWScale(22);
    _ivHeader.layer.masksToBounds = YES;
    [self.contentView addSubview:_ivHeader];
    [_ivHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.contentView.mas_leading).offset(DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(44), DWScale(44)));
    }];
 
    [self.contentView addSubview:self.robotTitle];
    
    [self.contentView addSubview:self.robotContent];
    
    [self.robotTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(_ivHeader.mas_trailing).offset(DWScale(8));
        make.top.mas_equalTo(_ivHeader.mas_top);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-DWScale(16));
        make.height.mas_equalTo(DWScale(22));
    }];
    [self.robotContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(_ivHeader.mas_bottom);
        make.leading.mas_equalTo(_ivHeader.mas_trailing).offset(DWScale(8));
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-DWScale(16));
        make.height.mas_equalTo(DWScale(20));
    }];
}
- (void)cellConfigWithModel:(NoaRobotModel *)model{
    if(model){
        [_ivHeader sd_setImageWithURL:[model.headPhoto getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
        self.robotTitle.text = model.robotName;
        self.robotContent.text = model.robotDesc;
    }
}
-(UILabel * )robotTitle{
    if(nil == _robotTitle){
        _robotTitle = [[UILabel alloc] init];
        _robotTitle.font = FONTR(16);
        _robotTitle.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    }
    return _robotTitle;
}
-(UILabel * )robotContent{
    if(nil == _robotContent){
        _robotContent = [[UILabel alloc] init];
        _robotContent.font = FONTR(14);
        _robotContent.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    }
    return _robotContent;
}
+ (CGFloat)defaultCellHeight {
    return DWScale(62);
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
