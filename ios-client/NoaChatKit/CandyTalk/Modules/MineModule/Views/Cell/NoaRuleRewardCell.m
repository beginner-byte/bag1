//
//  NoaRuleRewardCell.m
//  NoaKit
//
//  Created by Candy on 2024/12/26.
//

#import "NoaRuleRewardCell.h"

@interface NoaRuleRewardCell()

@property (nonatomic, strong) UILabel *leftContentLbl;
@property (nonatomic, strong) UILabel *rightContentLbl;
//@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UIView *bottomLine;
@end


@implementation NoaRuleRewardCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
//    self.topLine = [[UIView alloc] init];
//    self.topLine.tkThemebackgroundColors = @[COLOR_99, COLOR_99];
//    [self.contentView addSubview:self.topLine];
//    [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.top.trailing.equalTo(self.contentView);
//        make.height.mas_equalTo(1);
//    }];
    
    UIView *leftLine = [[UIView alloc] init];
    leftLine.tkThemebackgroundColors = @[COLOR_99, COLOR_99];
    [self.contentView addSubview:leftLine];
    [leftLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.equalTo(self.contentView);
        make.width.mas_equalTo(1);
    }];
    
    self.bottomLine = [[UIView alloc] init];
    self.bottomLine.tkThemebackgroundColors = @[COLOR_99, COLOR_99];
    [self.contentView addSubview:self.bottomLine];
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.equalTo(self.contentView);
        make.height.mas_equalTo(1);
    }];
    
    UIView *rightLine = [[UIView alloc] init];
    rightLine.tkThemebackgroundColors = @[COLOR_99, COLOR_99];
    [self.contentView addSubview:rightLine];
    [rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.top.bottom.equalTo(self.contentView);
        make.width.mas_equalTo(1);
    }];
    
    self.leftContentLbl = [[UILabel alloc] init];
    self.leftContentLbl.text = LanguageToolMatch(@"当月连续签到成功天数");
    self.leftContentLbl.tkThemetextColors = @[COLOR_11, COLORWHITE];
    self.leftContentLbl.font = FONTN(14);
    self.leftContentLbl.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.leftContentLbl];
    [self.leftContentLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(leftLine.mas_trailing);
        make.top.equalTo(self.contentView.mas_top);
        make.bottom.equalTo(self.bottomLine.mas_top);
        make.width.mas_equalTo((DScreenWidth - DWScale(16) * 2) * 0.6);
    }];
    
    self.rightContentLbl = [[UILabel alloc] init];
    self.rightContentLbl.text = LanguageToolMatch(@"奖励积分");
    self.rightContentLbl.tkThemetextColors = @[COLOR_11, COLORWHITE];
    self.rightContentLbl.font = FONTN(14);
    self.rightContentLbl.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.rightContentLbl];
    [self.rightContentLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.trailing.equalTo(rightLine.mas_leading);
        make.bottom.equalTo(self.bottomLine.mas_top);
        make.leading.equalTo(self.leftContentLbl.mas_trailing);
    }];
    
    UIView *centerLine = [[UIView alloc] init];
    centerLine.tkThemebackgroundColors = @[COLOR_99, COLOR_99];
    [self.contentView addSubview:centerLine];
    [centerLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.contentView);
        make.leading.equalTo(self.leftContentLbl.mas_trailing);
        make.width.mas_equalTo(1);
    }];
}

- (void)setRewardDic:(NSDictionary *)rewardDic {
    _rewardDic = rewardDic;
    
    NSString *leftValue = [_rewardDic.allKeys firstObject];
    NSNumber *rightValue = [_rewardDic objectForKey:leftValue];
    
    self.leftContentLbl.text = leftValue;
    self.rightContentLbl.text = rightValue.stringValue;
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
