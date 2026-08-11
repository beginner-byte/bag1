//
//  NoaHistoryChoiceUserCell.m
//  NoaKit
//
//  Created by Candy on 2024/8/12.
//

#import "NoaHistoryChoiceUserCell.h"


@interface NoaHistoryChoiceUserCell ()

@property (nonatomic, strong) UIImageView *ivSelect;//选中
@property (nonatomic, strong) UIImageView *ivHeader;//头像
@property (nonatomic, strong) UILabel *lblName;//昵称、备注

@property (nonatomic, strong) NoaBaseUserModel *baseUserModel;

@end

@implementation NoaHistoryChoiceUserCell

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
    _ivSelect = [[UIImageView alloc] initWithImage:ImgNamed(@"c_select_no")];
    [self.contentView addSubview:_ivSelect];
    [_ivSelect mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(18), DWScale(18)));
    }];
    
    _ivHeader = [[UIImageView alloc] initWithImage:DefaultAvatar];
    [_ivHeader rounded:DWScale(22)];
    [self.contentView addSubview:_ivHeader];
    [_ivHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(_ivSelect.mas_trailing).offset(DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(44), DWScale(44)));
    }];
    
    _lblName = [UILabel new];
    _lblName.text = @"";
    _lblName.font = FONTR(16);
    _lblName.numberOfLines = 1;
    _lblName.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [self.contentView addSubview:_lblName];
    [_lblName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(_ivHeader.mas_trailing).offset(DWScale(10));
        make.trailing.equalTo(self.contentView).offset(-DWScale(16));
    }];
}

+ (CGFloat)defaultCellHeight {
    return DWScale(56);
}

#pragma mark - 数据赋值
- (void)cellConfigBaseUserWith:(NoaBaseUserModel *)model search:(NSString *)searchStr {
    if (model) {
        _baseUserModel = model;
                
        [_ivHeader sd_setImageWithURL:[model.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
        
        __block NSMutableAttributedString *attStrName = [[NSMutableAttributedString alloc] initWithString:![NSString isNil:model.name] ? model.name : @""];
        attStrName.yy_font = FONTR(16);
        self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
            switch (themeIndex) {
                case 1:
                {
                    //暗黑
                    attStrName.yy_color = COLOR_11_DARK;
                }
                    break;
                    
                default:
                {
                    //浅色
                    attStrName.yy_color = COLOR_11;
                }
                    break;
            }
        };
        if (![NSString isNil:searchStr]) {
            NSRange rangeName = [model.name rangeOfString:searchStr options:NSCaseInsensitiveSearch];//不区分大小写
            [attStrName yy_setFont:FONTR(16) range:rangeName];
            [attStrName yy_setColor:COLOR_5966F2 range:rangeName];
        }
        _lblName.attributedText = attStrName;
    }
}

- (void)setSelectedUser:(BOOL)selectedUser {
    _selectedUser = selectedUser;
    if (self.baseUserModel.isExistGroup) {
        _ivSelect.image = ImgNamed(@"c_select_unknow");
    } else {
        if (selectedUser) {
            _ivSelect.image = ImgNamed(@"c_select_yes");
        }else {
            _ivSelect.image = ImgNamed(@"c_select_no");
        }
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
