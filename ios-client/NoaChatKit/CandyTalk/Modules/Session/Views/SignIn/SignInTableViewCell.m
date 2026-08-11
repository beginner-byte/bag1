//
//  SignInTableViewCell.m
//  NoaKit
//
//  Created by Apple on 2023/8/16.
//

#import "SignInTableViewCell.h"
#import "NoaMessageTimeTool.h"

@interface SignInTableViewCell()

@property(nonatomic, strong)UILabel *createTimerLabel;

@end


@implementation SignInTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = UIColor.clearColor;
        self.backgroundColor = UIColor.clearColor;
        [self setupUI];
    }
    return self;
}
-(void)setupUI {
    _createTimerLabel = [[UILabel alloc] init];
    _createTimerLabel.text = @"";
    _createTimerLabel.textAlignment = NSTextAlignmentCenter;
    _createTimerLabel.tkThemetextColors = @[COLOR_66, COLORWHITE];
    _createTimerLabel.font = FONTR(12);
    [self.contentView addSubview:_createTimerLabel];
    [_createTimerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(DWScale(12));
    }];
    
    UIImageView * logoImgView = [[UIImageView alloc] init];
    logoImgView.image = ImgNamed(@"session_signlIn_header_logo");
    [self.contentView addSubview:logoImgView];
    [logoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(DWScale(16));
        make.top.mas_equalTo(_createTimerLabel.mas_bottom).offset(DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(40), DWScale(40)));
    }];

    UIView * signContentView = [[UIView alloc] initWithFrame:CGRectMake(16 + DWScale(47), DWScale(25), DScreenWidth - DWScale(47) - 16 - 25, DWScale(111))];
    signContentView.tkThemebackgroundColors = @[COLORWHITE, COLOR_66];
    [self.contentView addSubview:signContentView];
    [signContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(logoImgView.mas_trailing).offset(DWScale(7));
        make.top.equalTo(logoImgView);
        make.size.mas_equalTo(CGSizeMake(DScreenWidth - DWScale(63) - DWScale(25), DWScale(111)));
    }];

    if(ZLanguageTOOL.isRTL){
        signContentView.layer.mask = [signContentView round:signContentView.bounds TopLeft:DWScale(16) TopRight:DWScale(2) BottomLeft:DWScale(16) BottomRight:DWScale(16)];
    }else{
        signContentView.layer.mask = [signContentView round:signContentView.bounds TopLeft:DWScale(2) TopRight:DWScale(16) BottomLeft:DWScale(16) BottomRight:DWScale(16)];
    }
    
    UIView * signWarnTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth - DWScale(47) - 16 -25, DWScale(32))];
    signWarnTopView.tkThemebackgroundColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.12], COLOR_5966F2];
    signWarnTopView.clipsToBounds = YES;
    [signContentView addSubview:signWarnTopView];
    
    UILabel * signWarnTitleLabel = [[UILabel alloc] init];
    signWarnTitleLabel.text = LanguageToolMatch(@"签到提醒");
    signWarnTitleLabel.tkThemetextColors = @[COLOR_5966F2, COLORWHITE];
    signWarnTitleLabel.font = FONTR(16);
    [signWarnTopView addSubview:signWarnTitleLabel];
    [signWarnTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(signWarnTopView.mas_leading).offset(DWScale(8));
        make.centerY.mas_equalTo(signWarnTopView);
        make.trailing.mas_equalTo(signWarnTopView.mas_trailing);
    }];
    
    
    NSString *st = [NSString stringWithFormat:LanguageToolMatch(@"欢迎来到%@，不要忘记签到哦～"), [ZTOOL appName]];
    
    UILabel * signWarnContentLabel = [[UILabel alloc] init];
    signWarnContentLabel.text = st;
    signWarnContentLabel.font = FONTR(16);
    signWarnContentLabel.tkThemetextColors = @[COLOR_11, COLORWHITE];
    [signContentView addSubview:signWarnContentLabel];
    [signWarnContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(signContentView.mas_leading).offset(DWScale(8));
        make.top.mas_equalTo(signWarnTopView.mas_bottom).offset(DWScale(7));
        make.trailing.mas_equalTo(signWarnTopView.mas_trailing);
        make.height.mas_equalTo(DWScale(22));
    }];
    UIView * spaceLineView = [[UIView alloc] init];
    spaceLineView.tkThemebackgroundColors = @[COLOR_F3F3F3, COLOR_F5F6F9_DARK];
    [signContentView addSubview:spaceLineView];
    [spaceLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(signContentView.mas_leading).offset(DWScale(5));
        make.trailing.mas_equalTo(signContentView.mas_trailing).offset(DWScale(-8));
        make.height.mas_equalTo(DWScale(1));
        make.top.mas_equalTo(signWarnContentLabel.mas_bottom).offset(DWScale(14));
    }];
    
    UIButton * goSignInButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [goSignInButton setTitle:LanguageToolMatch(@"去签到") forState:UIControlStateNormal];
    goSignInButton.titleLabel.font = FONTR(16);
    [goSignInButton setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2] forState:UIControlStateNormal];
    [signContentView addSubview:goSignInButton];
    [goSignInButton addTarget:self action:@selector(goSignAction) forControlEvents:UIControlEventTouchUpInside];
    [goSignInButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(signContentView);
        make.top.mas_equalTo(spaceLineView.mas_bottom).offset(DWScale(6));
        make.width.mas_equalTo(DWScale(80));
        make.height.mas_equalTo(DWScale(22));
    }];
}

- (void)setSiginSecverTime:(long long)siginSecverTime {
    _siginSecverTime = siginSecverTime;
    
    NSDate *msgTime = [NSDate dateWithTimeIntervalSince1970:_siginSecverTime/1000];
    _createTimerLabel.text = [NoaMessageTimeTool getTimeStringForSignMessage:msgTime mustIncludeTime:YES];
}

-(void)goSignAction{
    if ([self.baseDelegate respondsToSelector:@selector(cellClickAction:)]) {
        [self.baseDelegate cellClickAction:self.baseCellIndexPath];
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
