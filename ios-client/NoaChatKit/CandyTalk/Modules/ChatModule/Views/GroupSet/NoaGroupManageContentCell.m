//
//  NoaGroupManageContentCell.m
//  NoaKit
//
//  Created by Candy on 2023/4/25.
//

#import "NoaGroupManageContentCell.h"

@implementation NoaGroupManageContentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

#pragma mark - 界面布局
- (void)setupUI {
    self.contentView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    
    _viewContent = [[UIButton alloc] init];
    _viewContent.frame = CGRectMake(DWScale(16), 0, DScreenWidth - DWScale(32), DWScale(75));
    _viewContent.tkThemebackgroundColors =  @[COLORWHITE, COLOR_F5F6F9_DARK];
    [_viewContent setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE]] forState:UIControlStateSelected];
    [_viewContent setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE]] forState:UIControlStateHighlighted];
    [_viewContent addTarget:self action:@selector(cellTouchAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_viewContent];
    
    
    _lblTitle = [UILabel new];
    _lblTitle.font = FONTR(16);
    _lblTitle.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [_viewContent addSubview:_lblTitle];
    [_lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewContent).offset(DWScale(16));
        make.leading.equalTo(_viewContent).offset(DWScale(16));
        make.height.mas_equalTo(DWScale(22));
    }];
    
    _btnSwitch = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnSwitch.userInteractionEnabled = NO;
    [_btnSwitch setImage:ImgNamed(@"c_switch_off") forState:UIControlStateNormal];
    [_btnSwitch setImage:ImgNamed(@"c_switch_on") forState:UIControlStateSelected];
    [_viewContent addSubview:_btnSwitch];
    [_btnSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_lblTitle);
        make.trailing.equalTo(_viewContent).offset(-DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(44), DWScale(44)));
    }];
    
    _lblContent = [UILabel new];
    _lblContent.numberOfLines = 2;
    _lblContent.preferredMaxLayoutWidth = DWScale(200);
    _lblContent.font = FONTR(12);
    _lblContent.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    [_viewContent addSubview:_lblContent];
    [_lblContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_lblTitle);
        make.top.equalTo(_lblTitle.mas_bottom).offset(DWScale(4));
        make.trailing.equalTo(_btnSwitch.mas_leading).offset(-DWScale(5));
        //make.width.mas_equalTo(DWScale(200));
    }];
    
    _viewLine = [UIView new];
    _viewLine.tkThemebackgroundColors = @[COLOR_EEEEEE, [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1]];
    [_viewContent addSubview:_viewLine];
    [_viewLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewContent).offset(DWScale(16));
        make.trailing.equalTo(_viewContent).offset(-DWScale(16));
        make.bottom.equalTo(_viewContent);
        make.height.mas_equalTo(1);
    }];
    
}
- (void)updateCellUIWith:(NSInteger)currentRow totalRow:(NSInteger)totalRow {
    
    if (currentRow == 0) {
        _lblTitle.text = LanguageToolMatch(@"群私密");
        _lblContent.text = LanguageToolMatch(@"禁止成员查看其他成员资料");
        _viewContent.height = DWScale(80);
    }else if (currentRow == 1) {
        _lblTitle.text = LanguageToolMatch(@"邀请确认");
        _lblContent.text = LanguageToolMatch(@"邀请成员入群需管理员或群主确认");
        _viewContent.height = DWScale(80);
    }
    
    if (totalRow > 1) {
        //多个cell
        if (currentRow == 0) {
            //顶部切圆角
            [_viewContent round:DWScale(12) RectCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
        }else if (currentRow + 1 == totalRow) {
            //底部切圆角
            [_viewContent round:DWScale(12) RectCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight];
        }else {
            //中间不切圆角
            [_viewContent round:0 RectCorners:UIRectCornerAllCorners];
        }
    }else {
        //单个cell
        [_viewContent round:DWScale(12) RectCorners:UIRectCornerAllCorners];
    }
    
    
}

#pragma mark - 交互事件
- (void)cellTouchAction {
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
