//
//  NoaChatActivityLevelHeaderView.m
//  NoaKit
//
//  Created by Candy on 2025/2/19.
//

#import "NoaChatActivityLevelHeaderView.h"

@interface NoaChatActivityLevelHeaderView()

@property(nonatomic, strong)UILabel *levelLbl;
@property(nonatomic, strong)UILabel *scoreLbl;
@property(nonatomic, strong)UILabel *groupSendMsgTipsLbl;
@property(nonatomic, strong)UILabel *groupReadMsgTipsLbl;
@property(nonatomic, strong)UILabel *dayMaxScroeLbl;

@end

@implementation NoaChatActivityLevelHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.contentView.userInteractionEnabled = YES;
    
    UIImageView *levelBackImgView = [[UIImageView alloc] init];
    [levelBackImgView setImage:ImgNamed(@"img_myLevel_score_back")];
    [self.contentView addSubview:levelBackImgView];
    [levelBackImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(DWScale(16));
        make.top.equalTo(self.contentView).offset(DWScale(16));
        make.trailing.equalTo(self.contentView).offset(DWScale(-16));
        make.height.mas_equalTo(DWScale(116));
    }];
    
    _levelLbl = [[UILabel alloc] init];
    NSString *levelContent = @"LV0";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:levelContent];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"DINPro-Bold" size:40] range:NSMakeRange(0, levelContent.length)];//设置字体
    [attributedString addAttribute:NSStrokeColorAttributeName value:COLORWHITE range:NSMakeRange(0, levelContent.length)];// 设置描边颜色为白色
    [attributedString addAttribute:NSStrokeWidthAttributeName value:@(-3) range:NSMakeRange(0, levelContent.length)];//设置描边宽度，负数表示描边和填充同时显示
    [attributedString addAttribute:NSForegroundColorAttributeName value:COLOR_5966F2 range:NSMakeRange(0, levelContent.length)];//设置填充颜色为蓝色
    _levelLbl.attributedText = attributedString;
    [levelBackImgView addSubview:_levelLbl];
    [_levelLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(levelBackImgView).offset(DWScale(24));
        make.trailing.equalTo(levelBackImgView).offset(DWScale(-24));
        make.top.equalTo(levelBackImgView).offset(DWScale(20));
        make.height.mas_equalTo(DWScale(52));
    }];
    
    _scoreLbl = [[UILabel alloc] init];
    _scoreLbl.text = [NSString stringWithFormat:@"%@%d", LanguageToolMatch(@"分值："), 0];
    _scoreLbl.font = FONTN(16);
    _scoreLbl.tkThemetextColors = @[COLOR_0848A7, COLOR_0848A7_DARK];
    _scoreLbl.textAlignment = NSTextAlignmentLeft;
    [levelBackImgView addSubview:_scoreLbl];
    [_scoreLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_levelLbl.mas_bottom).offset(DWScale(8));
        make.leading.equalTo(levelBackImgView).offset(DWScale(24));
        make.trailing.equalTo(levelBackImgView).offset(DWScale(-24));
        make.height.mas_equalTo(DWScale(16));
    }];
    
    UILabel *tips1 = [[UILabel alloc] init];
    tips1.text = LanguageToolMatch(@"群活跃等级根据你在群内发消息情况变化，规则如下");
    tips1.font = FONTN(14);
    tips1.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    [self.contentView addSubview:tips1];
    [tips1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(DWScale(16));
        make.top.equalTo(levelBackImgView.mas_bottom).offset(DWScale(24));
        make.trailing.equalTo(self.contentView).offset(DWScale(-16));
    }];
    
    //群内发言
    UIView *talkBackView = [[UIView alloc] init];
    talkBackView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    [self.contentView addSubview:talkBackView];
    [talkBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView);
        make.top.equalTo(tips1.mas_bottom).offset(DWScale(8));
        make.trailing.equalTo(self.contentView);
        make.height.mas_equalTo(DWScale(74));
    }];
    
    UIImageView *talkIcon = [[UIImageView alloc] init];
    [talkIcon setImage:ImgNamed(@"icon_group_sendmsg_score")];
    [talkBackView addSubview:talkIcon];
    [talkIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(talkBackView).offset(DWScale(16));
        make.centerY.equalTo(talkBackView);
        make.width.mas_equalTo(DWScale(36));
        make.height.mas_equalTo(DWScale(36));
    }];
    
    UILabel *talkTitleLbl = [[UILabel alloc] init];
    talkTitleLbl.text = LanguageToolMatch(@"群内发言");
    talkTitleLbl.font = FONTN(16);
    talkTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [talkBackView addSubview:talkTitleLbl];
    [talkTitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(talkBackView).offset(DWScale(15));
        make.leading.equalTo(talkIcon.mas_trailing).offset(DWScale(12));
        make.trailing.equalTo(talkBackView).offset(DWScale(-16));
        make.height.mas_equalTo(DWScale(22));
    }];
    
    _groupSendMsgTipsLbl = [[UILabel alloc] init];
    _groupSendMsgTipsLbl.text = [NSString stringWithFormat:LanguageToolMatch(@"在群内每发送一条消息得%ld分"), 1];
    _groupSendMsgTipsLbl.font = FONTN(14);
    _groupSendMsgTipsLbl.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    [talkBackView addSubview:_groupSendMsgTipsLbl];
    [_groupSendMsgTipsLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(talkTitleLbl.mas_bottom).offset(DWScale(2));
        make.leading.equalTo(talkIcon.mas_trailing).offset(DWScale(12));
        make.trailing.equalTo(talkBackView).offset(DWScale(-16));
        make.height.mas_equalTo(DWScale(20));
    }];
    
    //分割线
    UIView *lineView = [[UIView alloc] init];
    lineView.tkThemebackgroundColors = @[COLOR_EEEEEE, COLOR_EEEEEE_DARK];
    [talkBackView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(talkBackView.mas_bottom);
        make.leading.equalTo(talkBackView).offset(DWScale(16));
        make.trailing.equalTo(talkBackView).offset(DWScale(-16));
        make.height.mas_equalTo(1);
    }];
    
    //群内在线
    UIView *onlineBackView = [[UIView alloc] init];
    onlineBackView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    [self.contentView addSubview:onlineBackView];
    [onlineBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView);
        make.top.equalTo(talkBackView.mas_bottom);
        make.trailing.equalTo(self.contentView);
        make.height.mas_equalTo(DWScale(74));
    }];
    
    UIImageView *onlineIcon = [[UIImageView alloc] init];
    [onlineIcon setImage:ImgNamed(@"icon_group_readed_score")];
    [onlineBackView addSubview:onlineIcon];
    [onlineIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(onlineBackView).offset(DWScale(16));
        make.centerY.equalTo(onlineBackView);
        make.width.mas_equalTo(DWScale(36));
        make.height.mas_equalTo(DWScale(36));
    }];
    
    UILabel *onlineTitleLbl = [[UILabel alloc] init];
    onlineTitleLbl.text = LanguageToolMatch(@"群内在线");
    onlineTitleLbl.font = FONTN(16);
    onlineTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [onlineBackView addSubview:onlineTitleLbl];
    [onlineTitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(onlineBackView).offset(DWScale(15));
        make.leading.equalTo(onlineIcon.mas_trailing).offset(DWScale(12));
        make.trailing.equalTo(onlineBackView).offset(DWScale(-16));
        make.height.mas_equalTo(DWScale(22));
    }];
    
    _groupReadMsgTipsLbl = [[UILabel alloc] init];
    _groupReadMsgTipsLbl.text = [NSString stringWithFormat:LanguageToolMatch(@"在群内首次已读消息得%ld分"), 1];
    _groupReadMsgTipsLbl.font = FONTN(14);
    _groupReadMsgTipsLbl.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    [onlineBackView addSubview:_groupReadMsgTipsLbl];
    [_groupReadMsgTipsLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(onlineTitleLbl.mas_bottom).offset(DWScale(2));
        make.leading.equalTo(onlineIcon.mas_trailing).offset(DWScale(12));
        make.trailing.equalTo(onlineBackView).offset(DWScale(-16));
        make.height.mas_equalTo(DWScale(20));
    }];
    
    UILabel *tips2 = [[UILabel alloc] init];
    tips2.text = LanguageToolMatch(@"每日分值上限");
    tips2.font = FONTN(14);
    tips2.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    [self.contentView addSubview:tips2];
    [tips2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(DWScale(16));
        make.top.equalTo(onlineBackView.mas_bottom).offset(DWScale(16));
        make.trailing.equalTo(self.contentView).offset(DWScale(-16));
    }];
    
    UIView *dayMaxScroeBackView = [[UIView alloc] init];
    dayMaxScroeBackView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    [self.contentView addSubview:dayMaxScroeBackView];
    [dayMaxScroeBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView);
        make.top.equalTo(tips2.mas_bottom).offset(DWScale(8));
        make.trailing.equalTo(self.contentView);
        make.height.mas_equalTo(DWScale(54));
    }];
    
    _dayMaxScroeLbl = [[UILabel alloc] init];
    _dayMaxScroeLbl.text = LanguageToolMatch(@"群活跃分值每日上限：");
    _dayMaxScroeLbl.font = FONTN(16);
    _dayMaxScroeLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [dayMaxScroeBackView addSubview:_dayMaxScroeLbl];
    [_dayMaxScroeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(dayMaxScroeBackView).offset(DWScale(16));
        make.centerY.equalTo(dayMaxScroeBackView);
        make.trailing.equalTo(dayMaxScroeBackView).offset(DWScale(-16));
        make.height.mas_equalTo(DWScale(54));
    }];
    
    UILabel *tips3 = [[UILabel alloc] init];
    tips3.text = LanguageToolMatch(@"群活跃等级体系");
    tips3.font = FONTN(14);
    tips3.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    [self.contentView addSubview:tips3];
    [tips3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(DWScale(16));
        make.top.equalTo(_dayMaxScroeLbl.mas_bottom).offset(DWScale(16));
        make.trailing.equalTo(self.contentView).offset(DWScale(-16));
        make.bottom.equalTo(self.contentView).offset(DWScale(-8));
    }];
}

