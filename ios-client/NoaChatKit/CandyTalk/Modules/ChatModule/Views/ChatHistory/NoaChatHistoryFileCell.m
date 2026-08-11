//
//  NoaChatHistoryFileCell.m
//  NoaKit
//
//  Created by Candy on 2023/2/2.
//

#import "NoaChatHistoryFileCell.h"
//#import <YYText/YYText.h>
#import "NoaMessageTimeTool.h"
@interface NoaChatHistoryFileCell ()
@property (nonatomic, strong) UIImageView *fileHeader;//文件头像
@property (nonatomic, strong) UILabel *lblFileType;//文件类型
@property (nonatomic, strong) UILabel *lblFilename;//文件名称
@property (nonatomic, strong) UILabel *lblFileDetail;//文件大小、发送人、时间

@property (nonatomic, strong) NoaIMChatMessageModel *chatMessageModel;
@property (nonatomic, copy) NSString *searchStr;
@end

@implementation NoaChatHistoryFileCell

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
    [self addSubview:_viewBg];
    
    _fileHeader = [[UIImageView alloc] initWithFrame:CGRectMake(DWScale(24), DWScale(14), DWScale(32), DWScale(40))];
    [self addSubview:_fileHeader];
    [_fileHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading).offset(DWScale(24));
        make.top.equalTo(self.mas_top).offset(DWScale(14));
        make.size.mas_equalTo(CGSizeMake(DWScale(32), DWScale(40)));
    }];
    
    _lblFileType = [UILabel new];
    _lblFileType.tkThemetextColors = @[COLORWHITE, COLORWHITE_DARK];
    _lblFileType.font = FONTR(10);
    _lblFileType.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_lblFileType];
    [_lblFileType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(_fileHeader);
        make.bottom.equalTo(_fileHeader).offset(-DWScale(5));
    }];
    
    _lblFilename = [UILabel new];
    _lblFilename.font = FONTR(16);
    _lblFilename.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [self addSubview:_lblFilename];
    [_lblFilename mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(_fileHeader.mas_trailing).offset(DWScale(16));
        make.trailing.mas_equalTo(self).offset(-DWScale(16));
        make.top.mas_equalTo(DWScale(12));
        make.height.mas_equalTo(DWScale(22));
    }];

    _lblFileDetail = [UILabel new];
    _lblFileDetail.font = FONTR(12);
    _lblFileDetail.tkThemetextColors = @[COLOR_66, COLOR_99];
    [self addSubview:_lblFileDetail];
    [_lblFileDetail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(_fileHeader.mas_trailing).offset(DWScale(16));
        make.top.mas_equalTo(_lblFilename.mas_bottom).offset(DWScale(4));
        make.height.mas_equalTo(DWScale(18));
    }];
}
#pragma mark - 交互事件
- (void)cellTouchAction {
    if ([self.cellDelegate respondsToSelector:@selector(cellClickAction:)]) {
        [self.cellDelegate cellClickAction:self.cellIndexPath];
    }
}

#pragma mark - 界面赋值
- (void)configCellWith:(NoaIMChatMessageModel *)chatMessageModel searchContent:(NSString *)searchStr {
    _chatMessageModel = chatMessageModel;
    _searchStr = searchStr;
    
    _fileHeader.image = [UIImage getFileMessageIconWithFileType:chatMessageModel.fileType fileName:chatMessageModel.fileName];
    _lblFileType.text = [NSString getFileTypeContentWithFileType:chatMessageModel.fileType fileName:chatMessageModel.fileName];
    
    NSDate *msgTime = [NSDate dateWithTimeIntervalSince1970:chatMessageModel.sendTime / 1000];
    NSString * timeStr = [NoaMessageTimeTool getTimeStringAutoShort2:msgTime mustIncludeTime:YES];
    NSString * fileSize = [NSString fileTranslateToSize:chatMessageModel.fileSize];
    _lblFileDetail.text = [NSString stringWithFormat:@"%@ %@ %@",fileSize,chatMessageModel.fromNickname,timeStr];
    
    if(![NSString isNil:chatMessageModel.fileName]){
        /*
        NSString * fileName;
        NSRange range = [chatMessageModel.fileName rangeOfString:@"-"];
        if(range.length == 0){
            fileName = chatMessageModel.fileName;
        }else{
            fileName = [chatMessageModel.fileName substringWithRange:NSMakeRange(range.location+1, chatMessageModel.fileName.length - (range.location+1))];
        }
        */
        __block NSMutableAttributedString *attStrName = [[NSMutableAttributedString alloc] initWithString:chatMessageModel.showFileName];
        attStrName.yy_font = FONTR(16);
        self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
            switch (themeIndex) {
                case 1:
                {
                    //暗黑
                    attStrName.yy_color = COLOR_11_DARK;
                }
                    break;
                    
                default:
                {
                    //浅色
                    attStrName.yy_color = COLOR_11;
                }
                    break;
            }
        };
        if (![NSString isNil:searchStr]) {
            NSRange rangeName = [chatMessageModel.showFileName rangeOfString:searchStr options:NSCaseInsensitiveSearch];//不区分大小写
            [attStrName yy_setFont:FONTR(16) range:rangeName];
            [attStrName yy_setColor:COLOR_5966F2 range:rangeName];
        }
        _lblFilename.attributedText = attStrName;
    }else{
        _lblFilename.text = @"";
    }
}

+ (CGFloat)defaultCellHeight {
    return DWScale(68);
}

+(NSString *)cellIdentifier{
    return @"NoaChatHistoryFileCell";
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
