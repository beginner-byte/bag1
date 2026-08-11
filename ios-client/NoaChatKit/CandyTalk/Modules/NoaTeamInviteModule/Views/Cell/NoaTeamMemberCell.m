//
//  NoaTeamMemberCell.m
//  NoaKit
//
//  Created by Candy on 2023/7/20.
//

#import "NoaTeamMemberCell.h"

@interface NoaTeamMemberCell ()

@property (nonatomic, strong) UILabel *lblName;
@property (nonatomic, strong) UILabel *liveLabel;
@property (nonatomic, strong) UILabel *lblDate;
@property (nonatomic, strong) UIButton *kickOutButton;
@end

@implementation NoaTeamMemberCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.contentView.backgroundColor = UIColor.clearColor;
        [self setupUI];
    }
    return self;
}

#pragma mark - 界面布局
- (void)setupUI {
    [self.contentView addSubview:self.baseContentButton];
    [self.baseContentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    UIView *backView = [UIView new];
    backView.tkThemebackgroundColors = @[COLORWHITE,COLORWHITE_DARK];
    backView.layer.cornerRadius = DWScale(12);
    backView.layer.masksToBounds = YES;
    [self.contentView addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView).offset(DWScale(-10));
    }];
    
    [backView addSubview:self.lblName];
    [self.lblName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(backView).offset(DWScale(16));
        make.top.mas_equalTo(backView).offset(DWScale(18));
        make.trailing.mas_equalTo(backView).offset(-DWScale(160));
        make.height.mas_equalTo(DWScale(20));
    }];
    
    UIImageView *liveImage = [[UIImageView alloc] init];
    liveImage.image = ImgNamed(@"team_live_time_icon");
    [backView addSubview:liveImage];
    [liveImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(backView).offset(DWScale(16));
        make.top.mas_equalTo(self.lblName.mas_bottom).offset(DWScale(13));
        make.width.height.mas_equalTo(DWScale(16));
    }];
    
    [backView addSubview:self.liveLabel];
    [self.liveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(liveImage);
        make.leading.mas_equalTo(liveImage.mas_trailing).offset(DWScale(6));
        make.height.mas_equalTo(DWScale(17));
        make.trailing.mas_equalTo(backView).offset(-DWScale(12));
    }];
    
    UIImageView *dateImage = [[UIImageView alloc] init];
    dateImage.image = ImgNamed(@"team_join_time_icon");
    [backView addSubview:dateImage];
    [dateImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(backView).offset(DWScale(16));
        make.top.mas_equalTo(liveImage.mas_bottom).offset(DWScale(9));
        make.width.height.mas_equalTo(DWScale(16));
    }];
    
    
    [backView addSubview:self.lblDate];
    [self.lblDate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.height.mas_equalTo(self.liveLabel);
        make.centerY.mas_equalTo(dateImage);
    }];

    [backView addSubview:self.kickOutButton];
    [self.kickOutButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(backView).offset(DWScale(12));
        make.trailing.mas_equalTo(backView).offset(DWScale(-12));
        make.height.mas_equalTo(DWScale(32));
        make.width.mas_lessThanOrEqualTo(DScreenWidth - DWScale(200));
        make.width.mas_greaterThanOrEqualTo(DWScale(88));
    }];
}

+ (CGFloat)defaultCellHeight {
    return DWScale(110);
}

#pragma mark - 界面赋值
- (void)setMemberModel:(NoaTeamMemberModel *)memberModel {
    _memberModel = memberModel;
    self.lblName.text = memberModel.nickname;
    self.lblDate.text = [NSString stringWithFormat:@"%@: %@",LanguageToolMatch(@"加入时间"),memberModel.joinTime];
    NSString *latestOffLineTimeString = @"";
    if (memberModel.latestOfflineTime > 0) {
        latestOffLineTimeString = [NSDate timeDescriptionFromTimestamp:memberModel.latestOfflineTime];
    } else if (memberModel.latestOfflineTime == 0) {
        latestOffLineTimeString = LanguageToolMatch(@"在线");
    } else {
        latestOffLineTimeString = @"-";
    }
    self.liveLabel.text = [NSString stringWithFormat:@"%@: %@",LanguageToolMatch(@"最近在线时间"),latestOffLineTimeString];
}

- (void)kickOutEvent{
    if (self.tickoutCallback) {
        self.tickoutCallback();
    }
}

- (UILabel *)lblName {
    if (_lblName == nil) {
        _lblName = [[UILabel alloc] init];
        _lblName.font = FONTM(14);
        _lblName.tkThemetextColors = @[COLOR_11,COLOR_11_DARK];
        _lblName.textAlignment = NSTextAlignmentLeft;
    }
    return _lblName;
}

- (UILabel *)liveLabel {
    if (_liveLabel == nil) {
        _liveLabel = [[UILabel alloc] init];
        _liveLabel.font = FONTR(12);
        _liveLabel.tkThemetextColors = @[COLOR_11,COLOR_11_DARK];
        _liveLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _liveLabel;
}

- (UILabel *)lblDate {
    if (_lblDate == nil) {
        _lblDate = [[UILabel alloc] init];
        _lblDate.font = FONTR(12);
        _lblDate.tkThemetextColors = @[COLOR_11,COLOR_11_DARK];
        _lblDate.textAlignment = NSTextAlignmentLeft;
    }
    return _lblDate;
}

- (UIButton *)kickOutButton{
    if (_kickOutButton == nil) {
        _kickOutButton = [[UIButton alloc] init];
        [_kickOutButton setTitle:LanguageToolMatch(@"踢出团队") forState:UIControlStateNormal];
        [_kickOutButton setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateNormal];
        _kickOutButton.tkThemebackgroundColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.1], [COLOR_5966F2_DARK colorWithAlphaComponent:0.1]];
        [_kickOutButton addTarget:self action:@selector(kickOutEvent) forControlEvents:UIControlEventTouchUpInside];
        [_kickOutButton rounded:DWScale(18)];
        _kickOutButton.titleLabel.font = FONTR(14);
        _kickOutButton.titleEdgeInsets = UIEdgeInsetsMake(6, 16, 6, 16);
    }
    return _kickOutButton;
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
