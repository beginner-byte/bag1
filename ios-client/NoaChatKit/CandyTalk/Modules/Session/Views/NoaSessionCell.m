//
//  NoaSessionCell.m
//  NoaKit
//
//  Created by Candy on 2026/9/23.
//

#import "NoaSessionCell.h"
#import "NoaBaseImageView.h"
#import "YYLabel.h"
#import "NSString+SessionLatestMessage.h"
#import "NoaBaseTableView.h"
#import "NoaToolManager.h"
#import "MBadgeView.h"
#import "NoaDraftStore.h"
#import "NoaImageLoader.h"

@interface NoaSessionCell ()
@property (nonatomic, strong) NoaBaseImageView *ivHeader; //头像
@property (nonatomic, strong) UILabel *lblTitle;//昵称
@property (nonatomic, strong) UILabel *lblContent;//消息内容
@property (nonatomic, strong) UILabel *lblTime;//消息时间
@property (nonatomic, strong) MBadgeView *lblRed;//消息未读数
@property (nonatomic, strong) UIView *viewRed;//消息未读红点
@property (nonatomic, strong) UIView *viewOnline;//用户在线状态
@end

@implementation NoaSessionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        [self setupUI];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    // TODO: 优化cell复用导致图片展示错乱问题
    // 取消之前的图片加载操作
    [self.ivHeader sd_cancelCurrentImageLoad];
    // 保留现有图像，待新URL加载成功后覆盖，减少闪烁
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{ // animate between regular and highlighted state
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        self.tkThemebackgroundColors = @[COLOR_EEEEEE, COLOR_EEEEEE_DARK];
        self.contentView.tkThemebackgroundColors = @[COLOR_EEEEEE, COLOR_EEEEEE_DARK];
    }else{
        self.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        self.contentView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    }
}

#pragma mark - 界面布局
- (void)setupUI {
    self.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    self.contentView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    
    _ivHeader = [[NoaBaseImageView alloc] init];
    _ivHeader.contentMode = UIViewContentModeScaleAspectFill;
    [_ivHeader rounded:25 width:1 color:HEXCOLOR(@"D8D9FF")];
    [self.contentView addSubview:_ivHeader];
    [_ivHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(16);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    
    _lblTitle = [UILabel new];
    _lblTitle.tkThemetextColors = @[COLOR_11,COLORWHITE];
    [self.contentView addSubview:_lblTitle];

    _lblContent = [UILabel new];
    _lblContent.tkThemetextColors = @[COLOR_8D93A6,COLOR_8D93A6_DARK];
    [self.contentView addSubview:_lblContent];
    
    _lblTime = [UILabel new];
    _lblTime.font = FONTR(12);
    _lblTime.tkThemetextColors = @[COLOR_8D93A6,COLOR_8D93A6_DARK];
    [self.contentView addSubview:_lblTime];
    [_lblTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_lblTitle);
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-DWScale(16));
        make.width.mas_equalTo(DWScale(100));
    }];
    
    [_lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_ivHeader).offset(DWScale(1));
        make.leading.equalTo(_ivHeader.mas_trailing).offset(DWScale(12));
        make.trailing.equalTo(self.lblTime.mas_leading).offset(DWScale(-10));
        make.height.mas_equalTo(DWScale(22));
    }];
    
    [_lblContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(_ivHeader);
        make.leading.equalTo(_ivHeader.mas_trailing).offset(DWScale(12));
        make.trailing.equalTo(self.lblTime.mas_leading).offset(DWScale(-10));
        make.height.mas_equalTo(DWScale(22));
    }];
    _lblRed = [MBadgeView new];
    _lblRed.textLb.font = FONTR(12);
    _lblRed.textLb.textColor = COLORWHITE;
    _lblRed.badgeCorlor = COLOR_F93A2F;
    _lblRed.layer.cornerRadius = DWScale(8);
    _lblRed.layer.masksToBounds = YES;
    _lblRed.hidden = YES;
    WeakSelf
    [_lblRed setClearBlock:^{
        if (weakSelf.clearSessionBlock) {
            weakSelf.clearSessionBlock();
        }
    }];
    [self.contentView addSubview:_lblRed];
    [_lblRed mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_lblContent);
        make.trailing.equalTo(self.contentView).offset(-DWScale(16));
        make.height.mas_equalTo(DWScale(20));
        make.width.mas_equalTo(DWScale(20));
    }];
    
    _viewRed = [UIView new];
    _viewRed.tkThemebackgroundColors = @[COLOR_F93A2F, COLOR_F93A2F];
    _viewRed.layer.cornerRadius = DWScale(5);
    _viewRed.layer.masksToBounds = YES;
    _viewRed.hidden = YES;
    [self.contentView addSubview:_viewRed];
    [_viewRed mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_lblContent);
        make.trailing.equalTo(self.contentView).offset(-DWScale(16));
        make.height.mas_equalTo(DWScale(10));
        make.width.mas_equalTo(DWScale(10));
    }];
    
    _viewOnline = [UIView new];
    _viewOnline.tkThemebackgroundColors = @[HEXCOLOR(@"54E623"), HEXCOLOR(@"54E623")];
    _viewOnline.layer.cornerRadius = DWScale(8);
    _viewOnline.layer.masksToBounds = YES;
    _viewOnline.layer.tkThemeborderColors = @[COLORWHITE, COLORWHITE_DARK];
    _viewOnline.layer.borderWidth = DWScale(1);
    [self.contentView addSubview:_viewOnline];
    [_viewOnline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(_ivHeader);
        make.trailing.mas_equalTo(_ivHeader);
        make.size.mas_equalTo(CGSizeMake(DWScale(16), DWScale(16)));
    }];
    
}


