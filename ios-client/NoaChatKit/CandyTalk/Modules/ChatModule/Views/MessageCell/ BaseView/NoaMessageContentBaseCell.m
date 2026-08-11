//
//  NoaMessageContentBaseCell.m
//  NoaKit
//
//  Created by Candy on 2026/9/28.
//

#import "NoaMessageContentBaseCell.h"

@interface NoaMessageContentBaseCell() <UIGestureRecognizerDelegate>

/// 头像长按手势
@property (nonatomic, strong) UILongPressGestureRecognizer *userAvatarLongTap;

/// 消息内容长按手势
@property (nonatomic, strong) UILongPressGestureRecognizer *messageLongTap;

@end

@implementation NoaMessageContentBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

#pragma mark - 界面布局
- (void)setupUI {
    //选中状态
    _selectedStatusBtn = [[UIButton alloc] init];
    _selectedStatusBtn.frame = CGRectMake(16, 15, 0, 0);
    [_selectedStatusBtn setImage:ImgNamed(@"checkbox_unselected") forState:UIControlStateNormal];
    [_selectedStatusBtn setImage:ImgNamed(@"checkbox_selected") forState:UIControlStateSelected];
    [self.contentView addSubview:_selectedStatusBtn];
    
    //头像
    _msgAvatarImgView = [[UIImageView alloc] initWithImage:DefaultAvatar];
    _msgAvatarImgView.frame = CGRectMake(16, 10, 40, 40);
    [_msgAvatarImgView rounded:16 width:1 color:[COLORWHITE colorWithAlphaComponent:0.7]];
    _msgAvatarImgView.userInteractionEnabled = YES;
    [self.contentView addSubview:_msgAvatarImgView];
    
    _msgUserRoleName = [UILabel new];
    _msgUserRoleName.text = @"";
    _msgUserRoleName.tkThemetextColors = @[COLORWHITE, COLORWHITE];
    _msgUserRoleName.font = FONTN(7);
    _msgUserRoleName.tkThemebackgroundColors = @[COLOR_EAB243, COLOR_EAB243_DARK];
    _msgUserRoleName.textAlignment = NSTextAlignmentCenter;
    [_msgUserRoleName rounded:7];
    _msgUserRoleName.hidden = YES;
    [self.contentView addSubview:_msgUserRoleName];
    [_msgUserRoleName mas_makeConstraints:^(MASConstraintMaker *make) {
          make.leading.equalTo(_msgAvatarImgView).offset(-DWScale(1));
          make.trailing.equalTo(_msgAvatarImgView).offset(DWScale(1));
          make.bottom.equalTo(_msgAvatarImgView);
          make.height.mas_equalTo(14);
    }];
    
    //昵称
    _userNickLbl = [[UILabel alloc] init];
    _userNickLbl.frame = CGRectMake(62, 10, DScreenWidth - 140, 14);
    _userNickLbl.text = @"";
    _userNickLbl.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    _userNickLbl.font = FONTN(14);
    [self.contentView addSubview:_userNickLbl];
    [_userNickLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_msgAvatarImgView.mas_leading).offset(-6);
        make.top.equalTo(self.contentView);
        make.width.mas_equalTo(DScreenWidth - 140);
        make.height.mas_equalTo(16);
    }];
    
    //群主或群管理标识图
    _groupRoleLabel = [[UILabel alloc] init];
    _groupRoleLabel.font = FONTN(10);
    _groupRoleLabel.text = @"";
    _groupRoleLabel.textColor = COLORWHITE;
    _groupRoleLabel.textAlignment = NSTextAlignmentCenter;
    _groupRoleView = [UIButton new];
    [_groupRoleView rounded:DWScale(4)];
    [_groupRoleView addTarget:self action:@selector(activityLevelClick) forControlEvents:UIControlEventTouchUpInside];
    [_groupRoleView addSubview:_groupRoleLabel];
    [_groupRoleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_groupRoleView);
        make.edges.equalTo(_groupRoleView).insets(UIEdgeInsetsMake(3, 4, 3, 4));
    }];
    [self.contentView addSubview:_groupRoleView];
    [_groupRoleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_userNickLbl.mas_leading).offset(-4);
        make.centerY.equalTo(_userNickLbl);
        make.height.mas_equalTo(16);
    }];
    
    //气泡
    _viewSendBubble = [[NoaBubbleSendView alloc] init];
    _viewSendBubble.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_viewSendBubble];
    
    UITapGestureRecognizer *sendBubbleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendBubbleClick)];
    [_viewSendBubble addGestureRecognizer:sendBubbleTap];
    
    _viewReceiveBubble = [[NoaBubbleReceiveView alloc] init];
    _viewReceiveBubble.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_viewReceiveBubble];
    
    UITapGestureRecognizer *receiveBubbleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(receiveBubbleClick)];
    [_viewReceiveBubble addGestureRecognizer:receiveBubbleTap];
    
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
        make.bottom.equalTo(_msgAvatarImgView.mas_top).offset(-19);
        make.height.mas_equalTo(12);
    }];
    
    //已读状态(已读人数进度)
    _readedView = [[NoaMsgReadProgressView alloc] initWithRadius:16 fillColor:COLOR_5966F2];
    [_readedView configBorderWithColor:COLOR_5966F2 borderWidth:1.5];
    _readedView.progress = 0;
    _readedView.frame = CGRectMake(0, 0, DWScale(16), DWScale(16));
    _readedView.hidden = YES;
    [self.contentView addSubview:_readedView];
    [_readedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_viewSendBubble.mas_leading).offset(-6);
        make.bottom.equalTo(_viewSendBubble.mas_bottom);
        make.width.mas_equalTo(DWScale(16));
        make.height.mas_equalTo(DWScale(16));
    }];
    
    //发送失败
    _reSendBtn = [UIButton new];
    [_reSendBtn setImage:ImgNamed(@"icon_msg_resend") forState:UIControlStateNormal];
    [_reSendBtn addTarget:self action:@selector(MessageReSendAction) forControlEvents:UIControlEventTouchUpInside];
    _reSendBtn.hidden = YES;
    [self.contentView addSubview:_reSendBtn];
    [_reSendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_viewSendBubble.mas_leading).offset(-6);
        make.centerY.equalTo(_viewSendBubble);
        make.width.mas_equalTo(DWScale(16));
        make.height.mas_equalTo(DWScale(16));
    }];
    
    _sendLoadingView = [UIImageView new];
    _sendLoadingView.image = ImgNamed(@"img_msg_send_loading");
    _sendLoadingView.hidden = YES;
    [self.contentView addSubview:_sendLoadingView];
    [_sendLoadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_reSendBtn);
    }];
    
    //消息发送时间
    _msgTimeLbl = [UILabel new];
    _msgTimeLbl.text = @"";
    _msgTimeLbl.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    _msgTimeLbl.font = FONTN(12);
    _msgTimeLbl.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_msgTimeLbl];
    [_msgTimeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewReceiveBubble.mas_leading);
        make.top.equalTo(_viewReceiveBubble.mas_bottom).offset(2);
        make.width.mas_equalTo(DWScale(40));
        make.height.mas_equalTo(DWScale(18));
    }];
    
    //头像底部可点击View
    _msgAvatarBackView = [[NoaBaseMsgAvatarView alloc] init];
    _msgAvatarBackView.backgroundColor = COLOR_CLEAR;
    _msgAvatarBackView.userInteractionEnabled = YES;
    [self.contentView addSubview:_msgAvatarBackView];
    //头像点击手势
    UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarClick)];
    [_msgAvatarBackView addGestureRecognizer:avatarTap];
    //长按头像手势
    _userAvatarLongTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(userAvatarLonTapClick:)];
    _userAvatarLongTap.delegate = self;
    [_msgAvatarBackView addGestureRecognizer:_userAvatarLongTap];
    
    //长按手势
    _messageLongTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(messageLongClick:)];
    _messageLongTap.delegate = self;
    [self.contentView addGestureRecognizer:_messageLongTap];

    [self.contentView bringSubviewToFront:self.msgAvatarBackView];
}

