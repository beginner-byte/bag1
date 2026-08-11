//
//  NoaChatSetGroupCommonCell.m
//  NoaKit
//
//  Created by Candy on 2026/11/5.
//

#import "NoaChatSetGroupCommonCell.h"
#import "UIView+Addition.h"

@interface NoaChatSetGroupCommonCell ()
@property (nonatomic, strong) NSArray *titleArr;
@property (nonatomic, strong) LingIMGroup *model;
@end

@implementation NoaChatSetGroupCommonCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = UIColor.clearColor;
        self.backgroundColor = UIColor.clearColor;
        [self setupUI];
        _titleArr = @[LanguageToolMatch(@"查看聊天记录"),
                      LanguageToolMatch(@"消息置顶"),
                      LanguageToolMatch(@"消息免打扰"),
                      LanguageToolMatch(@"我的群昵称")];
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
    
    _ivArrow = [[UIImageView alloc] initWithImage:ImgNamed(@"c_arrow_right_gray")];
    [_viewBg addSubview:_ivArrow];
    [_ivArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_viewBg);
        make.trailing.equalTo(_viewBg).offset(-DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(8), DWScale(16)));
    }];
    
    _lblContent = [UILabel new];
    _lblContent.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    _lblContent.font = FONTR(14);
    _lblContent.preferredMaxLayoutWidth = DWScale(100);
    _lblContent.textAlignment = NSTextAlignmentRight;
    [_viewBg addSubview:_lblContent];
    [_lblContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_viewBg);
        make.trailing.equalTo(_ivArrow.mas_leading).offset(-DWScale(5));
        make.size.mas_equalTo(CGSizeMake(DWScale(150), DWScale(16)));
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
    [_btnCenter setTitle:LanguageToolMatch(@"退出群聊") forState:UIControlStateNormal];
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
    
}
#pragma mark - 交互事件
- (void)cellTouchAction {
    if ([self.baseDelegate respondsToSelector:@selector(cellClickAction:)]) {
        [self.baseDelegate cellClickAction:self.baseCellIndexPath];
    }
}

#pragma mark - 界面赋值更新
- (void)cellConfigWithTitle:(NSString *)cellTitle model:(LingIMGroup *)model {
    if (![NSString isNil:cellTitle]) {
        _model = model;
        _lblTitle.hidden = YES;
        _lblContent.hidden = YES;
        _ivArrow.hidden = YES;
        _btnAction.hidden = YES;
        _btnCenter.hidden = YES;
        _viewLine.hidden = YES;
        if ([cellTitle isEqualToString:LanguageToolMatch(@"群机器人")]) {
            //群机器人
            _lblTitle.hidden = NO;
            _lblTitle.text = LanguageToolMatch(@"群机器人");
            _viewBg.layer.cornerRadius = 0;
            _viewBg.layer.masksToBounds = YES;
            _viewLine.hidden = NO;
            _lblContent.hidden = NO;
            _lblContent.text = [NSString stringWithFormat:@"%ld个", model.robotCount];
            _ivArrow.hidden = NO;
            [_viewBg round:DWScale(12) RectCorners:UIRectCornerAllCorners];
            _viewLine.hidden = YES;
        } else if ([cellTitle isEqualToString:LanguageToolMatch(@"群管理")]) {
           //群管理
           _viewBg.layer.cornerRadius = DWScale(12);
           _viewBg.layer.masksToBounds = YES;
           _lblTitle.hidden = NO;
           _lblTitle.text = LanguageToolMatch(@"群管理");
           _ivArrow.hidden = NO;
       } else if ([cellTitle isEqualToString:LanguageToolMatch(@"查看聊天记录")]) {
           //搜索聊天记录
           _lblTitle.hidden = NO;
           _lblTitle.text = LanguageToolMatch(@"查看聊天记录");
           _viewBg.layer.cornerRadius = 0;
           _viewBg.layer.masksToBounds = YES;
           _viewLine.hidden = NO;
           _ivArrow.hidden = NO;
           [_viewBg round:DWScale(12) RectCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
       } else if ([cellTitle isEqualToString:LanguageToolMatch(@"消息置顶")]) {
           //消息置顶
           _lblTitle.hidden = NO;
           _lblTitle.text = LanguageToolMatch(@"消息置顶");
           _viewBg.layer.cornerRadius = 0;
           _viewBg.layer.masksToBounds = YES;
           _viewLine.hidden = NO;
           _btnAction.hidden = NO;
           _btnAction.selected = model.msgTop;
           [_viewBg round:0 RectCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight];
       } else if ([cellTitle isEqualToString:LanguageToolMatch(@"消息免打扰")]) {
           //消息免打扰
           _lblTitle.hidden = NO;
           _lblTitle.text = LanguageToolMatch(@"消息免打扰");
           _viewBg.layer.cornerRadius = 0;
           _viewBg.layer.masksToBounds = YES;
           _viewLine.hidden = NO;
           _btnAction.hidden = NO;
           _btnAction.selected = model.msgNoPromt;
           [_viewBg round:0 RectCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight];
       } else if ([cellTitle isEqualToString:LanguageToolMatch(@"我的群昵称")]) {
           //我的群昵称
           _lblTitle.hidden = NO;
           _lblTitle.text = LanguageToolMatch(@"我的群昵称");
           _viewBg.layer.cornerRadius = 0;
           _viewBg.layer.masksToBounds = YES;
           _viewLine.hidden = NO;
           _lblContent.hidden = NO;
           _lblContent.text = model.nicknameInGroup;
           _ivArrow.hidden = NO;
           [_viewBg round:DWScale(12) RectCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight];
           _viewLine.hidden = YES;
       } else if ([cellTitle isEqualToString:LanguageToolMatch(@"清空聊天记录")]) {
           //清空聊天记录
           _lblTitle.hidden = NO;
           _lblTitle.text = LanguageToolMatch(@"清空聊天记录");
           _viewBg.layer.cornerRadius = DWScale(12);
           _viewBg.layer.masksToBounds = YES;
       } else if ([cellTitle isEqualToString:LanguageToolMatch(@"投诉与支持")]) {
           //投诉
           _viewBg.layer.cornerRadius = DWScale(12);
           _viewBg.layer.masksToBounds = YES;
           _lblTitle.hidden = NO;
           _lblTitle.text = LanguageToolMatch(@"投诉与支持");
           _ivArrow.hidden = NO;
       } else if ([cellTitle isEqualToString:LanguageToolMatch(@"退出群聊")]) {
           //退出群聊
           _btnCenter.hidden = NO;
           _viewBg.layer.cornerRadius = DWScale(12);
           _viewBg.layer.masksToBounds = YES;
       } else {
           return;
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
