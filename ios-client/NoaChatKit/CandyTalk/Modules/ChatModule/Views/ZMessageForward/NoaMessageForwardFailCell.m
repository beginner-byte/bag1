//
//  NoaMessageForwardFailCell.m
//  NoaKit
//
//  Created by Candy on 2024/3/18.
//

#import "NoaMessageForwardFailCell.h"
#import "NoaBaseImageView.h"

@interface NoaMessageForwardFailCell()

@property (nonatomic, strong)NoaBaseImageView *ivGroupHeader;//群头像
@property (nonatomic, strong)UILabel *ivGroupNameLbl;//群名称
@property (nonatomic, strong)UILabel *ivReasonLbl;//转发失败原因

@end

@implementation NoaMessageForwardFailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        self.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    _ivGroupHeader = [NoaBaseImageView new];
    [_ivGroupHeader rounded:DWScale(22)];
    [self.contentView addSubview:_ivGroupHeader];
    [_ivGroupHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(44), DWScale(44)));
    }];
    
    _ivGroupNameLbl = [UILabel new];
    _ivGroupNameLbl.text = @"";
    _ivGroupNameLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _ivGroupNameLbl.font = FONTN(16);
    [self.contentView addSubview:_ivGroupNameLbl];
    [_ivGroupNameLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_ivGroupHeader.mas_trailing).offset(DWScale(10));
        make.centerY.equalTo(_ivGroupHeader);
        make.width.mas_equalTo(DWScale(160));
        make.height.mas_equalTo(DWScale(24));
    }];
    
    _ivReasonLbl = [UILabel new];
    _ivReasonLbl.text = @"";
    _ivReasonLbl.tkThemetextColors = @[COLOR_F93A2F, COLOR_F93A2F];
    _ivReasonLbl.font = FONTN(12);
    _ivReasonLbl.textAlignment = NSTextAlignmentRight;
    _ivReasonLbl.numberOfLines = 0;
    [self.contentView addSubview:_ivReasonLbl];
    [_ivReasonLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_ivGroupNameLbl.mas_trailing).offset(DWScale(20));
        make.trailing.equalTo(self.contentView).offset(-DWScale(20));
        make.centerY.equalTo(self.contentView);
        make.height.mas_equalTo(DWScale(48));
    }];
}

#pragma mark - Data
- (void)setPreCheckFailModel:(NoaForwardMsgPrecheckModel *)preCheckFailModel {
    _preCheckFailModel = preCheckFailModel;

    [_ivGroupHeader sd_setImageWithURL:[_preCheckFailModel.dialogInfo.avatar getImageFullUrl] placeholderImage:DefaultGroup options:SDWebImageAllowInvalidSSLCertificates];
    _ivGroupNameLbl.text = _preCheckFailModel.dialogInfo.nickname;
    //原因
    switch (_preCheckFailModel.exceptionInfo.code) {
        case NetWork_Error_Friend_Delete:
            _ivReasonLbl.text = LanguageToolMatch(@"已被对方删除");
            break;
        case NetWork_Error_Friend_Blacklist:
            _ivReasonLbl.text = LanguageToolMatch(@"已将对方拉黑");
            break;
        case NetWork_Error_Friend_BeBlacklist:
            _ivReasonLbl.text = LanguageToolMatch(@"已被对方拉黑");
            break;
        case NetWork_Error_Group_Nonentity:
            _ivReasonLbl.text = LanguageToolMatch(@"群组不存在");
            break;
        case NetWork_Error_Group_Single_Silent:
            _ivReasonLbl.text = LanguageToolMatch(@"已被群组禁言");
            break;
        case NetWork_Error_Group_All_Silent:
            _ivReasonLbl.text = LanguageToolMatch(@"群组开启全员禁言");
            break;
        case NetWork_Error_Group_Single_ShutDown:
            _ivReasonLbl.text = LanguageToolMatch(@"群组已封停");
            break;
        case NetWork_Error_Group_Not_In:
            _ivReasonLbl.text = LanguageToolMatch(@"已不在群组");
            break;
        case NetWork_Error_Group_Interval:
            _ivReasonLbl.text = LanguageToolMatch(@"发送频次过快");
            break;
        case NetWork_Error_Group_Number_Limit:
            _ivReasonLbl.text = LanguageToolMatch(@"转发数量超过限制");
            break;
        default:
            _ivReasonLbl.text = LanguageToolMatch(@"未知");
            break;
    }
}

#pragma mark - Other
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