- (void)setConfigMessage:(NoaMessageModel *)model {
    [super setConfigMessage:model];
    
    if (model.isShowSelectBox) {
        [self.contentView addGestureRecognizer:self.cellTouchTap];
    } else {
        [self.contentView removeGestureRecognizer:self.cellTouchTap];
    }
    
    //默认都是隐藏的
    _groupRoleView.hidden = YES;
    _selectedStatusBtn.hidden = YES;//隐藏多选box
    _readedView.hidden = YES;       //消息已读状态
    _reSendBtn.hidden = YES;        //消息发送失败，重发
    _sendLoadingView.hidden = YES;  //消息发送中，loading小菊花
    _msgDateLbl.hidden = YES;       //消息时间label
    
    if (model.message.messageType == CIMChatMessageType_GroupNotice || model.message.messageType == CIMChatMessageType_CardMessage || model.message.messageType == CIMChatMessageType_GameStickersMessage || model.message.messageType == CIMChatMessageType_NetCallMessage || model.message.messageType == CIMChatMessageType_ServerMessage || model.message.messageSendType == CIMChatMessageSendTypeSending || model.message.messageSendType == CIMChatMessageSendTypeFail || model.message.messageType == CIMChatMessageType_ForwardMessage) {
        _selectedStatusBtn.selected = NO;
        self.contentView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_EEEEEE_DARK];
    } else {
        if (model.multiSelected) {
            _selectedStatusBtn.selected = YES;
            self.contentView.tkThemebackgroundColors = @[HEXACOLOR(@"4791FF", 0.2),COLOR_00];
        } else {
            _selectedStatusBtn.selected = NO;
            self.contentView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_EEEEEE_DARK];
        }
    }
    
    
    CGFloat offset_Y = CellTop;
    //如果要显示日期时间，offset_Y + 12 + 19
    if (![NSString isNil:model.dataTime]) {
        _msgDateLbl.hidden = NO;
        _msgDateLbl.text = model.dataTime;
        offset_Y = offset_Y + 12 + 19;
    }
  
    //默认消息发送者头像
    NSString *messageFromHeader = model.message.fromIcon;
    NSString *messageFromNickname = model.message.fromNickname;
    NSString *messageUserRoleName = @"";
    NSInteger role = 0;
    NSInteger activityScroe = 0;
    if (model.isSelf) {
        role = model.userGroupRole;
        //自己发的消息
        messageFromHeader = UserManager.userInfo.avatar;
        messageFromNickname = UserManager.userInfo.nickname;
        //角色名称
        messageUserRoleName = [UserManager matchUserRoleConfigInfo:UserManager.userInfo.roleId disableStatus:UserManager.userInfo.disableStatus];
        if (model.message.chatType == CIMChatType_GroupChat) {
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:model.message.fromID groupID:model.message.toID];
            if (groupMemberModel) {
                if (groupMemberModel.nicknameInGroup.length > 0) {
                    messageFromNickname = groupMemberModel.nicknameInGroup;
                }
                if (model.isActivityLevel == 1) {
                    activityScroe = groupMemberModel.activityScroe;
                }
            }
        } else if (model.isActivityLevel == 1) {
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:model.message.fromID groupID:model.message.toID];
            if (groupMemberModel) {
                activityScroe = groupMemberModel.activityScroe;
            }
        }
    }else {
        //别人发的消息
        if (model.message.chatType == CIMChatType_GroupChat) {
            //群聊
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:model.message.fromID groupID:model.message.toID];
            if (groupMemberModel) {
                messageFromHeader = [NSString loadAvatarWithUserStatus:groupMemberModel.disableStatus avatarUri:groupMemberModel.userAvatar];
                messageFromNickname = [NSString loadNickNameWithUserStatus:groupMemberModel.disableStatus realNickName:![NSString isNil:groupMemberModel.remarks]? groupMemberModel.remarks : groupMemberModel.showName];
                role = groupMemberModel.role;
                messageUserRoleName = [UserManager matchUserRoleConfigInfo:groupMemberModel.roleId disableStatus:groupMemberModel.disableStatus];
                activityScroe = groupMemberModel.activityScroe;
            } else {
                CIMLog(@"AvatarWarn: group member cache miss, using fromIcon fallback. groupID=%@, fromID=%@, fromIcon=%@",
                       model.message.toID, model.message.fromID, model.message.fromIcon);
            }
        } else{
            //单聊
            LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:model.message.fromID];
            if (friendModel) {
                messageFromHeader = [NSString loadAvatarWithUserStatus:friendModel.disableStatus avatarUri:friendModel.avatar];
                messageFromNickname = [NSString loadNickNameWithUserStatus:friendModel.disableStatus realNickName:friendModel.showName];
                messageUserRoleName = [UserManager matchUserRoleConfigInfo:friendModel.roleId disableStatus:friendModel.disableStatus];
            } else {
                CIMLog(@"AvatarWarn: friend cache miss, using fromIcon fallback. friendID=%@, fromIcon=%@",
                       model.message.fromID, model.message.fromIcon);
            }
        }
    }
    
    /** 自己发送的 */
    if (model.isSelf) {
        if (model.message.messageType == CIMChatMessageType_GroupNotice || model.message.messageType == CIMChatMessageType_CardMessage || model.message.messageType == CIMChatMessageType_GameStickersMessage || model.message.messageType == CIMChatMessageType_NetCallMessage || model.message.messageType == CIMChatMessageType_ServerMessage || model.message.messageType == CIMChatMessageType_ForwardMessage|| model.message.messageSendType == CIMChatMessageSendTypeSending || model.message.messageSendType == CIMChatMessageSendTypeFail) {
            _selectedStatusBtn.selected = NO;
            _selectedStatusBtn.hidden = YES;
            _selectedStatusBtn.frame = CGRectMake(16, offset_Y+(40/2-DWScale(18)/2), 0, 0);
            [_selectedStatusBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self.contentView).offset(16);
                make.top.equalTo(self.contentView).offset(offset_Y+(40/2-DWScale(18)/2));
                make.size.mas_equalTo(CGSizeMake(0, 0));
            }];
            
            self.contentView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_EEEEEE_DARK];
        } else {
            if (model.isShowSelectBox) {
                _viewSendBubble.userInteractionEnabled = NO;
                _viewReceiveBubble.userInteractionEnabled = NO;
                _selectedStatusBtn.hidden = NO;
                _selectedStatusBtn.frame = CGRectMake(16, offset_Y+(40/2-DWScale(18)/2), DWScale(18), DWScale(18));
                [_selectedStatusBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.equalTo(self.contentView).offset(16);
                    make.top.equalTo(self.contentView).offset(offset_Y+(40/2-DWScale(18)/2));
                    make.size.mas_equalTo(CGSizeMake(DWScale(18), DWScale(18)));
                }];
            } else {
                _viewSendBubble.userInteractionEnabled = YES;
                _viewReceiveBubble.userInteractionEnabled = YES;
                _selectedStatusBtn.selected = NO;
                _selectedStatusBtn.hidden = YES;
                _selectedStatusBtn.frame = CGRectMake(16, offset_Y+(40/2-DWScale(18)/2), 0, 0);
                [_selectedStatusBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.equalTo(self.contentView).offset(16);
                    make.top.equalTo(self.contentView).offset(offset_Y+(40/2-DWScale(18)/2));
                    make.size.mas_equalTo(CGSizeMake(0, 0));
                }];
                self.contentView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_EEEEEE_DARK];
            }
        }
        //头像
        _msgAvatarImgView.frame = CGRectMake(DScreenWidth - 16 - 40, offset_Y, 40, 40);
        [_msgAvatarImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView).offset(DScreenWidth - 16 - 40);
            make.top.equalTo(self.contentView).offset(offset_Y);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
        // 自己头像：走统一头像加载逻辑，兼容注销头像与默认图
        [_msgAvatarImgView loadAvatarWithUserImgContent:messageFromHeader defaultImg:DefaultAvatar];
        if (messageUserRoleName.length <= 0) {
            _msgUserRoleName.hidden = YES;
        } else {
            _msgUserRoleName.hidden = NO;
            [_msgUserRoleName mas_remakeConstraints:^(MASConstraintMaker *make) {
                  make.leading.equalTo(_msgAvatarImgView).offset(-DWScale(1));
                  make.trailing.equalTo(_msgAvatarImgView).offset(DWScale(1));
                  make.bottom.equalTo(_msgAvatarImgView);
                  make.height.mas_equalTo(14);
            }];
            _msgUserRoleName.text = messageUserRoleName;
        }

        CGRect avatarRect = _msgAvatarImgView.frame;
        avatarRect.origin.x -= 16;
        avatarRect.origin.y -= 10;
        avatarRect.size.width += 32;
        avatarRect.size.height += 40;
        _msgAvatarBackView.frame = avatarRect;

        //群聊需要显示昵称
        if (model.message.chatType == CIMChatType_GroupChat) {
            _userNickLbl.hidden = NO;
            [_userNickLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.trailing.equalTo(_msgAvatarImgView.mas_leading).offset(-6);
                make.top.equalTo(self.contentView).offset(offset_Y);
                make.width.mas_lessThanOrEqualTo(DScreenWidth - 140);
                make.height.mas_equalTo(16);
            }];
            if (model.isActivityLevel == 1) {
                _groupRoleLabel.text = [self checkGroupActivityRoleShowStatus:model.isActivityLevel activityScore:activityScroe role:role];
                [_groupRoleView sizeToFit];
                [_groupRoleView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.trailing.equalTo(_userNickLbl.mas_leading).offset(-4);
                    make.centerY.equalTo(_userNickLbl);
                    make.height.mas_equalTo(16);
                }];
            } else {
                if (role == 1 || role == 2) {
                    _groupRoleLabel.text = [self checkGroupActivityRoleShowStatus:model.isActivityLevel activityScore:activityScroe role:role];
                    [_groupRoleView sizeToFit];
                    [_groupRoleView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.trailing.equalTo(_userNickLbl.mas_leading).offset(-4);
                        make.centerY.equalTo(_userNickLbl);
                        make.height.mas_equalTo(16);
                    }];
                }
            }
            //用户名称从数据中取值
            _userNickLbl.text = messageFromNickname;
            offset_Y += 18;
        } else {
            _userNickLbl.hidden = YES;
            [_userNickLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self.contentView).offset(62);
                make.top.equalTo(self.contentView).offset(offset_Y);
                make.size.mas_equalTo(CGSizeMake(DScreenWidth - 140, 16));
            }];
            _groupRoleView.hidden = YES;
        }
        
        //消息气泡
        _viewSendBubble.hidden = NO;
        _viewReceiveBubble.hidden = YES;
        if (model.message.messageType == CIMChatMessageType_FileMessage || model.message.messageType == CIMChatMessageType_CardMessage || model.message.messageType == CIMChatMessageType_GeoMessage || model.message.messageType == CIMChatMessageType_ForwardMessage) {
            UIColor *fillColor;
            if ([TKThemeManager config].themeIndex == 0) {
                fillColor = COLORWHITE;
            } else {
                fillColor = COLOR_66;
            }
            _viewSendBubble.bgFillColor = fillColor;
            if ([ZLanguageTOOL isRTL]) {
                _viewSendBubble.frame = CGRectMake(16 + 40 + 6, offset_Y, model.messageWidth + 20, model.messageHeight);
            } else {
                _viewSendBubble.frame = CGRectMake(_msgAvatarImgView.x - 6 - (model.messageWidth + 20), offset_Y, model.messageWidth + 20, model.messageHeight);
            }
        } else if (model.message.messageType == CIMChatMessageType_GroupNotice) {
            if ([ZLanguageTOOL isRTL]) {
                _viewSendBubble.frame = CGRectMake(16 + 40 + 6, offset_Y, model.messageWidth + 20, model.messageHeight);
            } else {
                _viewSendBubble.frame = CGRectMake(_msgAvatarImgView.x - 6 - (model.messageWidth + 20), offset_Y, model.messageWidth + 20, model.messageHeight);
            }
        } else if (model.message.messageType == CIMChatMessageType_GameStickersMessage) {
            //游戏表情背景色透明
            _viewSendBubble.bgFillColor = COLOR_CLEAR;
            if ([ZLanguageTOOL isRTL]) {
                _viewSendBubble.frame = CGRectMake(16 + 40 + 6, offset_Y, model.messageWidth + 20, model.messageHeight + 16);
            } else {
                _viewSendBubble.frame = CGRectMake(_msgAvatarImgView.x - 6 - (model.messageWidth + 20), offset_Y, model.messageWidth + 20, model.messageHeight + 16);
            }
        } else {
            _viewSendBubble.bgFillColor = nil;
            if (model.messageWidth < model.translateMessageWidth) {
                model.messageWidth = model.translateMessageWidth;
            }
            if ([ZLanguageTOOL isRTL]) {
                _viewSendBubble.frame = CGRectMake(16 + 40 + 6, offset_Y, model.messageWidth + 20, model.messageHeight + model.translateMessageHeight + DWScale(3) + 18);
            } else {
                _viewSendBubble.frame = CGRectMake(_msgAvatarImgView.x - 6 - (model.messageWidth + 20), offset_Y, model.messageWidth + 20, model.messageHeight + model.translateMessageHeight + DWScale(3) + 18);
            }
        }
        //解决显示占位图时，占位图底部会漏出蓝色气泡的蓝边
        if (model.message.messageType == CIMChatMessageType_ImageMessage || model.message.messageType == CIMChatMessageType_VideoMessage || model.message.messageType == CIMChatMessageType_StickersMessage) {
            UIColor *fillColor;
            if ([TKThemeManager config].themeIndex == 0) {
                fillColor = COLOR_F5F6F9;
            } else {
                fillColor = COLOR_66;
            }
            _viewSendBubble.bgFillColor = fillColor;
        }
       
        [_viewSendBubble setNeedsDisplay];
        
        _msgTimeLbl.text = [NSDate transTimeStrToDateMethod4:model.message.sendTime];
        _msgTimeLbl.textAlignment = NSTextAlignmentRight;
        [_msgTimeLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(_viewSendBubble.mas_trailing);
            make.top.equalTo(_viewSendBubble.mas_bottom).offset(2);
            make.width.mas_equalTo(DWScale(40));
            make.height.mas_equalTo(DWScale(18));
        }];
        
        //更新布局参数
        CGRect rect = _viewSendBubble.frame;
        
        if (model.message.messageType == CIMChatMessageType_TextMessage) {
            if (![NSString isNil:model.message.referenceMsgId]) {
                //引用消息
                rect.origin.x += 10;
                rect.origin.y += 9 + model.referenceMsgHeight;
                rect.size.width = model.messageWidth;
                rect.size.height = model.messageHeight - model.referenceMsgHeight;
            } else {
                //文本消息
                rect.origin.x += 10;
                rect.origin.y += 9;
                rect.size.width = model.messageWidth;
                rect.size.height = model.messageHeight;
            }
        } else if (model.message.messageType == CIMChatMessageType_ImageMessage) {
            //图片消息(图片不用设置frame,填充消息气泡)
        } else if (model.message.messageType == CIMChatMessageType_StickersMessage  ) {
            //表情消息(表情图片不用设置frame,填充消息气泡)
        } else if (model.message.messageType == CIMChatMessageType_VoiceMessage) {
            //语音消息
        } else if (model.message.messageType == CIMChatMessageType_VideoMessage) {
            //视频消息
        } else if (model.message.messageType == CIMChatMessageType_FileMessage) {
            //文件消息
            if ([ZLanguageTOOL isRTL]) {
                rect.origin.x = 16 + 40 + 6 + 20;
            } else {
                rect.origin.x = _msgAvatarImgView.x - 6 - (model.messageWidth + 20) +  model.messageWidth - DWScale(32);
            }
            rect.origin.y += DWScale(14);
            rect.size.width = DWScale(32);
            rect.size.height = DWScale(40);
        } else if (model.message.messageType == CIMChatMessageType_ServerMessage) {
            //音视频通话操作提示消息
            IMServerMessage *serverMessage = model.message.serverMessage;
            CustomEvent *customEvent = serverMessage.customEvent;
            if (customEvent.type == 101 || customEvent.type == 103) {
                //文本消息
                if ([ZLanguageTOOL isRTL]) {
                    rect.origin.x += 10;
                } else {
                    rect.origin.x += 10 + DWScale(18) + 6;
                }
                rect.origin.y += 9;
                rect.size.width = model.messageWidth - (6 + DWScale(18));
                rect.size.height = model.messageHeight;
            }
        } else if (model.message.messageType == CIMChatMessageType_NetCallMessage) {
            //即构 音视频通话操作提示消息
            if ([ZLanguageTOOL isRTL]) {
                rect.origin.x += 10;
            } else {
                rect.origin.x += 10 + DWScale(18) + 6;
            }
            rect.origin.y += 9;
            rect.size.width = model.messageWidth - (6 + DWScale(18));
            rect.size.height = model.messageHeight;
        } else if (model.message.messageType == CIMChatMessageType_AtMessage) {
            if (![NSString isNil:model.message.referenceMsgId]) {
                //引用消息+@消息
                rect.origin.x += 10;
                rect.origin.y += 9 + model.referenceMsgHeight;
                rect.size.width = model.messageWidth;
                rect.size.height = model.messageHeight - model.referenceMsgHeight;
            } else {
                // @消息
                rect.origin.x += 10;
                rect.origin.y += 9;
                rect.size.width = model.messageWidth;
                rect.size.height = model.messageHeight;
            }
        } else if (model.message.messageType == CIMChatMessageType_GroupNotice) {
            //群公告消息
        } else if (model.message.messageType == CIMChatMessageType_CardMessage) {
            //名片消息
            rect.origin.x += 10;
            rect.origin.y += 10;
            rect.size.width = DWScale(40);
            rect.size.height = DWScale(40);
        } else if (model.message.messageType == CIMChatMessageType_GeoMessage) {
            //地理位置消息
            rect.origin.x += 16;
            rect.origin.y += DWScale(16);
            rect.size.width = DWScale(250-16*2);
            rect.size.height = DWScale(22);
        } else if (model.message.messageType == CIMChatMessageType_ForwardMessage) {
            //合并转发-消息记录
            rect.origin.x += 10 + DWScale(3) + DWScale(7);
            rect.origin.y += 10;
            rect.size.width = model.messageWidth - DWScale(3) - DWScale(7);
            rect.size.height = DWScale(22);
        } else if (model.message.messageType == CIMChatMessageType_GameStickersMessage) {
            //游戏表情消息
            rect.origin.x += 10;
            rect.origin.y += 9;
            rect.size.width = model.messageWidth;
            rect.size.height = model.messageHeight;
        }
        
        _contentRect = rect;

        //消息已读状态
        [_readedView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(_viewSendBubble.mas_leading).offset(-6);
            make.bottom.equalTo(_viewSendBubble.mas_bottom);
            make.width.mas_equalTo(DWScale(16));
            make.height.mas_equalTo(DWScale(16));
        }];
     
        //消息重发按钮
        [_reSendBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(_viewSendBubble.mas_leading).offset(-6);
            make.centerY.equalTo(_viewSendBubble);
            make.width.mas_equalTo(DWScale(16));
            make.height.mas_equalTo(DWScale(16));
        }];
        //更新消息的发送状态
        [self configMsgSendStatus:model.message.messageSendType];
        
    } else {
        /** 别人发送的消息 */
        //头像
        if (model.message.messageType == CIMChatMessageType_GroupNotice || model.message.messageType == CIMChatMessageType_CardMessage || model.message.messageType == CIMChatMessageType_GameStickersMessage || model.message.messageType == CIMChatMessageType_NetCallMessage || model.message.messageType == CIMChatMessageType_ServerMessage || model.message.messageType == CIMChatMessageType_ForwardMessage || model.message.messageSendType == CIMChatMessageSendTypeSending || model.message.messageSendType == CIMChatMessageSendTypeFail) {
            _selectedStatusBtn.selected = NO;
            _selectedStatusBtn.hidden = YES;
            _selectedStatusBtn.frame = CGRectMake(16, offset_Y+(40/2-DWScale(18)/2), 0, 0);
            [_selectedStatusBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self.contentView).offset(16);
                make.top.equalTo(self.contentView).offset(offset_Y+(40/2-DWScale(18)/2));
                make.size.mas_equalTo(CGSizeMake(0, 0));
            }];
            _msgAvatarImgView.frame = CGRectMake(16, offset_Y, 40, 40);
            [_msgAvatarImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self.contentView).offset(16);
                make.top.equalTo(self.contentView).offset(offset_Y);
                make.size.mas_equalTo(CGSizeMake(40, 40));
            }];
            self.contentView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_EEEEEE_DARK];
        } else {
            if (model.isShowSelectBox) {
                _viewSendBubble.userInteractionEnabled = NO;
                _viewReceiveBubble.userInteractionEnabled = NO;
                _selectedStatusBtn.hidden = NO;
                _selectedStatusBtn.frame = CGRectMake(16, offset_Y+(40/2-DWScale(18)/2), DWScale(18), DWScale(18));
                [_selectedStatusBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.equalTo(self.contentView).offset(16);
                    make.top.equalTo(self.contentView).offset(offset_Y+(40/2-DWScale(18)/2));
                    make.size.mas_equalTo(CGSizeMake(DWScale(18), DWScale(18)));
                }];
                _msgAvatarImgView.frame = CGRectMake(16 + DWScale(18) + 16, offset_Y, 40, 40);
                [_msgAvatarImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.equalTo(self.contentView).offset(16 + DWScale(18) + 16);
                    make.top.equalTo(self.contentView).offset(offset_Y);
                    make.size.mas_equalTo(CGSizeMake(40, 40));
                }];
            } else {
                _viewSendBubble.userInteractionEnabled = YES;
                _viewReceiveBubble.userInteractionEnabled = YES;
                _selectedStatusBtn.selected = NO;
                _selectedStatusBtn.hidden = YES;
                _selectedStatusBtn.frame = CGRectMake(16, offset_Y+(40/2-DWScale(18)/2), 0, 0);
                [_selectedStatusBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.equalTo(self.contentView).offset(16);
                    make.top.equalTo(self.contentView).offset(offset_Y+(40/2-DWScale(18)/2));
                    make.size.mas_equalTo(CGSizeMake(0, 0));
                }];
                _msgAvatarImgView.frame = CGRectMake(16, offset_Y, 40, 40);
                [_msgAvatarImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.equalTo(self.contentView).offset(16);
                    make.top.equalTo(self.contentView).offset(offset_Y);
                    make.size.mas_equalTo(CGSizeMake(40, 40));
                }];
                self.contentView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_EEEEEE_DARK];
            }
        }
        if (messageUserRoleName.length <= 0) {
            _msgUserRoleName.hidden = YES;
        } else {
            _msgUserRoleName.hidden = NO;
            [_msgUserRoleName mas_remakeConstraints:^(MASConstraintMaker *make) {
                  make.leading.equalTo(_msgAvatarImgView).offset(-DWScale(1));
                  make.trailing.equalTo(_msgAvatarImgView).offset(DWScale(1));
                  make.bottom.equalTo(_msgAvatarImgView);
                  make.height.mas_equalTo(14);
            }];
            _msgUserRoleName.text = messageUserRoleName;
        }
        
        // 别人头像保护：若误等于“我的头像”且 fromID 不是我，降级为默认图，避免串图
        if (![NSString isNil:messageFromHeader]) {
            if ([messageFromHeader isEqualToString:UserManager.userInfo.avatar] && ![model.message.fromID isEqualToString:UserManager.userInfo.userUID]) {
                CIMLog(@"AvatarGuard: other-user avatar equals my avatar, fallback to default. fromID=%@", model.message.fromID);
                messageFromHeader = @"";
            }
        }
        [_msgAvatarImgView loadAvatarWithUserImgContent:messageFromHeader defaultImg:DefaultAvatar];
        CGRect avatarRect = _msgAvatarImgView.frame;
        avatarRect.origin.x -= 16;
        avatarRect.origin.y -= 10;
        avatarRect.size.width += 32;
        avatarRect.size.height += 40;
        _msgAvatarBackView.frame = avatarRect;
        
        _viewSendBubble.hidden = YES;
        _viewReceiveBubble.hidden = NO;
        
        //群聊需要显示昵称
        if (model.message.chatType == CIMChatType_GroupChat) {
            _userNickLbl.hidden = NO;
            if (model.isActivityLevel == 1) {
                _groupRoleLabel.text = [self checkGroupActivityRoleShowStatus:model.isActivityLevel activityScore:activityScroe role:role];
                [_groupRoleView sizeToFit];
                if ([NSString isNil:_groupRoleLabel.text]) {
                    [_userNickLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.leading.equalTo(_msgAvatarImgView.mas_trailing).offset(6);
                        make.top.equalTo(self.contentView).offset(offset_Y);
                        make.width.mas_lessThanOrEqualTo(DScreenWidth - 140);
                        make.height.mas_equalTo(16);
                    }];
                } else {
                    [_groupRoleView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.leading.equalTo(_msgAvatarImgView.mas_trailing).offset(6);
                        make.trailing.equalTo(_userNickLbl.mas_leading).offset(-4);
                        make.centerY.equalTo(_userNickLbl);
                        make.height.mas_equalTo(16);
                    }];
                    
                    [_userNickLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.leading.equalTo(_groupRoleView.mas_trailing).offset(4);
                        make.top.equalTo(self.contentView).offset(offset_Y);
                        make.width.mas_lessThanOrEqualTo(DScreenWidth - 140);
                        make.height.mas_equalTo(16);
                    }];
                }
            } else {
                if (role == 1 || role == 2) {
                    _groupRoleLabel.text = [self checkGroupActivityRoleShowStatus:model.isActivityLevel activityScore:activityScroe role:role];
                    [_groupRoleView sizeToFit];
                    [_groupRoleView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.leading.equalTo(_msgAvatarImgView.mas_trailing).offset(6);
                        make.trailing.equalTo(_userNickLbl.mas_leading).offset(-4);
                        make.centerY.equalTo(_userNickLbl);
                        make.height.mas_equalTo(16);
                    }];
                    
                    [_userNickLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.leading.equalTo(_groupRoleView.mas_trailing).offset(4);
                        make.top.equalTo(self.contentView).offset(offset_Y);
                        make.width.mas_lessThanOrEqualTo(DScreenWidth - 140);
                        make.height.mas_equalTo(16);
                    }];
                } else {
                    [_userNickLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.leading.equalTo(_msgAvatarImgView.mas_trailing).offset(6);
                        make.top.equalTo(self.contentView).offset(offset_Y);
                        make.width.mas_lessThanOrEqualTo(DScreenWidth - 140);
                        make.height.mas_equalTo(16);
                    }];
                }
            }
        
            //用户名称从数据中取值
            _userNickLbl.text = messageFromNickname;
            offset_Y += 18;
            if (model.message.messageType == CIMChatMessageType_FileMessage || model.message.messageType == CIMChatMessageType_CardMessage || model.message.messageType == CIMChatMessageType_GeoMessage || model.message.messageType == CIMChatMessageType_ForwardMessage) {
                if ([ZLanguageTOOL isRTL]) {
                    _viewReceiveBubble.frame = CGRectMake(DScreenWidth - 16 - 40 - 6 - (model.messageWidth + 20), offset_Y, model.messageWidth + 20, model.messageHeight);
                } else {
                    _viewReceiveBubble.frame = CGRectMake(CGRectGetMaxX(_msgAvatarImgView.frame) + 6, offset_Y, model.messageWidth + 20, model.messageHeight);
                }
            } else if (model.message.messageType == CIMChatMessageType_GroupNotice) {
                if ([ZLanguageTOOL isRTL]) {
                    _viewReceiveBubble.frame = CGRectMake(DScreenWidth - 16 - 40 - 6 - (model.messageWidth + 20), offset_Y, model.messageWidth + 20, model.messageHeight);
                } else {
                    _viewReceiveBubble.frame = CGRectMake(CGRectGetMaxX(_msgAvatarImgView.frame) + 6, offset_Y, model.messageWidth + 20, model.messageHeight);
                }
            } else {
                if (model.messageWidth < model.translateMessageWidth) {
                    model.messageWidth = model.translateMessageWidth;
                }
                if ([ZLanguageTOOL isRTL]) {
                    _viewReceiveBubble.frame = CGRectMake(DScreenWidth - 16 - 40 - 6 - (model.messageWidth + 20), offset_Y, model.messageWidth + 20, model.messageHeight + model.translateMessageHeight + 18);
                } else {
                    _viewReceiveBubble.frame = CGRectMake(CGRectGetMaxX(_msgAvatarImgView.frame) + 6, offset_Y, model.messageWidth + 20, model.messageHeight + model.translateMessageHeight + 18);
                }
            }
        } else {
            _userNickLbl.hidden = YES;
            [_userNickLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self.contentView).offset(62);
                make.top.equalTo(self.contentView).offset(offset_Y);
                make.size.mas_equalTo(CGSizeMake(DScreenWidth - 140, 16));
            }];
            if (model.message.messageType == CIMChatMessageType_FileMessage || model.message.messageType == CIMChatMessageType_CardMessage || model.message.messageType == CIMChatMessageType_GeoMessage || model.message.messageType == CIMChatMessageType_ForwardMessage) {
                if ([ZLanguageTOOL isRTL]) {
                    _viewReceiveBubble.frame = CGRectMake(DScreenWidth - 16 - 40 - 6 - (model.messageWidth + 20), offset_Y, model.messageWidth + 20, model.messageHeight);
                } else {
                    _viewReceiveBubble.frame = CGRectMake(CGRectGetMaxX(_msgAvatarImgView.frame) + 6, offset_Y, model.messageWidth + 20, model.messageHeight);
                }
            } else if (model.message.messageType == CIMChatMessageType_GroupNotice) {
                if ([ZLanguageTOOL isRTL]) {
                    _viewReceiveBubble.frame = CGRectMake(DScreenWidth - 16 - 40 - 6 - (model.messageWidth + 20), offset_Y, model.messageWidth + 20, model.messageHeight);
                } else {
                    _viewReceiveBubble.frame = CGRectMake(CGRectGetMaxX(_msgAvatarImgView.frame) + 6, offset_Y, model.messageWidth + 20, model.messageHeight);
                }
            } else {
                if (model.messageWidth < model.translateMessageWidth) {
                    model.messageWidth = model.translateMessageWidth;
                }
                if ([ZLanguageTOOL isRTL]) {
                    _viewReceiveBubble.frame = CGRectMake(DScreenWidth - 16 - 40 - 6 - (model.messageWidth + 20), offset_Y, model.messageWidth + 20, model.messageHeight + model.translateMessageHeight + DWScale(3) + 18);
                } else {
                    _viewReceiveBubble.frame = CGRectMake(CGRectGetMaxX(_msgAvatarImgView.frame) + 6, offset_Y, model.messageWidth + 20, model.messageHeight + model.translateMessageHeight + DWScale(3) + 18);
                }
            }
        }
        if (model.message.messageType == CIMChatMessageType_GameStickersMessage) {
            //游戏表情背景色透明
            _viewReceiveBubble.bgFillColor = COLOR_CLEAR;
            if ([ZLanguageTOOL isRTL]) {
                _viewReceiveBubble.frame = CGRectMake(DScreenWidth - 16 - 40 - 6 - (model.messageWidth + 20), offset_Y, model.messageWidth + 20, model.messageHeight + 16);
            } else {
                _viewReceiveBubble.frame = CGRectMake(CGRectGetMaxX(_msgAvatarImgView.frame) + 6, offset_Y, model.messageWidth + 20, model.messageHeight + 16);
            }
        }
        if (model.message.messageType == CIMChatMessageType_StickersMessage) {
            //解决显示占位图时，占位图底部会漏出蓝色气泡的蓝边
            UIColor *fillColor;
            if ([TKThemeManager config].themeIndex == 0) {
                fillColor = COLOR_F5F6F9;
            } else {
                fillColor = COLOR_66;
            }
            _viewReceiveBubble.bgFillColor = fillColor;
        }
        [_viewReceiveBubble setNeedsDisplay];

        _msgTimeLbl.text = [NSDate transTimeStrToDateMethod4:model.message.sendTime];
        _msgTimeLbl.textAlignment = NSTextAlignmentLeft;
        [_msgTimeLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_viewReceiveBubble.mas_leading);
            make.top.equalTo(_viewReceiveBubble.mas_bottom).offset(2);
            make.width.mas_equalTo(DWScale(40));
            make.height.mas_equalTo(DWScale(18));
        }];
        
        //更新布局参数
        CGRect rect = _viewReceiveBubble.frame;
        
        if (model.message.messageType == CIMChatMessageType_TextMessage) {
            if (![NSString isNil:model.message.referenceMsgId]) {
                //引用消息
                rect.origin.x += 10;
                rect.origin.y += 9 + model.referenceMsgHeight;
                rect.size.width = model.messageWidth;
                rect.size.height = model.messageHeight - model.referenceMsgHeight;
            } else {
                //文本消息
                rect.origin.x += 10;
                rect.origin.y += 9;
                rect.size.width = model.messageWidth;
                rect.size.height = model.messageHeight;
            }
        } else if (model.message.messageType == CIMChatMessageType_ImageMessage) {
            //图片消息
        } else if (model.message.messageType == CIMChatMessageType_StickersMessage) {
            //表情消息
        } else if (model.message.messageType == CIMChatMessageType_VoiceMessage) {
            //语音消息
        } else if (model.message.messageType == CIMChatMessageType_VideoMessage) {
            //视频消息
        } else if (model.message.messageType == CIMChatMessageType_FileMessage) {
            //文件消息
            if ([ZLanguageTOOL isRTL]) {
                rect.origin.x = DScreenWidth - 16 - 40 - 6 - model.messageWidth;
            } else {
                rect.origin.x = CGRectGetMaxX(_msgAvatarImgView.frame) + 6 + model.messageWidth - DWScale(32);
            }
            rect.origin.y += DWScale(14);
            rect.size.width = DWScale(32);
            rect.size.height = DWScale(40);
        } else if (model.message.messageType == CIMChatMessageType_ServerMessage) {
            //音视频通话操作提示消息
            IMServerMessage *serverMessage = model.message.serverMessage;
            CustomEvent *customEvent = serverMessage.customEvent;
            if (customEvent.type == 101 || customEvent.type == 103) {
                //文本内容rect
                if ([ZLanguageTOOL isRTL]) {
                    rect.origin.x += 10 + DWScale(18) + 6;
                } else {
                    rect.origin.x += 10;
                }
                rect.origin.y += 9;
                rect.size.width = model.messageWidth - (6 + DWScale(18));
                rect.size.height = model.messageHeight;
            }
        } else if (model.message.messageType == CIMChatMessageType_NetCallMessage) {
            //即构 音视频通话操作提示消息
            if ([ZLanguageTOOL isRTL]) {
                rect.origin.x += 10 + DWScale(18) + 6;
            } else {
                rect.origin.x += 10;
            }
            rect.origin.y += 9;
            rect.size.width = model.messageWidth - (6 + DWScale(18));
            rect.size.height = model.messageHeight;
        } else if (model.message.messageType == CIMChatMessageType_AtMessage) {
            if (![NSString isNil:model.message.referenceMsgId]) {
                //引用消息 + @消息
                rect.origin.x += 10;
                rect.origin.y += 9 + model.referenceMsgHeight;
                rect.size.width = model.messageWidth;
                rect.size.height = model.messageHeight - model.referenceMsgHeight;
            } else {
                // @消息
                rect.origin.x += 10;
                rect.origin.y += 9;
                rect.size.width = model.messageWidth;
                rect.size.height = model.messageHeight;
            }
        } else if (model.message.messageType == CIMChatMessageType_GroupNotice) {
            //群公告消息
        } else if (model.message.messageType == CIMChatMessageType_CardMessage) {
            //名片消息
            if ([ZLanguageTOOL isRTL]) {
                rect.origin.x = (model.messageWidth + 20) + 10;
            } else {
                rect.origin.x += 10;
            }
            rect.origin.y += 10;
            rect.size.width = DWScale(40);
            rect.size.height = DWScale(40);
        } else if (model.message.messageType == CIMChatMessageType_GeoMessage) {
            //地理位置消息 title的Rect
            rect.origin.x += 16;
            rect.origin.y += DWScale(16);
            rect.size.width = DWScale(250-16*2);
            rect.size.height = DWScale(22);
        } else if (model.message.messageType == CIMChatMessageType_ForwardMessage) {
            //合并抓发-消息记录title的坐标
            if ([ZLanguageTOOL isRTL]) {
                rect.origin.x += 10 + DWScale(3) + DWScale(7) - 10;
            } else {
                rect.origin.x += 10 + DWScale(3) + DWScale(7);
            }
            rect.origin.y += 10;
            rect.size.width = model.messageWidth - DWScale(3) - DWScale(7);
            rect.size.height = DWScale(22);
        } else if (model.message.messageType == CIMChatMessageType_GameStickersMessage) {
            //游戏表情消息
            rect.origin.x += 10;
            rect.origin.y += 9;
            rect.size.width = model.messageWidth;
            rect.size.height = model.messageHeight;
        }
        
        _contentRect = rect;
        
    }
}

