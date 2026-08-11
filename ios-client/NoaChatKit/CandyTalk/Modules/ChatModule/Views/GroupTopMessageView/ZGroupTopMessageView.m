//
//  ZGroupTopMessageView.m
//  NoaChatKit
//
//  Created by Auto on 2025/1/15.
//

#import "ZGroupTopMessageView.h"
#import "NoaToolManager.h"
#import "NoaChatInputEmojiManager.h"
#import "NoaUserManager.h"
#import "NSMutableAttributedString+Addition.h"
#import "NoaMessageTools.h"

@interface ZGroupTopMessageView ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *leftIndicatorView; // 左侧竖条容器
@property (nonatomic, strong) UIView *barsContainer; // 竖条容器（用于垂直居中）
@property (nonatomic, strong) NSMutableArray<UIView *> *indicatorBars; // 动态创建的竖条数组
@property (nonatomic, strong) UIView *singleIndicatorBar; // 单条数据时的竖条
@property (nonatomic, strong) UILabel *topLabel; // 置顶消息标签
@property (nonatomic, strong) UIView *contentContainerView; // 内容容器（用于轮播效果）
@property (nonatomic, strong) YYLabel *contentLabel; // 当前内容展示
@property (nonatomic, strong) YYLabel *nextContentLabel; // 下一个内容展示（用于轮播）
@property (nonatomic, strong) UIButton *listButton; // 消息列表按钮
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture; // 滑动手势
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture; // 点击手势

@property (nonatomic, strong) NSArray<NSDictionary *> *dataArray;
@property (nonatomic, assign) NSInteger currentIndex; // 当前显示的数据索引
@property (nonatomic, assign) CGFloat panOffset; // 滑动过程中的偏移量
@property (nonatomic, copy) NSString *sessionID; // 会话ID，用于查询数据库

// 动画控制相关
@property (nonatomic, strong) UIViewPropertyAnimator *currentAnimator; // 当前正在进行的动画
@property (nonatomic, assign) NSInteger pendingTargetIndex; // 待切换的目标索引（用于防抖）

@end

@implementation ZGroupTopMessageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.indicatorBars = [NSMutableArray array];
        self.pendingTargetIndex = -1; // 初始化为无效值
        [self setupUI];
        self.hidden = YES;
    }
    return self;
}

- (void)setupUI {
    // 容器 View
    self.containerView = [[UIView alloc] init];
    self.containerView.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
    self.containerView.layer.cornerRadius = DWScale(8);
    self.containerView.layer.masksToBounds = YES;
    self.containerView.layer.borderWidth = 0.5;
    self.containerView.layer.tkThemeborderColors = @[[COLOR_737780 colorWithAlphaComponent:0.1], [COLOR_737780_DARK colorWithAlphaComponent:0.1]];
    [self addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    // 左侧竖条指示器容器
    self.leftIndicatorView = [[UIView alloc] init];
    [self.containerView addSubview:self.leftIndicatorView];
    [self.leftIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.containerView).offset(DWScale(12));
        make.top.equalTo(self.containerView).offset(DWScale(6));
        make.bottom.equalTo(self.containerView).offset(DWScale(-6));
        make.width.mas_equalTo(DWScale(2));
    }];
    
    // 单条数据时的竖条
    self.singleIndicatorBar = [[UIView alloc] init];
    self.singleIndicatorBar.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    self.singleIndicatorBar.layer.cornerRadius = DWScale(2);
    self.singleIndicatorBar.hidden = YES;
    [self.leftIndicatorView addSubview:self.singleIndicatorBar];
    [self.singleIndicatorBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.leftIndicatorView);
    }];
    
    // 置顶消息标签
    self.topLabel = [[UILabel alloc] init];
    self.topLabel.text = LanguageToolMatch(@"置顶消息");
    self.topLabel.tkThemetextColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    self.topLabel.font = FONTN(12);
    [self.containerView addSubview:self.topLabel];
    [self.topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.leftIndicatorView.mas_trailing).offset(DWScale(8));
        make.top.equalTo(self.containerView).offset(DWScale(4));
        make.height.mas_equalTo(DWScale(17));
    }];
    
    // 内容容器（用于轮播效果）
    self.contentContainerView = [[UIView alloc] init];
    self.contentContainerView.clipsToBounds = YES;
    [self.containerView addSubview:self.contentContainerView];
    [self.contentContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.topLabel);
        make.top.equalTo(self.topLabel.mas_bottom).offset(DWScale(2));
        make.trailing.equalTo(self.containerView).offset(DWScale(-52));
        make.height.mas_equalTo(DWScale(20));
    }];
    
    // 当前内容展示
    self.contentLabel = [[YYLabel alloc] init];
    self.contentLabel.font = FONTN(14);
    self.contentLabel.numberOfLines = 1;
    self.contentLabel.userInteractionEnabled = YES;
    self.contentLabel.backgroundColor = COLOR_CLEAR;
    [self.contentContainerView addSubview:self.contentLabel];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.contentContainerView);
        make.top.bottom.equalTo(self.contentContainerView);
    }];
    
    // 下一个内容展示（用于轮播）
    self.nextContentLabel = [[YYLabel alloc] init];
    self.nextContentLabel.font = FONTN(14);
    self.nextContentLabel.numberOfLines = 1;
    self.nextContentLabel.userInteractionEnabled = YES;
    self.nextContentLabel.backgroundColor = COLOR_CLEAR;
    self.nextContentLabel.alpha = 0;
    [self.contentContainerView addSubview:self.nextContentLabel];
    [self.nextContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.contentContainerView);
        make.top.bottom.equalTo(self.contentContainerView);
    }];
    
    // 消息列表按钮
    self.listButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.listButton setImage:ImgNamed(@"chat_group_message_top_btn") forState:UIControlStateNormal];
    [self.listButton addTarget:self action:@selector(listButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.listButton];
    [self.listButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.containerView).offset(DWScale(-12));
        make.top.equalTo(self.containerView).offset(DWScale(12));
        make.bottom.equalTo(self.containerView).offset(DWScale(-12));
        make.width.height.mas_equalTo(DWScale(24));
    }];
    
    // 滑动手势（多条数据时启用）
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    self.panGesture.enabled = NO;
    [self addGestureRecognizer:self.panGesture]; // 滑动区域是整个 ZGroupTopMessageView
    
    // 点击手势（用于定位消息）
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:self.tapGesture];
    
    // 确保点击手势和滑动手势可以同时识别
    [self.tapGesture requireGestureRecognizerToFail:self.panGesture];
}

