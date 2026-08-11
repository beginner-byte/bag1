//
//  NoaTitleContentButtonCell.m
//  NoaKit
//
//  Created by Candy on 2026/9/14.
//

#import "NoaTitleContentButtonCell.h"

@implementation NoaTitleContentButtonCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    _lblTitle = [UILabel new];
    //_lblTitle.text = @"标题";
    _lblTitle.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _lblTitle.font = FONTR(16);
    [self.contentView addSubview:_lblTitle];
    [_lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(DWScale(16));
        make.top.equalTo(self.contentView).offset(DWScale(16));
        make.bottom.equalTo(self.contentView).offset(-DWScale(16));
        make.width.mas_lessThanOrEqualTo(DWScale(150));
        make.height.mas_greaterThanOrEqualTo(DWScale(22));
    }];
    
    _lblContent = [UILabel new];
    //_lblContent.text = @"内容";
    _lblContent.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    _lblContent.font = FONTR(14);
    [self.contentView addSubview:_lblContent];
    
    _btnAction = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnAction addTarget:self action:@selector(btnActionClick) forControlEvents:UIControlEventTouchUpInside];
    [_btnAction setImage:ImgNamed(@"c_switch_off") forState:UIControlStateNormal];
    [_btnAction setImage:ImgNamed(@"c_switch_on") forState:UIControlStateSelected];
    [self.contentView addSubview:_btnAction];
    [_btnAction mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(44), DWScale(44)));
    }];
}

+ (CGFloat)defaultCellHeight {
    return DWScale(54);
}
#pragma mark - 数据更新
- (void)setCellData:(id)cellData {
    _cellData = cellData;
}
#pragma mark - 交互事件
- (void)btnActionClick {
    if (_delegate && [_delegate respondsToSelector:@selector(cellButtonAction:)]) {
        [_delegate cellButtonAction:_cellData];
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