- (void)configMsgSendStatus:(CIMChatMessageSendType)sendStatus {
    self.reSendBtn.hidden = YES;
    self.readedView.hidden = YES;
    if (sendStatus == CIMChatMessageSendTypeSending) {
        //发送中
        [self startSendLoadingAnimation];
    } else if (sendStatus == CIMChatMessageSendTypeSuccess) {
        //发送成功
        [self stopSendLoadingAnimation];
        //展示消息已读状态
        [self configMsgReadStatus];
    } else if (sendStatus == CIMChatMessageSendTypeFail) {
        //发送失败
        [self stopSendLoadingAnimation];
        self.reSendBtn.hidden = NO;
    }
}

- (void)showSendMessageReadProgressView:(BOOL)showProgress {
    [super showSendMessageReadProgressView:showProgress];
    _readedView.hidden = !showProgress;
}
#pragma mark - 小菊花旋转
//开始旋转
- (void)startSendLoadingAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];///.y的话就向下移动。
    animation.toValue = [NSNumber numberWithFloat:M_PI *2];
    animation.duration = 2.5;
    animation.removedOnCompletion = NO;//yes的话，又返回原位置了。
    animation.repeatCount = MAXFLOAT;
    animation.fillMode = kCAFillModeForwards;
    [_sendLoadingView.layer addAnimation:animation forKey:@"animateTransform"];
    _sendLoadingView.hidden = NO;
}