// 根据数量计算每个竖条的高度
// 容器总高度48，leftIndicatorView上下各6，所以可用高度 = 48 - 12 = 36
// 竖条之间间距固定为2
// 5条及以上时，只显示5个竖条
- (CGFloat)indicatorHeightForCount:(NSInteger)count {
    if (count == 1) {
        // 单条：使用整个容器高度（在 setupUI 中已设置 edges）
        return 0; // 返回0表示使用 edges 约束
    } else {
        // 多条：计算每个竖条的高度
        // 5条及以上时，只显示5个竖条
        NSInteger displayCount = count > 5 ? 5 : count;
        // 总高度 = displayCount * barHeight + (displayCount - 1) * spacing = 36
        // barHeight = (36 - (displayCount - 1) * 2) / displayCount
        CGFloat spacing = DWScale(2);
        CGFloat availableHeight = DWScale(48) - DWScale(12); // 总高度减去上下边距
        CGFloat totalSpacing = (displayCount - 1) * spacing;
        CGFloat barHeight = (availableHeight - totalSpacing) / displayCount;
        return barHeight;
    }
}

// 创建或更新竖条
- (void)updateIndicatorBarsForCount:(NSInteger)count {
    // 清除旧的竖条和容器
    for (UIView *bar in self.indicatorBars) {
        [bar removeFromSuperview];
    }
    [self.indicatorBars removeAllObjects];
    
    if (self.barsContainer) {
        [self.barsContainer removeFromSuperview];
        self.barsContainer = nil;
    }
    
    if (count == 1) {
        // 单条数据：显示单条竖条
        self.singleIndicatorBar.hidden = NO;
        self.panGesture.enabled = NO;
        return;
    }
    
    // 多条数据：隐藏单条竖条，动态创建多个竖条
    self.singleIndicatorBar.hidden = YES;
    self.panGesture.enabled = YES;
    
    // 5条及以上时，只显示5个竖条
    NSInteger displayCount = count > 5 ? 5 : count;
    
    CGFloat barHeight = [self indicatorHeightForCount:count];
    CGFloat spacing = DWScale(2); // 竖条之间间距
    CGFloat totalHeight = displayCount * barHeight + (displayCount - 1) * spacing;
    
    // 创建一个容器 view 来垂直居中所有竖条
    self.barsContainer = [[UIView alloc] init];
    [self.leftIndicatorView addSubview:self.barsContainer];
    [self.barsContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.leftIndicatorView);
        make.leading.trailing.equalTo(self.leftIndicatorView);
        make.height.mas_equalTo(totalHeight);
    }];
    
    UIView *previousBar = nil;
    for (NSInteger i = 0; i < displayCount; i++) {
        UIView *bar = [[UIView alloc] init];
        bar.tkThemebackgroundColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.3], [COLOR_5966F2_DARK colorWithAlphaComponent:0.3]];
        bar.layer.cornerRadius = DWScale(2);
        [self.barsContainer addSubview:bar];
        [self.indicatorBars addObject:bar];
        
        [bar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.barsContainer);
            make.width.mas_equalTo(DWScale(2));
            make.height.mas_equalTo(barHeight);
            if (i == 0) {
                make.top.equalTo(self.barsContainer);
            } else {
                make.top.equalTo(previousBar.mas_bottom).offset(spacing);
            }
        }];
        
        previousBar = bar;
    }
}

- (void)updateWithTopMessages:(NSArray<NSDictionary *> *)dataArray sessionID:(NSString *)sessionID {
    self.dataArray = dataArray;
    self.sessionID = sessionID;
    
    if (!dataArray || dataArray.count == 0) {
        [self setHidden:YES animated:YES];
        return;
    }
    
    [self setHidden:NO animated:YES];
    
    // 更新左侧指示器
    [self updateIndicatorBarsForCount:dataArray.count];
    
    // 重置当前索引和偏移量
    self.currentIndex = 0;
    self.panOffset = 0;
    
    // 重置两个 label 的状态
    self.contentLabel.transform = CGAffineTransformIdentity;
    self.contentLabel.alpha = 1;
    self.nextContentLabel.transform = CGAffineTransformIdentity;
    self.nextContentLabel.alpha = 0;
    
    // 更新指示器高亮和内容显示
    [self updateIndicatorHighlight];
    [self updateContentDisplay];
}

