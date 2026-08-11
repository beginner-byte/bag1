//
//  NoaGroupManageManagerCell.m
//  NoaKit
//
//  Created by Candy on 2026/11/15.
//

#import "NoaGroupManageManagerCell.h"
@interface NoaGroupManageManagerCell ()
//@property (nonatomic, strong) NSArray *titleArr;
@property (nonatomic, strong) LingIMGroupMemberModel *model;
@end
@implementation NoaGroupManageManagerCell

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
    
    _viewBg = [[UIView alloc] initWithFrame:CGRectMake(DWScale(16), 0, DScreenWidth - DWScale(32), [NoaGroupManageManagerCell defaultCellHeight])];
    _viewBg.tkThemebackgroundColors = @[COLORWHITE, COLOR_EEEEEE_DARK];
    [self.contentView addSubview:_viewBg];
    
    _ivHeader = [[NoaBaseImageView alloc] initWithImage:DefaultAvatar];
    _ivHeader.layer.cornerRadius = DWScale(22);
    _ivHeader.layer.masksToBounds = YES;
    [_viewBg addSubview:_ivHeader];
    [_ivHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_viewBg);
        make.leading.equalTo(_viewBg.mas_leading).offset(DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(44), DWScale(44)));
    }];
    

    _lblUserName = [UILabel new];
    _lblUserName.font = FONTR(16);
    _lblUserName.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [_viewBg addSubview:_lblUserName];
    [_lblUserName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(_ivHeader.mas_trailing).offset(DWScale(10));
        make.centerY.equalTo(_viewBg);
        make.height.mas_equalTo(DWScale(22));
    }];
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelBtn setTitle:LanguageToolMatch(@"取消管理") forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(cancelManage) forControlEvents:UIControlEventTouchUpInside];
    [_cancelBtn setTitleColor:HEXCOLOR(@"4791FF") forState:UIControlStateNormal];
    _cancelBtn.titleLabel.font = FONTR(16);
    [_viewBg addSubview:_cancelBtn];
    [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_viewBg);
        make.trailing.mas_equalTo(_viewBg.mas_trailing).offset(DWScale(-16));
        make.height.mas_equalTo(DWScale(20));
    }];
    
    _lblUserName = [UILabel new];
    _lblUserName.font = FONTR(16);
    _lblUserName.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [_viewBg addSubview:_lblUserName];
    [_lblUserName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(_ivHeader.mas_trailing).offset(DWScale(10));
        make.trailing.mas_equalTo(_cancelBtn.mas_leading).offset(-DWScale(10));
        make.centerY.equalTo(_viewBg);
        make.height.mas_equalTo(DWScale(22));
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
- (void)cancelManage{
    if (self.tapCancelManagerBlock) {
        self.tapCancelManagerBlock(self.model);
    }
}
+ (CGFloat)defaultCellHeight {
    return DWScale(68);
}

- (void)cellConfigWithmodel:(LingIMGroupMemberModel *)model{
    self.model = model;
    
    [_ivHeader sd_setImageWithURL:[model.userAvatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
    _lblUserName.text = model.userNickname;
}

@end