- (void)stopSendLoadingAnimation {
    [_sendLoadingView.layer removeAllAnimations];
    _sendLoadingView.hidden = YES;
}

//展示单聊、群聊消息已读/未读状态
- (void)configMsgReadStatus {
    if ([UserManager.userRoleAuthInfo.showUserRead.configValue isEqualToString:@"true"]) {
        if (self.messageModel.message.messageType == CIMChatMessageType_ServerMessage) {
            IMServerMessage *serverMessage = self.messageModel.message.serverMessage;
            CustomEvent *customEvent = serverMessage.customEvent;
            if (customEvent.type == 101 || customEvent.type == 103) {
                _readedView.hidden = YES;
            }
        } else if (self.messageModel.message.messageType == CIMChatMessageType_NetCallMessage) {
            _readedView.hidden = YES;
        } else {
            _readedView.hidden = NO;
            if (self.messageModel.message.totalNeedReadCount != 0) {
                float readProgress = (float)self.messageModel.message.haveReadCount / (float)self.messageModel.message.totalNeedReadCount;
                _readedView.progress = readProgress;
            } else {
                _readedView.progress = 0;
            }
        }
    } else {
        _readedView.hidden = YES;
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // 如果是头像长按手势
    if ([gestureRecognizer isEqual:_userAvatarLongTap]) {
        // 获取触摸点在头像视图中的位置
        CGPoint location = [touch locationInView:_msgAvatarBackView];
        // 判断触摸点是否在头像视图的bounds内
        BOOL isTouchingAvatar = CGRectContainsPoint(_msgAvatarBackView.bounds, location);
        return isTouchingAvatar;
    }
    
    // 如果是消息内容长按手势
    if ([gestureRecognizer isEqual:_messageLongTap]) {
        // 获取触摸点在头像视图中的位置
        CGPoint location = [touch locationInView:_msgAvatarBackView];
        // 判断触摸点是否在头像视图的bounds内
        BOOL isTouchingAvatar = CGRectContainsPoint(_msgAvatarBackView.bounds, location);
        // 只有不在头像区域时才接收
        return !isTouchingAvatar;
    }
    
    return YES;
}

#pragma mark - Click
//点击了头像
- (void)avatarClick {
    NSInteger role = 0;
    if (self.messageModel.message.chatType == CIMChatType_GroupChat) {
        //群聊
        LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:self.messageModel.message.fromID groupID:self.messageModel.message.toID];
        if (groupMemberModel) {
            role = groupMemberModel.role;
        } else {
            role = 3;//本地群成员表里查不到，就认为该群成员是机器人
        }
    }
    if ([self.delegate respondsToSelector:@selector(userAvatarClick:role:)]) {
        [self.delegate userAvatarClick:self.messageModel.message.fromID role:role];
    }
}