/// 根据 data 获取要展示的内容（富文本）
- (NSMutableAttributedString *)getDisplayContentFromData:(NSDictionary *)data {
    if (!data) {
        return nil;
    }
    
    NSString *smsgId = [data objectForKeySafe:@"smsgId"];
    NSString *displayText = @"";
    
    // 如果有 sessionID 和 smsgId，尝试从数据库查询消息
    if (self.sessionID.length > 0 && smsgId.length > 0) {
        NoaIMChatMessageModel *messageModel = [IMSDKManager toolGetOneChatMessageWithServiceMessageID:smsgId sessionID:self.sessionID];
        
        if (messageModel) {
            // 找到了数据库中的消息
            BOOL isSelf = [messageModel.fromID isEqualToString:UserManager.userInfo.userUID];
            
            // 计算 showContent 和 showTranslateContent
            if (messageModel.messageType == CIMChatMessageType_AtMessage) {
                // @消息：需要转换 \vUid\v 为 @昵称
                // 计算 showContent
                if ([NSString isNil:messageModel.showContent]) {
                    if (isSelf) {
                        messageModel.showContent = [NoaMessageTools atContenTranslateToShowContent:![NSString isNil:messageModel.atContent] ? messageModel.atContent : @"" atUsersDictList:messageModel.atUsersInfoList withMessage:messageModel isGetShowName:YES];
                    } else {
                        messageModel.showContent = [NoaMessageTools atContenTranslateToShowContent:![NSString isNil:messageModel.atTranslateContent] ? messageModel.atTranslateContent : messageModel.atContent atUsersDictList:messageModel.atUsersInfoList withMessage:messageModel isGetShowName:YES];
                    }
                }
                
                // 计算 showTranslateContent
                if ([NSString isNil:messageModel.showTranslateContent]) {
                    if (isSelf) {
                        messageModel.showTranslateContent = [NoaMessageTools atContenTranslateToShowContent:![NSString isNil:messageModel.atTranslateContent] ? messageModel.atTranslateContent : @"" atUsersDictList:messageModel.atUsersInfoList withMessage:messageModel isGetShowName:YES];
                    } else {
                        messageModel.showTranslateContent = [NoaMessageTools atContenTranslateToShowContent:![NSString isNil:messageModel.againAtTranslateContent] ? messageModel.againAtTranslateContent : messageModel.atTranslateContent atUsersDictList:messageModel.atUsersInfoList withMessage:messageModel isGetShowName:YES];
                    }
                }
            } else if (messageModel.messageType == CIMChatMessageType_TextMessage) {
                // 文本消息：showContent 是原文，showTranslateContent 是译文
                // 计算 showContent（原文）
                if ([NSString isNil:messageModel.showContent]) {
                    // 无论是自己发的还是接收的，showContent 都是原文 textContent
                    messageModel.showContent = messageModel.textContent ?: @"";
                }
                
                // 计算 showTranslateContent（译文）
                if ([NSString isNil:messageModel.showTranslateContent]) {
                    if (isSelf) {
                        // 自己发的消息：showTranslateContent 就是 translateContent
                        messageModel.showTranslateContent = messageModel.translateContent ?: @"";
                    } else {
                        // 接收的消息：优先使用 againTranslateContent，其次使用 translateContent
                        if (![NSString isNil:messageModel.againTranslateContent]) {
                            messageModel.showTranslateContent = messageModel.againTranslateContent;
                        } else if (![NSString isNil:messageModel.translateContent]) {
                            messageModel.showTranslateContent = messageModel.translateContent;
                        } else {
                            messageModel.showTranslateContent = @"";
                        }
                    }
                }
            }
            
            // 判断是否有译文
            BOOL hasTranslation = NO;
            
            if (isSelf) {
                // 自己发的消息：检查 translateContent 或 atTranslateContent
                if (messageModel.messageType == CIMChatMessageType_AtMessage) {
                    hasTranslation = ![NSString isNil:messageModel.atTranslateContent];
                } else {
                    hasTranslation = ![NSString isNil:messageModel.translateContent];
                }
            } else {
                // 接收的消息：优先检查 againTranslateContent 或 againAtTranslateContent，其次检查 translateContent 或 atTranslateContent
                if (messageModel.messageType == CIMChatMessageType_AtMessage) {
                    hasTranslation = ![NSString isNil:messageModel.againAtTranslateContent] || ![NSString isNil:messageModel.atTranslateContent];
                } else {
                    hasTranslation = ![NSString isNil:messageModel.againTranslateContent] || ![NSString isNil:messageModel.translateContent];
                }
            }
            
            // 确定要展示的内容
            if (hasTranslation && messageModel.showTranslateContent.length > 0) {
                // 有译文，使用 showTranslateContent
                displayText = messageModel.showTranslateContent;
            } else if (messageModel.showContent.length > 0) {
                // 无译文或 showTranslateContent 为空，使用 showContent
                displayText = messageModel.showContent;
            } else {
                // showContent 也为空，使用原始内容
                if (messageModel.messageType == CIMChatMessageType_TextMessage) {
                    displayText = messageModel.textContent ?: @"";
                } else if (messageModel.messageType == CIMChatMessageType_AtMessage) {
                    displayText = messageModel.atContent ?: @"";
                }
            }
        }
    }
    
    // 如果数据库没有找到消息，或者 displayText 为空，使用 data.body.content
    if (displayText.length == 0) {
        NSString *bodyStr = [data objectForKeySafe:@"body"];
        if ([bodyStr isKindOfClass:[NSString class]]) {
            NSDictionary *bodyDict = [NSJSONSerialization JSONObjectWithData:[bodyStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            if ([bodyDict isKindOfClass:[NSDictionary class]]) {
                displayText = [bodyDict objectForKeySafe:@"content"] ?: @"";
            } else {
                displayText = bodyStr;
            }
        }
    }
    
    // 使用 yy_emojiAttributedString 转换文本为富文本
    NSMutableAttributedString *attributedString = [[NoaChatInputEmojiManager sharedManager] yy_emojiAttributedString:displayText];
    
    // 设置字体和颜色
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 2;
    NSDictionary *dict = @{
        NSFontAttributeName: FONTN(14),
        NSParagraphStyleAttributeName: [style copy]
    };
    
    if (attributedString) {
        [attributedString addAttributes:dict range:NSMakeRange(0, attributedString.length)];
        // 设置颜色（使用主题颜色方法）
        [attributedString configAttStrLightColor:COLOR_11 darkColor:COLOR_11_DARK range:NSMakeRange(0, attributedString.length)];
    } else {
        attributedString = [[NSMutableAttributedString alloc] initWithString:displayText attributes:dict];
        [attributedString configAttStrLightColor:COLOR_11 darkColor:COLOR_11_DARK range:NSMakeRange(0, attributedString.length)];
    }
    
    // 对文本进行截断处理，确保文本+省略号尽可能占满布局宽度
    attributedString = [self truncateAttributedString:attributedString toFitWidth:[self getAvailableContentWidth]];
    
    return attributedString;
}

/// 计算 contentLabel 的可用宽度
- (CGFloat)getAvailableContentWidth {
    // 如果 contentContainerView 已经有 frame，直接使用其宽度
    if (self.contentContainerView && self.contentContainerView.frame.size.width > 0) {
        return self.contentContainerView.frame.size.width;
    }
    
    // 如果还没有布局，使用约束计算：
    // contentContainerView 的约束：
    // leading = topLabel.leading (leftIndicatorView.trailing + 8)
    // trailing = containerView.trailing - 52 (右侧按钮宽度 + 间距)
    // 所以可用宽度 = 屏幕宽度 - 左右边距 - 左侧指示器区域 - 右侧按钮区域
    
    // 屏幕宽度
    CGFloat screenWidth = DScreenWidth;
    // 整个 view 的左右边距（各 16）
    CGFloat viewMargin = DWScale(16) * 2;
    // 左侧指示器区域：leftIndicatorView (2) + 间距 (8) = 10
    CGFloat leftIndicatorArea = DWScale(2) + DWScale(8);
    // 右侧按钮区域：约束中 trailing offset 是 -52
    CGFloat rightButtonArea = DWScale(52);
    
    // 可用宽度 = 屏幕宽度 - view 左右边距 - 左侧指示器区域 - 右侧按钮区域
    CGFloat availableWidth = screenWidth - viewMargin - leftIndicatorArea - rightButtonArea;
    
    return availableWidth;
}

/// 规范化 attributedString 中的空白字符：将所有换行符、回车符、制表符等替换为空格，合并连续空白为单个空格，并去除开头和结尾的空白
- (NSMutableAttributedString *)normalizeWhitespaceInAttributedString:(NSMutableAttributedString *)attributedString {
    if (!attributedString || attributedString.length == 0) {
        return attributedString;
    }
    
    // 创建空白字符集（包括换行符、回车符、制表符、空格等）
    NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    // 获取纯文本
    NSString *plainText = attributedString.string;
    
    // 第一步：使用正则表达式将所有空白字符（换行符、回车符、制表符等）替换为空格，并合并多个连续空白为单个空格
    // 正则表达式：匹配一个或多个空白字符（包括换行、回车、制表符、空格等）
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\s+" options:0 error:nil];
    NSString *normalizedText = [regex stringByReplacingMatchesInString:plainText options:0 range:NSMakeRange(0, plainText.length) withTemplate:@" "];
    
    // 第二步：去除开头和结尾的空白字符（空格）
    NSString *trimmedText = [normalizedText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // 如果去除空白后文本为空，返回空
    if (trimmedText.length == 0) {
        return [[NSMutableAttributedString alloc] initWithString:@""];
    }
    
    // 第三步：创建新的 attributedString，保持原有属性
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:trimmedText];
    
    // 复制原 attributedString 的属性到新文本
    // 由于文本已经被规范化，我们需要找到原文本中第一个非空白字符的属性，应用到整个新文本
    NSDictionary *attributes = nil;
    for (NSInteger i = 0; i < attributedString.length; i++) {
        unichar ch = [plainText characterAtIndex:i];
        if (![whitespaceCharacterSet characterIsMember:ch]) {
            // 找到第一个非空白字符，使用它的属性
            NSRange effectiveRange;
            attributes = [attributedString attributesAtIndex:i effectiveRange:&effectiveRange];
            if (attributes) {
                [result addAttributes:attributes range:NSMakeRange(0, result.length)];
            }
            break;
        }
    }
    
    // 如果没有找到非空白字符的属性，使用第一个字符的属性
    if (!attributes && attributedString.length > 0) {
        attributes = [attributedString attributesAtIndex:0 effectiveRange:NULL];
        if (attributes) {
            [result addAttributes:attributes range:NSMakeRange(0, result.length)];
        }
    }
    
    return result;
}

/// 截断 attributedString，使其文本+省略号的宽度尽可能接近但不超过可用宽度
- (NSMutableAttributedString *)truncateAttributedString:(NSMutableAttributedString *)attributedString toFitWidth:(CGFloat)maxWidth {
    if (!attributedString || attributedString.length == 0) {
        return attributedString;
    }
    
    // 获取字体（从 attributedString 中获取，如果没有则使用默认字体）
    UIFont *font = [attributedString attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
    if (!font) {
        font = FONTN(14);
    }
    
    // 使用 YYTextLayout 计算文本实际宽度（更准确，能处理 emoji 等特殊字符）
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(CGFLOAT_MAX, DWScale(20))];
    container.maximumNumberOfRows = 1;
    YYTextLayout *fullLayout = [YYTextLayout layoutWithContainer:container text:attributedString];
    CGFloat fullTextWidth = fullLayout.textBoundingSize.width;
    
    // 如果文本宽度小于等于可用宽度，不需要截断
    if (fullTextWidth <= maxWidth) {
        return attributedString;
    }
    
    // 计算省略号的宽度
    NSString *ellipsis = @"...";
    NSMutableAttributedString *ellipsisAttributedString = [[NSMutableAttributedString alloc] initWithString:ellipsis];
    NSDictionary *attributes = [attributedString attributesAtIndex:0 effectiveRange:NULL];
    [ellipsisAttributedString addAttributes:attributes range:NSMakeRange(0, ellipsisAttributedString.length)];
    
    YYTextContainer *ellipsisContainer = [YYTextContainer containerWithSize:CGSizeMake(CGFLOAT_MAX, DWScale(20))];
    ellipsisContainer.maximumNumberOfRows = 1;
    YYTextLayout *ellipsisLayout = [YYTextLayout layoutWithContainer:ellipsisContainer text:ellipsisAttributedString];
    CGFloat ellipsisWidth = ellipsisLayout.textBoundingSize.width;
    
    // 如果可用宽度小于省略号宽度，直接返回省略号
    if (maxWidth <= ellipsisWidth) {
        return ellipsisAttributedString;
    }
    
    // 使用二分查找找到最大可显示字符数
    NSInteger left = 0;
    NSInteger right = attributedString.length;
    NSInteger bestLength = 0;
    
    // 获取底层字符串，用于安全截断
    NSString *plainString = attributedString.string;
    
    // 辅助方法：确保截断位置不会在 emoji 中间
    NSInteger (^safeTruncateIndex)(NSInteger) = ^NSInteger(NSInteger index) {
        if (index <= 0) {
            return 0;
        }
        if (index >= plainString.length) {
            return plainString.length;
        }
        // 使用 rangeOfComposedCharacterSequenceAtIndex 确保不会在 emoji 中间截断
        // 如果 index 在某个 composed character sequence 中间，调整到该序列的结束位置
        NSRange composedRange = [plainString rangeOfComposedCharacterSequenceAtIndex:index];
        // 如果 index 正好在 composedRange 的开始，返回该位置
        if (composedRange.location == index) {
            return index;
        }
        // 如果 index 在 composedRange 中间，调整到 composedRange 的开始（避免截断 emoji）
        if (composedRange.location < index && index < NSMaxRange(composedRange)) {
            return composedRange.location;
        }
        // 如果 index 在 composedRange 的结束位置之后，检查前一个字符
        if (index > 0) {
            NSRange prevComposedRange = [plainString rangeOfComposedCharacterSequenceAtIndex:index - 1];
            if (NSMaxRange(prevComposedRange) > index) {
                // index 在前一个字符序列中间，调整到前一个序列的结束
                return prevComposedRange.location;
            }
        }
        return index;
    };
    
    while (left <= right) {
        NSInteger mid = (left + right) / 2;
        
        // 确保 mid 不会在 emoji 中间截断
        NSInteger safeMid = safeTruncateIndex(mid);
        
        // 创建截断后的 attributedString（包含省略号）
        NSMutableAttributedString *testAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[attributedString attributedSubstringFromRange:NSMakeRange(0, safeMid)]];
        [testAttributedString appendAttributedString:ellipsisAttributedString];
        
        // 计算宽度
        YYTextContainer *testContainer = [YYTextContainer containerWithSize:CGSizeMake(CGFLOAT_MAX, DWScale(20))];
        testContainer.maximumNumberOfRows = 1;
        YYTextLayout *testLayout = [YYTextLayout layoutWithContainer:testContainer text:testAttributedString];
        CGFloat testWidth = testLayout.textBoundingSize.width;
        
        if (testWidth <= maxWidth) {
            // 可以显示更多字符
            bestLength = safeMid;
            left = mid + 1;
        } else {
            // 超出宽度，减少字符数
            right = mid - 1;
        }
    }
    
    // 如果 bestLength 为 0，至少显示省略号
    if (bestLength == 0) {
        return ellipsisAttributedString;
    }
    
    // 再次确保 bestLength 不会在 emoji 中间截断
    NSInteger safeBestLength = safeTruncateIndex(bestLength);
    
    // 创建截断后的 attributedString
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithAttributedString:[attributedString attributedSubstringFromRange:NSMakeRange(0, safeBestLength)]];
    [result appendAttributedString:ellipsisAttributedString];
    
    return result;
}