#pragma mark - 数据赋值
- (void)setModel:(LingIMSessionModel *)model {
    WeakSelf
    if (model) {
        _model = model;
        
        // 取消之前的图片加载操作
        [self.ivHeader sd_cancelCurrentImageLoad];
        
        // 立即清空头像，避免显示旧数据
        self.ivHeader.image = nil;
        
        if (model.sessionType == CIMSessionTypeDefault) return;
        _viewOnline.hidden = YES;
        if (model.sessionType == CIMSessionTypeSingle) {
            //单聊
            // 占位图，等待最终头像URL再加载，避免重复加载导致闪烁
            self.ivHeader.image = DefaultAvatar;
            self.lblTitle.text = model.sessionName;
            dispatch_async_main_queue(^{
                LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:model.sessionID];
                if (friendModel) {
                    NSString *avatarUri = [NSString loadAvatarWithUserStatus:friendModel.disableStatus avatarUri:friendModel.avatar];
                    [NoaImageLoader loadImageIntoImageView:weakSelf.ivHeader
                                                   urlStr:avatarUri
                                              placeholder:DefaultAvatar
                                                pixelSize:CGSizeMake(DWScale(44), DWScale(44))
                                                 animated:NO];
                    NSString *tempFriendNick = [NSString loadNickNameWithUserStatus:friendModel.disableStatus realNickName:friendModel.showName];
                    weakSelf.lblTitle.text = ![NSString isNil:tempFriendNick] ? tempFriendNick : model.sessionName;
                } else {
                    [NoaImageLoader loadImageIntoImageView:weakSelf.ivHeader
                                                   urlStr:[model.sessionAvatar getImageFullUrl].absoluteString
                                              placeholder:DefaultAvatar
                                                pixelSize:CGSizeMake(DWScale(44), DWScale(44))
                                                 animated:NO];
                    weakSelf.lblTitle.text = model.sessionName;
                }
                if (friendModel) {
                    weakSelf.viewOnline.hidden = friendModel.onlineStatus ? NO : YES;
                }
            });

            //会话最新消息处理
            // 优先显示本地草稿
            NSDictionary *localDraft = [NoaDraftStore loadDraftForSession:_model.sessionID];
            if (localDraft.count > 0) {
                [self showLocalDraftDict:localDraft];
            } else {
                NoaIMChatMessageModel *lastMessage = _model.sessionLatestMessage;
                if (lastMessage) {
                    self.model.sessionLatestMessage = lastMessage;
                    [self showLocalLatestMessageWith:self.model.sessionLatestMessage];
                } else {
                    NoaIMChatMessageModel *lastMessage = [DBTOOL getLatestChatMessageWithTableName:weakSelf.model.sessionTableName];
                    self.model.sessionLatestMessage = lastMessage;
                    [self showLocalLatestMessageWith:self.model.sessionLatestMessage];
                }
            }
        } else if (model.sessionType == CIMSessionTypeGroup) {
            //群聊
            [NoaImageLoader loadImageIntoImageView:self.ivHeader
                                           urlStr:[model.sessionAvatar getImageFullUrl].absoluteString
                                      placeholder:DefaultGroup
                                        pixelSize:CGSizeMake(DWScale(44), DWScale(44))
                                         animated:NO];
            _lblTitle.text = _model.sessionName;
            
            //会话最新消息处理
            NSDictionary *localDraft2 = [NoaDraftStore loadDraftForSession:_model.sessionID];
            if (localDraft2.count > 0) {
                [self showLocalDraftDict:localDraft2];
            }else {
                NoaIMChatMessageModel *lastMessage = _model.sessionLatestMessage;
                if (lastMessage) {
                    self.model.sessionLatestMessage = lastMessage;
                    [self showLocalLatestMessageWith:weakSelf.model.sessionLatestMessage];
                }else{
                    NoaIMChatMessageModel *lastMessage = [DBTOOL getLatestChatMessageWithTableName:weakSelf.model.sessionTableName];
                    self.model.sessionLatestMessage = lastMessage;
                    [self showLocalLatestMessageWith:weakSelf.model.sessionLatestMessage];
                }
            }
            
        }else if (model.sessionType == CIMSessionTypeMassMessage) {
            
            //群发助手
            _ivHeader.image = ImgNamed(@"session_hair_group_logo");
            _lblTitle.text = _model.sessionName;
            
            //会话最新消息处理
            [self showLatestMassMessage];
            
        } else if (model.sessionType == CIMSessionTypeSystemMessage) {
            
            //系统消息(群助手)
            _ivHeader.image = ImgNamed(@"session_helper_group_logo");
            _lblTitle.text = _model.sessionName;
            
            //会话最新消息处理
            [self showLocalLatestMessageWith:_model.sessionLatestMessage];
        } else if (model.sessionType == CIMSessionTypeSignInReminder) {
            
            //签到提醒
            _ivHeader.image = ImgNamed(@"session_signlIn_header_logo");
            _lblTitle.text = LanguageToolMatch(_model.sessionName);
            
            //会话最新消息处理
            _lblContent.attributedText = [NSString getSessionDefaultLastMsgContentAttributedStringWith:LanguageToolMatch(@"今日未签到-前去签到")];
        }
        
        //时间
        if (_model.sessionLatestMessage) {
            _lblTime.text = _model.sessionLatestMessage.sendTime > 0 ? [NSString timeIntervalStringWith:_model.sessionLatestMessage.sendTime / 1000] : @"";
        } else {
            _lblTime.text = _model.sessionLatestTime > 0 ? [NSString timeIntervalStringWith:_model.sessionLatestTime / 1000] : @"";
        }
        
        CGFloat timeStrWidth = [_lblTime.text widthForFont:_lblTime.font] + 15;
        [_lblTime mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_lblTitle);
            make.trailing.equalTo(self.contentView.mas_trailing).offset(-DWScale(16));
            make.width.mas_equalTo(timeStrWidth);
        }];
        
        //未读数
        [self showSessionUnreadContent];
        
        //文件助手、群发助手、群助手 的 多语言 头像 本地处理；如有修改，需要重新发版
        [self specialSessionTitleConfig];
        
    }
}

