//
//  NoaTrustedDeviceCell.m
//  CandyTalk
//
//  Created by Codex on 2026/8/9.
//

#import "NoaTrustedDeviceCell.h"
#import "NoaTrustedDeviceModel.h"

@interface NoaTrustedDeviceCell ()

/// 卡片背景容器。
@property (nonatomic, strong) UIView *cardView;
/// 设备平台标签。
@property (nonatomic, strong) UILabel *typeLabel;
/// 当前设备状态标签。
@property (nonatomic, strong) UILabel *currentLabel;
/// 最近 IP 标签。
@property (nonatomic, strong) UILabel *lastIpLabel;
/// 上次 IP 标签。
@property (nonatomic, strong) UILabel *previousIpLabel;
/// 最近活跃时间标签。
@property (nonatomic, strong) UILabel *lastSeenLabel;
/// 异常状态标签。
@property (nonatomic, strong) UILabel *anomalyLabel;
/// 非当前设备显示的剔除操作按钮。
@property (nonatomic, strong) UIButton *revokeButton;
/// 剔除按钮与异常标签之间的动态间距约束。
@property (nonatomic, strong) MASConstraint *revokeButtonTopConstraint;
/// 剔除按钮的动态高度约束。
@property (nonatomic, strong) MASConstraint *revokeButtonHeightConstraint;

@end

@implementation NoaTrustedDeviceCell

/// 初始化单元格并创建信任设备卡片视图。
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.clearColor;
        self.contentView.backgroundColor = UIColor.clearColor;
        [self setupUI];
    }
    return self;
}

/// 创建卡片内部标签并设置约束。
- (void)setupUI {
    self.cardView = [[UIView alloc] init];
    self.cardView.tkThemebackgroundColors = @[COLORWHITE, COLOR_F5F6F9_DARK];
    [self.cardView rounded:DWScale(12)];
    [self.contentView addSubview:self.cardView];

    self.typeLabel = [self labelWithFont:FONTM(17) colors:@[COLOR_11, COLOR_11_DARK]];
    self.currentLabel = [self labelWithFont:FONTR(12) colors:@[COLOR_5966F2, COLOR_5966F2_DARK]];
    self.lastIpLabel = [self labelWithFont:FONTR(14) colors:@[COLOR_66, COLOR_66_DARK]];
    self.previousIpLabel = [self labelWithFont:FONTR(14) colors:@[COLOR_66, COLOR_66_DARK]];
    self.lastSeenLabel = [self labelWithFont:FONTR(14) colors:@[COLOR_66, COLOR_66_DARK]];
    self.anomalyLabel = [self labelWithFont:FONTR(13) colors:@[COLOR_FF504E, COLOR_FF504E]];
    self.revokeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.revokeButton setTitle:LanguageToolMatch(@"剔除设备") forState:UIControlStateNormal];
    [self.revokeButton setTkThemeTitleColor:@[COLORWHITE, COLORWHITE_DARK] forState:UIControlStateNormal];
    self.revokeButton.titleLabel.font = FONTM(15);
    self.revokeButton.tkThemebackgroundColors = @[COLOR_FF504E, COLOR_FF504E];
    [self.revokeButton rounded:DWScale(8)];
    [self.revokeButton addTarget:self action:@selector(revokeButtonClick) forControlEvents:UIControlEventTouchUpInside];

    NSArray<UILabel *> *labels = @[self.typeLabel, self.currentLabel, self.lastIpLabel, self.previousIpLabel, self.lastSeenLabel, self.anomalyLabel];
    for (UILabel *label in labels) {
        [self.cardView addSubview:label];
    }
    [self.cardView addSubview:self.revokeButton];

    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(DWScale(8));
        make.leading.equalTo(self.contentView).offset(DWScale(16));
        make.trailing.equalTo(self.contentView).offset(-DWScale(16));
        make.bottom.equalTo(self.contentView).offset(-DWScale(8));
    }];
    [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.equalTo(self.cardView).offset(DWScale(16));
        make.trailing.lessThanOrEqualTo(self.currentLabel.mas_leading).offset(-DWScale(8));
        make.height.mas_equalTo(DWScale(24));
    }];
    [self.currentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.typeLabel);
        make.trailing.equalTo(self.cardView).offset(-DWScale(16));
    }];
    [self.lastIpLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.typeLabel.mas_bottom).offset(DWScale(12));
        make.leading.equalTo(self.cardView).offset(DWScale(16));
        make.trailing.equalTo(self.cardView).offset(-DWScale(16));
        make.height.mas_equalTo(DWScale(20));
    }];
    [self.previousIpLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lastIpLabel.mas_bottom).offset(DWScale(6));
        make.leading.trailing.equalTo(self.lastIpLabel);
        make.height.mas_equalTo(DWScale(20));
    }];
    [self.lastSeenLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.previousIpLabel.mas_bottom).offset(DWScale(6));
        make.leading.trailing.equalTo(self.lastIpLabel);
        make.height.mas_equalTo(DWScale(20));
    }];
    [self.anomalyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lastSeenLabel.mas_bottom).offset(DWScale(6));
        make.leading.trailing.equalTo(self.lastIpLabel);
        make.height.mas_equalTo(DWScale(18));
    }];
    [self.revokeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        self.revokeButtonTopConstraint = make.top.equalTo(self.anomalyLabel.mas_bottom).offset(0);
        make.leading.trailing.equalTo(self.lastIpLabel);
        self.revokeButtonHeightConstraint = make.height.mas_equalTo(0);
        make.bottom.equalTo(self.cardView).offset(-DWScale(14));
    }];
}