//长按头像
- (void)userAvatarLonTapClick:(UILongPressGestureRecognizer *)longPressGesture {
    //长按手势会分别在UIGestureRecognizerStateBegan和UIGestureRecognizerStateEnded状态时调用响应函数，
    //此处需做判断
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        NSInteger role = 0;
        if (self.messageModel.message.chatType == CIMChatType_SingleChat) {
            //单聊
            LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:self.messageModel.message.fromID];
            if (friendModel) {
                if ([self.delegate respondsToSelector:@selector(userAvatarLongTapClick:nickname:role:)]) {
                    [self.delegate userAvatarLongTapClick:friendModel.friendUserUID nickname:friendModel.nickname role:role];
                }
            }
        }
        if (self.messageModel.message.chatType == CIMChatType_GroupChat) {
            //群聊
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:self.messageModel.message.fromID groupID:self.messageModel.message.toID];
            if ((self.messageModel.userGroupRole == 2 && groupMemberModel && groupMemberModel.role != 2) || (self.messageModel.userGroupRole == 1 && groupMemberModel && groupMemberModel.role == 0)) {
                if ([self.delegate respondsToSelector:@selector(userAvatarLongTapClickAtAndBanned:nickname:role:cellIndex:)]) {
                    [self.delegate userAvatarLongTapClickAtAndBanned:groupMemberModel.userUid nickname:groupMemberModel.nicknameInGroup role:role cellIndex:self.cellIndex];
                }
            } else {
                if (groupMemberModel) {
                    role = groupMemberModel.role;
                } else {
                    role = 3;//本地群成员表里查不到，就认为该群成员是机器人
                }
                if ([self.delegate respondsToSelector:@selector(userAvatarLongTapClick:nickname:role:)]) {
                    [self.delegate userAvatarLongTapClick:groupMemberModel.userUid nickname:groupMemberModel.nicknameInGroup role:role];
                }
            }
        }
    }
}

