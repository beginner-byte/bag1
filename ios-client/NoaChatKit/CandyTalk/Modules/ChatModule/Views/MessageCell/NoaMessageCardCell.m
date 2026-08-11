//
//  NoaMessageCardCell.m
//  NoaKit
//
//  Created by Candy on 2023/4/12.
//

#import "NoaMessageCardCell.h"

@implementation NoaMessageCardCell
{
    UIImageView *_cardHeadImgView;
    UILabel *_cardNickName;
    UIView *_lineView;
    UILabel *_cardTipsLbl;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupCardUI];
    }
    return self;
}

#pragma mark - UI布局
- (void)setupCardUI {
    _cardHeadImgView = [[UIImageView alloc] init];
    _cardHeadImgView.image = DefaultAvatar;
    [_cardHeadImgView rounded:DWScale(20)];
    [self.contentView addSubview:_cardHeadImgView];
    
    _cardNickName = [[UILabel alloc] init];
    _cardNickName.text = @"";
    _cardNickName.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _cardNickName.font = FONTN(16);
    _cardNickName.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_cardNickName];
    [_cardNickName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_cardHeadImgView.mas_trailing).offset(DWScale(10));
        make.trailing.equalTo(self.viewSendBubble.mas_trailing).offset(-DWScale(10));
        make.centerY.equalTo(_cardHeadImgView);
        make.height.mas_equalTo(DWScale(22));
    }];
    
    _lineView = [[UIView alloc] init];
    _lineView.tkThemebackgroundColors = @[[COLOR_0041A2 colorWithAlphaComponent:0.3], [COLOR_0041A2 colorWithAlphaComponent:0.3]];
    [self.contentView addSubview:_lineView];
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.viewSendBubble).offset(DWScale(10));
        make.trailing.equalTo(self.viewSendBubble).offset(-DWScale(10));
        make.top.equalTo(_cardHeadImgView.mas_bottom).offset(DWScale(6));
        make.height.mas_equalTo(0.8);
    }];
    
    _cardTipsLbl = [[UILabel alloc] init];
    _cardTipsLbl.text = LanguageToolMatch(@"个人名片");
    _cardTipsLbl.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    _cardTipsLbl.font = FONTN(12);
    _cardTipsLbl.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_cardTipsLbl];
    [_cardTipsLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_cardHeadImgView);
        make.top.equalTo(_lineView.mas_bottom).offset(DWScale(4));
        make.width.mas_equalTo(DWScale(120));
        make.height.mas_equalTo(DWScale(17));
    }];
}

- (void)setConfigMessage:(NoaMessageModel *)model {
    [super setConfigMessage:model];
    //头像位置
    _cardHeadImgView.frame = _contentRect;
    //头像图片
    [_cardHeadImgView sd_setImageWithURL:[model.message.cardHeadPicUrl getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
    //昵称
    _cardNickName.text = model.message.cardNickName;
    //UI
    if (model.isSelf) {
        [_cardNickName mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_cardHeadImgView.mas_trailing).offset(DWScale(10));
            make.trailing.equalTo(self.viewSendBubble.mas_trailing).offset(-DWScale(10));
            make.centerY.equalTo(_cardHeadImgView);
            make.height.mas_equalTo(DWScale(22));
        }];
        
        [_lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.viewSendBubble).offset(DWScale(10));
            make.trailing.equalTo(self.viewSendBubble).offset(-DWScale(10));
            make.top.equalTo(_cardHeadImgView.mas_bottom).offset(DWScale(4));
            make.height.mas_equalTo(1);
        }];
    } else {
        [_cardNickName mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_cardHeadImgView.mas_trailing).offset(DWScale(10));
            make.trailing.equalTo(self.viewReceiveBubble.mas_trailing).offset(-DWScale(10));
            make.centerY.equalTo(_cardHeadImgView);
            make.height.mas_equalTo(DWScale(22));
        }];
        
        [_lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.viewReceiveBubble).offset(DWScale(10));
            make.trailing.equalTo(self.viewReceiveBubble).offset(-DWScale(10));
            make.top.equalTo(_cardHeadImgView.mas_bottom).offset(DWScale(4));
            make.height.mas_equalTo(1);
        }];
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
