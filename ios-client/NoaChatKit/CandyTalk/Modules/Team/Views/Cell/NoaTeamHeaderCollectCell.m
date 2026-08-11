//
//  NoaTeamHeaderCollectCell.m
//  NoaKit
//
//  Created by Candy on 2023/9/7.
//

#import "NoaTeamHeaderCollectCell.h"

@interface NoaTeamHeaderCollectCell ()

@property (nonatomic, strong) UIView *teamBackView;
@property (nonatomic, strong) UILabel *teamTitleLbl;
@property (nonatomic, strong) UIButton *defaultTipBtn;
@property (nonatomic, strong) UIView *teamLineView;
@property (nonatomic, strong) UILabel *teamMemberNumLbl;

@end

@implementation NoaTeamHeaderCollectCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

#pragma mark - 界面布局
- (void)setupUI {
    _teamBackView = [UIView new];
    _teamBackView.userInteractionEnabled = YES;
    _teamBackView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    [_teamBackView rounded:DWScale(12) width:1 color:COLOR_F6F6F6];
    [self.contentView addSubview:_teamBackView];
    [_teamBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    _defaultTipBtn = [UIButton new];
    [_defaultTipBtn setTitle:LanguageToolMatch(@"选为默认") forState:UIControlStateNormal];
    [_defaultTipBtn setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateNormal];
    [_defaultTipBtn rounded:DWScale(10) width:1 color:COLOR_ECECEC];
    _defaultTipBtn.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F6F6F6_DARK];
    _defaultTipBtn.titleLabel.font = FONTN(12);
    _defaultTipBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [_defaultTipBtn addTarget:self action:@selector(selectedDefaultTeamClick) forControlEvents:UIControlEventTouchUpInside];
    [_teamBackView addSubview:_defaultTipBtn];
    [_defaultTipBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_teamBackView).offset(DWScale(10));
        make.trailing.equalTo(_teamBackView).offset(-DWScale(10));
        make.size.mas_equalTo(CGSizeMake(DWScale(64), DWScale(20)));
    }];
    
    
    _teamTitleLbl = [UILabel new];
    _teamTitleLbl.text = @"";
    _teamTitleLbl.font = FONTB(14);
    _teamTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [_teamBackView addSubview:_teamTitleLbl];
    [_teamTitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(_teamBackView).offset(DWScale(10));
        make.trailing.equalTo(_defaultTipBtn.mas_leading).offset(-DWScale(10));
        make.height.mas_equalTo(DWScale(20));
    }];
    
    _teamLineView = [UIView new];
    _teamLineView.tkThemebackgroundColors = @[COLOR_FAFAFA, COLOR_FAFAFA_DARK];
    [_teamBackView addSubview:_teamLineView];
    [_teamLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_teamTitleLbl.mas_bottom).offset(DWScale(13));
        make.leading.equalTo(_teamLineView).offset(DWScale(12));
        make.trailing.equalTo(_teamLineView).offset(-DWScale(12));
        make.height.mas_equalTo(1);
    }];
    
    _teamMemberNumLbl = [UILabel new];
    _teamMemberNumLbl.text = @"";
    _teamMemberNumLbl.font = FONTB(10);
    _teamMemberNumLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [_teamBackView addSubview:_teamMemberNumLbl];
    [_teamMemberNumLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_teamLineView.mas_bottom).offset(DWScale(18));
        make.leading.equalTo(_teamBackView).offset(DWScale(10));
        make.trailing.equalTo(_teamBackView).offset(-DWScale(10));
        make.height.mas_equalTo(DWScale(15));
    }];
}

#pragma mark - Setter
- (void)setTeamModel:(NoaTeamModel *)teamModel {
    _teamModel = teamModel;
    
    //团队名称
    _teamTitleLbl.text = _teamModel.teamName;
    //是否是默认团队(0否1是)
    if (_teamModel.isDefaultTeam == 1) {
        _defaultTipBtn.userInteractionEnabled = NO;
        [_defaultTipBtn setTitle:LanguageToolMatch(@"当前默认") forState:UIControlStateNormal];
        [_defaultTipBtn setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
        [_defaultTipBtn rounded:DWScale(10) width:0 color:COLOR_CLEAR];
        _defaultTipBtn.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    } else {
        _defaultTipBtn.userInteractionEnabled = YES;
        [_defaultTipBtn setTitle:LanguageToolMatch(@"选为默认") forState:UIControlStateNormal];
        [_defaultTipBtn setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateNormal];
        [_defaultTipBtn rounded:DWScale(10) width:1 color:COLOR_ECECEC];
        _defaultTipBtn.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F6F6F6_DARK];
    }
    //总团队人数
    NSString *numStr = [NSString stringWithFormat:@"%ld", (long)_teamModel.totalInviteNum];
    NSString *numTitleStr = LanguageToolMatch(@"总团队人数 ");
    NSString *memberNumStr = [NSString stringWithFormat:@"%@%@", numTitleStr, numStr];
    NSMutableAttributedString *memberNumAttStr = [[NSMutableAttributedString alloc] initWithString:memberNumStr];
    [memberNumAttStr configAttStrLightColor:COLOR_11 darkColor:COLOR_11_DARK range:NSMakeRange(0, memberNumStr.length)];
    [memberNumAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2_DARK range:NSMakeRange(numTitleStr.length, numStr.length)];
    [memberNumAttStr addAttribute:NSFontAttributeName value:FONTN(10) range:NSMakeRange(0, memberNumStr.length)];
    [memberNumAttStr addAttribute:NSFontAttributeName value:FONTN(14) range:NSMakeRange(numTitleStr.length, numStr.length)];
    _teamMemberNumLbl.attributedText = memberNumAttStr;
}


#pragma mark - Action
- (void)selectedDefaultTeamClick {
    //选为默认
    if (_delegate && [_delegate respondsToSelector:@selector(selectedTeamForDefaultAction:)]) {
        [_delegate selectedTeamForDefaultAction:self.teamModel];
    }
}

@end