//消息发送失败，点击重发消息
- (void)MessageReSendAction {
    if ([self.delegate respondsToSelector:@selector(messageReSendClick:)]) {
        [self.delegate messageReSendClick:self.cellIndex];
    }
}

//长按菜单弹窗
- (void)messageLongClick:(UILongPressGestureRecognizer *)longPressGesture {
    //长按手势会分别在UIGestureRecognizerStateBegan和UIGestureRecognizerStateEnded状态时调用响应函数，
    //此处需做判断
    if (longPressGesture.state == UIGestureRecognizerStateBegan){
        if ([self.delegate respondsToSelector:@selector(messageCellLongTapWithIndex:)]) {
            [self.delegate messageCellLongTapWithIndex:self.cellIndex];
        }
    }
}

//点击了气泡
- (void)sendBubbleClick {
    if ([self.delegate respondsToSelector:@selector(messageBubbleClick:)]) {
        [self.delegate messageBubbleClick:self.cellIndex];
    }
}

- (void)receiveBubbleClick {
    if ([self.delegate respondsToSelector:@selector(messageBubbleClick:)]) {
        [self.delegate messageBubbleClick:self.cellIndex];
    }
}

//点击了cell
- (void)cellViewClick {
    if (self.messageModel.isShowSelectBox && self.messageModel.message.messageSendType == CIMChatMessageSendTypeSuccess && self.messageModel.message.messageType != CIMChatMessageType_GroupNotice && self.messageModel.message.messageType != CIMChatMessageType_CardMessage  && self.messageModel.message.messageType != CIMChatMessageType_GameStickersMessage && self.messageModel.message.messageType != CIMChatMessageType_NetCallMessage && self.messageModel.message.messageType != CIMChatMessageType_ServerMessage) {
        if ([self.delegate respondsToSelector:@selector(messageCellClick:)]) {
            [self.delegate messageCellClick:self.cellIndex];
        }
    }
}