#pragma mark - Setter
- (void)setMyLevelScroe:(NSInteger)myLevelScroe {
    _myLevelScroe = myLevelScroe;
}

- (void)setActivityInfoModel:(NoaGroupActivityInfoModel *)activityInfoModel {
    _activityInfoModel = activityInfoModel;
    
    if (_activityInfoModel) {
        NSString *levelContent = [self computeCurrentUserLevel];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:levelContent];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"DINPro" size:40] range:NSMakeRange(0, levelContent.length)];//设置字体
        [attributedString addAttribute:NSStrokeColorAttributeName value:COLORWHITE range:NSMakeRange(0, levelContent.length)];// 设置描边颜色为白色
        [attributedString addAttribute:NSStrokeWidthAttributeName value:@(-3) range:NSMakeRange(0, levelContent.length)];//设置描边宽度，负数表示描边和填充同时显示
        [attributedString addAttribute:NSForegroundColorAttributeName value:COLOR_5966F2 range:NSMakeRange(0, levelContent.length)];//设置填充颜色为蓝色
        _levelLbl.attributedText = attributedString;
        
        _scoreLbl.text = [NSString stringWithFormat:@"%@%ld", LanguageToolMatch(@"分值："), (long)_myLevelScroe];
        
        NoaGroupActivityActionModel *talkActionModel = (NoaGroupActivityActionModel *)[_activityInfoModel.actions objectAtIndexSafe:0];
        if (talkActionModel) {
            _groupSendMsgTipsLbl.text = [NSString stringWithFormat:LanguageToolMatch(@"在群内每发送一条消息得%ld分"), (long)talkActionModel.score];
        }
        NoaGroupActivityActionModel *onlineActionModel = (NoaGroupActivityActionModel *)[_activityInfoModel.actions objectAtIndexSafe:1];
        if (onlineActionModel) {
            _groupReadMsgTipsLbl.text = [NSString stringWithFormat:LanguageToolMatch(@"在群内首次已读消息得%ld分"), (long)onlineActionModel.score];
        }
        
        _dayMaxScroeLbl.text = [NSString stringWithFormat:@"%@%ld", LanguageToolMatch(@"群活跃分值每日上限："), (long)_activityInfoModel.dailyLimit];
    }
}

- (NSString *)computeCurrentUserLevel {
    NSString *levelStr = @"--";
    for (NoaGroupActivityLevelModel *levelConfigInfo in _activityInfoModel.sortLevels) {
        if (_myLevelScroe >= levelConfigInfo.minScore) {
            levelStr = [NSString isNil:levelConfigInfo.alias] ? levelConfigInfo.level : levelConfigInfo.alias;
        }
    }
    return levelStr;
}

@end
