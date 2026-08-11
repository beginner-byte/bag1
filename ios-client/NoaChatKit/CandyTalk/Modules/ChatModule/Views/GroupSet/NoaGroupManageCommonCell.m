//
//  NoaGroupManageCommonCell.m
//  NoaKit
//
//  Created by Candy on 2026/11/14.
//

#import "NoaGroupManageCommonCell.h"
@interface NoaGroupManageCommonCell ()
//@property (nonatomic, strong) NSArray *titleArr;
@property (nonatomic, strong) LingIMGroup *model;
@end

@implementation NoaGroupManageCommonCell

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
//    _viewBg = [[UIView alloc] initWithFrame:CGRectMake(DWScale(16), 0, DScreenWidth - DWScale(32), DWScale(54))];
//    _viewBg.tkThemebackgroundColors = @[COLORWHITE, COLOR_EEEEEE_DARK];
//    [self.contentView addSubview:_viewBg];
    
    _viewBg = [[UIButton alloc] init];
    _viewBg.frame = CGRectMake(DWScale(16), 0, DScreenWidth - DWScale(32), DWScale(54));
    _viewBg.tkThemebackgroundColors =  @[COLORWHITE, COLOR_F5F6F9_DARK];
    [_viewBg setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE]] forState:UIControlStateSelected];
    [_viewBg setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE]] forState:UIControlStateHighlighted];
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
    _lblTitle.numberOfLines = 2;
    
    _ivArrow = [[UIImageView alloc] initWithImage:ImgNamed(@"c_arrow_right_gray")];
    [_viewBg addSubview:_ivArrow];
    [_ivArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_viewBg);
        make.trailing.equalTo(_viewBg).offset(-DWScale(16));
        make.leading.equalTo(_lblTitle.mas_trailing).offset(DWScale(8));
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
    
    _viewLineCenter = [UIView new];
    _viewLineCenter.hidden = YES;
    _viewLineCenter.tkThemebackgroundColors = @[HEXCOLOR(@"C5C5C5"), HEXCOLOR(@"C5C5C5")];
    [_viewBg addSubview:_viewLineCenter];
    [_viewLineCenter mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_viewBg);
        make.leading.equalTo(_viewBg).offset(DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(12), DWScale(1)));
    }];
}

- (void)setCornerRadiusWithIsShow:(BOOL)isShow location:(CornerRadiusLocationType)locationType{
    if (isShow) {
        WeakSelf;
            UIBezierPath *path;
            if (locationType == CornerRadiusLocationAll) {
                path = [UIBezierPath bezierPathWithRoundedRect:weakSelf.viewBg.bounds  byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight|UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(DWScale(12), DWScale(12))];
            }else if (locationType == CornerRadiusLocationTop){
                path = [UIBezierPath bezierPathWithRoundedRect:weakSelf.viewBg.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(DWScale(12), DWScale(12))];
            }else{
                path = [UIBezierPath bezierPathWithRoundedRect:weakSelf.viewBg.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(DWScale(12), DWScale(12))];
            }

            CAShapeLayer *layer1 = [[CAShapeLayer alloc]init];
            layer1.frame = weakSelf.viewBg.bounds;
            layer1.path = path.CGPath;
            weakSelf.viewBg.layer.mask = layer1;
    }else{
        WeakSelf;
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:weakSelf.viewBg.bounds byRoundingCorners:nil cornerRadii:CGSizeZero];;

            CAShapeLayer *layer1 = [[CAShapeLayer alloc]init];
            layer1.frame = weakSelf.viewBg.bounds;
            layer1.path = path.CGPath;
            weakSelf.viewBg.layer.mask = layer1;
    }
}
#pragma mark - 交互事件
- (void)cellTouchAction {
    if ([self.baseDelegate respondsToSelector:@selector(cellClickAction:)]) {
        [self.baseDelegate cellClickAction:self.baseCellIndexPath];
    }
}

#pragma mark - 界面赋值更新
- (void)cellConfigWith:(GroupManageCellType)cellType itemStr:(NSString *)itemStr  model:(LingIMGroup *)model{
    if (cellType) {
        _model = model;
        
        _lblTitle.hidden = YES;
        _ivArrow.hidden = YES;
        _btnAction.hidden = YES;
        _btnCenter.hidden = YES;
        _viewLine.hidden = YES;
        _viewLineCenter.hidden = YES;
        
        if (cellType == GroupManageCellCommon) {
            //群管理
            _lblTitle.hidden = NO;
            _lblTitle.text = itemStr;
            _ivArrow.hidden = NO;
        }else if (cellType == GroupManageCellSelect){
            //通用功能
            _lblTitle.hidden = NO;
            _lblTitle.text = itemStr;
            _viewLine.hidden = NO;
            _btnAction.hidden = NO;
            _btnAction.selected = model.msgTop;
        }else if (cellType == GroupManageCellButton){
            //退出群聊
            _btnCenter.hidden = NO;
            [_btnCenter setTitle:itemStr forState:UIControlStateNormal];
        }
        
        //标题前的横线处理
        if ([itemStr isEqualToString:LanguageToolMatch(@"邀请进群申请")]) {
            _viewLineCenter.hidden = NO;
            [_lblTitle mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_viewBg);
                make.leading.equalTo(_viewBg).offset(DWScale(30));
            }];
        }else {
            _viewLineCenter.hidden = YES;
            [_lblTitle mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_viewBg);
                make.leading.equalTo(_viewBg).offset(DWScale(16));
            }];
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
