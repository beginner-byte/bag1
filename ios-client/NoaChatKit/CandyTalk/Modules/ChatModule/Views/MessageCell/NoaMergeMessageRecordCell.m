//
//  NoaMergeMessageRecordCell.m
//  NoaKit
//
//  Created by Candy on 2023/4/25.
//

#import "NoaMergeMessageRecordCell.h"
#import "NSString+SessionLatestMessage.h"

@implementation NoaMergeMessageRecordCell
{
    UIImageView *_recordTipsImgView;
    UILabel *_recordTitleLab;
    UILabel *_recordContentLab1;
    UILabel *_recordContentLab2;
    UILabel *_recordContentLab3;
    UILabel *_recordContentLab4;
    NSMutableArray *_recordContentLblArr;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupMessageRecordUI];
    }
    return self;
}

#pragma mark - UI布局
- (void)setupMessageRecordUI {
    _recordTitleLab = [[UILabel alloc] init];
    _recordTitleLab.text = @"";
    _recordTitleLab.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _recordTitleLab.font = FONTN(16);
    _recordTitleLab.textAlignment = NSTextAlignmentLeft;
    _recordTitleLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [self.contentView addSubview:_recordTitleLab];
    
    _recordTipsImgView = [[UIImageView alloc] init];
    _recordTipsImgView.image = ImgNamed(@"m_msg_record_tips");
    [self.contentView addSubview:_recordTipsImgView];
    [_recordTipsImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.viewReceiveBubble).offset(10);
        make.centerY.equalTo(_recordTitleLab);
        make.width.mas_equalTo(DWScale(3));
        make.height.mas_equalTo(DWScale(14));
    }];
    
    _recordContentLblArr = [[NSMutableArray alloc] init];
    
    _recordContentLab1 = [[UILabel alloc] init];
    _recordContentLab1.text = @"";
    _recordContentLab1.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    _recordContentLab1.font = FONTN(10);
    _recordContentLab1.hidden = YES;
    _recordContentLab1.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_recordContentLab1];
    [_recordContentLblArr addObject:_recordContentLab1];
    [_recordContentLab1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_recordTitleLab.mas_bottom).offset(DWScale(6));
        make.leading.equalTo(_recordTipsImgView);
        make.trailing.equalTo(_recordTitleLab);
        make.height.mas_equalTo(DWScale(16));
    }];
    
    
    _recordContentLab2 = [[UILabel alloc] init];
    _recordContentLab2.text = @"";
    _recordContentLab2.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    _recordContentLab2.font = FONTN(10);
    _recordContentLab2.hidden = YES;
    _recordContentLab2.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_recordContentLab2];
    [_recordContentLblArr addObject:_recordContentLab2];
    [_recordContentLab2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_recordContentLab1.mas_bottom).offset(DWScale(1));
        make.leading.equalTo(_recordTipsImgView);
        make.trailing.equalTo(_recordTitleLab);
        make.height.mas_equalTo(DWScale(16));
    }];
    
    _recordContentLab3 = [[UILabel alloc] init];
    _recordContentLab3.text = @"";
    _recordContentLab3.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    _recordContentLab3.font = FONTN(10);
    _recordContentLab3.hidden = YES;
    _recordContentLab3.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_recordContentLab3];
    [_recordContentLblArr addObject:_recordContentLab3];
    [_recordContentLab3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_recordContentLab2.mas_bottom).offset(DWScale(1));
        make.leading.equalTo(_recordTipsImgView);
        make.trailing.equalTo(_recordTitleLab);
        make.height.mas_equalTo(DWScale(16));
    }];
    
    _recordContentLab4 = [[UILabel alloc] init];
    _recordContentLab4.text = @"";
    _recordContentLab4.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    _recordContentLab4.font = FONTN(10);
    _recordContentLab4.hidden = YES;
    _recordContentLab4.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_recordContentLab4];
    [_recordContentLblArr addObject:_recordContentLab4];
    [_recordContentLab4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_recordContentLab3.mas_bottom).offset(DWScale(1));
        make.leading.equalTo(_recordTipsImgView);
        make.trailing.equalTo(_recordTitleLab);
        make.height.mas_equalTo(DWScale(16));
    }];
}

- (void)setConfigMessage:(NoaMessageModel *)model {
    [super setConfigMessage:model];
    
    _recordContentLab1.hidden = YES;
    _recordContentLab2.hidden = YES;
    _recordContentLab3.hidden = YES;
    _recordContentLab4.hidden = YES;
    
    _recordTitleLab.frame = _contentRect;
    
    if (model.isSelf) {
        [_recordTipsImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.viewSendBubble).offset(10);
            make.centerY.equalTo(_recordTitleLab);
            make.width.mas_equalTo(DWScale(3));
            make.height.mas_equalTo(DWScale(14));
        }];
    } else {
        [_recordTipsImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.viewReceiveBubble).offset(10);
            make.centerY.equalTo(_recordTitleLab);
            make.width.mas_equalTo(DWScale(3));
            make.height.mas_equalTo(DWScale(14));
        }];
    }
    
    _recordTitleLab.text = LanguageToolMatch(model.message.forwardMessage.title);
    //最多展示4条
    NSInteger max_num = model.message.forwardMessage.messageListArray.count > 4 ? 4 : model.message.forwardMessage.messageListArray.count;
    for (int i=0; i<max_num; i++) {
        IMChatMessage *imChatMessage = (IMChatMessage *)[model.message.forwardMessage.messageListArray objectAtIndex:i];
        UILabel *recordContentLab = (UILabel *)[_recordContentLblArr objectAtIndex:i];
        recordContentLab.hidden = NO;
        recordContentLab.attributedText = [NSString getMessageRecordAttributedStringWith:imChatMessage];
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
