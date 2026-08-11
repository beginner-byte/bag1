//
//  NoaGroupMemberPageInfoCell.m
//  NoaKit
//
//  Created by Candy on 2026/12/9.
//

#import "NoaGroupMemberPageInfoCell.h"
@interface NoaGroupMemberPageInfoCell ()
//@property (nonatomic, strong) NSArray *titleArr;
@property (nonatomic, strong) UILabel  *lblTypeName;
@property (nonatomic, strong) UIImageView *ivArrowTop;
@property (nonatomic, strong) UILabel  *lblRemark;//备注Label
@property (nonatomic, strong) UILabel  *lblDes;//描述Label
@property (nonatomic, strong) UILabel  *lblNickName;//在本群昵称label
@end
@implementation NoaGroupMemberPageInfoCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = UIColor.clearColor;
        self.backgroundColor = UIColor.clearColor;
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    UIView *viewBg = [[UIView alloc] initWithFrame:CGRectMake(DWScale(16), 0, DScreenWidth - DWScale(16), DWScale(54))];
    viewBg.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    [self.contentView addSubview:viewBg];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.tkThemebackgroundColors = @[[UIColor colorWithRed:151.0/255.0 green:151.0/255.0 blue:151.0/255.0 alpha:1], UIColor.clearColor];
    [viewBg addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(viewBg);
        make.leading.mas_equalTo(0);
        make.trailing.mas_equalTo(viewBg.mas_trailing);
        make.height.mas_equalTo(0.8);
    }];
    
    _lblTypeName = [UILabel new];
    _lblTypeName.font = FONTR(16);
    _lblTypeName.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [viewBg addSubview:_lblTypeName];
    [_lblTypeName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(viewBg);
        make.leading.equalTo(viewBg).offset(0);
    }];
    
    self.ivArrowTop = [[UIImageView alloc] initWithImage:ImgNamed(@"c_arrow_right_gray")];
    [viewBg addSubview:self.ivArrowTop];
    [self.ivArrowTop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(viewBg);
        make.trailing.equalTo(viewBg).offset(-DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(8), DWScale(16)));
    }];

    _lblRemark = [UILabel new];
    _lblRemark.font = FONTR(14);
    _lblRemark.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    [viewBg addSubview:_lblRemark];
    [_lblRemark mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(viewBg);
        make.trailing.equalTo(self.ivArrowTop.mas_leading).offset(DWScale(-10));
    }];

    _lblDes = [UILabel new];
    _lblDes.font = FONTR(14);
    _lblDes.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    [viewBg addSubview:_lblDes];
    [_lblDes mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(viewBg);
        make.leading.equalTo(self.lblTypeName.mas_trailing).offset(DWScale(5));
        make.trailing.equalTo(viewBg).offset(-DWScale(16));
    }];

    _lblNickName = [UILabel new];
    _lblNickName.font = FONTR(14);
    _lblNickName.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    [viewBg addSubview:_lblNickName];
    [_lblNickName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(viewBg);
        make.trailing.equalTo(viewBg).offset(-DWScale(16));
    }];
    
    
}
#pragma mark - 交互事件

+ (CGFloat)defaultCellHeight {
    return DWScale(54);
}

- (void)cellConfigWith:(NSString *)cellType model:(LingIMGroupMemberModel *)model{
    if ([cellType isEqualToString: CellRemarkType]) {
        self.lblRemark.hidden = NO;
        self.ivArrowTop.hidden = NO;
        self.lblDes.hidden = YES;
        self.lblNickName.hidden = YES;
        self.lblTypeName.text = LanguageToolMatch(@"备注：");
    }else if([cellType isEqualToString: CellDesType]){
        self.lblRemark.hidden = NO;
        self.lblDes.hidden = YES;
        self.ivArrowTop.hidden = YES;
        self.lblNickName.hidden = YES;
        self.lblTypeName.text = LanguageToolMatch(@"描述：");
    }else if([cellType isEqualToString: CellNickNameType]){
        self.lblNickName.hidden = NO;
        self.lblRemark.hidden = YES;
        self.ivArrowTop.hidden = YES;
        self.lblDes.hidden = YES;
        self.lblTypeName.text = LanguageToolMatch(@"在本群的昵称：");
        self.lblNickName.text = model.nicknameInGroup;
    }else{
        self.lblNickName.hidden = YES;
        self.lblRemark.hidden = YES;
        self.ivArrowTop.hidden = YES;
        self.lblDes.hidden = YES;
    }
}

@end