// 图片加载失败信息上报
- (void)loadImageFailWithURL:(NSString *)url error:(NSError *)error {
    
    if ([NSString isNil:url] || [NSString isNil:error.description]) {
        return;
    }
    //日志上传 oss竞速失败
    NSMutableDictionary *loganDict = [NSMutableDictionary dictionary];
    [loganDict setValue:url forKey:@"imageUrl"];
    [loganDict setValue:error.description forKey:@"failReason"];
    [IMSDKManager imSdkWriteLoganWith:LingIMLoganTypeApi loganContent:[[NoaIMLoganManager sharedManager] configLoganContent:loganDict]];

}

//群成员活跃登录标签点击
- (void)activityLevelClick {
    if ([self.delegate respondsToSelector:@selector(groupMemberActivityLevelTagClick:)]) {
        [self.delegate groupMemberActivityLevelTagClick:self.cellIndex];
    }
}

#pragma mark - Tools
//计算是否需要显示活跃等级(是否启用群活跃功能（0：关闭，1：开启）)、等级值、是否显示我在本群的角色(0普通成员;1管理员;2群主)
- (NSString *)checkGroupActivityRoleShowStatus:(NSInteger)isActivityLevel activityScore:(NSInteger)activityScore role:(NSInteger)role {
    NSString *groupRoleLabelStr;
    NSString *roleContent = @"";
    if (role == 2) {
        roleContent =  LanguageToolMatch(@"群主");
        _groupRoleView.backgroundColor = COLOR_FF9327;
    } else if (role == 1) {
        roleContent =  LanguageToolMatch(@"管理员");
        _groupRoleView.backgroundColor = COLOR_5966F2;
    } else {
        roleContent = @"";
        _groupRoleView.backgroundColor = COLOR_FF9C9C;
    }
    
    if (isActivityLevel == 1) {
        if (role == 3) {
            groupRoleLabelStr = @"";
            _groupRoleView.hidden = YES;
        } else {
            //开启-显示群活跃等级
            NSString *levelStr = @"";
            for (NoaGroupActivityLevelModel *levelConfigInfo in UserManager.activityConfigInfo.sortLevels) {
                if (activityScore >= levelConfigInfo.minScore) {
                    levelStr = [NSString isNil:levelConfigInfo.alias] ? levelConfigInfo.level : levelConfigInfo.alias;
                }
            }
            _groupRoleView.hidden = NO;
            groupRoleLabelStr = [NSString stringWithFormat:@"%@%@", levelStr, roleContent];
        }
    } else {
        //关闭-隐藏群活跃等级
        groupRoleLabelStr = roleContent;
        if (role == 1 || role == 2) {
            _groupRoleView.hidden = NO;
        } else {
            _groupRoleView.hidden = YES;
        }
    }
    return groupRoleLabelStr;
}

#pragma mark - Lazy
//cell点击手势
- (UITapGestureRecognizer *)cellTouchTap {
    if (!_cellTouchTap) {
        _cellTouchTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellViewClick)];
    }
    return _cellTouchTap;
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
