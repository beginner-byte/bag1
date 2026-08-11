//
//  NoaMessageSystemCell.m
//  NoaKit
//
//  Created by Candy on 2026/10/27.
//

#import "NoaMessageSystemCell.h"

@interface NoaMessageSystemCell ()

@property (nonatomic, strong) UILabel *msgDateLbl;//日期时间
@property (nonatomic, strong) UILabel *lblTip;

@end


@implementation NoaMessageSystemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    //日期时间
    _msgDateLbl = [UILabel new];
    _msgDateLbl.text = @"";
    _msgDateLbl.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    _msgDateLbl.font = FONTN(12);
    _msgDateLbl.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_msgDateLbl];
    [_msgDateLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(DWScale(20));
        make.trailing.equalTo(self.contentView).offset(DWScale(-20));
        make.top.equalTo(self.contentView).offset(5);
        make.height.mas_equalTo(12);
    }];
    
    _lblTip = [UILabel new];
    _lblTip.textAlignment = NSTextAlignmentCenter;
    _lblTip.font = FONTN(13);
    _lblTip.numberOfLines = 0;
    [self.contentView addSubview:_lblTip];
    [_lblTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_msgDateLbl.mas_bottom).offset(19);
        make.leading.equalTo(self.contentView).offset(10);
        make.bottom.equalTo(self.contentView).offset(-5);
        make.trailing.equalTo(self.contentView).offset(-10);
    }];
    
    UITapGestureRecognizer *sysMsgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sysMessageTapAction)];
    [_lblTip addGestureRecognizer:sysMsgTap];
}

- (void)setConfigMessage:(NoaMessageModel *)model {
    [super setConfigMessage:model];

    _lblTip.attributedText = model.attStr;
    _lblTip.textAlignment = NSTextAlignmentCenter;
    
    if (![NSString isNil:model.dataTime]) {
        _msgDateLbl.hidden = NO;
        _msgDateLbl.text = model.dataTime;
        [_msgDateLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView).offset(DWScale(20));
            make.trailing.equalTo(self.contentView).offset(DWScale(-20));
            make.top.equalTo(self.contentView).offset(5);
            make.height.mas_equalTo(12);
        }];
        
        [_lblTip mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_msgDateLbl.mas_bottom).offset(19);
            make.leading.equalTo(self.contentView).offset(10);
            make.bottom.equalTo(self.contentView).offset(-5);
            make.trailing.equalTo(self.contentView).offset(-10);
        }];
    } else {
        _msgDateLbl.hidden = YES;
        [_msgDateLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView).offset(DWScale(20));
            make.trailing.equalTo(self.contentView).offset(DWScale(-20));
            make.top.equalTo(self.contentView).offset(0);
            make.height.mas_equalTo(0);
        }];
        
        [_lblTip mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_msgDateLbl.mas_bottom).offset(5);
            make.leading.equalTo(self.contentView).offset(10);
            make.bottom.equalTo(self.contentView).offset(-5);
            make.trailing.equalTo(self.contentView).offset(-10);
        }];
    }

    if (model.message.messageType == CIMChatMessageType_ServerMessage) {
        if (model.message.serverMessage.sMsgType == IMServerMessage_ServerMsgType_NullFriendMessage) {
            _lblTip.userInteractionEnabled = YES;
        } else {
            _lblTip.userInteractionEnabled = NO;
        }
    }
}

//添加好友弹窗
- (void)sysMessageTapAction {
    if ([self.delegate respondsToSelector:@selector(systemMessageNotFriendAlert:)]) {
        [self.delegate systemMessageNotFriendAlert:self.cellIndex];
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
