//
//  NoaChatSingleSetCommonCell.m
//  NoaKit
//
//  Created by Candy on 2026/12/29.
//

#import "NoaChatSingleSetCommonCell.h"
@interface NoaChatSingleSetCommonCell ()
@property (nonatomic, strong) LingIMFriendModel *model;
@end

@implementation NoaChatSingleSetCommonCell

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
    _viewBg = [[UIButton alloc] init];
    _viewBg.frame = CGRectMake(DWScale(16), 0, DScreenWidth - DWScale(32), DWScale(54));
    _viewBg.tkThemebackgroundColors =  @[COLORWHITE, COLOR_F5F6F9_DARK];
    [_viewBg setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateSelected];
    [_viewBg setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateHighlighted];
    [_viewBg addTarget:self action:@selector(cellTouchAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_viewBg];
    
    _lblTitle = [UILabel new];
    _lblTitle.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _lblTitle.font = FONTR(16);
    _lblTitle.preferredMaxLayoutWidth = DWScale(100);
    [_viewBg addSubview:_lblTitle];
    [_lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_viewBg);
        make.leading.equalTo(_viewBg).offset(DWScale(16));
    }];
    
    _ivArrow = [[UIImageView alloc] initWithImage:ImgNamed(@"c_arrow_right_gray")];
    [_viewBg addSubview:_ivArrow];
    [_ivArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_viewBg);
        make.trailing.equalTo(_viewBg).offset(-DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(8), DWScale(16)));
    }];
    
    _btnAction = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnAction.userInteractionEnabled = NO;
    [_btnAction setImage:ImgNamed(@"c_switch_off") forState:UIControlStateNormal];
    [_btnAction setImage:ImgNamed(@"c_switch_on") forState:UIControlStateSelected];
    [_viewBg addSubview:_btnAction];
    [_btnAction mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_viewBg);
        make.trailing.equalTo(_viewBg).offset(-DWScale(15));
        make.size.mas_equalTo(CGSizeMake(DWScale(44), DWScale(44)));
    }];
    
    _btnCenter = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnCenter.userInteractionEnabled = NO;
    [_btnCenter setTitleColor:HEXCOLOR(@"FF3333") forState:UIControlStateNormal];
    _btnCenter.titleLabel.font = FONTR(16);
    [_viewBg addSubview:_btnCenter];
    [_btnCenter mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_viewBg);
    }];
    
    _viewLine = [UIView new];
    _viewLine.tkThemebackgroundColors = @[COLOR_EEEEEE, [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1]];
    [_viewBg addSubview:_viewLine];
    [_viewLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewBg).offset(DWScale(16));
        make.trailing.equalTo(_viewBg).offset(-DWScale(16));
        make.bottom.equalTo(_viewBg);
        make.height.mas_equalTo(DWScale(1));
    }];
    
    _lblContent = [UILabel new];
    _lblContent.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    _lblContent.font = FONTR(14);
    [_viewBg addSubview:_lblContent];
    [_lblContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_viewBg);
        make.trailing.equalTo(_viewBg).offset(-DWScale(30));
    }];
}

- (void)cellTouchAction {
    if ([self.baseDelegate respondsToSelector:@selector(cellClickAction:)]) {
        [self.baseDelegate cellClickAction:self.baseCellIndexPath];
    }
}

- (void)setCornerRadiusWithIsShow:(BOOL)isShow location:(CornerRadiusLocationType)locationType{
    
    if (isShow) {
        UIBezierPath *path;
        if (locationType == CornerRadiusLocationAll) {
            path = [UIBezierPath bezierPathWithRoundedRect:self.viewBg.bounds  byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(DWScale(12), DWScale(12))];
        }else if (locationType == CornerRadiusLocationTop){
            path = [UIBezierPath bezierPathWithRoundedRect:self.viewBg.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(DWScale(12), DWScale(12))];
        }else{
            path = [UIBezierPath bezierPathWithRoundedRect:self.viewBg.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(DWScale(12), DWScale(12))];
        }
        
        CAShapeLayer *layer1 = [[CAShapeLayer alloc]init];
        layer1.frame = self.viewBg.bounds;
        layer1.path = path.CGPath;
        self.viewBg.layer.mask = layer1;
    }else{
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.viewBg.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeZero];
        
        CAShapeLayer *layer1 = [[CAShapeLayer alloc]init];
        layer1.frame = self.viewBg.bounds;
        layer1.path = path.CGPath;
        self.viewBg.layer.mask = layer1;
    }
}
#pragma mark - 界面赋值更新
- (void)cellConfigWith:(ChatSingleSetCommonCellType)cellType itemStr:(NSString *)itemStr  model:(LingIMFriendModel *)model {
    if (cellType) {
        _model = model;
        
        _lblTitle.hidden = YES;
        _ivArrow.hidden = YES;
        _btnAction.hidden = YES;
        _btnCenter.hidden = YES;
        _viewLine.hidden = YES;
        _lblContent.hidden = YES;
        
        if (cellType == ChatSingleSetCellTypeCommon) {
            //群管理
            _lblTitle.hidden = NO;
            _lblTitle.text = itemStr;
            _ivArrow.hidden = NO;
        }else if (cellType == ChatSingleSetCellTypeSelect) {
            //通用功能
            _lblTitle.hidden = NO;
            _lblTitle.text = itemStr;
            _viewLine.hidden = NO;
            _btnAction.hidden = NO;
            if ([itemStr isEqualToString:LanguageToolMatch(@"消息置顶")]) {
                _btnAction.selected = model.msgTop;
            }
            if ([itemStr isEqualToString:LanguageToolMatch(@"消息免打扰")]) {
                _btnAction.selected = model.msgNoPromt;
            }
        }else if (cellType == ChatSingleSetCellTypeText) {
            _lblContent.hidden = NO;
        }
    }
}


+ (CGFloat)defaultCellHeight {
    return DWScale(54);
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