/// 创建使用项目主题色的文本标签。
/// @param font 标签字体
/// @param colors 明暗主题文字颜色数组
/// @return 已配置字体与主题色的标签
- (UILabel *)labelWithFont:(UIFont *)font colors:(NSArray *)colors {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.tkThemetextColors = colors;
    return label;
}

/// 根据接口模型刷新设备卡片内容；缺失字段统一展示为“--”。
- (void)setDeviceModel:(NoaTrustedDeviceModel *)deviceModel {
    _deviceModel = deviceModel;
    NSString *deviceType = deviceModel.deviceType.length > 0 ? deviceModel.deviceType.uppercaseString : @"--";
    NSString *lastIp = deviceModel.lastIp.length > 0 ? deviceModel.lastIp : @"--";
    NSString *previousIp = deviceModel.previousIp.length > 0 ? deviceModel.previousIp : @"--";
    NSString *lastSeenAt = deviceModel.lastSeenAt.length > 0 ? deviceModel.lastSeenAt : @"--";

    self.typeLabel.text = deviceType;
    self.currentLabel.text = deviceModel.isCurrent ? LanguageToolMatch(@"当前设备") : @"";
    self.lastIpLabel.text = [NSString stringWithFormat:@"%@：%@", LanguageToolMatch(@"最近 IP"), lastIp];
    self.previousIpLabel.text = [NSString stringWithFormat:@"%@：%@", LanguageToolMatch(@"上次 IP"), previousIp];
    self.lastSeenLabel.text = [NSString stringWithFormat:@"%@：%@", LanguageToolMatch(@"最近活跃"), lastSeenAt];
    self.anomalyLabel.text = deviceModel.anomalyFlag ? [NSString stringWithFormat:LanguageToolMatch(@"IP 异常变更 %ld 次"), (long)deviceModel.anomalyCount] : @"";
    self.revokeButton.hidden = deviceModel.isCurrent;
    [self.revokeButtonTopConstraint setOffset:deviceModel.isCurrent ? 0 : DWScale(12)];
    [self.revokeButtonHeightConstraint setOffset:deviceModel.isCurrent ? 0 : DWScale(40)];
}

/// 将非当前设备的剔除操作回传给列表控制器。
- (void)revokeButtonClick {
    if (self.deviceModel == nil || self.deviceModel.isCurrent) {
        return;
    }
    if (self.revokeDeviceBlock) {
        self.revokeDeviceBlock(self.deviceModel);
    }
}

@end