- (void)updateContentDisplay {
    // 更新当前内容
    if (self.currentIndex < self.dataArray.count) {
        NSDictionary *data = self.dataArray[self.currentIndex];
        NSMutableAttributedString *attributedString = [self getDisplayContentFromData:data];
        if (attributedString) {
            self.contentLabel.attributedText = attributedString;
        } else {
            self.contentLabel.attributedText = nil;
        }
    } else {
        self.contentLabel.attributedText = nil;
    }
    
    // 更新下一个内容（用于轮播预览）
    [self updateNextContent];
}

- (void)updateNextContent {
    // 根据当前索引和滑动方向，确定下一个要显示的内容
    NSInteger nextIndex = -1;
    if (self.panOffset < 0) {
        // 向上滑动，显示下一条
        nextIndex = self.currentIndex + 1;
    } else if (self.panOffset > 0) {
        // 向下滑动，显示上一条
        nextIndex = self.currentIndex - 1;
    }
    
    if (nextIndex >= 0 && nextIndex < self.dataArray.count) {
        NSDictionary *data = self.dataArray[nextIndex];
        NSMutableAttributedString *attributedString = [self getDisplayContentFromData:data];
        if (attributedString) {
            self.nextContentLabel.attributedText = attributedString;
        } else {
            self.nextContentLabel.attributedText = nil;
        }
    } else {
        self.nextContentLabel.attributedText = nil;
    }
}

