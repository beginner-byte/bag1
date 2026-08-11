//
//  NoaMessageGroupNoticeCell.m
//  NoaKit
//
//  Created by Candy on 2023/3/8.
//

// 40 + 文本高度 + 10

#import "NoaMessageGroupNoticeCell.h"

@implementation NoaMessageGroupNoticeCell
{
    UIView *_viewGroupNotice;
    UIImageView *_ivGroupNotice;
    UILabel *_lblGroupNoticeTip;
    UIView *_viewGroupNoticeLine;
    UILabel  *_lblGroupNotice;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupGroupNoticeUI];
    }
    return self;
}

#pragma mark - 界面布局
- (void)setupGroupNoticeUI {
    _viewGroupNotice = [UIView new];
    _viewGroupNotice.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_viewGroupNotice];
    
    _ivGroupNotice = [[UIImageView alloc] initWithImage:ImgNamed(@"g_notice_logo")];
    [_viewGroupNotice addSubview:_ivGroupNotice];
    [_ivGroupNotice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(_viewGroupNotice).offset(DWScale(10));
        make.size.mas_equalTo(CGSizeMake(DWScale(15), DWScale(15)));
    }];
    
    _lblGroupNoticeTip = [UILabel new];
    _lblGroupNoticeTip.text = [NSString stringWithFormat:@"%@:",LanguageToolMatch(@"群公告")];
    _lblGroupNoticeTip.tkThemetextColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    _lblGroupNoticeTip.font = FONTR(16);
    [_viewGroupNotice addSubview:_lblGroupNoticeTip];
    [_lblGroupNoticeTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_ivGroupNotice);
        make.leading.equalTo(_ivGroupNotice.mas_trailing).offset(DWScale(4));
    }];
    
    _viewGroupNoticeLine = [UIView new];
    _viewGroupNoticeLine.tkThemebackgroundColors = @[HEXCOLOR(@"0041A2"), HEXCOLOR(@"0041A2")];
    [_viewGroupNotice addSubview:_viewGroupNoticeLine];
    [_viewGroupNoticeLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewGroupNotice).offset(DWScale(10));
        make.top.equalTo(_viewGroupNotice).offset(DWScale(35));
        make.size.mas_equalTo(CGSizeMake(DWScale(230), 1));
    }];
    
    _lblGroupNotice = [UILabel new];
    _lblGroupNotice.numberOfLines = 4;
    _lblGroupNotice.preferredMaxLayoutWidth = DWScale(230);
    _lblGroupNotice.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    _lblGroupNotice.font = FONTR(16);
    _lblGroupNotice.lineBreakMode = NSLineBreakByTruncatingTail;
    [_viewGroupNotice addSubview:_lblGroupNotice];
    [_lblGroupNotice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewGroupNotice).offset(DWScale(10));
        make.top.equalTo(_viewGroupNotice).offset(DWScale(40));
        make.width.mas_equalTo(DWScale(230));
    }];
    
    UITapGestureRecognizer *tapGestureRecognizer = [UITapGestureRecognizer new];
    [_viewGroupNotice addGestureRecognizer:tapGestureRecognizer];
    @weakify(self)
    [[tapGestureRecognizer rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
        @strongify(self)
        if (self.delegate && [self.delegate respondsToSelector:@selector(messageCellClickGroupNotice:)]) {
            [self.delegate messageCellClickGroupNotice:self.cellIndex];
        }
    }];
}

- (void)setConfigMessage:(NoaMessageModel *)model {
    [super setConfigMessage:model];
    
    _viewGroupNotice.frame = _contentRect;
    NSMutableAttributedString *groupNoticeAttr = [model.attStr mutableCopy];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 2;
    style.lineBreakMode = NSLineBreakByTruncatingTail;//设置为abc...后会高度计算不准确
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:16],NSParagraphStyleAttributeName:[style copy]};
    [groupNoticeAttr addAttributes:dict range:NSMakeRange(0, groupNoticeAttr.length)];
    _lblGroupNotice.attributedText = groupNoticeAttr;
    //气泡背景色
    WeakSelf
    [self setTkThemeChangeBlock:^(id  _Nullable itself, NSUInteger themeIndex) {
        //0浅色 ， 暗黑
        if (themeIndex == 0) {
            weakSelf.viewSendBubble.bgFillColor = COLORWHITE;
        }else {
            weakSelf.viewSendBubble.bgFillColor = COLORWHITE_DARK;
        }
    }];
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
