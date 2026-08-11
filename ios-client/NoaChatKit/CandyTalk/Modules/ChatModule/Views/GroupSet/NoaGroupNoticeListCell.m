//
//  NoaGroupNoticeListCell.m
//  NoaKit
//
//  Created by phl on 2025/8/11.
//

#import "NoaGroupNoticeListCell.h"
#import "NoaGroupNoteLocalUserNameModel.h"

@interface NoaGroupNoticeListCell()

@property (nonatomic, strong) UIView *bgView;

/// 置顶label(使用UIButton,主要是为了内边距)
@property (nonatomic, strong) UIButton *topStateButton;

/// 群公告文字展示
@property (nonatomic, strong) UITextView *textView;

/// 发送群公告的用户名称
@property (nonatomic, strong) UILabel *creatUserNameLabel;

/// 创建群公告的时间
@property (nonatomic, strong) UILabel *creatTimeLabel;

@end

@implementation NoaGroupNoticeListCell

- (void)setGroupModel:(NoaGroupNoteLocalUserNameModel *)groupModel {
    if (!groupModel) {
        self.textView.text = @"";
        self.creatUserNameLabel.text = @"";
        self.creatTimeLabel.text = @"";
        return;
    }
    
    _groupModel = groupModel;
    
    //处理公告文字内容（优先展示翻译）
    self.textView.text = _groupModel.showContent;
    
    // 公告创建人名称
    self.creatUserNameLabel.text = groupModel.noticeCreateNickname;
    
    // 公告创建时间
    NSString *createName = [NSString isNil:groupModel.createTime] ? @"" : groupModel.createTime;
    if (createName.length > 0) {
        NSString *createDataStr = [NSDate transTimeStrToDateMethod6:[createName longLongValue]];
        self.creatTimeLabel.text = createDataStr;
    }
    
    [self changeTopLayout:[_groupModel isTop]];
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [UIView new];
        _bgView.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
    }
    return _bgView;
}

- (UIButton *)topStateButton {
    if (!_topStateButton) {
        _topStateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_topStateButton setTitle:LanguageToolMatch(@"置顶") forState:UIControlStateNormal];
        _topStateButton.titleLabel.font = FONTR(11);
        [_topStateButton setTitleColor:COLOR_5966F2 forState:UIControlStateNormal];
        _topStateButton.titleLabel.tkThemetextColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
        _topStateButton.tkThemebackgroundColors = @[HEXACOLOR(@"4791FF", 0.2), HEXACOLOR(@"4791FF", 0.2)];
        _topStateButton.titleEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 16);
        _topStateButton.userInteractionEnabled = NO;
        _topStateButton.hidden = YES;
    }
    return _topStateButton;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [UITextView new];
        _textView.translatesAutoresizingMaskIntoConstraints = NO;
        _textView.userInteractionEnabled = NO;
        _textView.font = FONTR(14);
        _textView.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _textView.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
        _textView.textContainer.maximumNumberOfLines = 4;
        _textView.textContainer.lineFragmentPadding = 0.0;
        _textView.textContainerInset = UIEdgeInsetsZero;
        // 行高设置（通过段落样式）
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.minimumLineHeight = 20;
        paragraphStyle.maximumLineHeight = 20;
        if ([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"阿拉伯语"] ||
            [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"波斯语"]) {
            paragraphStyle.alignment = NSTextAlignmentRight;
        } else {
            paragraphStyle.alignment = NSTextAlignmentLeft;
        }
        _textView.typingAttributes = @{
            NSParagraphStyleAttributeName: paragraphStyle,
            NSFontAttributeName: FONTR(14),
        };
        
        _textView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
        // 禁止滑动
        _textView.scrollEnabled = NO;
    }
    return _textView;
}

- (UILabel *)creatUserNameLabel {
    if (!_creatUserNameLabel) {
        _creatUserNameLabel = [UILabel new];
        _creatUserNameLabel.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
        _creatUserNameLabel.font = FONTR(12);
        _creatUserNameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _creatUserNameLabel;
}

- (UILabel *)creatTimeLabel {
    if (!_creatTimeLabel) {
        _creatTimeLabel = [UILabel new];
        _creatTimeLabel.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
        _creatTimeLabel.font = FONTR(12);
        _creatTimeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _creatTimeLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setUpUI];
    }
    return self;
}

- (void)setUpUI {
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.topStateButton];
    [self.bgView addSubview:self.textView];
    [self.bgView addSubview:self.creatUserNameLabel];
    [self.bgView addSubview:self.creatTimeLabel];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@5);
        make.leading.equalTo(@16);
        make.trailing.equalTo(self.contentView).offset(-16);
        make.bottom.equalTo(self.contentView).offset(-5);
    }];
    
    CGFloat width = [self calculateButtonWidthForText:self.topStateButton.titleLabel.text font:self.topStateButton.titleLabel.font];
    [self.topStateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(self.bgView);
        make.height.equalTo(@20);
        make.width.equalTo(@(width));
    }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topStateButton.mas_bottom).offset(2);
        make.leading.equalTo(@16);
        make.trailing.equalTo(self.bgView).offset(-16);
    }];
    
    [self.creatUserNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textView.mas_bottom).offset(5);
        make.leading.equalTo(self.textView);
        make.height.equalTo(@12);
        make.bottom.equalTo(self.bgView).offset(-16);
    }];
    
    [self.creatTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.creatUserNameLabel);
        make.trailing.equalTo(self.textView);
        make.height.equalTo(@12);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 切圆角
        CAShapeLayer *topLabelLayer;
        if ([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"阿拉伯语"] ||
            [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"波斯语"]) {
            topLabelLayer = [self round:self.topStateButton.bounds TopLeft:0 TopRight:8.0 BottomLeft:14.0 BottomRight:0];
        } else {
            topLabelLayer = [self round:self.topStateButton.bounds TopLeft:8.0 TopRight:0 BottomLeft:0 BottomRight:14.0];
        }
        self.topStateButton.layer.mask = topLabelLayer;
        
        CAShapeLayer *bgViewLayer = [self configCornerRect:UIRectCornerAllCorners radius:8.0 rect:self.bgView.bounds];
        self.bgView.layer.mask = bgViewLayer;
    });
}