- (void)updateIndicatorHighlight {
    if (self.dataArray.count == 1) {
        // 单条数据：单条竖条始终高亮
        return;
    }
    
    // 多条数据：当前索引的竖条高亮，其他半透明
    // 如果数据超过5条，竖条只显示5个，需要映射当前索引到竖条索引
    NSInteger totalCount = self.dataArray.count;
    NSInteger displayCount = totalCount > 5 ? 5 : totalCount;
    
    // 计算当前索引对应的竖条索引
    NSInteger barIndex = self.currentIndex;
    if (totalCount > 5) {
        // 超过5条时，将当前索引映射到0-4的范围
        // 例如：6条数据，索引0-4对应竖条0-4，索引5对应竖条4（最后一个）
        if (self.currentIndex < displayCount) {
            barIndex = self.currentIndex;
        } else {
            // 当前索引在5及以上，高亮最后一个竖条
            barIndex = displayCount - 1;
        }
    }
    
    for (NSInteger i = 0; i < self.indicatorBars.count; i++) {
        UIView *bar = self.indicatorBars[i];
        if (i == barIndex) {
            // 当前索引对应的竖条：高亮
            bar.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
        } else {
            // 其他竖条：半透明
            bar.tkThemebackgroundColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.3], [COLOR_5966F2_DARK colorWithAlphaComponent:0.3]];
        }
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    if (self.dataArray.count <= 1) {
        return;
    }
    
    CGPoint translation = [gesture translationInView:self];
    CGFloat contentHeight = DWScale(20); // 内容高度
    CGFloat threshold = contentHeight * 0.5; // 滑动阈值：内容高度的一半
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        // 开始滑动，重置偏移量
        self.panOffset = 0;
        [self updateNextContent];
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        // 滑动过程中，实时更新两个 label 的位置和透明度
        self.panOffset = translation.y;
        
        // 限制滑动范围
        CGFloat maxOffset = contentHeight;
        if (self.panOffset < 0 && self.currentIndex + 1 >= self.dataArray.count) {
            // 已经到最后一条，不允许继续向上滑动
            self.panOffset = 0;
        } else if (self.panOffset > 0 && self.currentIndex - 1 < 0) {
            // 已经是第一条，不允许继续向下滑动
            self.panOffset = 0;
        } else {
            // 限制滑动距离
            if (self.panOffset < -maxOffset) {
                self.panOffset = -maxOffset;
            } else if (self.panOffset > maxOffset) {
                self.panOffset = maxOffset;
            }
        }
        
        // 更新下一个内容
        [self updateNextContent];
        
        // 计算进度（0-1）
        CGFloat progress = fabs(self.panOffset) / maxOffset;
        progress = MIN(progress, 1.0);
        
        // 更新当前 label 的位置和透明度
        CGAffineTransform currentTransform = CGAffineTransformMakeTranslation(0, self.panOffset);
        self.contentLabel.transform = currentTransform;
        self.contentLabel.alpha = 1.0 - progress * 0.5; // 逐渐变淡
        
        // 更新下一个 label 的位置和透明度
        if (self.panOffset < 0) {
            // 向上滑动，下一个内容从下方移入
            CGAffineTransform nextTransform = CGAffineTransformMakeTranslation(0, contentHeight + self.panOffset);
            self.nextContentLabel.transform = nextTransform;
            self.nextContentLabel.alpha = progress * 0.5 + 0.5; // 逐渐显示
        } else if (self.panOffset > 0) {
            // 向下滑动，下一个内容从上方移入
            CGAffineTransform nextTransform = CGAffineTransformMakeTranslation(0, -contentHeight + self.panOffset);
            self.nextContentLabel.transform = nextTransform;
            self.nextContentLabel.alpha = progress * 0.5 + 0.5; // 逐渐显示
        } else {
            // 没有滑动，隐藏下一个 label
            self.nextContentLabel.alpha = 0;
        }
        
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        // 滑动结束，判断是否切换
        BOOL shouldSwitch = NO;
        NSInteger targetIndex = self.currentIndex;
        
        if (fabs(self.panOffset) > threshold) {
            // 滑动距离超过阈值，执行切换
            shouldSwitch = YES;
            if (self.panOffset < 0) {
                // 向上滑动，切换到下一条
                targetIndex = self.currentIndex + 1;
                if (targetIndex >= self.dataArray.count) {
                    targetIndex = self.currentIndex;
                    shouldSwitch = NO;
                }
            } else if (self.panOffset > 0) {
                // 向下滑动，切换到上一条
                targetIndex = self.currentIndex - 1;
                if (targetIndex < 0) {
                    targetIndex = self.currentIndex;
                    shouldSwitch = NO;
                }
            }
        }
        
        if (shouldSwitch && targetIndex != self.currentIndex) {
            // 直接完成切换，不需要额外动画（因为滑动过程中已经完成了视觉切换）
            [self completeSwitchToIndex:targetIndex];
        } else {
            // 回弹到当前位置
            [self resetContentPosition];
        }
        
        // 重置偏移量
        self.panOffset = 0;
    }
}