#pragma mark - 会话最新消息
//展示本地存储的最新消息
- (void)showLocalLatestMessageWith:(NoaIMChatMessageModel *)latestMessage {
    if (latestMessage) {
        self.lblContent.attributedText = [NSString getSessionLatestMessageAttributedStringWith:self.model];;
        self.lblContent.textAlignment = NSTextAlignmentLeft;
        
    }else {
        //暂无新消息提示
        _lblContent.attributedText = [self sessionNoNewMessageTip];
        _lblContent.textAlignment = NSTextAlignmentLeft;

    }
}

//展示最新的群发助手消息
- (void)showLatestMassMessage {
    
    NSString *userKey = [NSString stringWithFormat:@"%@-MassMessage", UserManager.userInfo.userUID];
    NSString *jsonStr = [[MMKV defaultMMKV] getStringForKey:userKey];
    if (![NSString isNil:jsonStr]) {
        //最新群发助手消息提示
        NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if (!error) {
            LIMMassMessageModel *massMessageModel = [LIMMassMessageModel mj_objectWithKeyValues:dict];
            _model.sessionLatestMassMessage = massMessageModel;
            _lblContent.attributedText = [NSString getSessionLatestMassMessageAttributedStringWith:_model];
            _lblContent.textAlignment = NSTextAlignmentLeft;

        }
    }else {
        //暂无新消息提示
        _model.sessionLatestMassMessage = nil;
        _lblContent.attributedText = [self sessionNoNewMessageTip];
        _lblContent.textAlignment = NSTextAlignmentLeft;

    }
}

