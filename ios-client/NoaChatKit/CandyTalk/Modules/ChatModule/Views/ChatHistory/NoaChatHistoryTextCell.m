//
//  NoaChatHistoryTextCell.m
//  NoaKit
//
//  Created by Candy on 2026/11/14.
//

#import "NoaChatHistoryTextCell.h"
#import "NoaMessageTimeTool.h"
//#import <YYText/YYText.h>

@interface NoaChatHistoryTextCell ()
@property (nonatomic, strong) UIImageView *ivHeader;//用户头像
@property (nonatomic, strong) UILabel *lblNickname;//用户昵称
@property (nonatomic, strong) UILabel *lblSendTime;//消息发送时间
@property (nonatomic, strong) UILabel *lblMessageContent;//文本消息内容

@property (nonatomic, strong) NoaIMChatMessageModel *chatMessageModel;
@property (nonatomic, copy) NSString *searchStr;
@end

@implementation NoaChatHistoryTextCell
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
    UIButton * _viewBg = [[UIButton alloc] init];
    _viewBg.frame = CGRectMake(0, 0, DScreenWidth , DWScale(68));
    _viewBg.tkThemebackgroundColors =  @[COLORWHITE, COLOR_F5F6F9_DARK];
    [_viewBg setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE]] forState:UIControlStateSelected];
    [_viewBg setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE]] forState:UIControlStateHighlighted];
    [_viewBg addTarget:self action:@selector(cellTouchAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_viewBg];
    
    _ivHeader = [[UIImageView alloc] initWithFrame:CGRectMake(DWScale(16), DWScale(12), DWScale(44), DWScale(44))];
    _ivHeader.layer.cornerRadius = DWScale(22);
    _ivHeader.layer.masksToBounds = YES;
    [self.contentView addSubview:_ivHeader];
    
    _lblNickname = [UILabel new];
    _lblNickname.font = FONTR(16);
    _lblNickname.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [self.contentView addSubview:_lblNickname];
    [_lblNickname mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_ivHeader.mas_trailing).offset(DWScale(10));
        make.top.equalTo(_ivHeader);
        make.height.mas_equalTo(DWScale(22));
    }];
    
    _lblSendTime = [UILabel new];
    _lblSendTime.font = FONTR(12);
    _lblSendTime.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    [self.contentView addSubview:_lblSendTime];
    [_lblSendTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_lblNickname);
        make.trailing.equalTo(self.contentView).offset(-DWScale(16));
    }];
    
    _lblMessageContent = [UILabel new];
    _lblMessageContent.numberOfLines = 0;
    _lblMessageContent.preferredMaxLayoutWidth = DScreenWidth - DWScale(86);
    _lblMessageContent.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    [self.contentView addSubview:_lblMessageContent];
    [_lblMessageContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_lblNickname);
        make.trailing.equalTo(_lblSendTime);
        make.bottom.equalTo(_ivHeader);
        make.height.mas_equalTo(DWScale(22));
    }];
    
}
#pragma mark - 交互事件
- (void)cellTouchAction {
    if ([self.baseDelegate respondsToSelector:@selector(cellClickAction:)]) {
        [self.baseDelegate cellClickAction:self.baseCellIndexPath];
    }
}

#pragma mark - 界面赋值
- (void)configCellWith:(NoaIMChatMessageModel *)chatMessageModel searchContent:(NSString *)searchStr {
    if (chatMessageModel && (chatMessageModel.messageType == CIMChatMessageType_TextMessage || chatMessageModel.messageType == CIMChatMessageType_AtMessage)) {
        
        _chatMessageModel = chatMessageModel;
        _searchStr = searchStr;
        
        //头像
        
        if (chatMessageModel.chatType == CIMChatType_SingleChat) {
            LingIMFriendModel *userInfoModel =  [IMSDKManager toolCheckMyFriendWith:chatMessageModel.fromID];
            
            NSString *avatarUrl = [NSString loadAvatarWithUserStatus:userInfoModel.disableStatus avatarUri:userInfoModel.avatar];
            [_ivHeader loadAvatarWithUserImgContent:avatarUrl defaultImg:DefaultAvatar];
            //昵称
            if ([chatMessageModel.fromID isEqualToString:UserManager.userInfo.userUID]) {
                _lblNickname.text = UserManager.userInfo.showName;
            } else {
                if (userInfoModel.disableStatus == 4) {
                    //别人的的消息，并且对方账号已注销
                    _lblNickname.text = [NSString loadNickNameWithUserStatus:userInfoModel.disableStatus realNickName:chatMessageModel.fromNickname];
                } else {
                    _lblNickname.text = chatMessageModel.fromNickname;
                }
            }
        }else {
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:chatMessageModel.fromID groupID:chatMessageModel.toID];
            
            NSString *avatarUrl = [NSString loadAvatarWithUserStatus:groupMemberModel.disableStatus avatarUri:groupMemberModel.userAvatar];
            [_ivHeader loadAvatarWithUserImgContent:avatarUrl defaultImg:DefaultGroup];
            //昵称
            if ([chatMessageModel.fromID isEqualToString:UserManager.userInfo.userUID]) {
                _lblNickname.text = UserManager.userInfo.showName;
            } else {
                if (groupMemberModel.disableStatus == 4) {
                    //别人的的消息，并且对方账号已注销
                    _lblNickname.text = [NSString loadNickNameWithUserStatus:groupMemberModel.disableStatus realNickName:chatMessageModel.fromNickname];
                } else {
                    _lblNickname.text = chatMessageModel.fromNickname;
                }
            }
        }
        //日期时间
        NSDate *msgTime = [NSDate dateWithTimeIntervalSince1970:chatMessageModel.sendTime / 1000];
        _lblSendTime.text = [NoaMessageTimeTool getTimeStringAutoShort2:msgTime mustIncludeTime:YES];
       
        
        NSString *showContentStr = [self getShowText];
        WeakSelf
        self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
            if (themeIndex == 1) {
                //暗黑
                weakSelf.lblMessageContent.attributedText = [weakSelf showAttributedSearchResult:showContentStr searchValue:weakSelf.searchStr normalColor:COLOR_99_DARK normalFont:FONTR(16)];
            }else {
                //浅色
                weakSelf.lblMessageContent.attributedText = [weakSelf showAttributedSearchResult:showContentStr searchValue:weakSelf.searchStr normalColor:COLOR_99 normalFont:FONTR(16)];
            }
        };
    }
}