- (void)resetContentPosition {
    [UIView animateWithDuration:0.25 animations:^{
        self.contentLabel.transform = CGAffineTransformIdentity;
        self.contentLabel.alpha = 1.0;
        self.nextContentLabel.transform = CGAffineTransformIdentity;
        self.nextContentLabel.alpha = 0;
    }];
}

- (void)completeSwitchToIndex:(NSInteger)index {
    // 直接完成切换，不需要动画（因为滑动过程中已经完成了视觉切换）
    if (index < 0 || index >= self.dataArray.count || index == self.currentIndex) {
        return;
    }
    
    self.currentIndex = index;
    
    // 更新 contentLabel 的内容
    NSDictionary *newData = self.dataArray[index];
    NSMutableAttributedString *attributedString = [self getDisplayContentFromData:newData];
    if (attributedString) {
        self.contentLabel.attributedText = attributedString;
    } else {
        self.contentLabel.attributedText = nil;
    }
    
    // 直接更新内容，不需要动画
    self.contentLabel.transform = CGAffineTransformIdentity;
    self.contentLabel.alpha = 1;
    self.nextContentLabel.transform = CGAffineTransformIdentity;
    self.nextContentLabel.alpha = 0;
    self.nextContentLabel.attributedText = nil;
    
    // 更新指示器高亮
    [self updateIndicatorHighlight];
}