//展示本地存储的草稿
- (void)showLocalDraftContent {
    if (_model.draftDict.count > 0) {
        //最新消息展示
        _lblContent.attributedText = [NSString getSessionDraftContentAttributedStringWith:_model];
        _lblContent.textAlignment = NSTextAlignmentLeft;

    }else {
        //暂无新消息提示
        _lblContent.attributedText = [self sessionNoNewMessageTip];
        _lblContent.textAlignment = NSTextAlignmentLeft;
    }
}

// 展示本地持久化草稿
- (void)showLocalDraftDict:(NSDictionary *)draft {
    NSString *text = [draft objectForKey:@"draftContent"];
    if (text.length > 0) {
        // 复用原有构造草稿富文本的方法（以 _model 为输入）
        LingIMSessionModel *tmp = _model;
        tmp.draftDict = draft;
        NSMutableAttributedString *contentAtt = [NSString getSessionDraftContentAttributedStringWith:tmp];
        if (contentAtt.length > 0) {
            _lblContent.attributedText = contentAtt;
            _lblContent.textAlignment = NSTextAlignmentLeft;
            return;
        }
    }
    _lblContent.attributedText = [self sessionNoNewMessageTip];
    _lblContent.textAlignment = NSTextAlignmentLeft;
}

//会话红点处理
- (void)showSessionUnreadContent {
    _lblRed.hidden = YES;
    _viewRed.hidden = YES;
    
    switch (_model.sessionType) {
        case CIMSessionTypeMassMessage://群发助手
        {
            //不进行红点及数字的显示
        }
            break;
        case CIMSessionTypeSingle://单聊
        case CIMSessionTypeGroup://群聊
        case CIMSessionTypeSignInReminder: //系统消息(签到提醒)
        {
            //红点数字显示
            _lblRed.hidden = (_model.sessionUnreadCount + _model.readTag) > 0 ? NO : YES;
            if ((_model.sessionUnreadCount + _model.readTag) > 99) {
                [_lblRed mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(_lblContent);
                    make.trailing.equalTo(self.contentView).offset(-DWScale(16));
                    make.height.mas_equalTo(DWScale(16));
                    make.width.mas_equalTo(DWScale(24));
                }];
            } else {
                [_lblRed mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(_lblContent);
                    make.trailing.equalTo(self.contentView).offset(-DWScale(16));
                    make.height.mas_equalTo(DWScale(16));
                    make.width.mas_equalTo(DWScale(16));
                }];
            }
            [_lblRed setBadge:(_model.sessionUnreadCount + _model.readTag)];
            
            if (_model.sessionNoDisturb) {
                //开启消息免打扰
                _lblRed.backgroundColor = HEXCOLOR(@"CCCCCC");
            } else {
                //关闭消息免打扰
                _lblRed.backgroundColor = COLOR_F93A2F;
            }
        }
            
            break;
        case CIMSessionTypeSystemMessage://系统消息(群助手)
        {
            //红点显示
            _viewRed.hidden = _model.sessionUnreadCount > 0 ? NO : YES;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 消息免打扰富文本
- (NSMutableAttributedString *)sessionNoDisturbTitle {
    if (![NSString isNil:_model.sessionName]) {
        NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:_model.sessionName];
        
        // 保存原始长度，避免在异步回调中访问可能已释放的对象
        NSUInteger originalLength = attriStr.length;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 2;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;//NSLineBreakByCharWrapping;
        [attriStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, originalLength)];
        
        [attriStr addAttribute:NSFontAttributeName value:FONTR(16) range:NSMakeRange(0, originalLength)];
        
        self.contentView.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
            // 使用保存的原始长度，避免访问可能已释放的对象
            NSUInteger safeLength = originalLength;
            if (safeLength > 0) {
                switch (themeIndex) {
                    case 1:
                    {
                        //暗黑
                        [attriStr addAttribute:NSForegroundColorAttributeName value:COLOR_11_DARK range:NSMakeRange(0, safeLength)];
                    }
                        break;
                        
                    default:
                    {
                        [attriStr addAttribute:NSForegroundColorAttributeName value:COLOR_11 range:NSMakeRange(0, safeLength)];
                    }
                        break;
                }
            }
        };
        
        
        return attriStr;
    }else{
        return nil;
    }

}