+ (CGFloat)defaultCellHeight {
    return DWScale(68);
}

#pragma mark - 富文本
- (NSAttributedString *)showAttributedSearchResult:(NSString *)searchResult searchValue:(NSString *)searchValue normalColor:(UIColor*)normalColor normalFont:(UIFont*)normalFont{
    
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:searchResult];
    
    if (searchValue.length == 0) return attributedStr;
    
    NSRange searchResultRange = NSMakeRange(0, searchResult.length);
    [attributedStr addAttribute:NSFontAttributeName value:normalFont range:searchResultRange];
    [attributedStr addAttribute:NSForegroundColorAttributeName value:normalColor range:searchResultRange];
    
    NSRange searchValueRange = [searchResult rangeOfString:searchValue options:NSCaseInsensitiveSearch];//不区分大小写
    [attributedStr addAttribute:NSForegroundColorAttributeName value:COLOR_5966F2 range:searchValueRange];
    
    return attributedStr;
}

#pragma mark - 获取文本在label需要几行展示
- (NSArray *)getLinesArrayOfStringInLabel:(UILabel *)label{
    NSString *text = [label text];
    UIFont *font = [label font];
    CGRect rect = [label frame];

    CTFontRef myFont = CTFontCreateWithName(( CFStringRef)([font fontName]), [font pointSize], NULL);
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:text];
    
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge  id)myFont range:NSMakeRange(0, attStr.length)];
    
    CFRelease(myFont);
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString(( CFAttributedStringRef)attStr);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,rect.size.width,100000));
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    NSArray *lines = ( NSArray *)CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    for (id line in lines) {
        CTLineRef lineRef = (__bridge  CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        NSString *lineString = [text safeSubstringWithRange:range];
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr, lineRange, kCTKernAttributeName, (CFTypeRef)([NSNumber numberWithFloat:0.0]));
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr, lineRange, kCTKernAttributeName, (CFTypeRef)([NSNumber numberWithInt:0.0]));
        //NSLog(@"''''''''''''''''''%@",lineString);
        [linesArray addObject:lineString];
    }

    CGPathRelease(path);
    CFRelease( frame );
    CFRelease(frameSetter);
    return (NSArray *)linesArray;
}
- (NSString *)getShowText {
    if (_chatMessageModel) {
        
        [_lblMessageContent layoutIfNeeded];
        NSString *textContent;
        if (_chatMessageModel.messageType == CIMChatMessageType_TextMessage) {
            //文本消息
            textContent = _chatMessageModel.textContent;
        }else if (_chatMessageModel.messageType == CIMChatMessageType_AtMessage) {
            //@消息
            textContent = _chatMessageModel.showContent;
        }
        if (![textContent containsString:_searchStr]) return textContent;
        
        UILabel *showLabel = [UILabel new];
        showLabel.frame = _lblMessageContent.bounds;
        showLabel.text = textContent;
        showLabel.font = FONTR(16);
        
        WeakSelf
        __block NSString *showText;
        
        NSArray *textLineArr = [self getLinesArrayOfStringInLabel:showLabel];
        NSString *firstString = textLineArr.firstObject;
        NSInteger showNumber = firstString.length;
        
        if (_searchStr.length > showNumber) {
            return _searchStr;
        }
        
        [textLineArr enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj containsString:weakSelf.searchStr]) {
                if (textContent.length > showNumber) {
                    if (idx == 0) {
                        //开头
                        showText = [NSString stringWithFormat:@"%@...",obj];
                    }else if (idx == textLineArr.count - 1) {
                        //结尾
                        showText = [NSString stringWithFormat:@"...%@",obj];
                    }else {
                        //中间
                        showText = [NSString stringWithFormat:@"...%@...",obj];
                    }
                }else {
                    showText = obj;
                }
                *stop = YES;
            }
        }];
        
        if (![NSString isNil:showText]) {
            return showText;
        }else {
            NSRange searchValueRange = [showLabel.text rangeOfString:_searchStr options:NSCaseInsensitiveSearch];//不区分大小写
            NSInteger shang = (showNumber - (6 + _searchStr.length)) / 2;
            NSInteger yu = (showNumber - (6 + _searchStr.length)) % 2;
            NSInteger indexX = searchValueRange.location;
            NSInteger left = shang;
            NSInteger right = shang;
            if (yu == 1) {
                if (indexX >= left + 1) {
                    left = shang + 1;
                }else {
                    right = shang + 1;
                }
            }
            NSRange leftRange = NSMakeRange(indexX - left, left);
            NSString *leftStr = [textContent safeSubstringWithRange:leftRange];
            NSRange rightRange = NSMakeRange(indexX + _searchStr.length, right);
            NSString *rightStr = [textContent safeSubstringWithRange:rightRange];
            return [NSString stringWithFormat:@"...%@%@%@...",leftStr,_searchStr,rightStr];
        }
        
    }
    return nil;
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
