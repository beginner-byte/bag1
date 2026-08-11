//
//  NoaChatSetGroupNoteCell.m
//  NoaKit
//
//  Created by Candy on 2026/11/5.
//

#import "NoaChatSetGroupNoteCell.h"

@interface NoaChatSetGroupNoteCell ()
//@property (nonatomic, strong) UILabel *lblGroupNote
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIButton * viewBg;
@property (nonatomic, strong) UILabel *lblNote;
@end

@implementation NoaChatSetGroupNoteCell
static UILabel *_lblGroupNote = nil;

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
    
    self.viewBg = [UIButton buttonWithType:UIButtonTypeCustom];
//    viewBg.frame = CGRectMake(DWScale(16), 0, DScreenWidth - DWScale(32), DWScale(84));
    self.viewBg.tkThemebackgroundColors =  @[COLORWHITE, COLOR_F5F6F9_DARK];
    [self.viewBg setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE]] forState:UIControlStateSelected];
    [self.viewBg setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE]] forState:UIControlStateHighlighted];
    [self.viewBg addTarget:self action:@selector(cellTouchAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.viewBg];
    
    [self.viewBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.leading.mas_equalTo(DWScale(16));
        make.width.mas_equalTo(DScreenWidth - DWScale(32));
        make.bottom.mas_equalTo(self.contentView);
    }];
    
    self.lineView = [[UIView alloc] init];
    self.lineView.tkThemebackgroundColors = @[COLOR_EEEEEE,COLOR_555555];
    [self.viewBg addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.viewBg);
        make.leading.equalTo(self.viewBg).offset(DWScale(16));
        make.trailing.equalTo(self.viewBg).offset(-DWScale(16));
        make.height.mas_equalTo(1.0);
    }];
 
    
    self.lblNote = [UILabel new];
    self.lblNote.text = LanguageToolMatch(@"群公告");
    self.lblNote.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    self.lblNote.font = FONTR(16);
    [self.viewBg addSubview:self.lblNote];
    [self.lblNote mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.viewBg).offset(DWScale(16));
        make.top.equalTo(self.viewBg).offset(DWScale(16));
        make.height.mas_equalTo(DWScale(22));
    }];
    
    UIImageView *ivArrow = [[UIImageView alloc] initWithImage:ImgNamed(@"c_arrow_right_gray")];
    [self.viewBg addSubview:ivArrow];
    [ivArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.lblNote);
        make.trailing.equalTo(self.viewBg).offset(-DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(8), DWScale(16)));
    }];
    
    _lblGroupNote = [UILabel new];
    _lblGroupNote.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    _lblGroupNote.font = FONTR(14);
    _lblGroupNote.text = LanguageToolMatch(@"暂无公告");
    _lblGroupNote.numberOfLines = 0;
    [self.viewBg addSubview:_lblGroupNote];
    [_lblGroupNote mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.viewBg).offset(DWScale(16));
        make.top.equalTo(self.lblNote.mas_bottom).offset(DWScale(10));
        make.trailing.equalTo(self.viewBg).offset(-DWScale(16));
    }];
    
}
#pragma mark - 交互事件
- (void)cellTouchAction {
    if ([self.baseDelegate respondsToSelector:@selector(cellClickAction:)]) {
        [self.baseDelegate cellClickAction:self.baseCellIndexPath];
    }
}

#pragma mark - 界面赋值
- (void)setGroupModel:(LingIMGroup *)groupModel {
    _groupModel = groupModel;
    if (_groupModel) {
        if (![NSString isNil:groupModel.groupNotice.groupId]) {
            //处理公告文字内容
            NSString *groupNoticeStr = @"";
            if (![NSString isNil:_groupModel.groupNotice.translateContent]) {
                NSString *currentLanguageMapCode = [ZLanguageTOOL languageCodeFromDevieInfo];
                NSDictionary *noticeDict = [NSString  jsonStringToDic:_groupModel.groupNotice.translateContent];
                if (![[noticeDict allKeys] containsObject:currentLanguageMapCode]) {
                    if ([currentLanguageMapCode isEqualToString:@"lb"]) {
                        groupNoticeStr = (NSString *)[noticeDict objectForKeySafe:@"lbb"];
                    } else if ([currentLanguageMapCode isEqualToString:@"no"]) {
                        groupNoticeStr = (NSString *)[noticeDict objectForKeySafe:@"nor"];
                    } else {
                        NSString *notice_en = (NSString *)[noticeDict objectForKeySafe:@"en"];
                        groupNoticeStr = notice_en;
                    }
                } else {
                    NSString *notice_current = (NSString *)[noticeDict objectForKeySafe:currentLanguageMapCode];
                    groupNoticeStr = notice_current;
                }
            } else {
                groupNoticeStr = ![NSString isNil:_groupModel.groupNotice.content] ? _groupModel.groupNotice.content : LanguageToolMatch(@"群公告");
            }
            _lblGroupNote.text = groupNoticeStr;
        }else {
            _lblGroupNote.text = LanguageToolMatch(@"暂无公告");
        }
        
        CGSize noteSize = [_lblGroupNote.text sizeWithFont:FONTR(14) constrainedToSize:CGSizeMake(DScreenWidth - DWScale(32)-DWScale(32), 1000)];
        _lblGroupNote.numberOfLines = 0;
        [_lblGroupNote mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.viewBg).offset(DWScale(16));
            make.top.equalTo(self.lblNote.mas_bottom).offset(DWScale(10));
            if(noteSize.height>65){
                make.height.mas_equalTo(65);
            }else{
                make.height.mas_equalTo(noteSize.height);
            }
            make.trailing.equalTo(self.viewBg).offset(-DWScale(16));
        }];
        
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (CGRectIsEmpty(self.viewBg.bounds)) {
        return;
    }
    [self.viewBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.leading.mas_equalTo(DWScale(16));
        make.width.mas_equalTo(DScreenWidth - DWScale(32));
        make.bottom.mas_equalTo(self.contentView);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.viewBg round:DWScale(12) RectCorners:self.isShowLine ? UIRectCornerBottomLeft | UIRectCornerBottomRight : UIRectCornerAllCorners];
    });
}

- (void)setIsShowLine:(BOOL)isShowLine {
    _isShowLine = isShowLine;
    self.lineView.hidden = !isShowLine;
//    [self.viewBg round:DWScale(12) RectCorners:isShowLine ? UIRectCornerBottomLeft | UIRectCornerBottomRight : UIRectCornerAllCorners];
}
+ (CGFloat)defaultCellHeight {
    
    CGSize noteSize = [_lblGroupNote.text sizeWithFont:FONTR(14) constrainedToSize:CGSizeMake(DScreenWidth - DWScale(32)-DWScale(32), 1000)];
    return DWScale(16)+DWScale(22)+DWScale(10)+(noteSize.height>DWScale(55)? DWScale(55):noteSize.height)+DWScale(10);
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