- (void)switchToIndex:(NSInteger)index animated:(BOOL)animated {
    if (index < 0 || index >= self.dataArray.count || index == self.currentIndex) {
        return;
    }
    
    // 取消之前正在进行的动画
    if (self.currentAnimator && self.currentAnimator.isRunning) {
        [self.currentAnimator stopAnimation:YES];
        [self.currentAnimator finishAnimationAtPosition:UIViewAnimatingPositionCurrent];
        self.currentAnimator = nil;
    }
    
    // 如果之前有动画被取消，需要先重置状态
    [self.layer removeAllAnimations];
    [self.contentLabel.layer removeAllAnimations];
    [self.nextContentLabel.layer removeAllAnimations];
    
    NSInteger oldIndex = self.currentIndex;
    self.currentIndex = index;
    
    // 更新下一个 label 的内容为新的当前内容
    NSDictionary *newData = self.dataArray[index];
    NSMutableAttributedString *attributedString = [self getDisplayContentFromData:newData];
    if (attributedString) {
        self.nextContentLabel.attributedText = attributedString;
    } else {
        self.nextContentLabel.attributedText = nil;
    }
    
    CGFloat contentHeight = DWScale(20);
    BOOL isMovingUp = index > oldIndex; // 向上切换
    
    if (animated) {
        // 轮播动画效果
        if (isMovingUp) {
            // 向上切换：当前内容向上移出，新内容从下方移入
            self.nextContentLabel.transform = CGAffineTransformMakeTranslation(0, contentHeight);
            self.nextContentLabel.alpha = 0;
        } else {
            // 向下切换：当前内容向下移出，新内容从上方移入
            self.nextContentLabel.transform = CGAffineTransformMakeTranslation(0, -contentHeight);
            self.nextContentLabel.alpha = 0;
        }
        
        // 保存目标索引，用于 completion 回调中获取正确的数据
        NSInteger targetIndex = index;
        
        // 使用 UIViewPropertyAnimator 以便可以取消
        self.currentAnimator = [[UIViewPropertyAnimator alloc] initWithDuration:0.3 curve:UIViewAnimationCurveEaseInOut animations:^{
            if (isMovingUp) {
                // 当前内容向上移出
                self.contentLabel.transform = CGAffineTransformMakeTranslation(0, -contentHeight);
                // 新内容从下方移入
                self.nextContentLabel.transform = CGAffineTransformIdentity;
            } else {
                // 当前内容向下移出
                self.contentLabel.transform = CGAffineTransformMakeTranslation(0, contentHeight);
                // 新内容从上方移入
                self.nextContentLabel.transform = CGAffineTransformIdentity;
            }
            self.contentLabel.alpha = 0;
            self.nextContentLabel.alpha = 1;
        }];
        
        __weak typeof(self) weakSelf = self;
        [self.currentAnimator addCompletion:^(UIViewAnimatingPosition finalPosition) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            // 检查动画是否完成且目标索引仍然有效
            if (finalPosition == UIViewAnimatingPositionEnd &&
                targetIndex >= 0 &&
                targetIndex < strongSelf.dataArray.count &&
                targetIndex == strongSelf.currentIndex) {
                
                // 直接从 dataArray 获取目标数据，而不是依赖 nextContentLabel
                NSDictionary *targetData = strongSelf.dataArray[targetIndex];
                NSMutableAttributedString *targetAttributedString = [strongSelf getDisplayContentFromData:targetData];
                
                // 在同一帧内更新内容和重置状态，避免闪烁
                [UIView performWithoutAnimation:^{
                    if (targetAttributedString) {
                        strongSelf.contentLabel.attributedText = targetAttributedString;
                    } else {
                        strongSelf.contentLabel.attributedText = nil;
                    }
                    strongSelf.contentLabel.transform = CGAffineTransformIdentity;
                    strongSelf.contentLabel.alpha = 1;
                    strongSelf.nextContentLabel.transform = CGAffineTransformIdentity;
                    strongSelf.nextContentLabel.alpha = 0;
                    strongSelf.nextContentLabel.attributedText = nil; // 清空下一个 label 的内容
                }];
                
                // 更新指示器高亮
                [strongSelf updateIndicatorHighlight];
            } else {
                // 动画被取消或目标索引已改变，重置状态
                [UIView performWithoutAnimation:^{
                    // 确保显示当前索引对应的内容
                    if (strongSelf.currentIndex >= 0 && strongSelf.currentIndex < strongSelf.dataArray.count) {
                        NSDictionary *currentData = strongSelf.dataArray[strongSelf.currentIndex];
                        NSMutableAttributedString *currentAttributedString = [strongSelf getDisplayContentFromData:currentData];
                        if (currentAttributedString) {
                            strongSelf.contentLabel.attributedText = currentAttributedString;
                        } else {
                            strongSelf.contentLabel.attributedText = nil;
                        }
                    }
                    strongSelf.contentLabel.transform = CGAffineTransformIdentity;
                    strongSelf.contentLabel.alpha = 1;
                    strongSelf.nextContentLabel.transform = CGAffineTransformIdentity;
                    strongSelf.nextContentLabel.alpha = 0;
                    strongSelf.nextContentLabel.attributedText = nil;
                }];
                [strongSelf updateIndicatorHighlight];
            }
            
            strongSelf.currentAnimator = nil;
        }];
        
        [self.currentAnimator startAnimation];
    } else {
        // 无动画，直接更新
        [self updateContentDisplay];
        [self updateIndicatorHighlight];
        self.contentLabel.transform = CGAffineTransformIdentity;
        self.contentLabel.alpha = 1;
        self.nextContentLabel.transform = CGAffineTransformIdentity;
        self.nextContentLabel.alpha = 0;
    }
}

