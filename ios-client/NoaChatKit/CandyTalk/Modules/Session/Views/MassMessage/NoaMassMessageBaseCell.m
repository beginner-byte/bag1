//
//  NoaMassMessageBaseCell.m
//  NoaKit
//
//  Created by Candy on 2023/4/19.
//

// 60 + 1 // 文本或附件信息(高度自适应) // 1 + 74

#import "NoaMassMessageBaseCell.h"

@implementation NoaMassMessageBaseCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setupBaseUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupBaseUI {
    self.contentView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    
    _viewContent = [UIView new];
    _viewContent.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
    _viewContent.layer.cornerRadius = DWScale(12);
    _viewContent.layer.masksToBounds = YES;
    [self.contentView addSubview:_viewContent];
    [_viewContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(DWScale(16));
        make.trailing.equalTo(self.contentView).offset(-DWScale(16));
        make.bottom.top.equalTo(self.contentView);
    }];
    
    _lblTarget = [UILabel new];
    _lblTarget.layer.cornerRadius = DWScale(4);
    _lblTarget.layer.masksToBounds = YES;
    _lblTarget.font = FONTR(12);
    [_viewContent addSubview:_lblTarget];
    [_lblTarget mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewContent).offset(DWScale(15));
        make.leading.equalTo(_viewContent).offset(DWScale(16));
        make.height.mas_equalTo(DWScale(18));
    }];
    
    _lblNumber = [UILabel new];
    _lblNumber.font = FONTR(12);
    _lblNumber.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    [_viewContent addSubview:_lblNumber];
    [_lblNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_lblTarget);
        make.leading.equalTo(_lblTarget.mas_trailing).offset(DWScale(12));
    }];
    
    _lblReceiver = [UILabel new];
    _lblReceiver.font = FONTR(12);
    _lblReceiver.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _lblReceiver.preferredMaxLayoutWidth = DScreenWidth - DWScale(128);
    [_viewContent addSubview:_lblReceiver];
    [_lblReceiver mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_lblTarget);
        make.top.equalTo(_lblTarget.mas_bottom).offset(DWScale(4));
        make.height.mas_equalTo(DWScale(18));
        make.width.mas_lessThanOrEqualTo(DScreenWidth - DWScale(128));
    }];
    
    _btnReceiver = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnReceiver setTitle:LanguageToolMatch(@"查看列表") forState:UIControlStateNormal];
    _btnReceiver.titleLabel.font = FONTR(12);
    [_btnReceiver setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateNormal];
    [_btnReceiver addTarget:self action:@selector(btnReceiverClick) forControlEvents:UIControlEventTouchUpInside];
    [_viewContent addSubview:_btnReceiver];
    [_btnReceiver mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_lblReceiver);
        make.trailing.equalTo(_viewContent).offset(-DWScale(16));
        make.width.mas_equalTo(DWScale(48));
    }];
    _btnReceiver.titleLabel.numberOfLines = 2;
    
    UIView *viewLineTop = [UIView new];
    viewLineTop.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
    [_viewContent addSubview:viewLineTop];
    [viewLineTop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_lblTarget);
        make.trailing.equalTo(_btnReceiver);
        make.top.equalTo(_viewContent).offset(DWScale(60));
        make.height.mas_equalTo(DWScale(1));
    }];
    
    UIView *viewLineBottom = [UIView new];
    viewLineBottom.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
    [_viewContent addSubview:viewLineBottom];
    [viewLineBottom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_lblTarget);
        make.trailing.equalTo(_btnReceiver);
        make.bottom.equalTo(_viewContent).offset(-DWScale(74));
        make.height.mas_equalTo(DWScale(1));
    }];
    
    _btnSendAgain = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnSendAgain setTitle:LanguageToolMatch(@"再发一条") forState:UIControlStateNormal];
    [_btnSendAgain setTkThemeTitleColor:@[COLORWHITE, COLORWHITE_DARK] forState:UIControlStateNormal];
    [_btnSendAgain setTkThemebackgroundColors:@[COLOR_5966F2, COLOR_5966F2_DARK]];
    _btnSendAgain.layer.cornerRadius = DWScale(12);
    _btnSendAgain.layer.masksToBounds = YES;
    [_btnSendAgain addTarget:self action:@selector(btnSendAgainClick) forControlEvents:UIControlEventTouchUpInside];
    [_viewContent addSubview:_btnSendAgain];
    [_btnSendAgain mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_viewContent).offset(-DWScale(16));
        make.bottom.equalTo(_viewContent).offset(-DWScale(21));
        make.size.mas_equalTo(CGSizeMake(DWScale(84), DWScale(32)));
    }];
    _btnSendAgain.titleLabel.numberOfLines = 2;
    
    if([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"简体中文"] ||
       [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"繁體中文"] ){
        _btnSendAgain.titleLabel.font = FONTR(14);
    }else{
        _btnSendAgain.titleLabel.font = FONTR(12);

    }
    _lblSending = [UILabel new];
    _lblSending.font = FONTR(12);
    _lblSending.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    _lblSending.hidden = YES;
    [_viewContent addSubview:_lblSending];
    [_lblSending mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_btnSendAgain);
        make.leading.equalTo(_viewContent).offset(DWScale(16));
        make.height.mas_equalTo(DWScale(18));
    }];
    
    _lblSendEnd = [UILabel new];
    _lblSendEnd.font = FONTR(12);
    _lblSendEnd.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    _lblSendEnd.text = LanguageToolMatch(@"发送完毕");
    _lblSendEnd.hidden = YES;
    [_viewContent addSubview:_lblSendEnd];
    [_lblSendEnd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewContent).offset(DWScale(16));
        make.bottom.equalTo(_lblSending.mas_top).offset(-DWScale(2));
        make.height.mas_equalTo(DWScale(18));
    }];
    
    _lblSendFail = [UILabel new];
    _lblSendFail.font = FONTR(12);
    _lblSendFail.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    _lblSendFail.hidden = YES;
    [_viewContent addSubview:_lblSendFail];
    [_lblSendFail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_btnSendAgain);
        make.leading.equalTo(_viewContent).offset(DWScale(16));
        make.height.mas_equalTo(DWScale(18));
    }];
    
    _btnFail = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnFail setTitle:LanguageToolMatch(@"查看列表") forState:UIControlStateNormal];
    _btnFail.titleLabel.font = FONTR(12);
    [_btnFail setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateNormal];
    [_btnFail addTarget:self action:@selector(btnFailClick) forControlEvents:UIControlEventTouchUpInside];
    [_viewContent addSubview:_btnFail];
    [_btnFail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_lblSendFail);
        make.leading.equalTo(_lblSendFail.mas_trailing).offset(DWScale(10));
        make.width.mas_equalTo(DWScale(48));
    }];
    _btnFail.titleLabel.numberOfLines = 2;
    
}
#pragma mark - 界面赋值
- (void)setMessageModel:(LIMMassMessageModel *)messageModel {
    _messageModel = messageModel;
    
    if (![NSString isNil:messageModel.label]) {
        _lblTarget.text = [NSString stringWithFormat:@" %@ ", messageModel.label];
        _lblTarget.tkThemetextColors = @[COLORWHITE, COLORWHITE_DARK];
        _lblTarget.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    }else {
        _lblTarget.text = LanguageToolMatch(@"未命名标签");
        _lblTarget.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
        _lblTarget.tkThemebackgroundColors = @[COLOR_CLEAR, COLOR_CLEAR_DARK];
    }
    _lblNumber.text = [NSString stringWithFormat:LanguageToolMatch(@"%ld位收件人"), messageModel.totalCount];
    
    __block NSMutableArray *userShowNameList = [NSMutableArray array];
    [messageModel.userUidList enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:obj];
        if (friendModel) {
            NSString *showFriendName;
            if (friendModel.showName.length > 5) {
                showFriendName = [friendModel.showName substringToIndex:5];
            } else {
                showFriendName = friendModel.showName;
            }
            [userShowNameList addObjectIfNotNil:showFriendName];
        } else {
            LingIMGroupModel *groupModel = [IMSDKManager toolCheckMyGroupWith:obj];
            if (groupModel) {
                NSString *showGroupName = @"";
                if (groupModel.groupName.length > 5) {
                    showGroupName = [groupModel.groupName substringToIndex:5];
                } else {
                    showGroupName = groupModel.groupName;
                }
                [userShowNameList addObjectIfNotNil:showGroupName];
            }
        }
    }];
    _lblReceiver.text = [userShowNameList componentsJoinedByString:@"；"];
    
    if (messageModel.status == 2) {
        //发送完成
        _lblSending.hidden = YES;
        _lblSendFail.text = [NSString stringWithFormat:LanguageToolMatch(@"%ld人发送失败"), messageModel.errorCount];
        _lblSendEnd.hidden = NO;
        _lblSendFail.hidden = NO;
        _btnFail.hidden = NO;
    }else {
        //1发送中 3发送失败
        _lblSending.hidden = NO;
        _lblSending.text = messageModel.status == 1 ? LanguageToolMatch(@"发送中...") : LanguageToolMatch(@"发送失败");
        _lblSendEnd.hidden = YES;
        _lblSendFail.hidden = YES;
        _btnFail.hidden = YES;
    }
    
    if ([UserManager.userRoleAuthInfo.groupHairAssistant.configValue isEqualToString:@"true"]) {
        _btnSendAgain.hidden = NO;
    } else {
        _btnSendAgain.hidden = YES;
    }
}
#pragma mark - 按钮交互事件
//查看发送接收者列表
- (void)btnReceiverClick {
    if (_massMessageDelegate && [_massMessageDelegate respondsToSelector:@selector(cellCheckAllReceiverWith:)] && _messageModel) {
        [_massMessageDelegate cellCheckAllReceiverWith:_messageModel];
    }
}
//再发一条
- (void)btnSendAgainClick {
    if (_massMessageDelegate && [_massMessageDelegate respondsToSelector:@selector(cellSendAgainWith:)] && _messageModel) {
        [_massMessageDelegate cellSendAgainWith:_messageModel];
    }
}
//查看发送失败列表
- (void)btnFailClick {
    if (_massMessageDelegate && [_massMessageDelegate respondsToSelector:@selector(cellCheckErrorReceiverWith:)] && _messageModel) {
        [_massMessageDelegate cellCheckErrorReceiverWith:_messageModel];
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