#pragma mark - 暂无新消息提示
- (NSMutableAttributedString *)sessionNoNewMessageTip {
    
    NSMutableAttributedString *sessionAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"[暂无新消息]")];

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 2;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;//NSLineBreakByCharWrapping;
    
    __block NSDictionary *dict;
    self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        switch (themeIndex) {
            case 1:
            {
                //暗黑
                dict = @{
                    NSFontAttributeName:FONTR(12),
                    NSForegroundColorAttributeName:COLOR_99_DARK,
                    NSParagraphStyleAttributeName:paragraphStyle,
                };
            }
                break;
                
            default:
            {
                dict = @{
                    NSFontAttributeName:FONTR(12),
                    NSForegroundColorAttributeName:COLOR_99,
                    NSParagraphStyleAttributeName:paragraphStyle,
                };
            }
                break;
        }
    };
    
    [sessionAttStr addAttributes:dict range:NSMakeRange(0, sessionAttStr.length)];
    
    return sessionAttStr;
}

#pragma mark - 文件助手、群发助手、群助手 的 多语言 头像 本地处理
- (void)specialSessionTitleConfig {
    if (_model) {
        if ([_model.sessionID isEqualToString:@"100001"]) {
            //群发助手
            _lblTitle.text = LanguageToolMatch(@"群发助手");
            _ivHeader.image = ImgNamed(@"session_hair_group_logo");
        }else if ([_model.sessionID isEqualToString:@"100002"]) {
            //文件助手
            _lblTitle.text = LanguageToolMatch(@"文件助手");
            _ivHeader.image = ImgNamed(@"session_file_helper_logo");
            //[_ivHeader setImageWithURL:[_model.sessionAvatar getImageFullString] options:(JImageOptionAvoidAutoSetImage | JImageOptionProgressive) placeHolder:ImgNamed(@"session_file_helper_logo")];
        }else if ([_model.sessionID isEqualToString:@"100008"]) {
            //群助手
            _lblTitle.text = LanguageToolMatch(@"群助手");
            _ivHeader.image = ImgNamed(@"session_helper_group_logo");
        }else if ([_model.sessionID isEqualToString:@"100009"]) {
            //支付通知
            _lblTitle.text = LanguageToolMatch(@"支付通知");
            _ivHeader.image = ImgNamed(@"session_pay_notificeation_logo");
        }
    }
    
}

#pragma mark - 交互事件
- (void)btnContentBgClick:(UIButton *)sender {

    if (_cellDelegate && [_cellDelegate respondsToSelector:@selector(cellClickAction:)]) {
        [_cellDelegate cellClickAction:_cellIndexPath];
    }
    
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


@end