/// 根据用户置顶，展示不同布局
/// - Parameter isTop: 是否是置顶
- (void)changeTopLayout:(BOOL)isTop {
    self.topStateButton.hidden = !isTop;
    CGFloat height = [self.groupModel getTextViewHeight];
    if (isTop) {
        [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@5);
            make.leading.equalTo(@16);
            make.trailing.equalTo(self.contentView).offset(-16);
            make.bottom.equalTo(self.contentView).offset(-5);
        }];
        
        [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topStateButton.mas_bottom).offset(2);
            make.leading.equalTo(@16);
            make.height.equalTo(@(height));
            make.trailing.equalTo(self.bgView).offset(-16);
        }];
        
        NSLog(@"contentView = %@, textViewHeight = %f", NSStringFromCGRect(self.contentView.bounds), [self.groupModel getTextViewHeight]);
    }else {
        [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@5);
            make.leading.equalTo(@16);
            make.trailing.equalTo(self.contentView).offset(-16);
            make.bottom.equalTo(self.contentView).offset(-5);
        }];
        
        [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@16);
            make.leading.equalTo(@16);
            make.trailing.equalTo(self.bgView).offset(-16);
            make.height.equalTo(@(height));
        }];
        
        NSLog(@"contentView = %@, textViewHeight = %f", NSStringFromCGRect(self.contentView.bounds), height);
    }
    
    [self.bgView setNeedsLayout];
    [self.bgView layoutIfNeeded];
    
    NSLog(@"textView = %@", NSStringFromCGRect(self.textView.bounds));
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (CGRectIsEmpty(self.contentView.bounds)) {
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 切圆角
        CAShapeLayer *bgViewLayer = [self configCornerRect:UIRectCornerAllCorners radius:12.0 rect:self.bgView.bounds];
        self.bgView.layer.mask = bgViewLayer;
    });
}

/// 将控件画圆角
/// - Parameters:
///   - corners: 哪个角绘制圆角
///   - cornerRadius: 半径
///   - rect: 控件的frame
- (CAShapeLayer *)configCornerRect:(UIRectCorner)corners
                            radius:(CGFloat)cornerRadius
                              rect:(CGRect)rect {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = rect;
    maskLayer.path = maskPath.CGPath;
    return maskLayer;
}

- (CAShapeLayer *)roundCornersWithTopLeft:(CGFloat)topLeft
                                 topRight:(CGFloat)topRight
                               bottomLeft:(CGFloat)bottomLeft
                              bottomRight:(CGFloat)bottomRight {
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    // 左上角
    [path moveToPoint:CGPointMake(0, topLeft)];
    if (topLeft > 0) {
        [path addArcWithCenter:CGPointMake(topLeft, topLeft)
                        radius:topLeft
                    startAngle:M_PI
                      endAngle:M_PI * 1.5
                     clockwise:YES];
    } else {
        [path addLineToPoint:CGPointMake(0, 0)];
    }
    
    // 右上角
    [path addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) - topRight, 0)];
    if (topRight > 0) {
        [path addArcWithCenter:CGPointMake(CGRectGetWidth(self.bounds) - topRight, topRight)
                        radius:topRight
                    startAngle:M_PI * 1.5
                      endAngle:0
                     clockwise:YES];
    }
    
    // 右下角
    [path addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - bottomRight)];
    if (bottomRight > 0) {
        [path addArcWithCenter:CGPointMake(CGRectGetWidth(self.bounds) - bottomRight, CGRectGetHeight(self.bounds) - bottomRight)
                        radius:bottomRight
                    startAngle:0
                      endAngle:M_PI_2
                     clockwise:YES];
    }
    
    // 左下角
    [path addLineToPoint:CGPointMake(bottomLeft, CGRectGetHeight(self.bounds))];
    if (bottomLeft > 0) {
        [path addArcWithCenter:CGPointMake(bottomLeft, CGRectGetHeight(self.bounds) - bottomLeft)
                        radius:bottomLeft
                    startAngle:M_PI_2
                      endAngle:M_PI
                     clockwise:YES];
    }
    
    [path closePath];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = path.CGPath;
    return maskLayer;
}

// 计算文本宽度的方法
- (CGFloat)calculateButtonWidthForText:(NSString *)text font:(UIFont *)font {
    NSDictionary *attributes = @{NSFontAttributeName: font};
    CGSize size = [text sizeWithAttributes:attributes];
    CGFloat textWidth = size.width + 35; // 左右各16的内边距,多余出来一点
    return MIN(textWidth, 150); // 最大不超过150
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
