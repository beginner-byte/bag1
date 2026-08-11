//
//  NoaNewFriendVerifyApplyInfoCell.m
//  NoaKit
//
//  Created by Candy on 2026/9/13.
//

#import "NoaNewFriendVerifyApplyInfoCell.h"

@interface NoaNewFriendVerifyApplyInfoCell ()

@end

@implementation NoaNewFriendVerifyApplyInfoCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    _lblApplyContent = [UILabel new];
    _lblApplyContent.text = LanguageToolMatch(@"申请人：");
    _lblApplyContent.numberOfLines = 0;
    _lblApplyContent.font = FONTR(16);
    _lblApplyContent.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    _lblApplyContent.preferredMaxLayoutWidth = DScreenWidth - DWScale(32);
    [self.contentView addSubview:_lblApplyContent];
    [_lblApplyContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(DWScale(16));
        make.trailing.equalTo(self.contentView).offset(-DWScale(16));
        make.top.equalTo(self.contentView).offset(DWScale(16));
        make.bottom.equalTo(self.contentView).offset(-DWScale(16));
    }];
    
    WeakSelf
    [_lblApplyContent setTkThemeChangeBlock:^(id  _Nullable itself, NSUInteger themeIndex) {
        switch (themeIndex) {
            case 1:
            {
                //1暗黑模式
                [weakSelf.lblApplyContent changeTextRange:[weakSelf.lblApplyContent.text rangeOfString:LanguageToolMatch(@"申请人：")] font:nil color:COLOR_66_DARK];
            }
                break;
                
            default:
            {
                //0浅色模式
                [weakSelf.lblApplyContent changeTextRange:[weakSelf.lblApplyContent.text rangeOfString:LanguageToolMatch(@"申请人：")] font:nil color:COLOR_66];
            }
                break;
        }
    }];
    
    UIView *viewLineTop = [[UIView alloc] initWithFrame:CGRectMake(DWScale(16), 0, DScreenWidth - DWScale(16), 0.5)];
    viewLineTop.tkThemebackgroundColors = @[COLOR_E6E6E6, COLOR_E6E6E6_DARK];
    [self.contentView addSubview:viewLineTop];
    
    UIView *viewLineBottom = [UIView new];
    viewLineBottom.tkThemebackgroundColors = @[COLOR_E6E6E6, COLOR_E6E6E6_DARK];
    [self.contentView addSubview:viewLineBottom];
    [viewLineBottom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(viewLineTop);
        make.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(0.5);
    }];
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
