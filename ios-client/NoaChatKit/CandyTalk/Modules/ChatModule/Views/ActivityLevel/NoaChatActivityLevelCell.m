//
//  NoaChatActivityLevelCell.m
//  NoaKit
//
//  Created by Candy on 2025/2/19.
//

#import "NoaChatActivityLevelCell.h"

@interface NoaChatActivityLevelCell()

@property(nonatomic, strong)UILabel *levelLbl;
@property(nonatomic, strong)UILabel *scoreLbl;

@end

@implementation NoaChatActivityLevelCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        self.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _levelLbl = [[UILabel alloc] init];
    _levelLbl.text = @"--";
    _levelLbl.font = FONTN(16);
    _levelLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _levelLbl.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    [self.contentView addSubview:_levelLbl];
    [_levelLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(DWScale(16));
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo((DScreenWidth - DWScale(32)) / 2);
        make.height.mas_equalTo(DWScale(20));
    }];
    
    _scoreLbl = [[UILabel alloc] init];
    _scoreLbl.text = @"--";
    _scoreLbl.font = FONTN(16);
    _scoreLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _scoreLbl.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    _scoreLbl.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_scoreLbl];
    [_scoreLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView).offset(DWScale(-16));
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo((DScreenWidth - DWScale(32)) / 2);
        make.height.mas_equalTo(DWScale(20));
    }];
    
    //分割线
    UIView *lineView = [[UIView alloc] init];
    lineView.tkThemebackgroundColors = @[COLOR_EEEEEE, COLOR_EEEEEE_DARK];
    [self.contentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.leading.equalTo(self.contentView).offset(DWScale(16));
        make.trailing.equalTo(self.contentView).offset(DWScale(-16));
        make.height.mas_equalTo(1);
    }];
}

- (void)setActivityLevelModel:(NoaGroupActivityLevelModel *)activityLevelModel {
    _activityLevelModel = activityLevelModel;
    
    _levelLbl.text = [NSString isNil:_activityLevelModel.alias] ? _activityLevelModel.level : _activityLevelModel.alias;
    _scoreLbl.text = [NSString stringWithFormat:@"%ld", (long)_activityLevelModel.minScore];
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