- (void)listButtonAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(groupTopMessageViewDidClickListButton:)]) {
        [self.delegate groupTopMessageViewDidClickListButton:self];
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture {
    // 排除点击列表按钮的情况
    CGPoint location = [gesture locationInView:self.containerView];
    if (CGRectContainsPoint(self.listButton.frame, location)) {
        // 点击的是列表按钮，不处理（列表按钮会自己处理点击事件）
        return;
    }
    
    // 获取点击位置相对于整个 view 的坐标
    CGPoint locationInView = [gesture locationInView:self];
    CGFloat viewHeight = CGRectGetHeight(self.bounds);
    CGFloat midY = viewHeight / 2.0;
    
    // 判断点击位置是上部分还是下部分
    BOOL isUpperPart = locationInView.y < midY;
    
    if (isUpperPart) {
        // 点击上部分：切换到上一条消息，然后定位
        [self handleUpperPartTap];
    } else {
        // 点击下部分：直接定位当前消息
        if (self.delegate && [self.delegate respondsToSelector:@selector(groupTopMessageViewDidClickView:)]) {
            [self.delegate groupTopMessageViewDidClickView:self];
        }
    }
}

// 处理点击上部分的逻辑（内部方法，实际执行切换）
- (void)performUpperPartTap {
    // 边界情况：如果没有数据，直接返回
    if (self.dataArray.count == 0) {
        return;
    }
    
    // 如果只有一条消息，直接定位
    if (self.dataArray.count == 1) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(groupTopMessageViewDidClickView:)]) {
            [self.delegate groupTopMessageViewDidClickView:self];
        }
        return;
    }
    
    // 计算上一条消息的索引
    NSInteger previousIndex = self.currentIndex - 1;
    if (previousIndex < 0) {
        // 当前是第一个，循环到最后一个
        previousIndex = self.dataArray.count - 1;
    }
    
    // 更新待切换的目标索引（用于防抖）
    self.pendingTargetIndex = previousIndex;
    
    // 切换到上一条消息（带动画）
    [self switchToIndex:previousIndex animated:YES];
    
    // 切换完成后，定位到切换后的消息
    // 使用延迟确保动画完成后再定位
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 检查目标索引是否仍然有效（防止快速点击导致的状态不一致）
        if (self.pendingTargetIndex >= 0 &&
            self.pendingTargetIndex < self.dataArray.count &&
            self.pendingTargetIndex == self.currentIndex) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(groupTopMessageViewDidClickView:)]) {
                [self.delegate groupTopMessageViewDidClickView:self];
            }
        }
        self.pendingTargetIndex = -1; // 重置
    });
}

// 处理点击上部分的逻辑（带防抖）
- (void)handleUpperPartTap {
    // 取消之前的延迟执行（防抖：如果快速点击，只执行最后一次）
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performUpperPartTap) object:nil];
    
    // 延迟执行，如果快速点击会取消之前的延迟
    [self performSelector:@selector(performUpperPartTap) withObject:nil afterDelay:0.1];
}

- (NSString *)currentSmsgId {
    if (self.currentIndex >= 0 && self.currentIndex < self.dataArray.count) {
        NSDictionary *data = self.dataArray[self.currentIndex];
        NSString *smsgId = [data objectForKeySafe:@"smsgId"];
        return smsgId ?: @"";
    }
    return @"";
}

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = hidden ? 0 : 1;
        } completion:^(BOOL finished) {
            self.hidden = hidden;
        }];
    } else {
        self.hidden = hidden;
    }
}

@end

