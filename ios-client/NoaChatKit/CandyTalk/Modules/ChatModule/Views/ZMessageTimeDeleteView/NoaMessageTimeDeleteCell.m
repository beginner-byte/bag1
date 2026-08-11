//
//  NoaMessageTimeDeleteCell.m
//  NoaKit
//
//  Created by Candy on 2023/4/18.
//

#import "NoaMessageTimeDeleteCell.h"

@implementation NoaMessageTimeDeleteCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}
+ (CGFloat)defaultCellHeight {
    return DWScale(56);
}
#pragma mark - 界面布局
- (void)setupUI {
    
    [self.contentView addSubview:self.baseContentButton];
    self.baseContentButton.frame = CGRectMake(0, 0, DScreenWidth, DWScale(56));
    
    _lblContent = [UILabel new];
    _lblContent.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_lblContent];
    [_lblContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
    }];
    
    
    _viewLine = [[UIView alloc] initWithFrame:CGRectMake(0, DWScale(56) - 1, DScreenWidth, 1)];
    _viewLine.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F6F6F6_DARK];
    [self.contentView addSubview:_viewLine];
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
